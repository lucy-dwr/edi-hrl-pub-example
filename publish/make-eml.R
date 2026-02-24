# Script to run the EMLassemblyline workflow to make EML (demo).

# Specify inputs
data_file_names <- "data/clean/microhabitat_observations_clean.csv"
attributes_file_names <- "publish/metadata_templates/attributes_microhabitat_observations.csv" # needs to be "attributes_NAME_OF_DATA_TABLE.csv"
template_dir <- "publish/metadata_templates"
eml_output_path <- "publish/eml/microhabitat_observations.eml"

# Complete required metadata (fill in)
title <- "TODO: microhabitat observations data package title"
maintenance <- "TODO: maintenance description"
edi_number <- "TODO: EDI package number (if applicable)"

# TODO: Fill out metadata files and objects

# Specify template inputs
abstract_file <- file.path(template_dir, "abstract.txt")
methods_file <- file.path(template_dir, "methods.docx")
keywords_file <- file.path(template_dir, "keywords.txt")
personnel_file <- file.path(template_dir, "personnel.txt")
geography_file <- file.path(template_dir, "geographic_coverage.txt")
taxa_file <- file.path(template_dir, "taxonomic_coverage.txt")
rights_file <- file.path(template_dir, "intellectual_rights.txt")
custom_units_file <- file.path(template_dir, "custom_units.txt")

# Create EML
hrlpub::make_eml_edi(data_file_names = data_file_names,
                     attributes_file_names = attributes_file_names,
                     title = title,
                     maintenance = maintenance,
                     edi_number = edi_number)

