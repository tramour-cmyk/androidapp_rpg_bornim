# Kerbensystem: Kampfregeln zum Bauen (930, Entwurf)

Sokrates, 14.11., 20:12. Ein Regelwerk für Jerry, Tom, Homer und Diogenes: was gebaut wird, in welcher Reihenfolge, woran man es prüft. Der Gesprächsverlauf mit dem Chef, die Vorbilder, beide Rechnungen und alle verworfenen Wege stehen in [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md); was hier steht, ersetzt die Regelseite 930 in [Kampf](DESIGN-KAMPF.md) („Entwurf zur Entscheidung: Handgemenge und Abstand“). **Nichts davon ist entschieden.** Gebaut wird erst nach dem Los des Chefs ([Vorlage 930](chefsache/entscheiden/930-glutsystem.md); 1236); bis dahin nur Rechnung (Stufe 0).

Vom Chef schon gesagt: Aktionspunkte ja (14.11., 00:25); Richtung „Lesen, Planen, Antworten“ gefällt (10:20); Ansage nicht immer mit Ziel, gekoppelt an Werte (11:18). **Name 1260 D** (15.11., 10:07): die Punkte heißen **Kerbe / Notch** (im Entwurf „Glut“); ungeschlagene Kerben **verstreichen** / Lapse (Homer 1265). Dateinamen (`DESIGN-GLUT.md`, `glut2.py`, Code `glut`) bleiben, bis Jerry den Code umbenennt (1266). Im Handbuch nie „Aktionspunkte“ (Chef 14.11., 22:49).

## 1. Was das System will

**Jede Runde ist ein kleines Rätsel in drei Schritten:**

1. **Lesen:** der Gegner sagt an, was er vorhat. Wie viel man davon sieht, hängt am Helden (Wahrnehmung, Spähen).
2. **Planen:** der Spieler schlägt drei Kerben: Weg, ein Tun, der Rest vertieft das Tun oder geht in eine Haltung.
3. **Antworten:** im Zug des Gegners löst die Haltung von selbst aus; dazu der Ring als Geschick der Hand.

**Warum das einen Preis gewinnen kann (der Platz in der Szene):** Clair Obscur: Expedition 33 hat 2025 gezeigt, dass Rundenkampf mit Ausweichen und Parieren im Takt die Leute fesselt; Sea of Stars hat das Brechen angesagter Zauber populär gemacht, Into the Breach und Slay the Spire das offene Rätsel durch Ansagen. Alle drei belohnen **entweder** die Hand **oder** den Kopf. Wir verbinden beides: der Kopf entscheidet vorher, wie viele Kerben im Gegnerzug warten, die Hand entscheidet im Ring, wie gut sie wirken. Und **Lesen ist eine Fähigkeit des Helden**, nicht nur des Spielers: ein Kräutersammler mit scharfen Augen sieht mehr von dem, was kommt, als ein Wachsoldat. Information als etwas, das man im Rollenspiel steigert, kenne ich aus keinem Handy-Rollenspiel. (Vorbilder aus eigener Kenntnis; Quellen zu XCOM, Jagged Alliance, Pathfinder, Descent in [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md).)

**Vier Maße für jede Regel** (Chef 10:21): gut, tragfähig, ausbaufähig, in Bild und Klang umsetzbar. Dazu das Leitbild: kein Kampf langweilig, echte Wahl, Grinden darf man, muss man nie.

## 2. Begriffe (ins Glossar nach Entscheid)

| Begriff | Bedeutung |
|---|---|
| **Kerbe** / Notch | die Währung eines Zugs; drei je Zug, ganze Zahlen; jede Tat schlägt eine Kerbe (1260 D) |
| **Freier Schritt** | Felder ohne Kerbe, nach Tempo |
| **Tun** | die eine Handlung je Zug (Schlag, Schuss, Wurf, Zauber, Kampfhandlung) |
| **Vertiefen** / Deepen | übrige Kerben ins Tun, macht es stärker (im Entwurf „Nachlegen“) |
| **Haltung** | übrige Kerben für den Gegnerzug: Gegenschlag, Wachschuss oder Wehr |
| **Antwort** | eine Kerbe der Haltung, die auslöst |
| **Verstreichen** / Lapse | ungeschlagene Kerben verstreichen mit dem Zug (im Entwurf „Verglimmen“; Homer 1265) |
| **Goldkerbe** / Gold Notch | einmal je Kampf eine vierte Kerbe (im Entwurf „Funke“) |
| **Lauern** | Haltung eines Gegners: wer heranrückt, läuft in seinen Schlag |
| **Ansage lesen** | wie viel der Held von der Ansage sieht (Stufe 0–3) |
| **Großer Schlag** | Gegnerhandlung für 2 Kerben, immer mit Ring |
| **Abstand** | nah, fern, weit (930 Regel 1) |

