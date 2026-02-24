# Ingest runner for the demo workflow

# This runner combines:
#   1) a manually provided raw CSV used by the cleaning tutorial, and
#   2) a scripted CDEC API download written to data/raw/
#
# It returns only file paths that are real ingest outputs so targets can track
# them with format = "file"
run_ingest <- function(
  manual_raw_path = "data/raw/microhabitat_observations_raw.csv",
  require_manual_raw = TRUE,
  cdec_output_path = "data/raw/oroville_precip_2024_raw.rds",
  cdec_group = "OR1",
  cdec_start_date = "2024-01-01",
  cdec_end_date = "2024-12-31",
  refresh_cdec = FALSE,
  max_attempts = 5,
  wait_seconds = 5,
  verbose = TRUE
) {
  if (isTRUE(verbose)) {
    message("Running ingest for the demo workflow.")
  }

  # Load helper functions from ingest/read-data-cdec.R in an isolated
  # environment so helper symbols do not leak into the global environment
  if (!file.exists("ingest/read-data-cdec.R")) {
    stop("Missing helper script: ingest/read-data-cdec.R", call. = FALSE)
  }

  ingest_env <- new.env(parent = globalenv())
  sys.source("ingest/read-data-cdec.R", envir = ingest_env)

  if (!exists("ingest_cdec_group", envir = ingest_env, inherits = FALSE)) {
    stop("ingest/read-data-cdec.R must define ingest_cdec_group().", call. = FALSE)
  }

  # Collect the files produced/validated by ingest to return to callers
  outputs <- character()

  # Validate the manual raw file expected by downstream cleaning; instrict mode
  # (require_manual_raw = TRUE), fail fast if missing so the pipeline does not
  # proceed with incomplete raw inputs
  if (file.exists(manual_raw_path)) {
    outputs <- c(outputs, manual_raw_path)
    if (isTRUE(verbose)) {
      message("Found manual raw input: ", manual_raw_path)
    }
  } else if (isTRUE(require_manual_raw)) {
    stop(
      "Required manual raw file is missing: ", manual_raw_path,
      "\nPlace the file in data/raw/ before running ingest.",
      call. = FALSE
    )
  } else if (isTRUE(verbose)) {
    message("Manual raw input not found (allowed): ", manual_raw_path)
  }

  # Fetch (or reuse) CDEC data and add the output path; setting refresh_cdec = FALSE
  # makes ingest idempotent by reusing an existing RDS file when present
  cdec_path <- ingest_env$ingest_cdec_group(
    groups = cdec_group,
    start.date = cdec_start_date,
    end.date = cdec_end_date,
    output_file = cdec_output_path,
    overwrite = refresh_cdec,
    max_attempts = max_attempts,
    wait_seconds = wait_seconds,
    verbose = verbose
  )

  # Keep only unique, existing paths so downstream stages can consume a clean
  # vector of file outputs
  outputs <- c(outputs, cdec_path)
  outputs <- unique(outputs[file.exists(outputs)])

  if (length(outputs) == 0) {
    stop("Ingest finished but no output files were found.", call. = FALSE)
  }

  if (isTRUE(verbose)) {
    message("Ingest outputs:")
    for (path in outputs) {
      message(" - ", path)
    }
  }

  outputs
}
