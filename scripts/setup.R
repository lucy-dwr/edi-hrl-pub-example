# Friendly setup helper

setup <- function(use_renv = TRUE) {
  if (use_renv && file.exists("renv.lock")) {
    if (!requireNamespace("renv", quietly = TRUE)) {
      install.packages("renv")
    }
    renv::restore(prompt = FALSE)
    return(invisible(TRUE))
  }

  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  if (!requireNamespace("cder", quietly = TRUE)) {
    install.packages("cder")
  }

  # TODO: update this install
  if (!requireNamespace("hrlpub", quietly = TRUE)) {
    remotes::install_github("TODO_ORG/hrlpub")
  }

  invisible(TRUE)
}

setup()
