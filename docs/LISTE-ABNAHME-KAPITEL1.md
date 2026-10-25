# Abnahme Kapitel 1: Meilenstein und Wochenziel

**Meilenstein „marktreif“** (338, Chef 23.10., 09:05; ersetzt 26 vom 11.10.; **ohne Datum seit 25.10., 01:02:** „Es gibt keinen Release-Termin. Wir arbeiten so lange, bis das Produkt … gut ist“): Kapitel 1 öffentlich im Play Store in Marktqualität; Maß ist Qualität, nicht ein Termin. **Zuerst Umzug des heutigen Spiels nach Godot (348, „jetzt“), alle machen mit.** Was in die Blöcke (a) bis (f) unten fällt, ist Muss; Kapitel 2, Gruppenkämpfe, Dungeons, weitere Klassen, Schmied erst nach dem Marktstart. Wer einen Punkt erledigt, hakt ihn hier ab. Liest Ford beim Start (Wochenziel); sonst nur bei Anlass.

## Stand zum Marktstart (338.1; Perikles: montags ganz, täglich neu; als Seite: [Dashboard](https://claude.ai/artifact/5gdqbHNUUpbBUU9sBo4i7t), 339)

**Stand 25.10., 02:1x: gelb.** Du hast entschieden: kein Termin, das Spiel zieht jetzt nach Godot um, das alte Spiel ruht ganz außer der Store-Vorbereitung (142), Vorgabe ist das heutige Spiel, du prüfst nur Vergleichsbilder alt gegen neu, Vorgabe für den Look ist Probe-Build 11 mit dicker Tusche nach Licht und Schatten (348, 338). Der Umzugsplan steht in `LISTE-UMZUG-348.md`: Woche 1 baut Tom das Godot-Grundgerüst mit dem Dorf als erster Gebietskarte (348.6), Jerry einen Kampf gegen das Wolfsrudel mit den echten Regeln (348.7), beide listen alles auf, was umziehen muss (348.8). Danach schätzen sie neu (bisher grob 45 bis 63 Sitzungen ohne Modelle). Builds 85 bis 88 sind auf `main` und sind die Vorgabe.

**Heute für dich**
- **Entscheiden:** [38](chefsache/entscheiden/38-balance-kapitel1.md) Balance (ob Stufe 1 so leichter bleibt; Build 88 hast du freigegeben); [264](chefsache/entscheiden/264-arbeitsorte.md) Arbeitsorte (Kür).
- **Testen, nur wenn du willst:** Build 89 [0.1.1023](chefsache/ansehen/t89-mars-lyra-englisch.md) (MARS spielnötig, Lyras Befreiung, Englisch) ist fertig gebaut. Getestet kommt er als bessere Vorgabe auf `main`; sonst ruht er mit dem alten Spiel.

**1. Stand gegen den Plan**

Was unten steht, ist im alten Spiel fertig und zieht als Vorgabe mit um. Termine je Block gibt es erst nach den Umzugsproben.

| Block | Ampel | warum (Vorgänge) | fertig bis |
|---|---|---|---|
| (a) Kapitel 1 rund | gelb | Absturz (346), Ruckeln (358) und die Fehler aus deinem Durchspielen (350–352) sind auf `main`, im tiefen Wald das Hängenbleiben auch, die Sicht unter den Baumkronen baut Tom noch (353); Stufe 1 leichter (38) und Ansage harter Schläge (354) sind mit Build 88 auf `main`, Lyras Befreiung (356.1) liegt in Build 89; Schwierigkeitsgrad (39) hängt an 38; Tablet (267) wartet auf deinen Test. Englische Texte sind berichtigt, eine Stelle formuliert Homer neu (338.1b, c). | nach Umzug |
| (b) Erster Eindruck | gelb | Logo und Hauptmenü sind fertig (251, 292.3). Figuren und Intro-/Outro-Bilder im neuen Look entstehen jetzt im Umzug; Vorgabe ist Build 11 der Godot-Probe mit dicker Tusche. | nach Umzug |
| (c) Ein Aussehen | grün | Das Spielermenü im Stil des Hauptmenüs ist mit Build 83 auf `main` (326). | erledigt im alten Spiel |
| (d) Klassischer Kampf rund | gelb | Graks Hieb (320) und sichtbarer Angriff (337) sind auf `main`; Ansage harter Schläge ist mit Build 88 auf `main` (354). | nach Umzug |
| (e) MARS als Alternative | gelb | Angriff und Ring sind auf `main` (336, 337); die fünf spielnötigen Punkte und der Schalter sind gebaut (296.2, 212); Schmuck ist Kür (296.3). Den Feinschliff (Lyra, spielnötige Punkte) trägt Build 89; der Weiterbau geschieht im neuen Spiel. | nach Umzug |
| (f) Store | gelb | Konto angelegt, 25 $ bezahlt (142, 341.1b); als Nächstes Ausweis- und Telefonprüfung. Webseite: Gestaltung gebilligt, Umleitung steht, Sokrates baut Aufbau, Impressum und Datenschutz; von dir fehlen FTP-Zugang, Name und Anschrift (252). Preis (45) wartet auf den Gewerbeschein. | läuft neben dem Umzug |

