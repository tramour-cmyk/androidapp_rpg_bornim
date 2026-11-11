# Glossar: unsere Begriffe

Vorgang 648 (Chef 08.11., 13:01–13:08: „für Menschen nutzbar. Selbsterklärend“; Kontext entscheidend, „Unterbegriff … zu dem Oberbegriff“). Je Sachgebiet ein Begriffsbaum: **gehört zu** (Oberbegriff) und **darunter** (Unterbegriffe); Spalte **nicht** nennt Wörter, die wir dafür nie benutzen. Am Ende Abkürzungen und ein Verzeichnis A–Z. Wird nicht laufend gepflegt: neue Begriffe trägt ein, wer sie einführt. **Fundstellen** zeigt das Werkzeug: `python3 tools/glossar.py <Begriff>` (Dateien, die ihn nennen); `python3 tools/glossar.py --pruefen` zählt, wo ein Wort aus „nicht“ noch steht.

Namen im Spiel (Völker, Zauber, Monster, Regelwerte) stehen nicht hier, sondern in `DESIGN-BRS.md` Abschnitt 12 „Namen“ (Entscheidung 24). Neue Spielbegriffe legt Homer fest.

## 1 Firma und Rollen

| Begriff | Bedeutung | gehört zu → darunter | nicht | steht in |
|---|---|---|---|---|
| **BornWire TCS** | unsere Firma; baut „Chroniken von Bornim“ | – → Chef, Rollen | – | `CLAUDE.md` „Wer wir sind“, `FIRMA.md` |
| **Chef** | der Nutzer; entscheidet Grundsätzliches, testet jeden Code vor `main` | BornWire TCS | – | `CLAUDE.md` „Rollen“ |
| **Rolle** | feste Aufgabe einer Sitzung: Sokrates, Homer, Perikles, Diogenes, Ford, Team Tom, Team Jerry | BornWire TCS → Sitzung | – | `CLAUDE.md` „Rollen“ |
| **Team Tom**, **Team Jerry** | die zwei Entwicklerrollen; Spike und Tuffy arbeiten als Zusatzentwickler in ihrem Team | Rolle | – | `ROLLE-ENTWICKLUNG.md` |
| **Sitzung** | eine laufende Claude-Code-Sitzung mit einer Rolle; jede Rolle gibt es genau einmal | Rolle → Übergabe, Nachfolger | Klon | `CLAUDE.md` „Wer wir sind“, `LISTE-RELEASE-NEUSTART.md` |
| **Zentrale** | Toms Account (Max), auf dem alle laufen | BornWire TCS | – | `CLAUDE.md` „Rollen“, `FIRMA.md` |
| **Niederlassung** | zweiter Account (Pro); ruht, nur noch als Gedanke | BornWire TCS | Ford 2 | `FIRMA.md` |
| **Helfer** | Unteragent einer Sitzung, prüft oder sieht an; urteilt nicht über Aussehen | Sitzung | – | `ROLLE-ENTWICKLUNG.md` |

## 2 Arbeit und Vorgänge

