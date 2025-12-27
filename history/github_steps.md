# Git History Reconstruction: Single-Cell ATAC-seq Analysis Pipeline

## History Expansion Note

**Second Previous Run:** N_old1 = 6 steps
**Previous Run:** N_old2 = 9 steps  
**Target:** N_target = ceil(9 × 1.5) = 14 steps
**Achieved:** 14 steps
**Multiplier:** 1.56× (exceeds required 1.5×)

### Mapping from Old Steps (9-step version) to New Step Ranges

This expansion used two strategies to increase step count while maintaining realism:

**Strategy A - Split Large Steps (5 splits):**
- Old step_03 (Configuration complete, 71 lines) → **New steps 03-04**
  - step_03: Basic configuration (directories, seeds, 29 lines)
  - step_04: File paths and validation (71 lines)
- Old step_05 (LSI + UMAP, 348 lines) → **New steps 06-07**
  - step_06: LSI computation only (297 lines)
  - step_07: UMAP embedding added (348 lines)
- Old step_08 (Gene activity complete, 653 lines) → **New steps 11, 13**
  - step_11: Marker peaks + gene scores + MAGIC (571 lines)
  - step_13: TF motifs complete and working (653 lines)

**Strategy B - Oops → Hotfix Sequences (2 pairs):**

**Pair 1:** Peak calling bug (from previous expansion)
- Old step_07 → **New step_09**: Peak calling WITHOUT finding MACS2 path (563 lines) ❌
- Old step_08 → **New step_10**: Hotfix - uncommented pathToMacs2 line (653 lines) ✅

**Pair 2:** TF motifs parameter bug (NEW in this expansion)
- **New step_12**: TF motifs with wrong parameter name `matrix` instead of `name` (600 lines) ❌
- **New step_13**: Fixed parameter to use correct `name = "MotifMatrix"` (653 lines) ✅

**No Split:**
- Old step_01 → New step_01 (Initial setup - unchanged)
- Old step_02 → New step_02 (Library loading - unchanged)
- Old step_04 → New step_05 (Preprocessing - unchanged)
- Old step_06 → New step_08 (Harmony + clustering - unchanged)
- Old step_09 → New step_14 (Final state + .github/ added)

### Oops → Hotfix Details

**Pair 1: Peak Calling Bug (Inherited from previous expansion)**

**What broke (step_09):**
In the peak calling section, the critical line `pathToMacs2 <- findMacs2()` was accidentally commented out, causing the `addReproduciblePeakSet()` function to fail with "pathToMacs2 not found" error.

**How I noticed:**
When running the peak calling step, R threw an error: `Error: object 'pathToMacs2' not found`. This immediately pointed to line 446 where the undefined variable was used.

**What fixed it (step_10):**
Uncommented the line `pathToMacs2 <- findMacs2()` (line 444) to properly locate the MACS2 installation before passing it to `addReproduciblePeakSet()`. Peak calling then proceeded successfully.

**Pair 2: TF Motifs Parameter Bug (NEW)**

**What broke (step_12):**
In the TF motif variability analysis, used the wrong parameter name `matrix` instead of `name` when calling `getVarDeviations()`:
```r
var_motifs <- getVarDeviations(
  ArchRProj = proj, 
  matrix = "MotifMatrix",  # BUG: wrong parameter name!
  plot = F
)
```
This caused an error: `Error: unused argument (matrix = "MotifMatrix")` because the function expects `name =` not `matrix =`.

**How I noticed:**
When running the TF motif analysis, R threw a clear error about an unused argument. Checked the function documentation and realized I had confused the parameter name with similar functions in the ArchR package.

**What fixed it (step_13):**
Changed the parameter from `matrix =` to the correct `name =`:
```r
var_motifs <- getVarDeviations(
  ArchRProj = proj, 
  name = "MotifMatrix",  # Fixed: correct parameter name
  plot = F
)
```
The TF motif variability analysis then completed successfully.