**2. Ausgaben**
- **Echtes Geld:** das Max-Abo (fest) und gekauftes Nutzungsguthaben; laut deinem Bild vom 24.10., 17:21 diesen Monat 248,62 $, davon 54,03 $ übrig, kein Ausgabenlimit, Neuladen aus. Neuer Stand liegt nicht vor.
- **Wochenguthaben Max:** seit Sa 24.10., 21:00 neu; die Woche zuvor war ab Fr 23.10., 10:1x aufgebraucht (Sparbetrieb).
- **Wofür:** Anteil Betrieb und Spiel rechnet Perikles am Mo 26.10. neu (Wochenziel); zuletzt 46 % Betrieb, 46 % Spiel (23.10.). Gegen den Betriebsanteil läuft seit 24.10. 347 (kürzere Antworten, kleinerer Start der Teams).

**3. Risiken und Gegenmittel**

| Risiko | Folge | Gegenmittel (wer) |
|---|---|---|
| Umzug nach Godot dauert länger als geschätzt | 45–63 Sitzungen ungeprüft, Modelle nicht eingerechnet; Kapitel 1 geht während des Umzugs nicht voran | Woche 1 je Team ein Stück aus dem echten Spiel (348.6 Dorf, 348.7 Wolfskampf) und die Bestandsliste (348.8), dann neue Schätzung; läuft Gebietskarte oder Kampfort nicht, zurück zum alten Code (Verlust je Team 2–3 Sitzungen; Sokrates, Perikles) |
| Gewerbeschein kommt spät | Webseite mit Impressum und Datenschutz (252) fehlt; das Konto steht schon (341.1b) | beim Amt nachfragen (du); Webseite so vorbereiten, dass nur noch die Angaben fehlen (Sokrates) |
| Anschrift vor dem Zahlungsprofil | Google zeigt die Anschrift öffentlich | Wohn- oder Geschäftsanschrift (Büroservice) vor dem Zahlungsprofil entscheiden (du, Sokrates; 341.1b) |
| Guthaben knapp | letzte Woche gut ein Tag Stillstand; mit dem Umzug eher mehr | Betriebsanteil senken: Tagesbericht ersetzt (23.10.); seit 24.10. kürzere Antworten und kleinerer Start der Teams (347; Perikles, Messung Sokrates); Credits mit Monatslimit nur auf dein Wort |
| „Gut“ hat kein Ende | ohne Termin fehlt die natürliche Grenze; Bilderrunden fressen die Wochen (Spielermenü und Intro-Bilder brauchten drei Runden) | beim Umzug ist die Vorgabe das heutige Spiel, du prüfst nur Abweichungen am Vergleichsbild (348); jede Vorlage vorher fremd geprüft (338.2), damit Runden nur noch Geschmack sind |
| MARS wird nicht rund | (e) fehlt | nach dem Umzug Stand messen; reicht es nicht, entscheidest du: Marktstart nur mit klassischem Kampf oder MARS als Testfunktion gekennzeichnet |
| 12 Tester fehlen | Pflichttest kann nicht beginnen | Liste vor Ende des Umzugs (du, Sokrates); Test läuft wenn möglich vorher mit der alten App, damit das Konto bereit ist (142; vom Ruhen ausgenommen) |

Dazu, ohne Vorgang (Perikles vergibt Nummern mit der neuen Schätzung nach Woche 1): Englisch durchgehend (Homer, Tom); Spielstände über Updates (Tom); Handys und Tablets (Tom, mit 267); Store-Texte und Bilder (Homer, Sokrates); 12 Tester finden (Chef, Sokrates).

**Reihenfolge** (ohne Datum; Google: neues privates Konto braucht 14 Tage geschlossenen Test mit 12 Testern, dann Prüfung, etwa eine Woche):

