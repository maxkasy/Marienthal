# Synth_Data_Notes

## Variable Description

types of variables:
- **reported**
- aggregated
- *computed*

**GKZ** = Gemeindekennzahl


### SV data
* AM = number of unemployed; annual average of number at monthly reference date, 
    aggregated from:
    AMS Qualifikation (AQ)
    Arbeitslos laut HV (AO)
    sonstige AMS Vormerkung (AS)
    Arbeitslos (AL)
* BE = number of employed; annual average of number at monthly reference date, 
aggregated from:
    Nicht geförderte Unselbstständige (NU)
    Geförderte Unselbstständige (GU)
    Selbststänidge (SB)
    Geringfügige Beschäftigung (BE) - in official definition this would be part of SO (try both)
* SO = number of inactive; annual average of number at monthly reference date, 
aggregated from:
    Gesichert Erwerbsfern (GO)
    Sonstig Erwerbsfern (SE)
    Tod bzw. keine Daten (UN)
* POP_workingage = AM + BE + SO
* *UE_rate_U3* = unemployment rate; headline: AM/(BE+AM)
* *UE_rate_tot* = unemployment rate of total working age pop; AM/(BE+AM+SO)
* *EMP_rate_tot* = employment rate; BE/(BE+AM+SO)
* *Inactive_rate_tot* = inactive rate; SO/(BE+AM+SO)

### AMS data
* ue_long = number of long term unemployed; annual average of number at monthly reference date
* ue_short = number of short term unemployed; annual average of number at monthly reference date
* *ue_tot* = number of long + short term unemployed
* *ue_short_share* = short term unemployed as a share of all unemployed: ue_short/(ue_long+ue_short) ue_short_by_ue_tot
* *ue_long_share* = long term unemployed as a share of all unemployed:  ue_long/(ue_long+ue_short) ue_long_by_ue_tot
* *ue_short_rate_tot* = short term unemployed as a share of total working age pop: ue_short/(BE+AM+SO) ue_short_by_pop
* *ue_long_rate_tot* = long term unemployed as a share of total working age pop: ue_long/(BE+AM+SO) ue_long_by_pop

* *age_mean* = mean age; 2019/12 or 2020/07


## Offene Fragen an AMS

wir wollen auch die interviewen, die raus fallen.

Tagsatz variable over time für AL: Nein

GB: check definition

Zeitreiehe für Bevölkerung im Erwerbsalter (1. Präferenz) oder Active population (um unemployment rate als zeitreihe auszurechnen) (2. Präferenz, idealerweise beides)

Data format: long: municipal-year level

Bis Mo: Longitudinal data set municipal-year level + 1 longitudinal + 1 cross-section variable

## To Decide

- Do we use the pre-corona data from December 2019, or latest data from July 2020? (try with both or use both if no limit to variables)
ausprobieren

- Do we take all variables suggested below for unemployed and for population or only a subset? (depends on how many variables would be too many)
zu viele Variablen könnten zu overfitting führen.

- Zeitreihen monatlich oder jährlich
wsl. jährlich

- Should we include AMS geförderte Beschäftigung (GU) as part of the employed to compute municipal unemployment rates? (Perhaps yes...)
Perhaps employed.

- Anzahl AL (monatlich seit 2011): mean annual unemployment number (better would be unemployment rate but we would need the number of employees for this). Should we request employment data from AMS or use the employment data from AMDB?
ASK AMS for additional data.

- For longitudinal data AL and Bevölkerung: do we want the the total number of unemployed or the unemployment rate? Aiming to track similar sized municipalities would speak for total number, while aiming to track similar labour market conditions would speak for the unemployment rate. Maybe we should use both if we don't run into problems of having too many variables?
ASK AMS for additional data.

- Wages and Employment from AMDB: aggregate to mean annual values or use monthly changes for past 17 months to track evolution?


- Brauchen wir Tabelle 2011-01_bis_2020-08_AL_NOE_TAGSATZ.dsv über Zeitraum oder reicht eindimensional?
Nein

## AL - suggestions for variables to compute

### Cross-section AL

Shares are implied as shares of total unemployed per town and reference date.

- Alter: mean weighted by N
- Ausbildung: > Pflichtschule share of total AL
- Beruf: drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has 10 categories and it’s not straightforward how they could be combined)
- Deutsch: share >A2 (or B2? maybe check with AMS practicioner what is most useful.) K stands for no language skills in German.
- Geschlecht: share male
- LZBL: share long term unemployed 
- Migrationshintergrund: share migration background (MIG1 + MIG2)
- Nace (sector): drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has multiple categories and it’s not straightforward how they could be combined)
- Tagsatz: mean weighted by N
- Vermittlungseinschränkung: share with any disability

### Longitudinal AL

- LZBL: long-term unemployed as a share of active population (once we get the data) (OR number of total unemployed) (OR total number of long-term unemployed?) on an annual basis (or monthly possible?)
- Tagsatz: mean unemployment benefits on an annual basis (or monthly possible?)
- Vermittlungseinschränkung: total number (or share) or unemployed with a disability

## Bevölkerung - suggestions for variables to compute

### Cross-section Pop

Shares are implied as shares of total population per town and reference date.

- Alter: given age in 5 year brackets. Take average age weighted by N.
- Dienstgebergröße: employer with > 249 employees (SME) as a share of total Pop
- EU Gliederung: citizenship by country group - drop
- GB (= Anzahl in paralleler geringfügiger Beschäftigung): drop
- Geschätzte Ausbildung: share >= Matura (AHS+BHS+Uni/FH) (or share > Pflichtschule wie bei AL)
- Geschlecht: share male
- Ausländer: share of non-Austrians (perhaps drop and only use migration background)
- KRZ Geld (= Wochengeld, Karenzgeld, Kinderbetreuungsgeld): drop
- Migrationshintergrund: share with migration background (Mig1 + Mig2)
- NACE: How about computing the share of public sector employment? Otherwise drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has multiple categories and it’s not straightforward how they could be combined).
- Uni_status: unemployment rate: (AL+AO+AQ+AS)/(NU+SE+GU) (- should we include AMS geförderte Beschäftigung (GU) for the employed?)
- Versorgungspflicht: drop. Alternatively: share with care responsibility (either registered by AMS or through receiption of Kindergeld subsidy. For men only registered if they have taken paternity leave.)

### Longitudinal Pop

- Anzahl AL (monatlich seit 2011): mean annual unemployment number (better would be unemployment rate but we would need the number of employees for this)

## Wages - suggestions for variables to compute

We have monthly observations for January 2019 to May 2020.

- mean annual wage for 2019 (Or monthly from Jan 2019 to May 2020?)
- mean number of total employed for 2019 (or monthly from Jan 2019 to May 2020?)