# ingest

This folder contains scripts that pull data into [`data/raw/`](../data/raw/) through API calls and scripted downloads and exposes a `run_ingest()` function in [`ingest/ingest.R`](ingest.R) so the runner or `{targets}` pipeline can call it.

To run ingest in an R console:

```r
source("ingest/ingest.R")
run_ingest()
```

## Example

This folder contains an ingestion script for Oroville precipitation data that calls the [CDEC](https://cdec.water.ca.gov) API. See [`ingest/read-data-cdec.R`](read-data-cdec.R) for this script.

If you want to step through the full example script directly:

```r
source("ingest/read-data-cdec.R")
```

It demonstrates how to:

- Wrap an API call in retry logic to handle transient failures
- Make ingest idempotent by skipping downloads when the output file already exists
- Write ingested data to a local RDS file for use by downstream pipeline stages

When run, this script writes:

- [`data/raw/oroville_precip_2024_raw.rds`](../data/raw/oroville_precip_2024_raw.rds)
