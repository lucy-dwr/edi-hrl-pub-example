# data/raw

This folder stores data pulled from upstream systems through manual uploads or through APIs and download scripts. Keep files in this folder immutable and replace them only by re-running ingestion.

## Example

This folder contains example data files:

- [`microhabitat_observations_raw.csv`](microhabitat_observations_raw.csv): Raw microhabitat survey observations (uploaded manually). Species values are not standardized; many records use `NA` to indicate no fish observed at that location.
- [`oroville_precip_2024_raw.rds`](oroville_precip_2024_raw.rds): Precipitation data for the Oroville group of stations, pulled from the [CDEC](https://cdec.water.ca.gov) API using the script [`ingest/read-data-cdec.R`](../../ingest/read-data-cdec.R).

TODO: Add provenance details for the microhabitat dataset (collection period, source system, and any access restrictions).
