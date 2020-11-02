# Code for *Employing the unemployed of Marienthal: Evaluation of a guaranteed job program*

The master file for preparation of both the pairwise randomized treatment assignment, and for construction of the synthetic control, is **0_master.R**.
All output (tables and figures) produced by these scripts is available in the *Data* subfolder.


## 1. Pairwise matching and treatment assignment

The master file first calls **1a_matching_data_prep.R** to prepare the data of the pilot participants for matching.
Data are prepared based on *Leistungsbezug_TeilnehmerInnen.dsv* (for benefit_receipt as a proxy of prior income),
*Arbeitsmarktstatus_mon_uni_status_int_TeilnehmerInnen.dsv* (for construction of total days unemployed in the last 10 years), and *Arbeitslose_TeilnehmerInnen.dsv* (for a series of further demographics).

In **1b_pairwise_matching.R**, the package *nbpMatching* is then used for pairwise matching and random assignment of treatment within pairs.
This script exports *TeilnehmerInnen_Welle_1.csv* and *TeilnehmerInnen_Welle_2.csv* to the *Data/* subfolder, which are used by the implementing partner organization for assigning participants to waves.

Lastly, **1c_matching_quality_checks.R** is invoked to run a series of descriptive checks and produces some visual summaries of the quality of matches which are also stored in the *Data* subfolder.


## 2. Construction of the synthetic control

In the second step, the master file calls **2a_synth_data_prep.R** to prepare the data for the construction of the municipality-level synthetic control.
*2a_synth_data_prep.R* prepares 
1) the cross-section data on the unemployed, (2) the longitudinal data on the unemployed, (3) the cross-section data on the working age population, (4) the longitudinal data on the working age population, (5) the mean wage level, and (6) the communal tax. 

(1) and (2) are from the AMS internal registry (*Arbeitsmarktdatenbank*), (3), (4) and (5) are from the social security registry (via *AMS BMAFJ Erwerbskarrierenmonitoring*  or *AMDB*), and (6) is from the national statistical agency (*STATcube - Statistische Datenbank* of Statistik Austria). 
In step (7), the script merges all variables constructed and exports "municipalities_merged.csv" to the "Data/" subfolder, which is used in the next step to construct the synthetic control.

In **2b_synthetic_controls.R**, a subset of 26 municipalities is selected which are closest to Gramatneusiedl in terms of Mahalonobis distance.
The package *Synth* is then used to construct the synthetic control based on these 26 municipalites.
The package *furrr* is used for parallelizing permutation inference.

Lastly, **2c_synth_figures.R** prepares tables and visual summaries for evaluation of the synthetic control. All output is stored in the *Data* subfolder.