„Rückschritt“ (Antwort nach perfektem Ring) und „Eilschritt“ (Fertigkeit) sind verworfen, um Zusammenstöße mit Ausweichen und freiem Schritt zu vermeiden.

## 3. Regeln des Helden

1. **Drei Kerben je Zug.** Nie weniger als 1: Umreißen und Netz nehmen je 1, stapeln aber nicht darunter. Betäubt: Zug fällt aus wie heute.
2. **Freier Schritt nach Tempo**, einmal je Zug: schnell 2 Felder, normal 1, langsam 0 (Tempo aus Gewandtheit und Last, `DESIGN-BRS.md`). Jedes weitere Feld 1 Kerbe.
3. **Lösen** aus nah kostet 1 und gibt keinen neuen freien Schritt; ein noch nicht genutzter darf danach gegangen werden. Ein schneller naher Gegner setzt nach (Schlag mit Ring), außer die Haltung ist Wehr.
4. **Abstand:** nah, fern, weit; ein Kampf beginnt fern, beim Überfall nah, nach Schleichen wählt der Held (930 Regel 8). **Weit ist die letzte Stufe**; weiter zurück heißt fliehen.
5. **Platztausch** in der eigenen Reihe kostet den freien Schritt (wie heute der Wechsel).
6. **Ein Tun je Zug für 1 Kerbe.** Schwere Handlungen kosten 2 (Tun mit festem Vertiefen, ohne dessen Schadensplus): Glutstrahlen, Flammenfächer, Glutkugel, Wuchtschlag, Schädelstoß, Durchschlag, Zwei auf einmal, Schildstoß.
7. **Übrige Kerben frei teilen:**
   - **Vertiefen:** je Kerbe +25 % Schaden auf das Tun dieses Zugs (930.5: 15 % zu schwach, 20 und 25 % erfüllen das Maß, 25 % am ausgeglichensten).
   - **Haltung**, eine Art je Zug, Zahl = übrige Kerben, beim Planen gewählt, löst von selbst aus:
     - **Gegenschlag** (Nahkampfwaffe): kommt ein Gegner nah heran oder schlägt ein naher Gegner zu, schlägt der Held vorher.
     - **Wachschuss** (Fernwaffe, Angriffszauber mit Mana): rückt ein Gegner ein Feld vor, schießt der Held vorher.
     - **Wehr:** je Kerbe ein Schlag gegen den Helden mit Ungunst (−25), bis zum eigenen nächsten Zug; gegen große Schläge läuft dazu der Ring langsamer (perfekt leichter).
   - Gegenschlag und Wachschuss: **halber Schaden, nie kritisch**, ab Geselle der Fertigkeit voll.
   - Haltung verfällt mit dem eigenen nächsten Zug.
8. **Antworten lösen keine Antworten aus.** Ein Gegenschlag, der tötet oder taumeln lässt, bricht den Angriff ab.
9. **Höchstens zwei Ringe je Gegnerzug**; weitere große Schläge dieser Runde treffen ohne Ring.
10. **Kleines frei:** Waffe wechseln, Pfeilart wählen, einmal je Zug. **Trank** trinken oder geben kostet 1 (ist kein Tun: Trank, Schlag und eine Haltung gehen in einem Zug).
11. **Kraft schöpfen** (einmal je Kampf) kostet 1. Einschüchtern und Hinterhalt zu Beginn kosten nichts.
12. **Goldkerbe** ab Heldenstufe 4, einmal je Kampf: entsteht durch einen perfekten Ring oder wenn das Leben unter die Hälfte fällt; gibt im nächsten Zug eine vierte Kerbe.
13. **Fliehen** kostet alle 3 Kerben, Probe wie heute, nie vor einem Boss; ein schneller naher Gegner setzt nach.
14. **Abwehr-Taste entfällt:** alles in Wehr ist die Abwehr. **Decken** wird eine Haltung des Wächters (ab Kapitel 2).

