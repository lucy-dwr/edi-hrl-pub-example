# clean

Transformations that turn raw (untouched) data in [`data/raw/`](../data/raw/) into cleaned data in [`data/clean/`](../data/clean/). Keep steps deterministic and well-documented. A `run_clean()` function is exposed in [`clean/clean.R`](clean.R) so the runner or `{targets}` pipeline can reuse it.

To run cleaning in an R console (recommended for consistency with the ingest runner and `{targets}`):

```r
source("clean/clean.R")
run_clean()
```

## Example Cleaning Script

[`clean/clean-microhabitat-observations.R`](clean-microhabitat-observations.R) is a tutorial-style example cleaning workflow for the Feather River microhabitat dataset.

If you want to step through the full example script directly:

```r
source("clean/clean-microhabitat-observations.R")
```

It demonstrates how to:

- Profile and parse dates from multiple raw formats
- Run standard negative-value and percent-range checks
- Standardize species names to a controlled vocabulary
- Standardize channel geomorphic labels to a controlled vocabulary
- Record cleaning actions in an issue summary and diagnostic detail files

When run, the cleaning script writes:

- cleaned data to [`data/clean/microhabitat_observations_clean.csv`](../data/clean/microhabitat_observations_clean.csv)
- issue summary to [`data/clean/microhabitat_observations_issue_summary.csv`](../data/clean/microhabitat_observations_issue_summary.csv)
- diagnostics to [`data/clean/diagnostics/`](../data/clean/diagnostics/)
