###### Data preparation for matching

### 1. benefit receipt (TAGSATZLEIST) ---------------------------------

# reading in benefits file from source data
file_path = paste(data_path,
                  "Leistungsbezug_TeilnehmerInnen.dsv",
                  sep = "")
benefits =
  read_delim(file_path,
             delim = ";",
             locale = locale(encoding = "latin1", decimal_mark = ","))

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
  read_delim(file_path,
             delim = ";",
             locale = locale(encoding = "latin1")) %>%
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
  read_delim(file_path,
             delim = ";",
             locale = locale(encoding = "latin1"))

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
