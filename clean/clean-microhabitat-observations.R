# Clean Feather River microhabitat data

# This script checks and cleans the following fields:
#   - dates
#   - negative values
#   - percent ranges
#   - controlled species vocabulary
#   - controlled geomorphic unit vocabulary
# 
# After checks and cleaning, clean data are saved along with an issue log and
# diagnostic outputs. Doing so documents dataset quality and provenance.
#
# Comments are included throughout to explain the rationale and implementation
# of this code so as to serve as a tutorial. 

# ==============================================================================
# Set up and run options ----
# ==============================================================================

# Attach HRL data publication package to get data cleaning functions
library(hrlpub)

# Set TRUE for more console output
verbose <- FALSE


# ==============================================================================
# Data import ----
# ==============================================================================

# Establish file paths
raw_path <- "data/raw/microhabitat_observations_raw.csv"
clean_path <- "data/clean/microhabitat_observations_clean.csv"
issues_path <- "data/clean/microhabitat_observations_issue_summary.csv"
diagnostics_dir <- "data/clean/diagnostics"
dir.create(diagnostics_dir, showWarnings = FALSE, recursive = TRUE)

# Read raw data and keep dates as character to profile formats first
raw <- readr::read_csv(
  raw_path,
  col_names = TRUE,
  show_col_types = FALSE,
  na = c("", "NA"),
  col_types = readr::cols(date = readr::col_character())
)


# ==============================================================================
# Data exploration and cleaning ----
# ==============================================================================

# Take a look at the data prior to any cleaning
if (verbose) {
  dplyr::glimpse(raw)
}

# Establish the total row count for prevalence calculations
n_total <- nrow(raw)

# Initialize an issue log
issue_log <- tibble::tibble()


# ==============================================================================
# Date cleaning ----
# ==============================================================================

# Profile raw date formats before parsing
raw <- raw |>
  dplyr::mutate(
    date_format_raw = dplyr::case_when(
      stringr::str_detect(date, "^\\d{4}-\\d{2}-\\d{2}$") ~ "yyyy-mm-dd",
      stringr::str_detect(date, "^\\d{2}/\\d{2}/\\d{4}$") ~ "mm/dd/yyyy",
      stringr::str_detect(date, "^\\d{2}-\\d{2}-\\d{4}$") ~ "dd-mm-yyyy",
      is.na(date) ~ "missing",
      TRUE ~ "other"
    )
  )

date_format_counts <- raw |>
  dplyr::count(date_format_raw, name = "rows") |>
  dplyr::mutate(prevalence = round(rows / n_total, 4))

if (verbose) {
  hrlpub::print_table("Date format counts:", date_format_counts)
}

# Parse dates with multiple format fallbacks
raw <- raw |>
  dplyr::mutate(date_original = date) |>
  dplyr::mutate(
    date_parsed = suppressWarnings(
      lubridate::parse_date_time(date, orders = c("ymd", "mdy", "dmy"))
    ),
    date = lubridate::as_date(date_parsed)
  )

# Split date quality outcomes into missing vs unparsable values
date_missing_details <- raw |>
  dplyr::filter(is.na(date_original)) |>
  dplyr::select(micro_hab_data_tbl_id, date_original, date_format_raw)

date_parse_failures <- raw |>
  dplyr::filter(!is.na(date_original), is.na(date)) |>
  dplyr::select(micro_hab_data_tbl_id, date_original, date_format_raw)

# Log date parsing info
hrlpub::log_info("Date values missing in raw data: ", nrow(date_missing_details))
hrlpub::log_info("Date parse failures: ", nrow(date_parse_failures))

