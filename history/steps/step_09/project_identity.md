# Project Identity

**Status:** Finalized

## Professional Naming
- **Display Title:** Single-Cell ATAC-seq Analysis Pipeline with ArchR
- **Repo Slug:** scatac-archr-analysis-pipeline (already professional - no change needed)
- **Tagline:** Comprehensive chromatin accessibility analysis workflow for single-cell ATAC-seq data
- **GitHub Description:** A complete single-cell ATAC-seq analysis pipeline implementing preprocessing, dimensionality reduction, clustering, peak calling, TF motif analysis, and integration with gene expression data using the ArchR framework.

## Technical Details
- **Primary Stack:** R, ArchR, Bioconductor
- **Topics/Keywords:** 
  - single-cell
  - atac-seq
  - chromatin-accessibility
  - bioinformatics
  - genomics
  - epigenomics
  - archr
  - transcription-factors
  - umap
  - r-bioconductor

## Project Overview

### Problem
Analyzing single-cell ATAC-seq (Assay for Transposase-Accessible Chromatin with sequencing) data to understand chromatin accessibility patterns, gene regulation, and cellular heterogeneity at single-cell resolution.

### Approach
A comprehensive multi-step analysis pipeline using the ArchR framework:
1. Preprocessing & quality control (doublet removal, filtering)
2. Dimensionality reduction (Iterative LSI, UMAP) with Harmony batch correction
3. Clustering and cell type identification
4. Peak calling and marker peak identification
5. Gene activity score computation
6. Transcription factor motif enrichment analysis
7. Integration with scRNA-seq gene expression data
8. Peak-to-gene linkage analysis
9. Differential accessibility analysis
10. Transcription factor footprinting
11. Co-accessibility analysis

### Inputs
- **scATAC-seq data:** Fragment files in TSV.GZ format (from scbi_p2.zip)
- **scRNA-seq reference:** Seurat object with PBMC gene expression data (new_pbmc.rds)
- **Genome:** hg38 (human reference genome)

### Outputs
- **Quality control:** Fragment size distributions, TSS enrichment plots, fragment vs TSS scatter plots
- **Dimensionality reduction:** UMAP embeddings colored by sample, TSS enrichment, fragment count, and clusters
- **Clustering:** Cell cluster assignments and visualizations
- **Peak analysis:** Peak matrices, marker peak heatmaps, browser tracks for specific genes
- **Gene activity:** Gene score matrices, MAGIC-imputed gene activity visualizations
- **TF motif analysis:** Motif enrichment plots, motif activity UMAPs, deviation scores
- **Integration:** Integrated gene expression data, correlation analysis
- **Differential analysis:** MA plots, volcano plots, TF motif enrichment for differential peaks
- **Footprinting:** Tn5 bias-corrected TF footprints
- **Co-accessibility:** Peak co-accessibility networks, enhancer-gene linkages
