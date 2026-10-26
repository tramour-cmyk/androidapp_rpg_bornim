# Umzug nach Godot (348)

Entschieden 25.10., 00:30–01:04 (Vorgangsarchiv „348, Umstieg“, „348, Umzug Einzelheiten“, „338, Termin“): Umzug jetzt, altes Spiel ruht, kein Release-Termin. **Vorgabe ist das heutige Spiel**: was es zeigt und kann, muss es danach mindestens so gut zeigen und können. Der Chef prüft nur Vergleichsbilder alt/neu. Plan: Sokrates (Vertretung des Chefs, 25.10., 01:19), Abnahme und Wochenziel: Perikles.

## Grundsätze

- **Ein Projekt:** `godot/` im Repo (Arbeitszweige `claude/tom-348-…`, `claude/jerry-348-…`), App-Kennung bleibt `de.bornim.game`, Build über eigenen Workflow; `main` erst nach Test des Chefs.
- **Look aus der Probe** (`tools/godot348/`, Build 12, b71b9a47f): `toon.gdshader` (drei Lichtstufen, `fill` hellt den Helden im Schatten auf), `tusche.gdshader` (Tusche nach Licht, ohne MSAA; Schablone: 1 = ohne Linie wie Blüten, 2 = feinere Linie wie Held, `main.gd` `toon_mark`), Gras `halm.gdshader` ohne Linie, gemalte Texturen aus `tools/blender348/v3/tex.py`. Keiner stellt seine eigene Tusche ein.
- **Modellregel** (Jerry, 348.7): unten im Abschnitt „Modellregel“.
- **Regeln** (`core`) nach GDScript mit denselben Testfällen; Tom Welt, Leute, Story, Läden, Spielstand; Jerry Kampf, MARS, Höhle, Klang.
- **Abgleich:** je Ort und Figur ein Vergleichsbild alt/neu; was fehlt oder schlechter ist, ist ein Fehler.
- **Der Chef sieht mit** (Chef 25.10., 07:46: „wäre es nicht gut, wenn ich als Mensch zumindest mal irgendwo einen Blick auf ein paar Entwürfe werfen könnte, um zu sagen, ah, ja, nein, vielleicht“): jedes Modell (Held, Leute, Tiere, Monster, Häuser, Dinge; Chef 07:47 „betrifft … auch andere Modelle“) zuerst als grober Entwurf neben dem alten Bild, bevor es verfeinert wird; dazu spätestens alle zwei Stunden und nach jedem Abschnitt ein Vergleichsbild alt/neu, alles auf Telegram (`meldung.sh --bild`, Helfer prüft vorher, Vergleichsblätter misst Diogenes vorher: Arbeitsteilung 3); nach drei Prüferrunden ohne Urteil des Chefs keine vierte, sondern Bild an ihn; das Zwei-Stunden-Bild geht immer zum Chef, notfalls mit Befund von Helfer oder Diogenes (Chef 25.10., 13:26). **Schläft der Chef** (nachts, Vertretung), urteilt Sokrates an seiner Stelle (362): Bild trotzdem auf Telegram, dazu Nachricht an Sokrates; ohne laufende Sokrates-Sitzung startet Ford eine. Der Chef sieht morgens die Bilder und kann „zurück“ sagen.

## Woche 1: Fundament (ab 25.10.)

| Nr. | Wer | Was | fertig, wenn |
|---|---|---|---|
| 348.6 | Tom | Godot-Projekt `godot/` mit Held, Steuerung (Tippen, Joystick), Kamera, Licht, Tusche aus der Probe; Kartenformat aus den heutigen Karten (Export aus `core`), Dorf Bornim als erste Gebietskarte mit Kollision und Ein- und Ausgängen | APK am Handy, Vergleichsbild Dorf alt/neu |
| 348.7 | Jerry | Modellregel (oben) schriftlich in dieser Datei; ein Kampfort in Godot: Wolfsrudel in MARS mit den echten Regeln (GDScript), Kamera, Ansagen, Ende | APK am Handy, Vergleichsbild Kampf alt/neu |
| 348.8 | Tom, Jerry | Bestandsliste: jede Gebietskarte, jeder Grundriss, jede Figur, jedes Tier, Monster, Ausrüstung, Gegenstand im alten Spiel, mit Quelle im Code; Spalte „Modell“, „Wer“ | Liste unten vollständig |

## Modellregel (348.7, Jerry, 25.10.)

Gilt für jedes Modell im neuen Spiel: Figur, Tier, Monster, Ausrüstung, Ding, Gebäude.

