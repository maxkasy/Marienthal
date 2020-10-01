library(Synth)
library(tidyverse)

home <- getwd()
data_out <- paste0(home, "/Data/")

# source script from Dropbox
# source( paste0(home, "/synth_data_prep.R"))

municipalities =
  read_csv(paste(data_out,
                 "municipalities_merged.csv",
                 sep = "")) %>% 
  mutate(GKZ = as.integer(GKZ),
         year = as.integer(year)) %>%
  as.data.frame() # for compatibility with synth


# prepare data in synth format
Gramatneusiedl = 30731 # GKZ for treated town
controls = unique(municipalities$GKZ)
controls = controls[controls != Gramatneusiedl]


municipalities_synth_prepared = municipalities %>%
  dataprep(
    unit.variable = "GKZ",
    unit.names.variable = "GEMEINDE",
    time.variable = "year",
    dependent = "UE_rate_tot",
    predictors = c("POP_workingage"),
    time.predictors.prior = 2020,
    special.predictors = list(list("age_mean", 2019, c("mean"))),
    treatment.identifier = Gramatneusiedl,
    controls.identifier   = controls,
    time.optimize.ssr     = 2011:2020
  )

municipalities_synth_out =
  synth(data.prep.obj = municipalities_synth_prepared)

# checking solution of synth
gaps_covariates = municipalities_synth_prepared$X0 %*% municipalities_synth_out$solution.w - municipalities_synth_prepared$X1

gaps_outcomes = municipalities_synth_prepared$Z0 %*% municipalities_synth_out$solution.w - municipalities_synth_prepared$Z1

gaps_covariates
gaps_outcomes

municipalities_synth_tables <-
  synth.tab(dataprep.res = municipalities_synth_prepared, 
            synth.res = municipalities_synth_out)

municipalities_synth_tables$tab.w %>% 
  arrange(desc(w.weights)) %>% 
  head(n=15)


# TBD: permutation inference, implemented by running a for loop to implement placebo tests across all control units
# in the sample and collecting information on the gaps.