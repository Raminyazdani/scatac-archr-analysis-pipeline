# Sys.setenv(CONDA_BUILD_SYSROOT="/")
# install.packages("renv")
# renv::init()

# if (!requireNamespace("devtools", quietly = TRUE)) {
#   install.packages("devtools", dependencies = TRUE)
# }
# 
# # Install 'BiocManager' if not already installed
# if (!requireNamespace("BiocManager", quietly = TRUE)) {
#   install.packages("BiocManager", dependencies = TRUE)
# }
# 
# devtools::install_github(
#   "GreenleafLab/ArchR", 
#   ref = "dev", 
#   repos = BiocManager::repositories(),
#   dependencies = TRUE,
#   upgrade = "always" # Ensures dependencies are updated if needed
# )



#devtools::install_github(
#  "GreenleafLab/ArchR", 
#  ref = "dev", 
#  repos = BiocManager::repositories(),
#  dependencies = TRUE,
#)


# devtools::install_github("GreenleafLab/ArchR", ref="master", repos = BiocManager::repositories())
# ArchR::installExtraPackages()




# Configuration & Initialization

# 0 initialation
# 0.1 libraries

library(ArchR)
library(ggplot2)
library(tidyverse)
library(patchwork)
