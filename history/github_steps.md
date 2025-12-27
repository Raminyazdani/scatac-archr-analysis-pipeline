# Git History Reconstruction: Single-Cell ATAC-seq Analysis Pipeline

## History Expansion Note

**Previous Run:** N_old = 6 steps
**Target:** N_target = ceil(6 × 1.5) = 9 steps
**Achieved:** 9 steps
**Multiplier:** 1.5× (exactly as required)

### Mapping from Old Steps to New Step Ranges

This expansion used two strategies to increase step count while maintaining realism:

**Strategy A - Split Large Steps:**
- Old step_02 (Dependencies + Script Setup) → **New steps 02-03**
  - step_02: Library loading only (46 lines)
  - step_03: Complete configuration setup (71 lines)
- Old step_04 (Dimensionality Reduction + Clustering) → **New steps 05-06**
  - step_05: LSI and initial UMAP (348 lines)
  - step_06: Harmony batch correction and clustering (435 lines)

**Strategy B - Oops → Hotfix Sequence:**
- Old step_05 (Peak Analysis) → **New steps 07-08** (OOPS + FIX inserted)
  - step_07: Peak calling attempted WITHOUT finding MACS2 path (563 lines) ❌
  - step_08: Hotfix - uncommented pathToMacs2 line, peak calling works (653 lines) ✅

**No Split:**
- Old step_01 → New step_01 (Initial setup - unchanged)
- Old step_03 → New step_04 (Preprocessing - unchanged)
- Old step_06 → New step_09 (Final state - unchanged)

### Oops → Hotfix Details

**What broke (step_07):**
In the peak calling section, the critical line `pathToMacs2 <- findMacs2()` was accidentally commented out, causing the `addReproduciblePeakSet()` function to fail with "pathToMacs2 not found" error.

**How I noticed:**
When running the peak calling step, R threw an error: `Error: object 'pathToMacs2' not found`. This immediately pointed to line 446 where the undefined variable was used.

**What fixed it (step_08):**
Uncommented the line `pathToMacs2 <- findMacs2()` (line 444) to properly locate the MACS2 installation before passing it to `addReproduciblePeakSet()`. Peak calling then proceeded successfully.

This is a realistic mistake that could happen during code development when commenting out sections for testing and forgetting to uncomment them before the next run.

---

## Overview

This document describes a realistic development history for the scATAC-seq analysis pipeline, reconstructing how this project would have been built incrementally by a bioinformatics researcher.

## Development Timeline

The project evolved through 9 major steps, from initial repository setup to a complete, portfolio-ready analysis pipeline.

---

## Step 01: Initial Repository Setup

**Commit Message:** `Initial commit: Set up R project structure`

**Date:** Week 1, Day 1

**Description:**
Created the foundational repository structure for an R-based bioinformatics project. Set up basic environment management with renv and created initial documentation.

**Files Added:**
- `.gitignore` - R project ignore rules
- `README.md` - Initial project description
- `renv.lock` - Empty/minimal R environment lockfile

**Developer Notes:**
> "Starting a new scATAC-seq analysis project. Setting up the basic R project structure with renv for reproducibility. Will use ArchR framework for the analysis."

---

## Step 02: Add Core Libraries

**Commit Message:** `Load core libraries: ArchR, ggplot2, tidyverse`

**Date:** Week 1, Day 3

**Description:**
Added library loading section to the script. This minimal first script just loads the essential packages needed for scATAC-seq analysis.

**Files Modified:**
- `renv.lock` - Updated with ArchR and dependencies
- `README.md` - Added installation instructions

**Files Added:**
- `analysis_pipeline.R` - Initial script with library loading only (46 lines)

**Key Changes:**
- Added ArchR (v1.0.3) from GitHub
- Added Bioconductor packages
- Added tidyverse, ggplot2, patchwork for visualization
- Installed all dependencies via renv

**Developer Notes:**
> "Got all packages installed. Just loading libraries for now. Will add configuration and setup logic next."

---

## Step 03: Configuration and Directory Setup

**Commit Message:** `Add configuration section: directories, seeding, and file paths`

**Date:** Week 1, Day 4

**Description:**
Extended the script with complete configuration and initialization section. Set up project directories, random seeding for reproducibility, and defined all input/output file paths.

**Files Modified:**
- `analysis_pipeline.R` - Extended to 71 lines with complete configuration section