issue_log <- dplyr::bind_rows(
  issue_log,
  hrlpub::log_issue(
    issue = "date_missing_or_not_provided",
    rows_affected = nrow(date_missing_details),
    action = "Left as NA when missing in raw date field",
    n_total = n_total,
    details_path = file.path(diagnostics_dir, "microhabitat_date_missing_or_not_provided.csv")
  ),
  hrlpub::log_issue(
    issue = "date_parse_failed",
    rows_affected = nrow(date_parse_failures),
    action = "Parsed with ymd/mdy/dmy; unparsable non-missing entries coerced to NA",
    n_total = n_total,
    details_path = file.path(diagnostics_dir, "microhabitat_date_parse_failures.csv")
  ),
  hrlpub::log_issue(
    issue = "date_formats_profiled",
    rows_affected = n_total,
    action = "Raw date formats counted; see diagnostics",
    n_total = n_total,
    details_path = file.path(diagnostics_dir, "microhabitat_date_format_counts.csv")
  )
)

# ==============================================================================
# Negative and percent cleaning ----
# ==============================================================================

# Identify numeric columns that should not have negative values and clean percent
# columns to the 0-100 range
negative_cols <- c("count", "fl_mm", "dist_to_bottom", "depth", "focal_velocity", "velocity")
percent_cols <- names(raw)[stringr::str_starts(names(raw), "percent_")]

# Run standard basic checks to identify any negative values and percentages
# outside of a 0% to 100% expected range
if (verbose) {
  clean_checks <- hrlpub::run_clean_checks(
    data = raw,
    dataset_name = "microhabitat",
    negative_cols = negative_cols,
    percent_cols = percent_cols,
    verbose = TRUE
  )
} else {
  invisible(utils::capture.output(
    clean_checks <- hrlpub::run_clean_checks(
      data = raw,
      dataset_name = "microhabitat",
      negative_cols = negative_cols,
      percent_cols = percent_cols,
      verbose = FALSE
    ),
    type = "message"
  ))
}

issue_log <- issue_log |>
  dplyr::bind_rows(clean_checks$issue_log)

negative_details <- clean_checks$negative_details
percent_details <- clean_checks$percent_details

# Clean negative values by setting them to NA using the declared negative_cols
raw <- raw |>
  dplyr::mutate(
    dplyr::across(
      dplyr::all_of(negative_cols),
      ~ replace(.x, !is.na(.x) & .x < 0, NA)
    )
  )


# ==============================================================================
# Species names ----
# ==============================================================================

# Check unique species values in the raw dataset column
unique_species_values <- sort(unique(raw$species[!is.na(raw$species)]))
if (verbose) {
  unique_species_values
}

# Specify a controlled vocabulary for species
species_vocab <- c(
  "chinook salmon",
  "steelhead trout (wild)",
  "steelhead trout (clipped)",
  "sacramento pikeminnow",
  "speckled dace",
  "tule perch"
)

# Map known misspellings and label variants to canonical species names
species_map <- tibble::tribble(
  ~raw_value,                    ~clean_value,
  "chinok salmon",              "chinook salmon",
  "chinook salmon",             "chinook salmon",
  "sacramento pikeminnow",      "sacramento pikeminnow",
  "speckled dace",              "speckled dace",
  "steelhead trout (wild)",     "steelhead trout (wild)",
  "steelhead trout (wlid)",     "steelhead trout (wild)",
  "steelhead trout, (clipped)", "steelhead trout (clipped)",
  "steelhed trout (wild)",      "steelhead trout (wild)",
  "tule perch",                 "tule perch"
)

# Ensure map keys are unique to avoid many-to-many joins and row multiplication
if (anyDuplicated(species_map$raw_value) > 0) {
  stop("species_map has duplicate raw_value entries. Each raw_value must map to exactly one clean_value.")
}

# Apply the controlled vocabulary
raw <- raw |>
  dplyr::mutate(
    species_original = species,              # Retain original labels before any normalization and correction
    species_norm = species |>
      stringr::str_replace_all(",", "") |>   # Remove commas
      stringr::str_squish() |>               # Trim leading, trailing, and multiple spaces
      stringr::str_to_lower()                # Convert everything to lowercase
  ) |>
  # Add corrected species names where a known mapping exists
  dplyr::left_join(species_map, by = c("species_norm" = "raw_value")) |>
  # Use corrected names where available; otherwise keep normalized values
  dplyr::mutate(species = dplyr::coalesce(clean_value, species_norm)) |>
  dplyr::mutate(
    species = dplyr::if_else(
      !is.na(species) & !species %in% species_vocab,
      # Use NA values where there isn't a recognized or corrected value
      NA_character_,
      species
    )
  ) |>
  dplyr::select(-species_norm, -clean_value) # Drop unnecessary processing columns

