# Publish a completed EML package to EDI.
#
# This script is provided as a reference illustration — do not run it as part
# of the demo. Run publish/make-eml.R first to generate the EML file, then
# use this script to upload it to EDI.
#
# Prerequisites:
#   1. Run publish/make-eml.R to generate publish/eml/{edi_number}.xml.
#   2. Store EDI credentials in .Renviron as EDI_USER_ID and EDI_PASSWORD.
#   3. Use the same edi_number as in make-eml.R.
#
# NOTE: hrlpub::publish_data_edi() ignores its path_eml_file argument and
# instead reads the EML from data-raw/eml/{edi_number}.xml. However,
# hrlpub::make_eml_edi() writes the EML to publish/eml/{edi_number}.xml.
# These paths do not match. Before publishing, confirm where the EML file
# was written and copy or move it to the location publish_data_edi() expects,
# or raise the path mismatch with the hrlpub maintainers.

library(hrlpub)

# Must match the EDI number used in publish/make-eml.R.
edi_number <- "TODO: replace with reserved EDI number, e.g. edi.1234.1"

# Publish to staging first to review the formatted data package, then
# switch publish_environment to "production" for the final release.
# Use publish_type = "update" (and increment edi_number) for revisions
# to an already-published package.
hrlpub::publish_data_edi(
  publish_type        = "new",
  edi_number          = edi_number,
  publish_environment = "staging"
)
