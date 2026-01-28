# clean

Transformations that turn `data/raw/` into `data/clean/`. Keep steps deterministic and well-documented. Expose a `run_clean()` function in `clean/clean.R` so the CLI runner or {targets} pipeline can reuse it.

To run the example cleaning script directly:

```
Rscript clean/clean-microhabitat-observations.R
```
