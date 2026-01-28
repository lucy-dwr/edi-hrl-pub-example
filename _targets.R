# Minimal {targets} pipeline for the demo workflow.

if (!requireNamespace("targets", quietly = TRUE)) {
  stop("Install the 'targets' package to use this pipeline: install.packages('targets')")
}

library(targets)
tar_option_set(packages = character())

source("ingest/ingest.R")
source("clean/clean.R")
source("qc/qc.R")
source("publish/publish.R")

list(
  tar_target(raw_outputs, run_ingest(), format = "file", cue = tar_cue(mode = "always")),
  tar_target(clean_outputs, run_clean(), format = "file"),
  tar_target(qc_outputs, run_qc(clean_outputs)),
  tar_target(publish_outputs, run_publish(clean_outputs, qc_outputs))
)
