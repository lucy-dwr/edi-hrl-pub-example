# data/clean

This folder stores data that are created by cleaning and quality control steps and that are ready for publication. Regenerate these data using scripts in `clean/` that process raw data in `data/raw/` or by running the `{targets}` pipeline, rather than editing data files by hand.

## Example outputs

- [`microhabitat_observations_clean.csv`](microhabitat_observations_clean.csv): Cleaned microhabitat observations with standardized date parsing, validated numeric ranges, and controlled vocabularies applied.
- [`microhabitat_observations_issue_summary.csv`](microhabitat_observations_issue_summary.csv): Summary of cleaning issues and prevalence (e.g., invalid dates, negative values, missing/unknown species).
- [`diagnostics/`](diagnostics/): Detailed diagnostics files written by the cleaning script (date format counts, parse failures, negative values, and controlled vocabulary standardization details).
