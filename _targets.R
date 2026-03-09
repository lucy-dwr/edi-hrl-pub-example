# {targets} pipeline for the demo workflow.
#
# {targets} orchestrates the ingest -> clean -> qc -> publish stages as an
# explicit dependency graph. Each step below is a "target": a named unit of
# work with defined inputs and outputs. When you call tar_make(), {targets}
# checks which targets are out of date and only re-runs those, skipping work
# that hasn't changed. This makes iterative work faster and more reproducible.
#
# Dependency structure:
#   run_ingest()                           -> raw_outputs
#   run_clean(raw_outputs)                 -> clean_outputs
#   run_qc(clean_outputs)                  -> qc_outputs
#   run_publish(clean_outputs, qc_outputs) -> publish_outputs
#
# cue = tar_cue(mode = "always") on raw_outputs means ingest always re-runs,
# which is appropriate for data pulled from an external API that may be updated.
# All other targets use the default ("thorough"): they re-run only when their
# command, dependencies, or input files change.
#
# To run: call targets::tar_make() in an R console from the project root.
# To inspect without running: source this file — it prints the target objects.

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
  tar_target(clean_outputs, run_clean(raw_outputs), format = "file"),
  tar_target(qc_outputs, run_qc(clean_outputs)),
  tar_target(publish_outputs, run_publish(clean_outputs, qc_outputs))
)
