# Projektplan Kapitel 1

Bis 02.11. „Abnahme Kapitel 1“ (`LISTE-ABNAHME-KAPITEL1.md`, umbenannt mit 479, Chef 02.11., 18:34).

**Oberste Direktive (Chef 31.10., Archiv 418):** Kapitel 1 in der Godot-Fassung mit dem Bornimer Rollenspielsystem (BRS, 451) fertigstellen: ohne technische Fehler, gut aussehend, nach unserer Signatur, düster, professionell und immersiv durch Klang, Musik, Kampfsystem und die Möglichkeiten des Spielers. Qualität vor Quantität und vor Eile; es gibt keinen Termin. Fertig ist, was die Abnahmeliste erfüllt. Geht jeder Kür und jedem Neuen vor.

**Stufen statt eines Meilensteins** (447, Chef 01.11.: „447 ja, mit K2b, aber nummeriere das Ganze doch neu und vernünftig durch“): sechs Stufen ohne Datum, jede ein spielbarer Build mit einer Prüfung. **„Kapitel 1 fertig“** = Stufen 1–4 abgehakt; **„marktreif“** (338) = Stufe 5; Stufe 6 nach dem Marktstart. Punkte heißen „Stufe.Punkt“ (z. B. „3.2“), der Buchstabe danach ist der Bereich (T Technik, A Aussehen, K Klang, M Kampf, G Regelwerk BRS, W Möglichkeiten des Spielers, S Store). Ein Punkt wird erst abgehakt, wenn er ganz fertig ist, nicht „gut genug für die Stufe“. Was unter die Abnahmeliste fällt, ist Muss; Kapitel 2, Berufungen, Gruppenkämpfe, Dungeons, Bergbau erst danach. Abhaken darf nur, wer in der Zeile als Prüfer steht; „Chef“ heißt: erst nach seinem Wort. **Stand je Punkt** (448): ohne Marke offen; am Zeilenende „· Stand: in Arbeit“ oder „· Stand: gebaut“ (setzt Perikles nach den Vorräten); abgehakt = abgenommen; der Tagesbericht zählt je Stufe (`tools/tagesbericht.py`). Liest Ford beim Start (Wochenziel); sonst nur bei Anlass.

## Abnahmeliste Kapitel 1 (418, abgenommen vom Chef 01.11., 09:43; in Stufen seit 447, 01.11.; 418 Umfang A gilt nicht mehr)

**Wie du die Verweise findest** (484): „E 7“ = Entscheidung 7 in der Liste [Entscheidungen zum BRS](DESIGN-BRS-ENTSCHEIDUNGEN.md); „NW 5“ = Abschnitt 5 im [Regelwerk des Bornimer Rollenspielsystems](DESIGN-BRS.md) (E 84); eine Zahl ohne Buchstaben ist ein Vorgang. Gilt nur, was entschieden ist; neue Entscheidungen gehen hier ein. Alle Zahlen sind Startwerte; abhakbar mit Zahlen erst nach der Rechensimulation (444). Termine gibt es keine; Wochenziele nennen Reihenfolge und Schätzung, keine Tage je Punkt. Alte Kurzzeichen (T1 … S1, bis 01.11.): Git, Stand vor „Perikles: 447.1“.

**Stufe 1 · Kern spielbar** (Prüfung: Rechensimulation 444 abgenommen; der Chef spielt Dorf und Wald an)
- [x] **1.1** G · Ohne Klassen (E 1): Erschaffung mit sechs Grundwerten ab 1, 21 Punkte, jeder Wert 3 bis 8 (E 77); fünf Völker mit Bonus, Malus und Merkmal, Volk hebt bis 9, nie unter 3 (E 70, 72, 78); Herkunft freiwillig oder Wanderer, Startfertigkeiten bei 10 (E 68, 69; NW 2). Ins Spiel erst mit 2.3; bis dahin im Testmenü zu sehen (470a: „C“, aber der Rechenkern des Kampfs ist mit 3–4 Sitzungen über 2 geschätzt, darum gilt B). · Stand: abgenommen (720, Chef 09.11., 14:49)
- [ ] **1.2** G · Fertigkeiten steigen durch Tun, Wert 0–100 in vier Rängen, am Rangende Halt mit kleinem Puffer bis zur Prüfung (E 67, E 44); Kapitel 1 bis Geselle (49) mit Bewährungsproben zum Gesellen (Takt, NW 5); Prüfregel und die 37 (E 59); Hinweis beim Aufstieg, Heldenblatt zeigt nur Getanes (NW 3). (471 in t274 bestanden; Bewährungsproben und Lehrmeister mit 2.6, 3.1) · Stand: gebaut
- [ ] **1.3** G · Heldenstufe aus Erfahrung (E 16), höchstens 40 % aus Fertigkeitsaufstiegen (E 17); Kapitelgrenze weich bis zwei Stufen darüber (E 18, E 35); Erfahrungstopf je Gebiet, Wiederkehrer geben kaum Erfahrung, aber Beute (E 19, E 21). · Stand: gebaut
- [x] **1.4** M · Neue Monsterwerte für Kapitel 1 nach dem BRS auf Rechenmodell D (E 73–75, NW 7). · Stand: abgenommen (720, Chef 09.11., 14:49)

**Stufe 2 · Kapitel 1 durchspielbar** (Prüfung: Zufallsspieler spielt Kapitel 1 durch; Kollision 0; Kapitelsimulation: jede Herkunft schafft die Bosse; der Chef spielt einmal grob durch)
- [ ] **2.1** T · Kollision und Sprungtest 0 in jedem Ort; kein Schweben nach Start und Kartenwechsel (24); Tippen trifft, was gezeichnet ist.
- [ ] **2.2** T · Kerntests der Regeln des BRS als GDScript-Tests grün; Zufallsspieler spielt Kapitel 1 im neuen Spiel durch (26). · Stand: in Arbeit
- [ ] **2.3** M · MARS rund auf den Regeln des BRS (`DESIGN-BRS.md` 7, Rechenmodell D; nur MARS, `klassisch.gd` entfällt, 870a 2 ersetzt 212 A): kein W20, Trefferchance und Proben als Prozent (870a 5), jeder Angriff sichtbar (249), Ansage harter Schläge, Pechsträhne als Prozent; Zahlen 444. Umzug BRS (870): Held, Kampf, Beute mit Build 277 auf `main`, Laden und Kotlin-Ausstieg in Build 278. · Stand: in Arbeit
- [ ] **2.4** M · Kampf nie langweilig, echte Wahl (`DESIGN-LEITBILD.md`); Schwierigkeitsgrade (39).
- [ ] **2.5** M · Ausgleich gemessen, nicht geschätzt: Simulation „Zeit bis Stufe“ und Kapitelsimulation auf den Regeln des BRS (444); jede Herkunft und der Wanderer schaffen die Bosse in vergleichbarem Maß; Zielwert mit dem Chef festlegen (38).
- [ ] **2.6** G · Lehrmeister spricht an, sobald zwei Kernfertigkeiten eines Pfads Geselle sind; Anwärter möglich (E 63, E 79; Takt NW 5); Bewährungsprobe zum Gesellen siehe 3.1.
- [ ] **2.7** G · Jede Herkunft hat in Kapitel 1 eine Handlung (Chef 01.11., 09:43): Wachsoldat, Jägerkind, Zauberlehrling, Klosterschüler, Herumtreiber im Kampf und mit Schleichen und Spähen; Kräutersammler: Kräuter sammeln und ein Rezept Heiltrank; Schmiedelehrling: Reparieren bei Borin.
- [ ] **2.8** G · Schleichen mit Schleichtaste und Hinterhalt, Bosse wachsamer (E 55, E 47); Spähen durch Verweilen findet Fallen, Kräuter, Truhen, Wahrnehmung verstärkt (E 57, E 83), dann entschärfen; Truhen mit Dietrich, Truhen in Häusern der Leute zu (E 55, E 46); schwere Rüstung sperrt Schleichen, Metall sperrt Evokation, Illusion, Beschwörung (E 33, E 80); kein Stehlen, kein Barde (E 30, E 31).
- [ ] **2.9** G · Kurze Erholung 2 h, Langes Ausruhen 9 h (E 26); Tragkraft mit Nimmersatt-Beutel, darüber langsamer (E 41).
- [ ] **2.10** G · **Bauweise** (Chef 01.11., 09:43): Leute, Orte und Gegenstände haben beim Bau Datenfelder für Ruf, Rezept und Zustand (in Stufe 3 gefüllt); jede Zahl steht in einer Datendatei, nicht im Code (422, 444).
- [ ] **2.11** W · Jeder Ort, jede Hauptquest und Nebenquest, jedes Gespräch, Laden, Anschlagbrett, Tagesablauf, Hilfe aus dem alten Spiel geht in Godot mindestens so (`LISTE-ABGLEICH-ALT.md`, 348.9, 620.2), außer was das BRS ersetzt. · Stand: in Arbeit
- [ ] **2.12** W · Spielerfreundlich (`DESIGN-LEITBILD.md` 3): auf „Normal“ ohne Grinden schaffbar.
- [ ] **2.13** M · **Alle Gegner von Kapitel 1 im Spiel** (Chef 05.11., 08:2x; 579): jeder Gegner der alten Fassung (`Story.kt` Flüsterwald, Tiefer Wald, Blutzahnhöhle, Tag und Nacht) mit Modell auf der Karte und im Kampf, eigener Kennung (577), Klang und Kampfblende. Haken = vom Chef im Build gesehen. Stand 05.11., 08:2x:
  - [x] Wolf (gekauft) · [x] Riesenratte (gekauft) · [x] Goblin · [x] Kobold · [x] Goblin-Schamane · [x] Goblin-Bogenschütze (alle im Build 257)
  - [ ] Riesenfledermaus: nur Kapsel, Modell in 510
  - [x] Wildschwein · [x] Riesenhundertfüßer · [x] Riesenspinne · [x] Riesenegel (für Stirge) · [x] Säureschnecke (für Ockergallerte): Haken 720 (Chef 09.11., 14:49, im Probekampf gesehen); auf der Karte nachts und in der Höhle noch nicht prüfbar (539, 492)
  - [ ] Skelett · [ ] Zombie · [ ] Ghul: fehlen (506)
  - [ ] **Bosse:** [ ] Grimmzahn neu auf dem Kaufwolf (533; heute altes Modell, Kampf und Leibwache gehen) · [ ] Krogg (bugbear) · [ ] Grak (hobgoblin_captain): mit der Blutzahnhöhle (492)
