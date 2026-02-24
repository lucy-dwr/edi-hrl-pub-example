# qc

Validation and quality-control checks between cleaning and publication. Store rule definitions, thresholds, and generated reports here; keep large report artifacts out of version control. A `run_qc()` function is exposed in [`qc/qc.R`](qc.R) so the runner or `{targets}` pipeline can invoke it.

To run QC in an R console:

```r
source("qc/qc.R")
run_qc()
```

## Example QC Script

[`qc/qc-microhabitat-observations.R`](qc-microhabitat-observations.R) is a tutorial-style QC workflow for cleaned microhabitat observations.

When run, this script writes artifacts that describe the QC results:

- [`data/clean/microhabitat_observations_qc_issue_summary.csv`](../data/clean/microhabitat_observations_qc_issue_summary.csv)
- [`data/clean/diagnostics/microhabitat_qc_flags.csv`](../data/clean/diagnostics/microhabitat_qc_flags.csv)
- [`data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv`](../data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv) (when QC flags are present)
- [`data/clean/diagnostics/microhabitat_qc_report.rds`](../data/clean/diagnostics/microhabitat_qc_report.rds)
