library(xlsx)

###### Data preparation for synthetic control

### 0. merge data sets ---------------------------------

#### Unemployed - cross-section ####
sub_paths_2019_12 = "AL/2019-12_AL_NOE/2019-12_"
sub_paths_2020_07 = "AL/2020-07_AL_NOE/2020-07_"
path_AL = "AL/"

files_used = c(
  "AL_NOE_ALTER.dsv",
  "AL_NOE_AUSBILDUNG.dsv",
  "AL_NOE_BERUF.dsv",
  "AL_NOE_DEUTSCH.dsv",
  "AL_NOE_GESCHLECHT.dsv",
  "AL_NOE_LZBL.dsv",
  "AL_NOE_MIGRATIONSHINTERGRUND.dsv",
  "AL_NOE_NACE.dsv",
  "AL_NOE_TAGSATZ.dsv",
  "AL_NOE_VERMITTLUNGSEINSCHRAENKUNG.dsv"
)

### age ####
file_path = paste(data_path, sub_paths_2019_12, files_used[1], sep = "")

data_age_AL = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

mean_age_AL <- data_age_AL %>%
  group_by(GKZ) %>%
  summarize(age_mean_AL = weighted.mean(ALTER, n)) %>% # weighted average
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging


### education ####
file_path = paste(data_path, sub_paths_2019_12, files_used[2], sep="")

data_edu_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate edu status
# ISCED 5-6 = edu_high_AL
# ISCED 3-4 = edu_middle_AL
# ISCED 1-2 = edu_low_AL
# -- = edu_NA_AL
data_edu_AL <- data_edu_AL %>%
  mutate(
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "AK", "edu_high_AL"),
    # AK Akademie (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "FB", "edu_high_AL"),
    # FB Fachhochschule Bakkalaureat (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "FH", "edu_high_AL"),
    # FH Fachhochschule (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "UB", "edu_high_AL"),
    # UB Bakkalaureatstudium (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "UV", "edu_high_AL"),
    # UV Universitaet (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HB", "edu_middle_AL"),
    # HB Hoehere berufsbildende Schule (ISCED 4) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HK", "edu_middle_AL"),
    # HK Hoehere kaufmaennische Schule (ISCED 4) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HT", "edu_middle_AL"),
    # HT Hoehere technische Schule (ISCED 4) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LM", "edu_middle_AL"),
    # LM Lehre und Meisterpruefung  (ISCED 4) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "H*", "edu_middle_AL"),
    # H* Hoehere Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HA", "edu_middle_AL"),
    # HA Allgemeinbildende hoehere Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HS", "edu_middle_AL"),
    # HS Hoehere sonstige Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "L*", "edu_middle_AL"),
    # L* Allgemeine Lehrausbildung (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LE", "edu_middle_AL"),
    # LE Lehre (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LT", "edu_middle_AL"),
    # LT Teilintegrierte Lehre (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "M*", "edu_middle_AL"),
    # M* Mittlere Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MB", "edu_middle_AL"),
    # MB Mittlere berufsbildende Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MK", "edu_middle_AL"),
    # MK Mittlere kaufmaennische Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MS", "edu_middle_AL"),
    # MS Sonstige mittlere Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MT", "edu_middle_AL"),
    # MT Mittlere technische Schule (ISCED 3) = edu_middle_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "PO", "edu_low_AL"),
    # PO Keine abgeschlossene Pflichtschule (ISCED 2) = edu_low_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "PS", "edu_low_AL"),
    # PS Pflichtschule (ISCED 2) = edu_low_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "XX", "edu_NA_AL"),
    # XX Ungeklaert = edu_NA_AL
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "--", "edu_NA_AL")
    # -- Ungeklaert = edu_NA_AL
  )

# sum rows of same category
data_edu_AL <- data_edu_AL %>%
  group_by(GKZ, AUSBILDUNG) %>%
  summarize(n = sum(n))

# reshape dataset to wide
edu_AL_wide = data_edu_AL %>%
  spread(AUSBILDUNG, n) %>%
  mutate(edu_NA_AL = replace_na(edu_NA_AL, 0), # replace NAs with 0 to allow summarise
        edu_low_AL = replace_na(edu_low_AL, 0),
        edu_middle_AL = replace_na(edu_middle_AL, 0),
        edu_high_AL = replace_na(edu_high_AL, 0) 
        )

