# qc

Validation and quality-control checks between cleaning and publication. Store rule definitions, thresholds, and generated reports here; keep large report artifacts out of version control. A `run_qc()` function is exposed in [`qc/qc.R`](qc.R) so the runner or `{targets}` pipeline can invoke it.

To run QC in an R console:

```r
source("qc/qc.R")
run_qc()
```

## Example QC Script

[`qc/qc-microhabitat-observations.R`](qc-microhabitat-observations.R) is a tutorial-style QC workflow for cleaned microhabitat observations.

If you want to step through the full example script directly:

```r
source("qc/qc-microhabitat-observations.R")
```

It demonstrates how to:

- Apply built-in `hrlpub` QC checks to fish-observation records
- Classify flagged records as SUSPECT or REJECT
- Summarize flag counts and reasons
- Write a QC report and per-row flag details for review

When run, this script writes artifacts that describe the QC results:

- [`data/clean/microhabitat_observations_qc_issue_summary.csv`](../data/clean/microhabitat_observations_qc_issue_summary.csv)
- [`data/clean/diagnostics/microhabitat_qc_flags.csv`](../data/clean/diagnostics/microhabitat_qc_flags.csv)
- [`data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv`](../data/clean/diagnostics/microhabitat_qc_flag_reason_counts.csv)
- [`data/clean/diagnostics/microhabitat_qc_report.rds`](../data/clean/diagnostics/microhabitat_qc_report.rds)
