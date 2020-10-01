library(tidyverse)
library(lubridate)

data_out <- "/Data/"

# 1. Pairwise matching and randomization -------- 

# data path for local data: switch between Max and Lukas
data_path = "/Users/max/Documents/Jobgarantie/Marienthal_merged/"
# data_path = "/Users/lukas/Documents/Jobgarantie/Marienthal_merged/"

# source script from Dropbox
source("matching_data_prep.R")

source("pairwise_matching.R")

source("matching_quality_checks.R")




# 2. Synthetic control -------- 

data_path = "/Users/max/Documents/Jobgarantie/Population_noe/"
# data_path = "/Users/lukas/Documents/Jobgarantie/Population_noe/"

source("synth_data_prep.R")

source("synthetic_controls.R")

