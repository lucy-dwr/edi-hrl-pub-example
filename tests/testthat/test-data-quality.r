# tests/testthat/test-data-quality.R
# ============================================
# DATA QUALITY TESTS
# ============================================
# These tests check for NA values, outliers, and data quality issues
# Configure settings in config.R

library(testthat)
library(readr)
library(dplyr)
library(here)

# Load configuration
source(here("tests", "testthat", "config.R"))

# ============================================
# HELPER FUNCTIONS
# ============================================

check_outliers_threshold <- function(data, col_name, thresholds) {
  values <- data[[col_name]]
  values <- values[!is.na(values)]

  outliers <- values < thresholds[1] | values > thresholds[2]

  list(
    has_outliers = any(outliers),
    n_outliers = sum(outliers),
    outlier_values = values[outliers],
    threshold_min = thresholds[1],
    threshold_max = thresholds[2]
  )
}

check_outliers_iqr <- function(data, col_name, multiplier = 1.5) {
  values <- data[[col_name]]
  values <- values[!is.na(values)]

  if (length(values) < 4) return(list(has_outliers = FALSE, n_outliers = 0))

  Q1 <- quantile(values, 0.25)
  Q3 <- quantile(values, 0.75)
  IQR_val <- Q3 - Q1

  lower_bound <- Q1 - multiplier * IQR_val
  upper_bound <- Q3 + multiplier * IQR_val

  outliers <- values < lower_bound | values > upper_bound

  list(
    has_outliers = any(outliers),
    n_outliers = sum(outliers),
    outlier_values = values[outliers],
    threshold_min = lower_bound,
    threshold_max = upper_bound
  )
}

# ============================================
# TESTS FOR EACH DATA FILE
# ============================================

for (file_name in DATA_FILES) {

  # Create a test context for this file
  test_that(paste("Data file exists:", file_name), {
    file_path <- get_data_file_path(file_name)
    expect_true(file.exists(file_path),
                info = paste("File not found:", file_path))
  })

  # Read the data file
  file_path <- get_data_file_path(file_name)

  # Skip remaining tests if file doesn't exist
  if (!file.exists(file_path)) {
    next
  }

  data <- read_csv(file_path, show_col_types = FALSE)

  # ============================================
  # TEST 1: Check for NA values in required columns
  # ============================================
  test_that(paste(file_name, "- Required columns have no NA values"), {
    for (col in REQUIRED_COLUMNS) {
      if (col %in% names(data)) {
        n_na <- sum(is.na(data[[col]]))
        expect_equal(n_na, 0,
                     info = paste("Column", col, "has", n_na, "NA values"))
      }
    }
  })

  # ============================================
  # TEST 2: Check maximum NA percentage for all columns
  # ============================================
  test_that(paste(file_name, "- No column exceeds maximum NA percentage"), {
    for (col in MAX_NA_PERCENT_COLUMNS) {
      na_percent <- (sum(is.na(data[[col]])) / nrow(data)) * 100
      expect_lte(na_percent, MAX_NA_PERCENT)
      if(na_percent > MAX_NA_PERCENT) {
        print(paste("Column", col, "has", round(na_percent, 1),"% NA values (max allowed:", MAX_NA_PERCENT, "%)"))
      }
    }
  })

  # ============================================
  # TEST 3: Check for outliers using specified method
  # ============================================
  if (length(OUTLIER_THRESHOLDS) > 0 && !USE_IQR_METHOD) {
    test_that(paste(file_name, "- No outliers beyond specified thresholds"), {
      for (col_name in names(OUTLIER_THRESHOLDS)) {
        if (col_name %in% names(data)) {
          result <- check_outliers_threshold(data, col_name, OUTLIER_THRESHOLDS[[col_name]])

          expect_false(result$has_outliers,
                       info = paste("Column", col_name, "has", result$n_outliers,
                                    "outlier(s) outside range [",
                                    result$threshold_min, ",", result$threshold_max, "].",
                                    "Values:", paste(head(result$outlier_values, 5), collapse = ", ")))
        }
      }
    })
  }

  if (USE_IQR_METHOD && length(OUTLIER_THRESHOLDS) > 0) {
    test_that(paste(file_name, "- No outliers using IQR method"), {
      for (col_name in names(OUTLIER_THRESHOLDS)) {
        if (col_name %in% names(data) && is.numeric(data[[col_name]])) {
          result <- check_outliers_iqr(data, col_name, IQR_MULTIPLIER)

          expect_false(result$has_outliers,
                       info = paste("Column", col_name, "has", result$n_outliers,
                                    "outlier(s) using IQR method.",
                                    "Bounds: [", round(result$threshold_min, 2), ",",
                                    round(result$threshold_max, 2), "].",
                                    "Values:", paste(head(result$outlier_values, 5), collapse = ", ")))
        }
      }
    })
  }

  # ============================================
  # TEST 4: Validate date columns
  # ============================================
  if (length(DATE_COLUMNS) > 0) {
    test_that(paste(file_name, "- Date columns are properly formatted"), {
      for (col in DATE_COLUMNS) {
        if (col %in% names(data)) {
          dates <- data[[col]][!is.na(data[[col]])]

          # Try to parse dates
          parsed <- as.Date(dates, format = EXPECTED_DATE_FORMAT)
          n_invalid <- sum(is.na(parsed))

          expect_equal(n_invalid, 0,
                       info = paste("Column", col, "has", n_invalid,
                                    "invalid date(s). Expected format:",
                                    EXPECTED_DATE_FORMAT))
        }
      }
    })
  }

  # ============================================
  # TEST 5: Check positive-only columns
  # ============================================
  if (length(POSITIVE_ONLY_COLUMNS) > 0) {
    test_that(paste(file_name, "- Positive-only columns contain no negative values"), {
      for (col in POSITIVE_ONLY_COLUMNS) {
        if (col %in% names(data) && is.numeric(data[[col]])) {
          values <- data[[col]][!is.na(data[[col]])]
          n_negative <- sum(values < 0)

          expect_equal(n_negative, 0,
                       info = paste("Column", col, "has", n_negative,
                                    "negative value(s)"))
        }
      }
    })
  }

  # ============================================
  # TEST 6: Check proportion columns (0-1 range)
  # ============================================
  if (length(PROPORTION_COLUMNS) > 0) {
    test_that(paste(file_name, "- Proportion columns are between 0 and 1"), {
      for (col in PROPORTION_COLUMNS) {
        if (col %in% names(data) && is.numeric(data[[col]])) {
          values <- data[[col]][!is.na(data[[col]])]
          n_out_of_range <- sum(values < 0 | values > 1)

          expect_equal(n_out_of_range, 0,
                       info = paste("Column", col, "has", n_out_of_range,
                                    "value(s) outside [0, 1] range"))
        }
      }
    })
  }

  # ============================================
  # TEST 7: Check dataset is not empty
  # ============================================
  test_that(paste(file_name, "- Dataset is not empty"), {
    expect_gt(nrow(data), 0)
    expect_gt(ncol(data), 0)
  })
}

# ============================================
# SUMMARY TEST
# ============================================
test_that("All configured data files were tested", {
  n_files <- length(DATA_FILES)
  expect_gt(n_files, 0)
})