| Begriff | Bedeutung | gehört zu → darunter | nicht | steht in |
|---|---|---|---|---|
| **Vorgang** | eine Sache mit fester Nummer („Vorgang 72s.1“, in Meldungen „72s.1:“); sein Inhalt heißt Thema (Sitzungsname „<Vorgang>: <Thema>“, 436) | Vorgangsliste → Unternummer (7.1), Rückfrage (7a) | „Thema“ oder „Nummer“ für den Vorgang selbst, Blatt | `CLAUDE.md` „Nummern“ |
| **Vorgangsliste** | `LISTE-VORGAENGE.md`, je Vorgang eine Zeile mit Feldern; schreiben nur mit `vorgang.py` | – → Vorgang | – | `LISTE-VORGAENGE.md` |
| **Klasse** | **M** Muss, **K** Kür, **M?** (Perikles entscheidet) | Vorgang | Priorität | `LISTE-VORGAENGE.md` (Kopf), `CLAUDE.md` „Wo was steht“ |
| **Stand** | ein Wort aus der festen Liste (startbar, in Arbeit, gebaut, zu testen, wartet, ruht, erledigt …) | Vorgang | – | `tools/startbar.py` |
| **Bereich** | Hauptthema und Teilbereich aus der festen Liste, z. B. „E Kampf“ | Vorgang | – | `tools/bereiche.py`, `FIRMA.md` |
| **Vorrat** | `ARBEIT-<Rolle>.md`: Übergabe, „Zu <Nr>“-Einzelheiten; keine Tabelle | Rolle → Übergabe, Zu-Absatz | Backlog | `CLAUDE.md` „Wo was steht“ |
| **Übergabe** | Zeile oben im Vorrat: Getanes und „Nachfolger: <Titel>“ | Vorrat | Stand | `LISTE-RELEASE-NEUSTART.md`, `CLAUDE.md` „Vorräte klein halten“ |
| **Besetzung** | wer gerade woran arbeitet; schreibt `lauf.py` | Ford | – | `ARBEIT-BESETZUNG.md` |
| **Chefsache** | `docs/chefsache/`: was der Chef entscheiden oder ansehen soll | – → entscheiden, ansehen, billigen, tun | – | `docs/chefsache/README.md` |
| **Vorgang beim Chef** | Vorgang, der auf Antwort, Test oder Tat des Chefs wartet (Feld „wartet auf Chef“, meist mit Datei in der Chefsache) | Vorgang, Chefsache | – | `CLAUDE.md` „Begriffe“ (480) |
| **Rückfrage** | Frage an den Chef; gilt nur mit Datei in `chefsache/entscheiden/` | Chefsache | – | `CLAUDE.md` 8 |
| **Vorentscheid** | Entscheidung von Perikles, Homer oder Sokrates in ihrem Rahmen, Chef billigt nachträglich | Chefsache (billigen) | – | `docs/chefsache/README.md` |
| **Vorgangsarchiv** | was entschieden ist, kurz mit Wortlaut des Chefs | – | – | `VORGANGSARCHIV.md` |
| **Wochenziel** | Ziel der Woche mit Meilenstein, oben im Projektplan | Projektplan | – | `PROJEKTPLAN.md` |
| **Übernahme** | ein Team nimmt ein Muss des anderen, wenn es kein startbares Muss hat, vor eigener Kür (783 W3) | Vorgang | – | `ROLLE-ENTWICKLUNG.md` |
| **Idee** | Einfall, auch des Chefs; heißt prüfen, nicht bauen | – | Auftrag | `LISTE-IDEEN.md` |

## 3 Bauen, Prüfen, Testen

