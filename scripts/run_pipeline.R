#!/usr/bin/env Rscript

# Simple sequential runner for ingest -> clean -> QC -> publish.
# Each stage looks for a `run_<stage>()` function inside `stage/stage.R`.
# The script will skip stages that are not yet implemented, so you can
# fill them in incrementally.

args <- commandArgs(trailingOnly = TRUE)
known_flags <- c("--skip-ingest", "--skip-clean", "--skip-qc", "--skip-publish", "--help", "-h")

show_help <- function() {
  cat(
"Usage: Rscript scripts/run_pipeline.R [flags]\n\n",
"Flags:\n",
"  --skip-ingest    Skip ingestion step\n",
"  --skip-clean     Skip cleaning step\n",
"  --skip-qc        Skip quality-control step\n",
"  --skip-publish   Skip publish step\n",
"  -h, --help       Show this message\n",
"\n",
"Expectations:\n",
"  - Define run_ingest() in ingest/ingest.R to pull data into data/raw/\n",
"  - Define run_clean() in clean/clean.R to write cleaned outputs to data/clean/\n",
"  - Define run_qc() in qc/qc.R to validate cleaned data (return paths or a report)\n",
"  - Define run_publish() in publish/publish.R to package outputs for release\n",
sep = ""
  )
  quit(save = "no")
}

if (any(args %in% c("--help", "-h"))) {
  show_help()
}

unknown <- setdiff(args, known_flags)
if (length(unknown) > 0) {
  stop(sprintf("Unknown flag(s): %s", paste(unknown, collapse = ", ")), call. = FALSE)
}

opts <- list(
  skip_ingest = "--skip-ingest" %in% args,
  skip_clean = "--skip-clean" %in% args,
  skip_qc = "--skip-qc" %in% args,
  skip_publish = "--skip-publish" %in% args
)

stamp <- function(fmt, ...) {
  cat(sprintf("[%s] %s\n", format(Sys.time(), "%H:%M:%S"), sprintf(fmt, ...)))
}

stage_runner <- function(stage, fn) {
  stamp("Starting %s", stage)
  t0 <- Sys.time()
  tryCatch({
    fn()
    elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
    stamp("Finished %s (%.1fs)", stage, elapsed)
  }, error = function(e) {
    stop(sprintf("Step '%s' failed: %s", stage, e$message), call. = FALSE)
  })
}

load_runner <- function(stage_dir, stage_name, fn_name = NULL) {
  if (is.null(fn_name)) {
    fn_name <- paste0("run_", stage_name)
  }
  script_path <- file.path(stage_dir, paste0(stage_name, ".R"))
  if (!file.exists(script_path)) {
    stamp("%s not implemented yet: add %s with %s()", stage_name, script_path, fn_name)
    return(function(...) invisible(NULL))
  }
  env <- new.env(parent = globalenv())
  sys.source(script_path, envir = env)
  if (!exists(fn_name, envir = env, inherits = FALSE)) {
    stamp("%s not implemented yet: define %s() inside %s", stage_name, fn_name, script_path)
    return(function(...) invisible(NULL))
  }
  get(fn_name, envir = env, inherits = FALSE)
}

main <- function() {
  if (!opts$skip_ingest) {
    stage_runner("ingest", load_runner("ingest", "ingest"))
  }
  if (!opts$skip_clean) {
    stage_runner("clean", load_runner("clean", "clean"))
  }
  if (!opts$skip_qc) {
    stage_runner("qc", load_runner("qc", "qc"))
  }
  if (!opts$skip_publish) {
    stage_runner("publish", load_runner("publish", "publish"))
  }
  stamp("Pipeline complete")
}

main()