- [ ] **2.14** W · **Alle Orte von Kapitel 1 begehbar** (Chef 05.11., 08:2x). Haken = im Build begehbar wie alt, vom Chef gesehen; „Ort fertig“ (4.3) kommt danach. Stand 05.11.:
  - [x] Bornim (Dorf) · [x] Flüsterwald · [x] Tiefer Flüsterwald (491, „passt fürs Erste“; Schild am Eingang und Morwens Hütte offen)
  - [x] Zum Schlafenden Greif (Schänke) · [x] Thessas Kramladen · [x] Haus des Ältesten · [x] Tempel des Morgenlichts: Haken 720 (Chef 09.11., 14:49)
  - [ ] **Blutzahnhöhle:** fehlt im Build (492 seit 08.11. wieder in Arbeit; neu nach Signatur)
- [ ] **2.15** W · **Hauptquest von Kapitel 1 einmal durchgespielt**, Station für Station (Testmenü „Stationen“, 555; Chef 05.11., 08:2x). Haken = der Chef hat die Station im Build gespielt. Stand 05.11.:
  - [x] 1 Garrick (Schlagbaum, t257 251.7) · [x] 2 Morwen (t257 251.2) · [x] 3 Grimmzahn (Kampf, t257 252.7; Blende, Tod offen)
  - [ ] 4 Höhle · [ ] 5 Krogg · [ ] 6 Grak · [ ] 7 Lyra: warten auf die Höhle (492)
  - [ ] 8 Kapitelende (Aldric, Amulett, Brief)
- [ ] **2.16** A · **Alle Leute von Kapitel 1 mit eigenem Gesicht** (475; Chef 05.11., 08:2x). Haken = Gesicht vom Chef abgenommen, keine zwei gleich, Gesicht frei. Stand 05.11.: keiner abgenommen (Lauf 1 nein, 04.11., 20:47)
  - [ ] Aldric · [ ] Borin · [ ] Bram · [ ] Garrick · [ ] Gwenna · [ ] Jorin · [ ] Liska · [ ] Morwen · [ ] Osric · [ ] Pim · [ ] Rowena · [ ] Thessa · [ ] Lyra (mit 492)
- [ ] **2.17** M · **Alle Zauber und Fähigkeiten bis Stufe 6 im Kampf zu sehen** (Chef 05.11., 08:2x). Haken = im Kampf gewirkt und vom Chef gesehen. Seit dem Umzug BRS (870a 3 A, Chef 10.11., 15:08) hängen Kampfhandlungen an Fertigkeiten statt an Klassen; Extra-Angriff, Doppelzug, Zweiwaffenkampf entfallen. Vollständige Liste und Zahlen: Jerry mit 444 (870.5), Namen Homer (870.14); bis dahin:
  - Für alle: [ ] Kraft schöpfen (einmal je Kampf)
  - Ab Geselle je Fertigkeit: [ ] Einhänder: Finte · [ ] Dolche: Stich aus dem Hinterhalt · [ ] Zweihänder: Wuchtschlag · [ ] Schild: Vorform von Decken · [ ] Bogen: Vorform von Zielschuss
  - Zauber nach Schule (`DESIGN-BRS.md` 12): [ ] Kleinzauber · [ ] Funkenpfeil · [ ] Arkanpfeil · [ ] Flammenfächer · [ ] Arkanhaut · [ ] Glutkugel · [ ] Gleißstrahl · [ ] Wundsegen · [ ] Beistand · [ ] Bannschild
  - Effekte dazu nach dem Kauf (415d.1, Film 572)

**Stufe 3 · Alle Systeme angelegt** (447 „mit K2b“, Chef 01.11.: „alle Elemente grundsätzlich drin … die Anlagen sollen schon erkennbar sein“; je System ein kleiner, ganzer Kreislauf mit spürbarer Wirkung, kein leerer Knopf. Prüfung: je Punkt ein Spieltest „merkt man, was das kann?“; 444 rechnet Gold, Reparatur und Tränke mit)
- [ ] **3.1** G · Pfad und Lehrmeister: Einladung, Anwärter, Hinweise und Aufgaben des Lehrmeisters, Bewährungsprobe zum Gesellen je Pfad, den Kapitel 1 trägt (Jorin Wächter, Osric Heiler und Paladin, Garrick Waldläufer und Scharfschütze, Thessa Schatzjäger, Morwen Magier und Kriegsmagier; NW 5, E 79, Archiv 447.4a); Zwischenprüfung ab Kapitel 2 (447.5).
- [ ] **3.2** G · Meisterschaften: Einladung zu dreien (Alchemist Morwen, Schneider Garrick, Feldkoch Rowena; 975a); Schmied und Runenmeister laden ab Kapitel 2 ein, Schmieden und Runenkunde üben und benutzen geht in Kapitel 1 (Archiv 447.4a); Alchemie (Kräuter → Heiltrank) und Schmieden (Reparatur, Dietrich) ganz, Schneidern, Runen, Kochen je ein Rezept (NW 6; Texte der Einladungen Homer).
- [ ] **3.3** G · Ruf bei den Leuten im Dorf; Wirkung sichtbar: Preis bei Borin und Händler, eine Auskunft mehr (NW 9; Ruf-Gespräche Homer).
- [ ] **3.4** G · Herstellen und Sammeln: Kräuter, Fisch, Jagd mit Zerlegen; Rezepte am Lagerfeuer und an Werkorten im Dorf; kein Bergbau (Chef 01.11., 11:55: „Erze brauchen wir doch noch gar nicht“), Erz für Schmieden und Runen nur kaufen oder finden (NW 10).
- [ ] **3.5** G · Abnutzung und Reparatur: Zustand, Borin repariert, „Alles reparieren“ (NW 11).
- [ ] **3.6** G · Tiere beruhigen an Wölfen und Wildschwein; Tierbegleiter erst mit dem Pfad Waldläufer (NW 8).
- [ ] **3.7** G · Profil: Taten und Chronik (Entwurf C, Entscheidung 76).
- [ ] **3.8** G · Gegenstandskatalog: jeder Gegenstand mit Platz, Stufe, Preis, Modell und Bezugsweg in `tools/gegenstaende/gegenstaende.json`, das Spiel liest nur ihn; Übersicht `LISTE-GEGENSTAENDE.md` erzeugt (458).