# compute rates
edu_AL_wide = edu_AL_wide %>%
  mutate(
    edu_high_AL_by_tot_AL = edu_high_AL / (edu_high_AL + edu_middle_AL + edu_low_AL + edu_NA_AL),
    edu_middle_AL_by_tot_AL = edu_middle_AL / (edu_high_AL + edu_middle_AL + edu_low_AL + edu_NA_AL),
    edu_low_AL_by_tot_AL = edu_low_AL / (edu_high_AL + edu_middle_AL + edu_low_AL + edu_NA_AL)
  ) %>%
  mutate(year = 2019) %>% # add year for merging
    mutate(year = as.character(year)) # change variable type for merging


### occupation tbd####
# file_path = paste(data_path, sub_paths_2019_12, files_used[3], sep="")
# 
# data_occ_AL = read_delim(
#   file_path, 
#   delim=";",
#   locale = locale(encoding = "latin1", decimal_mark = ",")
# ) %>%
#   select( -1) # drop first column X1


### German ####
file_path = paste(data_path, sub_paths_2019_12, files_used[4], sep="")

data_german_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)


# aggregate German by >A or no info
data_german_AL <- data_german_AL %>%
  group_by(GKZ) %>%
  mutate(DEUTSCH = as.integer((DEUTSCH != "K") & (DEUTSCH != "A")
         & (DEUTSCH != "A1")) & (DEUTSCH != "A2"), # more than A or no info
  )        %>%
  group_by(GKZ, DEUTSCH) %>%
  summarize(sum_n = sum(n)) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging

# reshape dataset to wide
german_AL_wide = data_german_AL %>%
  spread(DEUTSCH, sum_n) %>%
  rename(ok_german = "TRUE",
         poor_german = "FALSE" ) %>%
  mutate(ok_german = replace_na(ok_german, 0), # replace NAs with 0 to allow summarise
         poor_german = replace_na(poor_german, 0) 
  )

# compute rates
german_AL_wide = german_AL_wide %>%
  mutate(
    poor_german_AL_by_tot_AL = poor_german / (ok_german + poor_german)
    ) 


### sex ####
file_path = paste(data_path, sub_paths_2019_12, files_used[5], sep="")

data_sex_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
) 

# prep data
sex_AL_wide = data_sex_AL %>%
  spread(GESCHLECHT, n) %>% # reshape dataset to wide
  mutate(M = replace_na(M, 0), # replace NAs with 0 to allow summarise
         W = replace_na(W, 0)) %>%
  group_by(GKZ) %>%
  summarize(M = sum(M), # sum rows of same GKZ to bring observations in same line
            W = sum(W)
  ) %>%
  mutate(
    men_AL_by_tot_AL = M / (M + W) # compute share of male unemployed
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) %>% # change variable type for merging
    rename(men_AL = M,
           women_AL = W)


### migration ####
file_path = paste(data_path, sub_paths_2019_12, files_used[7], sep="")

data_mig_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate migration first and second gen
data_mig_AL = data_mig_AL %>%
  mutate(
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "-", "no_mig_AL"),
    # "-" no migration background = no_mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG1", "mig_AL"),
    # MIG1 migration background first gen = mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG2", "mig_AL")
    # MIG2 migration background second gen = mig
  )

# prep data
mig_AL_wide = data_mig_AL %>%
  spread(MIGRATIONSHINTERGRUND, n) %>% # reshape dataset to wide
  mutate(mig_AL = replace_na(mig_AL, 0),
         no_mig_AL = replace_na(no_mig_AL, 0)) %>% # replace NAs with 0 to allow summarise
  group_by(GKZ) %>%
  summarize(mig_AL = sum(mig_AL), # sum rows of same GKZ to bring observations in same line
            no_mig_AL = sum(no_mig_AL)
  ) %>%
  mutate(
    mig_AL_by_tot_AL = mig_AL / (mig_AL + no_mig_AL) # compute share of male unemployed
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging


# ### sector tbd ####
# file_path = paste(data_path, sub_paths_2019_12, files_used[8], sep="")
# 
# data_sector_AL = read_delim(
#   file_path, 
#   delim=";",
#   locale = locale(encoding = "latin1", decimal_mark = ",")
# ) %>%
# select( -1) # drop first column X1


### Tagsatz ####
# average 2011-2020 
file_path = paste(data_path,
                  path_AL,
                  "2011-01_bis_2020-08_AL_NOE_TAGSATZ.dsv",
                  sep = "")

Ubenefit_AL = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
) %>%
  select( -1) %>% # drop first column X1
  rename(Ubenefit_daily_mean2011_2020 = TAGSATZ_DURCHSCHNITT) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year), # change variable type for merging
         GKZ = as.numeric(GKZ) # change variable type for merging
         ) 


