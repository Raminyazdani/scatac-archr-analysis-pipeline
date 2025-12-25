# Git Development History: scATAC-seq Analysis Pipeline with ArchR

This document describes the realistic development progression of the scATAC-seq analysis pipeline, reconstructed as if developed incrementally by a bioinformatician building out a production-ready analysis workflow.

## Development Timeline

### Step 1: Repository Initialization (step_01)
**Commit Message:** `Initial commit: Project setup with README and gitignore`

**What happened:**
- Created GitHub repository for single-cell ATAC-seq analysis project
- Added initial README with project overview
- Created .gitignore for R/ArchR artifacts
- Added MIT or similar license (if applicable)

**Rationale:**
Every project starts with proper initialization - establishing the repository structure, documenting the purpose, and setting up version control hygiene.

**Files:**
- README.md (basic structure)
- .gitignore
- LICENSE (optional)

---

### Step 2: Environment Configuration (step_02)
**Commit Message:** `Add renv for reproducible R environment management`

**What happened:**
- Initialized renv for package version management
- Generated renv.lock with all package dependencies
- Documented installation instructions in README

**Rationale:**
R package dependencies change frequently. Using renv ensures anyone can reproduce the exact environment with locked package versions. This is critical for bioinformatics reproducibility.

**Files Added:**
- renv.lock
- .Rprofile (renv bootstrap)

**Files Modified:**
- README.md (added Installation section)

---

### Step 3: Configuration and Setup Code (step_03)
**Commit Message:** `Add project configuration and directory initialization`

**What happened:**
- Created prJ.R script with configuration section
- Added code for:
  - Setting random seed (reproducibility)
  - Thread count configuration
  - Directory structure setup (data/, results/)
  - Input file validation

**Rationale:**
Before implementing analysis logic, establish the infrastructure: where files live, how to configure resources, and validation that required inputs exist.

**Files Added:**
- prJ.R (lines 1-107: configuration section)

---

### Step 4: Data Preprocessing and QC (step_04)
**Commit Message:** `Implement preprocessing pipeline and quality control`

**What happened:**
- Added ArchR environment setup (genome, threads)
- Implemented Arrow file creation from fragment files
- Added doublet detection and filtering
- Created QC plotting functions:
  - Fragment size distributions
  - TSS enrichment plots
  - Per-sample QC scatter plots

**Rationale:**
QC is the foundation of any genomics pipeline. Before analyzing data, we must filter low-quality cells and visualize data quality metrics.

**Files Modified:**
- prJ.R (added lines 108-275: preprocessing and QC section)

**Code sections added:**
- Section 1: Preprocessing and Quality Control
  - ArchR setup
  - Arrow file creation with filtering (minTSS=8, minFrags=1000)
  - Doublet scoring and removal
  - QC plot generation

---

### Step 5: Dimensionality Reduction (step_05)
**Commit Message:** `Add dimensionality reduction with LSI and UMAP`

**What happened:**
- Implemented Iterative LSI for dimensionality reduction
- Added UMAP embedding generation
- Created UMAP visualizations colored by:
  - Sample annotation
  - TSS enrichment
  - Fragment count

**Rationale:**
High-dimensional scATAC-seq data (hundreds of thousands of features) must be reduced to interpretable dimensions. LSI is the standard method for ATAC-seq data, followed by UMAP for visualization.

**Files Modified:**
- prJ.R (added lines 276-347: dimensionality reduction section)

**Code sections added:**
- Section 2.1-2.2: Iterative LSI and UMAP

---

### Step 6: Batch Effect Correction (step_06)
**Commit Message:** `Add Harmony batch correction for multi-sample integration`

**What happened:**
- Integrated Harmony for batch effect correction
- Re-computed UMAP on batch-corrected embeddings
- Generated before/after comparison plots

**Rationale:**
Multi-sample experiments have technical batch effects. Harmony corrects these while preserving biological variation, essential for integrating samples from different runs or conditions.

