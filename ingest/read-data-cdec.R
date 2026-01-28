# Create a function to call the CDEC API with retries to handle transient outages
fetch_cdec_group_with_retry <- function(groups, start.date, end.date, max_attempts = 5, wait_seconds = 5) {
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

    message(
      sprintf(
        "Attempt %d/%d failed to fetch CDEC data: %s",
        attempt,
        max_attempts,
        conditionMessage(result)
      )
    )

    if (attempt < max_attempts) {
      Sys.sleep(wait_seconds)
    }
  }

  stop("Unable to fetch CDEC data after retries.")
}

oroville_precip_2024_raw <- fetch_cdec_group_with_retry(
  groups = "OR1",
  start.date = "2024-01-01",
  end.date = "2024-12-31"
)

# Save the fetched data to an RDS file in `data/raw` for later cleaning
saveRDS(
  oroville_precip_2024_raw,
  file = "data/raw/oroville_precip_2024_raw.rds"
)