1. **Maß:** 1 Godot-Einheit = 1 m; 1 Feld der alten Karte = 1,16 m (`Karte.TS` in `godot/skripte/karte.gd`, Probe Build 11, Chef „Welt so ja“; Tom 25.10.), Kampfort mit demselben Maß. Held 1,8 m; alle anderen im Verhältnis wie im alten Spiel (Vorgabe: Vergleichsbild alt/neu nebeneinander), Tiere nach echter Größe (Wolf 0,8 m Schulterhöhe). Export in Metern; `held.glb` der Probe ist in Zentimetern und wird beim Übernehmen umgestellt, nie im Spiel mit 0,01 skaliert.
2. **Herkunft:** jedes Modell ist ein Python-Skript in `tools/blender348/` (Blender als Modul, Version wie im Workflow), das die `.glb` erzeugt; nie von Hand in Blender, nie eingecheckte `.glb` ohne Skript. Fremde Teile nur nach „Fremde Inhalte“ (`CLAUDE.md`).
3. **Ausrichtung:** Ursprung am Boden unter dem Schwerpunkt (Mensch: zwischen den Füßen), Blick nach glTF +Z (Blender −Y), oben +Y.
4. **Skelett:** Menschen aller Völker auf dem fremden CC0-Gerüst (Quaternius, Universal Animation Library, 65 Knochen, dessen Knochennamen; Chef 25.10., 23:33, 348.12, Archiv): Zwerg, Halbling, Elf, Halbork über Knochenlängen nach `Doll.kt` (`v3/cc0.py VOLK=`, Probe trägt: Füße am Boden, keine Risse); Körper und Kleidung bauen wir selbst darauf. Menschenähnliche (Goblin, Grak, Zombie) bis zur Prüfung durch Jerry weiter mit `rig.py`. Tiere ein Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne), in allen Modellen dieser Bauart gleich benannt. Waffen, Schilde, Fackel als eigene `.glb`, im Spiel an den Handknochen gehängt, nicht ins Netz gebacken; Griffpunkt = Ursprung.
5. **Bewegungen:** im Skript erzeugt; Menschen aus der CC0-Bibliothek (Quaternius, 43 Bewegungen, davon 32 brauchbar), im Skript deutsch benannt, Beckenverschiebung je Volk mit der Beinlänge; was dort fehlt (Stich, Ausweichen, Abwehr), im eigenen Skript auf demselben Gerüst; Hieb dort 1,5 s, auf 0,8 s noch ungeprüft. 30 Bilder je Sekunde, deutsche Namen wie im alten Spiel (Stehen, Gehen, Ausholen, Hieb, Stich, Biss, Sprung, Treffer, Ausweichen, Abwehr, Sturz, Aufstehen, Tod …); Schleifen nahtlos; Füße am Boden, Gehtempo in `<name>-info.json` (wie `held-info.json`), damit nichts gleitet. Schlagzeiten wie `DESIGN-ABNAHME.md` (Biss, Stich 0,6 s; Hieb 0,8 s).
6. **Aussehen:** Farbe gemalt wie `tex.py` (Textur oder in Eckfarben gebacken), höchstens 1024 px; kein Glanz außer Gold (Signatur); Licht und Tusche nur aus `toon.gdshader` und `tusche.gdshader`, nie im Modell. Mindestens drei Varianten (Fell, Statur, Kleidung) als Schalter im Skript; ebenso jedes Objekt, das mehrfach vorkommt (Blumenkästen, Fässer, Kisten, Zäune, Höhlenobjekte; Chef 25.10., 08:42: „Ist nur doof, wenn alle Blumenkästen gleich aussehen … denkt an die Varianten der Objekte auch“). Keine Kachelgrenzen sichtbar: Wege, Wiesen, Plätze, Pflaster unregelmäßig, nie gerade Linien oder rechte Winkel (Chef 08:46: „Natur ist wild, der Mensch ist eigentlich nicht in der Lage, gerade Linien zu ziehen“). Ebenso Hausfassaden und Dächer: Moos, kleine Schäden, Abnutzung, nie zwei gleich (Chef 08:48).
7. **Größe:** Figur höchstens 6000 Dreiecke, Ausrüstung höchstens 800, Ding höchstens 2000 (Samsung A56, `DESIGN-ABNAHME.md` Leistung); mehr nur nach Messung.
8. **Name:** Datei = Kennung im alten Spiel (`wolf.glb`, `hobgoblin_captain.glb`, `shortsword.glb`), angezeigter Name aus den Regeln, nie im Modell.
9. **Geprüft vor Abgabe:** Kontaktblatt aller Bewegungen (`blatt.py`), Durchdringung Waffe/Körper 0, Fußgleiten gemessen, Vergleichsbild alt/neu in der Bestandsliste vermerkt (Spalte „Modell“: Skript, Stand). **Kurzvideo** (368, Chef 26.10., 16:23: „wäre schon sinnvoll, wenn ich das … auch mal sehen würde“): jedes Modell mit Bewegungen geht mit einem MP4 (H.264, 5–15 s, höchstens 10 MB) an den Chef: alle Bewegungen nacheinander, Name eingeblendet, Vergleich nebeneinander (alt/neu oder eigen/fremd), Grundansicht, Bild wie im Spiel (Licht, Tusche); in jeder Runde, in der Bewegungen neu sind oder sich ändern, und bei „gebaut“. Kontaktblatt und Video aus denselben Bildern; geprüft wird das Kontaktblatt (Diogenes sieht keinen Film, 75j), der Text nennt, woraus das Video gemacht ist. Senden: `meldung.sh --datei <video.mp4> <Name> "<Nr>: …"`.

**Urteil Chef Wölfe (25.10., 08:57, Vergleichsbild 07:51):** „Die Richtung passt, aber im Moment ist es noch nicht so wirklich wolfig. Der am ehesten wolfig ist, ist der dunkelste Wolf.“ Ändern: (1) alle drei in exakt gleicher Haltung; (2) Körper nicht zum Gegner gedreht („wo die hinlaufen wollen, weg wahrscheinlich“); (3) Schnauze kommt nicht heraus; (4) Augen fehlen; (5) Ohren prägnanter; (6) Körper passt; (7) Textur gleich bis auf die Farbe, drei echte Varianten; (8) Animationen: atmen, mal Lefzen zeigen, mal scharren. Helden im Kampfort: „völlige Klone“, Rückansicht ohne Texturen, „schaut … wie eine Statue aus“ (gesprochen „Stute“).

**Urteil Chef Dorf-APK (25.10., Lauf 46; über Sokrates):** 18:06 (Bild), „Mehrfach bereits angesprochen“: „Brunnendach verkehrt, Brunnen nicht offen in der Mitte“, Marktstanddach „nicht auf Stand, sondern schwebt auf einer Seite“ (Tom). 18:07: „Ratte viel zu klein für eine Riesenratte“; 18:20 nach 0,44 m: „Die Ratte muss deutlich größer sein“ (Jerry). 18:20 Wolf: „sieht eher aus wie ein Kojote. Der Wolf ist im Rist gleich hoch vorne und hinten. Der Brustkorb geht dann nach unten weiter und ist muskulös. Also der muss irgendwie hinten angehoben werden“ (Jerry). 18:20 Held: „Die Fackel des Helden trägt immer noch hinten“; „Der Übergang von Gehen zu Rennen ist zu krass. Außerdem ist es keine Rennanimation, sondern nur eine … beschleunigte Gehen-Animation“ (Tom). 18:20 Leute: „das Gehen der einzelnen Leute an sich läuft“; „egal wer steht, so circa im 3 bis 4 Sekunden Takt glitscht dann die Figur und zuckt“ (Tom). 18:28 zur Testbitte: „Zu 348.6 gibt es ja nix freizugeben. Rest war okay. Der kleine Junge marschiert ein bisschen wie ein Soldat“ (Tom; Pim). **Chef 25.10., 17:03, Gang je Figur** (offen; fiel 19:58 aus Toms Vorrat, Sokrates 26.10. wieder eingetragen): „Kind ein bisschen flotter, eine Dame schreitet mehr, ein alter Bauer geht langsam. Und schleift vielleicht Bein noch“ (Tom; Helfer 25.10.: Hinken kaum sichtbar, Pims Takt kaum schneller).

**Urteil Chef Lauf 75 (26.10., 11:41, über Sokrates):** „sieht alles schon recht schön aus“; aber (1) Gesicht des Helden „völlig nichtssagend … schrecklich, möchte ich fast sagen“ (Tom); (2) Leute wenden um 180° „sehr flott … wirkt jetzt nicht sehr natürlich. Aber wir wollen ja eine natürlich lebendige Welt haben“ (Tom: Wenden langsamer, über Schritte). 11:42: „Lauf 75 … auf dem Rechner über MuMu-Player nicht laufen lassen. Das startet da nicht. Auf Handy ging's“ (Tom: Ursache, z. B. x86 oder Vulkan).

## Arbeitsteilung ab 25.10. (348.9, Chef 12:24: „Super Vorschläge“)

