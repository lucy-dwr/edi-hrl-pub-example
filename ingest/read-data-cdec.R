# Create a function to call the CDEC API with retries to handle transient outages
fetch_cdec_group_with_retry <- function(groups, start.date, end.date, max_attempts = 5, wait_seconds = 5, verbose = TRUE) {
  for (attempt in seq_len(max_attempts)) {
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

    if (attempt < max_attempts) {
      Sys.sleep(wait_seconds)
    }
  }

  stop("Unable to fetch CDEC data after retries.", call. = FALSE)
}

# Ingest a CDEC group to a local RDS file, with idempotent skip behavior.
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

  saveRDS(cdec_data, file = output_file)

  if (isTRUE(verbose)) {
    message("Wrote CDEC data to: ", output_file)
  }

  output_file
}
