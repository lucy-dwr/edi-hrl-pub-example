# Generate an EML metadata document for EDI publication
#
# This script uses hrlpub::make_eml_edi(), which wraps EMLassemblyline to
# produce an EML XML file. It reads:
#   - data tables from data/clean/
#   - metadata from publish/metadata/
#   - attribute definitions from publish/metadata/attributes/
# and writes the EML file to publish/eml/{edi_number}.xml.
#
# NOTE: This script only generates the EML metadata file locally. It does NOT
# submit anything to EDI. You can run it, inspect the output XML, and verify
# the metadata looks correct before publishing.
#
# Prerequisites before running:
#   1. Complete all metadata templates in publish/metadata/
#      (see publish/README.md for the full list)
#   2. Replace the edi_number placeholder below with a real reserved package
#      number before submitting. Reserve one at https://portal.edirepository.org/
#      (log in -> Tools -> Reserve a Package ID). There is no hrlpub function
#      for this step; it must be done through the EDI web portal.

library(hrlpub)

# ==============================================================================
# Inputs ----
# ==============================================================================

# Data table(s) to include in the publication. Filenames only; make_eml_edi()
# reads from data/clean/ automatically
data_file_names <- "microhabitat_observations_clean.csv"

# Attribute definition file(s) for each data table above. Filenames only;
# make_eml_edi() reads from publish/metadata/attributes/
attributes_file_names <- "attributes_microhabitat_observations_clean.csv"

# ==============================================================================
# Metadata ----
# ==============================================================================

title <- "Feather River Microhabitat Observations 2001-2002"
maintenance <- "annually"

# EDI package number. The placeholder below ("edi.000.1") is safe to use for
# generating and inspecting EML locally. Before submitting to EDI, replace it
# with your reserved package number. Use "edi.XXXX.1" for a new package, or
# increment the version (e.g., "edi.XXXX.2") when updating an existing one.
edi_number <- "edi.000.1"

# ==============================================================================
# Generate EML ----
# ==============================================================================

# This call produces an EML XML file locally. It does not contact EDI.
# Open the output file in publish/eml/ to inspect the generated metadata.
hrlpub::make_eml_edi(
  data_file_names       = data_file_names,
  attributes_file_names = attributes_file_names,
  title                 = title,
  maintenance           = maintenance,
  edi_number            = edi_number
)

# ==============================================================================
# Publish to EDI (not run in tutorial) ----
# ==============================================================================

# Once the EML looks correct and you are ready to publish for real:
#   1. Reserve a package number at https://portal.edirepository.org/
#      (log in -> Tools -> Reserve a Package ID)
#   2. Replace edi_number above with your reserved number
#   3. Add your EDI credentials to .Renviron:
#        EDI_USER_ID=your_username
#        EDI_PASSWORD=your_password
#   4. Uncomment and run the call below.
#
# Use publish_environment = "staging" first to review your submission before
# committing to production.

# hrlpub::publish_data_edi(
#   path_eml_file       = file.path("publish", "eml", paste0(edi_number, ".xml")),
#   publish_type        = "new",       # or "update" for a new version
#   edi_number          = edi_number,
#   publish_environment = "staging"    # change to "production" when ready
# )
