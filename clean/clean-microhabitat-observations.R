# Run options ------------------------------------------------------------------
# Set TRUE for more console output
verbose <- FALSE

# Helper functions -------------------------------------------------------------
# Print a message only when verbose is TRUE
log_info <- function(...) {
  if (isTRUE(verbose)) {
    message(...)
  }
}

# Print a label and a table only when verbose is TRUE
print_table <- function(label, x) {
  if (isTRUE(verbose)) {
    message(label)
    print(x)
  }
}

# Log an issue row with prevalence calculated from total dataframe rows (n_total) in this script
log_issue <- function(issue, rows_affected, action, details_path = NA_character_) {
  tibble::tibble(
    issue = issue,
    rows_affected = rows_affected,
    prevalence = if (n_total > 0) round(rows_affected / n_total, 4) else NA_real_,
    action = action,
    details_path = details_path
  )
}

# Clean negative numeric values, log issues, and capture diagnostics
clean_negative_values <- function(data, cols, diagnostics_dir, issue_log) {
  negative_details <- list()

  for (col in cols) {
    negative_rows <- which(!is.na(data[[col]]) & data[[col]] < 0)
    n_bad <- length(negative_rows)
    if (n_bad > 0) {
      negative_details[[col]] <- tibble::tibble(
        micro_hab_data_tbl_id = data$micro_hab_data_tbl_id[negative_rows],
        variable = col,
        value = data[[col]][negative_rows]
      )
    }
    data[[col]] <- ifelse(data[[col]] < 0, NA, data[[col]])
    if (n_bad > 0) {
      issue_log <- dplyr::bind_rows(
        issue_log,
        log_issue(
          paste0(col, "_negative"),
          n_bad,
          "Negative values set to NA",
          details_path = file.path(diagnostics_dir, paste0("microhabitat_negative_", col, ".csv"))
        )
      )
    }
  }

  if (isTRUE(verbose)) {
    if (length(negative_details) > 0) {
      negative_summary <- data.frame(
        variable = names(negative_details),
        rows = vapply(negative_details, nrow, integer(1)),
        row.names = NULL
      )
      print_table("Negative value counts by variable:", negative_summary)
    } else {
      log_info("Negative value counts by variable: 0")
    }
  }

  list(raw = data, issue_log = issue_log, negative_details = negative_details)
}

# Clean percent columns to the 0-100 range, log issues, and capture diagnostics
clean_percent_ranges <- function(data, cols, diagnostics_dir, issue_log) {
  percent_details <- list()

  for (col in cols) {
    out_of_range <- which(!is.na(data[[col]]) & (data[[col]] < 0 | data[[col]] > 100))
    n_bad <- length(out_of_range)
    if (n_bad > 0) {
      percent_details[[col]] <- tibble::tibble(
        micro_hab_data_tbl_id = data$micro_hab_data_tbl_id[out_of_range],
        variable = col,
        value = data[[col]][out_of_range]
      )
    }
    data[[col]] <- ifelse(!is.na(data[[col]]) & (data[[col]] < 0 | data[[col]] > 100), NA, data[[col]])
    if (n_bad > 0) {
      issue_log <- dplyr::bind_rows(
        issue_log,
        log_issue(
          paste0(col, "_out_of_range"),
          n_bad,
          "Percent values outside 0-100 set to NA",
          details_path = file.path(diagnostics_dir, paste0("microhabitat_percent_out_of_range_", col, ".csv"))
        )
      )
    }
  }

  if (isTRUE(verbose)) {
    if (length(percent_details) > 0) {
      percent_summary <- data.frame(
        variable = names(percent_details),
        rows = vapply(percent_details, nrow, integer(1)),
        row.names = NULL
      )
      print_table("Percent out-of-range counts by variable:", percent_summary)
    } else {
      log_info("Percent out-of-range counts by variable: 0")
    }
  }

  list(raw = data, issue_log = issue_log, percent_details = percent_details)
}

# Data import ------------------------------------------------------------------
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

# Data exploration and cleaning ------------------------------------------------
# Take a look at the data prior to any cleaning
dplyr::glimpse(raw)

# Establish the total row count for prevalence calculations
n_total <- nrow(raw)

# Initialize an issue log
issue_log <- tibble::tibble()

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

print_table("Date format counts:", date_format_counts)