**Stufe 4 · Kapitel 1 fertig** (Prüfung: der Chef spielt ganz durch und sagt „gut“)
- [ ] **4.1** T · Kein Absturz, kein Hängenbleiben, kein Ruckeln auf den Testgeräten des Chefs (Handy und Tablet, 267); Spielstände halten über Updates.
- [ ] **4.2** T · Jeder Fehler aus den Tests des Chefs behoben (Prüfer: Chef). · Stand: in Arbeit
- [ ] **4.3** A · Jeder Ort „Ort fertig“ nach `DESIGN-ABNAHME.md`, sinngemäß in Godot: Dorf, Räume, Flüsterwald, Tiefer Flüsterwald, Blutzahnhöhle.
- [ ] **4.4** A · Jede Figur, jedes Haus, jedes Ding im Bestand `LISTE-ABGLEICH-ALT.md` 6 auf „abgenommen“ (Prüfer: Chef; Diogenes misst nebenher, 373). · Stand: in Arbeit
- [ ] **4.5** A · Signatur nach `DESIGN-STIL.md`: schwarz-gold, Tusche, düster und lesbar; Hauptmenü, Erschaffung, Menüs, Vorspann und Zwischenbilder im selben Look (Prüfer: Chef).
- [ ] **4.6** K · Musik je Ort, Tageszeit und Kampf; Umgebung aus echten Aufnahmen je Ort.
- [ ] **4.7** K · Schritte je Untergrund (74), Raumklang in Innenräumen und Höhle (119), Stimmen der Gegner (18); bisher „wenn Zeit ist“, jetzt Muss, weil die Direktive Klang nennt (Prüfer: Chef).
- [ ] **4.8** G · Namen nach dem Glossar, keine SRD-Begriffe im Spiel (E 24, E 25, E 27; NW 12; `regelcheck` zählt die Reste, 446). Wächter 870.11 greift, Aufräumen 870.13 nach dem Kotlin-Ausstieg. · Stand: in Arbeit
- [ ] **4.9** W · Englisch durchgehend (Homer, Tom).
- [ ] **4.10** W · **Durchgespielt:** der Chef spielt Kapitel 1 einmal ganz durch und sagt „gut“ (Prüfer: Chef).

**Stufe 5 · marktreif** (338; Prüfung: Kapitel 1 öffentlich im Play Store)
- [ ] **5.1** S · Store-Seite, Texte und Bilder (Homer, Sokrates); Impressum (Datenschutzseite online, 252); Gewerbeschein und Preis (142, 45); Repo privat (109); 12 Tester, geschlossener Test 14 Tage, Prüfung durch Google. Vorlauf (142, 109, 142.3) läuft schon jetzt daneben, weil er lange dauert. · Stand: in Arbeit

**Stufe 6 · SRD im Code abgelöst** (nach dem Marktstart; der Spieler sieht es nicht)
- [ ] **6.1** G · Auch im Code keine SRD-Werte mehr, der Lizenzhinweis „SRD 5.1 · CC BY 4.0“ entfällt; `regelcheck` ohne Treffer (446).

## Orte und Welt je Zeile (479, Chef 02.11., 20:14: „479 (1) ja. (2) A.“; ersetzen 2.11 und 4.3)

Quelle: der alte Kotlin-Code (`core`, `app`), abgeglichen mit `LISTE-ABGLEICH-ALT.md` und dem Stand in `godot/` auf `main` (Arbeitszweige nicht mitgezählt). Je Zeile zwei Häkchen: **begehbar** (Stufe 2: geht im Spiel wie alt) und **fertig** (Stufe 4: „Ort fertig“ oder „gut“ von dir). Stand Godot: **da** = vorhanden, **teils** = nur ein Teil, **fehlt**.

**Orte** (acht Karten im alten Spiel; die Blutzahnhöhle hat eine Ebene)

| Nr. | Ort | Godot heute | begehbar | fertig |
|---|---|---|---|---|
| O1 | Dorf Bornim (5 Leute, Hühner, Hund, Vögel, Schmetterlinge) | da (Build 146) | [ ] | [ ] |
| O2 | Gasthaus „Zum Schlafenden Greif“ (Rowena, Borin, Katze) | da | [ ] | [ ] |
| O3 | Thessas Kramladen | da | [ ] | [ ] |
| O4 | Haus des Ältesten (Aldric) | da | [ ] | [ ] |
| O5 | Tempel des Morgenlichts (Osric, Lyra nach der Rettung) | da | [ ] | [ ] |
| O6 | **Flüsterwald** (Garrick, 11 Gegnerarten, Teiche, Frösche, Libellen) | **fehlt**: der Weg in den Wald startet nur einen Kampf (490, Spike) | [ ] | [ ] |
| O7 | **Tiefer Flüsterwald** mit Morwens Hütte, Endgegner Grimmzahn | **fehlt** (491, Spike) | [ ] | [ ] |
| O8 | **Blutzahnhöhle** (Lyra gefangen, Endgegner Krogg und Grak, 10 Gegnerarten; Krogg erst abnehmen, wenn Morwens Rauch aus O7 im Spiel zu bekommen ist, 427.1) | **fehlt** (492, Tom) | [ ] | [ ] |
| O9 | Kampforte Wald (Lichtung, Waldrand, Teich, Baum, Felsen, Steinkreis) | teils: nur die Lichtung (493, Spike) | [ ] | [ ] |
| O10 | Kampforte Höhle (Eingang, Gang, Halle, Teich, Lager) | fehlt (507, Jerry) | [ ] | [ ] |

**Welt** (gilt an jedem Ort)

