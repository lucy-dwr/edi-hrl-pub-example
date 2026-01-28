# targets

Optional {targets} pipeline support.

- `_targets.R` at the project root is the active pipeline entry point.
- `targets/targets_full_pipeline.R` is a fuller template that wires ingest -> clean -> qc -> publish using `run_<stage>()` functions.

Run the pipeline in an R console:

```
targets::tar_make()
```
