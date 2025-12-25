# scATAC-seq Analysis Pipeline with ArchR

A reproducible single-cell ATAC-seq analysis pipeline for chromatin accessibility profiling using ArchR

[![R](https://img.shields.io/badge/R-4.x+-blue.svg)](https://www.r-project.org/)
[![ArchR](https://img.shields.io/badge/ArchR-Bioconductor-green.svg)](https://www.archrproject.com/)

## Overview

This pipeline provides a comprehensive workflow for analyzing single-cell ATAC-seq (Assay for Transposase-Accessible Chromatin using sequencing) data to understand chromatin accessibility and gene regulation at single-cell resolution. Built on the ArchR framework, it implements industry-standard analysis methods for processing raw scATAC-seq fragment files through quality control, dimensionality reduction, clustering, peak calling, motif analysis, and integration with scRNA-seq data.

## What This Pipeline Does

Single-cell ATAC-seq reveals which genomic regions are accessible (open chromatin) in individual cells, providing insights into:
- Cell type identification based on chromatin accessibility patterns
- Transcription factor activity and binding site prediction
- Gene regulatory element discovery (enhancers, promoters)
- Cell state transitions and developmental trajectories
- Integration with gene expression to link chromatin state with transcriptional output

## Features

- **Quality Control**: TSS enrichment, fragment distribution analysis, doublet detection and removal
- **Dimensionality Reduction**: Iterative LSI with batch correction using Harmony
- **Visualization**: UMAP embeddings colored by sample, cluster, QC metrics, gene scores, and motif activity
- **Clustering**: Graph-based clustering with multiple resolution support
- **Peak Calling**: MACS2-based reproducible peak identification per cluster
- **Differential Accessibility**: Statistical testing to identify cluster-specific regulatory regions
- **Motif Analysis**: TF motif enrichment and footprinting analysis using CIS-BP database
- **Gene Activity Scoring**: Chromatin-based gene activity estimation with MAGIC imputation
- **scRNA-seq Integration**: Label transfer and gene expression correlation
- **Peak-to-Gene Links**: Identification of regulatory element-gene associations
- **Co-accessibility**: Discovery of coordinately accessible genomic regions

## Tech Stack

- **R** (version 4.x+)
- **ArchR** - Scalable single-cell ATAC-seq analysis framework
- **ggplot2** - Data visualization
- **tidyverse** - Data manipulation and analysis
- **patchwork** - Combining multiple plots
- **Harmony** - Batch effect correction
- **MACS2** - Peak calling (automatically detected by ArchR)
- **renv** - R environment management for reproducibility

## Repository Structure

```
scatac-archr-analysis-pipeline/
├── prJ.R                 # Main analysis pipeline script
├── renv.lock             # Locked R package versions for reproducibility
├── README.md             # This file
├── data/                 # Created by pipeline: processed data files
├── results/              # Created by pipeline: analysis outputs
│   ├── ArchRProject/     # ArchR project directory
│   ├── qc/               # Quality control plots
│   ├── *.png             # UMAP and other visualizations
│   └── *.pdf             # Reports and browser tracks
└── *.arrow               # ArchR Arrow files (created during analysis)
```

## Setup

### Prerequisites

- R version 4.x or higher
- At least 16GB RAM (32GB recommended for large datasets)
- Sufficient disk space for intermediate Arrow files (~2-3x raw data size)

### Installation

#### Option 1: Using renv (Recommended)

This project uses `renv` for reproducible environment management. All package versions are locked in `renv.lock`.

```r
# Install renv if not already installed
install.packages("renv")

# Navigate to project directory and restore the environment
setwd("/path/to/scatac-archr-analysis-pipeline")
renv::restore()
```

#### Option 2: Manual Installation

If you prefer manual installation or encounter issues with renv:

```r
# Install CRAN packages
install.packages(c("ggplot2", "tidyverse", "patchwork", "devtools"))

# Install BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install ArchR from GitHub
devtools::install_github("GreenleafLab/ArchR", ref="master", 
                         repos = BiocManager::repositories())

# Install additional ArchR dependencies
ArchR::installExtraPackages()
```

## Data Requirements

### Input Files

Place the following files in the project root directory before running:

1. **scATAC-seq Fragment Files** (`scbi_p2.zip`)
   - Compressed archive containing fragment files in `.tsv.gz` format
   - Each file represents one sample with columns: chromosome, start, end, barcode, duplicate_count
   - Expected structure: `scbi_p2/scbi_p2/*.tsv.gz`

2. **scRNA-seq Reference Data** (`new_pbmc.rds`) - *Optional*
   - Seurat object with annotated cell types for label transfer
   - Required only for the integration step (Section 7 of pipeline)
   - If unavailable, comment out integration sections in `prJ.R`

### Data Acquisition

If you don't have the data files:
- Fragment files are typically generated by 10x Genomics Cell Ranger ATAC or similar preprocessing tools
- scRNA-seq reference can be a published dataset (e.g., from GEO, SRA) processed with Seurat
- Contact the data provider or refer to your experimental setup for obtaining these files

## How to Run

### Configuration

Before running, review the configuration section in `prJ.R` (lines 48-63):

```r
# Set random seed for reproducibility
set.seed(1)

# Configure thread count (adjust based on your system)
arch_r_threads = max(1, parallel::detectCores() - 2)

# Paths are automatically set relative to project directory
project_dir = getwd()
data_dir = file.path(project_dir, "data")
result_dir = file.path(project_dir, "results")

# Input file paths (update if your files have different names)
downloaded_zip_file_path = file.path("scbi_p2.zip")
rna_pbmc_path = file.path("new_pbmc.rds")
```

### Execution

#### Option 1: Run from R Console

```bash
cd /path/to/scatac-archr-analysis-pipeline
R
```

```r
source("prJ.R")
```

#### Option 2: Run from Command Line

```bash
cd /path/to/scatac-archr-analysis-pipeline
Rscript prJ.R
```

**Note**: The pipeline may take several hours depending on dataset size and system resources.

### Pipeline Stages

The pipeline runs sequentially through these stages:

1. **Configuration** - Environment setup, directory creation, data validation
2. **Preprocessing & QC** - Arrow file creation, TSS enrichment, doublet filtering (saves QC plots)
3. **Dimensionality Reduction** - LSI, UMAP, Harmony batch correction
4. **Clustering** - Seurat-based graph clustering
5. **Peak Calling** - MACS2 reproducible peak sets per cluster
6. **Gene Activity** - Chromatin-based gene scoring with MAGIC imputation
7. **Motif Analysis** - TF motif deviation and footprinting
8. **scRNA Integration** - Label transfer and correlation (*requires RNA data*)
9. **Peak-Gene Linkage** - Regulatory element mapping
10. **Differential Accessibility** - Cluster-specific accessibility analysis
11. **Co-accessibility** - Identification of linked regulatory regions

## Outputs

### Generated Directories

- `data/` - Extracted and processed data files
- `results/` - All analysis outputs
  - `results/ArchRProject/` - ArchR project files and metadata
  - `results/qc/` - Quality control plots per sample

### Key Output Files

#### Quality Control
- `fragment_length_plot.png` - Fragment size distribution across samples
- `TSSE_plot_*.png` - TSS enrichment distributions (dist, violin, ridge plots)
- `plot_DC*.png` - Fragments vs TSS enrichment scatter plots per sample

#### Dimensionality Reduction & Clustering
- `pre_batch_effect_umap_*.png` - UMAP before batch correction
- `post_batch_effect_umap_*.png` - UMAP after Harmony correction
- `cluster_plot_umap.png` - Final clustered UMAP

#### Peak Analysis
- `heatmap_peaks.pdf` - Marker peaks heatmap across clusters
- `*_browser_track.pdf` - IGV-style genome browser tracks for marker genes (TOP2A, MKI67, AURKA, SATB2, SLC12A7)

#### Gene Activity & Motif Analysis
- `umap_magic_vs_no_magic.pdf` - Comparison of gene scores with/without imputation
- `UMAP_z:*.pdf` - Motif activity projections on UMAP
- `Violin_z:*.pdf` - Motif activity distributions per cluster

#### Differential Accessibility
- `glun5_vs_cyc_MA.png` - MA plot showing differential peaks
- `glun5_vs_cyc_volcan.png` - Volcano plot of differential accessibility
- `tf_motif_enriched_*.png` - TF motif enrichment plots
- `Footprints-Divide-Bias.pdf` - TF footprinting results

#### Integration & Linkage
- `UMAP_GeneExpression_*.pdf` - Integrated gene expression on UMAP
- `UMAP_GeneExpression_Grid_Spaced.pdf` - Combined gene expression grid
- `peak2gene_heatmap.pdf` - Peak-to-gene linkage heatmap
- `Plot-Tracks-*-with-CoAccessibility.pdf` - Browser tracks with co-accessibility loops
- `Plot-Tracks-*-with-Peak2GeneLinks.pdf` - Browser tracks with peak-gene links

### Arrow Files

The pipeline generates `.arrow` files in the project root - these are ArchR's binary format for efficient data storage and should not be deleted during analysis.

## Reproducibility Notes

- **Random Seed**: Set to 1 for reproducible results (line 52 of `prJ.R`)
- **Package Versions**: Locked via `renv.lock` - use `renv::restore()` to ensure exact package versions
- **Threading**: Configured to use `detectCores() - 2` by default; adjust if needed
- **Genome Reference**: Uses hg38 (automatically downloaded by ArchR on first run)
- **Motif Database**: CIS-BP (automatically downloaded by ArchR)

## Troubleshooting

### Installation Issues

**Problem**: `renv::restore()` fails or takes too long

**Solution**: Try manual installation (see Option 2 above), then run:
```r
ArchR::installExtraPackages()
```

**Problem**: ArchR installation fails with compilation errors

**Solution**: Ensure you have build tools installed:
- **macOS**: Install Xcode Command Line Tools: `xcode-select --install`
- **Linux**: Install build essentials: `sudo apt-get install build-essential`
- **Windows**: Install Rtools from CRAN

### Runtime Issues

**Problem**: "ZIP file is missing" error

**Solution**: Ensure `scbi_p2.zip` is in the project root directory. Check the filename matches exactly (case-sensitive).

**Problem**: "RNA PBMC file is missing" error

**Solution**: 
- If you have the file, ensure it's named `new_pbmc.rds` in the project root
- If you don't have RNA data, comment out Section 7 (lines 655-735) in `prJ.R`

**Problem**: Out of memory errors

**Solution**:
- Reduce thread count: `arch_r_threads = 1`
- Close other applications
- Process fewer cells by adjusting filtering thresholds (lines 127-134)
- Use a machine with more RAM (minimum 16GB, 32GB+ recommended)

**Problem**: MACS2 not found

**Solution**: Install MACS2 via conda or pip:
```bash
pip install macs2
# or
conda install -c bioconda macs2
```

**Problem**: Genome/annotation download failures

**Solution**: ArchR automatically downloads required references. If downloads fail:
- Check internet connection
- Try again (ArchR resumes interrupted downloads)
- Manually download and install as described in [ArchR documentation](https://www.archrproject.com/bookdown/index.html)

### Output Issues

**Problem**: Some plots are empty or fail to generate

**Solution**:
- Check console output for specific errors
- Ensure Arrow files were created successfully (check for `.arrow` files in project root)
- Verify sufficient cells passed QC filters (check `nCells(proj)` output)

**Problem**: QualityControl folder not found errors

**Solution**: The pipeline now creates required directories automatically. If you still see errors, check file permissions in the project directory.

## Citation

If you use this pipeline in your research, please cite:

**ArchR**:
Granja JM, Corces MR, et al. (2021) ArchR is a scalable software package for integrative single-cell chromatin accessibility analysis. *Nature Genetics* 53, 403–411. https://doi.org/10.1038/s41588-021-00790-6

## License

This pipeline is provided as-is for research and educational purposes. ArchR and its dependencies are subject to their respective licenses.

## Contact

For questions about this pipeline implementation, please open an issue in the GitHub repository.

For questions about ArchR itself, refer to the [official documentation](https://www.archrproject.com/) and [GitHub repository](https://github.com/GreenleafLab/ArchR).