## 4. Regeln der Gegner

15. **Gewöhnliche Gegner 2 Kerben, Bosse 3**, freier Schritt nach Tempo wie der Held. Bosse: ein Tun und eine Sonderregel; ihre dritte Kerbe zeigen sie offen als **„holt aus“**.
16. **Großer Schlag = 2 Kerben = Ring** (1048 A); kleine Schläge ohne Ring.
17. **Lauern** (übrige Kerben eines Gegners mit Speer oder Kampfgeschick): hält einen Zug; wer heranrückt, läuft in den Schlag; danach greift der Lauernde selbst an. Lauernde ducken sich nicht: **Fernkampf ist die Antwort auf Lauern.**
18. **Langsame Gegner haben ein Mittel auf Abstand** (Wiedergänger ruft Nachschub, Schnecke spuckt Säure aus fern), damit Abstand halten nie endlos geht.
19. **Brechen:** Zurückdrängen, Netz verbrennen und Taumeln lassen einen angesagten großen Schlag ins Leere gehen. Das Feld `breakable` der Ansage gibt es schon (`mars.gd` `_intent`).
20. **Täuschen:** einzelne Arten (Goblin-Späher, Grimmzahn, Grak) sagen einen großen Schlag an und führen einen kleinen, oder umgekehrt; erkennbar erst mit Ansage lesen Stufe 3.
21. **Je Art eine eigene Frage** an den Spieler: Tabelle „Gegner im Glutsystem“ in [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md). Kurz: Wölfe Gegenschlag, Wiedergänger Abstand und Wachschuss, Kobold nicht anrennen, Späher Weg kostet, Spinne Ring, Fledermaus Schlag und Gegenschlag (nicht reines Warten: 930.5, Kräutersammler 39 statt 98 Siege je 100), Krogg ausweichen statt abfangen, Grak Reihenfolge.
22. **Gemischte Begegnungen** (Wolf mit Späher, Kobold mit Schamane): zwei Rezepte, die sich widersprechen.

## 5. Ansage lesen (neu, Chef 11:18)

Die Ansage zeigt nicht immer alles. Vier Stufen:

| Stufe | Der Spieler sieht | Bild im Chip |
|---|---|---|
| 0 | nur, **dass** etwas kommt, und ob groß | `!` oder `!!`, kein Ziel |
| 1 | die **Art** (Biss, Netz, Hieb …) | Zeichen der Art |
| 2 | Art und **Ziel** | Rand in der Farbe des Angezielten (heute so gebaut) |
| 3 | dazu die **Kerben** des Gegners und **Täuschung** | rote Kerben, durchgestrichenes Zeichen bei Täuschung |

- **Lesewert des Helden** = Wahrnehmung (Grundwert) und Spähen (Fertigkeit); `DESIGN-BRS.md` sagt schon: „Wahrnehmung verstärkt Spähen beim Entdecken“. **Gegenwert** je Art („undurchschaubar“): Tiere niedrig, Goblins mittel, Bosse hoch. Gerechnet in 930.5: **Lesewert** = Wahrnehmung + Spähen/5; **Gegenwert** Tiere 1, Säureschnecke 2, Goblins und Kobold 3, Untote 4, Krogg und Grimmzahn 6, Grak 8; **Stufe** = 2 + ⌊(Lesewert − Gegenwert)/4⌋, begrenzt auf 0 bis 3, Spähen ab Geselle +1, Bosse mindestens 1.
- **Bosse und große Schläge** zeigen immer mindestens Stufe 1, damit der Ring nie unfair kommt.
- **Wirkung:** wer mehr sieht, spart Kerben gezielt; wer wenig sieht, legt sie als Versicherung in Wehr. Die Rechnung von Fassung 2 zeigt, dass beides trägt (keine Spielweise immer vorn).
- **Gewinn für die Herkünfte:** Jägerkind und Kräutersammler (Wahrnehmung und Spähen) lesen besser. **Aber (930.5):** im Autopiloten bringt Lesen nur 2 bis 5 Siege je 100, weil die Ansage allein zwischen Wehr und Gegenschlag entscheidet und die nah beieinander liegen. Damit Lesen spürbar wird, muss die falsche Haltung mehr kosten oder die Ansage mehr verraten; offen für das Gespräch nach dem Film (930.7), Regelkern baut die Stufen trotzdem.
- **Wachsen:** Spähen bis Geselle in Kapitel 1 erreichbar (Kräutersammler, Jägerkind beginnen damit); später Ausrüstung (Späherhaube) und Pfad (Waldläufer liest Tiere immer auf 3).
- **Stärkstes Gegenargument:** Stufe 0 fühlt sich wie Strafe an, der Spieler sieht weniger als heute. **Antwort:** Stufe 2 ist heute; der Durchschnittsheld beginnt dort gegen Tiere, nur gegen Bosse und Täuscher sieht er weniger, und genau dort ist das Nicht-Wissen Spannung.

