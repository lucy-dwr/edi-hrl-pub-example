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
    # Must match the EDI number used in publish/make-eml.R.
    edi_number <- "edi.000.1"

    # Publish to staging first to review the formatted data package, then
    # switch publish_environment to "production" for the final release.
    # Use publish_type = "update" (and increment edi_number) for revisions
    # to an already-published package.
    message("Publishing to EDI...")
    hrlpub::publish_data_edi(
      publish_type        = "new",
      edi_number          = edi_number,
      publish_environment = "staging"
    )
  }
}
