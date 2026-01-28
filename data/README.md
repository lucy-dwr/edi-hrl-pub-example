# data

This folder is a shared home for data at each stage of processing.

- [`raw/`](raw/): source data manually imported or pulled in by `ingest/`. Raw data should be treated as immutable.
- [`clean/`](clean/): cleaned, publication-ready outputs created by `clean/` and `qc/`, plus diagnostics (e.g., issue summaries and format checks) for the microhabitat observations workflow.
