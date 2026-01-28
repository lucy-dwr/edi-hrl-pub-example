# Minimal {targets} pipeline for the cleaning stage.
# For a fuller template (ingest -> clean -> qc -> publish), see targets/targets_full_pipeline.R.

if (!requireNamespace("targets", quietly = TRUE)) {
  stop("Install the 'targets' package to use this pipeline: install.packages('targets')")
}

library(targets)
tar_option_set(packages = character())

source("clean/clean.R")

list(
  tar_target(clean_outputs, run_clean(), format = "file")
)
