library(kableExtra) # for table export

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
    
    municipalities_synth_tables$tab.w %>%
        arrange(desc(w.weights)) %>%
        head(n = non_zero_weights) %>%
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
}


check_synth(municipalities_synth_Gramatneusiedl)



plot_gap = function(ms) {
    year = ms$municipalities_synth_prepared$tag$time.plot %>%
        lubridate::ymd(truncated = 2L)
    
    tibble(
        Year = year,
        Col = "Actual outcome",
        Y = ms$municipalities_synth_prepared$Z1
    ) %>%
        bind_rows(
            tibble(
                Year = year,
                Col = "Synthetic outcome",
                Y = ms$municipalities_synth_prepared$Z0 %*%
                    ms$municipalities_synth_out$solution.w
            )
        ) %>%
        ggplot(aes(x = Year, y =  Y, color = Col)) +
        geom_path() +
        scale_color_manual(values = c("firebrick", "gray70")) +
        scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
        expand_limits(y = 0) +
        theme_minimal() + 
        theme(legend.position="top") +
        labs(color = "",
             y = "Outcome",
             title = "Actual outcome and synthetic control outcome")
    
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
            alpha = (GKZ == Gramatneusiedl)
        )) +
        geom_path() +
        scale_color_manual(
            values = c("gray70", "firebrick"),
            labels = c("Other", "Gramatneusiedl")
        ) +
        scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
        scale_alpha_manual(values = c(.25,1), guide = 'none') + 
        theme_minimal() +
        theme(legend.position="top") +
        labs(color = "Municipality",
             title = "Gap in actual outcome versus synthetic control outcome")
}


ggsave(
    "Data/Synthetic_permutation_inference.png",
    plot_permutation_trajectories(Gramatneusiedl),
    width = 7,
    height = 4
)
