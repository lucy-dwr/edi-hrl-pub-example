# Publish runner for the demo workflow
#
# By default both stages are skipped so the pipeline can complete without
# EDI credentials or a reserved package number.
#
# To generate EML (requires EDI_USER_ID in .Renviron and a reserved EDI number
# filled in to publish/make-eml.R), set generate_eml = TRUE.
#
# To upload to EDI after EML is generated (also requires EDI_PASSWORD), set
# publish = TRUE.
run_publish <- function(clean_outputs = NULL,
                        qc_outputs = NULL,
                        generate_eml = TRUE,
                        publish = FALSE) {
  if (!isTRUE(generate_eml) && !isTRUE(publish)) {
    message("Publish step skipped (generate_eml = FALSE, publish = FALSE).")
    message("  - To generate EML: fill in publish/make-eml.R and set generate_eml = TRUE.")
    message("  - To upload to EDI: set publish = TRUE after EML is generated.")
    return(invisible(NULL))
  }

  if (isTRUE(generate_eml)) {
    eml_script <- "publish/make-eml.R"
    if (!file.exists(eml_script)) {
      stop("Missing EML script: ", eml_script, call. = FALSE)
    }
    message("Generating EML...")
    source(eml_script, local = new.env(parent = globalenv()))
  }

  if (isTRUE(publish)) {
    pub_script <- "publish-data.R"
    if (!file.exists(pub_script)) {
      stop("Missing publish script: ", pub_script, call. = FALSE)
    }
    message("Publishing to EDI...")
    source(pub_script, local = new.env(parent = globalenv()))
  }
}