1. **Perikles:** Meilenstein „Kapitel 1 auf Godot mindestens so gut wie alt“; Checkliste = Bestandsliste 348.8, je Zeile ein Stand; Tagesziele je Team; täglich ein Stand an den Chef.
2. **Modelle jetzt** (statt ab Woche 2): erst Licht nach 3486-sonne, dann je Bauart ein Grundmodell (Mensch, Vierbeiner, Vogel, Insekt, Spinne), daraus alle Leute, Monster, Tiere ableiten; Häuser und Dinge parallel; Aufteilung unten.
3. **Diogenes:** misst jedes Vergleichsblatt alt/neu, bevor es zum Chef geht (Helligkeit, Schatten, Vollständigkeit gegen die Bestandsliste); Rollenänderung gegenüber „nur auf Anlass“ und 75j (höchstens 10 Bilder), Perikles passt `ROLLE-PRUEFUNG.md` an.
4. **Homer:** schlägt die Stimmung je Ort und Tageszeit vor; nach Billigung des Chefs Messlatte für Diogenes; sieht jeden Modellentwurf vor dem Chef.
5. **Drehen** (Chef 12:24: „die Perspektive ändert sich sowieso, wenn man die Karte dreht … was ja im alten Spiel gar nicht ging“): alt/neu nur in der Grundansicht vergleichen; jedes Modell und Haus von allen Seiten fertig (Rückseiten texturiert), Kontaktblatt aus vier Richtungen; gedrehte Ansichten prüft Diogenes gegen Regeln statt gegen alt (Schatten passt zur Sonne, nichts flimmert, nichts verdeckt).
6. **Grundansicht wie alt** (3486 a, Chefrunde 25.10., 13:26; ersetzt „nach Süden“ 12:25): Kamera im Südosten, Blick nach Nordwesten, Türen und Fronten zum Betrachter; Sonne wie in der Natur. Schatten mittags kurz nach rechts hinten, morgens lang nach links hinten, abends lang nach rechts vorn.
7. **Abnahmeliste je Modell** (348.11, Chef 25.10., 21:21 „a ja“): vor Runde 1 legt Homer 4–5 prüfbare Punkte fest (Größe gegen den Helden, Umriss, Merkmal, Farbe, Haltung), der Chef billigt sie einmal (Chefsache); Helfer, Homer, Diogenes urteilen nur danach, alles andere kommt auf die Feintuning-Liste; laufende Modelle ab der nächsten Runde (Goblin Runde 4 läuft nach Chef 21:12, Liste gilt ab Runde 5). Die Listen stehen in `LISTE-FIGUREN.md` „Abnahmelisten“ (Chef 22:00: Goblin, Wildschwein, Held, Leute gebilligt).

## Stimmung und Messlatte (348.9, Chefrunde 25.10., 13:26: 3489 1 a, 2 ja)

**Stimmung:** Helligkeit und Farbe wie im alten Spiel; Gradmesser Leitbild 1 „düster, erwachsen, glaubwürdig“ (Chef 13:11: „quietschehell passt einfach nicht“), düster durch Licht und Schatten, nicht durch Dunkelheit. Tageszeiten wie alt: Morgen bis 10 Uhr (Dämmerung 5–7), Mittag 10–15, Nachmittag 15–19, Abenddämmerung 19–21, Nacht 21–5. Tom eicht `licht.gd` je Tageszeit auf die Tafel, mit Dämmerung, Tönung und Randabdunklung wie `MapGrade` (Dämmerung violett, Nacht blau, Höhle kalt-grünlich; Ränder am Tag 0,18–0,22 dunkler, nachts bis 0,36); Räume, Wald, Höhle je Ort beim Bau.

In Klammern: altes Bild, Mittel/Streuung (0–255), Grundansicht, ohne Leiste, Ausschnitt wie unten; bei Räumen, Höhle, Wald zählt der schwarze Rand mit.

| Ort | Morgen | Mittag | Nachmittag | Abenddämmerung | Nacht |
|---|---|---|---|---|---|
| **Dorf** | Sonne tief im Osten, blasses Gold, lange Schatten nach links hinten, Schatten blaugrau; Ostseiten hell, Rauch aus den Kaminen (64/21) | gedämpft, leicht verhangen, Erdfarben, Moos und Ruß statt Bunt; Fronten zum Betrachter im Licht, kurze dunkle Schatten nach rechts hinten (65/21) | Sonne im Westen, warmes Kupfer, lange Schatten nach rechts vorn, Schattenseiten kühl (66/20) | rötlich-violett, Fenster und Laternen gehen an: erste warme Inseln (51/15) | kaltes Blauschwarz, Mondlicht; Laternen und Fenster als warme Kegel mit Abfall, Wege bleiben lesbar (28/14) |
| **Flüsterwald** | wie Dorf, unter den Kronen grüner und dunkler | grünlich gefiltert, Lichtflecken durch die Kronen (33/24) | wie Mittag, wärmer | rötlich-violett, dunkler als das Dorf (23/16) | blau, sehr dunkel; Glühwürmchen, Garricks Feuer als einzige warme Insel (12/8) |
| **Tiefer Flüsterwald** | schattig, kaum Sonne | schattig-grün, nie sonnig; Held immer ganz sichtbar (353a) (21/21) | wie Mittag | früher dunkel, rötlich-düster | dunkler als der Wald; Morwens Fenster als warme Insel (10/10) |
| **Gasthaus** | grauer Fensterschein, Kamin warm, Ecken dunkel | wie Morgen (18/24) | wie Morgen | Kerzen und Kamin tragen | nur Kamin und Kerzen, warm, Ecken fast schwarz (11/19) |
| **Laden, Ältester** | grauer Fensterschein, Kerze am Pult oder Tisch | wie Morgen (Laden 18/26, Ältester 12/20) | wie Morgen | Kerzen | Kerzen, sonst dunkel |
| **Tempel** | kühles, helles Fensterlicht, Altarkerzen gold | wie Morgen (26/37) | wie Morgen | Altarkerzen tragen | dunkel, etwas kälter als die anderen Räume |
| **Höhle** | immer fast schwarz; nur Fackeln warm, Pilze türkis, Kristalle violett, Lichtspalt am Tag weiß, nachts Mond (18/19) | | | | |

Farbe alt: Dorf am Tag warm (R−B +18 bis +26), nachts neutral (−1).

