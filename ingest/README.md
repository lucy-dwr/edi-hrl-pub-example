# ingest

This folder contains scripts that pull data into `data/raw/` through API calls and scripted downloads. Add source-specific notes (e.g., by updating this README.md file) and configs here as needed. Expose a `run_ingest()` function in `ingest/ingest.R` so the CLI runner or {targets} pipeline can call it.

## Example

This folder contains an ingestion script for Oroville precipitation data that calls the [CDEC](https://cdec.water.ca.gov) API. See [`ingest/read-data-cdec.R`](read-data-cdec.R) for this script.
