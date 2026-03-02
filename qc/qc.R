# QC runner for the demo workflow
#
# This runner executes the QC script and returns only QC-stage outputs so
# downstream stages (or targets) can consume a clear set of artifacts. It accepts
# optional clean_outputs from an upstream stage and resolves the cleaned
# microhabitat path from that vector when available.
run_qc <- function(
  clean_outputs = NULL,
  max_count = 1000,
  check_interobs = FALSE,
  check_condition = FALSE,
  verbose = FALSE
) {
  script_path <- "qc/qc-microhabitat-observations.R"
  default_clean_path <- "data/clean/microhabitat_observations_clean.csv"
  clean_path <- default_clean_path

  # Validate that the QC script exists before trying to source it
  if (!file.exists(script_path)) {
    stop("Missing QC script: ", script_path, call. = FALSE)
  }

  # Prefer an explicit clean output path when run from targets/pipeline
  if (!is.null(clean_outputs)) {
    clean_outputs <- as.character(clean_outputs)
    clean_candidates <- clean_outputs[
      grepl("microhabitat_observations_clean\\.csv$", clean_outputs)
    ]
    if (length(clean_candidates) > 0) {
      clean_path <- clean_candidates[[1]]
    }
  }

  # Pass resolved runtime settings to the QC script in an isolated environment
  qc_env <- new.env(parent = globalenv())
  qc_env$qc_clean_path <- clean_path
  qc_env$qc_max_count <- max_count
  qc_env$qc_check_interobs <- check_interobs
  qc_env$qc_check_condition <- check_condition
  qc_env$verbose <- verbose

  result <- source(script_path, local = qc_env)$value

  # If the sourced script did not return paths, fall back to expected outputs
  if (is.null(result)) {
    result <- c(
      "data/clean/microhabitat_observations_qc_issue_summary.csv",
      "data/clean/diagnostics/microhabitat_qc_flags.csv",
      "data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv",
      "data/clean/diagnostics/microhabitat_qc_report.rds"
    )
    result <- result[file.exists(result)]
  }

  if (length(result) == 0) {
    stop("QC finished but no expected QC outputs were found.", call. = FALSE)
  }

  result
}
