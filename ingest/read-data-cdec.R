# Read data from the CDEC API
#
# This script defines helper functions for downloading CDEC station group data
# with retry logic and writing the results to local RDS files. It also calls
# those functions to run the download when sourced directly.
#
# The example uses the California Data Exchange Center (CDEC) API via the
# {cder} package to fetch 2024 precipitation data for the Oroville station
# group (OR1).
#
# Comments are included throughout to explain the rationale and implementation
# of this code so as to serve as a tutorial.

# ==============================================================================
# API fetch with retry ----
# ==============================================================================

# Public APIs can return transient errors due to network issues or server load.
# Wrapping the API call in retry logic makes ingestion more resilient without
# requiring manual re-runs when a single request fails
fetch_cdec_group_with_retry <- function(groups, start.date, end.date, max_attempts = 5, wait_seconds = 5, verbose = TRUE) {
  for (attempt in seq_len(max_attempts)) {
    # tryCatch captures any error as a value rather than stopping execution,
    # which lets us inspect it, log it, and decide whether to retry
    result <- tryCatch(
      cder::cdec_query_group(
        groups = groups,
        start.date = start.date,
        end.date = end.date
      ),
      error = identity
    )

    if (!inherits(result, "error")) {
      return(result)
    }

    if (isTRUE(verbose)) {
      message(
        sprintf(
          "Attempt %d/%d failed to fetch CDEC data: %s",
          attempt,
          max_attempts,
          conditionMessage(result)
        )
      )
    }

    # Pause between attempts to avoid hammering the API after a failure
    if (attempt < max_attempts) {
      Sys.sleep(wait_seconds)
    }
  }

  stop("Unable to fetch CDEC data after retries.", call. = FALSE)
}

# ==============================================================================
# CDEC group ingestion ----
# ==============================================================================

# Ingest a CDEC group to a local RDS file, with idempotent skip behavior.
# Making ingestion idempotent means re-running the script does not re-download
# data that already exists locally, which saves time and avoids unnecessary API
# calls. Set overwrite = TRUE to force a fresh download
ingest_cdec_group <- function(
  groups,
  start.date,
  end.date,
  output_file,
  overwrite = FALSE,
  max_attempts = 5,
  wait_seconds = 5,
  verbose = TRUE
) {
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

  # Skip the download if the output file already exists and overwrite is FALSE
  if (file.exists(output_file) && !isTRUE(overwrite)) {
    if (isTRUE(verbose)) {
      message("Skipping CDEC download; output already exists: ", output_file)
    }
    return(output_file)
  }

  if (!requireNamespace("cder", quietly = TRUE)) {
    stop(
      "Missing package 'cder'. Install it before downloading CDEC data.",
      call. = FALSE
    )
  }

  cdec_data <- fetch_cdec_group_with_retry(
    groups = groups,
    start.date = start.date,
    end.date = end.date,
    max_attempts = max_attempts,
    wait_seconds = wait_seconds,
    verbose = verbose
  )

  if (!is.data.frame(cdec_data)) {
    stop("CDEC query did not return a data frame.", call. = FALSE)
  }

  if (nrow(cdec_data) == 0 && isTRUE(verbose)) {
    message("CDEC query returned 0 rows. Writing empty dataset to: ", output_file)
  }

  # RDS preserves R data types (dates, factors, etc.) without conversion, making
  # it a reliable format for intermediate pipeline outputs that will be read back
  # into R. Use CSV or another open format for final published outputs
  saveRDS(cdec_data, file = output_file)

  if (isTRUE(verbose)) {
    message("Wrote CDEC data to: ", output_file)
  }

  output_file
}


# ==============================================================================
# Run CDEC ingestion ----
# ==============================================================================

# Set TRUE for more console output
if (!exists("verbose")) {
  verbose <- FALSE
}

# Set defaults for the CDEC download (can be overridden before sourcing).
# OR1 is the CDEC station group identifier for the Oroville area.
# Adjust cdec_group, start/end dates, and output path for a different dataset
if (!exists("cdec_group")) {
  cdec_group <- "OR1"
}
if (!exists("cdec_start_date")) {
  cdec_start_date <- "2024-01-01"
}
if (!exists("cdec_end_date")) {
  cdec_end_date <- "2024-12-31"
}
if (!exists("cdec_output_path")) {
  cdec_output_path <- "data/raw/oroville_precip_2024_raw.rds"
}
if (!exists("refresh_cdec")) {
  refresh_cdec <- FALSE
}

# Download CDEC data and write to a local RDS file
outputs <- ingest_cdec_group(
  groups = cdec_group,
  start.date = cdec_start_date,
  end.date = cdec_end_date,
  output_file = cdec_output_path,
  overwrite = refresh_cdec,
  verbose = verbose
)

invisible(outputs)
