# metadata_templates

These files provide the metadata that `hrlpub::make_eml_edi()` reads to produce
an EML (Ecological Metadata Language) document for EDI publication. EML is an
XML-based standard that describes who collected the data, where, when, how, and
under what rights — it is what makes a dataset findable and reusable by others
(the "F" and "R" in [FAIR](https://www.go-fair.org/fair-principles/)).

The files here are filled in for the example microhabitat dataset and illustrate
what completed metadata templates look like. To start your own dataset workflow,
use the [hrl-edi-template](https://github.com/FlowWest/hrl-edi-template)
repository, which provides blank versions of these files ready to fill in.

## Source files

| File | What it contains |
|------|-----------------|
| [`abstract.txt`](abstract.txt) | A plain-text paragraph describing the study and dataset |
| [`keywords.txt`](keywords.txt) | Tab-separated keywords for discovery; `keywordThesaurus` column can be left blank |
| [`personnel/personnel.csv`](personnel/personnel.csv) | CSV list of dataset creators and contacts; one row per person-role combination (roles: `creator`, `contact`) |
| [`geographic_coverage.txt`](geographic_coverage.txt) | Bounding box coordinates (north/south/east/west) and a place name |
| [`intellectual_rights.txt`](intellectual_rights.txt) | License and reuse terms; the CC license here applies to most HRL datasets and usually does not need to change |
| [`methods.docx`](methods.docx) | Free-text description of field and lab methods |
| [`taxonomic_coverage.txt`](taxonomic_coverage.txt) | Taxonomic names, authority system, and authority IDs for species in the dataset; only needed if your dataset includes species observations |
| [`custom_units.txt`](custom_units.txt) | Definitions for units used in your data that are not in the standard EML unit dictionary; only needed if your data uses non-standard units |
| [`attributes/attributes_microhabitat_observations.csv`](attributes/attributes_microhabitat_observations.csv) | Column-by-column definitions for each data table: name, description, class, units, missing value codes; one file per data table |

## Auto-generated files (do not edit)

`make_eml_edi()` converts the CSV source files to tab-separated `.txt` files
before passing them to EMLassemblyline. These are written into this folder
automatically each time the script runs:

- [`personnel.txt`](personnel.txt) — generated from [`personnel/personnel.csv`](personnel/personnel.csv)
- `attributes_<table_name>.txt` — generated from [`attributes/attributes_<table_name>.csv`](attributes/attributes_microhabitat_observations.csv) (example)

Do not edit the `.txt` files directly; any changes will be overwritten the next
time `make_eml_edi()` runs. Edit the CSV source files instead.

## Notes on this example

- **[`taxonomic_coverage.txt`](taxonomic_coverage.txt)** is incomplete — it covers only Chinook salmon and needs to be expanded to include all species in the dataset (steelhead, tule perch, speckled dace, Sacramento pikeminnow). See the Open items section of the root README.
- **[`custom_units.txt`](custom_units.txt)** contains units carried over from other datasets that do not apply to the microhabitat observations and should be removed before publishing. See the Open items section of the root README.
- **[`attributes/attributes_survey_locations.csv`](attributes/attributes_survey_locations.csv)** is stubbed out but the corresponding data table (`survey_locations_clean.csv`) is not yet included in the example publication.