| Nr. | Merkmal | Godot heute | begehbar | fertig |
|---|---|---|---|---|
| W1 | Tageszeit, Tag und Nacht | da | [ ] | [ ] |
| W2 | Schatten nach Sonnenstand (morgens, mittags, abends) | da | [ ] | [ ] |
| W3 | Wetter: Regen, ferne Blitze und Donner, Regen als Klang | fehlt | [ ] | [ ] |
| W4 | Spuren: Fußspuren nach Regen, Blut, Staub beim Rennen (auch im Regen) | teils: Regeln da, im Spiel nicht aufgerufen | [ ] | [ ] |
| W5 | Tagesablauf der Leute, Stammplätze | teils: Tagesablauf da, Stammplätze fehlen | [ ] | [ ] |
| W6 | Leute machen auf sich aufmerksam (Zeichen, Geste: Hand heben, winken, nicken, Krug heben) | teils: Zeichen da, Geste fehlt | [ ] | [ ] |
| W7 | Leute schauen den Helden an, wenn er nah ist, nach 10 s nicht mehr | teils: nur beim Ansprechen | [ ] | [ ] |
| W8 | Ruhebewegungen aller Figuren (Leute, Monster, Tiere) und Atmen im Stand | teils: Leute da, Monster nur im Kampfort, Atmen außerhalb fehlt | [ ] | [ ] |
| W9 | Garrick am Feuer (nickt ein, fährt auf, wenn der Held kommt) | fehlt | [ ] | [ ] |
| W10 | Rudel und Leibwache folgen dem Anführer auf der Karte | fehlt | [ ] | [ ] |
| W11 | Jedes Tier und Lebewesen mit eigenem Laut (Vögel, Grillen, Eule, ferner Wolf; Monster schnüffeln, knurren) | fehlt (Hühner da) | [ ] | [ ] |
| W12 | Umgebungsklang je Ort (Fluss, Teich, Tropfen, Feuer, Raumklang) | teils: Teich fehlt | [ ] | [ ] |
| W13 | Musik je Ort und Tageszeit | da | [ ] | [ ] |
| W14 | Schritte je Untergrund, Keuchen | da | [ ] | [ ] |
| W15 | Licht: Fackel, Sichtweite des Helden | teils: Sichtweite fehlt | [ ] | [ ] |
| W16 | Ortslicht: Laternen, Fenster, Kerzen, Pilze, Kristalle, Mond | teils: Pilze, Kristalle fehlen | [ ] | [ ] |
| W17 | Feuerschein auf Figuren | fehlt | [ ] | [ ] |
| W18 | Wasser lebt (Glitzern, Regenringe, Lichtspiegel) | teils | [ ] | [ ] |
| W19 | Kartenrand: Wald läuft ins Dunkel | fehlt | [ ] | [ ] |
| W20 | Rauch aus Kaminen | da | [ ] | [ ] |
| W21 | Kleinleben Dorf: Katze, Hund, Vögel fliegen vor dem Helden auf | fehlt (Hühner, Ziege, Kaninchen da) | [ ] | [ ] |
| W22 | Kleinleben Wald: Frosch, Libelle, Schmetterling, Glühwürmchen | teils: Schmetterling, Glühwürmchen | [ ] | [ ] |
| W23 | Leute auf eigenem Modell statt eines gemeinsamen Kopfs (475) | teils | [ ] | [ ] |
| W24 | Nebel des Krieges in der Wildnis wie alt: schwarz, was nie gesehen wurde, gedämpft, was gerade nicht in Sicht ist (`Fog.kt`; 502, Chef 03.11., 07:30) | fehlt (505, Tom) | [ ] | [ ] |
| W25 | Sichtfeld des Helden: Bäume, Felsen, Wände sperren die Sicht; Form vor dem Bau als Vorlage an dich (alt Kegel 160° plus kleiner Kreis; 502) | fehlt (505, Tom) | [ ] | [ ] |

„da“ heißt nur: im Code gefunden, nicht von dir abgenommen. Geprüft nur Kopf und einzelne Stellen der Godot-Dateien; ob jedes Merkmal dem alten Stand voll entspricht, sagt erst dein Häkchen.

## Wochenziel 09.–15.11.: Der Kampf funktioniert (Perikles, gesetzt 09.11., 10:1x; neu geordnet 12.11., 16:5x nach 1052; ersetzt das vom 03.11.)

**Du kämpfst im nächsten gemeinsamen Build (281) gegen Wölfe, Ratten und Grimmzahn und sagst „Kampf passt“: der Held sieht ordentlich aus, jeder Angriff trifft den Gegner sichtbar, der Kampf zeigt, was geschieht (Ring lesbar, Ausweichen, Angriff mit Bewegung, Zustände an den Figuren, Bericht in Farbe), die Gegner laufen frei statt auf Schienen, drehen mit Schritten und zeigen dir nicht den Rücken, der Kampf ist flott.** Der Umhang gehört nicht mehr dazu: gestoppt, Vorlage für irgendwann (861, Chef 12.11., 07:10). Grundlage: „Kampf zuerst, nichts Neues“ (Chef 08.11., 21:36, Archiv). Muss sind nur die Zeilen unten, deine „jetzt“, deine „bitte machen“ und Abstürze. Was ohne Kampfbezug neu gebaut würde, ruht mit dem Stand „ruht, Kampf zuerst (338.1)“; gestrichen wird nichts. Kür baut diese Woche keiner. Termine gibt es keine, die Reihenfolge gilt. Der alte Stand (Build 271, Schritte 1–8 vom 09.11.): Git, Stand vor „Perikles: 1052“.

| Reihenfolge | Vorgang | Wer | fertig, wenn |
|---|---|---|---|
| 1 | Build 280 auf `main`: 1029 schalter_1024 grün, PR #199 zusammenführen (deine Freigabe 15:55) | Jerry | PR #199 gemischt; an 280 hängen alle neuen Zweige beider Teams |
| 2 | **Sammelbuild 281** gleich danach (1055): alle fertigen Zweige beider Teams (45 Punkte warten: Tom 14, Jerry 31); Prüfliste als Kampfweg, Kampf zuerst, jede Zeile ohne Vorwissen prüfbar, gegengelesen vor dem Baustart (1020.1) | Jerry stellt zusammen; du testest | dein Test von t281, danach `vorgang.py build 281`; löst die Sperre 620.1 B beider Teams |
| 3 | **Der Kampf zeigt, was geschieht** (ein Paket, am Kotlin-Bild gemessen): 1039 Ring lesbar, 1043 Ausweichen sichtbar, 1025 und 1032 Angriff mit Bewegung, 1036 Zustände an Figuren, 1031 Bericht in Farbe; was davon gebaut ist, fährt in 281 | Jerry | dein Probekampf in 281: jede Handlung ist zu sehen |
| 4 | Drehen mit Schritten: 1040 Grimmzahn, 1040.1 Leute (Wiederholfund t268) | Jerry, Tom | keine Figur dreht sich mehr wie eine Puppe auf der Stelle |
| 5 | danach Jerry: 1041 Platztausch im selben Takt, 1034 ein Probekampf für alles; Ring öfter (1048, Vorlage bei dir) wird erst nach 1039 gebaut | Jerry | wie in der Zeile |
| 6 | Tom: übrige Funde aus t280 (1022 Kartenrand, 984.1), dann 1044 Standpose der Frauen (dein „bitte machen“ 16:08); Tom hat Luft und bietet Jerry Übernahme an (`ROLLE-ENTWICKLUNG.md`, Stau 114 Muss bei Jerry) | Tom | wie in der Zeile |

**Stärkstes Gegenargument zur neuen Ordnung:** Ein Sammelbuild mit 45 Punkten ist schwer zu testen, und die Funde aus t280 kämen mit einem kleineren Build schneller. **Entkräftet:** beide Teams stehen unter Sperre, bis getestet ist; ein Build löst beide, die Prüfliste stellt den Kampf nach oben, du kannst nach dem Kampfteil abbrechen und den Rest später prüfen.

**Große Punkte danach, in dieser Reihenfolge** (1061, Perikles 12.11., 17:4x, auf Chef 17:42 „erst einen Umzug fertig machen, dass wir 431 wieder als Thema grundsätzlich anfassen“):
1. **Umzug BRS fertig** (läuft neben dem Kampf): 882.1 Tom, 882.2 und 870.10 Perikles (Kotlin-Bau aus), 870.13 Tom (Aufräumen, SRD-Hinweis raus).
2. **Kampf passt** (Wochenziel oben, t281).
3. **431 Körper je Volk im Helden** (Tom, gleich nach 870.10): zuerst Aufwand vorlegen (Kleidung und Rüstung auf fünf Körpern, Völker im Umriss deutlich verschieden), bauen erst nach deinem Ja. Vor jedem weiteren Figurenfeinschliff (372, 397, 513, 1044 ausgenommen), weil Kleidung und Rüstung sonst zweimal angepasst werden.
4. **Kapitel 1 durchspielbar** (Stufe 2): 492 Höhle, 505 Nebel und Sichtfeld, 494 übrige Gegner, 507 Kampforte Höhle, 506 Untote, 495 Zufallsspieler, 496 Durchspiel-Build. Läuft mit 3 nebeneinander (Spike und Jerry), sobald der Kampf passt.
5. **Was der Spieler tun kann nach BRS** (2.6–2.9): Lehrmeister, Handlung je Herkunft, Schleichen, Spähen, Truhen (515), Rast und Tragkraft, Ernten (568).
6. **Welt lebendig wie alt** (2.11): Leute, Dinge, Innenräume, Nacht, Kleinleben (614, 637–640, 665, 509), Klang je Ort und Monster (598, 517, 936–938).
7. **Ausgleich gemessen** (2.5): Kapitelsimulation, jede Herkunft schafft die Bosse (1050, 38).
8. **Aussehen fertig:** Tusche nach Licht (348.13, 348.13b, 302.1), Held im Feinschliff (372), Ruhebewegungen (397); danach Store (622 AAB, 142).

