# Single-Cell ATAC-seq Analysis with ArchR

> A bioinformatics pipeline for analyzing single-cell ATAC-seq data

## Project Overview

This project implements a comprehensive analysis workflow for single-cell ATAC-seq (Assay for Transposase-Accessible Chromatin with sequencing) data using the ArchR framework.

## Features

- Quality control and preprocessing
- Dimensionality reduction and clustering  
- Peak calling and marker identification
- Transcription factor motif analysis
- Integration with scRNA-seq data

## Tech Stack

- **R** (v4.4.2) - Primary programming environment
- **ArchR** (v1.0.3) - scATAC-seq analysis framework
- **Bioconductor** (v3.20) - Genomic data analysis packages
- **tidyverse** - Data manipulation
- **ggplot2** & **patchwork** - Visualization

## Setup

### Installation

```r
# Install renv for environment management
install.packages("renv")

# Restore the environment (installs all dependencies)
renv::restore()
```

### Manual ArchR Installation

```r
# If needed, install ArchR manually
devtools::install_github("GreenleafLab/ArchR", ref="master", 
                         repos = BiocManager::repositories())
ArchR::installExtraPackages()
```

## Usage

```r
# Source the analysis pipeline
source("analysis_pipeline.R")
```

## Repository Structure

```
scatac-archr-analysis-pipeline/
├── README.md              # This file
├── .gitignore             # Git ignore rules
├── analysis_pipeline.R    # Main analysis script
├── renv.lock              # R environment lock file
├── data/                  # Input data (not tracked)
└── results/               # Analysis outputs (not tracked)
```

## Data Requirements

Place your input files in the project root:
- `scbi_p2.zip` - scATAC-seq fragment files
- `new_pbmc.rds` - scRNA-seq reference (optional)

## Status

🚀 **Active Development** - Configuration and setup complete

## License

TBD
