# publish

Export and publication steps that package `data/clean/` outputs for publication to EDI. Use this folder for scripts and stash rendered outputs or links to hosted artifacts. Expose a `run_publish()` function (e.g., in `publish/publish.R`) so both the runner and optional {targets} pipeline can call it.

## Metadata workflow (microhabitat observations demo)

1. Fill in the metadata templates in [`publish/metadata/`](metadata/):
   - [`abstract.txt`](metadata/abstract.txt)
   - [`attributes_microhabitat_observations.csv`](metadata/attributes/attributes_microhabitat_observations.csv)
   - [`keywords.txt`](metadata/keywords.txt)
   - [`personnel/personnel.csv`](metadata/personnel/personnel.csv)
   - [`methods.docx`](metadata/methods.docx)
   - [`taxonomic_coverage.txt`](metadata/taxonomic_coverage.txt) (if needed)
   - [`custom_units.txt`](metadata/custom_units.txt) (if needed)
   - [`intellectual_rights.txt`](metadata/intellectual_rights.txt)

2. Reserve an EDI package number at <https://portal.edirepository.org/>
   (log in → Tools → Reserve a Package ID) and fill in `edi_number` in
   [`publish/make-eml.R`](make-eml.R).

3. Run the script in an R console:

```r
source("scripts/setup.R")
source("publish/make-eml.R")
```

This writes the EML file to [`publish/eml/`](eml/).

## Publication (illustration only)

[`publish/publish.R`](publish.R) shows how to publish to EDI via the `run_publish()`
function. In this demo, publication is disabled (`publish = FALSE`) and is included
for reference only.