**Messlatte (Diogenes):** je Feld des Vergleichsblatts altes Bild gegen neues an derselben Stelle, zur selben Uhrzeit, in der Grundansicht; ohne altes Bild gegen die Tafel.
- **Maß:** `tools/vglmass.py` (Diogenes, Zweig `claude/diogenes-3489-messung`): L = 0,299 R + 0,587 G + 0,114 B (0–255) ohne obere und untere 12 %; Mittel, Streuung (Standardabweichung) von L, Mittel von R−B. Die Tafelwerte sind mit Ausschnitt Höhe 12–85 %, Breite 8–92 % gemessen, darum nur Anhalt; verbindlich ist das alte Bild im selben Blatt.
- **Grenzen:** Mittel höchstens 5 % vom alten entfernt, mindestens ±2 Stufen; Streuung höchstens 25 % über alt; R−B mit gleichem Vorzeichen wie alt, |R−B| ≤ 3 gilt als neutral und passt zu jedem.
- **Folge (Chef 14:33, ersetzt 13:26):** die Messlatte ist nur Hinweis, kein Halt; jedes Blatt geht mit dem Befund zum Chef. Das alte Spiel ist Vorlage, keine identische Kopie; Maß ist das Leitbild „düster“ (`DESIGN-LEITBILD.md`), „ein Prozentpunkt heller ist kein Beinbruch“. Zurück ans Team nur, was sichtbar gegen das Leitbild verstößt (deutlich heller oder bunter, Richtwert über 15 %).
- **Höchstens 10 Runden je Modell oder Ort** (Chef 14:33: „maximal 10 Versuche und dann steht mal ein Wolf und das Feintuning macht dann ich“): nach der zehnten Runde steht das Modell, das Team baut das nächste; Feinschliff nur auf Wort des Chefs.
- **Alte Bilder:** `tools/t bild KARTENZOOM=1 ONLY=zoom_nah_p "HELDORT=village:19:13:d:8;…:12;…:17;…:20;…:23;forest:9:29:u:12/20/23;deep_forest:2:18:r:12/23;inn:4:6:u:12/23;temple|shop|elder:4:6:u:12;cave:10:17:u:12"` (Homer 25.10., 13:00, etwa 25 Minuten).

## Modelle und Orte nach Bestandsliste (ab sofort)

Aufteilung nach Bereich (Tom: Leute, Häuser, Innenräume, Dorftiere wie Hühner, Katzen, Hunde; Jerry: Monster, Wald- und Höhlentiere wie Frösche, Libellen, Schmetterlinge, Höhle, Waffen und Rüstungen), Reihenfolge wie Kapitel 1 gespielt wird.

## Bestandsliste (348.8)

Pfade: `core/` = `core/src/main/kotlin/de/bornim/core/`, `art/` = `core/art/`, `ui/` = `app/src/main/java/de/bornim/game/ui/`. Spalte „Modell“: Skript in `tools/blender348/`, Stand (– = keins).

**Checkliste des Meilensteins Umzug** (348.9, `LISTE-ABNAHME-KAPITEL1.md`): jede Tabellenzeile und jeder fette Absatz ohne Tabelle (Ausrüstung: jeder Unterpunkt) ist ein Punkt. Der Stand steht unter „Modell“ (nach dem Skript, bei Absätzen als „Modell: …“ am Ende; fehlt er, gilt –) als eines dieser Wörter: **–** (nichts) · **Entwurf** (grob neben dem alten Bild beim Chef) · **gebaut** (fertig im Godot-Zweig, Vergleichsblatt da) · **gemessen** (fertiges Vergleichsblatt von Diogenes ohne Befund) · **abgenommen** (Chef ja zum Vergleichsblatt, mit Datum; auch sein „steht“ nach der Grenze 10 Runden, Feinschliff bleibt eigene Zeile; Perikles 26.10. auf Frage Jerry). Jedes Bild, auch ein Entwurf, geht erst zu Diogenes, Modellentwürfe auch zu Homer (Arbeitsteilung 3, 4), dann zum Chef; mit Bewegungen samt Kurzvideo (Modellregel 9, 368). Bis „gebaut“ schreibt das Team, „gemessen“ Diogenes, „abgenommen“ das Team nach dem Wort des Chefs. Bei Karten, Grundrissen und Funktionen meint „Modell“ die ganze Umsetzung (Boden, Dinge, Leute, Licht, Bedienung).

Kartenformat für alle Karten: `MapExport.kt` → `godot/daten/karten.json`.

### Bereich Tom (Tom 25.10.)

**Schätzung 348.14 (Tom 26.10.):** Spalte oder Satz „Schätzung“ je Punkt: S = Sitzungen bis „gebaut“, R = erwartete Bilderrunden (Blatt über Diogenes zum Chef). Summe Bereich Tom: **78,75 ≈ 79 S, 59 R** (Gebietskarten und Grundrisse 21 S/20 R, Dinge und Möbel 5/4, Leute und Held 11,25/5, Dorftiere 5/4, Gegenstände 1/1, Oberfläche 3/2, Funktionen 32,5/23); Spanne ±25 % 59–99 S, bei rund 8 $ je Sitzung 470–790 $. Grundlage: seit 25.10., 01:19 rund 40 Sitzungen Tom für 348.6 (318,93 $), daraus Fundament, Dorf (13 Runden), Held (5), Leute (4 Runden, CC0-Gerüst 4, Feinschliff 4), also etwa 1,3 Sitzungen je Runde. Nicht enthalten: Warten auf den Chef und Chefsachen, „gemessen“, „abgenommen“, Leistung am Tablet (267). Annahmen: Abnahmeliste vor Runde 1 und höchstens 10 Runden (348.11; Chef 14:33) halten es bei 2–4 Runden je Punkt; Listen gibt es bisher nur für Held, Leute, Goblin, Wildschwein, Monster, für Gebietskarten, Grundrisse, Dinge, Möbel, Dorftiere, Söldner schreibt sie Homer und billigt der Chef vor Runde 1 (nicht in den S); Waffen und Fackel an der Hand (Speer, Hammer, Bogen), Vierbeiner und Vogelskelett von Jerry. **Offen beim Chef (Aussehen), wenn der Punkt dran ist:** Intro, Zwischenbilder, Gegenstände als Bilder aus dem alten Zeichner (geschätzt) oder neu in 3D (+6 S, +5 R). Stärkstes Gegenargument: die Grenze von 10 Runden hielt bisher nicht (Dorf 13, Leute 12), Feinschliff brauchte 4 Sitzungen für 4 Figuren und ist nicht fertig; gilt das weiter, sind es rund 110 S (880 $) oder mehr.

**Gebietskarten und Grundrisse** (genau 8, `World.maps` `core/World.kt:205`; keine Ebenen, Kapitel 2 ohne Karte):