#### Unemployed - longitudinal ####
### long term unemployed (LZBL) ####
file_path = paste(data_path,
                  path_AL,
                  "2011-01_bis_2020-08_AL_NOE_LZBL.dsv",
                  sep = "")

data_LZBL_AL = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# drop X1 (var for number of row)
myvars <- c("GKZ", "STICHTAG", "LZBL", "n")
data_LZBL_AL <- data_LZBL_AL[myvars]

# reshape dataset to wide for LZBL categories (short vs long term ue)
data_LZBL_AL = data_LZBL_AL %>%
  spread(LZBL, n)

# only 11 very small municipalities have remaining NAs for long term
# ue because there were no long term ue registered at that year
# replace NA with 0 to create a balanced panel
data_LZBL_AL = data_LZBL_AL %>%
  mutate(ue_long = replace_na(J, 0),
         ue_short = replace_na(N, 0))

# create annual averages
# alternative way using openair package: timeAverage(data_LZBL_AL, avg.time = "year")
data_LZBL_AL$year <- data_LZBL_AL$STICHTAG %>%
  format("%Y")

mean_LZBL_AL <- data_LZBL_AL %>%
  group_by(GKZ, year) %>%
  summarize(ue_long = mean(ue_long),
            ue_short = mean(ue_short))

# Link municipalities that changed GKZ over time (2017 reform)

oldGKZ <-
  c(
    32401,
    32402,
    32405,
    32406,
    32406,
    32407,
    32409,
    32410,
    32411,
    32413,
    32417,
    32418,
    32419,
    32424,
    32404,
    32403,
    32412,
    32415,
    32416,
    32421,
    32423,
    32408
  )

newGKZ <-
  c(
    30729,
    30730,
    30731,
    30732,
    30732,
    30733,
    30734,
    30735,
    30736,
    30737,
    30738,
    30739,
    30740,
    30741,
    31235,
    31949,
    31950,
    31951,
    31952,
    31953,
    31954,
    32144
  )

x <- c(1:22)

for (i in x) {
  mean_LZBL_AL$GKZ[which(mean_LZBL_AL$GKZ == oldGKZ[i])] <- newGKZ[i]
}


# compute ue rates
mean_LZBL_AL = mean_LZBL_AL %>%
  mutate(
    ue_tot = ue_long + ue_short,
    ue_short_by_ue_tot = ue_short / ue_tot,
    # short term UE as a share of total UE
    ue_long_by_ue_tot = ue_long / ue_tot     # long term UE as a share of total UE
  )


# test for balanced panel - remaining GKZ have less than 10 observations
unbalanced = mean_LZBL_AL %>%
  group_by(GKZ) %>%
  summarize(n = n()) %>%
  filter(n < 10)

### disability ####
file_path = paste(data_path,
                  path_AL,
                  "2011-01_bis_2020-08_AL_NOE_VERMITTLUNGSEINSCHRAENKUNG.dsv",
                  sep = "")

data_disability_AL = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate disability status
data_disability_AL = data_disability_AL %>%
  mutate(
    VERMITTLUNGSEINSCHRAENKUNG = as.integer(VERMITTLUNGSEINSCHRAENKUNG != "-"), # job relevant health issues
    VERMITTLUNGSEINSCHRAENKUNG = replace(VERMITTLUNGSEINSCHRAENKUNG, VERMITTLUNGSEINSCHRAENKUNG == "0", "no_disability_AL"),
    # 
    VERMITTLUNGSEINSCHRAENKUNG = replace(VERMITTLUNGSEINSCHRAENKUNG, VERMITTLUNGSEINSCHRAENKUNG == "1", "disability_AL")
    # 
    )

# reshape dataset to wide for LZBL categories (short vs long term ue)
disability_AL_wide = data_disability_AL %>%
  spread(VERMITTLUNGSEINSCHRAENKUNG, n)

