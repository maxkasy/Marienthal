library(tidyverse)
library(lubridate)
library(xlsx)

### Explore municipal data for synthetic control

# data path for local data: switch between Max and Lukas
# data_path = "/Users/max/Documents/Jobgarantie/Population_noe/"
 data_path = "/Users/lukas/Documents/Jobgarantie/Population_noe/"

home <- getwd()
data_out <- paste0(home, "/Data/")

## Unemployed
# cross-section data
sub_paths = c("AL/2019-12_AL_NOE/2019-12_",
              "AL/2020-07_AL_NOE/2020-07_",
              "AL/2020-08_AL_NOE/2020-08_")

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


file_paths = paste(data_path, sub_paths, files_used, sep="")

data_list_al = map(file_paths, function(path) read_delim(path, delim=";",
                                                      locale = locale(encoding = "latin1", decimal_mark = ",")))

for (dat in data_list_al) print(head(dat))

for (i in 1:length(data_list_al)) {
  print(i)
  print(files_used[i])
  print(NROW(data_list[[i]]))
  print(head(data_list[[i]]))
}

# longitudinal data
read_data_NOE = function(path, filename) {
  paste(data_path, path, filename, sep = "") %>% 
    read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
}

data_LZBL = read_data_NOE(path_AL, "2011-01_bis_2020-08_AL_NOE_LZBL.dsv")
data_TAGSATZ = read_data_NOE(path_AL, "2011-01_bis_2020-08_AL_NOE_TAGSATZ.dsv")
data_VERMITTLUNGSEINSCHRAENKUNG = read_data_NOE(path_AL, "2011-01_bis_2020-08_AL_NOE_VERMITTLUNGSEINSCHRAENKUNG.dsv")

print(head(data_LZBL))
print(head(data_TAGSATZ))
print(head(data_VERMITTLUNGSEINSCHRAENKUNG))

## Population
# cross-section data
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

data_list_pop = map(file_paths_pop, function(path) read_delim(path, delim=";",
                                                      locale = locale(encoding = "latin1", decimal_mark = ",")))

for (dat in data_list_pop) print(head(dat))

for (i in 1:length(data_list_pop)) {
  print(i)
  print(files_used_pop[i])
  print(NROW(data_list_pop[[i]]))
  print(head(data_list_pop[[i]]))
}

# longitudinal data
read_data_NOE = function(path, filename) {
  paste(data_path, path, filename, sep = "") %>% 
    read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
}

data_pop_ue = read_data_NOE(path_pop, "2011-01_bis_2020-07_BEVOELKERUNG_NOE_ANZAHL_AL.dsv")

print(head(data_pop_ue))

# Pop every status 2011-2015
data_pop_2015 = read_data_NOE(path_pop, "2011 bis 2015_Bev_erwerbf_Alter_Status_GKZ.dsv")

print(head(data_pop_2015))

# Pop every status 2016-2020
data_pop_2020 = read_data_NOE(path_pop, "2016 bis August 2020_Bev_erwerbf_Alter_Status_GKZ.dsv")

print(head(data_pop_2020))


## Wage (Bemessungsgrundlage)

file_paths_wage_age_sex_AMSsubsidy = paste(data_path, path_pop, "UB_Avg_bmg nach Geschlecht_ALTER_ GKZ_nach stichtag_20190111_202000531.xlsx", sep="")
file_paths_wage_age = paste(data_path, path_pop, "3_UB_Avg_bmg nach GKZ_nach Alter_stichtag_20190111_202000531_mit_bestand.xlsx", sep="")
file_paths_wage_sex = paste(data_path, path_pop, "2_UB_Avg_bmg nach GKZ_nach Geschlecht_stichtag_20190111_202000531_mit_bestand.xlsx", sep="")
file_paths_wage = paste(data_path, path_pop, "1_UB_Avg_bmg nach GKZ_nach stichtag_20190111_202000531_mit_bestand.xlsx", sep="")

data_wage = read.xlsx(file_paths_wage)

print(head(data_wage))