**Files Modified:**
- prJ.R (added lines 348-398: Harmony correction section)

**Code sections added:**
- Section 2.3: Batch effect correction with Harmony

---

### Step 7: Clustering (step_07)
**Commit Message:** `Implement graph-based clustering`

**What happened:**
- Added Seurat-based clustering on Harmony-corrected dimensions
- Visualized clusters on UMAP
- Generated cluster statistics (cell counts, sample proportions)

**Rationale:**
Clustering groups cells with similar chromatin accessibility patterns, often corresponding to cell types or states. This is a key step for downstream differential analysis.

**Files Modified:**
- prJ.R (added lines 399-435: clustering section)

**Code sections added:**
- Section 3: Clustering

---

### Step 8: Peak Calling (step_08)
**Commit Message:** `Add reproducible peak calling with MACS2`

**What happened:**
- Implemented per-cluster peak calling
- Added peak matrix construction
- Identified cluster marker peaks
- Created peak heatmap visualization
- Generated browser tracks for marker genes

**Rationale:**
Peaks represent regulatory elements (promoters, enhancers). Calling peaks per cluster identifies cell-type-specific regulatory regions.

**Files Modified:**
- prJ.R (added lines 436-499: peak calling section)

**Code sections added:**
- Section 4: Peak calling and marker identification

---

### Step 9: Gene Activity Scoring (step_09)
**Commit Message:** `Add gene activity scoring and imputation`

**What happened:**
- Computed gene activity scores from chromatin accessibility
- Identified marker genes per cluster
- Implemented MAGIC imputation for denoising
- Created gene activity UMAP plots (with/without imputation)

**Rationale:**
Gene activity scores estimate expression from chromatin accessibility. MAGIC imputation reduces sparsity. This bridges ATAC-seq to gene-level interpretation.

**Files Modified:**
- prJ.R (added lines 500-571: gene activity section)

**Code sections added:**
- Section 5: Gene Activity (3 subsections)

---

### Step 10: Motif Analysis (step_10)
**Commit Message:** `Implement transcription factor motif enrichment analysis`

**What happened:**
- Added motif annotation (CIS-BP database)
- Computed motif deviations (chromVAR)
- Identified variable motifs across clusters
- Generated motif activity UMAP and violin plots

**Rationale:**
TF motif enrichment identifies which transcription factors are active in different cell populations - crucial for understanding gene regulation.

**Files Modified:**
- prJ.R (added lines 572-653: motif analysis section)

**Code sections added:**
- Section 6: Transcription Factor motif activity (3 subsections)

---

### Step 11: scRNA-seq Integration (step_11)
**Commit Message:** `Add scRNA-seq integration for label transfer`

**What happened:**
- Implemented gene integration matrix from scRNA-seq reference
- Visualized integrated gene expression on UMAP
- Computed correlations between ATAC gene scores and RNA expression
- Transferred cluster labels from scRNA-seq

**Rationale:**
Integrating with annotated scRNA-seq data enables accurate cell type labeling and validates ATAC-based gene activity scores.

**Files Modified:**
- prJ.R (added lines 654-736: integration section)

**Code sections added:**
- Section 7: Integration with gene expression (3 subsections)

---

### Step 12: Peak-to-Gene Linkage (step_12)
**Commit Message:** `Add peak-to-gene linkage analysis`

**What happened:**
- Computed correlations between peak accessibility and gene activity
- Identified significant peak-gene links
- Created peak-to-gene heatmap

**Rationale:**
Linking peaks to genes identifies which regulatory elements control which genes - the core question of epigenomics.

**Files Modified:**
- prJ.R (added lines 737-756: peak-gene linkage section)

**Code sections added:**
- Section 8: Peak-gene linkage

---

### Step 13: Differential Accessibility (step_13)
**Commit Message:** `Implement differential accessibility analysis between clusters`

