library(tidyverse)
library(lubridate)

###### Data preparation for synthetic control

### 0. merge data sets ---------------------------------

#### Unemployed - cross-section ####
sub_paths_2019_12 = "AL/2019-12_AL_NOE/2019-12_"
sub_paths_2020_07 = "AL/2020-07_AL_NOE/2020-07_"
path_AL = "AL/"

files_used = c("AL_NOE_ALTER.dsv",
               "AL_NOE_AUSBILDUNG.dsv",
               "AL_NOE_BERUF.dsv",
               "AL_NOE_DEUTSCH.dsv",
               "AL_NOE_GESCHLECHT.dsv",
               "AL_NOE_LZBL.dsv",
               "AL_NOE_MIGRATIONSHINTERGRUND.dsv",
               "AL_NOE_NACE.dsv",
               "AL_NOE_TAGSATZ.dsv",
               "AL_NOE_VERMITTLUNGSEINSCHRAENKUNG.dsv")

### mean age
file_path = paste(data_path, sub_paths_2019_12, files_used[1], sep="")

data_age_AL = read_delim(file_path, delim=";",
                      locale = locale(encoding = "latin1", decimal_mark = ","))

mean_age_AL <- data_age_AL %>% 
  group_by(GKZ) %>% 
  summarize(age_mean = weighted.mean(ALTER, n)) %>% # weighted average
  mutate(
    year = 2019) %>% # add year for merging
mutate(
    year = as.character(year)) # change variable type for merging



### education share - not complete
# file_path = paste(data_path, sub_paths_2019_12, files_used[2], sep="")
# 
# data_edu_AL = read_delim(file_path, delim=";",
#                       locale = locale(encoding = "latin1", decimal_mark = ","))
# 
# mean_edu_AL <- data_edu_AL %>%
#   group_by(GKZ) %>%
#   mutate(BILDUNG = as.character((AUSBILDUNG != "PS") & (AUSBILDUNG != "PO")), # more than Pflichtschule
#   )        %>%
#   group_by(GKZ, BILDUNG) %>%
#   summarize(sum_n = sum(n)) %>%
#   print(head())
# 
# 
# 
# read_data_NOE = function(path, filename) {
#   paste(data_path, path, filename, sep = "") %>%
#     read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
# }
# 
# for (filename in files_used) {
#   data_sub = map(sub_paths, function(path) read_data_NOE(path, filename))
#   do.call(rbind, data_sub) %>%
#     write_csv(paste(data_path, "AL_merged/", filename, sep = ""))
# }




#### Unemployed - longitudinal ####
### long term unemployed (LZBL)
# use number of LZBL until we get the active pop to compute rates
file_path = paste(data_path, path_AL, "2011-01_bis_2020-08_AL_NOE_LZBL.dsv", sep="")

data_LZBL_AL = read_delim(file_path, delim=";",
                         locale = locale(encoding = "latin1", decimal_mark = ","))

# drop X1 (var for number of row)
myvars <- c("GKZ", "STICHTAG", "LZBL", "n" )
data_LZBL_AL <- data_LZBL_AL[myvars] 

# reshape dataset to wide for LZBL categories (short vs long term ue)
data_LZBL_AL = data_LZBL_AL %>% 
  spread(LZBL, n) 

# only 11 very small municipalities have remaining NAs for long term 
# ue because there were no long term ue registered at that year
# replace NA with 0 to create a balanced panel
data_LZBL_AL = data_LZBL_AL %>%
  mutate(ue_long = replace_na(J, 0),
         ue_short = replace_na(N, 0)
         )

# create annual averages
# alternative way using openair package: timeAverage(data_LZBL_AL, avg.time = "year")
data_LZBL_AL$year <- data_LZBL_AL$STICHTAG %>%
  format("%Y")

mean_LZBL_AL <- data_LZBL_AL %>% 
  group_by(GKZ, year) %>% 
  summarize(ue_long = mean(ue_long),
            ue_short = mean(ue_short)
            )

# Link municipalities that changed GKZ over time (2017 reform)

oldGKZ <- c(32401, 32402, 32405, 32406, 32406, 32407, 32409, 32410, 32411, 32413, 32417, 
            32418, 32419, 32424, 32404, 32403, 32412, 32415, 32416, 32421, 32423, 32408)

newGKZ <- c(30729, 30730, 30731, 30732, 30732, 30733, 30734, 30735, 30736, 30737, 30738, 
            30739, 30740, 30741, 31235, 31949, 31950, 31951, 31952, 31953, 31954, 32144)

x <- c(1:22)

for( i in x ){
      mean_LZBL_AL$GKZ[which(mean_LZBL_AL$GKZ == oldGKZ[i])] <- newGKZ[i]
}