**Key Features Added:**
- Project-relative directory setup (data/, results/)
- Random seed configuration for reproducibility
- Thread count auto-detection
- Input file path definitions (fragment files, RNA reference)
- Directory existence checks and creation
- File validation

**Developer Notes:**
> "Configuration section complete. Using portable `getwd()` and `file.path()` for cross-platform compatibility. All paths are now relative to project root."

---

## Step 04: Implement Preprocessing and QC Pipeline

**Commit Message:** `Implement Phase 1: Preprocessing and quality control`

**Date:** Week 2, Day 2

**Description:**
Developed the complete preprocessing pipeline including Arrow file creation, doublet detection, and quality control visualizations.

**Files Modified:**
- `analysis_pipeline.R` - Added lines 72-277 (Phase 1 complete)
- `README.md` - Updated with QC information

**Key Features Added:**
- ArchR environment setup (genome, threads)
- Arrow file creation from fragment files
- TSS enrichment and fragment count filtering
- Doublet identification and removal
- Quality control plots:
  - Fragment size distributions
  - TSS enrichment scores
  - Fragment vs TSS scatter plots

**Developer Notes:**
> "Completed preprocessing pipeline. Arrow files are created efficiently. Doublet removal working well. QC plots look good - TSS enrichment >8 and fragment count >1000 are reasonable thresholds."

---

## Step 05: Add Dimensionality Reduction (LSI + UMAP)

**Commit Message:** `Implement LSI dimensionality reduction and initial UMAP`

**Date:** Week 2, Day 5

**Description:**
Implemented Iterative LSI for dimensionality reduction and initial UMAP embedding (pre-batch correction) to visualize cell distribution.

**Files Modified:**
- `analysis_pipeline.R` - Extended to 348 lines (Phase 2 partial)

**Key Features Added:**
- Iterative LSI with 4 iterations
- TileMatrix-based dimensionality reduction
- Multi-resolution clustering (0.2, 0.5, 0.8)
- UMAP embedding on LSI dimensions
- Visualization of samples, TSS enrichment, fragment counts

**Developer Notes:**
> "LSI and initial UMAP working. Can see clear batch effects between samples - will need Harmony correction next."

---

## Step 06: Add Batch Correction and Clustering

**Commit Message:** `Implement Harmony batch correction and Seurat clustering`

**Date:** Week 2, Day 7

**Description:**
Added Harmony batch effect correction and Seurat-based clustering to identify cell populations.

**Files Modified:**
- `analysis_pipeline.R` - Extended to 435 lines (Phases 2-3 complete)
- `README.md` - Added dimensionality reduction documentation

**Key Features Added:**
- Harmony batch effect correction
- Post-batch-correction UMAP
- Seurat-based clustering
- Cluster visualization and comparison
- Sample composition analysis per cluster

**Developer Notes:**
> "Harmony effectively corrects batch effects across samples. Clusters are well-separated and biologically meaningful. Can proceed with peak calling."

---

## Step 07: Attempt Peak Calling (OOPS - Missing MACS2 Path)

**Commit Message:** `Add peak calling - WIP (ERROR: pathToMacs2 not defined)`

**Date:** Week 3, Day 3 (Morning)

**Description:**
Attempted to add peak calling functionality but accidentally left the `findMacs2()` call commented out, causing the script to fail when trying to call `addReproduciblePeakSet()`.

**Files Modified:**
- `analysis_pipeline.R` - Extended to 563 lines but with bug

**Key Features Added (BUT BROKEN):**
- Group coverage calculation
- Reproducible peak set calling (FAILS)
- Peak matrix creation

**Bug Introduced:**
```r
# OOPS: Forgot to call findMacs2() - pathToMacs2 is undefined!
# pathToMacs2 <- findMacs2()

proj <- addReproduciblePeakSet(
  ArchRProj = proj,
  groupBy = "Clusters",
  pathToMacs2 = pathToMacs2  # ERROR: object 'pathToMacs2' not found
)
```

**Developer Notes:**
> "Added peak calling code but getting an error: 'Error: object pathToMacs2 not found'. Need to debug this."

---

## Step 08: Hotfix - Uncomment MACS2 Path Discovery

**Commit Message:** `Fix peak calling: uncomment pathToMacs2 <- findMacs2() line`

**Date:** Week 3, Day 3 (Afternoon)

**Description:**
Fixed the peak calling error by uncommenting the `pathToMacs2 <- findMacs2()` line. Peak calling now works correctly.

