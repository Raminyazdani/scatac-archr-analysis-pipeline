
# 6 Transcription Factor motif activity

# 6.1 Compute TF motif activity
proj <- addMotifAnnotations(
  ArchRProj = proj, 
  motifSet = "cisbp",   # Use the CIS-BP motif database
  name = "Motif",
  force=T# Name for the motif annotations
)

proj <- addBgdPeaks(proj)

proj <- addDeviationsMatrix(
  ArchRProj = proj, 
  peakAnnotation = "Motif",  # Use the motif annotations added earlier
)

# 6.2 Plot UMAP embeddings for marker TFs
# OOPS: Wrong parameter name - should be "name" not "matrix"
var_motifs <- getVarDeviations(
  ArchRProj = proj, 
  matrix = "MotifMatrix",  # BUG: wrong parameter name!
  plot = F
)
