# Example workflow for publishing data to EDI

## Tutorial walkthrough

To follow the tutorial step by step, read and run the example scripts in this order:

1. **Ingest** — [`ingest/read-data-cdec.R`](ingest/read-data-cdec.R): fetch data from an API and write it to `data/raw/`
2. **Clean** — [`clean/clean-microhabitat-observations.R`](clean/clean-microhabitat-observations.R): clean raw data, standardize vocabularies, and record issues
3. **QC** — [`qc/qc-microhabitat-observations.R`](qc/qc-microhabitat-observations.R): quality-control cleaned data and generate a QC report
4. **Publish** — [`publish/make-eml.R`](publish/make-eml.R): generate EML metadata for EDI publication (requires EDI credentials and a reserved package number — see [`publish/README.md`](publish/README.md))

Each script can be sourced directly and includes comments explaining each step. See the folder READMEs for more detail on each stage.

## Running a pipeline to clean data, generate metadata, and publish

This repository contains an example of an open-source process for data import, cleaning, metadata generation, and publication. The workflow aligns with the expectations of the Healthy Rivers and Landscapes Science Committee for making our data open and aligned with [FAIR principles](https://www.go-fair.org/fair-principles/).

The workflow in this repository can be run in two ways: either by sourcing the pipeline orchestration script `scripts/run_pipeline.R` or by sourcing individual scripts in the pipeline (the simplest option), or by using the `{targets}` package to orchestrate the workflow with explicit dependencies and automatic re-runs when inputs change (a more advanced but robust option). The script-first approach is easiest to follow step-by-step and works well for learning or quick edits, but it requires manual sequencing and reruns. The `{targets}` approach adds a small learning curve but provides better reproducibility, caching, and a clear dependency graph for larger or more iterative work and is more robust to re-run when there are updates.

### Simple script-first approach

- To run a single step: run the relevant script, e.g., `source("clean/clean-microhabitat-observations.R")`.
- To run the sequential pipeline: `source("scripts/run_pipeline.R")`.
- If you need to install dependencies, run `source("scripts/setup.R")` first.

### More advanced `{targets}` approach

- `_targets.R` defines a small `{targets}` pipeline. The pipeline can be run in two ways:
    - In an R console with: `targets::tar_make()`
    - In continuous integration through GitHub Actions with `Rscript -e "targets::tar_make()"` in the workflow YAML file (e.g., `.github/workflows/test-data.yml`).

## Repository structure

- **`data/`:** data objects
    - **`raw/`:** raw (untreated) data
    - **`clean/`:** cleaned data
- **`ingest/`:** scripts that pull data into `data/raw/` if an API or scripted download is used
- **`clean/`:** scripts that clean raw data to produce clean datasets
- **`qc/`:** quality control scripts and reports to validate cleaned data
- **`publish/`:** scripts to generate metadata and publish cleaned data and metadata to EDI
- **`scripts/`:** scripts that run ingest → clean → qc → publish
- **`targets/`:** optional `{targets}` documentation/templates (main config is `_targets.R`)
- **`tests/`:** automated tests to ensure code quality and correctness as needed
    - **`testthat/`:** unit tests using the `testthat` package

## Example

This repository contains an example workflow for a dataset of fish microhabitat observations. A partial workflow for CDEC precipitation data is also included to illustrate how to handle an API call in data ingestion.

## Open items

- [`publish/metadata_templates/taxonomic_coverage.txt`](publish/metadata_templates/taxonomic_coverage.txt): needs to be corrected and expanded to cover all species in the dataset.
- [`publish/metadata_templates/custom_units.txt`](publish/metadata_templates/custom_units.txt): contains units carried over from other datasets that need to be removed.