| Kennung | Name | Quelle | Zeichner alt | Modell | Wer | Schätzung |
|---|---|---|---|---|---|---|
| village | Bornim (36×32) | `Story.kt:129` | `MapGround`, `MapTownIso`, `MapWoodIso.fieldObjects`, `MapFlora`; verteilt in `WorldArt.buildObjects` | `v3/dorf.py`, Entwurf (348.6) | Tom | 3 S, 2 R (Runde 13b, Grenze 10 überschritten: nur Fehler laut Chef, „Mehrfach bereits angesprochen“: Brunnen, Stand; Rest Runde 11, Sonne) |
| inn | Zum Schlafenden Greif | `Story.kt:296` | `MapRoom`, `MapRoomIso.objects` | – | Tom | 5 S, 4 R (erster Grundriss: Wände, Kamera, Kerzenlicht, schwarzer Rand) |
| shop | Thessas Kramladen | `Story.kt:364` | wie inn | – | Tom | 2 S, 2 R |
| elder | Haus des Ältesten | `Story.kt:390` | wie inn | – | Tom | 2 S, 2 R |
| temple | Tempel des Morgenlichts | `Story.kt:478` | wie inn | – | Tom | 2 S, 2 R |
| forest | Flüsterwald | `Story.kt:524` | `MapGround`, `MapWoodIso`, `MapFlora`, `MapEdge` | – | Tom | 4 S, 4 R (Kartenrand, Teiche, Garricks Feuer) |
| deep_forest | Tiefer Flüsterwald (mit Morwens Hütte, `HUT`) | `Story.kt:619` | wie forest, Hütte `MapTownIso.houseObjects`; Anforderung 353a (Chef 25.10.): Held immer ganz sichtbar, Weg voraus erkennbar (Probe Zweig `claude/tom-353-sicht-probe`) | – | Tom | 3 S, 4 R (Sicht 353a) |
| cave | Blutzahnhöhle | `Story.kt:731` | `MapCaveIso` | – | Jerry | unter „Höhle“ im Bereich Jerry (11 S, 10 R) |

**Dinge im Dorf** (Kachelzeichen `core/World.kt:3-84`, Zeichner `art/MapTownIso.kt`, sonst genannt): Haus mit Gasthausschild, Markise, Glockenturm (`Story.kt:196-206`; `house` :77), Brunnen `w` (:734), Stand `m` (:772), Laterne `l` (:823; Sonderfälle Kaels Tür 24/6 :850, Brücke 19/27 :930), Bank `n` (:958), Fass `b` (`MapRoomIso.barrelOutside`), Brücke `h` (:945), Zaun `x` (:1255), Schlagbaum `z` (:1182), Schild `S` (:611), Anschlagbrett `!` (:646), Hof `p` (:975, :986: Heukarren 13/9, Waschzuber 11/11, Holzstapel 2/5 und 28/13, Netz 7/24 und 22/27), Korn `c`, Beet `v`, Heu `y`, Wäscheleine `q` (`MapWoodIso.fieldObjects`), Baum `T` (Eiche, Fichte, toter Baum, Stumpf, Busch; `MapFlora.kt:140-173`), Blumen `f`, Rauch (`ui/WorldScreen.kt:2109`, `MapTownIso.chimneyTops`). In `dorf.py` fehlen noch: Heukarren, Waschzuber, toter Baum, Sonderlaternen, Gasthausschild, Markise (Stand 25.10.). Schätzung: 2 S, 2 R (fehlende Dinge, Varianten).

**Möbel der Grundrisse** (`art/MapRoomIso.kt`): Theke `K`, Tisch `Y`, Bett `B`, Regal `Q` (Laden: Waren, Ältester: Bücher), Altar `A`, Kamin `Z` (Rauch `WorldScreen.kt:2274`), Kram `J` (:2184-2198), Pult `d`, Truhe `a`, Lehnstuhl `s`, Wandtuch `V`, Gestell `U`, Kerzen `N`, Weihwasser `&`, Kisten `u`, Bank, Fass; Wandschmuck `MapRoom.wallThing` (:268); Borins Hocker und Hammer (:2136). Modell: –, Tom. Schätzung: 3 S, 2 R (für alle vier Grundrisse).

**Leute** (Puppe `Doll` + Outfit `art/MapFolk.kt`, gezeichnet `MapFigure.render`; Tagesablauf `core/VillageDay.kt`, Stammplätze `core/MapPeople.kt`). Skelett für alle: `v3/rig.py` (Modellregel 4). Modell: `v3/held3.py` mit `FIGUR=<kennung>`, Werte in `v3/leute.json` (Tom 25.10.).

| Kennung | Name | Quelle | Aussehen (`MapFolk.kt`) | Modell | Schätzung |
|---|---|---|---|---|---|
| jorin | Wache Jorin | `Story.kt:209` | guard :59 | `leute.json`, Entwurf | 1 S, 2 R (Saum; Speer von Jerry) |
| pim | Pim (Kind) | `Story.kt:225` | child :62 | `leute.json`, Entwurf | 0,5 S, 2 R (Gang „wie ein Soldat“) |
| bram | Bauer Bram | `Story.kt:233` | farmer :65 | `leute.json`, Entwurf | 1 S, 2 R (Saum, Schulter) |
| liska | Liska | `Story.kt:241` | maid :68 | `leute.json`, Entwurf | 0,25 S, 2 R |
| gwenna | Gwenna | `Story.kt:249` | villager :71 | `leute.json`, Entwurf | 0,5 S, 2 R (Unterarm) |
| rowena | Rowena | `Story.kt:313` | innkeeper :44 | `leute.json`, Entwurf | 0,25 S, 2 R (Krug) |
| borin | Borin (Zwerg, sitzt) | `Story.kt:341` | dwarf :74 | `leute.json`, Entwurf | 1 S, 2 R (Arm, Bart; Hammer von Jerry) |
| thessa | Thessa | `Story.kt:380` | merchant :50 | `leute.json`, Entwurf | 0,25 S, 2 R |
| aldric | Ältester Aldric | `Story.kt:404` | elder :47 | `leute.json`, Entwurf | 0,5 S, 2 R (Stab: Chefsache 3486-aldric-stab) |
| osric | Bruder Osric | `Story.kt:495` | priest :53 | `leute.json`, Entwurf | 1 S, 2 R (Kopf, Hals) |
| lyra_temple, lyra_cave | Lyra | `Story.kt:509`, `:776` | lyra :56 | `leute.json`, Entwurf | 0,5 S, 2 R (zwei Orte) |
| garrick | Jäger Garrick | `Story.kt:579` | hunter :30 | `leute.json`, Entwurf | 0,5 S, 2 R (Bogen auf dem Rücken von Jerry) |
| morwen | Kräuterfrau Morwen | `Story.kt:681` | herbalist :77 | `leute.json`, Entwurf | 0,5 S, 2 R (Haltung) |
| merc | Söldner (nur MARS-Probe) | `core/Skirmish.kt:1220` | wie Held (`Hero.create`) | – | 0,5 S, 1 R |
| Held | Held, vier Klassen | – | – | `v3/held3.py` + `rig.py`, Entwurf (348.6) | 3 S, 2 R (Halt der Fackel, Modell von Jerry; Rennen, Varianten, Rücken, Schild) |

Die zwei Runden der Leute sind zwei gemeinsame Blätter für alle 13, nicht je Figur; die Leute hatten schon 12 Runden (Grenze 10), darum nur noch Fehler mit Befund „stark“ und Wort des Chefs.

Grimmzahn, Krogg, Grak stehen auf Karten, sind aber Monster (Bereich Jerry).