| Schritt | was |
|---|---|
| erledigt | Chef spielt Kapitel 1 durch (26) ✓ 24.10.; Konto angelegt (142) ✓ 23.10.; (c) ✓ |
| 1 | Umzug Woche 1 (`LISTE-UMZUG-348.md`): Tom Grundgerüst und Dorf (348.6), Jerry Modellregel und Wolfskampf (348.7), beide Bestandsliste (348.8); danach Plan mit Schätzung (Perikles) |
| 2 | Umzug des heutigen Spiels; (a), (b), (d), (e) im neuen Code fertig |
| 3 | Fehler und Glätten; Englisch, Geräte, Spielstände; Store-Seite, Datenschutz, Impressum; Tester bereit |
| 4 | Chef: „gut“; geschlossener Test 14 Tage (falls nicht schon mit der alten App gelaufen), Antrag, Prüfung durch Google, Marktstart |

## Wochenziel 26.10.–01.11. (Perikles, gesetzt 25.10., 02:1x; Wochenziel 18.–24.10. in Git)

**Umzug Woche 1 steht: das Dorf Bornim läuft in Godot am Handy, ein Kampf gegen das Wolfsrudel mit den echten Regeln auch, und die Bestandsliste nennt alles, was umziehen muss; danach neue Schätzung des ganzen Umzugs.** Plan und Regeln: `LISTE-UMZUG-348.md`. Muss (M) sind nur diese Vorgänge; das alte Spiel ruht ganz (348), alles andere ist diese Woche Kür oder ruht (126). Am Mo 26.10. nach der Wochenzählung prüft Perikles Kostenanteil und Reihenfolge und passt an.

| Vorgang | Wer | fertig, wenn |
|---|---|---|
| 348.6 Grundgerüst und Dorf | Tom | APK am Handy; Vergleichsbild Dorf alt/neu an den Chef (fremd geprüft, 338.2) |
| 348.7 Modellregel und Wolfskampf | Jerry | Modellregel in `LISTE-UMZUG-348.md` ✓ 25.10.; APK am Handy, Vergleichsbild Kampf alt/neu an den Chef |
| 348.8 Bestandsliste | Tom, Jerry | Liste in `LISTE-UMZUG-348.md` vollständig, jede Zeile mit Quelle im Code |
| neue Schätzung | Tom, Jerry, dann Perikles | nach 348.6 bis 348.8: Sitzungen je Bereich samt Modellen; Perikles setzt Wochenziel 2 und Stand zum Marktstart |
| 142 Store-Vorbereitung | Chef, Sokrates | Ausweis- und Telefonprüfung; vom Ruhen ausgenommen |

**Oberste Direktive (179): Fehler ausmerzen, Kapitel 1 spielerfreundlich.** Im Umzug heißt das: was im alten Spiel geht, muss im neuen mindestens so gehen; jede Abweichung am Vergleichsbild ist ein Fehler und Muss. Neue Fehler des Chefs kommen als Muss dazu. Build 89 (alter Code) nur, wenn der Chef ihn testet.

**Guthaben:** Umzug kostet mehr als eine Woche Kleinarbeit. Ab 80 % Woche `lauf.py --nur-muss` (Ford), ab 95 % keine neuen Starts außer Rückläufer des Chefs; Nutzungsguthaben (Credits) nur auf Wort des Chefs.

## Pflicht in Block (a) Kapitel 1 rund

- [x] **Alle Orte „Ort fertig“** (`DESIGN-ABNAHME.md`): Dorf (5), Räume (13), Wald (27), Höhle (13e, seit 17.10.) erledigt; offen nur Mondlicht und Schacht nachts (D3.14 mit Fackel 84.1, Kür). Prüft das Team, nicht der Chef.
- [ ] **Läuft rund:** kein Schweben nach Start und Kartenwechsel, Zwischenbild (24; 24.6 wartet auf den Kampfort 72u); Sprungtest und Kollisionsprüfung 0; „Bewegungen unrund“ (19e) geklärt.
- [ ] **Ausgleich:** alle vier Klassen schaffen die Bosse in vergleichbarem Maß (Magier gegen Grak 44–62 %); Zielwert mit dem Chef festlegen (38).
- [ ] **Durchgespielt:** der Chef spielt Kapitel 1 einmal ganz durch; Zufallsspieler (`PlayerSimTest`) grün (26).

Erledigt (Verlauf in Git): alte Ansicht ausgebaut (13t), Gegner im neuen Stil (9i), Musik neu (28), Nebenquests (29), Kartenansicht (62), Tagesablauf (5la).

**Wenn Zeit ist (kein Hindernis für den Test):** Stimmen der Gegner (18), Schritte je Untergrund (74), Raumklang (119).
