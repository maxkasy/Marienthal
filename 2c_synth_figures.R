library(kableExtra) # for table export

variable_names = c(
  # "Unemp/pop",
  "Working age pop",
  "Long term unemp/pop",
  "Inactive/pop",
  "Mean age",
  "Share small firms",
  "Share mid firms",
  "Share low edu",
  "Share mid edu",
  "Share men",
  "Share migrant",
  "Share care resp",
  "Mean wage",
  "Mean age unemp",
  "Low edu/unemp",
  "Mid edu/unemp",
  "Poor German/unemp",
  "Men/unemp",
  "Migrant/unemp",
  "Health cond/unemp",
  "Communal tax/pop",
  # additional 2020 variables
  "Lt ue/pop 2020",
  "Inactive/pop",
  "Mean wage",
  "Mean age ue",
  "Low edu/ue",
  "Mid edu/ue",
  "Poor German/ue",
  "Health cond/ue"
)

#check the names align with the variables
tmp = tibble(a = c(matching_variables[-1], matching_variables_2020_names), b = variable_names)

# Checking solution of synth
synth_outcome_gap = function(ms) {
  ms$municipalities_synth_prepared$Z0 %*%
    ms$municipalities_synth_out$solution.w -
    ms$municipalities_synth_prepared$Z1
}

check_synth = function(ms) {
  ratio_covariates =
    ms$municipalities_synth_prepared$X0 %*%
    ms$municipalities_synth_out$solution.w /
    ms$municipalities_synth_prepared$X1
  
  gaps_outcomes = synth_outcome_gap(ms)
  
  print(ratio_covariates)
  print(gaps_outcomes)
  
  municipalities_synth_tables =
    synth.tab(
      dataprep.res = ms$municipalities_synth_prepared,
      synth.res = ms$municipalities_synth_out
    )
  
  non_zero_weights = sum(ms$municipalities_synth_out$solution.w > .005)
  
  non_zero_municipalities = municipalities_synth_tables$tab.w %>%
    arrange(desc(w.weights)) %>%
    head(n = non_zero_weights)
  
  non_zero_municipalities %>%
    kable(
      col.names = c("Weight", "Municipality", "Identifier"),
      row.names = F,
      digits = 3,
      format = "latex",
      booktabs = TRUE,
      escape = F,
      linesep = ""
    ) %>%
    write("Data/synthetic_control_weights.tex")
  
  
  # Build and print table of variables for control municipalities
  Gramatneusiedl_variables = t(ms$municipalities_synth_prepared$X1)  %>%
    as_tibble() %>%
    mutate(GEMEINDE = "Gramatneusiedl")
  
  control_variables = t(ms$municipalities_synth_prepared$X0) %>%
    as_tibble(rownames = "unit.numbers") %>%
    mutate(unit.numbers = as.integer(unit.numbers)) %>%
    right_join(non_zero_municipalities, by = "unit.numbers") %>%
    select(-c("w.weights", "unit.numbers")) %>%
    rename(GEMEINDE = unit.names)
  
  # Insert synthetic control values for comparison
  synthetic_variables = t(ms$municipalities_synth_prepared$X0 %*%
                            ms$municipalities_synth_out$solution.w) %>%
    as_tibble() %>%
    mutate(GEMEINDE = "Synthetic control")
  
  table_variables = bind_rows(Gramatneusiedl_variables,
                              synthetic_variables,
                              control_variables) %>%
    mutate(POP_workingage = as.integer(POP_workingage),
           mean_wage = as.integer(mean_wage),
           special.mean_wage.2020 = as.integer(special.mean_wage.2020)) %>%
    select(c("GEMEINDE", matching_variables[-1], matching_variables_2020_names))
  
  # Rename columns for printing
  names(table_variables) = c("Gemeinde", variable_names)
  
  # Split into sub-tables for page width reasons
  sub_tables = list(1:8, c(1, 9:15), c(1, 16:22), c(1, 23:29)) %>%
    map(~ table_variables[, .x])
  
  sub_kables = map(
    1:4,
    ~ sub_tables[[.x]] %>%
      kable(
        row.names = F,
        digits = 3,
        format = "latex",
        booktabs = TRUE,
        escape = F,
        linesep = c("", "\\addlinespace", "", "", "", "", "", "", "")
      ) %>%
      str_replace_all("_", " ")
  )
  
  paste(
    substring(
      sub_kables[[1]],
      first = 1,
      last = nchar(sub_kables[[1]]) - 13
    ),
    substring(
      sub_kables[[2]],
      first = 28,
      last = nchar(sub_kables[[2]]) - 13
    ),
    substring(
      sub_kables[[3]],
      first = 28,
      last = nchar(sub_kables[[3]]) - 13
    ),
    "\\addlinespace",
    "\\multicolumn{8}{c}{\\textbf{2020}}\\\\",
    "\\addlinespace",
    substring(sub_kables[[4]], first = 28),
    sep = ""
  ) %>%
    write("Data/synthetic_control_variables.tex")
}


