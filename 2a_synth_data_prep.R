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
# ISCED 5-6 = edu_high
# ISCED 3-4 = edu_middle
# ISCED 1-2 = edu_low
# -- = edu_missing
data_edu_AL <- data_edu_AL %>%
  mutate(
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "AK", "edu_high"),
    # AK Akademie (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "FB", "edu_high"),
    # FB Fachhochschule Bakkalaureat (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "FH", "edu_high"),
    # FH Fachhochschule (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "UB", "edu_high"),
    # UB Bakkalaureatstudium (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "UV", "edu_high"),
    # UV Universitaet (ISCED 5+6) = high
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HB", "edu_middle"),
    # HB Hoehere berufsbildende Schule (ISCED 4) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HK", "edu_middle"),
    # HK Hoehere kaufmaennische Schule (ISCED 4) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HT", "edu_middle"),
    # HT Hoehere technische Schule (ISCED 4) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LM", "edu_middle"),
    # LM Lehre und Meisterpruefung  (ISCED 4) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "H*", "edu_middle"),
    # H* Hoehere Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HA", "edu_middle"),
    # HA Allgemeinbildende hoehere Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "HS", "edu_middle"),
    # HS Hoehere sonstige Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "L*", "edu_middle"),
    # L* Allgemeine Lehrausbildung (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LE", "edu_middle"),
    # LE Lehre (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "LT", "edu_middle"),
    # LT Teilintegrierte Lehre (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "M*", "edu_middle"),
    # M* Mittlere Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MB", "edu_middle"),
    # MB Mittlere berufsbildende Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MK", "edu_middle"),
    # MK Mittlere kaufmaennische Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MS", "edu_middle"),
    # MS Sonstige mittlere Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "MT", "edu_middle"),
    # MT Mittlere technische Schule (ISCED 3) = edu_middle
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "PO", "edu_low"),
    # PO Keine abgeschlossene Pflichtschule (ISCED 2) = edu_low
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "PS", "edu_low"),
    # PS Pflichtschule (ISCED 2) = edu_low
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "XX", "edu_missing"),
    # XX Ungeklaert = edu_missing
    AUSBILDUNG = replace(AUSBILDUNG, AUSBILDUNG == "--", "edu_missing")
    # -- Ungeklaert = edu_missing
  )

# sum rows of same category
data_edu_AL <- data_edu_AL %>%
  group_by(GKZ, AUSBILDUNG) %>%
  summarize(n = sum(n))

# reshape dataset to wide
edu_AL_wide = data_edu_AL %>%
  spread(AUSBILDUNG, n)

# compute rates
edu_AL_wide = edu_AL_wide %>%
  mutate(
    edu_high_AL_by_tot_AL = edu_high / (edu_high + edu_middle + edu_low + edu_missing),
    edu_middle_AL_by_tot_AL = edu_middle / (edu_high + edu_middle + edu_low + edu_missing),
    edu_low_AL_by_tot_AL = edu_low / (edu_high + edu_middle + edu_low + edu_missing)
  )

# add year for merging
edu_AL_wide = edu_AL_wide %>%
  mutate(year = 2019) %>% # add year for merging
    mutate(year = as.character(year)) # change variable type for merging

### occupation not complete####
file_path = paste(data_path, sub_paths_2019_12, files_used[3], sep="")

data_occ_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)


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
         poor_german = "FALSE" )

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
  mutate(year = as.character(year)) # change variable type for merging


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
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "-", "no_mig"),
    # "-" no migration background = no_mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG1", "mig"),
    # MIG1 migration background first gen = mig
    MIGRATIONSHINTERGRUND = replace(MIGRATIONSHINTERGRUND, MIGRATIONSHINTERGRUND == "MIG2", "mig")
    # MIG2 migration background second gen = mig
  )

# prep data
mig_AL_wide = data_mig_AL %>%
  spread(MIGRATIONSHINTERGRUND, n) %>% # reshape dataset to wide
  mutate(mig = replace_na(mig, 0),
         no_mig = replace_na(no_mig, 0)) %>% # replace NAs with 0 to allow summarise
  group_by(GKZ) %>%
  summarize(mig = sum(mig), # sum rows of same GKZ to bring observations in same line
            no_mig = sum(no_mig)
  ) %>%
  mutate(
    mig_AL_by_tot_AL = mig / (mig + no_mig) # compute share of male unemployed
  ) %>%
  mutate(year = 2019) %>% # add year for merging
  mutate(year = as.character(year)) # change variable type for merging


### sector not complete####
file_path = paste(data_path, sub_paths_2019_12, files_used[8], sep="")

data_sector_AL = read_delim(
  file_path, 
  delim=";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
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

### Tagsatz ####


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
    VERMITTLUNGSEINSCHRAENKUNG = replace(VERMITTLUNGSEINSCHRAENKUNG, VERMITTLUNGSEINSCHRAENKUNG == "0", "no_disability"),
    # AK Akademie (ISCED 5+6) = high
    VERMITTLUNGSEINSCHRAENKUNG = replace(VERMITTLUNGSEINSCHRAENKUNG, VERMITTLUNGSEINSCHRAENKUNG == "1", "disability")
    # FB Fachhochschule Bakkalaureat (ISCED 5+6) = high
    )

# reshape dataset to wide for LZBL categories (short vs long term ue)
disability_AL_wide = data_disability_AL %>%
  spread(VERMITTLUNGSEINSCHRAENKUNG, n)

# sum rows of same category
disability_AL_wide <- disability_AL_wide %>%
  mutate(disability = replace_na(disability, 0),
         no_disability = replace_na(no_disability, 0)) %>%
  group_by(GKZ, STICHTAG) %>%
  summarize(disability = sum(disability),
            no_disability = sum(no_disability)
            )

# create annual averages
disability_AL_wide$year <- disability_AL_wide$STICHTAG %>%
  format("%Y")

mean_disability_AL_wide <- disability_AL_wide %>%
  group_by(GKZ, year) %>%
  summarize(disability = mean(disability),
            no_disability = mean(no_disability))

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
    ue_disability_by_ue_tot = disability / (disability + no_disability)
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
  mutate(year = as.character(year)) # change variable type for merging

### nationality ####
file_path = paste(file_paths_pop[7], sep = "")

data_nationality_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)



### migration ####
file_path = paste(file_paths_pop[9], sep = "")

data_mig_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

### sector ####
file_path = paste(file_paths_pop[10], sep = "")

data_sector_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)

### Versorgungspflicht ####
file_path = paste(file_paths_pop[12], sep = "")

data_care_POP = read_delim(
  file_path,
  delim = ";",
  locale = locale(encoding = "latin1", decimal_mark = ",")
)


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


#### Wages - cross section ####



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
  left_join(mean_disability_AL_wide, by = c("GKZ", "year")) %>%  # disability AL longitudinal
  left_join(mean_age_POP, by = c("GKZ", "year")) %>%  # age POP cross-section  
  left_join(firmsize_POP_wide, by = c("GKZ", "year")) %>%  # firmsize POP cross-section  
  left_join(sex_POP_wide, by = c("GKZ", "year")) %>%  # sex POP cross-section    

  
# drop Pop without GKZ (GKZ = 0)
municipalities <- municipalities %>%
  filter(GKZ != 0)

# compute rates for long & short UE
municipalities = municipalities %>%
  mutate(ue_long_by_pop = ue_long / (BE + AM + SO),
         ue_short_by_pop = ue_short / (BE + AM + SO))


# export
municipalities %>%
  write_csv(paste(data_out,
                  "municipalities_merged.csv",
                  sep = ""))