# compute ue rates
mean_LZBL_AL = mean_LZBL_AL %>%
  mutate(ue_tot = ue_long + ue_short,
         ue_short_share = ue_short / ue_tot,  # short term UE as a share of total UE
         ue_long_share = ue_long / ue_tot     # long term UE as a share of total UE
  )


# test for balanced panel - remaining GKZ have less than 10 observations
unbalanced = mean_LZBL_AL %>% 
  group_by(GKZ) %>% 
  summarize(n=n()) %>% 
  filter(n<10) 


#### Population - cross section ####
sub_paths_pop = c("Bevölkerung/2019-12_BEVOELKERUNG/2019-12_",
                  "Bevölkerung/2020-07_BEVOELKERUNG/2020-07_")

path_pop = "Bevölkerung/"

files_used_pop = c("BEVOELKERUNG_NOE_ALTER.dsv",
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

file_paths_pop = paste(data_path, sub_paths_pop, files_used_pop, sep="")


#### Population - longitudinal ####
read_data_NOE = function(path, filename) {
  paste(data_path, path_pop, filename, sep = "") %>% 
    read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
}

### Pop every status 2011-2015

data_pop_2015 = read_data_NOE(path_pop, "2011 bis 2015_Bev_erwerbf_Alter_Status_GKZ.dsv")

data_pop_2015 = data_pop_2015 %>% 
  mutate(STICHTAG = dmy(STICHTAG)) %>% 
    rename(status = PK_E_L3 ,
           n = "SUM(XT.REEMPLOYEES)--,COUNT(XT.PENR)ASANZAHL_PERSONEN--REEMPLOYEESBESTAND--*/")

# Pop every status 2016-2020 + merge
data_pop_2020 = read_data_NOE(path_pop, "2016 bis August 2020_Bev_erwerbf_Alter_Status_GKZ.dsv")

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
  mutate(status = replace(status, status == "AQ", "AM"), # AMS Qualifikation = AMS Vormerkung
         status = replace(status, status == "AO", "AM"), # Arbeitslos laut HV = AMS Vormerkung
         status = replace(status, status == "AS", "AM"), # sonstige AMS Vormerkung = AMS Vormerkung
         status = replace(status, status == "AL", "AM"), # Arbeitslos = AMS Vormerkung
         status = replace(status, status == "NU", "BE"), # Nicht geförderte Unselbstständige = Beschäftigte
         status = replace(status, status == "GU", "BE"), # Geförderte Unselbstständige = Beschäftigte
         status = replace(status, status == "SB", "BE"), # Selbststänidge = Beschäftigte
         status = replace(status, status == "GE", "SO"), # Gesichert Erwerbsfern = Sonstige
         status = replace(status, status == "GB", "BE"), # Geringfügige Beschäftigung = Beschäftigung; Nach AMS = Sonstige
         status = replace(status, status == "SE", "SO"), # Sonstig erwerbsfern = Sonstige
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
         BE = replace_na(BE, 0)
  )

# compute rates
pop_status_wide = pop_status_wide %>%
  mutate(UE_rate_U3 = AM / (BE + AM),
         UE_rate_tot = AM / (BE + AM + SO),
         EMP_rate_tot = BE / (BE + AM + SO),
         Inactive_rate_tot = SO / (BE + AM + SO)
             )

# replace NaN with 0 in few municipalities with 0 AM & 0 BE for balanced panel
pop_status_wide = pop_status_wide %>%
  mutate(UE_rate_U3 = replace_na(UE_rate_U3, 0),
  )

# test for balanced panel - remaining GKZ have less than 5 observations
unbalanced = pop_status_wide %>% 
  group_by(GKZ, GEMEINDE) %>% 
  summarize(n=n()) %>% 
  filter(n<10) 


#### Wages - cross section ####


#### merge ####
# with additional covariates for synthetic control

municipalities =
  pop_status_wide %>%  # LM status
    group_by(GKZ, year) %>%
  left_join(mean_LZBL_AL, by = c("GKZ", "year")) %>% # long & short term UE
  left_join(mean_age_AL, by = c("GKZ", "year")) # age  

# drop Pop without GKZ (GKZ = 0)
municipalities <- municipalities %>%
  filter(GKZ != 0)

# compute rates for long & short UE
municipalities = municipalities %>%
  mutate(UE_long_rate_tot = ue_long / (BE + AM + SO),
         UE_short_rate_tot = ue_short / (BE + AM + SO)
  )


# export
municipalities %>% 
  write_csv(paste(data_out,
                  "municipalities_merged.csv",
                  sep = ""))

