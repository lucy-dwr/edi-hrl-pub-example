# Generate an EML metadata document for EDI publication
#
# This script uses hrlpub::make_eml_edi(), which wraps EMLassemblyline to
# produce an EML XML file. It reads:
#   - data tables from data/clean/
#   - metadata templates from publish/metadata_templates/
#   - attribute definitions from publish/metadata_templates/attributes_csv_template/
# and writes the EML file to publish/eml/{edi_number}.xml.
#
# Prerequisites before running:
#   1. Complete all metadata templates in publish/metadata_templates/
#      (see publish/README.md for the full list)
#   2. Reserve an EDI package number at https://portal.edirepository.org/
#      (log in -> Tools -> Reserve a Package ID). There is no hrlpub function
#      for this step; it must be done through the EDI web portal.
#   3. Store your EDI user ID in .Renviron as EDI_USER_ID.

# TODO: confirm EDI number reservation process with Ashley Vizek.

# TODO: Add "survey_locations_clean.csv" and its attributes file once that
# table is prepared. See publish/metadata_templates/attributes_survey_locations.*
# for the attribute template that is already stubbed out

# TODO: figure out filepath default for make_eml_edi(); it currently looks in
# publish/metadata_templates/attributes_csv_template but I am not sure that
# using the word "template" in our code makes sense (beyond actual templates)

# TODO: figure out how to work with EDI number here without actually reservoing
# or publishing

library(hrlpub)

# ==============================================================================
# Inputs ----
# ==============================================================================

# Data table(s) to include in the publication. Filenames only; make_eml_edi()
# reads from data/clean/ automatically
data_file_names <- "microhabitat_observations_clean.csv"

# Attribute definition file(s) for each data table above. Filenames only;
# make_eml_edi() reads from publish/metadata_templates/attributes_csv_template/
attributes_file_names <- "attributes_microhabitat_observations.csv"

# ==============================================================================
# Metadata ----
# ==============================================================================

title <- "Feather River Microhabitat Observations"
maintenance <- "annually"

# EDI package number. Reserve a number at https://portal.edirepository.org/
# before running. Use "edi.XXXX.1" for a new package, or increment the version
# (e.g., "edi.XXXX.2") when updating an existing one.
edi_number <- "TODO: replace with reserved EDI number, e.g. edi.1234.1"

# ==============================================================================
# Generate EML ----
# ==============================================================================

hrlpub::make_eml_edi(
  data_file_names       = data_file_names,
  attributes_file_names = attributes_file_names,
  title                 = title,
  maintenance           = maintenance,
  edi_number            = edi_number
)
