# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [211](entscheiden/211-mars-bildschirm.md) | M? | E Kampf | 19.10. | Kampfbericht 5 Zeilen und umbrechend, Absicht mit Ziel und Erklärkarte, Zugleiste größer, Lebenspunkte als Balken, Knöpfe größer; der Kampfort wird etwa 10 % niedriger. | Homer |
| [215](entscheiden/215-uebergang-schalter.md) | Kür | G Bedienung | 19.10. | Übergänge: Schalter zum Betreten und Verlassen? (Empfehlung: B) | Sokrates |

## Zu billigen

Nichts offen.

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.870](ansehen/t32-tempelszene-mondlicht.md) | Build 32 | Tempelszene neu, Mondlicht | Tom | 19.10. |
| 2 | [0.1.874](ansehen/t33-angriff-gefolge-mars-menue.md) | Build 33 | Angriff, Gefolge, MARS im Systemmenü, Meldungen | Jerry | 19.10. |
| 3 | [0.1.875](ansehen/t34-mars-klassen-ruf-mond.md) | Build 34 | MARS Klassen und Zweitwaffe, Ruf, Elite-Stimme, Mondschacht, Klassenstück | Jerry | 19.10. |

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 19.10.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 3, Muss 0, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 211 | M? | von Chef (19.10., 12:30, über Sokrates): MARS-Bildschirm funktional und klar, nicht hübsch | Chef (Datei in der Chefsache) |
| 41 | K | Storyplan; Texte Kapitel 2 | ruht |
| 72 | K | Profil und Kampfsystem | wartet auf Sokrates |