# sum rows of same category
disability_AL_wide <- disability_AL_wide %>%
  mutate(disability_AL = replace_na(disability_AL, 0),
         no_disability_AL = replace_na(no_disability_AL, 0)) %>%
  group_by(GKZ, STICHTAG) %>%
  summarize(disability_AL = sum(disability_AL),
            no_disability_AL = sum(no_disability_AL)
            )

# create annual averages
disability_AL_wide$year <- disability_AL_wide$STICHTAG %>%
  format("%Y")

mean_disability_AL_wide <- disability_AL_wide %>%
  group_by(GKZ, year) %>%
  summarize(disability_AL = mean(disability_AL),
            no_disability_AL = mean(no_disability_AL))

# Link municipalities that changed GKZ over time (2017 reform)

oldGKZ <-
  c(
    32401,
    32402,
    32405,
    32406,
    32406,
    32407,
    32409,
    32410,
    32411,
    32413,
    32417,
    32418,
    32419,
    32424,
    32404,
    32403,
    32412,
    32415,
    32416,
    32421,
    32423,
    32408
  )

newGKZ <-
  c(
    30729,
    30730,
    30731,
    30732,
    30732,
    30733,
    30734,
    30735,
    30736,
    30737,
    30738,
    30739,
    30740,
    30741,
    31235,
    31949,
    31950,
    31951,
    31952,
    31953,
    31954,
    32144
  )

x <- c(1:22)

for (i in x) {
  mean_disability_AL_wide$GKZ[which(mean_disability_AL_wide$GKZ == oldGKZ[i])] <- newGKZ[i]
}

# compute share of ue with disability
mean_disability_AL_wide = mean_disability_AL_wide %>%
  mutate(
    ue_disability_by_ue_tot = disability_AL / (disability_AL + no_disability_AL)
    # share of unemployed with a disability
  )

# test for balanced panel - remaining GKZ have less than 10 observations
unbalanced = mean_disability_AL_wide %>%
  group_by(GKZ) %>%
  summarize(n = n()) %>%
  filter(n < 10)


#### Population - cross section ####
sub_paths_pop = c(
  "Bevölkerung/2019-12_BEVOELKERUNG/2019-12_",
  "Bevölkerung/2020-07_BEVOELKERUNG/2020-07_"
)

path_pop = "Bevölkerung/"

files_used_pop = c(
  "BEVOELKERUNG_NOE_ALTER.dsv",
  "BEVOELKERUNG_NOE_DIENSTGEBERGROESSE_UNTERNEHMEN.dsv",
  "BEVOELKERUNG_NOE_EU_GLIEDERUNG.dsv",
  "BEVOELKERUNG_NOE_GB.dsv",
  "BEVOELKERUNG_NOE_GESCHAETZTE_AUSBILDUNG.dsv",
  "BEVOELKERUNG_NOE_GESCHLECHT.dsv",
  "BEVOELKERUNG_NOE_INL_AUSL.dsv",
  "BEVOELKERUNG_NOE_KRZ_GELD.dsv",
  "BEVOELKERUNG_NOE_MIGRATIONSHINTERGRUND.dsv",
  "BEVOELKERUNG_NOE_NACE_2.dsv",
  "BEVOELKERUNG_NOE_UNI_STATUS.dsv",
  "BEVOELKERUNG_NOE_VERSORGUNGSPFLICHT.dsv"
)

file_paths_pop = paste(data_path, sub_paths_pop, files_used_pop, sep = "")

### age ####
file_path = paste(file_paths_pop[1], sep = "")

data_age_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

mean_age_POP <- data_age_POP %>%
  group_by(GKZ) %>%
  summarize(age_mean_POP = weighted.mean(ALTER, n)) %>% # weighted average
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging

### firmsize ####
file_path = paste(file_paths_pop[2], sep = "")