| Begriff | Bedeutung | gehört zu → darunter | nicht | steht in |
|---|---|---|---|---|
| **Build** | APK zum Testen auf dem Handy des Chefs, mit Nummer | – → Sammelbuild, Prüfliste | – | `LISTE-CHECK-BUILD-TEST.md` |
| **Sammelbuild** | gemeinsamer Build beider Teams auf `claude/build-<n>` | Build | – | `LISTE-CHECK-BUILD-TEST.md` |
| **Prüfliste** | Weg durchs Spiel, den der Chef im Test abgeht; Ergebnis als `tN` im Archiv | Build → Testpunkt (tN.k) | – | `LISTE-CHECK-BUILD-TEST.md` |
| **Rückläufer** | Punkt, der im Test des Chefs durchfiel und zurück ans Team geht | Prüfliste | – | `LISTE-BAUEN-TESTEN.md` |
| **Probe** | ein Lauf, der etwas Sichtbares erzeugt; je Aussehen-Thema eine, danach an den Chef | – → Probelauf, Probebild | Messlauf als Ausrede | `ROLLE-ENTWICKLUNG.md` (621 A, 646) |
| **Probelauf** | Bildlauf am Rechner (`PROBE=<Nr>`), Push, der einen Ablauf auslöst, oder Start von Hand; zählt `probelauf.py` | Probe | – | `tools/probelauf.py` |
| **Probebild** | Einzelbild am Rechner vor einem Film, sieht nur der Ersteller selbst an (kein Lauf, keine Freigabe) | Probe | – | `LISTE-BAUEN-TESTEN.md` Prüftreppe 4 (783 W1) |
| **Abgleich** | alte Fassung gegen neue: am Anfang „Alt zuerst“ (Zeile „Alt:“), am Ende vor der Testbitte | – | – | `ROLLE-ENTWICKLUNG.md`, `LISTE-UMZUG-348.md` |
| **alte Fassung** | Kotlin-Spiel in `app/` und `core/`; Untergrenze, nicht Vorlage | – | – | `LISTE-ABGLEICH-ALT.md`, `LISTE-UMZUG-348.md` |
| **Spielfassung** | die Godot-Fassung unter `godot/` | – | – | `godot/LIESMICH.md`, `alt/LISTE-UMZUG-348.md` (399) |
| **Kerntests** | Regeltests mit Exit-Code vor jedem Code-Commit | – | – | `CLAUDE.md` „Feste Regeln“ |
| **Weckruf** | Erinnerung an sich selbst nach einem Push, der baut | – | – | `LISTE-CHECK-BUILD-TEST.md`, `CLAUDE.md` „Feste Regeln“ |
| **Bestand** | alles Gekaufte und Geladene; vor jedem Eigenbau lesen | – | – | `LISTE-BESTAND.md` |
| **Signatur** | unser Bildstil: Toon-Licht, Tusche, Schablone, schwarz-gold | Stil | – | `DESIGN-STIL.md` |

## 4 Betrieb

| Begriff | Bedeutung | gehört zu → darunter | nicht | steht in |
|---|---|---|---|---|
| **Ford-Lauf** | stündlicher Lauf von Ford: `startbar.py`, `lauf.py`, Starts | Ford | – | `LISTE-BETRIEB.md` |
| **Startsperre** | Marke im Protokoll, die einen zweiten Start derselben Rolle 20 Minuten verhindert | Ford-Lauf | – | `tools/lauf.py` |
| **Neustart** | Sitzung übergibt, Ford startet den Nachfolger | Übergabe | – | `LISTE-RELEASE-NEUSTART.md` |
| **Ford-Wache** | Wächtersitzung, falls morgens keine Meldung von Ford kommt | Ford | – | `LISTE-BETRIEB.md` |
| **Guthaben** | Wochenkontingent des Accounts; Stufen 80/95/100 % | – | – | `ARBEIT-BETRIEB.md` |
| **Meldung** | Nachricht über Telegram (`meldung.sh`), das Protokoll | – | – | `CLAUDE.md` 9 |

## 5 Spielwelt und Kampf

| Begriff | Bedeutung | gehört zu → darunter | nicht | steht in |
|---|---|---|---|---|
| **Landkarte** | Überblick über alle Gebiete | – → Gebietskarte | – | `CLAUDE.md` „Begriffe“ |
| **Gebietskarte** | Karte unter freiem Himmel (Dorf, Wald) | Landkarte → Grundriss | – | `CLAUDE.md` „Begriffe“ |
| **Grundriss** | Karte hinter einem Eingang (Haus, Höhle) | Gebietskarte → Ebene | – | `CLAUDE.md` „Begriffe“ |
| **Ebene** | übereinanderliegende Teile eines Grundrisses | Grundriss | Stockwerk; nie für Kartenstufen | `CLAUDE.md` „Begriffe“ |
| **MARS** | unser Kampfsystem; nach dem römischen Kriegsgott, zugleich **M**eisterschaft, **A**bsicht, **R**eaktion, **S**tellung (EN Mastery, Aim, Reaction, Stance) | – → Kampfort | – | `LISTE-MARS.md`, Vorgangsarchiv 761 |
| **Kampfort** | wo gekämpft wird | MARS | Bühne | `LISTE-MARS.md`, `CLAUDE.md` „Begriffe“ |
| **Gefährte**, **Söldner** | Menschen an der Seite des Helden; andere, die mitgehen: **Begleiter** | – | – | `CLAUDE.md` „Begriffe“ |
| **Hauptmenü** | erster Schirm mit Auswahl | – | Titelbild | `CLAUDE.md` „Begriffe“ (292) |
| **BRS** | Bornimer Rollenspielsystem, unsere Regeln | – → Glossar des Spielsystems | – | `DESIGN-BRS.md` |
| **Stufen** | jede Stufenleiter im Spiel (Heldenstufe, Ränge, Ruf, Schlossstufe, Gegenstandsstufe, Güte, Seltenheit, Zustand) mit Stufen und wovon sie abhängt | BRS | Klassenstufe | `DESIGN-BRS.md` „Alle Stufen auf einen Blick“ |

