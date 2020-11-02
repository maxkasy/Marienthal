# Construction of a synthetic control for Gramatneusiedl
library(Synth) # for synthetic control method
library(furrr) # for parallelizing permutation inference
library(tidyverse)

municipalities =
  read_csv("Data/municipalities_merged.csv")


# Define relevant variables to be used for matching and synthetic control ------
# Restrict sample to subset of municipalities that are close to Gramatneusiedl
Gramatneusiedl = 30731 # GKZ for treated town

# Sample selection:
# Constructing Mahalanobis distance to Gramatneusiedl
# filtering based on this distance
matching_variables = c(
  #"EMP_rate_tot",  # this is the outcome variable for synthetic control.
  "UE_rate_tot",
  "POP_workingage",
  "ue_long_by_pop",
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
  "ue_health_condition_by_ue_tot",
  "communal_tax_by_pop"
)

# Additional matching variables for 2020
# List is in the format used by the synth package
matching_variables_2020 = list(
  list("ue_long_by_pop", 2020, "mean"),
  list("Inactive_rate_tot", 2020, "mean"),
  list("mean_wage", 2020, "mean"),
  list("age_mean_AL", 2020, "mean"),
  list("edu_low_AL_by_tot_AL", 2020, "mean"),
  list("edu_middle_AL_by_tot_AL", 2020, "mean"),
  list("poor_german_AL_by_tot_AL", 2020, "mean"),
  list("ue_health_condition_by_ue_tot", 2020, "mean")
)

# names of these additional matching variables for use in later tables
matching_variables_2020_names = paste("special",
                                      c("ue_long_by_pop",
                                        "Inactive_rate_tot",
                                        "mean_wage",
                                        "age_mean_AL",
                                        "edu_low_AL_by_tot_AL",
                                        "edu_middle_AL_by_tot_AL",
                                        "poor_german_AL_by_tot_AL",
                                        "ue_health_condition_by_ue_tot"), 
                                      "2020", sep=".")

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

# Create Mahalanobis distance to Gramatneusiedl -----
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
           quantile(distance_to_Gramatneusiedl, .05))

# convert data for compatibility to synth function
municipalities = municipalities %>%
  filter(GKZ %in% municipalities_matching_variables$GKZ) %>% # drop all municipalities further away in covariate space
  mutate(GKZ = as.integer(GKZ),
         year = as.integer(year)) %>%
  as.data.frame() # for compatibility with synth

all_identifiers = unique(municipalities$GKZ)

# function to construct synthetic control for municipality identified by GKZ -----
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
      special.predictors = matching_variables_2020,
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


if (T){
  # Running synth for all municipalities, for permutation inference
  # WARNING: this takes some time!
  plan(multiprocess) # initializing parallel processing
  
  # Run municipalities_synth() for all municipalities in selected sample
  municipalities_synth_all =
    future_map(all_identifiers, municipalities_synth)
}