data_firmsize_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate firm sizes
# > 249 employees = firmsize_large
# 10 - 249 employees = firmsize_middle
# < 10 employees = firmsize_small
# keine Angabe = firmsize_NA
data_firmsize_POP <- data_firmsize_POP %>%
rename(firmsize = DIENSTGEBERGROESSE_UNTERNEHMEN) %>%
  mutate(
    firmsize = replace(firmsize, firmsize == "> 1000 DN", "firmsize_large"),
    # AK Akademie (ISCED 5+6) = high
    firmsize = replace(firmsize, firmsize == "250 bis 999 DN", "firmsize_large"),
    # FB Fachhochschule Bakkalaureat (ISCED 5+6) = high
    firmsize = replace(firmsize, firmsize == "50 bis 249 DN", "firmsize_middle"),
    # FH Fachhochschule (ISCED 5+6) = high
    firmsize = replace(firmsize, firmsize == "10 bis 49 DN", "firmsize_middle"),
    # UB Bakkalaureatstudium (ISCED 5+6) = high
    firmsize = replace(firmsize, firmsize == "bis 9 DN", "firmsize_small"),
    # UV Universitaet (ISCED 5+6) = high
    firmsize = replace(firmsize, firmsize == "keine Angabe", "firmsize_NA")
    # UV Universitaet (ISCED 5+6) = high
)

# sum rows of same category
data_firmsize_POP <- data_firmsize_POP %>%
  group_by(GKZ, firmsize) %>%
  summarize(n = sum(n))

# reshape dataset to wide
firmsize_POP_wide = data_firmsize_POP %>%
  spread(firmsize, n)

# compute rates
firmsize_POP_wide = firmsize_POP_wide %>%
  mutate(
    firmsize_large_POP_by_tot_POP = firmsize_large / (firmsize_large + firmsize_middle + firmsize_small ),
    firmsize_middle_POP_by_tot_POP = firmsize_middle / (firmsize_large + firmsize_middle + firmsize_small ),
    firmsize_small_POP_by_tot_POP = firmsize_small / (firmsize_large + firmsize_middle + firmsize_small )
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) %>% # change variable type for merging
  select(-firmsize_NA) # drop firmsize_NA as those constitute most likely the inactive and unemployed

### education ####
file_path = paste(file_paths_pop[5], sep = "")

data_edu_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate edu status
# ISCED 5-6 = edu_high_POP
# ISCED 3-4 = edu_middle_POP
# ISCED 1-2 = edu_low_POP
# -- = edu_NA_POP
data_edu_POP <- data_edu_POP %>%
  rename(education = GESCHAETZTE_AUSBILDUNG) %>%
  mutate(
    education = replace(education, education == "Uni/FH", "edu_high_POP"),
    education = replace(education, education == "AHS", "edu_middle_POP"),
    education = replace(education, education == "BHS", "edu_middle_POP"),
    education = replace(education, education == "BMS", "edu_middle_POP"),
    education = replace(education, education == "Lehre", "edu_middle_POP"),
    education = replace(education, education == "Pflichtschule", "edu_low_POP"),
    education = replace(education, education == "keine Angabe", "edu_NA_POP")
  )

# sum rows of same category
  data_edu_POP <- data_edu_POP %>%
  group_by(GKZ, education) %>%
  summarize(n = sum(n))

# reshape dataset to wide
edu_POP_wide = data_edu_POP %>%
  spread(education, n)

