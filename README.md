# Example workflow for publishing data to EDI

> **This is a tutorial repository.** It demonstrates the HRL data publication workflow using an example dataset (Feather River microhabitat observations) and is meant to be read and run as a learning exercise. To start your own dataset workflow, use the [hrl-edi-template](https://github.com/FlowWest/hrl-edi-template) repository, which was designed to be cloned and adapted.

## Prerequisites

This repository uses [`{renv}`](https://rstudio.github.io/renv/) to manage R package dependencies. `renv` locks all packages to specific versions recorded in [`renv.lock`](renv.lock), so anyone who clones the repository gets the same package versions.

To restore the project environment, run this once in your R console from the project root:

```r
source("scripts/setup.R")
```

This calls `renv::restore()`, which installs all required packages at the recorded versions into a project-local library. It does not affect packages installed elsewhere on your machine.

## Tutorial walkthrough

To follow the tutorial step by step, read and run the example scripts in this order:

1. **Ingest** — [`ingest/read-data-cdec.R`](ingest/read-data-cdec.R): fetch data from an API and write it to `data/raw/`
2. **Clean** — [`clean/clean-microhabitat-observations.R`](clean/clean-microhabitat-observations.R): clean raw data, standardize vocabularies, and record issues
3. **QC** — [`qc/qc-microhabitat-observations.R`](qc/qc-microhabitat-observations.R): quality-control cleaned data and generate a QC report
4. **Publish** — [`publish/make-eml.R`](publish/make-eml.R): generate an EML metadata file locally; the script also shows (but does not run) the submission step that would publish to EDI (see [`publish/README.md`](publish/README.md))

Each script can be sourced directly and includes comments explaining each step. README files also exist throughout to explain components of this tutorial repository.

### Tutorial scripts vs. runner functions

Each stage has two scripts with different purposes:

- **Tutorial scripts** (e.g., `clean/clean-microhabitat-observations.R`) are designed to be read and run interactively, step by step. They include detailed comments explaining each decision. Start here when learning the workflow.
- **Runner functions** (e.g., `clean/clean.R`) each expose a `run_<stage>()` function (`run_ingest()`, `run_clean()`, `run_qc()`, `run_publish()`) used by the pipeline orchestration options below. They call the tutorial script internally, so the logic lives in one place.

See the folder READMEs for more detail on each stage.

## Running a pipeline to clean data, generate metadata, and publish

This repository contains an example of an open-source process for data import, cleaning, metadata generation, and publication. The workflow aligns with the expectations of the Healthy Rivers and Landscapes Science Committee for making our data open and aligned with [FAIR principles](https://www.go-fair.org/fair-principles/).

The workflow in this repository can be run in three ways. Sourcing **individual scripts** step by step is the simplest option and best for learning — you run each stage yourself in order. The **pipeline runner** ([`scripts/run_pipeline.R`](scripts/run_pipeline.R)) executes all stages in sequence automatically, which is convenient for a quick end-to-end run without the overhead of a dependency framework. The **`{targets}` approach** adds a small learning curve but tracks dependencies between stages and only re-runs what has changed, making it more robust and efficient for iterative work on a real dataset.

### Simple script-first approach

- To run a single step: run the relevant script, e.g., `source("clean/clean-microhabitat-observations.R")`.
- To run the sequential pipeline: `source("scripts/run_pipeline.R")`.

### More advanced `{targets}` approach

[`{targets}`](https://books.ropensci.org/targets/) is an R package for defining pipelines as explicit dependency graphs. Rather than running scripts manually in order, you define each step as a *target* and `{targets}` figures out what needs to re-run based on what has changed. This is useful when iterating on a dataset repeatedly — for example, if you update cleaning logic, only the clean, QC, and publish steps re-run; ingest is skipped if its inputs haven't changed.

[`_targets.R`](_targets.R) at the project root defines the pipeline for this repository. Run it with:

```r
targets::tar_make()
```

Or in continuous integration via `Rscript -e "targets::tar_make()"` in a GitHub Actions workflow (e.g., `.github/workflows/test-pipeline-targets.yml`).

**When to use `{targets}` vs. `scripts/run_pipeline.R`:** For learning the workflow step by step, the script-first approach is simpler. `{targets}` is more useful once you are iterating on a real dataset and want automatic caching and re-run detection.

## Repository structure

- **`data/`:** data objects
    - **`raw/`:** raw (untreated) data
    - **`clean/`:** cleaned data
- **`ingest/`:** scripts that pull data into `data/raw/` if an API or scripted download is used
- **`clean/`:** scripts that clean raw data to produce clean datasets
- **`qc/`:** quality control scripts and reports to validate cleaned data
- **`publish/`:** scripts to generate metadata and publish cleaned data and metadata to EDI
- **`scripts/`:** scripts that run ingest → clean → qc → publish
- **`tests/`:** automated tests to ensure code quality and correctness as needed

## Example

This repository contains an example workflow for a dataset of fish microhabitat observations. A partial workflow for CDEC precipitation data is also included to illustrate how to handle an API call in data ingestion.

## Open items

- [`publish/metadata_templates/taxonomic_coverage.txt`](publish/metadata_templates/taxonomic_coverage.txt): needs to be corrected and expanded to cover all species in the dataset.
- [`publish/metadata_templates/custom_units.txt`](publish/metadata_templates/custom_units.txt): contains units carried over from other datasets that need to be removed.
- Rename "template" directories: `publish/metadata_templates/` and `publish/metadata_templates/attributes_csv_template/` are named as if they contain blank templates, but in this repo they hold filled-in example metadata. Better names would be something like `publish/metadata/` and `publish/metadata/attributes/`. This rename requires a corresponding change to the path constants in `hrlpub::make_eml_edi()`, so it should be coordinated with an update to the `hrlpub` package.
- Testing infrastructure: this repository does not include automated data quality tests. For a production dataset workflow, consider adding `{testthat}` tests (or similar) to assert pipeline invariants — for example, that required columns are present and non-empty, that cleaned data contains no negative values in physical measurement columns, that observation attributes fall within anticipated ranges, and that date columns parse correctly. These checks are distinct from the QC stage, which flags records for scientific review; unit tests would catch regressions introduced by changes to cleaning or QC scripts.