## 6. Wachsen

| Quelle | Was sie ändert | ab |
|---|---|---|
| Fertigkeit, Anfänger | Tun, alle drei Haltungen, Antworten halb | Kapitel 1 |
| Fertigkeit, Geselle | Kampfhandlung (heute gebaut), Antworten voll | Kapitel 1 möglich, selten (444: höchstens 14–21 auf Stufe 6, Geselle ab 25) |
| Fertigkeit, Meister | die leichte Handlung wird stärker | Kapitel 2, Pfad |
| Fertigkeit, Großmeister | Meisterzug einmal je Kampf für 0 | Pfad |
| Nicht-Waffen, Geselle | Ausweichen: ein freies Feld mehr; Schild: Schildstoß, Wehr auch für den Nachbarn; Alchemie: ein Trank je Kampf für 0; Leichte Rüstung: Lösen für 0; Schleichen: Abstand zu Beginn wählen; **Spähen: Ansage +1 Stufe** | Kapitel 1 möglich |
| Heldenstufe | Größenordnung (Modell D), Goldkerbe ab 4 | Kapitel 1 |
| Pfad | bricht genau eine Regel (Tabelle in [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md); geändert: Berserker zweites Tun nach Treffer; Scharfschütze Vertiefen über zwei Züge nur für den Zielschuss, vor dem Bau rechnen) | Kapitel 2 |
| Ausrüstung, Tränke | Ausnahmen auf Zeit (Stiefel des Läufers, Eiltrank, Trank der Wachheit) | Kapitel 1 nur Eiltrank |
| Team | Bollwerk, Helfen, Herausziehen, Zange, Wache für den Partner, Zusammenspiel | Kapitel 2 |

**Nie mehr als drei Kerben als Grundzahl** (BRS: keine großen Zahlenaufschläge, „du wirst, was du tust“).

## 7. Bedienung (Hochformat)

1. **Ein Tipp auf den Gegner** = Weg und Tun; die übrigen Kerben gehen in die vorgeschlagene Haltung: nah Gegenschlag, fern Wachschuss, gegen einen angesagten großen Schlag **oder einen Gegner, der aus fern oder weit schießt**, Wehr (930.5: gegen Wolf mit Späher war Gegenschlag der falsche Vorschlag, Kräutersammler 42 statt 66 Siege je 100 mit Wehr). Wer nichts plant, spielt wie heute mit einem Tipp.
2. **Zweiter Tipp** (auf den Helden oder lang drücken): drei Symbole am Daumen (Gegenschlag oder Wachschuss, Wehr, Vertiefen), der Vorschlag vorgewählt; je Tipp auf ein Symbol wandert eine Kerbe dorthin.
3. **Vorschau** vor dem Bestätigen: Ziffern „1“, „2“ über den Figuren in Schlagfolge.
4. **Immer sichtbar:** großer Schlag (goldener Rahmen), „lauert“ (Speerspitze); Kerben des Gegners nur auf Stufe 3 und beim Antippen.
5. Knopfzeilen heute (`kampf_ui.gd` 951–990): Angriff, Können, Tasche, Wechsel bleiben; **Abwehr wird Haltung**; Flucht, Auto bleiben.
6. **Held Auto** spielt mit dem Vorschlag aus 1; Söldner Auto ebenso.

## 8. Bild und Klang

Nach 1260 D (15.11.): Kerbholz statt Feuer, damit die Punkte sich von Glutkugel, Glutstrahlen, Flammenfächer, Funkenpfeil trennen. Bestand und alte Fassung mit Glut in [Aktionspunkte](DESIGN-AKTIONSPUNKTE.md) („Bild und Klang zum Glutsystem“) und in Git (vor 15.11.). Für den Bau (1266):

