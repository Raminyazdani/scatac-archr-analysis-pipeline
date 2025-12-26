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
  LSIMethod = 1
)


filteredProj <- filterDoublets(original_proj)
proj <- filteredProj

# 1.4 collect all samples into a joint data structure
num_cells <- nCells(proj)
median_TSS <- median(proj$TSSEnrichment)
median_fragments <- median(proj$nFrags)
TileMatrix_obj <-getMatrixFromProject(
  ArchRProj = proj,
  useMatrix = "TileMatrix",
  binarize = TRUE
)
# 1.4.1
num_cells
# 1.4.2
median_TSS
# 1.4.3
# since we didnt call peaks yet this is tilematrix dimension
peak_dimensions <- dim(TileMatrix_obj)

# 1.5 quality control

cell_metadata <- getCellColData(proj)
cell_counts <- table(cell_metadata$Sample)

fragment_length_plot <- plotFragmentSizes(proj)

TSSE_plot_dist <- plotTSSEnrichment(ArchRProj = proj, groupBy = "Sample")
TSSE_plot_violin <- plotGroups(
  ArchRProj = proj, 
  groupBy = "Sample", 
  colorBy = "cellColData", 
  name = "TSSEnrichment",
  plotAs = "violin",
  alpha = 0.4,
  addBoxPlot = TRUE
)
TSSE_plot_ridge <- plotGroups(
  ArchRProj = proj, 
  groupBy = "Sample", 
  colorBy = "cellColData", 
  name = "TSSEnrichment",
  plotAs = "ridges"
)


create_fragments_tss_plot <- function(proj, sample_name) {
  # Extract metadata for the specific sample
  metadata <- getCellColData(proj) %>% 
    as.data.frame() %>%
    filter(Sample == sample_name)
  
  # Create plot
  p <- ggplot(metadata, aes(x = nFrags, y = TSSEnrichment)) +
    geom_point(alpha = 0.6, color = "blue") +
    theme_minimal() +
    labs(
      title = paste("Fragments vs TSS Enrichment -", sample_name),
      x = "Number of Fragments",
      y = "TSS Enrichment"
    ) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      axis.title = element_text(face = "bold")
    ) +
    geom_smooth(method = "loess", color = "red", se = TRUE)
  
  # Save plot
  ggsave(
    filename = paste0("./QualityControl/",sample_name, "/fragments_tss_plot.pdf"), 
    plot = p, 
    width = 8, 
    height = 6
  )
  
  return(p)
}
plot_DC1R3 <- create_fragments_tss_plot(proj, "dc1r3_r1")
plot_DC2R2_R1 <- create_fragments_tss_plot(proj, "dc2r2_r1")
plot_DC2R2_R2 <- create_fragments_tss_plot(proj, "dc2r2_r2")



# 1.5.1
cell_counts
# 1.5.2
fragment_length_plot
# 1.5.3
TSSE_plot_dist
TSSE_plot_violin
TSSE_plot_ridge
# 1.5.4
plot_DC1R3
plot_DC2R2_R1
plot_DC2R2_R2

# Save fragment_length_plot
ggsave("fragment_length_plot.png", plot = fragment_length_plot, width = 6, height = 4)

# Save TSSE_plot_dist
ggsave("TSSE_plot_dist.png", plot = TSSE_plot_dist, width = 6, height = 4)

# Save TSSE_plot_violin
ggsave("TSSE_plot_violin.png", plot = TSSE_plot_violin, width = 6, height = 4)

# Save TSSE_plot_ridge
ggsave("TSSE_plot_ridge.png", plot = TSSE_plot_ridge, width = 6, height = 4)

# Save plot_DC1R3
ggsave("plot_DC1R3.png", plot = plot_DC1R3, width = 6, height = 4)

# Save plot_DC2R2_R1
ggsave("plot_DC2R2_R1.png", plot = plot_DC2R2_R1, width = 6, height = 4)

# Save plot_DC2R2_R2
ggsave("plot_DC2R2_R2.png", plot = plot_DC2R2_R2, width = 6, height = 4)



# 1.6 Filter the dataset

# no need since the plots are ok


# Phase 2: Dimensionality Reduction
# 2 Dimensionality Reduction

