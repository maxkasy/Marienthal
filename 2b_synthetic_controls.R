library(Synth) # for synthetic control method
library(furrr) # for parallelizing permutation inference
library(tidyverse)

municipalities =
  read_csv("Data/municipalities_merged.csv")

# Restrict sample to subset of municipalities that are close to Gramatneusiedl
Gramatneusiedl = 30731 # GKZ for treated town



# Sample selection:
# Constructing Mahalanobis distance to Gramatneusiedl
# filtering based on this distance
matching_variables = c(
  "UE_rate_tot", # this is the outcome variable for synthetic control.
  "ue_long_by_pop", 
  "POP_workingage",
  "Inactive_rate_tot",
  "age_mean_POP",
  "firmsize_small_POP_by_tot_POP",
  "firmsize_middle_POP_by_tot_POP",
  "edu_low_POP_by_tot_POP",
  "edu_middle_POP_by_tot_POP",
  "men_POP_by_tot_POP",
  "mig_POP_by_tot_POP",
  "care_POP_by_tot_POP",
  "mean_wage",
  "age_mean_AL",
  "edu_low_AL_by_tot_AL",
  "edu_middle_AL_by_tot_AL",
  "poor_german_AL_by_tot_AL",
  "men_AL_by_tot_AL",
  "mig_AL_by_tot_AL",
  # "Ubenefit_daily_mean2011_2020 ",
  "ue_disability_by_ue_tot"
)



# NOTE: INCLUDE 2020 MEAN WAGE AS SPECIAL PREDICTOR? SEPARATE MATCHING VARIABLE

Gramatneusiedl_matching_variables =
  municipalities[municipalities$GKZ == Gramatneusiedl &
                   municipalities$year == 2019, matching_variables] %>%
  as.matrix() %>%  as.vector()

municipalities_matching_variables = municipalities %>%
  filter(year == 2019) %>%
  select(GKZ, matching_variables)

municipalities_matrix =  municipalities_matching_variables %>%
  select(-GKZ) %>%
  as.matrix()

# Create Mahalanobis distance to Gramatneusiedl
municipalities_matching_variables = municipalities_matching_variables %>%
  mutate(
    distance_to_Gramatneusiedl =
      municipalities_matrix %>%
      mahalanobis(center = Gramatneusiedl_matching_variables,
                  cov = var(municipalities_matrix))
  )

# Filtering based on distance
municipalities_matching_variables = municipalities_matching_variables %>% 
  filter(distance_to_Gramatneusiedl < 
           quantile(distance_to_Gramatneusiedl,.1))




# convert data for compatibility to synth function
municipalities = municipalities %>%
  filter(GKZ %in% municipalities_matching_variables$GKZ) %>% # drop all municipalities further away in covariate space
  mutate(GKZ = as.integer(GKZ),
         year = as.integer(year)) %>%
  as.data.frame() # for compatibility with synth

all_identifiers = unique(municipalities$GKZ)

# function to construct synthetic control for municipality identified by GKZ
municipalities_synth = function(GKZ) {
  control_municipalities = all_identifiers[all_identifiers != GKZ]
  
  municipalities_synth_prepared = municipalities %>%
    dataprep(
      unit.variable = "GKZ",
      unit.names.variable = "GEMEINDE",
      time.variable = "year",
      dependent = matching_variables[1],
      predictors = matching_variables[-1],
      # Use all matching variables as predictors, except the outcome in component 1
      time.predictors.prior = 2019,
      # special.predictors = list(list("age_mean_AL", 2019, c("mean"))),
      treatment.identifier = GKZ,
      controls.identifier   = control_municipalities,
      time.optimize.ssr     = 2011:2020
    )
  
  municipalities_synth_out =
    synth(data.prep.obj = municipalities_synth_prepared)
  
  list(municipalities_synth_prepared = municipalities_synth_prepared,
       municipalities_synth_out = municipalities_synth_out)
}

municipalities_synth_Gramatneusiedl =
  municipalities_synth(Gramatneusiedl)




# Running synth for all municipalities, for permutation inference
# WARNING: this takes a long time!
plan(multiprocess) # initializing parallel processing

# Run municipalities_synth() for all municipalities in selected sample
municipalities_synth_all =
  future_map(all_identifiers, municipalities_synth)


