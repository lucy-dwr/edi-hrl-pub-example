# data/clean

This folder stores data that are created by cleaning and quality control steps and that are ready for publication. Regenerate these data using scripts in `clean/` that process raw data in `data/raw/` or by running the `{targets}` pipeline, rather than editing data files by hand.

## Related Cleaning Workflow

These files are generated from raw inputs in [`data/raw/`](../raw/) by scripts in [`clean/`](../../clean/). For the microhabitat example in this repository, see:

- [`clean/README.md`](../../clean/README.md)
- [`clean/clean-microhabitat-observations.R`](../../clean/clean-microhabitat-observations.R)

To regenerate the microhabitat example outputs in an R console (recommended for consistency with the ingest runner and `{targets}`):

```r
source("clean/clean.R")
run_clean()
```

If you want to run the full example script directly:

```r
source("clean/clean-microhabitat-observations.R")
```

## Example outputs

- [`microhabitat_observations_clean.csv`](microhabitat_observations_clean.csv): Cleaned microhabitat observations with standardized date parsing, validated numeric ranges, and controlled vocabularies applied.
- [`microhabitat_observations_issue_summary.csv`](microhabitat_observations_issue_summary.csv): Summary of cleaning issues and prevalence (e.g., date missing vs date parse failures, negative values, and missing/unrecognized controlled-vocabulary labels).
- [`diagnostics/`](diagnostics/): Detailed diagnostics files written by the cleaning script.
  - Date diagnostics:
    - [`microhabitat_date_format_counts.csv`](diagnostics/microhabitat_date_format_counts.csv)
    - [`microhabitat_date_parse_failures.csv`](diagnostics/microhabitat_date_parse_failures.csv)
    - [`microhabitat_date_missing_or_not_provided.csv`](diagnostics/microhabitat_date_missing_or_not_provided.csv) (when present)
  - Negative-value diagnostics:
    - [`microhabitat_negative_count.csv`](diagnostics/microhabitat_negative_count.csv)
    - [`microhabitat_negative_fl_mm.csv`](diagnostics/microhabitat_negative_fl_mm.csv)
    - [`microhabitat_negative_depth.csv`](diagnostics/microhabitat_negative_depth.csv)
    - [`microhabitat_negative_velocity.csv`](diagnostics/microhabitat_negative_velocity.csv)
  - Species diagnostics:
    - [`microhabitat_species_standardized_details.csv`](diagnostics/microhabitat_species_standardized_details.csv)
    - [`microhabitat_species_missing_or_unrecognized.csv`](diagnostics/microhabitat_species_missing_or_unrecognized.csv)
  - Channel diagnostics:
    - [`microhabitat_channel_standardized_details.csv`](diagnostics/microhabitat_channel_standardized_details.csv)
    - [`microhabitat_channel_missing_or_unrecognized.csv`](diagnostics/microhabitat_channel_missing_or_unrecognized.csv)
