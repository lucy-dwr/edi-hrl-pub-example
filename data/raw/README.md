# data/raw

This folder stores data pulled from upstream systems through manual uploads or through APIs and download scripts. Keep files in this folder immutable and replace them only by re-running ingestion.

## Example Data Files

This folder contains example data files:

- [`microhabitat_observations_raw.csv`](microhabitat_observations_raw.csv): Raw microhabitat survey observations (uploaded manually). Values are intentionally not standardized and may include mixed date formats, negative numeric values, uncontrolled species labels, and uncontrolled channel geomorphic labels. In this dataset, species `NA` values are commonly associated with no-fish observations, but `NA` can also represent missing or otherwise unrecognized species entries.
  - **Source**: California Department of Water Resources (DWR)
  - **Collection period**: March–August 2001 and March–August 2002
  - **Study area**: Feather River — 29 sites across the Low Flow Channel (13 sites) and High Flow Channel (16 sites)
  - **Collection method**: Monthly snorkel surveys; each sampling section covered a 25 m × 4 m area parallel to the riverbank
  - **Access restrictions**: None beyond the Creative Commons license — see [`publish/metadata/intellectual_rights.txt`](../../publish/metadata/intellectual_rights.txt)
- [`oroville_precip_2024_raw.rds`](oroville_precip_2024_raw.rds): Precipitation data for the Oroville group of stations, pulled from the [CDEC](https://cdec.water.ca.gov) API using the script [`ingest/read-data-cdec.R`](../../ingest/read-data-cdec.R). No cleaning or diagnostics have yet been applied.
