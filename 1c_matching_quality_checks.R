library(kableExtra) # for table export
library(broom) # for tidying tables
library(patchwork) # for creating compound plots

# sanity checking the pairwise treatment assignment -----
print(participant_assignment_full)

# t-tests for equality of covariate means across waves -----
participant_assignment_full %>%
    select(-c(PSTNR, match, match_row)) %>%
    pivot_longer(c(MALE,PEALTER,MIG,BILDUNG,EINSCHRAENKUNG,BENEFIT_LEVEL,UE_DAYS),
    names_to = "Covariate") %>%
    mutate(Covariate = factor(Covariate,
        levels = c("MALE","PEALTER","MIG","BILDUNG","EINSCHRAENKUNG","BENEFIT_LEVEL","UE_DAYS"),
        labels = c("Male","Age","Migration Background","Education","Health condition","Benefit level","Days unemployed"))) %>% 
    group_by(Covariate) %>%
    rstatix::t_test(value ~ treatment_wave, detailed = T) %>%
    ungroup() %>%
    select(Covariate, estimate1, estimate2, estimate, statistic, p)  %>%
    kable(col.names = c("Covariate","Mean wave 1","Mean wave 2","Difference","T-statistic","P-value"),
        row.names = F,
        digits = 3,
        format = "latex",
        booktabs = TRUE,
        escape = F, 
        linesep = "") %>%
    write(paste0(data_out, "wave_comparison_ttests.tex"))




# plotting match pairs -----
pd = position_dodge(0.3) # for dodging binary variables horizontally, to avoid overlap

p1 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = MALE, y = UE_DAYS, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0, 1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "Male", y = "Days unemployed") +
    theme(legend.position = "none")

p2 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = MIG, y = PEALTER, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0, 1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "Migration background", y = "Age") +
    theme(legend.position = "none")

p3 = participant_assignment_full %>%
    mutate(pair_indicator = factor(pmin(PSTNR, match))) %>%
    ggplot(aes(x = BILDUNG, y = BENEFIT_LEVEL, color = pair_indicator)) +
    geom_point(position = pd) +
    geom_line(position = pd) +
    scale_color_viridis_d() +
    scale_x_continuous(breaks = c(0, 1), labels = c("No", "Yes")) +
    theme_minimal() +
    labs(x = "More than Pflichtschule", y = "Benefit level") +
    theme(legend.position = "none")


ggsave("Data/match_plots.png",
       p1 + p2 + p3,
       width = 9,
       height = 3)