# Parse dates with multiple format fallbacks
raw <- raw |>
  dplyr::mutate(date_original = date) |>
  dplyr::mutate(
    date_parsed = lubridate::parse_date_time(date, orders = c("ymd", "mdy", "dmy")),
    date = lubridate::as_date(date_parsed)
  )

date_parse_failures <- raw |>
  dplyr::filter(is.na(date)) |>
  dplyr::select(micro_hab_data_tbl_id, date_original, date_format_raw)

log_info("Date parse failures: ", nrow(date_parse_failures))

issue_log <- dplyr::bind_rows(
  issue_log,
  log_issue(
    "date_parse_failed",
    sum(is.na(raw$date)),
    "Parsed with ymd/mdy/dmy; invalid entries coerced to NA",
    details_path = file.path(diagnostics_dir, "microhabitat_date_parse_failures.csv")
  ),
  log_issue(
    "date_formats_profiled",
    n_total,
    "Raw date formats counted; see diagnostics",
    details_path = file.path(diagnostics_dir, "microhabitat_date_format_counts.csv")
  )
)

# Identify numeric columns that should not have negative values
negative_cols <- c("count", "fl_mm", "dist_to_bottom", "depth", "focal_velocity", "velocity")

# Clean negative numeric values by setting to NA and capturing details
negative_results <- clean_negative_values(raw, negative_cols, diagnostics_dir, issue_log)
raw <- negative_results$raw
issue_log <- negative_results$issue_log
negative_details <- negative_results$negative_details

# Clean percent columns to the 0-100 range
percent_cols <- names(raw)[stringr::str_starts(names(raw), "percent_")]
percent_results <- clean_percent_ranges(raw, percent_cols, diagnostics_dir, issue_log)
raw <- percent_results$raw
issue_log <- percent_results$issue_log
percent_details <- percent_results$percent_details

# Specify a controlled vocabulary for species
species_vocab <- c(
  "chinook salmon",
  "steelhead trout (wild)",
  "steelhead trout (clipped)",
  "sacramento pikeminnow",
  "speckled dace",
  "tule perch"
)

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

# Apply the controlled vocabulary
raw <- raw |>
  dplyr::mutate(
    species_original = species,
    species_norm = species |>
      stringr::str_replace_all(",", "") |>
      stringr::str_squish() |>
      stringr::str_to_lower()
  ) |>
  dplyr::left_join(species_map, by = c("species_norm" = "raw_value")) |>
  dplyr::mutate(species = dplyr::coalesce(clean_value, species_norm)) |>
  dplyr::mutate(
    species = dplyr::if_else(
      !is.na(species) & !species %in% species_vocab,
      NA_character_,
      species
    )
  ) |>
  dplyr::select(-species_norm, -clean_value)

species_standardized_details <- raw |>
  dplyr::filter(
    !is.na(species_original),
    !is.na(species),
    stringr::str_to_lower(stringr::str_replace_all(species_original, ",", "") |> stringr::str_squish()) != species
  ) |>
  dplyr::select(micro_hab_data_tbl_id, species_original, species_clean = species)

# Missing species values reflect observations with no fish observed.
species_missing_details <- raw |>
  dplyr::filter(is.na(species)) |>
  dplyr::select(micro_hab_data_tbl_id, species_original, date)

species_fixed <- nrow(species_standardized_details)
species_missing_or_dropped <- nrow(species_missing_details)

log_info("Species standardized: ", species_fixed)
log_info("Species missing or unrecognized: ", species_missing_or_dropped)

if (species_fixed > 0) {
  issue_log <- dplyr::bind_rows(
    issue_log,
    log_issue(
      "species_standardized",
      species_fixed,
      "Standardized to controlled vocabulary",
      details_path = file.path(diagnostics_dir, "microhabitat_species_standardized_details.csv")
    )
  )
}

issue_log <- dplyr::bind_rows(
  issue_log,
  log_issue(
    "species_missing_or_not_provided",
    species_missing_or_dropped,
    "Left as NA when missing or unrecognized (includes observations with no fish observed)",
    details_path = file.path(diagnostics_dir, "microhabitat_species_missing_or_unrecognized.csv")
  )
)

raw <- raw |> dplyr::select(-species_original)

# Controlled vocab: channel geomorphic unit
channel_vocab <- c("glide", "glide margin", "riffle", "riffle margin", "pool", "backwater")
channel_map <- c(
  "gilde margin" = "glide margin",
  "glide marginn" = "glide margin",
  "poo1" = "pool",
  "pool" = "pool"
)