# 2.1 Iterative LSI
proj <- addIterativeLSI(
  ArchRProj = proj,               # filtered ArchR project
  useMatrix = "TileMatrix",       # Use TileMatrix for dimensionality reduction
  name = "IterativeLSI",          # Name of the LSI analysis
  iterations = 4,                 # Number of LSI iterations
  clusterParams = list(           # Clustering parameters
    resolution = c(0.2,0.5,0.8),        # Resolution for clustering
    sampleCells = 10000,        # Number of cells to sample for clustering
    n.start = 10                # Number of random starts for clustering
  ), 
  varFeatures = 25000,            # Number of variable features to use
  dimsToUse = 1:30,                # Number of dimensions to use in downstream analysis
  force = T
)

# 2.2 UMAP with sample annotation and QC metrics
proj <- addUMAP(
  ArchRProj = proj,              #  ArchR project with filtered cells
  reducedDims = "IterativeLSI",   # Use reduced dimensions from Iterative LSI
  name = "UMAP",                  # Name the UMAP embedding
  nNeighbors = 30,                # Number of nearest neighbors
  minDist = 0.5,                  # Minimum distance between points
  metric = "cosine",               # Metric for UMAP distance calculations
  force = T
)

# Plot UMAP Colored by Sample Annotation
plot_sample <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "Sample",                # Color by Sample
  embedding = "UMAP"
)

# Plot UMAP Colored by TSS Enrichment
plot_tss <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "TSSEnrichment",         # Color by TSS Enrichment
  embedding = "UMAP"
)

# Plot UMAP Colored by Number of Fragments
plot_fragments <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "nFrags",                # Color by Number of Fragments
  embedding = "UMAP"
)

plot_sample      

plot_tss              

plot_fragments

# Save plot_DC1R3
ggsave("pre_batch_effect_umap_sample.png", plot = plot_sample, width = 6, height = 4)

# Save plot_DC2R2_R1
ggsave("pre_batch_effect_umap_tss.png", plot = plot_tss, width = 6, height = 4)

# Save plot_DC2R2_R2
ggsave("pre_batch_effect_umap_fragments.png", plot = plot_fragments, width = 6, height = 4)


# 2.3 Dealing with batch effects

proj <- addHarmony(
  ArchRProj = proj,
  reducedDims = "IterativeLSI",  # Use pre-corrected dimensions as input
  name = "Harmony",     # Name of the Harmony batch correction result
  groupBy = "Sample",   # Group cells by Sample for correction
  force = TRUE
)

proj <- addUMAP(
  ArchRProj = proj,
  reducedDims = "Harmony",  # Use Harmony-corrected dimensions
  name = "UMAP_Harmony",    # Name for the new UMAP embedding
  nNeighbors = 30,          # Number of neighbors (adjust if needed)
  minDist = 0.5,            # Minimum distance (adjust if needed)
  metric = "cosine",        # Metric for UMAP (default is cosine)
  force = TRUE              # Force overwriting if already present
)

plot_sample_harmony_umap <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "Sample",                # Color by Sample
  embedding = "UMAP_Harmony"
)

plot_TSS_harmony_umap <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "TSSEnrichment",                # Color by TSSEnrichment
  embedding = "UMAP_Harmony"
)

plot_frags_harmony_umap <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "nFrags",                # Color by nFrags
  embedding = "UMAP_Harmony"
)

# Save plot_DC1R3
ggsave("post_batch_effect_umap_sample.png", plot = plot_sample_harmony_umap, width = 6, height = 4)

# Save plot_DC2R2_R1
ggsave("post_batch_effect_umap_tss.png", plot = plot_TSS_harmony_umap, width = 6, height = 4)

# Save plot_DC2R2_R2
ggsave("post_batch_effect_umap_fragments.png", plot = plot_frags_harmony_umap, width = 6, height = 4)



# 3 Clustering
proj <- addClusters(
  input = proj,
  reducedDims = "Harmony", 
  method = "Seurat",
  name = "Clusters",
  force = TRUE
)


cluster_plot <- plotEmbedding(
  ArchRProj = proj, 
  colorBy = "cellColData", 
  name = "Clusters", 
  embedding = "UMAP_Harmony"
)

cluster_plot

ggsave("cluster_plot_umap.png", plot = cluster_plot, width = 6, height = 4)


cluster_cell_counts <- table(proj$Clusters)
print(cluster_cell_counts)

cluster_sample_proportions <- table(proj$Clusters, proj$Sample)
print(cluster_sample_proportions)

cluster_sample_percentages <- prop.table(cluster_sample_proportions, margin = 1) * 100



# Print the result
print(cluster_sample_percentages)

