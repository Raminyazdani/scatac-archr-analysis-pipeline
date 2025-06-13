# Sys.setenv(CONDA_BUILD_SYSROOT="/")
# install.packages("renv")
# renv::init()

# if (!requireNamespace("devtools", quietly = TRUE)) {
#   install.packages("devtools", dependencies = TRUE)
# }
# 
# # Install 'BiocManager' if not already installed
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager", dependencies = TRUE)
# }
# 
# devtools::install_github(
#   "GreenleafLab/ArchR", 
#   ref = "dev", 
#   repos = BiocManager::repositories(),
#   dependencies = TRUE,
#   upgrade = "always" # Ensures dependencies are updated if needed
# )



#devtools::install_github(
#  "GreenleafLab/ArchR", 
#  ref = "dev", 
#  repos = BiocManager::repositories(),
#  dependencies = TRUE,
#)


# devtools::install_github("GreenleafLab/ArchR", ref="master", repos = BiocManager::repositories())
# ArchR::installExtraPackages()




# Configuration & Initialization

# 0 initialation
# 0.1 libraries

library(ArchR)
library(ggplot2)
library(tidyverse)
library(patchwork)

## please config until #########################################


# 0.2 set seeding for random and thread count
set.seed(1)
arch_r_threads = max(1,parallel::detectCores()-2)
# 0.3 directories
# Use current directory as project root (change if needed)
project_dir = getwd()
data_dir = file.path(project_dir,"data")
result_dir = file.path(project_dir,"results")
downloaded_zip_file_path = file.path("scbi_p2.zip")
extracted_zip_path = file.path(data_dir,"scbi_p2")
rna_pbmc_path = file.path("new_pbmc.rds")
pdf_file_path <- file.path(result_dir, "analysis_report.pdf")
################################################################




if (!dir.exists(project_dir)) {
  dir.create(project_dir, recursive = TRUE)
  message("Created project directory: ", project_dir)
}

if (getwd()!=project_dir){
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

if (!file.exists(downloaded_zip_file_path)) {
  stop("The required ZIP file is missing. Please place the file at the following location: ", downloaded_zip_file_path)
} else {
  message("ZIP file already exists: ", downloaded_zip_file_path)
}

if (!dir.exists(extracted_zip_path)) {
  message("Extracting ZIP file to: ", extracted_zip_path)
  unzip(zipfile = downloaded_zip_file_path, exdir = extracted_zip_path)
  message("Extraction complete.")
} else {
  message("ZIP file already extracted: ", extracted_zip_path)
}

# Check if the RNA PBMC file exists; download if it doesn't
if (!file.exists(rna_pbmc_path)) {
  stop("The RNA PBMC file is missing. Please place the file at the following location: ", rna_pbmc_path)
} else {
  message("RNA PBMC file already exists: ", rna_pbmc_path)
}



# Phase 1: Preprocessing and Quality Control
# 1 Preprocessing and quality coontrol

# 1.1 Set up the environment
addArchRThreads(arch_r_threads)
addArchRGenome("hg38")


# 1.2 Read the data into an appropriate data structure and apply filtering
# 1.2.1 input files for data 
input_files_dir = file.path(extracted_zip_path,"scbi_p2")
input_files <- list.files(input_files_dir, pattern = "*.tsv.gz$", full.names = TRUE)
sample_names <- gsub(pattern = ".*_(dc[0-9]+r[0-9]+_r[0-9]+)_.*", replacement = "\\1", basename(input_files))

names(input_files) <-sample_names

# 1.2.2 creating arrow files
ArrowFiles <- createArrowFiles(
  inputFiles = input_files,
  sampleNames = names(input_files),
  minTSS  = 8, 
  minFrags = 1000, 
  addTileMat = TRUE,
  addGeneScoreMat = TRUE,
)

# 1.2.3 redeclaring the arrow files path
ArrowFiles <- list.files(project_dir, pattern = "arrow$", full.names = TRUE)


original_proj <-ArchRProject(
  ArrowFiles = ArrowFiles,  # Provide the list of Arrow file paths here
  outputDirectory = "ArchRProject"  # Define the output directory for results
)

# 1.3 identify doublets

original_proj <- addDoubletScores(
  input = original_proj,
  k = 10, 
  knnMethod = "UMAP", 
