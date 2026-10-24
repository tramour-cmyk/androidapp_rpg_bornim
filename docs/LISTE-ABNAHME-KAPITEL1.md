# Abnahme Kapitel 1: Meilenstein und Wochenziel

**Meilenstein „marktreif“** (338, Chef 23.10., 09:05; ersetzt 26 vom 11.10.; **ohne Datum seit 25.10., 01:02:** „Es gibt keinen Release-Termin. Wir arbeiten so lange, bis das Produkt … gut ist“): Kapitel 1 öffentlich im Play Store in Marktqualität; Maß ist Qualität, nicht ein Termin. **Zuerst Umzug des heutigen Spiels nach Godot (348, „jetzt“), alle machen mit.** Was in die Blöcke (a) bis (f) unten fällt, ist Muss; Kapitel 2, Gruppenkämpfe, Dungeons, weitere Klassen, Schmied erst nach dem Marktstart. Wer einen Punkt erledigt, hakt ihn hier ab. Liest Ford beim Start (Wochenziel); sonst nur bei Anlass.

## Stand zum Marktstart (338.1; Perikles: montags ganz, täglich neu; als Seite: [Dashboard](https://claude.ai/artifact/5gdqbHNUUpbBUU9sBo4i7t), 339)

**Stand 25.10., 01:05: gelb.** Du hast entschieden: kein Termin, das Spiel zieht jetzt nach Godot um, Vorgabe ist das heutige Spiel (348, 338). Damit gelten die Termine unten nicht mehr; einen neuen Plan lege ich vor, sobald du die Rückfrage in [348](chefsache/entscheiden/348-engine.md) beantwortest ((1) kein Termin ist beantwortet; offen): (2) Arbeit am alten Spiel ruht außer Store-Vorbereitung (142), (3) du prüfst nur Abweichungen alt gegen neu am Vergleichsbild, (4) Probe-Build 11 mit stärkerer Tusche (dunkler Umriss) als Vorgabe für alle. Tom und Jerry hatten 45 bis 63 Sitzungen für den Umzug geschätzt (grob, ohne Modelle für Leute, Tiere, Monster, Wald, Höhle, Innenräume); nach je einer Probe (Tom eine Gebietskarte, Jerry ein Kampfort) schätzen sie neu. Builds 85 bis 87 sind auf `main` und bleiben die Vorgabe für den Umzug.

**Heute für dich**
- **Entscheiden:** [348](chefsache/entscheiden/348-engine.md) Rückfrage „2, 3, 4 ja“ oder Abweichung; [38](chefsache/entscheiden/38-balance-kapitel1.md) Balance (ob Stufe 1 so leichter bleibt, nach deinem Test von Build 88); [264](chefsache/entscheiden/264-arbeitsorte.md) Arbeitsorte (Kür).
- **Testen:** Build 88 [0.1.1021](chefsache/ansehen/t88-ansage-stufe1.md) (harte Schläge angesagt, Stufe 1 leichter), falls das alte Spiel nicht ganz ruht (Frage 2).

**1. Stand gegen den Plan**

Was unten steht, ist im alten Spiel fertig und zieht als Vorgabe mit um. Termine je Block gibt es erst nach den Umzugsproben.

| Block | Ampel | warum (Vorgänge) | fertig bis |
|---|---|---|---|
| (a) Kapitel 1 rund | gelb | Absturz (346), Ruckeln (358) und die Fehler aus deinem Durchspielen (350–352) sind auf `main`, im tiefen Wald das Hängenbleiben auch, die Sicht unter den Baumkronen baut Tom noch (353); Stufe 1 leichter (38) und Ansage harter Schläge (354) liegen in Build 88, Lyras Befreiung (356.1) ist gebaut; Schwierigkeitsgrad (39) hängt an 38; Tablet (267) wartet auf deinen Test. Englische Texte sind berichtigt, eine Stelle formuliert Homer neu (338.1b, c). | nach Umzug |
| (b) Erster Eindruck | gelb | Logo und Hauptmenü sind fertig (251, 292.3). Figuren und Intro-/Outro-Bilder im neuen Look entstehen jetzt im Umzug; Vorgabe ist Build 11 der Godot-Probe mit Tusche (dunkler Umriss), falls du Frage 4 in 348 bejahst. | nach Umzug |
| (c) Ein Aussehen | grün | Das Spielermenü im Stil des Hauptmenüs ist mit Build 83 auf `main` (326). | erledigt im alten Spiel |
| (d) Klassischer Kampf rund | gelb | Graks Hieb (320) und sichtbarer Angriff (337) sind auf `main`; Ansage harter Schläge liegt in Build 88 (354). | nach Umzug |
| (e) MARS als Alternative | gelb | Angriff und Ring sind auf `main` (336, 337); die fünf spielnötigen Punkte und der Schalter sind gebaut (296.2, 212); Schmuck ist Kür (296.3). Weiterbau im alten Spiel ruht, falls du Frage 2 bejahst. | nach Umzug |
| (f) Store | gelb | Konto angelegt, 25 $ bezahlt (142, 341.1b); als Nächstes Ausweis- und Telefonprüfung. Webseite: Gestaltung gebilligt, Umleitung steht, Sokrates baut Aufbau, Impressum und Datenschutz; von dir fehlen FTP-Zugang, Name und Anschrift (252). Preis (45) wartet auf den Gewerbeschein. | läuft neben dem Umzug |

