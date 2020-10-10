# Synth\_Data\_Notes

## Variable Description

types of variables: - **reported** - aggregated - *computed*

**GKZ** = Gemeindekennzahl

### SV data

includes workingage population

## longitudinal

-   *AM* = number of unemployed; annual average of number at monthly reference date, aggregated from: AMS Qualifikation (AQ) Arbeitslos laut HV (AO) sonstige AMS Vormerkung (AS) Arbeitslos (AL)

-   *BE* = number of employed; annual average of number at monthly reference date, aggregated from: Nicht geförderte Unselbstständige (NU) Geförderte Unselbstständige (GU) Selbststänidge (SB) Geringfügige Beschäftigung (BE) - in official definition this would be part of SO (try both)

-   *SO* = number of inactive; annual average of number at monthly reference date, aggregated from: Gesichert Erwerbsfern (GO) Sonstig Erwerbsfern (SE) Tod bzw. keine Daten (UN)

-   *POP\_workingage* = AM + BE + SO

-   *UE\_rate\_U3* = unemployment rate; headline: AM/(BE+AM)

-   *UE\_rate\_tot* = unemployment rate of total working age pop; AM/(BE+AM+SO)

-   *EMP\_rate\_tot* = employment rate; BE/(BE+AM+SO)

-   *Inactive\_rate\_tot* = inactive rate; SO/(BE+AM+SO)

## cross-section 2019/12 or 2020/07

*age\_mean\_POP* = mean age

-   firmsize\_large = \>249 employees

-   firmsize\_middle = 10-249 employees

-   firmsize\_small = \<10 employees

-   *firmsize\_large\_POP\_by\_tot\_POP* = firmsize\_large / (firmsize\_large + firmsize\_middle + firmsize\_small )

-   *firmsize\_middle\_POP\_by\_tot\_POP* = firmsize\_middle / (firmsize\_large + firmsize\_middle + firmsize\_small )

-   *firmsize\_small\_POP\_by\_tot\_POP* = firmsize\_small / (firmsize\_large + firmsize\_middle + firmsize\_small )

-   edu\_high\_POP = ISCED 5-6

-   edu\_low\_POP = ISCED 1-2

-   edu\_middle\_POP = ISCED 3-4

-   edu\_NA\_POP = AUSBILDUNG missing; "keine Angabe"

-   *edu\_high\_POP\_by\_tot\_POP* = edu\_high\_POP / (edu\_high\_POP + edu\_middle\_POP + edu\_low\_POP + edu\_NA\_POP)

-   *edu\_middle\_POP\_by\_tot\_POP* = edu\_middle\_POP / (edu\_high\_POP + edu\_middle\_POP + edu\_low\_POP + edu\_NA\_POP)

-   *edu\_low\_POP\_by\_tot\_POP* = edu\_low\_POP / (edu\_high\_POP + edu\_middle\_POP + edu\_low\_POP + edu\_NA\_POP)

-   **men\_POP** = men

-   **women\_POP** = women

-   *men\_POP\_by\_tot\_POP* = men\_POP / (men\_POP + women\_POP)

-   Ausländer = foreign citzenship

-   Inländer = Austrian citzenship

-   *foreign\_nationality\_POP\_by\_tot\_POP* = Ausländer / (Ausländer + Inländer)

-   mig\_POP = first (MIG1) or second (MIG2) generation migration background

-   no\_mig\_POP = no migration background

-   *mig\_POP\_by\_tot\_POP* = mig\_POP / (mig\_POP + no\_mig\_POP)

-   care\_POP = person with a care responsibility for a child \<15

-   no\_care\_POP = person without a care responsibility for a child \<15

-   *care\_POP\_by\_tot\_POP* = care\_POP / (care\_POP + no\_care\_POP)

-   *mean\_wage* = 2019 for 12 months, 2020 for the first first 5 months

### AMS data

## longitudinal

-   ue\_long = number of long term unemployed; annual average of number at monthly reference date

-   ue\_short = number of short term unemployed; annual average of number at monthly reference date

-   ue\_tot = number of long + short term unemployed

-   *ue\_short\_by\_ue\_tot* = short term unemployed as a share of all unemployed: ue\_short/(ue\_long+ue\_short)

-   *ue\_long\_by\_ue\_tot* = long term unemployed as a share of all unemployed: ue\_long/(ue\_long+ue\_short)

-   *ue\_short\_by\_pop* = short term unemployed as a share of total working age pop: ue\_short/(BE+AM+SO)

-   *ue\_long\_by\_pop* = long term unemployed as a share of total working age pop: ue\_long/(BE+AM+SO)

-   disability\_AL = any kind of VERMITTLUNGSEINSCHRÄNKUNG recorded (A - Laut AMS,B - Beides (I u. L), I - Begünstigt nach BeinstG u./o. OFG, L- Begünstigt nach LBehG, P - Personen mit Behindertenpass)

-   no\_disability\_AL = no VERMITTLUNGSEINSCHRÄNKUNG recorded

-   *ue\_disability\_by\_ue\_tot* = disability\_AL / (disability\_AL + no\_disability\_AL)

## cross-section 2019/12 or 2020/07

-   *age\_mean\_AL* = mean age

-   edu\_high\_AL = ISCED 5-6

-   edu\_low\_AL = ISCED 1-2

-   edu\_middle\_AL = ISCED 3-4

-   edu\_NA\_AL = AUSBILDUNG missing; "XX" or "--"

