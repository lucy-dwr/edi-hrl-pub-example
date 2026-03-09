# tests

This folder is reserved for automated data quality tests. No tests are currently included in this example repository — see the Open items section of the [root README](../README.md) for context on when and how to add them.

To add tests to your own dataset workflow, the standard approach in R is to use [`{testthat}`](https://testthat.r-lib.org/) with a `tests/testthat/` directory structure. Tests can then be run from an R console with:

```r
testthat::test_dir("tests/testthat")
```

or in CI via:

```bash
Rscript -e 'testthat::test_dir("tests/testthat")'
```