- **Kerbmarken:** drei leere Plätze im Fußring (`kampfort.gd` 1337) wie am Kerbholz; jede Tat schlägt eine Kerbe: schwarzer Schnitt mit Goldrand (Tuschelinie, Gold als einziger Glanz). Vertiefen: die Kerbe wird tiefer, das Gold zieht zur Waffe. Haltung: Kerbe bleibt offen mit Zeichen (Klinge, Pfeilspitze, Schild). Antwort: der Goldrand blitzt im Augenblick des Schlags. Ungenutzt: die leeren Plätze verstreichen am Zugbeginn (vergehen still, ohne Schnitt).
- **Gegner:** Kerben rot (Stil 16), „holt aus“ als dritte Kerbe an Faust oder Waffe, Täuschung durchgestrichen.
- **Goldkerbe:** der Leuchtfunke über dem Kopf (`held.gd` 73) sinkt zum Fußring und wird die vierte, ganz goldene Kerbe.
- **Klang:** Kerbe schlagen ein trockener Schnitt in Holz; Vertiefen ein tieferer Schnitt je Kerbe; Haltung setzen neu (Klinge in Stellung, Sehne gespannt, Schild hoch, echte Aufnahmen, je drei Varianten); Antwort ein heller Schlag; Verstreichen leise; Goldkerbe ein Systemklang; **Ring daneben** bekommt einen dumpfen Treffer (heute stumm). Kein Knistern, Fauchen, Zischen.
- **Musik in zwei Ebenen** (Boss holt aus, Leben unter der Hälfte): eigener Vorgang nach Kapitel 1, nicht Bedingung.

## 9. Was Kapitel 1 braucht

**Ja:** Regeln 1–14 außer Decken; Gegner 15–21 für die Arten von Kapitel 1 (Riesenratte, Wolf, Grimmzahn, Wildschwein, Hundertfüßer, Spinne, Fledermaus, Blutegel, Goblin, Späher, Kobold, Schamane, Skelett, Wiedergänger, Grabhund, Schnecke, Krogg, Grak); Ansage lesen Stufe 0–3; Wachsen bis Geselle und Goldkerbe; Bedienung 1–6; Bild und Klang ohne Musikebenen; Eiltrank.

**Später:** Team (Kapitel 2, Garrick), Pfadregeln, Meister und Großmeister, Kampfort-Merkmale mit Kerben-Handlung (Baustein 3), Musik in zwei Ebenen, Pfeilarten und Munition, Feuerwand und Blitz.

## 10. Bauplan

Je Stufe ein Prüfpunkt; die nächste beginnt erst, wenn der vorige geprüft ist. Kosten nach dem, was ähnliche Vorgänge gekostet haben (709.1 Bisse 75 $, 1072 Laufwege 30 $, 930.3 Rechnung 9 $); Schätzung, keine Zusage.

| Stufe | Was | Wer | Prüfpunkt | Kosten |
|---|---|---|---|---|
| 0 | **Rechnung ergänzen** (`tools/sim444/glut2.py`): Kobold, Spinne, Fledermaus, gemischte Begegnungen, Ansage-Stufen mit Lesewert, Täuschen; Zahlen für Gegenwert und Vertiefen | Sokrates oder Jerry | keine Herkunft unter 15 Siegen je 100 gegen Krogg (Stufe gleich), keine feste Spielweise in mehr als einem Viertel der Fälle 3 Punkte vorn, Runden höchstens wie heute | 5–10 $ |
| 1 | **Regelkern** in `mars.gd` hinter einem Schalter (alter Kampf bleibt bis zur Abnahme): Kerben-Haushalt, freier Schritt, Lösen, Tun, Vertiefen, Haltung, Antworten, zwei Ringe, Goldkerbe, Fliehen; Gegner 2/3 Kerben, großer Schlag, Lauern; Werte in `werte.json` statt im Code (wie 1049) | Jerry | Kerntests je Regel (je Regelnummer oben ein Test), Rechnung im Spielcode gegen `glut2.py`: Sieg und Runden je Fall ±3 | 30–50 $ |
| 2 | **Bedienung und Kerbmarken** im Kampfort: Fußring, Daumenmenü, Vorschau, Zeichen der Haltung, Verstreichen | Jerry | Film in der Vorschau am Rechner, so gebaut, wie es ins Spiel kommt (Bekannte Fehler 3): Wachsoldat gegen zwei Wölfe, drei Runden; Rundenzeit nicht länger als heute (F9) | 40–60 $ |
| 3 | **Ansage lesen und Gegner**: Stufen im Chip, rote Kerben, „holt aus“, „lauert“, Täuschen, Brechen; Mittel der Langsamen | Jerry, Wortlaute Homer | Bild je Stufe 0–3 an einem Gegner; Film Krogg „holt aus“ | 20–30 $ |
| 4 | **Klang und Effekte** nach 8 | Jerry | Film mit Ton, eine Runde mit jeder Antwort und einer Goldkerbe | 20–30 $ |
| 5 | **Eingebungen und Texte**: erste Haltung, erstes Lauern, erstes Täuschen, Warten gegen Fernkämpfer; Namen im Spiel | Homer, Einbau Jerry | Texte in `STORY-BRS-KAMPF.md`, Marken wie `[930.glut.haltung]` | 5–10 $ |
| 6 | **Testbuild** mit Prüfliste: Handyfragen je Gebiet (Wald Wölfe, Höhle Krogg, Graks Halle) | Jerry, Prüfliste gegengelesen Tom | Test des Chefs | Build |