**Files Modified:**
- `analysis_pipeline.R` - Fixed to 653 lines (Phases 3-4 extended, working)

**Bug Fixed:**
```r
# Fixed: properly find MACS2 installation
pathToMacs2 <- findMacs2()

proj <- addReproduciblePeakSet(
  ArchRProj = proj,
  groupBy = "Clusters",
  pathToMacs2 = pathToMacs2  # Now works!
)
```

**Key Features Now Working:**
- MACS2 peak calling per cluster
- Marker peak identification
- Peak heatmap visualization
- Gene score matrix computation
- MAGIC imputation for visualization
- TF motif enrichment analysis (chromVAR)
- Browser track generation for key genes

**Developer Notes:**
> "Doh! I had commented out the findMacs2() line during testing and forgot to uncomment it. Fixed now. Peak calling produces reproducible peaks across clusters. Gene activity scores correlate well with expected markers."

---

## Step 09: Complete Integration, Differential Analysis, and Documentation

**Commit Message:** `Finalize pipeline: Add integration, differential analysis, and polish documentation`

**Date:** Week 4, Day 2

**Description:**
Completed the pipeline with scRNA-seq integration, differential accessibility analysis, TF footprinting, and co-accessibility analysis. Finalized all documentation for portfolio presentation.

**Files Modified:**
- `analysis_pipeline.R` - Extended to 979 lines (complete pipeline)
- `README.md` - Complete overhaul to portfolio-grade documentation
- `renv.lock` - Final dependency lockfile

**Files Added:**
- `project_identity.md` - Professional project identity document
- `report.md` - Development and transformation report
- `suggestion.txt` - Issue tracking ledger
- `suggestions_done.txt` - Applied changes ledger

**Key Features Added:**
- Integration with scRNA-seq data
- Peak-to-gene linkage analysis
- Differential accessibility between clusters
- TF footprinting with Tn5 bias correction
- Co-accessibility network analysis
- Comprehensive documentation

**Documentation Improvements:**
- Professional README with badges, detailed sections
- Complete usage instructions
- Data requirements and placement
- Output structure documentation
- Configuration options
- Troubleshooting guide
- Citation guidelines

**Developer Notes:**
> "Pipeline is complete and fully functional. Integration with scRNA-seq provides valuable validation. Differential analysis reveals cluster-specific regulatory elements. Documentation is now portfolio-ready with comprehensive instructions and troubleshooting guides."

---

## Development Summary

**Total Development Time:** ~4 weeks

**Final Statistics:**
- **Lines of Code:** 979 lines in main analysis script
- **Dependencies:** 200+ R packages via Bioconductor and CRAN
- **Analysis Phases:** 4 major phases (11 sub-analyses)
- **Output Files:** 20+ visualization types
- **Documentation:** 400+ lines of comprehensive README

**Key Technologies Used:**
- R 4.4.2
- ArchR 1.0.3
- Bioconductor 3.20
- Harmony (batch correction)
- MACS2 (peak calling)
- chromVAR (motif analysis)

**Development Approach:**
- Incremental feature addition
- Test each phase with sample data before proceeding
- Regular documentation updates
- Version control via renv for reproducibility
- Portfolio transformation with professional naming and documentation

**Challenges Encountered:**
1. **Batch effects:** Initial UMAP showed strong batch effects between samples → solved with Harmony
2. **Peak calling bug:** Forgot to uncomment pathToMacs2 line → quick hotfix (step 07→08)
3. **Documentation:** Evolved from minimal README to comprehensive portfolio-grade docs

---

## Snapshot Notes

Each step directory (`step_01` through `step_09`) contains a complete snapshot of the repository at that point in development. These snapshots represent the working tree state and exclude:
- `.git/` directory (version control metadata)
- `history/` directory (to avoid recursion)
- Generated data and results (ignored via `.gitignore`)

The snapshots can be used to:
1. Understand the incremental development process
2. Review code at different stages
3. Restore the project to any historical state
4. Study the evolution of the analysis pipeline

---

## Reproducibility Note

The final state (step_09) matches the current repository exactly (excluding the `history/` folder itself). All development was done with:
- Fixed random seeds (`set.seed(1)`)
- Locked package versions (`renv.lock`)
- Portable path handling (`getwd()`, `file.path()`)

This ensures that anyone can reproduce the analysis from any snapshot point.
