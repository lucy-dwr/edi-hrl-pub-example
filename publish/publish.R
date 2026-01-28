# Publish runner for the demo workflow.
run_publish <- function(clean_outputs = NULL, qc_outputs = NULL, publish = FALSE) {
  message("Publish step is a placeholder for this demo.")
  if (!isTRUE(publish)) {
    message("Skipping actual publication. See publish-data.R for the publish example.")
    return(invisible(NULL))
  }

  stop("Publishing is disabled in this demo. Set publish = FALSE.", call. = FALSE)
}