raw <- raw |>
  dplyr::mutate(channel_original = channel_geomorphic_unit) |>
  dplyr::mutate(
    channel_geomorphic_unit = channel_geomorphic_unit |>
      stringr::str_squish() |>
      stringr::str_to_lower()
  ) |>
  dplyr::mutate(channel_geomorphic_unit = dplyr::recode(
    channel_geomorphic_unit,
    !!!channel_map,
    .default = channel_geomorphic_unit
  )) |>
  dplyr::mutate(
    channel_geomorphic_unit = dplyr::if_else(
      !is.na(channel_geomorphic_unit) & !channel_geomorphic_unit %in% channel_vocab,
      NA_character_,
      channel_geomorphic_unit
    )
  )

channel_standardized_details <- raw |>
  dplyr::filter(
    !is.na(channel_original),
    !is.na(channel_geomorphic_unit),
    channel_original |> stringr::str_squish() |> stringr::str_to_lower() != channel_geomorphic_unit
  ) |>
  dplyr::select(micro_hab_data_tbl_id, channel_original, channel_clean = channel_geomorphic_unit)

channel_missing_details <- raw |>
  dplyr::filter(is.na(channel_geomorphic_unit)) |>
  dplyr::select(micro_hab_data_tbl_id, channel_original, date)

channel_fixed <- nrow(channel_standardized_details)
channel_missing_or_dropped <- nrow(channel_missing_details)

log_info("Channel units standardized: ", channel_fixed)
log_info("Channel units missing or unrecognized: ", channel_missing_or_dropped)

if (channel_fixed > 0) {
  issue_log <- dplyr::bind_rows(
    issue_log,
    log_issue(
      "channel_standardized",
      channel_fixed,
      "Standardized to controlled vocabulary",
      details_path = file.path(diagnostics_dir, "microhabitat_channel_standardized_details.csv")
    )
  )
}

issue_log <- dplyr::bind_rows(
  issue_log,
  log_issue(
    "channel_missing_or_not_provided",
    channel_missing_or_dropped,
    "Left as NA when missing or unrecognized",
    details_path = file.path(diagnostics_dir, "microhabitat_channel_missing_or_unrecognized.csv")
  )
)

raw <- raw |> dplyr::select(-date_original, -date_parsed, -date_format_raw, -channel_original)

# Persist outputs
readr::write_csv(raw, clean_path, na = "")
readr::write_csv(issue_log, issues_path)

# Write diagnostics
readr::write_csv(date_format_counts, file.path(diagnostics_dir, "microhabitat_date_format_counts.csv"))
if (nrow(date_parse_failures) > 0) {
  readr::write_csv(date_parse_failures, file.path(diagnostics_dir, "microhabitat_date_parse_failures.csv"))
}

if (length(negative_details) > 0) {
  for (nm in names(negative_details)) {
    readr::write_csv(
      negative_details[[nm]],
      file.path(diagnostics_dir, paste0("microhabitat_negative_", nm, ".csv"))
    )
  }
}

if (length(percent_details) > 0) {
  for (nm in names(percent_details)) {
    readr::write_csv(
      percent_details[[nm]],
      file.path(diagnostics_dir, paste0("microhabitat_percent_out_of_range_", nm, ".csv"))
    )
  }
}

if (nrow(species_standardized_details) > 0) {
  readr::write_csv(species_standardized_details, file.path(diagnostics_dir, "microhabitat_species_standardized_details.csv"))
}
if (nrow(species_missing_details) > 0) {
  readr::write_csv(species_missing_details, file.path(diagnostics_dir, "microhabitat_species_missing_or_unrecognized.csv"))
}
if (nrow(channel_standardized_details) > 0) {
  readr::write_csv(channel_standardized_details, file.path(diagnostics_dir, "microhabitat_channel_standardized_details.csv"))
}
if (nrow(channel_missing_details) > 0) {
  readr::write_csv(channel_missing_details, file.path(diagnostics_dir, "microhabitat_channel_missing_or_unrecognized.csv"))
}

message("Cleaned data written to: ", clean_path)
message("Issue summary written to: ", issues_path)

outputs <- c(clean_path, issues_path, list.files(diagnostics_dir, full.names = TRUE))
invisible(outputs)