**Dorftiere** (Modell: –, Tom): Huhn, 3 Gefieder, je 2 an jedem Heuballen (`art/MapHen.kt:474`); Katze im Gasthaus (`art/MapCat.kt:142`); Dorfhund (`art/MapDog.kt:144`: 24/10, 30/7, 19/9); Vögel (`art/MapBirds.kt:26`, Pixel). Keine Nutztiere, keine Tiere in Laden, Ältestenhaus, Tempel. Schätzung: 5 S, 4 R (Hund, Katze aus Jerrys Vierbeiner; Huhn, Vögel auf dem Vogelskelett, das Jerry mit der Fledermaus baut; Perikles 26.10.). **Chef 26.10., 19:09 (über Sokrates):** Huhn aus dem gekauften Janpec-Paket statt Eigenbau, „erst wenn Rattenprobe gelaufen ist. Sollte ja dann auch einfacher für Dorfhund und Katze gehen“: nach 348.12f Huhn, Hund, Katze aus Janpec, falls im Paket (sonst CC0 CDmir, `LISTE-CC0-MODELLE.md`); drei Gefieder durch Bemalung; Blatt an den Chef.

**Gegenstände** (Bilder, Modell nur, was der Held trägt): 21 Vorrat und Quest (`core/Items.kt:38-88`; Bild `art/SupplyArt.kt`, ohne eigenes Bild: spark_potion, gwenna_ring, grey_rag, smoke_bundle), Ladenwaren (`Story.kt:107`, `:42`; `Loot.shopGear`). Ausrüstung (57 Grundtypen `core/Gear.kt:269-336`, 9 Einzelstücke `:369-389`, Bild `art/ItemArt.kt`): Bereich Jerry. Schätzung: 1 S, 1 R (Bilder aus dem alten Zeichner übernehmen).

**Oberfläche im Dorf** (`ui/WorldScreen.kt`, Tom): Leiste oben `HudChip` (LP, ZP, EP, Stufe, Uhr, Zustände, Beutel; :2827), Ausdauer `StaminaBar`, Handlungs- und Rennknopf `ActionButton` (:2955), Steuerkreuz (:2922), Gesprächsfenster `DialogBox` (:2900), Schwarzblende `MapVeil`; Menü `MenuScreen` (Held, Tasche, Ausrüstung, Karte, Chronik, System, Test); Laden, Anschlagbrett, Rast (:96-100). In Godot heute nur Knöpfe, Textfeld, Joystick (`steuerung.gd`). Schätzung: 3 S, 2 R (ohne Menü, Laden, Brett, Rast: unter Funktionen).

### Bereich Jerry (Jerry 25.10.)

Wer: Jerry. Modell: Stand je Zeile (26.10.); Held: Tom. Vorkommen: Kapitel 1 endet bei Stufe 6, darum Ausrüstung bis Mindeststufe 6.

**Schätzung 348.14 (Jerry 26.10.):** Spalte oder Satz „Schätzung“ je Punkt wie bei Tom: S = Sitzungen bis „gebaut“, R = erwartete Bilderrunden. Summe Bereich Jerry: **rund 95 S, 79 R** (Monster 35,5 S/43 R, Kleintiere 2/2, Höhle mit Kampforten 11/10, Ausrüstung 13/10, Funktionen 33,5/14); Spanne ±25 % 71–119 S, bei rund 7 $ je Sitzung 500–830 $. Bei schon gebauten Modellen zählt die offene Nacharbeit (Wort des Chefs, CC0-Gerüst). Grundlage: seit 25.10., 01:19 rund 50 Sitzungen Jerry (348.7: 303,85 $, dazu Jerrys Teil an 348.9), daraus MARS-Regeln in GDScript mit Goldtests (`godot/regeln/mars.gd`, Zustände, Fliehen, Lohn), Kampfort mit Ansagen, Grundmodelle Vierbeiner und Goblin und rund 61 Bilderrunden (Kampfort 16, Wolf und Grimmzahn 11, Boden 6, Ratte 11, Wildschwein 3, Goblin 6, Späher 4, Schamane 3, Kobold 1 mit vier Zwischenständen), also etwa 0,8 Sitzungen je Runde; die Codearbeit jener Sitzungen steckt darin, für reine Modelle ist das ein Puffer (Funktionen sind getrennt geschätzt). Abgeleitete Modelle brauchten nach Goblin 3–4 Runden (Späher 4, Schamane 3+), neue Bauarten 10–11 (Wolf, Ratte vor der Abnahmeliste); angesetzt: abgeleitet 2–3 R, erste ihrer Bauart (Spinne, Insekt, Vogel) 4–5 R, Endgegner 4 R. Nicht enthalten: Warten auf den Chef und Chefsachen, „gemessen“, „abgenommen“, Feinschliff auf Wort des Chefs, Messung am A56 (211.14), Balance in MARS (38, D23.3), Schwierigkeit (39), Kür 344.2, 296.3. Annahmen: Abnahmeliste vor Runde 1 (Homer, Chef billigt; nicht in den S), Grenze 10 Runden (348.11; Chef 14:33); Held mit Klasse und Kleidung von Tom (`held3.py`), auf den Rüstung und Waffen passen; Vogelskelett baut Jerry mit der Fledermaus, Tom nutzt es für Vögel und Huhn. **Hebel beim Chef:** 348.12c (Sokrates, fertiges Modellpaket): passt ein Paket für Skelett, Zombie, Ghul, Spinne, Fledermaus, Gallerte, spart das etwa 10 S, 15 R (Anpassen an Maß, Tusche, Knochennamen bleibt). Stärkstes Gegenargument: die Grenze von 10 Runden hielt bei Jerry nicht (Kampfort 16, Ratte 11), und jede neue Bauart brauchte bisher über 10; gilt das weiter (neue Bauarten 11 R statt 4–5: +20 R; Höhle wie Dorf 13 statt 5: +8 R; übrige je 1 R mehr: +8 R; zusammen +36 R ≈ +29 S), sind es rund 125 S (870 $) oder mehr.

**Monster** (Regeln `core/Monsters.kt`, Rudel `core/Packs.kt`; Bild alt `art/FoeArt.kt` + Ausrüstung `core/MonsterKit.kt` für Menschenähnliche, `art/BeastArt.kt`/`WolfArt.kt` Tiere, `art/VerminArt.kt` Ungeziefer):