species_standardized_details <- raw |>
  # Retain only rows where there is an original species label, a final
  # (cleaned) label exists, and the final value differs from the original
  dplyr::filter(
    !is.na(species_original),
    !is.na(species),
    species_original != species
  ) |>
  dplyr::select(micro_hab_data_tbl_id, species_original, species_clean = species)

# Address missing or unrecognized species labels left as NA
# This includes observations where no fish were recorded.
species_missing_details <- raw |>
  dplyr::filter(is.na(species)) |>
  dplyr::select(micro_hab_data_tbl_id, species_original, date)

species_fixed <- nrow(species_standardized_details)
species_missing_or_dropped <- nrow(species_missing_details)

# Log species standardization
hrlpub::log_info("Species standardized: ", species_fixed)
hrlpub::log_info("Species missing or unrecognized: ", species_missing_or_dropped)

if (species_fixed > 0) {
  issue_log <- dplyr::bind_rows(
    issue_log,
    hrlpub::log_issue(
      issue = "species_standardized",
      rows_affected = species_fixed,
      action = "Standardized to controlled vocabulary",
      n_total = n_total,
      details_path = file.path(diagnostics_dir, "microhabitat_species_standardized_details.csv")
    )
  )
}

issue_log <- dplyr::bind_rows(
  issue_log,
  hrlpub::log_issue(
    issue = "species_missing_or_not_provided",
    rows_affected = species_missing_or_dropped,
    action = "Left as NA when missing or unrecognized (includes observations with no fish observed)",
    n_total = n_total,
    details_path = file.path(diagnostics_dir, "microhabitat_species_missing_or_unrecognized.csv")
  )
)

# Drop temporary processing columns before writing outputs
raw <- raw |> dplyr::select(-species_original)


# ==============================================================================
# Geomorphic labels ----
# ==============================================================================

# Check unique geomorphic unit values in the raw dataset column
unique_geomorphic_unit_values <- sort(unique(raw$channel_geomorphic_unit[!is.na(raw$channel_geomorphic_unit)]))
if (verbose) {
  unique_geomorphic_unit_values
}

# Establish a controlled vocabulary for channel geomorphic unit
channel_vocab <- c(
  "glide",
  "glide margin",
  "riffle",
  "riffle margin",
  "pool",
  "backwater"
)

# Map known misspellings and label variants to canonical geomorphic labels
channel_map <- tibble::tribble(
  ~raw_value,      ~clean_value,
  "gilde margin",  "glide margin",
  "glide marginn", "glide margin",
  "poo1",          "pool",
  "pool",          "pool"
)

# Ensure map keys are unique to avoid many-to-many joins and row multiplication
if (anyDuplicated(channel_map$raw_value) > 0) {
  stop("channel_map has duplicate raw_value entries. Each raw_value must map to exactly one clean_value.")
}

raw <- raw |>
  # Retain original labels before any normalization and correction
  dplyr::mutate(channel_original = channel_geomorphic_unit) |>
  dplyr::mutate(
    channel_norm = channel_geomorphic_unit |>
      stringr::str_squish() |>   # Trim leading, trailing, and repeated spaces
      stringr::str_to_lower()    # Convert everything to lowercase
  ) |>
  # Add corrected geomorphic labels where a known mapping exists
  dplyr::left_join(channel_map, by = c("channel_norm" = "raw_value")) |>
  # Use corrected labels where available; otherwise keep normalized values
  dplyr::mutate(channel_geomorphic_unit = dplyr::coalesce(clean_value, channel_norm)) |>
  dplyr::mutate(
    channel_geomorphic_unit = dplyr::if_else(
      !is.na(channel_geomorphic_unit) & !channel_geomorphic_unit %in% channel_vocab,
      # Use NA values where there isn't a recognized or corrected value
      NA_character_,
      channel_geomorphic_unit
    )
  ) |>
  dplyr::select(-channel_norm, -clean_value) # Drop unnecessary processing columns