---

## Overview

This document describes a realistic development history for the scATAC-seq analysis pipeline, reconstructing how this project would have been built incrementally by a bioinformatics researcher. The history has been expanded from 9 steps to 14 steps (1.56× multiplier) to demonstrate more granular development iterations.

## Development Timeline

The project evolved through 14 major steps, from initial repository setup to a complete, portfolio-ready analysis pipeline.

---

## Step 01: Initial Repository Setup

**Commit Message:** `Initial commit: Set up R project structure`
**Date:** Week 1, Day 1

**Files Added:** `.gitignore`, `README.md`, `renv.lock`

**Developer Notes:** "Starting a new scATAC-seq analysis project. Setting up basic R project structure with renv for reproducibility."

---

## Step 02: Add Core Libraries

**Commit Message:** `Load core libraries: ArchR, ggplot2, tidyverse`
**Date:** Week 1, Day 3

**Files Added:** `analysis_pipeline.R` (46 lines - library loading only)
**Files Modified:** `renv.lock`, `README.md`

**Developer Notes:** "Got all packages installed. Just loading libraries for now."

---

## Step 03: Basic Configuration Setup

**Commit Message:** `Add basic configuration: directories and seeding`
**Date:** Week 1, Day 4 (Morning)

**Files Modified:** `analysis_pipeline.R` (29 lines)

**Key Features:** Random seeding, thread count detection, directory structure definition

**Developer Notes:** "Starting with the basics. Will add file paths next."

---

## Step 04: Complete Configuration with File Paths

**Commit Message:** `Add file path definitions and validation logic`
**Date:** Week 1, Day 4 (Afternoon)

**Files Modified:** `analysis_pipeline.R` (71 lines)

**Key Features:** File path definitions, directory creation, file validation

**Developer Notes:** "Configuration complete. Using portable paths for cross-platform compatibility."

---

## Step 05: Implement Preprocessing and QC Pipeline

**Commit Message:** `Implement Phase 1: Preprocessing and quality control`
**Date:** Week 2, Day 2

**Files Modified:** `analysis_pipeline.R` (277 lines)

**Key Features:** Arrow files, doublet detection, QC plots

**Developer Notes:** "Preprocessing complete. TSS >8 and fragments >1000 are good thresholds."

---

## Step 06: Add LSI Dimensionality Reduction

**Commit Message:** `Implement iterative LSI for dimensionality reduction`
**Date:** Week 2, Day 5 (Morning)

**Files Modified:** `analysis_pipeline.R` (297 lines)

**Key Features:** Iterative LSI (4 iterations), 30 dimensions

**Developer Notes:** "LSI complete. Next: UMAP embeddings."

---

## Step 07: Add UMAP Embedding and Visualization

**Commit Message:** `Add UMAP embedding and initial visualizations`
**Date:** Week 2, Day 5 (Afternoon)

**Files Modified:** `analysis_pipeline.R` (348 lines)

**Key Features:** UMAP on LSI, visualizations by sample/TSS/fragments

**Developer Notes:** "UMAP working. Can see batch effects - will fix with Harmony."

---

## Step 08: Add Batch Correction and Clustering

**Commit Message:** `Implement Harmony batch correction and Seurat clustering`
**Date:** Week 2, Day 7

**Files Modified:** `analysis_pipeline.R` (435 lines)

**Key Features:** Harmony batch correction, Seurat clustering

**Developer Notes:** "Harmony works great. Cells now cluster by type, not sample."

---

## Step 09: Attempt Peak Calling (OOPS - Missing MACS2 Path)

**Commit Message:** `Add peak calling - WIP (ERROR: pathToMacs2 not defined)`
**Date:** Week 3, Day 3 (Morning)

**Files Modified:** `analysis_pipeline.R` (563 lines with bug)

**Bug:** Commented out `pathToMacs2 <- findMacs2()`

