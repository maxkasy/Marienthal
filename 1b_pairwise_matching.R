# Finding pairwise matches and constructing the treatment assignment
library(nbpMatching)

participants = read_csv(paste(data_path,
                              "participants_merged.csv",
                              sep = ""))

# create and select relevant covariates for matching
participant_matchingvars = participants %>%
  select(PSTNR,
         MALE,
         PEALTER,
         MIG,
         BILDUNG,
         EINSCHRAENKUNG,
         BENEFIT_LEVEL,
         UE_DAYS) %>%
  as.data.frame()

# create matrix of pairwise participant Mahalanobis distances
participant_distances = gendistance(participant_matchingvars, idcol = 1)
participant_distmatrix = distancematrix(participant_distances)

# pairwise matching based on distances
participant_match = nonbimatch(participant_distmatrix)

# random treatment assignment
participant_assignment = assign.grp(participant_match$matches, seed = 1929)

# merge assignment with original covariates
participant_assignment_full =
  participant_assignment %>%
  as_tibble() %>%
  rename(PSTNR = Group1.ID,
         match = Group2.ID,
         match_row = Group2.Row) %>%
  mutate(
    treatment_wave = if_else(treatment.grp == "A", 1, 2),
    PSTNR = as.integer(PSTNR),
    match = as.integer(match),
    match_row = as.integer(match_row)
  ) %>%
  select(PSTNR, treatment_wave, match, match_row) %>%
  left_join(participant_matchingvars, by = "PSTNR")


# exporting files for AMS; one for each wave
participant_assignment_full %>%
  filter(treatment_wave == 1) %>%
  select(PSTNR) %>%
  write_csv(paste0(data_out, "TeilnehmerInnen_Welle_1.csv"))

participant_assignment_full %>%
  filter(treatment_wave == 2) %>%
  select(PSTNR) %>%
  write_csv(paste0(data_out, "TeilnehmerInnen_Welle_2.csv"))
