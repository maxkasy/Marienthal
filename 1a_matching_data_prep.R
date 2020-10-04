###### Data preparation for matching

### 0. merge data sets that were received separately ---------------------------------

path_1 = "../Marienthal_TeilnehmerInnen-Daten/"
path_2 = "../XT_001_MAGMA_TN/6_plus_"


files_used = c("Leistungsbezug_TeilnehmerInnen.dsv",
               "Arbeitsmarktstatus_mon_uni_status_int_TeilnehmerInnen.dsv",
               "Arbeitslose_TeilnehmerInnen.dsv")

persons_dropped = c(1920209, 76914426)

for (filename in files_used[1:2]) {
  data_1 = paste(data_path, path_1, filename, sep = "") %>% 
    read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
  data_2 = paste(data_path, path_2, filename, sep = "") %>% 
    read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ","))
  
  bind_rows(data_1, data_2) %>%
    filter((PST_KEY != persons_dropped[1]) &
           (PST_KEY != persons_dropped[2])) %>%
    write_csv(paste(data_path, filename, sep = ""))
}

filename = files_used[3]
data_1 = paste(data_path, path_1, filename, sep = "") %>% 
  read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ",")) %>% 
  select(-BERUF) # to avoid type conversion issues
data_2 = paste(data_path, path_2, filename, sep = "") %>% 
  read_delim(delim = ";", locale = locale(encoding = "latin1", decimal_mark = ",")) %>% 
  select(-BERUF) # to avoid type conversion issues

bind_rows(data_1, data_2) %>%
  filter((PSTNR != persons_dropped[1]) &
           (PSTNR != persons_dropped[2])) %>%
  write_csv(paste(data_path, filename, sep = ""))

### 1. benefit receipt (TAGSATZLEIST) ---------------------------------

# reading in benefits file from source data
file_path = paste(data_path,
                  "Leistungsbezug_TeilnehmerInnen.dsv",
                  sep = "")
benefits =
  read_csv(file_path)

# for each participant (indexed by PST_KEY), only keep most recent (as indicated by STICHTAG) row of raw data
# and select variables
participants_benefits =
  benefits %>%
  mutate(PST_KEY = as.integer(PST_KEY),
         STICHTAG = dmy(STICHTAG),
         TAGSATZLEIST = as.integer(TAGSATZLEIST)) %>%
  group_by(PST_KEY) %>%
  arrange(STICHTAG) %>%
  slice(n()) %>%
  ungroup() %>%
  select(PST_KEY, STICHTAG, TAGSATZLEIST) %>%
  rename(PSTNR = PST_KEY, # rename to PSTNR for later merging
         BENEFIT_LEVEL = TAGSATZLEIST)

### 2. work history (days EMPLOYED within past 10 years) ---------------------------------

# reading in work history file from source data
file_path = paste(data_path,
                  "Arbeitsmarktstatus_mon_uni_status_int_TeilnehmerInnen.dsv",
                  sep = "")
work_history =
  read_csv(file_path) %>%
  rename(PSTNR = PST_KEY) # rename to PSTNR for merging)

# aggregate PK_E_L4 to PK_E_L1  for broader work status categories
participants_work_history = work_history %>%
  mutate(
    EMPLOYED = as.integer((STATUS != "AL") &
                            (STATUS != "D2") &
                            (STATUS != "SC") &
                            (STATUS != "LS") &
                            (STATUS != "SF") &
                            (STATUS != "SR")
    ),
    BEGINN = pmax(dmy(BEGINN), dmy("31.07.2010")),
    # we censor all spells to this start date, so spells starting earlier are partially counted
    ENDE = dmy(ENDE)
  ) %>%
  select(PSTNR, BEGINN, ENDE, EMPLOYED) %>%
  filter(ENDE > dmy("31.07.2010")) %>% #  restrict data to past 10 years
  mutate(duration = ENDE - BEGINN) %>%
  group_by(PSTNR, EMPLOYED) %>%
  summarise(UE_DAYS = as.integer(sum(duration)), ue_spells = n()) %>% # sum days of being registered as a job seeker
  filter(EMPLOYED == 0) %>% # Keep only unemployment spells
  select (-c(EMPLOYED))



### 3. Main covariate file and merge ---------------------------------

# reading in participant file from source data
file_path = paste(data_path,
                  "Arbeitslose_TeilnehmerInnen.dsv",
                  sep = "")
participants_raw =
  read_csv(file_path)

# for each participant (indexed by PSTNR), only keep most recent (as indicated by STICHTAG) row of raw data
participants =
  participants_raw %>%
  mutate(PSTNR = as.integer(PSTNR),
         STICHTAG = dmy(STICHTAG)) %>%
  group_by(PSTNR) %>%
  arrange(STICHTAG) %>%
  slice(n()) %>%
  ungroup() %>%
  mutate(
    MIG = as.integer((MIGRATIONSHINTERGRUND != "-")),
    MALE = as.integer(GESCHLECHT == "M"),
    BILDUNG = as.integer((AUSBILDUNG != "PS") & (AUSBILDUNG != "PO")), # more than Pflichtschule
    EINSCHRAENKUNG = as.integer(VERMITTLUNGSEINSCHRAENKUNG != "-") # job relevant health issues
  ) %>%
  left_join(participants_benefits, by = "PSTNR") %>%  # merge with additional covariates for matching
  left_join(participants_work_history, by = "PSTNR")

participants %>% 
  write_csv(paste(data_path,
                  "participants_merged.csv",
                  sep = ""))
