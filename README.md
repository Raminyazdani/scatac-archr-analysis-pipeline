# Single Cell Bioinformatics Project 2

**Project Type:** University Project  
**Primary Stack:** R

## Description

This is a Single Cell Bioinformatics project (Project 2) focusing on single-cell ATAC-seq analysis using ArchR. The project analyzes chromatin accessibility data to understand gene regulation and cellular heterogeneity.

## Tech Stack

- R (version 4.x recommended)
- ArchR (for ATAC-seq analysis)
- ggplot2
- tidyverse
- patchwork
- renv (for environment management)

## Folder Structure

```
SCB2/
├── prJ.R           # Main project script
├── renv.lock       # R environment lock file
├── data/           # Data directory (created by script)
├── results/        # Results directory (created by script)
└── README.md       # This file
```

## Setup / Installation

### Using renv (Recommended)
This project uses `renv` for reproducible R environment management:

1. Install renv if not already installed:
```r
install.packages("renv")
```

2. Navigate to the project directory and restore the environment:
```r
setwd("SCB2")
renv::restore()
```

### Manual Installation
If you prefer manual installation:
```r
# Install required packages
install.packages(c("ggplot2", "tidyverse", "patchwork"))

# Install BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install ArchR
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")
devtools::install_github("GreenleafLab/ArchR", ref="master", repos = BiocManager::repositories())

# Install extra ArchR packages
ArchR::installExtraPackages()
```

## How to Run

1. Navigate to the project directory and open R:
```bash
cd SCB2
R
```

2. Source the main script:
```r
source("prJ.R")
```

The script will:
- Create `data/` and `results/` directories if they don't exist
- Set the working directory to the project root
- Download required data (if configured)
- Run the ATAC-seq analysis pipeline

Alternatively, run from command line:
```bash
cd SCB2
Rscript prJ.R
```

## Inputs/Outputs

**Inputs:**
- Single-cell ATAC-seq data (scbi_p2.zip)
- RNA PBMC data (new_pbmc.rds)
- Arrow files (generated during preprocessing)

**Outputs:**
- `results/` - Analysis results and visualizations
- `results/analysis_report.pdf` - Comprehensive analysis report
- `data/` - Processed data files
- Browser track PDFs for gene visualization

## Notes

- The script now uses `getwd()` to determine the project directory (changed from absolute path)
- All paths are relative to the project directory
- The script automatically creates required directories
- Uses multi-threading (configurable via `arch_r_threads`)
- Environment is managed via renv.lock for reproducibility
- Random seed is set to 1 for reproducibility

## Troubleshooting

- If renv::restore() fails, try manual ArchR installation as shown above
- ArchR requires substantial memory; ensure at least 16GB RAM for large datasets
- For installation issues: `ArchR::installExtraPackages()`
- If the script fails to find data, verify data files are in the correct location
- For genome annotation issues, ArchR will download required references automatically
- Adjust `arch_r_threads` if you experience performance issues