# compute rates
edu_POP_wide = edu_POP_wide %>%
  mutate(
    edu_high_POP_by_tot_POP = edu_high_POP / (edu_high_POP + edu_middle_POP + edu_low_POP + edu_NA_POP),
    edu_middle_POP_by_tot_POP = edu_middle_POP / (edu_high_POP + edu_middle_POP + edu_low_POP + edu_NA_POP),
    edu_low_POP_by_tot_POP = edu_low_POP / (edu_high_POP + edu_middle_POP + edu_low_POP + edu_NA_POP)
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging


### sex ####
file_path = paste(file_paths_pop[6], sep = "")

data_sex_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# prep data
sex_POP_wide = data_sex_POP %>%
  spread(GESCHLECHT, n) %>% # reshape dataset to wide
  mutate(M = replace_na(M, 0), # replace NAs with 0 to allow summarise
         F = replace_na(F, 0)) %>%
  group_by(GKZ) %>%
  summarize(M = sum(M), # sum rows of same GKZ to bring observations in same line
            F = sum(F)
  ) %>%
  mutate(
    men_POP_by_tot_POP = M / (M + F) # compute share of male population
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) %>% # change variable type for merging
    rename(men_POP = M,
         women_POP = F)
  
### nationality ####
file_path = paste(file_paths_pop[7], sep = "")

data_nationality_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# prep data
nationality_POP_wide = data_nationality_POP %>%
  spread(INL_AUSL, n) %>% # reshape dataset to wide
  mutate(Ausländer = replace_na(Ausländer, 0), # replace NAs with 0 to allow summarise
         Inländer = replace_na(Inländer, 0)) %>%
  group_by(GKZ) %>%
  summarize(Ausländer = sum(Ausländer), # sum rows of same GKZ to bring observations in same line
            Inländer = sum(Inländer)
  ) %>%
  mutate(
    foreign_nationality_POP_by_tot_POP = Ausländer / (Ausländer + Inländer) # compute share of male population
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging

### migration ####
file_path = paste(file_paths_pop[9], sep = "")

data_mig_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

# aggregate migration first and second gen
data_mig_POP = data_mig_POP %>%
  mutate(
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "-", "no_mig_POP"),
    # "-" no migration background = no_mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG1", "mig_POP"),
    # MIG1 migration background first gen = mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG2", "mig_POP")
    # MIG2 migration background second gen = mig
  )

# prep data
mig_POP_wide = data_mig_POP %>%
  spread(MIGRATIONSHINTERGRUND, n) %>% # reshape dataset to wide
  mutate(mig_POP = replace_na(mig_POP, 0),
         no_mig_POP = replace_na(no_mig_POP, 0)) %>% # replace NAs with 0 to allow summarise
  group_by(GKZ) %>%
  summarize(mig_POP = sum(mig_POP), # sum rows of same GKZ to bring observations in same line
            no_mig_POP = sum(no_mig_POP)
  ) %>%
  mutate(
    mig_POP_by_tot_POP = mig_POP / (mig_POP + no_mig_POP) # compute share of male unemployed
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging



# ### sector tbd####
# file_path = paste(file_paths_pop[10], sep = "")
# 
# data_sector_POP = read_delim(
#   file_path,
#   delim = ";",
#   locale = locale(encoding = "latin1", decimal_mark = ",")
# ) %>%
# select( -1) # drop first column X1

### Versorgungspflicht ####
# indicates whether the person has a care responsibility for a child <15
file_path = paste(file_paths_pop[12], sep = "")

data_care_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

data_care_POP = data_care_POP %>%
  mutate(VERSORGUNGSPFLICHT = as.integer(VERSORGUNGSPFLICHT != "-")) # care responsibility for children <15

# prep data
care_POP_wide = data_care_POP %>%
  spread(VERSORGUNGSPFLICHT, n) %>% # reshape dataset to wide
  rename(care_POP = "1",
         no_care_POP = "<NA>") %>% # rename columns
  mutate(care_POP = replace_na(care_POP, 0),
         no_care_POP = replace_na(no_care_POP, 0)) %>% # replace NAs with 0 to allow summarise
  group_by(GKZ) %>%
  summarize(care_POP = sum(care_POP), # sum rows of same GKZ to bring observations in same line
            no_care_POP = sum(no_care_POP)
  ) %>%
  mutate(
    care_POP_by_tot_POP = care_POP / (care_POP + no_care_POP) # compute share of male unemployed
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging

#### Population - longitudinal ####
read_data_NOE = function(path, filename) {
  paste(data_path, path_pop, filename, sep = "") %>%
    read_delim(delim = ";",
               locale = locale(encoding = "latin1", decimal_mark = ","))
}

### LM status ####

### Pop every status 2011-2015

data_pop_2015 = read_data_NOE(path_pop, "2011 bis 2015_Bev_erwerbf_Alter_Status_GKZ.dsv")

data_pop_2015 = data_pop_2015 %>%
  mutate(STICHTAG = dmy(STICHTAG)) %>%
  rename(status = PK_E_L3 ,
         n = "SUM(XT.REEMPLOYEES)--,COUNT(XT.PENR)ASANZAHL_PERSONEN--REEMPLOYEESBESTAND--*/")

# Pop every status 2016-2020 + merge
data_pop_2020 = read_data_NOE(path_pop,
                              "2016 bis August 2020_Bev_erwerbf_Alter_Status_GKZ.dsv")

data_pop = data_pop_2020 %>%
  mutate(STICHTAG = dmy(STICHTAG)) %>%
  rename(status = PK_E_L3 ,
         n = "SUM(XT.REEMPLOYEES)--,COUNT(XT.PENR)ASANZAHL_PERSONEN--REEMPLOYEESBESTAND--*/") %>%
  bind_rows(data_pop_2015) # merge datasets

# create year variable
data_pop$year <- data_pop$STICHTAG %>%
  format("%Y")

# collapse by GKZ, (=Gemeinde), year, status (computing annual averages)
pop_status_annual <- data_pop %>%
  group_by(GKZ, GEMEINDE, year, status) %>%
  summarize(status_n = mean(n))

# aggregate status

## Entscheiden?
# Geringfügige Beschäftigung = Beschäftigung oder Sonstige; Nach AMS = Sonstige
# Sonstige Erwerbsferne Person als Sonstige oder As Inaktiv? Betrifft mitversicherte Partnerin, aber auch mitversichertes Kind und sich in Ausbildung Befindliche

pop_status_annual <- pop_status_annual %>%
  mutate(
    status = replace(status, status == "AQ", "AM"),
    # AMS Qualifikation = AMS Vormerkung
    status = replace(status, status == "AO", "AM"),
    # Arbeitslos laut HV = AMS Vormerkung
    status = replace(status, status == "AS", "AM"),
    # sonstige AMS Vormerkung = AMS Vormerkung
    status = replace(status, status == "AL", "AM"),
    # Arbeitslos = AMS Vormerkung
    status = replace(status, status == "NU", "BE"),
    # Nicht geförderte Unselbstständige = Beschäftigte
    status = replace(status, status == "GU", "BE"),
    # Geförderte Unselbstständige = Beschäftigte
    status = replace(status, status == "SB", "BE"),
    # Selbststänidge = Beschäftigte
    status = replace(status, status == "GE", "SO"),
    # Gesichert Erwerbsfern = Sonstige
    status = replace(status, status == "GB", "BE"),
    # Geringfügige Beschäftigung = Beschäftigung; Nach AMS = Sonstige
    status = replace(status, status == "SE", "SO"),
    # Sonstig erwerbsfern = Sonstige
    status = replace(status, status == "UN", "SO") # Tod bzw. keine Daten = Sonstige
  )

# sum rows of same category
pop_status_annual <- pop_status_annual %>%
  group_by(GKZ, GEMEINDE, year, status) %>%
  summarize(status_n = sum(status_n))

# reshape dataset to wide
pop_status_wide = pop_status_annual %>%
  spread(status, status_n)

# replace N/A with 0 to create a balanced panel
# pop_status_wide = pop_status_wide %>%
#   mutate(status = replace_na(AM, 0))


# only 5 tiny municipalities have NAs for AM & BE in 2011/12 (Bergland, Weinburg, Hofamt Priel)
# replace NA with 0 to create a balanced panel
pop_status_wide = pop_status_wide %>%
  mutate(AM = replace_na(AM, 0),
         BE = replace_na(BE, 0))

# sum up to total population workingage
pop_status_wide <- pop_status_wide %>%
  mutate(POP_workingage = AM + BE + SO)

# compute rates
pop_status_wide = pop_status_wide %>%
  mutate(
    UE_rate_U3 = AM / (BE + AM),
    UE_rate_tot = AM / (BE + AM + SO),
    EMP_rate_tot = BE / (BE + AM + SO),
    Inactive_rate_tot = SO / (BE + AM + SO)
  )

# replace NaN with 0 in few municipalities with 0 AM & 0 BE for balanced panel
pop_status_wide = pop_status_wide %>%
  mutate(UE_rate_U3 = replace_na(UE_rate_U3, 0),)

# test for balanced panel - remaining GKZ have less than 5 observations
unbalanced = pop_status_wide %>%
  group_by(GKZ, GEMEINDE) %>%
  summarize(n = n()) %>%
  filter(n < 10)


#### Wages - cross section  ####
file_paths_wage = paste(data_path, path_pop, "1_UB_Avg_bmg nach GKZ_nach stichtag_20190111_202000531_mit_bestand.xlsx", sep="")

data_wage_POP = read.xlsx(file_paths_wage, 1)

data_wage_POP = data_wage_POP %>%
  rename(wage_mean = DS_BEITRAGSGRUNDLAGE_INKL_SZ,
         n = BESTAND)

# create annual averages
data_wage_POP <- data_wage_POP %>%
  mutate(STICHTAG = dmy(STICHTAG))

data_wage_POP$year <- data_wage_POP$STICHTAG %>%
  format("%Y")

# create 2 summary variables: 1: mean wage for 2019; 2: mean wage for first 5M 2020
mean_wage_POP <- data_wage_POP %>%
  group_by(GKZ, year) %>%
  summarize(mean_wage = weighted.mean(wage_mean, n)) %>% # weighted average
  mutate(GKZ = as.numeric(GKZ)) 


### communal tax ####
file_path = paste(data_path, "20-597_STATcube_Kommunalsteuer_NÖ-Gem_j00-19.csv", sep = "")

data_communal_tax = read_csv(file_path)

# data_communal_tax = read_csv(file_path, strings_)
# tt <-read.csv(file_path, stringsAsFactors = F)

# data_communal_tax = read.csv( file = file_path ,
#          encoding="UTF-8")

# reshape dataset to long
data_tax_long = data_communal_tax %>%
  gather(key = year, value = communal_tax, -GEMEINDE)

# fix special characters for separate
# -> for now fixed in source csv
# data_communal_tax = iconv(data_communal_tax$GEMEINDE, "UTF-8" , "latin1")

# seperate GEMEINDE & GKZ
data_tax_long_sep = data_tax_long %>%
  separate(GEMEINDE, sep="<", into=c("GEMEINDE", "GKZ"))

# remove >
data_tax_long_sep = data_tax_long_sep %>%
  separate(GKZ, sep=">", into=c("GKZ", "GKZ2")) %>%
     select(-"GKZ2", - "GEMEINDE") %>%
        mutate(GKZ = as.numeric(GKZ),
               communal_tax = as.numeric(communal_tax)
               ) # change variable type for merging

# substr(data_tax_long_sep$GKZ, stop, last )


#### merge ####
# with additional covariates for synthetic control

municipalities =
  pop_status_wide %>%  # LM status longitudinal
  group_by(GKZ, year) %>%
  left_join(mean_LZBL_AL, by = c("GKZ", "year")) %>% # long & short term UE longitudinal
  left_join(mean_age_AL, by = c("GKZ", "year")) %>% # age AL cross-section
  left_join(edu_AL_wide, by = c("GKZ", "year")) %>% # edu AL cross-section
  left_join(german_AL_wide, by = c("GKZ", "year")) %>% # German AL cross-section
  left_join(sex_AL_wide, by = c("GKZ", "year")) %>% # sex AL cross-section
  left_join(mig_AL_wide, by = c("GKZ", "year")) %>% # migration background AL cross-section
  left_join(Ubenefit_AL, by = c("GKZ", "year")) %>% # unemployment benefit AL cross-section
  left_join(mean_disability_AL_wide, by = c("GKZ", "year")) %>%  # disability AL longitudinal
  left_join(mean_age_POP, by = c("GKZ", "year")) %>%  # age POP cross-section  
  left_join(firmsize_POP_wide, by = c("GKZ", "year")) %>%  # firmsize POP cross-section
  left_join(edu_POP_wide, by = c("GKZ", "year")) %>%  # edu POP cross-section 
  left_join(sex_POP_wide, by = c("GKZ", "year")) %>%  # sex POP cross-section    
  left_join(nationality_POP_wide, by = c("GKZ", "year")) %>%  # nationality POP cross-section   
  left_join(mig_POP_wide, by = c("GKZ", "year")) %>%  # migration background POP cross-section   
  left_join(care_POP_wide, by = c("GKZ", "year")) %>%  # care responsibility POP cross-section  
  left_join(mean_wage_POP, by = c("GKZ", "year")) %>% # mean wage cross-section for 2019 & 2020
  left_join(data_tax_long_sep, by = c("GKZ", "year")) # communal tax

  
  
# drop Pop without GKZ (GKZ = 0)
municipalities <- municipalities %>%
  filter(GKZ != 0)

# compute rates for long & short UE
municipalities = municipalities %>%
  mutate(ue_long_by_pop = ue_long / (BE + AM + SO),
         ue_short_by_pop = ue_short / (BE + AM + SO),
         communal_tax_by_pop = communal_tax / POP_workingage)


# export
municipalities %>%
  write_csv(paste(data_out,
                  "municipalities_merged.csv",
                  sep = ""))
