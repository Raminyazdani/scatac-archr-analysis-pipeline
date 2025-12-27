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

