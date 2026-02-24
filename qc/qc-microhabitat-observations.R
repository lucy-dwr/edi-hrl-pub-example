# Quality control Feather River microhabitat data
#
# This script applies post-cleaning quality-control checks to the cleaned
# microhabitat dataset and writes a QC issue summary plus diagnostics.

# ==============================================================================
# Set up and run options ----
# ==============================================================================

# Attach HRL data publication package to get QC helper functions
library(hrlpub)

# Set TRUE for more console output
verbose <- FALSE


# ==============================================================================
# Data import ----
# ==============================================================================

# Identify a path to the target cleaned data
qc_clean_path <- "data/clean/microhabitat_observations_clean.csv"

# Check that the target cleaned data file exists
if (!file.exists(qc_clean_path)) {
  stop("Clean data file not found at: ", qc_clean_path, call. = FALSE)
}

# Establish output paths for QC artifacts
diagnostics_dir <- "data/clean/diagnostics"
qc_issues_path <- "data/clean/microhabitat_observations_qc_issue_summary.csv"
qc_flags_path <- file.path(diagnostics_dir, "microhabitat_qc_flags.csv")
qc_flag_reason_counts_path <- file.path(diagnostics_dir, "microhabitat_qc_flag_reason_counts.csv")
qc_report_path <- file.path(diagnostics_dir, "microhabitat_qc_report.rds")
dir.create(diagnostics_dir, showWarnings = FALSE, recursive = TRUE)

# Read cleaned data for QC checks
clean_data <- readr::read_csv(qc_clean_path, show_col_types = FALSE)
n_total <- nrow(clean_data)

if (verbose) {
  dplyr::glimpse(clean_data)
}


# ==============================================================================
# QC checks ----
# ==============================================================================

# Remap microhabitat observation ID to the site_id field expected by the
# fish-observation QC helperå
qc_data <- clean_data |>
  dplyr::mutate(site_id = as.character(micro_hab_data_tbl_id))

# Run built-in hrlpub QC checks for fish-observation-like records; this function
# requires a specific column naming convention described at ?hrlpub::run_qc_checks
qc_results <- hrlpub::run_qc_checks(
  data = qc_data,
  data_type = "fish_observation",
  max_count = 1000,
  check_interobs = FALSE,
  check_condition = FALSE
)

if (verbose) {
  hrlpub::print_qc_summary(qc_results)
}

# Build and save an RDS QC report object for downstream review.
qc_report <- hrlpub::generate_qc_report(
  qc_results = qc_results,
  output_file = qc_report_path
)


# ==============================================================================
# QC summaries and diagnostics ----
# ==============================================================================

# Subset the per-row QC flag output so that it is compact and reviewable
qc_flags <- qc_results$flags |>
  dplyr::select(row_id, date, site_id, species, flag, flag_reason)

# Summarize reason frequencies for all non-pass QC flags.
qc_flag_reason_counts <- qc_flags |>
  dplyr::filter(flag != "PASS") |>
  dplyr::count(flag, flag_reason, name = "rows", sort = TRUE)

n_suspect <- sum(qc_flags$flag == "SUSPECT", na.rm = TRUE)
n_reject <- sum(qc_flags$flag == "REJECT", na.rm = TRUE)
n_flagged <- n_suspect + n_reject

# Log summary counts of suspected and rejected records
hrlpub::log_info("QC suspect records: ", n_suspect)
hrlpub::log_info("QC reject records: ", n_reject)

# Establish an issue log
qc_issue_log <- tibble::tibble()

if (n_suspect > 0) {
  qc_issue_log <- dplyr::bind_rows(
    qc_issue_log,
    hrlpub::log_issue(
      issue = "qc_suspect_records",
      rows_affected = n_suspect,
      action = "Flagged as SUSPECT by hrlpub::run_qc_checks for fish_observation data",
      n_total = n_total,
      details_path = qc_flags_path
    )
  )
}

if (n_reject > 0) {
  qc_issue_log <- dplyr::bind_rows(
    qc_issue_log,
    hrlpub::log_issue(
      issue = "qc_reject_records",
      rows_affected = n_reject,
      action = "Flagged as REJECT by hrlpub::run_qc_checks for fish_observation data",
      n_total = n_total,
      details_path = qc_flags_path
    )
  )
}

if (n_flagged == 0) {
  qc_issue_log <- dplyr::bind_rows(
    qc_issue_log,
    hrlpub::log_issue(
      issue = "qc_all_records_pass",
      rows_affected = 0,
      action = "All records passed hrlpub::run_qc_checks",
      n_total = n_total,
      details_path = qc_flags_path
    )
  )
}

# Write QC artifacts
readr::write_csv(qc_issue_log, qc_issues_path)
readr::write_csv(qc_flags, qc_flags_path)

if (nrow(qc_flag_reason_counts) > 0) {
  readr::write_csv(qc_flag_reason_counts, qc_flag_reason_counts_path)
}

if (verbose && nrow(qc_flag_reason_counts) > 0) {
  hrlpub::print_table("QC flag reason counts:", qc_flag_reason_counts)
}

message("QC issue summary written to: ", qc_issues_path)
message("QC flag details written to: ", qc_flags_path)
message("QC report written to: ", qc_report_path)

outputs <- c(qc_issues_path, qc_flags_path, qc_report_path)
if (nrow(qc_flag_reason_counts) > 0) {
  outputs <- c(outputs, qc_flag_reason_counts_path)
}
invisible(outputs)
