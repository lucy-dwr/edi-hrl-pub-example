# Clean runner for the demo workflow
#
# This runner executes the tutorial cleaning script and returns only clean-stage
# outputs so targets can track them with format = "file"
#
# It expects the primary raw microhabitat CSV from ingest (or manual placement)
# and can accept raw_outputs from an upstream runner for dependency checks
run_clean <- function(
  raw_outputs = NULL,
  raw_input_path = "data/raw/microhabitat_observations_raw.csv",
  script_path = "clean/clean-microhabitat-observations.R",
  clean_output_path = "data/clean/microhabitat_observations_clean.csv",
  issue_summary_path = "data/clean/microhabitat_observations_issue_summary.csv",
  diagnostics_dir = "data/clean/diagnostics",
  verbose = FALSE
) {
  # Validate that the cleaning script exists before trying to source it
  if (!file.exists(script_path)) {
    stop("Missing cleaning script: ", script_path, call. = FALSE)
  }

  # If raw_outputs were supplied by an upstream stage, check that the expected
  # raw file path is represented there (normalized for relative/absolute forms)
  if (!is.null(raw_outputs)) {
    expected_raw_norm <- normalizePath(raw_input_path, winslash = "/", mustWork = FALSE)
    listed_raw_norm <- normalizePath(as.character(raw_outputs), winslash = "/", mustWork = FALSE)
    has_expected_raw <- expected_raw_norm %in% listed_raw_norm
  } else {
    has_expected_raw <- TRUE
  }

  if (!has_expected_raw) {
    warning(
      "Expected raw input not listed in raw_outputs: ", raw_input_path,
      "\nProceeding because direct file existence is also checked.",
      call. = FALSE
    )
  }

  # Also enforce direct file existence so clean can run outside targets
  if (!file.exists(raw_input_path)) {
    stop(
      "Required raw input is missing: ", raw_input_path,
      "\nRun ingest first or place the raw file in data/raw/.",
      call. = FALSE
    )
  }

  # Provide runtime configuration to the cleaning script via local variables
  # in an isolated environment
  clean_env <- new.env(parent = globalenv())
  clean_env$raw_path <- raw_input_path
  clean_env$clean_path <- clean_output_path
  clean_env$issues_path <- issue_summary_path
  clean_env$diagnostics_dir <- diagnostics_dir
  clean_env$verbose <- verbose

  source(script_path, local = clean_env)

  # Return only clean-stage-owned diagnostics (excluding QC artifacts) so stage
  # boundaries remain clear in pipelines
  diagnostics_paths <- list.files(
    diagnostics_dir,
    pattern = "^microhabitat_(date|negative|species|channel|issue_log)",
    full.names = TRUE
  )

  outputs <- unique(c(clean_output_path, issue_summary_path, diagnostics_paths))
  outputs <- outputs[file.exists(outputs)]

  if (length(outputs) == 0) {
    stop("Cleaning finished but no expected clean outputs were found.", call. = FALSE)
  }

  outputs
}
