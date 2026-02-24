# data/raw

This folder stores data pulled from upstream systems through manual uploads or through APIs and download scripts. Keep files in this folder immutable and replace them only by re-running ingestion.

## Example Data Files

This folder contains example data files:

- [`microhabitat_observations_raw.csv`](microhabitat_observations_raw.csv): Raw microhabitat survey observations (uploaded manually). Values are intentionally not standardized and may include mixed date formats, negative numeric values, uncontrolled species labels, and uncontrolled channel geomorphic labels. In this dataset, species `NA` values are commonly associated with no-fish observations, but `NA` can also represent missing or otherwise unrecognized species entries.
- [`oroville_precip_2024_raw.rds`](oroville_precip_2024_raw.rds): Precipitation data for the Oroville group of stations, pulled from the [CDEC](https://cdec.water.ca.gov) API using the script [`ingest/read-data-cdec.R`](../../ingest/read-data-cdec.R). No cleaning or diagnostics have yet been applied.

TODO: Add provenance details for the microhabitat dataset (collection period, source system, and any access restrictions).
