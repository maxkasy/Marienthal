library(tidyverse)
library(lubridate)

home <- getwd()
data_out <- paste0(home, "/Data/")

# 1. Pairwise matching and randomization -------- 

# data path for local data: switch between Max and Lukas
data_path = "/Users/max/Documents/Jobgarantie/Marienthal_merged/"
# data_path = "/Users/lukas/Documents/Jobgarantie/Marienthal_merged/"

# source script from Dropbox
source("1a_matching_data_prep.R")

source("1b_pairwise_matching.R")

source("1c_matching_quality_checks.R")




# 2. Synthetic control -------- 

data_path = "/Users/max/Documents/Jobgarantie/Population_noe/"
# data_path = "/Users/lukas/Documents/Jobgarantie/Population_noe/"

source("2a_synth_data_prep.R")

source("2b_synthetic_controls.R")

