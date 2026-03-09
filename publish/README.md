# publish

Export and publication steps that package `data/clean/` outputs for publication to EDI. Use this folder for scripts and stash rendered outputs or links to hosted artifacts. Expose a `run_publish()` function (e.g., in `publish/publish.R`) so both the runner and optional {targets} pipeline can call it; you can delegate to `publish-data.R` from there.

## Metadata workflow (microhabitat observations demo)

1. Fill in the metadata templates in [`publish/metadata_templates/`](metadata_templates/):
   - [`abstract.txt`](metadata_templates/abstract.txt)
   - [`attributes_microhabitat_observations.csv`](metadata_templates/attributes_csv_template/attributes_microhabitat_observations.csv)
   - [`keywords.txt`](metadata_templates/keywords.txt)
   - [`personnel_csv_template/personnel.csv`](metadata_templates/personnel_csv_template/personnel.csv)
   - [`methods.docx`](metadata_templates/methods.docx)
   - [`taxonomic_coverage.txt`](metadata_templates/taxonomic_coverage.txt) (if needed)
   - [`custom_units.txt`](metadata_templates/custom_units.txt) (if needed)
   - [`intellectual_rights.txt`](metadata_templates/intellectual_rights.txt)

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

[`publish-data.R`](../publish-data.R) shows how to publish to EDI. In this demo,
do not run the publish step; it is included for reference only.
