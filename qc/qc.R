# QC runner for the demo workflow.
run_qc <- function(clean_outputs = NULL) {
  message("QC step is a placeholder for this demo.")
  message("No additional QC checks are executed.")
  # TODO: Add lightweight QC checks (e.g., missingness summaries, range checks, etc.).
  # TODO: Write QC outputs to a report file in data/clean/diagnostics/ or qc/.
  invisible(clean_outputs)
}
