# Shared stage runner for both the script-first pipeline and the {targets} pipeline.
run_clean <- function() {
  result <- source("clean/clean-microhabitat-observations.R", local = TRUE)$value
  if (is.null(result)) {
    result <- list.files("data/clean", recursive = TRUE, full.names = TRUE)
  }
  result
}