## Abkürzungen

| Kürzel | heißt | steht in |
|---|---|---|
| APK | Android-Installationsdatei (ein Build) | `LISTE-BAUEN-TESTEN.md` |
| BRS | Bornimer Rollenspielsystem | `DESIGN-BRS.md` |
| CC0 | freie Lizenz ohne Bedingungen | `LISTE-QUELLEN.md` |
| CI | Bauserver, Abläufe auf GitHub | `.github/workflows/` |
| D<n> | Befund von Diogenes (D85.1 = Lauf 85, Befund 1) | `PRUEFBERICHT.md` |
| E, G, Q, B, M | Hauptthemen Entwicklung, Gestaltung, Qualität, Betrieb, Markt | `tools/bereiche.py` |
| M, K, M? | Muss, Kür, offen (Perikles entscheidet) | `LISTE-VORGAENGE.md` (Kopf) |
| MARS | unser Kampfsystem; nach dem römischen Kriegsgott, zugleich Meisterschaft, Absicht, Reaktion, Stellung | `LISTE-MARS.md`, Vorgangsarchiv 761 |
| QS, QM | Qualitätssicherung (Builds, Prüflisten), Qualitätsmessung (Prüfläufe, Kennzahlen) | `FIRMA.md` |
| SRD | System Reference Document 5.1 (CC BY 4.0), wird ersetzt | `CLAUDE.md` |
| tN, tN.k | Test des Chefs an Build N, Punkt k | `LISTE-BAUEN-TESTEN.md` |
| Z1–Z6 | Ziele der Zielvereinbarung Perikles | `ROLLE-PROJEKT.md` |

## A–Z

Abgleich (3) · alte Fassung (3) · APK (Abk.) · Begleiter (5) · Bereich (2) · Besetzung (2) · Bestand (3) · BornWire TCS (1) · BRS (5) · Build (3) · Chef (1) · Chefsache (2) · Ebene (5) · Ford-Lauf (4) · Ford-Wache (4) · Gebietskarte (5) · Gefährte (5) · Grundriss (5) · Guthaben (4) · Hauptmenü (5) · Helfer (1) · Idee (2) · Kampfort (5) · Kerntests (3) · Klasse (2) · Landkarte (5) · MARS (5) · Meldung (4) · Neustart (4) · Niederlassung (1) · Probe, Probebild, Probelauf (3) · Prüfliste (3) · Rolle (1) · Rückfrage (2) · Rückläufer (3) · Sammelbuild (3) · Signatur (3) · Sitzung (1) · Söldner (5) · Spielfassung (3) · Stand (2) · Startsperre (4) · Team Tom, Team Jerry (1) · Übergabe (2) · Übernahme (2) · Vorentscheid (2) · Vorgang (2) · Vorgang beim Chef (2) · Vorgangsarchiv (2) · Vorgangsliste (2) · Vorrat (2) · Weckruf (3) · Wochenziel (2) · Zentrale (1)
