# AMS Datensatz Notes

## Summary Variables - To Dos

### benefit_receipt:
1. Leistungsbezug_TeilnehmerInnen.dsv
2. Höhe des letzten Bezugs (Tagsatzleistung)

Alternativ:
(2. Leistungsart auf HAUPTKAT_LFNR aggregieren - bzw. irrelevant, wenn wir nur Höhe verwenden)
1. Durchschnittliche Höhe über die letzten 5 Jahre (Tagsatzleistung (?))
- Messung der Dauer des Leistungsbezugs muss mit AMS abgelärt werden (siehe Q&A).

### work history
1. Arbeitsmarktstatus_mon_uni_status_int_TeilnehmerInnen.dsv
2. PK_E_L4 auf PK_E_L1 aggregieren
3. Dauer (Tage) von AM (AMS-Vormerkung) Zeiten der letzten 10 Jahre ausrechnen und als summary variable verwenden: AM-dauer

### health
Unklar, ob die Dauer der Krankenstandstage o.ä. über Leistungen ermittelt werden kann.

- gibt es Meldung für Krankenstandsmeldung?

### vermittlungen
wo ist die tabelle?


## Fragen an AMS

Variablen:
 vermittlungen

health. sie schicken info
(Info ist, was Personen angegeben haben)

Einteilung an Gottfried schicken.

Vormerkdauer ist in manchen Fällen sehr niedrig. Wie passt das mit LZB zusammen?
Inkludiert Vormerkdauer nur Tage seit letzter Schulung?
LZA: was bedeutet: keine LZA? Warum sind Personen mit keine LZA trotzdem Teil des Programmes? Ist das auch erst ab der letzten Schulung gerechnet?
Unterschied zwischen Vormerkdauer & Geschäftsfalldauer. Vormkerkdauer wird nach SC zurück gestellt (wenn länger als 4 Wochen in SC).
Geschäftsfalldauer. Vormerkdauer nur bedingt relevant für uns. LZA wichtig für uns.

Um 4 stellige Codes incl. 0 in R zu laden (für NACE & Berufsgruppen):
column_class()
beruf = character
nace = character

NACE & Beruf in Matching? Nein.

GKZ: 1 Person ist laut GKZ nicht in Gramat Neusiedl sondern in Schwechat wohnhaft.
Warum ist sie inkludiert? Wsl. Umzug passiert. -> AMS NÖ fragen.
Schicke PSTNR per mail an Gottfried.

Auf Excel Dimensionstabellen "tab mon_uni_status_dim" BEZ_E_L4 durchgehen.

- in welchen Tabellen sind Daten zu 
1. Vermittlungen, die in der Dimensionstabelle in den sheets "pst_vermittlungen_bus_...“ erklärt werden.

Was ist der Unterschied zwischen Beihilfen und Leistungen?
Beihilfen: Kosten für aktive Leistungen an Betroffene (z.b. Kurskosten)?
Leistungen: passive Leistungen an Betroffene?

### FSB_TeilnehmerInnen.dsv
--> Führerschein B Ja/Nein (vl. auch nur eine Teilmenge). Führerschein müsste in Interview Fragen aufgenommen werden. aktuellste Info.

- Unklar, was diese Tabelle zeigt.
- Warum sind nur 32 observations?
- Zeitstempel und SW bei allen ident.

### Leistungsbezug_TeilnehmerInnen.dsv - benefits

Was bedeutet:
1. Anfallstag: Tag an dem Leistung zu greifen beginnt.
2. Höchstausmaß: Enddatum des Leistungsbezugs. (Leistungen die über Jahr gehen sind evtl. nicht miteinander verkettet)
3. Grundbetrag: Bemessungsgrundlage (vom Tagsatz), also Einkommen auf Basis dessen der Tagsatz ausgerechnet wird.
4. Tagsatzleistung: beinhaltet auch andere Zuschläge und Abschläge (z.b. für Familien). Hohe Korrelation von 96-98% mit Grundbetrag. (1. Juli Stichtag für Berechnungsbasis)

- sind auch mehrere Leistungen parallel inkludiert, wie bei Beihilfen? Nein, nur bei Beihilfen.
- Warum sind mehrere Observations zu unterschiedlichen Stichtagen mit allen anderen Variablen ident? Ist jede Observation ein Termin beim AMS? Jeder Monatsletzte ist eine Momentaufnahme des Kunden.

### Beihilfen_TeilnehmerInnen.dsv - benefits

- Können Krankenstandstage o.ä. über Leistungstabelle ermittelt werden?

Kurskosten + Kursnebenkosten + Arbeitsmartkförderung

- was genau zeigt diese Tabelle: Welche Ausgaben für die Person für div. aktive und passive Programme und Leistungen getätigt wurden?
- mehrere parallel
- unklare Bezeichnungen in Dimensionstabellen

Vorschlag: für Matching nicht verwenden, da es nicht klar ist, in welcher Form die Information predictive sein soll.

## Data Overview

### NACE_hv_dg_konto_TeilnehmerInnen.dsv

- nicht verwenden, da unklar in welcher Form vergangene Beschäftigung nach Sector predictive sein soll.

### Arbeitslose_TeilnehmerInnen.dsv

Falls verwendet:
- Nace4 in Nace2 aggregieren
- Beruf6 in Beruf2 aggregieren


