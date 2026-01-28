# qc

Validation and quality-control checks between cleaning and publication. Store rule definitions, thresholds, and generated reports here; keep large report artifacts out of version control. Expose a `run_qc()` function in `qc/qc.R` that can be invoked by the runner or {targets} pipeline.