channel_standardized_details <- raw |>
  # Retain only rows where there is an original channel label, a final (cleaned)
  # label exists, and the original value was normalized
  dplyr::filter(
    !is.na(channel_original),
    !is.na(channel_geomorphic_unit),
    channel_original |> stringr::str_squish() |> stringr::str_to_lower() != channel_geomorphic_unit
  ) |>
  dplyr::select(micro_hab_data_tbl_id, channel_original, channel_clean = channel_geomorphic_unit)

# Address missing or unrecognized channel labels left as NA
channel_missing_details <- raw |>
  dplyr::filter(is.na(channel_geomorphic_unit)) |>
  dplyr::select(micro_hab_data_tbl_id, channel_original, date)

channel_fixed <- nrow(channel_standardized_details)
channel_missing_or_dropped <- nrow(channel_missing_details)

# Log channel unit standardization
hrlpub::log_info("Channel units standardized: ", channel_fixed)
hrlpub::log_info("Channel units missing or unrecognized: ", channel_missing_or_dropped)

if (channel_fixed > 0) {
  issue_log <- dplyr::bind_rows(
    issue_log,
    hrlpub::log_issue(
      issue = "channel_standardized",
      rows_affected = channel_fixed,
      action = "Standardized to controlled vocabulary",
      n_total = n_total,
      details_path = file.path(diagnostics_dir, "microhabitat_channel_standardized_details.csv")
    )
  )
}

issue_log <- dplyr::bind_rows(
  issue_log,
  hrlpub::log_issue(
    issue = "channel_missing_or_not_provided",
    rows_affected = channel_missing_or_dropped,
    action = "Left as NA when missing or unrecognized",
    n_total = n_total,
    details_path = file.path(diagnostics_dir, "microhabitat_channel_missing_or_unrecognized.csv")
  )
)

# Drop temporary processing columns before writing outputs
raw <- raw |> dplyr::select(
  -date_original,
  -date_parsed,
  -date_format_raw,
  -channel_original
)

# Persist outputs
readr::write_csv(raw, clean_path, na = "")
readr::write_csv(issue_log, issues_path)

# Write diagnostics
readr::write_csv(
  date_format_counts,
  file.path(diagnostics_dir, "microhabitat_date_format_counts.csv")
)

if (nrow(date_parse_failures) > 0) {
  readr::write_csv(
    date_parse_failures,
    file.path(diagnostics_dir, "microhabitat_date_parse_failures.csv")
  )
}

if (nrow(date_missing_details) > 0) {
  readr::write_csv(
    date_missing_details,
    file.path(diagnostics_dir, "microhabitat_date_missing_or_not_provided.csv")
  )
}

if (nrow(species_standardized_details) > 0) {
  readr::write_csv(
    species_standardized_details,
    file.path(diagnostics_dir, "microhabitat_species_standardized_details.csv")
  )
}

if (nrow(species_missing_details) > 0) {
  readr::write_csv(
    species_missing_details,
    file.path(diagnostics_dir, "microhabitat_species_missing_or_unrecognized.csv")
  )
}

if (nrow(channel_standardized_details) > 0) {
  readr::write_csv(
    channel_standardized_details,
    file.path(diagnostics_dir, "microhabitat_channel_standardized_details.csv")
  )
}

if (nrow(channel_missing_details) > 0) {
  readr::write_csv(
    channel_missing_details,
    file.path(diagnostics_dir, "microhabitat_channel_missing_or_unrecognized.csv")
  )
}

message("Cleaned data written to: ", clean_path)
message("Issue summary written to: ", issues_path)

outputs <- c(clean_path, issues_path, list.files(diagnostics_dir, full.names = TRUE))
invisible(outputs)