| Kennung | Name | Quelle | Bild alt | Wo | Skelett | Modell | Schätzung |
|---|---|---|---|---|---|---|---|
| wolf | Wolf | `Monsters.kt:91` | WolfArt | Flüsterwald, Tiefer Wald; Rudel, Leibwache Grimmzahns | Vierbeiner | `wolf.py`, gebaut (Runde 10; Chef 25.10., 21:03 „Wolf steht“) | 0 (Feinschliff nur auf Wort des Chefs) |
| dire_wolf | Grimmzahn | `:133` | WolfArt 1,45-fach | Endgegner Tiefer Wald (22,4) | Vierbeiner | `wolf.py ART=dire_wolf`, gebaut (Runde 10 und Pony; Chef 22:00 „kleiner“) | 0,5 S, 1 R (Chef 22:00: kleiner, Schulter 1,3 m) |
| boar | Wildschwein | `:145` | BeastArt | Wald am Tag | Vierbeiner | `wildschwein.py`, Entwurf (Runde 3 beim Chef) | 1,5 S, 2 R |
| giant_rat | Riesenratte | `:87` | BeastArt | Wald am Tag, Höhle | Vierbeiner | `ratte.py`, gebaut (Runde 11; Chef 25.10., 19:43 „Ratte steht“) | 0 (Dorfratte: Tom) |
| goblin | Goblin | `:96` | FoeArt, Kit :34 | Wald, Höhle; mit Späher | Mensch | `goblin.py`, gebaut (Runde 6 steht, billigen/3487-goblin-r6) | 3 S, 2 R (Goblin, Späher, Schamane, Kobold aufs CC0-Gerüst, 348.12; Feinschliff laut Chefsache) |
| goblin_archer | Goblin-Späher | `:102` | FoeArt, Kit :41 | Wald am Tag, Höhle | Mensch | `goblin.py ART=goblin_archer`, gebaut (Runde 4b, 26.10.) | 0 (Gerüst unter Goblin) |
| goblin_shaman | Goblin-Schamane | `:165` | FoeArt, Kit :78 | Tiefer Wald, Höhle | Mensch | `goblin.py ART=goblin_shaman`, gebaut (Runde 4c steht, 26.10.) | 0 (Gerüst unter Goblin) |
| kobold | Kobold | `:160` | FoeArt, Kit :47 | Wald; Rudel | Mensch | `goblin.py ART=kobold`, Entwurf (Runde 2c bei Diogenes, 1facdedd5; steht, wenn Prüfer und Diogenes (a)–(e) bestätigen) | 0,5 S, 0–1 R |
| skeleton | Skelett | `:108` | FoeArt, Kit :84 | Wald nachts, Höhle | Mensch | – | 3 S, 4 R (Knochen statt Haut, Leuchten) |
| zombie | Zombie | `:115` | FoeArt, Kit :53 | Wald nachts, Höhle | Mensch | – | 2,5 S, 3 R (aus dem CC0-Menschen) |
| ghoul | Ghul | `:175` | FoeArt, Kit :71 | Tiefer Wald nachts, Höhle | Mensch | – | 2,5 S, 3 R (aus Zombie) |
| bugbear | Krogg | `:127` | FoeArt, Kit :60 | Endgegner Höhle (16,9) | Mensch | – | 3 S, 4 R |
| hobgoblin_captain | Grak | `:139` | FoeArt, Kit :65 | Endgegner Höhle (10,2) | Mensch | – | 3 S, 4 R |
| giant_spider | Riesenspinne | `:121` | VerminArt | Tiefer Wald, Höhle | Spinne | – | 4 S, 5 R (erste Spinne: Skelett, Gang) |
| giant_centipede | Riesen-Hundertfüßer | `:155` | VerminArt | Wald am Tag | Insekt | – | 3 S, 4 R (erstes Insekt) |
| stirge | Stirge | `:150` | VerminArt | Wald | Insekt | – | 2,5 S, 3 R (Flügel) |
| giant_bat | Riesenfledermaus | `:170` | VerminArt | Wald nachts, Höhle | Vogel | – | 3 S, 4 R (erstes Vogelskelett, auch für Toms Vögel) |
| ochre_jelly | Ockergallerte | `:180` | VerminArt | Höhle, selten | keins | – | 1,5 S, 2 R |

Je Monster in den S: Bewegungen nach Modellregel 5 (Biss oder Hieb, Treffer, Sturz, Tod), Kontaktblatt, Einbau in den Kampfort.

**Kleintiere** (nur Bild, keine Regeln): Frosch und Libelle an den Teichen (`art/PondLife.kt:75`, `:29`), Schmetterling auf Blumen (`ui/WorldScreen.kt:1675`, auch im Dorf), Glühwürmchen nachts (`WorldScreen.kt:1896`, Kampfort `art/BattleScene.kt:549`); Eule, Grille nur Ton (`audio/WildSound.kt:36`). Vögel: Tom (Dorftiere), im Wald gleiches Modell. Schätzung: 2 S, 2 R (Glühwürmchen als Teilchen, ohne Skelett).

**Höhle** `cave` (Blutzahnhöhle, `Story.kt:731`, 22×20, eine Ebene; Bild `art/MapCaveIso.kt`, Boden `art/MapCave.kt:848`, Licht `MapLight.kt`): Eingang/Ausgang, Fels, Boden (`core/World.kt:22-25`); Wandfackel 2, Kristalle 2, Leuchtpilze 5, Stalagmit 3, Geröll 3, Felsblock 1, Knochen 4, Kisten 2, Schlafstätte 2, Lagerfeuer 1, Stützbalken 3 Paare, Lichtspalt 1, Gitter vor Graks Halle (öffnet `rusty_key`, `Game.kt:1093`), Truhen `cave_1`–`cave_3` (`Story.kt:762`), Wasser 5 (Kachelzeichen `World.kt:9-78`). Kampforte der Höhle `art/CaveScene.kt:24` (Eingang, Gang, Halle, Teich, Lager; Licht Fackel, Glimmen, Schacht, dunkel). Ketten gibt es im Spiel nicht (nur ungenutzt `MapCave.kt:593`; 356.1 braucht sie). Schätzung: Grundriss mit Licht 5 S, 5 R (Grundriss-Technik von Tom, Gasthaus zuerst), Höhlendinge mit Varianten 3 S, 2 R, Kampforte der Höhle 3 S, 3 R; zusammen 11 S, 10 R.

