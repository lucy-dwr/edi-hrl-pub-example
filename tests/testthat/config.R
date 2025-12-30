# tests/testthat/config.R
# ============================================
# DATA TESTING CONFIGURATION
# ============================================
# Edit this file to specify which data files to test
# and customize testing parameters

library(here)

# ============================================
# 1. SPECIFY YOUR DATA FILES
# ============================================
# Add the names of your data files (without .csv extension)
# These should be in your data directory

DATA_FILES <- c(
  "microhabitat_observations"
  # Add more files as needed
)

# ============================================
# 2. SPECIFY DATA DIRECTORY
# ============================================
DATA_DIR <- here("data-raw","data_objects")

# ============================================
# 3. OUTLIER DETECTION SETTINGS
# ============================================
# Define which columns to check for outliers and their thresholds
# Format: list(column_name = c(min_value, max_value))

OUTLIER_THRESHOLDS <- list(
  temperature = c(-10, 50),    # Temperature should be between -10 and 50
  focal_velocity = c(0, 6),    # Velocity is expected to be between 0 to 4 fps
  velocity = c(0, 6),          # Velocity is expected to be between 0 to 4 fps
  depth = c(0, 350),           # Depth should be between 0 and 100
  dist_to_bottom = c(0, 150)   # Depth should be between 0 and 100
  # Add more columns as needed
)

# Alternative: Use IQR method for outlier detection
# Set to TRUE to use IQR method (outliers are values beyond Q1-1.5*IQR or Q3+1.5*IQR)
USE_IQR_METHOD <- FALSE
IQR_MULTIPLIER <- 1.5  # Standard is 1.5, increase for more lenient detection

# ============================================
# 4. NA VALUE SETTINGS
# ============================================
# Columns that MUST NOT have NA values
REQUIRED_COLUMNS <- c(
  "date",
  "micro_hab_data_tbl_id",
  "location_table_id",
  "transect_code",
  "count"
  # Add more required columns
)

MAX_NA_PERCENT_COLUMNS <- c("micro_hab_data_tbl_id", "location_table_id", "transect_code",
                            "date", "count", "depth", "velocity", "surface_turbidity", "percent_fine_substrate",
                            "percent_sand_substrate", "percent_small_gravel_substrate", "percent_large_gravel_substrate",
                            "percent_cobble_substrate", "percent_boulder_substrate", "percent_no_cover_inchannel",
                            "percent_small_woody_cover_inchannel", "percent_large_woody_cover_inchannel",
                            "percent_submerged_aquatic_veg_inchannel", "percent_undercut_bank",
                            "percent_no_cover_overhead", "percent_cover_half_meter_overhead",
                            "percent_cover_more_than_half_meter_overhead", "channel_geomorphic_unit"
)

# Maximum allowed percentage of NA values for other columns (0-100)
MAX_NA_PERCENT <- 10  # Fail if any column has more than 10% NA values

# ============================================
# 5. DATE COLUMN SETTINGS (optional)
# ============================================
# If you have date columns, specify them here for validation
DATE_COLUMNS <- c(
  "date"
)

# Expected date format (e.g., "YYYY-MM-DD", "MM/DD/YYYY")
EXPECTED_DATE_FORMAT <- "%Y-%m-%d"

# ============================================
# 6. ADDITIONAL VALIDATION (optional)
# ============================================
# Columns that should only contain positive values
POSITIVE_ONLY_COLUMNS <- c(
  "count",
  "fl_mm",
  "dist_to_bottom",
  "depth",
  "focal_velocity",
  "velocty",
  "surface_turbidity",
  "percent_fine_substrate",
  "percent_sand_substrate",
  "percent_small_gravel_substrate",
  "percent_large_gravel_substrate",
  "percent_cobble_substrate",
  "percent_boulder_substrate",
  "percent_no_cover_inchannel",
  "percent_small_woody_cover_inchannel",
  "percent_large_woody_cover_inchannel",
  "percent_submerged_aquatic_veg_inchannel",
  "percent_undercut_bank",
  "percent_no_cover_overhead",
  "percent_cover_half_meter_overhead",
  "percent_cover_more_than_half_meter_overhead"
)

# Columns that should be within 0-1 range (e.g., proportions)
PROPORTION_COLUMNS <- c(
  # "proportion_occupied"
)

# ============================================
# HELPER FUNCTIONS (do not edit)
# ============================================
get_data_file_path <- function(file_name) {
  paste0(DATA_DIR, "/", file_name, ".csv")
}