**Zusammen grob 120–190 $.** Was dabei wegfällt oder sich mitändert: 709, 709.1 (Bisse) und 1072 (Plätze und Laufwege) werden auf die Abstände nah, fern, weit gebaut, nicht vorher (Halt Chef 13.11., 23:35); 1043 Sprung, 1032 Treffer, 1068 Ring beim eigenen Schlag, 931 Wolf und 1000 Graks Ausholen hängen an Stufe 1 und 3; Simulation 444 bekommt das Kerbensystem als Kampfmodell.

## 11. Schnittstellen im Code (heute, auf `main`)

- Ansage: `regeln/mars.gd` 239–264 `_intent(id, de, en, kind, extra, strong, ring, breakable, effect, break_any)`; 17 Ansagen. Neu: Felder `glut` (Kerben, Name im Code bis 1266), `lauert`, `taeuscht`, Stufe je Betrachter.
- Zeichnung der Ansage: `kampf/kampf_ui.gd` 2333–2540 `_draw_intents` (Chip, Zeichen, Goldkreis für Ring, WARN-Rand); Erklärung bei langem Drücken 1206–1245, Texte `kampf/marstips.gd`.
- Ring: `kampf/kampfort.gd` 59–61 (`RING_MS` 1100, `PERFECT_MS` 90, `GOOD_MS` 260), `tap()` 1117–1121, `_answer_ring` 1124–1133; gezeichnet `kampf_ui.gd` 1462–1485. Wehr: langsamer Ring = größeres Fenster, Zahl in Stufe 0.
- Fußring: `kampfort.gd` 1337. Knopfzeilen: `kampf_ui.gd` 951–990.
- Klang: `klang/klang.gd` 419–482 `kampf(e, mars)`, Musik 490; Dateien `daten/klang/sfx`, `music`.
- Effekte: `kampf/zauber.gd` (Funken 134, Glut 300), `kampf/tafel.gd` 87, `held.gd` 73; Pakete R7 `parry_block`, `campfire` (`LISTE-EFFEKTE.md`).
- Rechnung: `tools/sim444/glut2.py`, `glut2_ergebnis.md` auf `claude/sokrates-930-glut` (`a74d7f5e3`).

## 12. Offen beim Chef

1. **Los für Stufe 0 bis 2** (Rechnung, Regelkern hinter Schalter, Film der Bedienung), danach Gespräch über den Film, bevor 3 bis 6 beginnen.
2. Zahlen sind Vorschläge (Vertiefen 20 %, halbe Antworten, zwei Ringe); sie kommen aus Stufe 0 und am Ende aus seinem Test.
3. Goldkerbe ab Heldenstufe 4 und nur einmal je Kampf.
4. **Aus 930.5 fürs Gespräch nach dem Film** (Prüfung Sokrates 14.11., 20:45, nachgerechnet, gleiche Zahlen): Kräutersammler gegen Skelett fällt von 76 auf 39 Siege je 100 (Dolch sticht, Skelett halbiert Stich; dazu gibt Fassung 2 den Ring nur noch auf großen Schlägen, 1048 A); Wolf mit Späher für schwache Herkünfte zu hart (Kräutersammler 42, eine Stufe darunter 4). Beides Balance, nicht Regelkern; Zahlen kommen in `werte.json`, damit sie ohne Umbau zu ändern sind.