**Ausrüstung** (Regeln `core/Gear.kt:269-336`, Einzelstücke `:369-389`; Bild am Körper `art/Dress.kt`, Symbol `art/ItemArt.kt`; Laden Thessa `Loot.shopGear`; Beute ab Mindeststufe; als eigene `.glb`, Modellregel 4):
- **Waffen** (`:305-326`): dagger, shortsword, scimitar, handaxe, mace, spear, quarterstaff, rapier, longsword, battleaxe, morningstar, warhammer, wand, greatsword, greataxe, maul, halberd, staff, shortbow, longbow, light_crossbow. Startwaffen: Kämpfer longsword, Schurke shortsword, Magier und Kleriker quarterstaff. Von Gegnern getragen (`MonsterKit.kt`): dagger, shortsword, scimitar, handaxe, spear, morningstar (Krogg), greataxe (Grak), staff, shortbow. Modell: `waffen.py`, Entwurf (an den Goblins gezeigt). Schätzung: 4 S, 3 R (Blätter zu je etwa 7 Waffen; Symbole als Bilder aus dem alten Zeichner).
- **Einzelstücke** (`:373-387`): longsword_oakford, staff_of_embers, rapier_whisper, mace_of_dawn (Truhe `cave_3` je Klasse), greataxe_grak (Grak), gauntlets_ogre (Krogg), cloak_protection (Spinne, 3 %); Schmuck amulet_grimfang, ring_protection u. a. nur als Symbol. Schätzung: 1,5 S, 1 R.
- **Schilde** (`:328-330`): shield (Start Kämpfer), round_shield (Start Kleriker; Goblin, Kobold, Skelett), tower_shield (ab 5). Schätzung: 0,5 S, 1 R.
- **Nebenhand** (`:332-335`): torch (Laden), orb, tome, holy_symbol. Schätzung: 1 S, 1 R (Fackel zuerst, für Toms Held).
- **Rüstung** (`:271-299`): Kopf hood, circlet, leather_cap, helmet, great_helm; Körper robe, leather, studded_leather, chain_shirt, scale_mail, breastplate, half_plate, chain_mail, splint (plate ab 7: nicht in Kapitel 1); Arme wraps, gloves, bracers, gauntlets; Beine leggings, boots, chain_leggings, greaves; Rücken cloak, mantle. Schätzung: 6 S, 4 R (24 Teile am Körper des CC0-Helden, vier Völker; braucht Toms Held mit Kleidung als Schalter).

### Funktionen (Perikles 25.10., 348.9; Quelle nach Dateinamen, Teams berichtigen Quelle und Wer)

Was das alte Spiel kann, ohne eigenes Modell. Regeln mit denselben Testfällen wie `core` (Grundsätze).

| Funktion | Quelle alt | Wer | Modell | Schätzung |
|---|---|---|---|---|
| Gehen, Tippen, Joystick, Kollision, Kartenwechsel, Boden bremst | `core/FreeWalk.kt`, `Navigation.kt`, `Terrain.kt` | Tom | Entwurf (348.6) | 2 S, 1 R (Wechsel über alle Karten, Tests) |
| Uhr, Tag und Nacht, Sonne, Wetter | `core/PlayClock.kt`, `Light.kt`, `Weather.kt` | Tom | Entwurf (3486-sonne) | 2 S, 3 R (Eichung je Tageszeit) |
| Tagesablauf und Stammplätze der Leute, Hinweiszeichen | `core/VillageDay.kt`, `MapPeople.kt`, `Hail.kt` | Tom | – | 2 S, 1 R |
| Gespräche, Story, Quests, Chronik | `core/Story.kt`, `Script.kt`, `Chronicle.kt`; `ui/Dialogs.kt`, `ChronicleTab.kt` | Tom | – | 5 S, 2 R |
| Laden | `ui/ShopScreen.kt`, `core/Loot.kt` | Tom | – | 2 S, 2 R |
| Anschlagbrett (Aufträge) | `ui/BoardScreen.kt`, `core/Jobs.kt` | Tom | – | 1 S, 1 R |
| Rast | `ui/RestScreen.kt`, `core/Resting.kt` | Tom | – | 1 S, 1 R |
| Menü: Held, Tasche, Ausrüstung mit Vergleich, Karte mit Nebel, System | `ui/MenuScreen.kt`, `MenuTabs.kt`, `GearUi.kt`; `core/GearCompare.kt`, `Fog.kt`, `MapMarks.kt` | Tom | – | 5 S, 3 R |
| Charaktererstellung, vier Klassen | `ui/CreateScreen.kt`, `core/Hero.kt` | Tom | – | 3 S, 3 R (Puppe drehen, 357) |
| Vorspann, Hauptmenü, Spielstände | `core/Prelude.kt`, `GameState.kt`; `ui/App.kt`, `SlotsScreen.kt` | Tom | – | 3 S, 2 R |
| Intro, Zwischenbilder, Outro | `core/Intro.kt`, `Interlude.kt`; `ui/IntroScreen.kt`, `InterludeUi.kt` | Tom | – | 2 S, 1 R (Bilder aus dem alten Zeichner; neu in 3D +6 S, +5 R) |
| Hilfe im Systemmenü | `core/Guide.kt`, `ui/GuideScreen.kt` | Tom | – | 1 S, 1 R |
| Deutsch und Englisch | `core/I18n.kt` | Tom | – | 2 S, 0 R |
| Klassischer Kampf | `core/Battle.kt`, `ui/BattleScreen.kt` | Jerry | – | 6 S, 3 R (Regeln mit Goldtests, Ansicht im Kampfort; Schalter 212) |
| MARS | `core/Skirmish.kt`; `ui/SkirmishScreen.kt`, `MarsRules.kt`, `MarsTips.kt` | Jerry | Entwurf (348.7) | 8 S, 6 R (Wolfsrudel am Handy, Rest 296.2 mit Toms Held und Tasche, Zustandszeichen nach Ja; Kampforte Wald und Tiefer Wald, Tag und Nacht) |
| Regeln: Würfel, Zustände, Stufen, Talente, Ausdauer | `core/Rules.kt`, `Dice.kt`, `Status.kt`, `Perks.kt`, `Stamina.kt` | Jerry | – | 3 S, 0 R (Würfel, Zustände, Stufen in `godot/regeln/` angefangen) |
| Gegner auf der Karte, Rudel, Beute | `core/Roamers.kt`, `Packs.kt`, `MonsterKit.kt`, `Loot.kt` | Jerry | – | 4 S, 1 R (auf Toms Karten: Streifen, Bemerken, Übergang in den Kampf) |
| Musik, Klang, Klangeinstellungen | `app/…/audio/MusicPlayer.kt`, `SfxPlayer.kt`; `core/audio/WildSound.kt`; `ui/SoundSettings.kt` | Jerry | – | 6 S, 0 R (Musik mit Übergängen, Orts- und Kampfklang, Synthese aus `core/audio`; Hörprobe am Handy statt Bild) |
| Tränke brauen bei Morwen | `core/Recipes.kt` | Tom | – | 0,5 S, 1 R |
| Truhen, Türen, Gitter, Schlüssel | `core/Game.kt` | Tom, Jerry | – | Tom 1 S, 1 R; Gitter Jerry 0,5 S, 0 R (Bild mit der Höhle) |
| Kampfeffekte: Blut, Todesbild, Trefferhalt | `ui/BattleFx.kt`, `BattleBlood.kt`, `BattleKill.kt`; `core/HitWeight.kt` | Jerry | – | 4 S, 3 R |
| Ausgleich bei Pechsträhnen | `core/MissStreak.kt` | Jerry | – | 0,5 S, 0 R |
| Spuren (Blut, Fußspuren) | `core/Tracks.kt` | Jerry | – | 1,5 S, 1 R |
