# Single-Cell ATAC-seq Analysis Pipeline with ArchR

[![R](https://img.shields.io/badge/R-4.x-blue.svg)](https://www.r-project.org/)
[![ArchR](https://img.shields.io/badge/ArchR-1.0.3-green.svg)](https://www.archrproject.com/)
[![Bioconductor](https://img.shields.io/badge/Bioconductor-3.20-orange.svg)](https://bioconductor.org/)

> Comprehensive chromatin accessibility analysis workflow for single-cell ATAC-seq data

## Overview

This pipeline implements a complete analysis workflow for single-cell ATAC-seq (Assay for Transposase-Accessible Chromatin with sequencing) data using the ArchR framework. It enables researchers to analyze chromatin accessibility patterns, identify cell types, discover regulatory elements, and understand gene regulation at single-cell resolution.

### What It Does

Transforms raw scATAC-seq fragment files into biological insights through:
- Quality control and preprocessing with doublet removal
- Dimensionality reduction and batch effect correction
- Cell clustering and type identification
- Peak calling and marker discovery
- Transcription factor motif enrichment analysis
- Integration with scRNA-seq gene expression data
- Differential accessibility analysis
- Transcription factor footprinting
- Peak-to-gene regulatory linkage mapping

### Key Features

- **Robust QC Pipeline:** Automated quality filtering based on TSS enrichment and fragment counts
- **Batch Effect Correction:** Harmony integration for multi-sample datasets
- **Comprehensive Analysis:** End-to-end workflow from raw data to biological interpretation
- **Integration Ready:** Seamless integration with scRNA-seq data for multi-modal analysis
- **Reproducible:** Environment management with renv, fixed random seeds
- **Scalable:** Multi-threaded processing for large datasets

## Tech Stack

- **R** (v4.x) - Primary programming environment
- **ArchR** (v1.0.3) - scATAC-seq analysis framework
- **Bioconductor** (v3.20) - Genomic data analysis packages
- **Key Packages:**
  - `ggplot2` - Data visualization
  - `tidyverse` - Data manipulation
  - `patchwork` - Plot composition
  - `Seurat` - Integration with scRNA-seq
  - `chromVAR` - TF motif analysis

## Repository Structure

```
scatac-archr-analysis-pipeline/
├── analysis_pipeline.R   # Main analysis script
├── renv.lock             # R environment lock file (dependencies)
├── README.md             # This file
├── .gitignore            # Git ignore rules
├── data/                 # Input data (created by script, not tracked)
├── results/              # Output files (created by script, not tracked)
└── ArchRProject/         # ArchR project directory (created by script)
```

## Prerequisites

### System Requirements
- **RAM:** Minimum 16GB (32GB+ recommended for large datasets)
- **R Version:** 4.0 or higher
- **Operating System:** Linux, macOS, or Windows with WSL

### Required Software
- R (version 4.x)
- MACS2 (for peak calling) - will be detected automatically by ArchR

## Installation

### Option 1: Using renv (Recommended)

This project uses `renv` for reproducible R environment management.

```r
# 1. Clone the repository
git clone https://github.com/Raminyazdani/scatac-archr-analysis-pipeline.git
cd scatac-archr-analysis-pipeline

# 2. Open R and restore the environment
R
renv::restore()
```

The `renv::restore()` command will automatically install all required packages with the exact versions specified in `renv.lock`.

### Option 2: Manual Installation

If you prefer manual package installation:

```r
# Install CRAN packages
install.packages(c("ggplot2", "tidyverse", "patchwork", "devtools"))

# Install BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install ArchR from GitHub
devtools::install_github("GreenleafLab/ArchR", 
                         ref="master", 
                         repos = BiocManager::repositories())

# Install ArchR extra packages
ArchR::installExtraPackages()
```

## Usage

### Quick Start

```r
# 1. Navigate to project directory
setwd("/path/to/scatac-archr-analysis-pipeline")

# 2. Source the main pipeline script
source("analysis_pipeline.R")
```

Or run from command line:

```bash
cd /path/to/scatac-archr-analysis-pipeline
Rscript analysis_pipeline.R
```

### Configuration

Before running, configure these variables in `analysis_pipeline.R` (lines 49-63):

```r
# Random seed for reproducibility
set.seed(1)

# Number of CPU threads to use
arch_r_threads = max(1, parallel::detectCores()-2)

# Data file paths - update these to point to your data
downloaded_zip_file_path = file.path("scbi_p2.zip")
rna_pbmc_path = file.path("new_pbmc.rds")
```

**Note:** The pipeline uses `getwd()` to determine the project root, so ensure you run it from the project directory.

## Data Requirements

### Input Data

1. **scATAC-seq Fragment Files** 
   - Format: TSV.GZ (tab-separated gzipped text)
   - Content: Chromosome, start, end, cell barcode, read count
   - Location: Compressed in `scbi_p2.zip`
   - The script will extract to `data/scbi_p2/`

2. **scRNA-seq Reference Data** (for integration, optional)
   - Format: RDS file containing Seurat object
   - Must contain cluster annotations
   - Location: `new_pbmc.rds` in project root
   - Required field: `Cluster.Name` in metadata

3. **Genome Annotation**
   - Genome: hg38 (human reference)
   - Downloaded automatically by ArchR on first run

### Data Placement

Place your input files in the project root directory:

```
scatac-archr-analysis-pipeline/
├── scbi_p2.zip          # Your scATAC-seq fragment files
├── new_pbmc.rds         # Your scRNA-seq reference (optional)
└── analysis_pipeline.R
```

### Example Data

If you don't have data yet, you can:
- Use public datasets from [10x Genomics](https://www.10xgenomics.com/resources/datasets)
- Download PBMC scATAC-seq data from [ArchR tutorial](https://www.archrproject.com/bookdown/getting-started-with-archr.html)

## Pipeline Stages

The pipeline is organized into logical phases:

### Configuration & Initialization
- Load required libraries
- Set random seed and configure threading
- Create output directories

### Phase 1: Preprocessing & Quality Control
- Create Arrow files from fragment files
- Filter cells by TSS enrichment (≥8) and fragment count (≥1000)
- Identify and remove doublets
- Generate QC plots (fragment distributions, TSS enrichment)

### Phase 2: Dimensionality Reduction
- Iterative LSI dimensionality reduction
- UMAP embedding generation
- Harmony batch effect correction
- Cell clustering (Seurat method)

### Phase 3: Peak Analysis
- Group coverage calculation
- Reproducible peak calling (MACS2)
- Peak matrix generation
- Marker peak identification per cluster

### Phase 4: Gene Activity Analysis
- Gene score matrix computation
- Marker gene identification
- MAGIC imputation for visualization
- TF motif enrichment analysis

### Phase 5: Integration & Linkage
- Integration with scRNA-seq data
- Gene expression correlation analysis
- Peak-to-gene linkage mapping

### Phase 6: Differential Analysis
- Differential accessibility between clusters
- TF motif enrichment in differential peaks
- TF footprinting analysis
- Co-accessibility network analysis

## Output Structure

The pipeline generates outputs in organized directories:

```
results/
├── analysis_report.pdf              # Comprehensive results report
├── fragment_length_plot.png         # QC: Fragment size distribution
├── TSSE_plot_*.png                  # QC: TSS enrichment
├── plot_DC*.png                     # QC: Sample-specific QC
├── *_umap_*.png                     # UMAP visualizations
├── cluster_plot_umap.png            # Final clustering
├── heatmap_peaks.pdf                # Marker peak heatmap
├── *_browser_track.pdf              # Gene-specific browser tracks
├── umap_magic_vs_no_magic.pdf       # MAGIC imputation comparison
├── glun5_vs_cyc_*.png               # Differential analysis plots
├── tf_motif_enriched_*.png          # TF motif enrichment
├── peak2gene_heatmap.pdf            # Peak-gene linkages
└── UMAP_*.pdf                       # Various UMAP visualizations

ArchRProject/
├── ArrowFiles/                      # Efficient data storage
├── PeakCalls/                       # Called peaks per cluster
├── Plots/                           # Additional ArchR plots
└── Save-ArchR-Project.rds           # Saved project state
```

## Configuration Options

### Key Parameters

Edit these in `analysis_pipeline.R` to customize the analysis:

```r
# Quality filtering thresholds
minTSS  = 8         # Minimum TSS enrichment
minFrags = 1000     # Minimum fragments per cell

# LSI parameters
iterations = 4      # Number of LSI iterations
varFeatures = 25000 # Number of variable features

# UMAP parameters
nNeighbors = 30     # Number of nearest neighbors
minDist = 0.5       # Minimum distance between points

# Clustering resolution
resolution = c(0.2, 0.5, 0.8)  # Try multiple resolutions
```

## Reproducibility

### Environment Management

This project uses `renv` to ensure reproducibility:
- `renv.lock` contains exact package versions
- `renv::restore()` recreates the environment
- All analyses use fixed random seeds (`set.seed(1)`)

### Version Information

- R version: 4.4.2
- Bioconductor version: 3.20
- ArchR version: 1.0.3
- See `renv.lock` for complete package list

## Troubleshooting

### Common Issues

**Issue: `renv::restore()` fails**
```r
# Solution: Try manual ArchR installation
devtools::install_github("GreenleafLab/ArchR", ref="master", 
                         repos = BiocManager::repositories())
ArchR::installExtraPackages()
```

**Issue: Out of memory errors**
```r
# Solution: Reduce thread count or sample fewer cells
arch_r_threads = 2  # Use fewer threads
sampleCells = 5000  # Reduce sampling in LSI
```

**Issue: MACS2 not found**
```bash
# Install MACS2 via pip
pip install MACS2

# Or via conda
conda install -c bioconda macs2
```

**Issue: Data files not found**
- Verify `scbi_p2.zip` is in the project root directory
- Check that file paths in the configuration section are correct
- Ensure you're running the script from the project directory

**Issue: Genome annotation download fails**
```r
# Solution: Manually install genome
ArchR::installGenome("hg38")
```

**Issue: Plot generation errors**
- Ensure output directories exist (script creates them automatically)
- Check disk space for large plot files
- Verify ggplot2 and patchwork are properly installed

### Getting Help

- [ArchR Documentation](https://www.archrproject.com/bookdown/)
- [ArchR GitHub Issues](https://github.com/GreenleafLab/ArchR/issues)
- [Bioconductor Support](https://support.bioconductor.org/)

## Citation

If you use this pipeline in your research, please cite:

**ArchR Framework:**
```
Granja JM, Corces MR, Pierce SE, et al. ArchR is a scalable software package 
for integrative single-cell chromatin accessibility analysis. Nat Genet. 2021;53(3):403-411.
```

**This Pipeline:**
```
[Your Name]. (2024). Single-Cell ATAC-seq Analysis Pipeline with ArchR. 
GitHub repository: https://github.com/Raminyazdani/scatac-archr-analysis-pipeline
```

## License

[Specify license - e.g., MIT, GPL-3.0, Apache-2.0]

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Acknowledgments

- ArchR development team for the excellent framework
- Bioconductor community for genomic analysis tools
- Contributors and users of this pipeline

## Contact

For questions or feedback, please open an issue on GitHub.

---

**Note:** This is a computational pipeline for research purposes. Ensure you have appropriate permissions and ethical approval for any human genomic data analysis.