-   *edu\_high\_AL\_by\_tot\_AL* = edu\_high\_AL / (edu\_high\_AL + edu\_middle\_AL + edu\_low\_AL + edu\_NA\_AL)

-   *edu\_middle\_AL\_by\_tot\_AL* = edu\_middle\_AL / (edu\_high\_AL + edu\_middle\_AL + edu\_low\_AL + edu\_NA\_AL)

-   *edu\_low\_AL\_by\_tot\_AL* = edu\_low\_AL / (edu\_high\_AL + edu\_middle\_AL + edu\_low\_AL + edu\_NA\_AL)

-   *poor\_german* = \<=A2

-   *ok\_german* = \>=B1

-   *poor\_german\_AL\_by\_tot\_AL* = poor\_german / (ok\_german + poor\_german)

-   **men\_AL** = men

-   **women\_AL** = women

-   *men\_AL\_by\_tot\_AL* = men\_AL / (men\_AL + women\_AL)

-   mig\_AL = first (MIG1) or second (MIG2) generation migration background

-   no\_mig\_AL = no migration background

-   *mig\_AL\_by\_tot\_AL* = mig\_AL / (mig\_AL + no\_mig\_AL)

-   **Ubenefit\_daily\_mean2011\_2020** = Tagsatz: unemployment benefit level per day as an average for 2011-2020

## To Decide

-   Do we use the pre-corona data from December 2019, or latest data from July 2020? (try with both or use both if no limit to variables) ausprobieren

-   Do we take all variables suggested below for unemployed and for population or only a subset? (depends on how many variables would be too many) zu viele Variablen könnten zu overfitting führen.

-   Zeitreihen monatlich oder jährlich wsl. jährlich

-   Should we include AMS geförderte Beschäftigung (GU) as part of the employed to compute municipal unemployment rates? (Perhaps yes...) Perhaps employed.

-   Anzahl AL (monatlich seit 2011): mean annual unemployment number (better would be unemployment rate but we would need the number of employees for this). Should we request employment data from AMS or use the employment data from AMDB? ASK AMS for additional data.

-   For longitudinal data AL and Bevölkerung: do we want the the total number of unemployed or the unemployment rate? Aiming to track similar sized municipalities would speak for total number, while aiming to track similar labour market conditions would speak for the unemployment rate. Maybe we should use both if we don't run into problems of having too many variables? ASK AMS for additional data.

-   Wages and Employment from AMDB: aggregate to mean annual values or use monthly changes for past 17 months to track evolution?

-   Brauchen wir Tabelle 2011-01\_bis\_2020-08\_AL\_NOE\_TAGSATZ.dsv über Zeitraum oder reicht eindimensional? Nein

## AL - suggestions for variables to compute

### Cross-section AL

Shares are implied as shares of total unemployed per town and reference date.

-   Alter: mean weighted by N
-   Ausbildung: \> Pflichtschule share of total AL
-   Beruf: drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has 10 categories and it's not straightforward how they could be combined)
-   Deutsch: share \>A2 (or B2? maybe check with AMS practicioner what is most useful.) K stands for no language skills in German.
-   Geschlecht: share male
-   LZBL: share long term unemployed
-   Migrationshintergrund: share migration background (MIG1 + MIG2)
-   Nace (sector): drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has multiple categories and it's not straightforward how they could be combined)
-   Tagsatz: mean weighted by N
-   Vermittlungseinschränkung: share with any disability

### Longitudinal AL

-   LZBL: long-term unemployed as a share of active population (once we get the data) (OR number of total unemployed) (OR total number of long-term unemployed?) on an annual basis (or monthly possible?)
-   Tagsatz: mean unemployment benefits on an annual basis (or monthly possible?)
-   Vermittlungseinschränkung: total number (or share) or unemployed with a disability

## Bevölkerung - suggestions for variables to compute

### Cross-section Pop

Shares are implied as shares of total population per town and reference date.

-   Alter: given age in 5 year brackets. Take average age weighted by N.
-   Dienstgebergröße: employer with \> 249 employees (SME) as a share of total Pop
-   EU Gliederung: citizenship by country group - drop
-   GB (= Anzahl in paralleler geringfügiger Beschäftigung): drop
-   Geschätzte Ausbildung: share \>= Matura (AHS+BHS+Uni/FH) (or share \> Pflichtschule wie bei AL)
-   Geschlecht: share male
-   Ausländer: share of non-Austrians (perhaps drop and only use migration background)
-   KRZ Geld (= Wochengeld, Karenzgeld, Kinderbetreuungsgeld): drop
-   Migrationshintergrund: share with migration background (Mig1 + Mig2)
-   NACE: How about computing the share of public sector employment? Otherwise drop (no idea how to usefully aggregate it into 1 variable as even 1 digit level still has multiple categories and it's not straightforward how they could be combined).
-   Uni\_status: unemployment rate: (AL+AO+AQ+AS)/(NU+SE+GU) (- should we include AMS geförderte Beschäftigung (GU) for the employed?)
-   Versorgungspflicht: drop. Alternatively: share with care responsibility (either registered by AMS or through receiption of Kindergeld subsidy. For men only registered if they have taken paternity leave.)

### Longitudinal Pop

-   Anzahl AL (monatlich seit 2011): mean annual unemployment number (better would be unemployment rate but we would need the number of employees for this)

## Wages - suggestions for variables to compute

We have monthly observations for January 2019 to May 2020.

-   mean annual wage for 2019 (Or monthly from Jan 2019 to May 2020?)
-   mean number of total employed for 2019 (or monthly from Jan 2019 to May 2020?)
