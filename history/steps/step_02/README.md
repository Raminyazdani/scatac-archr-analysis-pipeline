# scATAC-seq Analysis Pipeline

A bioinformatics pipeline for analyzing single-cell ATAC-seq data using the ArchR framework.

## Overview

This repository contains code for analyzing single-cell ATAC-seq (Assay for Transposase-Accessible Chromatin using sequencing) data. The pipeline implements quality control, dimensionality reduction, clustering, peak calling, and downstream analyses to understand chromatin accessibility patterns at single-cell resolution.

## Tech Stack

- R (4.x+)
- ArchR - Single-cell ATAC-seq analysis framework
- ggplot2 - Visualization
- tidyverse - Data manipulation

## Repository Structure

```
scatac-archr-analysis-pipeline/
├── README.md
├── .gitignore
└── renv.lock          # Locked R package versions
```

## Setup

### Using renv (Recommended)

This project uses `renv` for reproducible R environment management:

```r
# Install renv
install.packages("renv")

# Restore environment
renv::restore()
```

### Manual Installation

```r
install.packages(c("ggplot2", "tidyverse", "patchwork", "devtools"))

# Install BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install ArchR
devtools::install_github("GreenleafLab/ArchR", ref="master", 
                         repos = BiocManager::repositories())
```

## Usage

Analysis scripts will be added soon.

## License

This project is available for research and educational purposes.