**What happened:**
- Performed statistical testing for cluster-specific peaks (GluN5 vs Cyc.Prog.)
- Generated MA and volcano plots
- Computed TF motif enrichment in differential peaks (up/down regulated)
- Created TF enrichment scatter plots

**Rationale:**
Identifying differential peaks reveals regulatory elements that define cell type differences. TF enrichment pinpoints the transcriptional regulators driving these differences.

**Files Modified:**
- prJ.R (added lines 757-866: differential accessibility section)

**Code sections added:**
- Section 9: Differential accessibility (2 subsections)

---

### Step 14: TF Footprinting (step_14)
**Commit Message:** `Add transcription factor footprinting analysis`

**What happened:**
- Selected top enriched TFs from differential analysis
- Generated TF footprints showing Tn5 insertion patterns
- Created footprint plots with bias normalization

**Rationale:**
Footprinting validates TF binding by showing the characteristic depletion of Tn5 insertions at TF binding sites (the TF protects DNA from cutting).

**Files Modified:**
- prJ.R (added lines 867-918: footprinting section)

**Code sections added:**
- Section 10: TF footprinting (2 subsections)

---

### Step 15: Co-accessibility Analysis (step_15)
**Commit Message:** `Add co-accessibility and enhancer identification (bonus features)`

**What happened:**
- Computed co-accessibility between peaks
- Identified coordinately regulated regions
- Generated browser tracks with co-accessibility loops
- Combined peak-to-gene links with co-accessibility
- Created tracks showing potential enhancer-gene connections

**Rationale:**
Co-accessible peaks often represent coordinated regulatory elements (e.g., enhancer-promoter pairs). This analysis identifies potential long-range regulatory interactions.

**Files Modified:**
- prJ.R (added lines 919-980: co-accessibility section)

**Code sections added:**
- Section 11: Co-accessibility (bonus, 2 subsections)

---

### Step 16: Documentation Enhancement (step_16)
**Commit Message:** `Enhance README with comprehensive usage documentation`

**What happened:**
- Expanded README with detailed sections:
  - Complete feature list
  - Setup instructions (renv + manual)
  - Data requirements and acquisition guidance
  - Detailed outputs documentation
  - Troubleshooting section
  - Citation information
- Added repository structure diagram

**Rationale:**
A production pipeline needs thorough documentation. Users should understand what the pipeline does, how to set it up, what data it needs, and what outputs to expect.

**Files Modified:**
- README.md (major expansion)

---

### Step 17: Final Polish (step_17 - FINAL STATE)
**Commit Message:** `Final polish: remove academic traces, improve path handling`

**What happened:**
- Removed week-based section headers (remnants from course structure)
- Replaced with professional section headers (numbered + descriptive)
- Fixed hardcoded QualityControl path to use result_dir variable
- Made ArchRProject output directory path consistent
- Updated README title and framing to be portfolio-grade
- Removed "University Project" designation
- Replaced "SCB2" folder references with current repo name

**Rationale:**
Final cleanup to make the codebase portfolio-ready: remove academic scaffolding, ensure all paths are properly parameterized, and polish documentation to professional standard.

**Files Modified:**
- prJ.R (comment headers, path fixes)
- README.md (title, framing, references)

---

## Development Philosophy

This progression follows a natural development workflow for bioinformatics pipeline development:

1. **Foundation First**: Setup, configuration, environment
2. **Core Functionality**: Preprocessing, QC, dimensionality reduction
3. **Biological Insight**: Clustering, peaks, gene activity
4. **Advanced Analysis**: Motifs, integration, linkage
5. **Specialized Methods**: Differential analysis, footprinting
6. **Documentation**: Making it usable by others
7. **Polish**: Production-ready cleanup

Each step builds logically on the previous one, following the natural order of scATAC-seq analysis while progressively adding more sophisticated methods.

## Reproducibility Note

All snapshots represent complete working states of the repository. Each step adds functionality without breaking previous work. The final state (step_17) is the complete, portfolio-ready pipeline.
