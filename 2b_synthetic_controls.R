library(Synth) # for synthetic control method
library(furrr) # for parallelizing permutation inference

municipalities =
  read_csv("Data/municipalities_merged.csv") %>%
  mutate(GKZ = as.integer(GKZ),
         year = as.integer(year)) %>%
  as.data.frame() # for compatibility with synth


# prepare data in synth format
Gramatneusiedl = 30731 # GKZ for treated town
all_identifiers = unique(municipalities$GKZ)

municipalities_synth = function(GKZ) {
  controls = all_identifiers[all_identifiers != GKZ]
  
# TBD: restrict donor pool to municipalities with covariate values that are not too far  
  
  municipalities_synth_prepared = municipalities %>%
    dataprep(
      unit.variable = "GKZ",
      unit.names.variable = "GEMEINDE",
      time.variable = "year",
      dependent = "UE_rate_tot",
      predictors = c("POP_workingage", "SO"),
      time.predictors.prior = 2020,
      special.predictors = list(list("age_mean", 2019, c("mean"))),
      treatment.identifier = GKZ,
      controls.identifier   = controls,
      time.optimize.ssr     = 2011:2020
    )
  
  municipalities_synth_out =
    synth(data.prep.obj = municipalities_synth_prepared,
          optimxmethod = "BFGS")
  
  list(municipalities_synth_prepared = municipalities_synth_prepared,
       municipalities_synth_out = municipalities_synth_out)
}


municipalities_synth_Gramatneusiedl =
  municipalities_synth(Gramatneusiedl)

municipalities_synth_prepared = municipalities_synth_Gramatneusiedl$municipalities_synth_prepared
municipalities_synth_out = municipalities_synth_Gramatneusiedl$municipalities_synth_out


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
  head(n = 15)


# Running synth for all municipalities, for permutation inference
# WARNING: this takes a long time!
plan(multiprocess)

municipalities_synth_all =
  future_map(all_identifiers, municipalities_synth)



# TBD: permutation inference, implemented by running a for loop to implement placebo tests across all control units
# in the sample and collecting information on the gaps.