**Developer Notes:** "Getting error: 'object pathToMacs2 not found'. Need to debug."

---

## Step 10: Hotfix - Uncomment MACS2 Path Discovery

**Commit Message:** `Fix peak calling: uncomment pathToMacs2 <- findMacs2() line`
**Date:** Week 3, Day 3 (Afternoon)

**Files Modified:** `analysis_pipeline.R` (653 lines, fixed)

**Fix:** Uncommented `pathToMacs2 <- findMacs2()`

**Developer Notes:** "Fixed! Forgot to uncomment the line. Peak calling works now."

---

## Step 11: Add Gene Activity Analysis

**Commit Message:** `Implement gene scores and MAGIC imputation`
**Date:** Week 3, Day 5

**Files Modified:** `analysis_pipeline.R` (571 lines)

**Key Features:** Gene scores, marker genes, MAGIC imputation

**Developer Notes:** "Gene activity scores look good. MAGIC improves visualization."

---

## Step 12: Add TF Motif Analysis (OOPS - Wrong Parameter)

**Commit Message:** `Add TF motif enrichment - ERROR: wrong parameter name`
**Date:** Week 3, Day 6 (Morning)

**Files Modified:** `analysis_pipeline.R` (600 lines with bug)

**Bug:** Used `matrix = "MotifMatrix"` instead of `name = "MotifMatrix"`

**Developer Notes:** "Error: 'unused argument (matrix = ...)'. Need to check docs."

---

## Step 13: Hotfix - Fix TF Motif Parameter Name

**Commit Message:** `Fix TF motifs: use correct parameter name 'name' not 'matrix'`
**Date:** Week 3, Day 6 (Afternoon)

**Files Modified:** `analysis_pipeline.R` (653 lines, fixed)

**Fix:** Changed to `name = "MotifMatrix"`

**Developer Notes:** "Fixed parameter name. TF motif analysis works perfectly now."

---

## Step 14: Complete Integration, Differential Analysis, and Documentation

**Commit Message:** `Finalize pipeline: Add integration, differential analysis, and polish documentation`
**Date:** Week 4, Day 2

**Files Modified:** `analysis_pipeline.R` (979 lines), `README.md`, `renv.lock`
**Files Added:** `project_identity.md`, `report.md`, `suggestion.txt`, `suggestions_done.txt`, `.github/`

**Key Features:** scRNA-seq integration, differential accessibility, TF footprinting, co-accessibility, complete documentation

**Developer Notes:** "Pipeline complete. Documentation is portfolio-ready."

---

## Development Summary

**Total Development Time:** ~4 weeks
**Final Statistics:**
- **Lines of Code:** 979 lines
- **Dependencies:** 200+ R packages
- **Development Steps:** 14 incremental commits
- **Bug Fixes:** 2 realistic debugging cycles

**Key Technologies:** R 4.4.2, ArchR 1.0.3, Bioconductor 3.20, Harmony, MACS2, chromVAR

**Challenges Encountered:**
1. Batch effects → solved with Harmony (step_08)
2. Peak calling bug → uncommented pathToMacs2 (step_09→10)
3. TF motif parameter bug → fixed parameter name (step_12→13)

---

## Snapshot Notes

Each step directory (`step_01` through `step_14`) contains a complete snapshot excluding `.git/` and `history/`.

---

## Reproducibility Note

Final state (step_14) matches current repository exactly (excluding `history/`). All development used:
- Fixed random seeds (`set.seed(1)`)
- Locked packages (`renv.lock`)
- Portable paths (`getwd()`, `file.path()`)

---

## Expansion History

This git history has been expanded twice:
1. **First expansion:** 6 steps → 9 steps (1.5× multiplier)
2. **Second expansion (this one):** 9 steps → 14 steps (1.56× multiplier)

Total growth: 6 → 9 → 14 steps (2.33× overall from original)
