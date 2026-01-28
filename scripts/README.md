# scripts

Entry points to run the pipeline end-to-end without {targets}.

- `run_pipeline.R`: sequential runner for ingest -> clean -> qc -> publish. Run from an R console with `source("scripts/run_pipeline.R")`.
- Keep stage-specific logic in `ingest/`, `clean/`, `qc/`, `publish/` and have each expose `run_<stage>()` so the runner can reuse it.
- If you want a `{targets}` pipeline instead, see `_targets.R` at the project root and `targets/targets_full_pipeline.R`.