**2. Ausgaben**
- **Echtes Geld:** das Max-Abo (fest) und gekauftes Nutzungsguthaben; laut deinem Bild vom 24.10., 17:21 diesen Monat 248,62 $, davon 54,03 $ übrig, kein Ausgabenlimit, Neuladen aus. Neuer Stand liegt nicht vor.
- **Wochenguthaben Max:** seit Sa 24.10., 21:00 neu; die Woche zuvor war ab Fr 23.10., 10:1x aufgebraucht (Sparbetrieb).
- **Wofür:** Anteil Betrieb und Spiel rechnet Perikles am Mo 26.10. neu (Wochenziel); zuletzt 46 % Betrieb, 46 % Spiel (23.10.). Gegen den Betriebsanteil läuft seit 24.10. 347 (kürzere Antworten, kleinerer Start der Teams).

**3. Risiken und Gegenmittel**

| Risiko | Folge | Gegenmittel (wer) |
|---|---|---|
| Umzug nach Godot dauert länger als geschätzt | 45–63 Sitzungen ungeprüft, Modelle nicht eingerechnet; Kapitel 1 geht während des Umzugs nicht voran | je Team zuerst eine Probe aus dem echten Spiel, dann neue Schätzung; läuft Gebietskarte oder Kampfort nicht, zurück zum alten Code (Verlust je Team 2–3 Sitzungen; Sokrates, Perikles) |
| Gewerbeschein kommt spät | Webseite mit Impressum und Datenschutz (252) fehlt; das Konto steht schon (341.1b) | beim Amt nachfragen (du); Webseite so vorbereiten, dass nur noch die Angaben fehlen (Sokrates) |
| Anschrift vor dem Zahlungsprofil | Google zeigt die Anschrift öffentlich | Wohn- oder Geschäftsanschrift (Büroservice) vor dem Zahlungsprofil entscheiden (du, Sokrates; 341.1b) |
| Guthaben knapp | letzte Woche gut ein Tag Stillstand; mit dem Umzug eher mehr | Betriebsanteil senken: Tagesbericht ersetzt (23.10.); seit 24.10. kürzere Antworten und kleinerer Start der Teams (347; Perikles, Messung Sokrates); Credits mit Monatslimit nur auf dein Wort |
| „Gut“ hat kein Ende | ohne Termin fehlt die natürliche Grenze; Bilderrunden fressen die Wochen (Spielermenü und Intro-Bilder brauchten drei Runden) | beim Umzug ist die Vorgabe das heutige Spiel, du prüfst nur Abweichungen (Frage 3 in 348); jede Vorlage vorher fremd geprüft (338.2), damit Runden nur noch Geschmack sind |
| MARS wird nicht rund | (e) fehlt | nach dem Umzug Stand messen; reicht es nicht, entscheidest du: Marktstart nur mit klassischem Kampf oder MARS als Testfunktion gekennzeichnet |
| 12 Tester fehlen | Pflichttest kann nicht beginnen | Liste vor Ende des Umzugs (du, Sokrates); Test läuft wenn möglich vorher mit der alten App, damit das Konto bereit ist (142, Frage 2 in 348) |

Dazu, ohne Vorgang (Perikles vergibt Nummern mit dem Umzugsplan): Englisch durchgehend (Homer, Tom); Spielstände über Updates (Tom); Handys und Tablets (Tom, mit 267); Store-Texte und Bilder (Homer, Sokrates); 12 Tester finden (Chef, Sokrates).

**Reihenfolge** (ohne Datum; Google: neues privates Konto braucht 14 Tage geschlossenen Test mit 12 Testern, dann Prüfung, etwa eine Woche):

| Schritt | was |
|---|---|
| erledigt | Chef spielt Kapitel 1 durch (26) ✓ 24.10.; Konto angelegt (142) ✓ 23.10.; (c) ✓ |
| 1 | Umzugsproben: Tom eine Gebietskarte, Jerry ein Kampfort in Godot, je 2–3 Sitzungen; danach Plan mit Schätzung (Perikles) |
| 2 | Umzug des heutigen Spiels; (a), (b), (d), (e) im neuen Code fertig |
| 3 | Fehler und Glätten; Englisch, Geräte, Spielstände; Store-Seite, Datenschutz, Impressum; Tester bereit |
| 4 | Chef: „gut“; geschlossener Test 14 Tage (falls nicht schon mit der alten App gelaufen), Antrag, Prüfung durch Google, Marktstart |

## Wochenziel 18.–24.10. (Perikles, gesetzt 16.10.)

