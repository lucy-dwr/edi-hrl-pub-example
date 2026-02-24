# QC runner for the demo workflow.
run_qc <- function(clean_outputs = NULL) {
  default_clean_path <- "data/clean/microhabitat_observations_clean.csv"
  clean_path <- default_clean_path

  # Prefer an explicit clean output path when run from targets/pipeline.
  if (!is.null(clean_outputs)) {
    clean_candidates <- clean_outputs[
      grepl("microhabitat_observations_clean\\.csv$", clean_outputs)
    ]
    if (length(clean_candidates) > 0) {
      clean_path <- clean_candidates[[1]]
    }
  }

  qc_env <- new.env(parent = globalenv())
  qc_env$qc_clean_path <- clean_path

  result <- source("qc/qc-microhabitat-observations.R", local = qc_env)$value

  if (is.null(result)) {
    result <- c(
      "data/clean/microhabitat_observations_qc_issue_summary.csv",
      "data/clean/diagnostics/microhabitat_qc_flags.csv",
      "data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv",
      "data/clean/diagnostics/microhabitat_qc_report.rds"
    )
    result <- result[file.exists(result)]
  }

  result
}
