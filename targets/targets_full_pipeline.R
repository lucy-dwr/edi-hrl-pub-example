# Full pipeline template for {targets}.
# Copy this file to the project root as `_targets.R` if you want ingest -> clean -> qc -> publish.

if (!requireNamespace("targets", quietly = TRUE)) {
  stop("Install the 'targets' package to use this pipeline: install.packages('targets')")
}

library(targets)
# Add shared packages used inside your stage functions here.
tar_option_set(packages = character())

# Helper: load a stage script and return its runner function.
get_runner <- function(stage, fn_name = paste0("run_", stage), script = file.path(stage, paste0(stage, ".R"))) {
  if (!file.exists(script)) {
    stop(sprintf("Missing stage script: add %s with %s()", script, fn_name), call. = FALSE)
  }
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  if (!exists(fn_name, envir = env, inherits = FALSE)) {
    stop(sprintf("Missing runner: define %s() inside %s", fn_name, script), call. = FALSE)
  }
  get(fn_name, envir = env, inherits = FALSE)
}

# These wrappers let you use the same run_* functions as the simple CLI.
pipeline_ingest <- function() {
  run_ingest <- get_runner("ingest")
  out <- run_ingest()
  if (is.null(out)) {
    # Fallback: track whatever exists in data/raw/ if run_ingest() does not return paths.
    out <- list.files("data/raw", recursive = TRUE, full.names = TRUE)
  }
  out
}

pipeline_clean <- function(raw_files) {
  run_clean <- get_runner("clean")
  out <- run_clean(raw_files)
  if (is.null(out)) {
    # Expect run_clean() to return paths to cleaned outputs (e.g., CSVs in data/clean/).
    out <- list.files("data/clean", recursive = TRUE, full.names = TRUE)
  }
  out
}

pipeline_qc <- function(clean_outputs) {
  run_qc <- get_runner("qc")
  run_qc(clean_outputs)
}

pipeline_publish <- function(clean_outputs, qc_outputs) {
  run_publish <- get_runner("publish")
  run_publish(clean_outputs, qc_outputs)
}

list(
  tar_target(raw_data, pipeline_ingest(), format = "file", cue = tar_cue(mode = "always")),
  tar_target(clean_data, pipeline_clean(raw_data), format = "file"),
  tar_target(qc_results, pipeline_qc(clean_data)),
  tar_target(published, pipeline_publish(clean_data, qc_results))
)
