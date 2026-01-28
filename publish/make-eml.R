# Script to run the EMLassemblyline workflow to make EML (demo).

# Specify inputs
data_file_names <- "data/clean/microhabitat_observations_clean.csv"
attributes_file_names <- "publish/metadata_templates/attributes_microhabitat.csv"
template_dir <- "publish/metadata_templates"
eml_output_path <- "publish/eml/microhabitat_observations.eml"

# Complete required metadata (fill in)
title <- "TODO: microhabitat observations data package title"
geography <- "TODO: geographic description"
coordinates <- "TODO: bounding coordinates"
maintenance <- "TODO: maintenance description"
edi_number <- "TODO: EDI package number (if applicable)"

# Specify template inputs
abstract_file <- file.path(template_dir, "abstract.txt")
methods_file <- file.path(template_dir, "methods.docx")
keywords_file <- file.path(template_dir, "keywords.txt")
personnel_file <- file.path(template_dir, "personnel.txt")
taxa_file <- file.path(template_dir, "taxonomic_coverage.txt")
rights_file <- file.path(template_dir, "intellectual_rights.txt")
custom_units_file <- file.path(template_dir, "custom_units.txt")

# Toggle to run EML creation.
hrlpub::make_eml_edi(
  data_file_names = data_file_names,
  attributes_file_names = attributes_file_names,
  title = title,
  geography = geography,
  coordinates = coordinates,
  maintenance = maintenance,
  edi_number = edi_number,
  abstract_file = abstract_file,
  methods_file = methods_file,
  keywords_file = keywords_file,
  personnel_file = personnel_file,
  taxonomic_coverage_file = taxa_file,
  intellectual_rights_file = rights_file,
  custom_units_file = custom_units_file,
  eml_output_path = eml_output_path
)
