# clean

Transformations that turn raw (untouched) data in `data/raw/` into cleaned data in `data/clean/`. Keep steps deterministic and well-documented. A `run_clean()` function is exposed in `clean/clean.R` so the runner or `{targets}` pipeline can reuse it.

To run the example cleaning script in an R console:

```
source("clean/clean-microhabitat-observations.R")
```