**Stärkstes Gegenargument:** 431 vor dem Durchspielen schiebt Höhle und Nebel weiter, Ziel seit 03.11. **Entkräftet:** 431 ist Figurenarbeit bei Tom, Höhle und Nebel laufen bei Spike und Jerry daneben; der Held ist, womit sich der Spieler identifiziert (Chef 17:38), und jeder Figurenfeinschliff vor 431 wäre doppelte Arbeit.

**Mit diesem Wochenziel entschieden (Perikles):** M? der Prüferbefunde 725–742 → K, meine ruhen; 515 Truhen und 568 Ernten → M (Abnahme 2.8, 3.4), ruhen bis „Kampf passt“; Reifes aus `LISTE-IDEEN.md` holt diese Woche keiner (nichts Neues); „Verwerfen?“ als eine Chefsache (743).

## Wochenziel 03.–08.11.: Kapitel 1 durchspielbar (Perikles, gesetzt 03.11., 07:1x nach 488; ersetzt durch das Wochenziel 09.–15.11. oben; nicht erreicht, 496 nicht gebaut)

**Du spielst Kapitel 1 einmal von Anfang bis Ende am Handy: vom Dorf durch den Flüsterwald und den Tiefen Flüsterwald bis in die Blutzahnhöhle und zurück zu Aldric.** Grundlage 488 (Chef 03.11., 06:44, „488 ja“): Feinarbeit am Aussehen ist eingefroren; Vorrang hat, was zum Durchspielen fehlt. Die Geschichte von Kapitel 1 (alle Gespräche und Quests bis „chapter1_done“) ist in Godot schon gebaut (390, `geschichte.gd`), ebenso Kämpfe gegen Wölfe, Grimmzahn, Grak und Goblins im Kampfort zum Ausprobieren (`kampf/probe.gd`); Ratten, Fledermäuse und Spinne stehen dort nur als Wolfsfigur. Es fehlen die Orte außerhalb des Dorfs und ein Teil der Gegner. Muss sind die Zeilen unten und was du ausdrücklich „jetzt“ sagst; alles andere ist Kür oder wartet „nach dem Durchspielen“ (Liste unten). Bis Sa 07.11., 20:00 arbeiten nur Tom, Jerry und Spike (468a).

| Reihenfolge | Vorgang | Wer | fertig, wenn | Schätzung |
|---|---|---|---|---|
| 1 | Build 204 testen (t204); 489 Musik- und Effektschalter im Hauptmenü, 406.2 Angriff gehen und Parade (deine „jetzt“) | du; Jerry | wie in der Zeile des Vorrats | – |
| 2 | **Wald:** 490 Flüsterwald, 505 Nebel des Krieges, 491 Tiefer Flüsterwald mit Morwens Hütte und Grimmzahn (479 A), 493 Kampforte Wald, 506 Untote (Skelett, Zombie, Ghul) | Spike (Team Tom) | Held geht vom Dorf in den Wald und weiter, trifft Garrick und Morwen, Gegner stehen auf der Karte und starten den Kampf, Kräuter, Teiche, Kartenrand; geht wie alt (`Story.kt:524`, `:619`) | etwa 18 S: Wald 4, Tiefer Wald 3, Kampforte 3, Untote 8 (348.14, dort mit Bilderrunden) |
| 3 | **Gegner:** 494 Wildschwein, Riesenspinne, Hundertfüßer, Stirge, Ockergallerte, Krogg, Ratten und Fledermäuse mit eigener Figur (348.12 Goblin gehört dazu); 507 Kampforte Höhle | Jerry | jeder Gegner aus dem alten Spiel kämpft an seinem Ort; Modelle in der Reihenfolge, in der du ihnen begegnest, je Gegner höchstens ein Lauf, Feinarbeit danach | etwa 18,5 S: Gegner 15,5, Kampforte Höhle 3 (348.14 vom 26.10., mit Bilderrunden) |
| 4 | **Höhle und Prüfung:** 492 Blutzahnhöhle mit Grundriss, Krogg, Grak, Lyra, Tor und Schlüssel; 495 Zufallsspieler spielt Kapitel 1 in Godot durch (Abnahme 2.2) | Tom (nach den Befunden aus Build 204) | Höhle geht wie alt (`Story.kt:731`); ein Programm spielt Kapitel 1 bis „chapter1_done“ durch und meldet, wo es hängenbleibt, bevor du spielst | Höhle etwa 8 S, Zufallsspieler schätzt die erste Sitzung |
| 5 | 496 Durchspiel-Build aus 2–4 und 478 (dein „jetzt“ 07.11.) | Jerry stellt zusammen | du spielst Kapitel 1 ganz durch; deine Befunde sind Muss, Aussehen nach Gewicht | – |
| vor 5 (478 jetzt, 07.11.) | 478 Rechenkern des Kampfs auf BRS, dann 2.3 mit Tom (470 Erschaffung, 471 Fertigkeiten, 472, 473 ins Spiel) | Jerry, Tom | wie Abnahme 2.3 | 3–4 Sitzungen (478) |

**Kampf im Durchspiel-Build nach dem BRS** (478, Chef 07.11., 16:3x: „Wir packen das BRS auf jeden Fall jetzt auch mit dazu“; ersetzt die Abwägung darunter): 478 und danach 2.3 kommen vor 496, parallel zu 492 und 505. *Bisher (03.11.):* er rechnet noch nach dem alten Regelwerk; das BRS kommt mit 2.3 gleich danach. **Stärkstes Gegenargument:** Was du beim ersten Durchspielen über Kämpfe sagst, gilt nur bedingt, weil 2.3 die Zahlen ändert; die Oberste Direktive verlangt das BRS. **Entkräftet:** Orte, Wege, Geschichte und Gegner hängen nicht an den Regeln; du sagtest „dass irgendwann das Spiel an sich fertig wird und ich durchspielen kann“, und mit 2.3 vorab kämen 3–4 Sitzungen vor dein erstes Durchspielen; Stufe 4 verlangt ohnehin ein zweites Durchspielen (4.10).

**Antworten an die Teams (Perikles, 488):** 471 Fertigkeiten ins Spiel mit 2.3 (Votum Tom A); 458.3, 455.2, 348.13 (Tom), 461.1, 460 (Jerry) nach dem Durchspielen; 348.12 Goblin geht in 494 auf; 417, 463, 406 (passt) in den nächsten gemeinsamen Build.

### Nach dem Durchspielen (488)

Eingefroren am 03.11.; gestrichen wird nichts. Nach deinem ersten Durchspiel ordnet Perikles diese Liste nach dem Gewicht deiner Befunde. Einzelheiten in der Zeile des Vorgangs.

**Erstes Wochenziel danach: Referenzszene** (620.4, Chef 07.11., 21:29: „620.4 A“; Archiv): Hauptmenü → Erschaffung → Vorspann → Dorf bei Tag (Marktplatz, Schänke innen, Schlagbaum mit Jorin und Garrick) → Flüsterwald → erster Wolfskampf bis zum Sieg, ganz fertig als Maß für alle weiteren Orte; fertig, wenn du sie durchspielst und „gut“ sagst. Tom (Dorf, Leute) und Jerry (Wolfskampf, Klang) schätzen sie, sobald 496 steht.