check_synth(municipalities_synth_Gramatneusiedl)



plot_gap = function(ms) {
  year = ms$municipalities_synth_prepared$tag$time.plot %>%
    lubridate::ymd(truncated = 2L)
  
  tibble(
    Year = year,
    Col = "Actual",
    Y = ms$municipalities_synth_prepared$Z1
  ) %>%
    bind_rows(
      tibble(
        Year = year,
        Col = "Synthetic",
        Y = ms$municipalities_synth_prepared$Z0 %*%
          ms$municipalities_synth_out$solution.w
      )
    ) %>%
    ggplot(aes(x = Year, y =  Y, color = Col)) +
    geom_path() +
    scale_color_manual(values = c("firebrick", "gray70")) +
    scale_x_date(
      date_breaks = "1 year",
      date_labels = "%Y",
      expand = expansion(mult = 0)
    ) +
    expand_limits(y = 0) +
    scale_y_continuous(expand = expansion(mult = 0)) +
    theme_minimal() +
    theme(legend.position = "top",
          plot.margin = unit(c(1, 1, 1, 1), "cm")) +
    labs(color = "",
         y = "Unemployment",
         title = "Actual unemployment and synthetic control unemployment")
  
}

ggsave(
  "Data/Synthetic_control_gap.png",
  plot_gap(municipalities_synth_Gramatneusiedl),
  width = 7,
  height = 4
)



plot_permutation_trajectories = function(GKZ) {
  all_gaps =
    map(
      1:length(all_identifiers),
      ~ municipalities_synth_all[[.x]] %>%
        synth_outcome_gap %>%
        as_tibble %>%
        mutate(
          Year = lubridate::ymd(2011:2020, truncated = 2L),
          GKZ = all_identifiers[.x]
        )
    ) %>%
    bind_rows() %>%
    rename(Gap = w.weight)

  all_gaps %>%
    ggplot(aes(
      x = Year,
      y = Gap,
      color = (GKZ == Gramatneusiedl),
      alpha = (GKZ == Gramatneusiedl),
      group = GKZ 
    )) +
    geom_hline(yintercept = 0, alpha = .7) +
    geom_line() +
    scale_color_manual(
      values = c("gray70", "firebrick"),
      labels = c("Other", "Gramatneusiedl")
    ) +
    scale_x_date(
      date_breaks = "1 year",
      date_labels = "%Y",
      expand = expansion(mult = 0)
    ) +
    scale_y_continuous(expand = expansion(mult = 0)) +
    scale_alpha_manual(values = c(.33, 1), guide = 'none') +
    theme_minimal() +
    theme(legend.position = "top",
          plot.margin = unit(c(1, 1, 1, 1), "cm")) +
    labs(color = "Municipality",
         title = "Gap in actual unemployment versus synthetic control unemployment")
}


ggsave(
  "Data/Synthetic_permutation_inference.png",
  plot_permutation_trajectories(Gramatneusiedl),
  width = 7,
  height = 4
)
