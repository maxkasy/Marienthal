# Overview of code for our Job-guarantee pilot evaluation


## Treatment assignment

The master file for treatment assignment is **pairwise_matching.R**.

This master file first calls **matching_data_prep.R** to prepare the data of the pilot participants for matching.
Data are prepared based on "Leistungsbezug_TeilnehmerInnen.dsv" (for benefit_receipt as a proxy of prior income),
"Arbeitsmarktstatus_mon_uni_status_int_TeilnehmerInnen.dsv" (for construction of total days unemployed in the last 10 years), and "Arbeitslose_TeilnehmerInnen.dsv" (for a series of further demographics, as registered at the last available date).

In **pairwise_matching.R**, the package nbpMatching is then used for pairwise matching and random assignment of treatment within pairs.
The script then exports "TeilnehmerInnen_Welle_1.csv" and "TeilnehmerInnen_Welle_2.csv" to the "Data/" subfolder, which are used by the implementing partner organization for assigning participants to waves.

Lastly, **matching_quality_checks.R** is invoked to run a series of descriptive checks and produces some visual summaries of the quality of matches which are also stored in the "Data" subfolder.


## Construction of synthetic control


## Inference for pairwise randomized sample


## Permutation inference for synthetic control