# Configuration & Initialization

# Load required libraries
library(ArchR)
library(ggplot2)
library(tidyverse)
library(patchwork)

## Configuration Section ##

# Set random seed for reproducibility
set.seed(1)

# Set number of threads for parallel processing
arch_r_threads = max(1, parallel::detectCores() - 2)

# Define directory structure
project_dir = getwd()
data_dir = file.path(project_dir, "data")
result_dir = file.path(project_dir, "results")

# Define input file paths
downloaded_zip_file_path = file.path("scbi_p2.zip")
extracted_zip_path = file.path(data_dir, "scbi_p2")
rna_pbmc_path = file.path("new_pbmc.rds")
pdf_file_path <- file.path(result_dir, "analysis_report.pdf")

## End Configuration ##

# Create directories if they don't exist
if (!dir.exists(project_dir)) {
  dir.create(project_dir, recursive = TRUE)
  message("Created project directory: ", project_dir)
}

if (getwd() != project_dir) {
  setwd(project_dir)
}

if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
  message("Created data directory: ", data_dir)
}

if (!dir.exists(result_dir)) {
  dir.create(result_dir, recursive = TRUE)
  message("Created results directory: ", result_dir)
}

# Verify input files exist
if (!file.exists(downloaded_zip_file_path)) {
  stop("The required ZIP file is missing. Please place the file at: ", downloaded_zip_file_path)
} else {
  message("ZIP file found: ", downloaded_zip_file_path)
}

if (!dir.exists(extracted_zip_path)) {
  message("Extracting ZIP file to: ", extracted_zip_path)
  unzip(zipfile = downloaded_zip_file_path, exdir = extracted_zip_path)
  message("Extraction complete.")
} else {
  message("ZIP file already extracted: ", extracted_zip_path)
}

if (!file.exists(rna_pbmc_path)) {
  stop("The RNA PBMC file is missing. Please place the file at: ", rna_pbmc_path)
} else {
  message("RNA PBMC file found: ", rna_pbmc_path)
}

message("Setup complete. Ready for analysis.")