**Kapitel 1 ist einmal ganz durchspielbar und eingestellt: Höhle fertig, „Normal“ gemessen und eingestellt, Schwierigkeitsgrad gebaut, Ende (Tempel) am Muster geprüft, der Chef spielt einmal durch.** Termin: Sa 24.10. Muss (M) sind nur diese Vorgänge; alles andere ist diese Woche Kür (126).

**Bis Sa 24.10., 10:00 (Perikles 21.10., 19:5x, nach 284; Chef 19:49: „Mit dem 61/62 Build spiele ich nicht durch. Wir geben noch bis Samstag Vormittag Vollgas, dann mit der "besten" Version spiele ich es durch.“):**
1. Muss zuerst: gebaute Builds zum Test bringen und Rückläufer des Chefs beheben (Tom 282, 283, 267, 267.1; Jerry 24.6, 211.14).
2. Kampf und Texte glätten, jetzt Muss: Jerry 249, 279, 280.2; Tom 280.1.
3. Letzter Build Sa 10:00; der neueste vom Chef freigegebene ist die „beste Version“ für das Durchspielen (26) Sa ab Mittag. Danach bis zum Ergebnis nur Fehler aus dem Durchspielen.
4. Guthaben (Max 59 % am 21.10., 15:25, etwa 0,75 %/h, Zurücksetzung Sa 21:00): so wäre es Fr abends leer. Darum ab 80 % Woche `lauf.py --nur-muss` (Ford), ab 95 % keine neuen Starts außer Rückläufer des Chefs. Nutzungsguthaben (Credits) nur auf Wort des Chefs.

| Vorgang | Wer | fertig, wenn |
|---|---|---|
| ~~13e Höhle „Ort fertig“~~ erledigt 17.10. | Tom | Punkte aus `DESIGN-ABNAHME.md` ohne Lücke außer Mondlicht (hängt an 84.1, Kür); prüft das Team, nicht der Chef |
| 38 Balance „Normal“ | Jerry, Diogenes | D4.1 neu gemessen (Zeile 38 in `ARBEIT-PRUEFUNG.md`), Zielwert Ausgleich mit dem Chef festgelegt (Chefsache) |
| 39 Schwierigkeitsgrad | Jerry, Homer (39.2 Wortlaut) | Build nach 38 getestet (39.1) |
| ~~112, 68 Tempelszene gegen das Intro~~ erledigt | Homer, dann Tom | entschieden 17.10.: Tom malt neu, nach dem Meilenstein |
| ~~26 Durchspielen~~ erledigt 24.10. | Chef | gespielt 23.10. (0.1.1008), Befunde als 350–357 und 38 in den Vorräten |

**Oberste Direktive (179, Chef 18.10.): Fehler ausmerzen, Kapitel 1 spielerfreundlich.** Darum zusätzlich Muss, jeweils vor jeder Kür: gemeldete Fehler und Spielbarkeit: 176 Licht Fackel/Funke, 175 Ruckeln nach der Blende, 173 Met, 20.4 Status „Met“, 174 Plätze, 172 Kampf zu langwierig, 154/155 Goldverlust und Höhlenfeuer, 39 Schwierigkeitsgrad, 84.1T Texte. Neue Fehler des Chefs oder von Diogenes kommen als Muss dazu. Stand 23.10. (`LISTE-VORGAENGE`): erledigt 172–176, 155; 154 im Test; 39 wartet.

Dazu Muss auf Zuruf des Chefs („jetzt“): D21 (Abgleich Vorrat gegen Chefsache, Tom und Jerry). Nicht diese Woche, weil Neues nach dem Meilenstein: Kampfprobe 72.10 und Kampfort 72u (Gruppenkämpfe), Kapitel 2 (41, 72s.1); der Chef kann jede Zeile mit „jetzt“ vorziehen.

## Pflicht in Block (a) Kapitel 1 rund

- [x] **Alle Orte „Ort fertig“** (`DESIGN-ABNAHME.md`): Dorf (5), Räume (13), Wald (27), Höhle (13e, seit 17.10.) erledigt; offen nur Mondlicht und Schacht nachts (D3.14 mit Fackel 84.1, Kür). Prüft das Team, nicht der Chef.
- [ ] **Läuft rund:** kein Schweben nach Start und Kartenwechsel, Zwischenbild (24; 24.6 wartet auf den Kampfort 72u); Sprungtest und Kollisionsprüfung 0; „Bewegungen unrund“ (19e) geklärt.
- [ ] **Ausgleich:** alle vier Klassen schaffen die Bosse in vergleichbarem Maß (Magier gegen Grak 44–62 %); Zielwert mit dem Chef festlegen (38).
- [ ] **Durchgespielt:** der Chef spielt Kapitel 1 einmal ganz durch; Zufallsspieler (`PlayerSimTest`) grün (26).

Erledigt (Verlauf in Git): alte Ansicht ausgebaut (13t), Gegner im neuen Stil (9i), Musik neu (28), Nebenquests (29), Kartenansicht (62), Tagesablauf (5la).

**Wenn Zeit ist (kein Hindernis für den Test):** Stimmen der Gegner (18), Schritte je Untergrund (74), Raumklang (119).