**Tom** – offen 12, Muss 5, startbar 3

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 213 | M | von Chef (19.10., 13:11, über Sokrates): Testreiter „Alle Vorräte auf mindestens 10“ legt | startbar |
| 198 | M | von Chef (19.10., 10:51; an Tom 11:14): nach gelungener Flucht greifen dieselben Gegner au | wartet auf Test/Build (gebaut) |
| 68 | M | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | startbar |
| 84.1T.1 | M | von Homer (19.10.): [84.5.rast] auch nach einem Morgen in einer Szene (Cmd.Morning) | wartet auf Test/Build (gebaut) |
| 214 | K | von Chef (19.10., 13:20, über Sokrates): Reiter Ausrüstung: Tippen auf einen Platz zeigt p | startbar |
| 27 | K | Wald „Ort fertig“ | wartet auf Test (Build) |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht |
| 30 | K | Abstürze beim Testen (Technik) | ruht |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht |
| D29.3 | K | von Diogenes (Lauf 30): Kleinleben und Schatten in Wald und Dorf (D29.3, D29.4, Prüfberich | wartet auf Test/Build (gebaut) |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (STORY-WAHLEN.md, Vorgangsarchiv 133) | ruht |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (nach Meilenstein) |

**Jerry** – offen 30, Muss 7, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 199 | M | von Chef (19.10., 10:51): Kampfknopf „Angriff“ statt „Angreifen“ | wartet auf Test (Build) |
| 200 | M | von Chef (19.10., 10:53): Gefolge des Bosses greift in Hintergrundgröße an (nicht vergröße | wartet auf Test (Build) |
| 201 | M | von Chef (19.10., 10:56): MARS-Probekampf ins Systemmenü (ohne Testreiter), beim Start scr | wartet auf Test (Build) |
| 203 | M? | von Chef (19.10.): MARS: „Abwarten“ wird „Abwehr“ (SRD-Ausweichen), Chef ja (Vorgangsarchi | wartet auf Test/Build (gebaut) |
| 204 | M? | von Chef (19.10., 11:25): MARS: langer Druck zeigt Erklärung der Schaltfläche, bei Fähigke | wartet auf Test/Build (gebaut) |
| 210 | M? | von Sokrates (Chef 19.10., 12:22, Vorgangsarchiv 210): MARS: langer Druck auf die Ansage d | wartet auf Test/Build (gebaut) |
| 205 | M? | von Chef (19.10.): MARS: Gefallene: eigene liegen, Gegner verschwinden, Chef ja (Vorgangsa | wartet auf Test/Build (gebaut) |
| 207 | M? | von Chef (19.10.): MARS: Brennende Hände als Reihenzauber, ohne Effektbild, Text knapp, Ch | wartet auf Test/Build (gebaut) |
| 208 | M? | von Chef (19.10.): MARS: Späher im Schatten angreifbar mit Nachteil, nie zweimal Schatten, | wartet auf Test/Build (gebaut) |
| 172 | M | Kampf zu langwierig: Klicks bis zur ersten Aktion | wartet auf Test (Build) |
| 72.10a.9 | K | MARS: Rolle und Reaktion je Klasse | wartet auf Test/Build |
| 72.10a.11 | K | MARS: Zweitwaffe ohne Zugverlust | wartet auf Test/Build |
| 190.9 | K | von Perikles (190): Sammelbuild Jerry: 72.10a.9 und .11 (Zweige claude/jerry-72-10a-9-klas | wartet auf Test/Build |
| 168.1 | K | Umsetzung 168: Kapitel 2 Garrick fest an der Seite, Söldner ab Kapitel 3 | nach dem Meilenstein |
| D23.3 | K | Diogenes Lauf 23: Magier und Kleriker sterben oft | ruht |
| 24.6 | K | Kampferöffnung wartet + Herzschlag in der Blende | wartet auf 72 (Chef) |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte (Grak im Wald) | nach dem Meilenstein |
| 133 | K | Umsetzung 133: Charisma-Proben und Erfahrung für gelöste Konflikte (mit 38; Vorgangsarchiv | nach dem Meilenstein |
| 212 | K | Umsetzung 212: Schalter „Kampf: MARS oder klassisch“ in den Einstellungen, jederzeit wechs | nach dem Meilenstein |
| 86 | K | Bewegung und Übersicht: Keuchen, Initiative, Rennen | wartet auf 38 (ruht) |
| 38 | M | Balance: Kapitel 1 gemessen | ruht |
| 39 | M | Schwierigkeitsgrad im Menü | wartet auf 38 (ruht) |
| 59e.1 | M | von Sokrates (Chef 19.10.): je Warenwechsel bei Thessa ein Stück für die Klasse; Wechsel b | wartet auf Test/Build |
| 59e | K | Händler: Vorrat je Laden (59e.2 Mengen) | wartet auf 39 (wartet) |
| 19e | K | Beispiel für „Bewegungen unrund“ | ruht |
| 134.3 | K | Kurzer Ruf zum Zeichen 134.1 | wartet auf Test/Build |
| 140 | K | Monster-Geräusche Rest | wartet auf Test/Build |
| 27o | K | Höhlenschacht nachts als Mondlicht (D3.14, von Team Tom) | wartet auf Test/Build |
| D29.1 | K | von Diogenes (Lauf 30): Ortsklang ohne Richtung; Dorf stumm (D29.1, D29.2) | wartet auf Test/Build (gebaut) |
| D32.1 | K | von Diogenes (Lauf 32/71 C): Englischer Text mit deutschem Wort: „Söldner knocked out“ (Pr | wartet auf Test/Build (gebaut) |

**Perikles** – offen 7, Muss 2, startbar 1

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 197.1 | M | von Sokrates (Chef 19.10., 13:03, „Ja, trag es so bei Perikles ein“ 13:09): lauf.py archiv | startbar |
| 90 | K | Tagesrückblick (Probe 18.–22.10.), Ford startet ihn (LISTE-BETRIEB.md Schritt 11) | Termin 20.10. |
| 165 | M | Ablaufstichprobe, im Tagesrückblick 90 | Termin 20.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann j | Termin 20.10. |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | Termin 21.10. |
| 99h.6 | K | Messung Leitung 20.–21.10. mit den Neustarts der Teams (99h, 99h.6) | Termin 22.10. |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz) | ruht bis 23.10. |

**Diogenes** – offen 5, Muss 2, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 149.1 | M | von Sokrates (Chef 17.10., 23:2x: „Ja“ auf Empfehlung Sokrates): in die Zählung 149 aufneh | Dauerzeile bis 24.10. |
| 149 | M | Probewoche Ford mit neuem Modell; dazu 156 Tom gegen Jerry | Dauerzeile bis 24.10. |
| Woche | K | Wochenzählung (QM, 106.1): alle Kennzahlen der Woche zählen, Tabelle oben im Prüfbericht ( | Termin 26.10. |
| 90 | K | Tagesrückblick der Woche gegen die Quellen prüfen | Termin 22.10. |
| 186.3 | K | Ausgefüllte Prüfbögen der Tester auswerten (tools/pruefbogen/, mit echten Bögen ungetestet | ruht |

**Sokrates** – offen 10, Muss 1, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 215 | K | von Chef (19.10., 13:19): Schalter zum bewussten Betreten oder Verlassen eines Bereichs | Chef (Datei in der Chefsache) |
| 72c | K | von Chef (19.10., 12:55): Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband | nach dem Meilenstein |
| 185 | K | von Chef (18.10., 18:5x): Ford seltener neu starten (Grenze 400.000 Token) | wartet auf Perikles |
| 167.6 | M | Morgenbericht mit Kennzahlen (167 sonst erledigt) | Termin 26.10. |
| 142 | K | Vorbereitung Pflichttest Play Store (von Perikles); dabei Store-Text „jede Entscheidung zä | ruht bis 31.10. |
| 45 | K | Geschäftsmodell (Play Store) | ruht |
| 109 | K | Repo öffentlich | ruht |
| 48 | K | Zufallsgenerierte Dungeons (48a–48f ja, ARBEIT-ARCHIV.md) | ruht |
| 49 | K | Lehrer, Fertigkeiten, Talente (DESIGN-HELDENBAU.md) | ruht |
| 50 | K | Weitere Klassen (Matrix im Heldenbau) | ruht |
## Lücken

Vom Werkzeug gefunden (D21.3): steht im Vorrat, hat hier keine Datei.

Nicht gestellt: 186.3 (Pruefung)

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Zeile 1 `# <Team> · Build <n> · <Version> · <Thema> · <PR>`, Zeile 2 `<Bereich, z. B. E Kampf> · <Team> · <TT.MM.>, <HH:MM> · <APK-Link>`, dann Tabelle `| # | Nr. | Wo und wie | Richtig | Falsch |` mit konkreten Schritten („Tippe …, erwarte …“); davor ein Satz „Ein Weg: …; über Build <n−1> installieren“, Zeilen in der Reihenfolge dieses Wegs (`LISTE-BAUEN-TESTEN.md` Sammelbuild). Sammelseite je Build: `## Build <n> · <Version> · <Thema> · <PR>`. Die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127); Abweichungen stehen unter „Lücken“.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Zu billigen (Vorentscheid, 194.1): `billigen/<nr>-<stichwort>.md`, Aufbau wie bei „entscheiden“ plus: Entschieden, Umgesetzt (Commit), Rückbau, Kosten, stärkstes Gegenargument (bei Balance und Spielgefühl die verworfene Möglichkeit). Hält keine Arbeit an; Antwort „gebilligt“ oder „zurück“, Sokrates löscht die Datei und setzt „gebilligt TT.MM.“ oder „zurück TT.MM.“ in die Archivzeile.
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
