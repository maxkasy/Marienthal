library(kableExtra) # for table export
library(broom) # for tidying tables
library(patchwork) # for creating compound plots

# sanity checking the pairwise treatment assignment -----
print(participant_assignment_full)

wave_comparison =
    participant_assignment_full %>%
    group_by(treatment_wave) %>%
    summarise(
        male = mean(MALE),
        age = mean(PEALTER),
        migrant = mean(MIG),
        education = mean(BILDUNG),
        handycap = mean(EINSCHRAENKUNG),
        benefit_level = mean(BENEFIT_LEVEL),
        ue_days = mean(UE_DAYS)
    )

wave_comparison %>% 
    kable(row.names=F, digits=3,
          format="latex", booktabs = TRUE, escape = F) %>% 
    write("Data/wave_comparison.tex")

# t-tests for equality of covariate means across waves -----

t.test(MALE ~ treatment_wave, participant_assignment_full) %>% tidy() %>% 
bind_rows(t.test(PEALTER ~ treatment_wave, participant_assignment_full) %>% tidy()) %>% 
bind_rows(t.test(MIG ~ treatment_wave, participant_assignment_full) %>% tidy()) %>% 
bind_rows(t.test(BILDUNG ~ treatment_wave, participant_assignment_full) %>% tidy()) %>% 
bind_rows(t.test(EINSCHRAENKUNG ~ treatment_wave, participant_assignment_full) %>% tidy()) %>% 
bind_rows(t.test(BENEFIT_LEVEL ~ treatment_wave, participant_assignment_full) %>% tidy()) %>% 
bind_rows(t.test(as.integer(UE_DAYS) ~ treatment_wave, participant_assignment_full) %>% tidy()) 




# plotting match pairs -----
pd = position_dodge(0.3) # for dodging binary variables horizontally, to avoid overlap

p1 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = MALE, y = UE_DAYS, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0,1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "Male", y = "Days unemployed") +
    theme(legend.position = "none")

p2 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = MIG, y = PEALTER, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0,1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "Migration background", y = "Age") +
    theme(legend.position = "none")

p3 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = BILDUNG, y = BENEFIT_LEVEL, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0,1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "More than Pflichtschule", y = "Benefit level") +
    theme(legend.position = "none")


ggsave("Data/match_plots.png",
       p1 + p2 + p3,
       width = 9,
       height = 3)