- 463.1 Umhang und Robe: Ärmel, Stiefel, Kettenhemd, Haut, Boden (Tom)
- 417 Tragart: Rumpf dreht beim Rennen, Füße rutschen, Schild steht ab, Kornfeld, Stabgang (Tom, Archiv 417)
- 438a Hinfallen und Aufstehen: Klinge quer im Kleid, Hand ruckt (Jerry)
- 431f Haut der Orkfrau, 431 Völker als Modelle, 475 Leute auf eigenem Körper (Tom)
- 455.1, 455.2 Roben, Netzliste und Größenfilm; 458.3 Netze des Gegenstandskatalogs; 476 Symbole der Ausrüstung (Tom)
- 348.13, 348.13b Tusche nach Lichtrichtung und Fackel; 302.1–302.3 Tusche an Figuren, Karte, Vorspann (Tom)
- 461.1 Grundstand Kampfort, 460 Kamerafahrten (Jerry, Tom)
- 372 Feinschliff Held; 387 gekaufte Tiere (Tom, Jerry)

## Wochenziel 02.–08.11. (Perikles, gesetzt 02.11., 11:2x; ersetzt durch das Wochenziel 03.–08.11. oben, 488)

**Stufe 1 „Kern spielbar“ ist gebaut und liegt dir als Build vor: Erschaffung, Fertigkeiten durch Tun, Heldenstufe und Monsterwerte nach dem BRS, gerechnet mit den Zahlen der Simulation 444.** Termine gibt es keine; die Reihenfolge gilt. Muss (M) sind die Vorgänge unten und jeder Rückläufer aus deinem Urteil (höchstens zwei Läufe je Urteil, 389, 407); alles andere ist Kür, auch Filme ohne dein Urteil dazwischen.

| Reihenfolge | Vorgang | Wer | fertig, wenn | Schätzung |
|---|---|---|---|---|
| 1 | von dir genannt (468): 463 Umhang und Robe geschlossen, 348.12k Grak, 427 Bestiarium, 467 Ausdauer nach BRS | Tom, Jerry, Sokrates | wie in der Zeile des Vorrats | – |
| 2 | 470 Bau BRS 1.1 Erschaffung | Tom | Erschaffung nach 1.1 im Testmenü, Zahlen aus der Datendatei; ins Spiel mit 2.3 (470a B) | 2 Sitzungen (447.2) |
| 3 | 471 Bau BRS 1.2 Fertigkeiten durch Tun | Tom, Kampfteil mit Jerry | Fertigkeiten steigen im Spiel nach 1.2 | erste Sitzung schätzt |
| 4 | 472 Bau BRS 1.3 Heldenstufe | Jerry | Heldenstufe im Spiel nach 1.3 | erste Sitzung schätzt |
| 5 | 473 Bau BRS 1.4 Monsterwerte | Jerry | Werte der Monster von Kapitel 1 als Daten und Regeln (`brs.gd`); der Kampf rechnet damit ab 2.3 (470a B) | 1 Sitzung, 1 Runde (447.3) |
| 6 | gemeinsame Builds aus den wartenden Änderungen, dann Stufe 1 als Build | Jerry stellt zusammen | höchstens 6 Änderungen je Build (317); du spielst Dorf und Wald an | – |
| 7 | 469 Ring ohne Klassen (aus deinem Urteil 406.1) | Jerry | wie in der Zeile des Vorrats | – |

**Stärkstes Gegenargument:** Figuren und Bewegungen, die du gerade beurteilst, rücken nach hinten. **Entkräftet:** sie bleiben Muss als Rückläufer deines Urteils, nur ohne Läufe auf Vorrat; ohne Stufe 1 lässt sich keine spätere Stufe abnehmen.

## Ausführlicher Stand (Zeile 10 des [Tagesberichts](ARBEIT-TAGESBERICHT.md); Perikles montags neu; ersetzt seit 448 den täglichen Stand zum Marktstart und das Dashboard)

**Stand 03.11., 07:1x** (Wochenzählung von Diogenes 02.11.; Zahlen je Tag im [Tagesbericht](ARBEIT-TAGESBERICHT.md))

| Stufe | Stand | was als Nächstes |
|---|---|---|
| 1 Kern spielbar | 2 von 4 abgenommen: 1.1 Erschaffung, 1.4 Monsterwerte (720, 09.11.). 1.3 Heldenstufe (472) noch nicht getestet (Aufstieg mit dem BRS); 1.2 Fertigkeiten (471) als Regeln nur auf einem Zweig, nicht im Spiel; Spike macht sie fertig (471 A), sichtbar mit 762. Simulation 444 gerechnet, nicht von dir abgenommen. | dein Test von 1.3; 762 |
| 2 Kapitel 1 durchspielbar | 0 von 12. Dorf, Räume und Wolfskampf spielbar (Build 146). Geschichte und Gespräche von Kapitel 1 gebaut (390). Flüsterwald, Tiefer Flüsterwald, Blutzahnhöhle und ein Teil der Gegner fehlen in Godot. Kampf rechnet noch nach dem alten System (2.3). | Wochenziel 03.11.: 490–496, dann 478 und 2.3 |
| 3 Alle Systeme angelegt | 0 von 8. Gegenstandskatalog angelegt (458). | nach Stufe 2 |
| 4 Kapitel 1 fertig | 0 von 10. Feinarbeit am Aussehen eingefroren (488); 463 Umhang, 417 Tragart, 406 Schild am 03.11. mit „passt“ eingefroren, Mängel auf der Liste „Nach dem Durchspielen“. | nach deinem ersten Durchspiel |
| 5 marktreif | Gewerbeschein offen (du, Vorgang 142 beim Chef) | – |
| 6 SRD im Code abgelöst | nach dem Marktstart | – |

**Woche 25.10.–01.11. (Diogenes):** Wochenziel nicht erreicht; Anteil Muss an den Kosten 95 %; Anteil Tom, Jerry, Homer 75 %; Kosten etwa 3978 $ Rechenwert in 424 Sitzungen. **Diese Woche:** Wochenguthaben 36 % am Montagmorgen (Ziel etwa 11 % je Tag, 468).

<details><summary>Alter Stand vom 01.11. (Blöcke T–S, Risiken, Reihenfolge); gilt nicht mehr, steht hier nur bis zum nächsten Montag</summary>


**Stand 01.11., 00:15: gelb. Seit 31.10. gilt deine neue oberste Direktive: kein Termin, fertig ist, was die Abnahmeliste oben erfüllt.** Die Liste liegt dir zur Abnahme vor (Chefsache 418); bis zu deinem Wort ampeln wir nach ihrem Entwurf, Block für Block. Das spielbare Godot-Spiel (Dorf und Waldkampf, 399) hast du am 31.10. gegen 20:40 mit Build 143 getestet; von deinen neun Befunden (416) ist einer abgenommen, vier sind gebaut, einer in Arbeit, drei offen (einer davon Kür). 15 neue Änderungen (Tom 7, Jerry 8) warten auf den nächsten gemeinsamen Build; höchstens 6 je Build (317), also mindestens drei Builds. Dazu 5 Punkte aus Build 143, die du noch abnimmst (Spielfassung, Innenräume, Klang, Dorf, Kampfort). Das alte Regelwerk ruht auf dein Wort („keine Energie mehr in das alte SRD-System“, 424); Spielsystem 2.0 ist als Nachschlagewerk beschrieben (Entscheidungen bis 75, Sokrates gleicht ab, 422; Diogenes liest quer, 441), gebaut wird es erst nach deinen Antworten zu den offenen Entwürfen (413a) und zum Umfang für Kapitel 1 (418). Kein Block ist rot; die meisten warten auf diese beiden Antworten.

**Heute für dich:** steht immer aktuell in der [Chefsache-Übersicht](chefsache/README.md) (Entscheiden, Billigen, Ansehen, Testen, Tun); ein Werkzeug schreibt sie bei jedem Push, keiner von Hand (275).

