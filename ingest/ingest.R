# Ingest runner for the demo workflow.
run_ingest <- function() {
  message("Running CDEC ingest for the Oroville precipitation example.")
  # TODO: Consider a flag or config to skip the CDEC API call for offline/demo runs.
  # TODO: Skip re-downloads if the target file already exists in data/raw/.
  if (!requireNamespace("cder", quietly = TRUE)) {
    stop("Missing package 'cder'. Install it before running ingest.", call. = FALSE)
  }

  source("ingest/read-data-cdec.R", local = TRUE)
  message("Microhabitat raw data is expected to be manually placed in data/raw/.")
  list.files("data/raw", recursive = TRUE, full.names = TRUE)
}
