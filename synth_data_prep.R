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

myvars <- c("GKZ", "STICHTAG", "LZBL", "n" )

data_LZBL_AL <- data_LZBL_AL[myvars] %>%
  filter((LZBL != "N" ))

# create annual averages
# alternative way using openair package: timeAverage(data_LZBL_AL, avg.time = "year")
data_LZBL_AL$year <- data_LZBL_AL$STICHTAG %>%
  format("%Y")

mean_LZBL_AL <- data_LZBL_AL %>% 
  group_by(GKZ, year) %>% 
  summarize(ue_long = mean(n))


#### Population - cross section ####



#### Population - longitudinal ####



#### Wages - cross section ####


#### merge ####

municipalities =
  mean_LZBL_AL %>%
    group_by(GKZ, year) %>%
  left_join(mean_age_AL, by = c("GKZ", "year"))  # merge with additional covariates for synthetic control

municipalities %>% 
  write_csv(paste(data_out,
                  "municipalities_merged.csv",
                  sep = ""))