**0. Meilenstein Umzug** (jetzt Teil von Block W): die Umzugsliste (seit 10.11. Bestand in `LISTE-ABGLEICH-ALT.md` 6) hinkt der Spielfassung nach und wird Mo 02.11. mit Wochenziel 2 neu gezählt; ihre Zeilen zum alten Regelwerk ruhen (424).

**1. Stand je Block der Abnahmeliste** (Ampel; Termine gibt es keine, Reihenfolge und Schätzung kommen mit Wochenziel 2 am Mo 02.11.)

| Block | Ampel | warum (Vorgänge) |
|---|---|---|
| T Ohne technische Fehler | gelb | Build 143 lief bei deinem Test. Gebaut: Tasten in der Erschaffung (416.1), Platzwechsel mit Dorfbewohnern (416.2), Kampflog schließt (416.5), Aktionsknopf am Tresen (416.7); offen: Rennen „wie Hochsprung“ (416.4), Leute drehen sich zum Helden (416.8), Fußspuren (416.6, Kür). Menü System abgenommen, Testmenü bekommt Icons (425). Tests und Zufallsspieler (ein Programm, das Kapitel 1 selbst durchspielt) auf den Regeln 2.0 gibt es erst, wenn 2.0 gebaut wird. Tablet (267) bei deinem nächsten Tablettest. |
| A Aussehen und Signatur | gelb | Bei dir zum Ansehen, jeweils nur „passt“ oder was anders sein soll: Held im Kampfort wie im Dorf (Film 403; Bewegung „gut“, 23:31), Waffen in der Hand beim Gehen (Probe Stab, Axt, Bogen, 417); zu entscheiden: Aussehen der Völker (430). Innenräume wie alt (399.5) sind in Build 143. Feinschliff der Tuschelinien ruht, bis das Spiel steht (348.13b). |
| K Klang und Musik | gelb | Tierlaute (401), Blende und Herzschlag vor dem Kampf (402) sind gebaut und kommen mit dem nächsten Build. Musik je Ort und Tageszeit, Schritte je Untergrund, Raumklang: noch nicht begonnen. |
| M Kampfsystem | gelb | Die Kampfbewegungen des Helden gefallen dir (403); offen aus deinem Film: Wölfe gleiten (438), Neuformation vor dem Tod (439), Wolf stirbt ohne Animation (440), alle bei Jerry. Kampf auf den Regeln 2.0 (Stufen statt W20) beginnt nach 413a. |
| G Spielsystem 2.0 | gelb | Nachschlagewerk gilt (Entscheidungen bis 84, 01.11.); Umfang für Kapitel 1 entschieden: nur der Kern, dazu leere Datenfelder für spätere Wellen und je Herkunft eine Handlung (418, 01.11., 09:43). Rechensimulation läuft (444). Gebaut ist davon noch nichts; der Bau wird mit Wochenziel 2 am Mo 02.11. auf Tom und Jerry verteilt. |
| W Möglichkeiten des Spielers | gelb | Spielbar: Hauptmenü, Erschaffung, Spielstände, Dorf mit Schenke, Laden, Ältestem und Tempel, Anschlagbrett, Rast, Waldkampf gegen das Wolfsrudel; Laden „Verkaufen“ wird nachgebessert (416.9, Spike, der Zusatzentwickler bei Tom). Englisch durchgehend: offen. |
| S Store | gelb | Konto und App angelegt, Datenschutzseite online (252). Der Weg zum Store: Gewerbeschein, dann das Repo auf privat stellen (109), dann der Aufruf für die 12 Tester (vorbereitet, 142.3), dann 14 Tage geschlossener Test. Bei dir: Gewerbe-Neuanmeldung korrigieren und absenden (Zu tun 142). |
**2. Ausgaben**
- **Echtes Geld:** das Max-Abo in der größeren Stufe (seit 25.10.); Nutzungsguthaben 0 $, nichts nachgekauft.
- **Wochenguthaben Max:** seit Samstagabend 31.10. eine neue Woche; dein letztes Bild der Nutzung ist vom 27.10. Wie viel der neuen Woche verbraucht ist, zeigt nur ein neues Bild von dir. Es gilt deine Entscheidung vom 22.10. (287): nicht sparen, nichts nachkaufen; ab 80 % startet Ford nur Muss.
- **Wofür (gebucht seit dem letzten Stand 29.10., 01:05, nur beendete Sitzungen):** 263 $ in 20 Sitzungen. Davon auf Vorgänge gebucht 238 $, nach ihrem Besitzer: Tom 80 $, Jerry 60 $, Homer 3 $, Perikles 80 $ (davon 56 $ aus Sokrates' Chefrunde, die auf 433 und 437 gebucht ist), Diogenes 12 $, Rest 4 $. Anteil Spiel so gerechnet etwa 60 % (Ziel ab 02.11.: 70 %). Die genaue Zählung nach Rollen macht Diogenes montags.

**3. Risiken und Gegenmittel**

| Risiko | Folge | Gegenmittel (wer) |
|---|---|---|
| Bau wartet auf dich | ohne deine Antworten zu 418 (Abnahmeliste, Umfang von 2.0) und 413a (offene Entwürfe) beginnt kein Bau der neuen Regeln, Blöcke M und G stehen still; ohne 430 (Aussehen der Völker) wartet Toms Modellarbeit (431); 442 (welches Modell in welcher Sitzung) ist ebenfalls offen | 418, 413a, 430, 442 beantworten (du); bis dahin Befunde aus Build 143 und dem Film 403 (Tom, Jerry) |
| Ford-Kette am Ende | Ford, der die Teams startet, startet sich selbst neu; nach 8 Neustarts muss ihn jemand von Hand starten; jetzt 6 | Ford einmal von Hand starten, erste Nachricht „Ford“ (du, Chefsache 110) |
| Builds stauen sich | 15 neue Änderungen, höchstens 6 je Build (317): mindestens drei Builds, jeder mit deinem Test | Jerry stellt morgens ab 7 Uhr den gemeinsamen Build zusammen (Ford startet ihn); du testest in der Reihenfolge der Testbitten |
| Plan ohne Schätzung | Termine gibt es nicht mehr; ohne Schätzung siehst du nicht, wie weit Kapitel 1 ist | Mo 02.11. Wochenziel 2: Reihenfolge und Schätzung je Block (Tom, Jerry, Perikles) |
| Gewerbeschein kommt spät | die frühere Anmeldung kam nie an; ohne Schein kein Preis, kein Zahlungsprofil, kein privates Repo, kein Tester-Aufruf | Neuanmeldung (Formular GewA 1) korrigieren und absenden, nach drei Werktagen nachfragen (du, Zu tun 142); den Rest so vorbereiten, dass nur noch die Angaben fehlen (Sokrates) |
| Anschrift vor dem Zahlungsprofil | Google zeigt die Anschrift öffentlich | Wohn- oder Geschäftsanschrift (Büroservice) vor dem Zahlungsprofil entscheiden (du, Sokrates) |
| Guthaben knapp | in der letzten Woche Stillstand ab Donnerstagnacht bis Samstagabend | ab 80 % nur Muss (287); ein Bild der Nutzung von dir zeigt den Stand |
| „Gut“ hat kein Ende | ohne Termin fehlt die natürliche Grenze; seit dem Umzug 4 bis 13 Bilderrunden je Figur oder Karte | nur du urteilst, nach genau einer Fehlerprüfung, höchstens ein Blatt je Modell und Runde (373); Feinschliff kommt ans Ende |
| 12 Tester fehlen | Pflichttest kann nicht beginnen; der Aufruf geht erst nach Gewerbeschein und privatem Repo raus | Aufruf ist vorbereitet, Organisationskonto geprüft (142.3, Sokrates); hängt an deiner Neuanmeldung |

Dazu, ohne Vorgang (Perikles vergibt Nummern mit Wochenziel 2): Englisch durchgehend (Homer, Tom); Spielstände über Updates (Tom); Store-Texte und Bilder (Homer, Sokrates).

**Reihenfolge** (ohne Datum; Google: neues privates Konto braucht 14 Tage geschlossenen Test mit 12 Testern, dann Prüfung, etwa eine Woche):

| Schritt | was |
|---|---|
| erledigt | Konto angelegt (142) ✓ 23.10.; spielbare Godot-Fassung mit Dorf und Waldkampf (399) ✓, Build 143 getestet 31.10. |
| 1 | Abnahmeliste und Umfang von 2.0 (418), offene Entwürfe (413a), Völker (430): du; Gewerbe-Neuanmeldung (142): du; danach Wochenziel 2 mit Schätzung (Perikles) |
| 2 | Regeln 2.0 bauen, Blöcke T, A, K, M, G, W im neuen Spiel abhaken |
| 3 | Fehler und Glätten; Englisch, Geräte, Spielstände; Store-Seite, Impressum; Tester bereit; du spielst Kapitel 1 ganz durch |
| 4 | Chef: „gut“; geschlossener Test 14 Tage (falls nicht schon mit der alten App gelaufen), Antrag, Prüfung durch Google, Marktstart |

</details>

## Meilenstein Umzug: „Kapitel 1 auf Godot mindestens so gut wie alt“ (348.9, Chef 25.10., 12:24; seit 418 Teil von Block W der Abnahmeliste)

**Erreicht, wenn** jeder Punkt der Checkliste „abgenommen“ ist, die Kerntests aus `core` als GDScript-Tests grün sind und der Zufallsspieler Kapitel 1 im neuen Spiel durchspielt; danach ersetzt das neue Spiel nach dem Test des Chefs das alte auf `main`. **Checkliste** = Bestand 348.8 samt Schirmen und Systemen in `LISTE-ABGLEICH-ALT.md` 6 (Stand-Wörter dort: –, Entwurf, gebaut, gemessen, abgenommen). Reihenfolge: zuerst das Licht (3486-sonne), dann je Bauart ein Grundmodell (Mensch, Vierbeiner, Vogel, Insekt, Spinne), daraus alle Figuren; Häuser und Dinge parallel; sonst so, wie Kapitel 1 gespielt wird. Jedes Vergleichsblatt misst Diogenes nebenher, als Hinweis an den Chef, kein Tor (373, `ROLLE-PRUEFUNG.md`).

**Stand 01.11.:** neu gezählt Mo 02.11. (oben „0. Meilenstein Umzug“). Die 15 Punkte der Gegenprobe 398 stehen als Zeilen in `LISTE-ABGLEICH-ALT.md` 6.3 und zählen über 4.4 (dazu 2.1 Sprungtest, 4.1 Absturz, 4.6/4.7 Klang, W7 Anschauen, O9 Kampforte); abgeschlossen 09.11.

**Tagesziele und Termine je Block** (338, 348.14, bis 29.10.) in Git, Stand vor „Perikles: 418“; entfallen mit den Stufen ohne Datum (447), Vorrang regelt das Wochenziel.

## Wochenziel 26.10.–01.11. (Perikles, gesetzt 25.10., 02:10; Umzug Woche 1 beginnt schon 25.10.; Wochenziel 18.–24.10. in Git)

**Umzug Woche 1 steht: das Dorf Bornim läuft in Godot am Handy, ein Kampf gegen das Wolfsrudel mit den echten Regeln auch, und die Bestandsliste nennt alles, was umziehen muss; danach neue Schätzung des ganzen Umzugs.** Plan und Regeln: `LISTE-UMZUG-348.md`. Muss (M) sind nur diese Vorgänge; das alte Spiel ruht ganz (348), alles andere ist diese Woche Kür oder ruht (126). **Geprüft Mo 26.10., 07:10 (Perikles):** Inhalt bleibt; Muss-Anteil seit Samstagnacht 89 % der gebuchten Kosten (Ziel 70 %); Entwicklung 71 % (nach Vorgängen; Anteil Spiel nach Rollen zählt Diogenes am 02.11.). Geändert: die Schätzung ist jetzt Vorgang 348.14 und steht in beiden Team-Vorräten vor jeder weiteren Bilderrunde, weil ohne sie weder Wochenziel 2 noch Termine je Block gehen.

| Vorgang | Wer | fertig, wenn |
|---|---|---|
| 348.6 Grundgerüst und Dorf | Tom | APK am Handy; Vergleichsbild Dorf alt/neu an den Chef (Diogenes misst nebenher, 373) |
| 348.7 Modellregel und Wolfskampf | Jerry | Modellregel in `LISTE-UMZUG-348.md` ✓ 25.10.; APK am Handy, Vergleichsbild Kampf alt/neu an den Chef |
| 348.8 Bestandsliste | Tom, Jerry | Liste in `LISTE-UMZUG-348.md` (seit 10.11. `alt/`) vollständig, jede Zeile mit Quelle im Code ✓ 25.10. |
| 348.9 Modelle jetzt | Tom, Jerry, Homer, Diogenes | Grundmodelle je Bauart als Entwurf beim Chef; Homers Stimmung je Ort gebilligt; Diogenes misst jedes Vergleichsblatt (Meilenstein Umzug oben) |
| 348.14 neue Schätzung | Tom, Jerry, dann Perikles | je Punkt der Checkliste im eigenen Bereich: Sitzungen und erwartete Bilderrunden bis „gebaut“, in `LISTE-UMZUG-348.md` (seit 10.11. `alt/`); ✓ 26.10. (Tom 79 S, Jerry 95 S); Termine je Block oben, Wochenziel 2 unten |
| 142 Store-Vorbereitung | Chef, Sokrates | Ausweis- und Telefonprüfung; vom Ruhen ausgenommen |

**Oberste Direktive:** seit 31.10. die neue (oben, 418); was im alten Spiel geht, muss im neuen mindestens so gehen (Block W), außer was Spielsystem 2.0 ersetzt. Neue Fehler des Chefs kommen als Muss dazu.

**Guthaben:** Max seit 25.10. in der größeren Stufe, Woche ab 0 % (25.10., 11:05). Es gilt 287 (Chef 22.10.): nicht sparen; ab 80 % Woche `lauf.py --nur-muss` (Ford), ab 95 % keine neuen Starts außer Rückläufer des Chefs, ab 100 % Stillstand bis Sa 31.10., 20:00; nichts nachkaufen.

## Wochenziel 2: 02.–08.11. (Perikles, vorab gesetzt 26.10., 17:15 nach der Schätzung 348.14; Montag 02.11. mit der Wochenzählung geprüft)

**Ersetzt durch das Wochenziel 02.–08.11. oben (02.11., 11:2x).**

**Umzug fertig zum Durchspielen: jeder Punkt der Checkliste ist bis Mo 02.11. „gebaut“ (hält nur, wenn du etwa 28 Blätter am Tag ansiehst, 373) und bis Di 03.11. von Diogenes gemessen (Hinweis, keine Bedingung für deine Abnahme); die Kerntests laufen als GDScript-Tests grün, der Zufallsspieler spielt Kapitel 1 im neuen Spiel durch; dann spielst du Kapitel 1 in Godot einmal ganz durch, und deine Fehler sind Muss.** Abnahme der Punkte nach deinem Wort, Feinschliff danach. Das Guthaben ab Sa 31.10., 20:00 reicht beim jetzigen Takt bis etwa Mi 04.11.; was dann offen ist, geht nach dem Stillstand ab Sa 07.11., 20:00 weiter. Messen, GDScript-Tests und Zufallsspieler sind nicht geschätzt. Stärkstes Gegenargument: wird es der späte Termin (seit 338a „B“ Di 03.11., früh; dann hält das Wochenziel nicht), bleibt für deine Fehler aus dem Durchspielen kaum Guthaben in dieser Woche.

Die alte Pflichtliste „Block (a) Kapitel 1 rund“ (altes Spiel) ist seit 418 in der Abnahmeliste oben aufgegangen; Wortlaut in Git, Stand vor „Perikles: 418“.
