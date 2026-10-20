# Änderungshistorie

Alle Änderungen an „Chroniken von Bornim“, neueste zuerst. Jede Version ist als [Release](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases) mit fertiger APK verfügbar. Zeiten in Berliner Zeit.

## Unveröffentlicht

- **242.2, 241.1, 242.3, 240.1, 248, 245 (PR #132, Build 44 „freigegeben“, 20.10.):** MARS: weicher Schatten kräftiger; Automatik spielt nur den Helden, Söldner auf „selbst“ wartet; einzelner Gegner vorn rückt an die Helden, wenn einer hinter ihm steht; bei der Zielwahl Namen nur an wählbaren Figuren; Held geht mit Schulterschwung, eigene Rennbilder, weiche Drehung auch der Leute, Schritte nach den Füßen; Kleintiere außerhalb des Sichtkreises im Nebel (Rückläufer: 2, 245.1 Rennen wie Moonwalk, 241.2 Automatik des Helden nicht ausschaltbar).
- Ablauf: Tagesbericht von Perikles täglich ab 7:30 (Sa, So 9:30) durch Fords Lauf (`lauf.py` `TAGESBERICHT`), Morgenmeldung nur noch eine Zeile (247.1).
- **240, 241, 242, 242.1, 231, 237 (PR #131, Build 43 „freigegeben“, 20.10.):** MARS: Zugkreis flach am Boden unter der Figur, Zieldreieck am Boden, weicher Kontaktschatten, Ring der Tiere um alle Pfoten; Nummer gehört der Figur („Wolf 1“ in Bericht, Zugleiste, Knöpfen); Automatik spielt Zug für Zug und lässt sich anhalten; Schonfrist bis zur ersten Wahl, Einkreisen nie zum Auftakt; Klang hält an, wenn die App nicht vorn ist (Rückläufer: 4, 240.1 Namen, 241.1 Automatik nimmt Söldner mit, 242.2 Schatten nicht zu sehen, 242.3 Gegner eng hintereinander, alle in Build 44; 249 Positionswechsel abgehackt, an Sokrates).
- **244 (Werkzeug, 20.10., Push ohne Gerätetest auf Wort des Chefs):** `tools/meldung.sh` nimmt `--bild`, `--datei`, `--laut`, `--probe` an jeder Stelle; unbekannte Option oder überzählige Angaben brechen ab, nichts geht raus (vorher wurde `--bild` hinter dem Text still übergangen und nur der Text gesendet).
- **211.17, 211.15, 211.16, 232, 233, 230 (PR #130, Build 42 „freigegeben“, 20.10.):** Biss von Wolf, Wildschwein und Ratte trifft den Helden im Bild; MARS ohne goldene Zeile, Namen nur bei Zielwahl und nach langem Druck, Absicht kurz in der Farbe des Ziels; lange Heldennamen in eigener Zeile; Testkampf nennt die laufende Bewegung; MARS-Zeichen ortsneutral (Rückläufer: 1, 42.5 Wölfe an den Zielknöpfen nicht zuzuordnen, als 240 im nächsten Build).
- **211.13 (PR #129, Build 41 „freigegeben“, 20.10.):** Kampfbild aus einer Kamera (25°, Achse −30°) für MARS und klassischen Kampf in Wald und Höhle: eine Bodenebene, Figuren nach Abstand groß und aus ihrem Winkel, Rückwand hinter den Gegnern; Wald mit 6 Kampforten, Höhle mit 5 (Rückläufer: 2, 211.17 Biss der Vierbeiner neben dem Helden, 231 Bertram fällt vor dem ersten Zug).
- **219.4, 223, 225, 219T.1, 229, 211 (PR #128, Build 40 „freigegeben“, 20.10.):** MARS: perfekter Ring zählt immer, eine Zeile mit der Antwort der Klasse; Nahkampf aus der hinteren Reihe an einem Freund vorbei mit Nachteil (Speer, Hellebarde ausgenommen), Hinweis, langer Druck und Regelseite; Knopf „Wechsel“ statt „Platz“, Erklärtexte nach Homer; Ringtexte (großer Ring auf dem kleinen); Raster der Plätze über das Gittersymbol rechts unten; Namen über den Figuren, Lebensbalken nur über Gegnern, Held und Söldner auf gleicher Höhe (Rückläufer: 0).
- **215 (PR #127, Build 39 „freigegeben“, 20.10.):** Haustür (Dorf und innen) ist Wand, der Held bleibt davor; Eintreten und Klopfen an verschlossenen Häusern nur über die Aktionstaste (Rückläufer: 1).
- **218, 227, 220, 215, 221, 214, 224, 68 (PR #126, Build 38 „freigegeben“, 19.10.):** Testreiter nach Zweck gegliedert, eigene Überschrift „Monster/Kampf beschwören“; Absturzbericht mit „Kopieren“ oben, gleiche Stapelzeilen zusammengefasst; Rennen 2,0-fach statt 2,6-fach; Übergänge über die Aktionstaste mit Ziel als Schrift; Wasser mit Glanz in der Strömung, Regenringen, Lichtstreif nachts; Ausrüstung: Tippen auf einen Platz zeigt passende Teile aus dem Beutel; Holzstapel aus Scheiten mit Hackklotz, Regal ohne Bruch; Tempelszene nach der abgenommenen Bildserie (Rückläufer: 1, 215 Haustür und Klopfen, fährt im nächsten Build).
- Regel „Aussehen erst als Bild, Build erst nach passt“ in `ROLLE-ENTWICKLUNG.md` (228).

- **213, 198, 84.1T.1, 216, 27, D29.3 (PR #124 mit #121, Build 35 „abgenommen und freigegeben“, 19.10.):** Testknopf „Alle Vorräte“ legt zwei Fackeln dazu; nach gelungener Flucht 12 s Ruhe vor denselben Gegnern; „Dein Funke ist verglommen.“ auch nach einem Morgen in einer Szene; Aktionstaste greift nach Nähe (Blickrichtung zuerst, Leute vor Dingen), näher an Leute heran; nachts kühles Mondlicht statt Heldenlaterne; Kleinleben und Schatten in Wald und Dorf, Dorfhund (Rückläufer: 0). Tempelszene (68) neu gezeichnet, Bilder 1–3 noch nicht abgenommen (35.9–35.11).
- **222.1 (Abläufe, 19.10.):** `.claude/settings.json`: Berliner Zeit und Autorenzeile fest, Force-Push und Rebase gesperrt, Hinweis an die Sicherheitsprüfung zu unserem Ablauf.
- **72.10a.9, 72.10a.11, 201, 134.3, 140, 27o, 59e.1, D32.1 (PR #123, Build 34 „freigegeben“, 19.10.):** MARS: Rolle und Reaktion je Klasse (Decken, Finte von hinten, Gebet) und Zweitwaffe unter „Platz“ ohne Zugverlust; Regelseite ergänzt; kurzer Ruf ohne Worte bei Leuten mit Neuem; Elite-Gegner mit tieferer Stimme; Höhlenschacht nachts im Mondlicht; bei jedem Warenwechsel ein Stück für die Klasse; „Mercenaries knocked out“ (Rückläufer: 0).
- **222 (Abläufe, 19.10.):** `.claude/settings.json` erlaubt lesende git-Befehle (`fetch`, `diff`, `merge-tree`) fest; die Sicherheitsprüfung sperrt Teams dort nicht mehr.
- **199, 200, 201, 172 (c) (PR #122, Build 33 „passt“, 19.10.):** Kampfknopf „Angriff“; Gefolge des Bosses greift in Hintergrundgröße an und schrumpft zurück; MARS-Probekampf im Systemmenü mit scrollbarer Regelseite (schwarz-gold, 201a); ein Tipp überspringt eine laufende Kampfmeldung.
- **197.1 (19.10.):** `lauf.py` archiviert ruhige Sokrates-Sitzungen, sobald ein Nachfolger läuft (nur eine offene Frage hält sie) und bucht auf die „Kosten auf“-Nummern aus der Übergabe der Sitzung selbst (Stand aus Git); Sitzung 18.10., 22:31 (9,14 $) von Hand auf 189, 190, 167.6, 191 gebucht.
- **172 (PR #120, Build 31 „freigegeben“, 19.10.):** Kampf schneller: „Angreifen“, „Abwehr“ und „Flucht“ stehen gleich im ersten Menü, ein Tipp bis zum Schlag; bei Überraschung sind Abwehr und Flucht sofort da (Rückläufer: 0).
- **72.10a.8 (PR #120, Build 31 „freigegeben“, 19.10.):** MARS: Gegner richten ihre Absichten gegen die Aufstellung (Grak „Durchbrechen“ stößt die vordere Figur nach hinten, Goblin „Flanke“ trifft hinten ohne Deckung); ein Platztausch kostet nur einen halben Zug (Rückläufer: 0).
- **202 (Werkzeug, 19.10.):** `startbar.py` zeigt die Übernahme (118): hat Tom oder Jerry nichts Startbares, nennt es den obersten freien Vorgang des anderen Teams.
- **206 (Abläufe, 19.10.):** Startaufträge, Haken, Besetzungstabelle und `CLAUDE.md` sagen „Vorgang“ statt „Zeile“ (Chef: „Es ist ein Vorgang, oder?“).
- **190 (Werkzeug, 19.10.):** `startbar.py` und `lauf.py` nach Vorgangsarchiv 190: „gebaut“ wartet auf Test/Build, Zeilen, auf die ein anderer Vorrat mit einer Muss-Zeile wartet, zählen als Muss, `--ohne NR:Grund` für Fords Ausschluss, „wartet auf Chef“ und Chefsache-Dateien halten nur die Sitzung der Zeile, der „Nachfolger:“ der Übergabe wird im nächsten Lauf gestartet (sonst WARNUNG, zweites Mal laut). Übernahme zwischen den Teams auch bei ruhender Niederlassung; Wochenziel-Ausschlüsse (72u.1, 72.10a.*T) auf „nach dem Meilenstein“.
- **187 (Werkzeug, 18.10.):** `tools/lauf.py` gibt in jeder START-Zeile die `source_url` des Repos mit aus, damit gestartete Sitzungen nie ohne Repo laufen.

## v0.1.867 – 18.10.2026, 20:01

- **180 (PR #119, Build 30 „freigegeben“, 18.10.):** Die einfache Fackel bleibt bei Thessa immer im Angebot, auch wenn schon eine getragen wird oder ein alter Spielstand sie als verkauft führt (Rückläufer: 2).
- **183 (PR #118, Build 29 „freigegeben“, 18.10.):** Ist der einzige Gegner in den Schatten verschwunden (Späher), sind Zauber und Können grau und das Kampffeld sagt „Kein Ziel in Sicht“; vorher passierte beim Tippen nichts (Rückläufer: 0).
- **181, 182 (PR #117, Build 28 „freigegeben“, 18.10.):** Ein betrunkener Held kann nicht rennen; MARS-Plätze heißen nur „vorn“ und „hinten“, die Platzwahl nennt, wer dort steht (Rückläufer: 0).
- **176a, 175 (PR #116, Build 27 „freigegeben“ bis auf die Fackel im Laden, 18.10.):** Der Fels am Höhleneingang wirft draußen keinen Schattenkeil mehr vom Licht von Fackel und Funke; nach der Blende zeichnen Held und Leute leise im Hintergrund, kein Ruckeln beim Spielstart, Testreiter zeigt die längste Bildpause; 180 (zweite Fackel) zurückgenommen, neu im nächsten Build (Rückläufer: 1).
- **154, 155, 174, 20.4 (PR #106, Build 26 „alles läuft“, 18.10.):** Eine verlorene Schlacht kostet kein Gold mehr, der Heimweg dauert 4 Stunden; das Feuer der Goblins bleibt in der Höhle, Rast dort verweigert; Aufstellungsplätze „vorn/hinten oben/unten“ (zu 182 noch unverständlich); Status heißt „Betrunken“. (Rückläufer: 0)
- **173, 176, 84.1T (PR #115, Build 25 „freigegeben“ bis auf den Schatten vor der Höhle, 18.10.):** Nach dem Hinweis „zu viel geschlafen“ verkauft Rowena keinen Met mehr; Fackel und Leuchtfunke leuchten so weit, wie der Held sieht (Fackel etwa 6 Felder, Funke etwa 5, schwächer), Schein wie die Wandfackeln; Texte von Homer zu Fackel und Funke; Schatten vor der Höhle offen in 176a (Rückläufer: 1).
- **130.2a, 130.3 (PR #112, Build 22 „alles passt“, 18.10.):** MARS-Protokoll scrollbar, Takt der Gegnerzüge langsamer; Wolf, Spinne und Späher mit eigenen Absichten, Auswahl „Gegner wechseln“ im Testreiter. (Rückläufer: 0)
- **84.1, 84.5 (PR #114, Build 24 „freigegeben“ bis auf das Licht, 18.10.):** Fackel im Laden (Nebenhand, statt Schild), Leuchtfunke als Fläschchen (schwebt über dem Kopf bis zur Rast, Taste „Funke löschen“ in der Tasche), Sicht im Dunkeln weiter, jagende Monster bemerken den Funken früher; Helligkeit offen in 176 (Rückläufer: 0).
- **139, 114, 86 (PR #111, Build 21 „alles läuft“, 18.10.):** Rowena kauft rohes Fleisch an der Theke; nach einem Zimmer wacht der Held am Bett auf; Rast-, Met- und Zimmertexte von Homer, Rowena sagt beim Öffnen der Theke einen Satz (Rückläufer: 0).
- **134.2, 170, 171 (PR #113, Build 23 „freigegeben“, 18.10.):** Gesten zum goldenen Zeichen (Hand heben, herwinken, nicken, Merkmal je Person); Stein an Garricks Lagerfeuer weiter weg, nicht mehr im Rücken nach Rast und Niederlage; Gold als eigene Zeile in der Tasche mit Münzstapel (Rückläufer: 0).
- **72.10a.T, 72.10a.7, 86.9 (PR #110, Build 20 „freigegeben“, 18.10.):** MARS-Texte wortgetreu (Zauber/Fähigkeit, „pro Kampf“/„pro Rast“, „kritisch“, Abzug „12 − 1“); Deckung und Nachteil nach Reihen, Goblin-Schütze beim zweiten Ruf Graks; Zustand „Betrunken“ mit Zeichen und Kampfzeile außer Atem (Rückläufer: 0).
- **72.10a, 130.1, 130.2 (PR #109, Build 19 „passt“, 18.10.):** MARS-Probe: Können (Fähigkeiten, Zauber, Ziele nach Reihen), Tasche mit Tränken, Zugleiste und goldener Ring am Zug, leuchtende Ziele, Wurfzahlen am Ziel (abschaltbar), Söldner-Namen, Held und Söldner fest auf Stufe 3; Name „MARS“ statt „Probe“ (Rückläufer: 0).
- **152, 138 (PR #108, Build 18 freigegeben, 17.10.):** Leute sperren einen runden Fleck um die Füße, der Held gleitet daran entlang; Garrick mitten auf seinem Feld, Abstand aus allen Richtungen gleich; Bram sperrt beim Umhergehen nicht mehr das ganze Feld; Kräuter wachsen bei Sonnenaufgang nach statt um Mitternacht.
- **131.1, 151, 152, 153 (PR #105, Build 17 „passt“, 17.10.):** Joystick kleiner (Normal 1,5 cm), Gehen etwas schneller, Rennen etwas langsamer, weicher Wechsel; unsichtbarer Busch unter Pims Haus weg; Leute sperren nur noch um die Füße, Garrick näher am Feuer (Abstand von Westen noch zu groß, 152 offen); Überspringen-Kasten schwarz-golden.

## v0.1.827 – 17.10.2026, 16:18

- **Zusammengeführt ohne Test-Build, Test im Release** (PR #104 mit #103, 17.10.; Chef: „das teste ich dann in einem Release gleich“): der Held geht gemächlich, etwa halb so schnell wie bisher, Zwerge und Halblinge etwas langsamer, schwere Rüstung ohne Kraft bremst, Geschick hilft; Rennen ist kurz (etwa 6 s bei Konstitution 10, länger mit Konstitution und Stufe); Joystick: im Kreis gehen, über den Ring hinaus rennen, Ring golden mit kurzem Rütteln; Taste „Rennen“ wahlweise im Menü (131); Garrick nennt Krogg, den Ostflügel und Morwen schon im ersten Gespräch (D23.2).
- **Zusammengeführt nach Test 0.1.821** (PR #102, 17.10., 14:1x; Chef: „0.1.821 passt. Sehr gut.“): Spielstände zeigen die gespielte Zeit („Gespielt: 2 Std. 14 Min.“), vier statt drei Plätze, das Fenster „Alle Plätze belegt“ rollt (132); Leute mit Neuem zeigen beim Herankommen kurz ein goldenes „!“ (134.1); Verweise in Code-Kommentaren auf umbenannte Notizen (117) (Rückläufer: 0).
- **Zusammengeführt nach Test 0.1.812/0.1.813/0.1.815/0.1.816** (PR #68, #98, #99, #100 über #101, 17.10., 01:1x): Probe im Testmenü: Held und Söldner gegen Grak mit Absichten, goldenem Ring zum Abwehren, zwei Reihen, Platztausch und Automatik (72.10, 72.11, 72.13); rennend bemerken Monster den Helden früher, außer Atem würfelt er die Initiative mit Nachteil (86); der Leitwolf heult im Kampf aus echten Aufnahmen (D3); Hühner stehen nie zu zweit auf einem Platz, auch beim Weglaufen und unter den Bäumen (129).
- **Zusammengeführt nach Test 0.1.798/0.1.800/0.1.802** (PR #93, #94, #95 über #97, 16.10., 21:4x): Höhle ohne Hörner im Klangbett (D1.14); „Alle Vorräte auffüllen“ legt ein Rauchbündel dazu (D4.1); Regen hörbar, ferner Donner aus echten Aufnahmen, im Kampf still (D3.10); ferne Wölfe aus drei Aufnahmen (D3.8); Monster auf der Karte geben in Ruhe Laute von sich (D3.9); Regen und Monster-Laute ohne Raumklang
- **Zusammengeführt nach Test 0.1.806** (PR #96, 16.10., 21:1x): wer beim freien Laufen dauerhaft gegen Dorfleute läuft, bringt sie nach dem zweiten Anstoß dazu, zur Seite zu treten; Wachen auf ihrer Runde weichen nicht (92; Rückläufer: 1).
- **Zusammengeführt nach Test 0.1.797** (PR #87, 16.10., 20:5x): nähert sich ein Jäger, wird die Musik leiser und dumpfer und eine dunkle Spur schleicht sich ein; bemerkt er den Helden, ist es still bis zur Kampfmusik (120).
- **Zusammengeführt nach Test 0.1.779/0.1.780/0.1.782** (PR #90, #91, #85, 16.10., 20:0x–20:2x): Rauchbündel nimmt Kroggs ersten Hieb (D4.1); Sterbehaltung liegt am Boden (51); Krogg zerfällt in feine Stücke (36.6); Zustände sitzen auf dem Umriss des Gegners (53); betrunken = Nachteil wie Vergiftet (86.9); Raumklang in Höhle, Tempelhalle, Schänke und Kammer (119); Stimmen der zwölf übrigen Gegner (18.11).
- **Zusammengeführt nach Test 0.1.781/0.1.791** (PR #92, 16.10., 17:5x): „!“, Elite-Glühen und Glitzern sitzen am Tier, Regenspritzer schräg wie die Karte (D3.5); Schatten unter Rudelwölfen und Wachen (D3.6); „bemerkt“-Laut nach Entfernung (D3.9); Schänkenherd an der Tür leise hörbar (D3.12).
- **Zusammengeführt nach Test 0.1.778** (PR #89, 16.10., 15:5x): leiser Klang unter Intro-Bild 1–4, im Schwarzbild dumpfe Glocke, Rufe und ein ferner Schrei (69c, 69c.1); drei Lautstärkeregler Gesamt, Musik, Effekte und „Dunkle Töne“ im System-Reiter (40, 13e.6); kein Absturz beim schnellen Beenden (30).
- **Zusammengeführt nach Test 0.1.777** (PR #88, 16.10., 15:0x): leer gerannt keucht der Held hörbar (95); Tiefer Wald ohne Vogelgesang, nachts fernes Wolfsgeheul, in der Höhle fernes Grollen, Vögel flattern und scharren hörbar (84, D3.2); Türklang nur auf Türen, Feuer und Ortsklang reißen nicht mehr ab (D3.1, D3.4); der Fluss rauscht, auf der Brücke am lautesten (D6.4).
- **Zusammengeführt nach Test 0.1.757** (PR #71, 16.10., 11:5x): Tippen in Intro und Tempelszene fragt „Überspringen?“ (104); Rast am Lagerfeuer kostet Zeit, Met und Zimmer bei Rowena, Ausdauertrank (86.6, 86.9, 86.10); Held und Leute im Hausschatten dunkel (89); Titelmusik leise unter dem Intro (69f); Funken, Sporen, Tropfen und Rauch senkrecht (D1.7, 27n); Taschentext des Rauchbündels (38); junge Fichten im Tiefen Wald in drei Höhen (D3.3).
- **Zusammengeführt nach Test 0.1.753** (PR #67, 16.10., 07:5x): Hühner flackern nicht mehr und landen nicht auf dem Fluss (94, D7.1); Morwens Hütte auf eigener Lichtung, Dächer nachts weich im Licht vor dem Haus (D3.13a); Testknopf „Kapitel 1 bis kurz vor Ende“ (100); Tempelszene zum Ende von Kapitel 1 (68); Bild 3 der Zwischensequenzen (70.6); Gesprächstext passt ins Feld (96); Beete bis zum Zaun (93); Nähte an Häusern, Schattenschicht, Morgenstand (D9.1–D9.3).
- **Zusammengeführt nach Test 0.1.750** (PR #65, 15.10., 16:5x): Schatten nach dem Sonnenstand, Held und Leute werfen Sonnenschatten (89); Schritte im System-Reiter abschaltbar (91); Atem und Laufen (86.1–86.4); Kartenausschnitt Normal/Näher (6l); Dorf nach Diogenes Lauf 6 (D6.1–D6.7), Wald und Höhle (D1.3, D1.11, D3.3, D3.5, D3.7, D3.11, 13e.6).
- **Zusammengeführt nach Test 0.1.748** (PR #64, 15.10., 16:0x): Intro bei Nacht in fünf Standbildern, im Dorf Laterne und Holzgeländer an der Brücke (69); Hühner am Südrand picken, scharren und flattern weg, mit Glucksen, Gackern, Flügelschlag und Scharren (83b/83c); Truhe in der Höhle mit Schatten (D1.5); Schritte des Helden je Untergrund (74).
- **Zusammengeführt nach Test 0.1.746** (PR #63, 15.10., 11:1x): Dorf Süd mit Hecke aus Büschen und jungen Fichten vor Beeten, Weizenfeld und Heuballen (83); Testmenü ohne Wetterleuchten und „Garrick döst“ (85); Katze in der Schänke läuft um den Tisch vor dem Tresen, ohne Flackern (87.1); Rowena und Thessa stehen dicht am Tresen (87.2); Borin trinkt aus einem Zinnkrug (87.3).
- **Zusammengeführt nach Test 0.1.741** (PR #62, 14.10., 21:2x): Feuer in der Höhle klingt nur auf dem freien Weg, nicht durch Wände (D1.9); keine alten versetzten Bodenschatten unter Truhe, Kisten, Feuer, Knochen (D1.5); Fels geht hinter dem Kartenrand weiter, der Gang am Ausgang läuft heller werdend hinaus (D1.6, 13e.5); kein Heldenlicht in der Höhle (13e.6 B; Helligkeit beim Berater).
- **Zusammengeführt nach Test 0.1.740** (PR #61, 14.10., 20:5x): Held bleibt vor verschlossener Tür stehen statt hinter der Hauswand zu verschwinden (82); Jungwolf springt zum Helden und beißt ihn (52); Kaels Laterne auf Steinsockel, nachts schwaches Bernsteinlicht (80a); Figurenschatten 2:1 (D1.5); Rowenas und Borins Klänge kommen mit ihrer Bewegung (D1.10; Ort und Becher folgen mit 87); Fenster und Türschwellen in drei Formen je Haus (D1.11).
- **Zusammengeführt nach Test 0.1.739** (PR #60, 14.10., 20:5x): Marktstand fest, nur das Tuchdach wird durchsichtig, Fahrspuren weich, Hausschatten ohne gerade Kante (5.5); Wald schließt sich hinter dem Weg Süd, kleine Tiere und Glühwürmchen verschwinden hinter Bäumen und Häusern, erste Reihen hinter dem Rand behalten ihr Licht, Weg nach Osten frei, Waldrand West und Nord, Tiefer Wald (27m.1–27m.5).
- **Zusammengeführt nach Test 0.1.729** (PR #59, enthält #58/0.1.728, 14.10., 13:0x): Wald geht über den Kartenrand hinaus weiter und läuft ins Dunkel aus, Ausgänge, Wege und Wasser frei (27m); Bildrate im Test-Reiter (gemessen 100–120 B/s, höchstens 10–12 ms); Kaels angesengte Laterne neben seiner Tür (80); Menhire und Schilder im Licht ihres Fußes, Pfützen weich und erdig, keine Nähte im Boden (27l, 27); Leiste über der Karte schwarz mit Goldlinie (77.1).
- **Zusammengeführt nach Test 0.1.721** (PR #57, 14.10., 07:1x): Wandkram in Räumen mit Schatten auf der Wand und hellen/dunklen Kanten, nichts mehr hinter Möbeln (D1.4); keine eckig dunklen Felder unter Möbeln, kein Umriss um Bodenschatten (D1.5); Entwurfsschalter entfernt, die fest an waren (D1.16); Builds nur noch für PR, `main` und auf Knopfdruck (78d).
- **Zusammengeführt nach Test 0.1.719** (PR #56, 13.10., 22:4x): Garrick dicht am Feuer (3b, Rückläufer: 1); Glühwürmchen ruhiger, Leuchten schwillt an und ab, Schwärme 1–9 (4, Rückläufer: 1); Pim, Gwenna, Liska nachts im Haus (5la); Stimmen hinter verschlossenen Türen (73b); Diogenes-Befunde: Kapitelende und Anschlagbrett schwarz-golden, Englisch im Vergleich, Farben, „…“ beim Abschneiden u. a. (D2), Licht nur aus Quellen in Räumen (D1.2/D1.3), Bänke und Ladenkram in drei Formen (D1.11).
- Notizen umgebaut (76–78, Nutzer 13.10., 21:52): Dateien unter `docs/` mit Vorsilben ROLLE-/DESIGN-/STORY-/LISTE-/ARBEIT-; `CLAUDE.md` auf den gemeinsamen Kern gekürzt (16,6 → etwa 9 KB); neu `docs/ROLLE-ENTWICKLER.md` (Wer du bist, Prüftreppe, Sammelbuilds); Berater-Prompt „Wer du bist“; Wächter gegen alte Namen in `tools/notiz.sh`.

- **Zusammengeführt nach Test 0.1.714** (PR #55, 13.10., 21:1x): nachts Läden zu mit Ritzenlicht (73a), Knopf der Karte nennt das Ziel (62r), Tempelboden aus Steinplatten (13), Garrick links vom Feuer (3b, Abstand folgt).
- **Zusammengeführt nach Test 0.1.709** (PR #54, 13.10.): alte gerade Ansicht ausgebaut, alle Orte diagonal (13t); Tippen auf ein Haus der Gebietskarte öffnet seinen Grundriss, Leute im Grundriss an ihrem Platz (62s/62h); Kaminrauch sichtbar, je Kamin eigener Takt (73); Wegweiser „Rabenschanze“/„Schilfrode“ (67a); keine Fußspuren auf trockenem Boden (61b).
- **Zusammengeführt nach Test 0.1.702** (PR #53, 13.10.): Höhle: der Blick bestimmt, was hell wird, auch hinter der Felsstufe am Lagerfeuer (13e); Gebietskarte und Grundrisse im Tuschestil, Schilder an den Häusern, Name beim Antippen (62h/62o/62n).
- **Zusammengeführt nach Test bis 0.1.689** (PR #52, 13.10.): Händler im Stil des Textkastens mit Vergleich beim Kauf, „Alle“ nur beim Verkaufen mit Abfrage (59, 59e); ein Aussehen für alle Oberflächen, Menüreiter als gezeichnete Zeichen (60e–k, 60j); Spuren aus Blut, Fußspuren und Staub (61, 61a); gezeichnete Karte mit Lücken, Bekannten am gewohnten Ort, Diensten und Schaltern (62a, 62c, 62e–g); Chronik mit Aufträgen und „Bisher geschehen“ (64); Laternen am Schlagbaum für Wache Jorin (66); Südrand mit Feldweg, Wegweiser und Umkehr (67); Haare und Köcher schwingen nach (17r); Tagesablauf im Dorf (5la–5la.3); Katze in der Schänke (6g); Farbstimmung je Ort und Tageszeit (6f); Leerlauf mit verschränkten Armen, Jorin stützt sich auf den Speer (55.1a/b); Tempelfenster (13x); Wald und Tiefer Wald fest diagonal (13v/27.6); Höhle: Rand des Blickfelds rund und weich, Felsen weich (13e).
- **Höhle: Licht blendet beim Drehen weich über** (13e, getestet 0.1.681): was aus dem Blick gerät, dunkelt in etwa einer halben Sekunde ab, Lichtstrahl und Fackeln folgen.
- **Höhle in der diagonalen Sicht** (13e, getestet 0.1.667/0.1.671): Felswände, Fackeln mit Flamme, Lichtstrahl durch den Schacht mit weichem Lichtfleck, Geröll und Tropfsteine, Weiher als Wasser, Lagerfeuer mit Steinring, Leuchtpilze, Kristalle und Felsbrocken; Erkundetes nur leicht abgedunkelt. PR #51.

## v0.1.656 – 13.10.2026, 10:13

Zweig von Tom (Thema 58), getestet in 0.1.628 (Nutzer 12.10., 23:1x: alles klappt), PR #50 (zusammengeführt 12.10., 23:13):

**Schild und Köcher auf dem Rücken (58)**
- Ein umgehängter Schild liegt über Umhang und Mantel und drückt den Stoff an den Rücken; darunter fällt der Umhang frei. Der Köcher ebenso.

Zweig von Tom (Thema 27e.1, 27h, 27i, 27j, 17a, 42d), getestet in 0.1.624 und 0.1.625 (Nutzer 12.10., 22:3x: passt), PR #48 (zusammengeführt 12.10., 22:3x):

**Weiher im Wald (27i, 27j)**
- Libellen schwirren tagsüber über dem Wasser; Frösche sitzen am Ufer, springen ins Wasser, wenn der Held nahe kommt, und klettern später wieder heraus.
- Klang aus echten Aufnahmen (CC0): Ein Frosch ruft, wenn seine Kehle schwillt, lauter je näher der Held ist, und schweigt im Wasser; Libellen hört man nur ganz nah und bei Tag; in der Dämmerung ein leiser Chor.

**Held und Ansicht (17a, 27e.1, 27h)**
- Umhang und Mantel schwingen nach dem Anhalten aus und setzen sich ruhig.
- Was vor dem Helden steht, deckt ihn zusammen nur zur Hälfte.
- Test-Reiter: Schalter „Alles diagonal“ (auch Wald, Tiefer Wald, Höhle).

**Textkasten (42d)**
- Gespräche, Erzähltext und Aushänge in einem schwarzen Kasten mit dünnem Goldrand: Sprecher in Gold, Text in gebrochenem Weiß mit Serife, Erzähltext kursiv, ▼ in Gold.
- Werkzeuge (nur Entwicklung): Kerntest `PondSoundTest`, `tools/klang/teich.py`.

Zweig von Tom (Thema 27.4, 27.5, 27e, 5.3, 5.4, 5.6, 5n, 55.2, 56), getestet in 0.1.590 bis 0.1.615 (Nutzer 12.10., 21:1x: Dorf, Schänke, Tiefer Wald passen), PR #49 = getesteter Stand von PR #48 (zusammengeführt 12.10., 21:15):

**Bäume und Dorf (27.4, 5.3, 5.4, 5.6, 5n)**
- Bäume mit Volumen in Wald, Tiefem Wald und Dorf: Blattballen, runder Stamm mit Wurzeln, Fichten in Etagen, Dürrholz.
- Alle zwölf Dorfbewohner sind Puppen mit Ruhebewegungen; Speer und Stab bleiben auf der Schulter.
- Schlagbaum und Zaun diagonal; Kaels Hütte steht zwei Felder weiter östlich, der Schlagbaum ist frei.
- Pflaster auf dem Markt ruhiger (Zwischending), Fensterlicht nachts wird von Bäumen, Häusern und Leuten verdeckt, Kaminrauch als weiche Säule; Gemüsebeet in Furchen, Kornfeld aus Halmen, junge Fichten am Dorfrand.
- Wäscheleine, Heu, Farn und Büsche im Dorf schräg gezeichnet (56d).

**Wald (27.5, 27g, 56a–56c, 27e)**
- Stamm, Felshang mit Höhleneingang, Feuerstelle und Wegweiser diagonal; Heilkräuter, Truhen, Steine, Steinkreis, Büsche, Farn und Schilf schräg (sichtbar, sobald der Wald diagonal ist).
- Der Weiher liegt tiefer, mit Erdstufe am Ufer (nur im Wald).
- Kronen vor dem Helden decken ihn auch in der geraden Sicht zusammen nur zu 35 %; im Tiefen Wald verschwand er sonst ganz (27e; weniger Transparenz folgt mit 27e.1).

**Schänke (55.2)**
- Borin sitzt auf einem Hocker an seinem Tisch: trinkt, isst, sieht sich um, zu zufälligen Zeiten, atmet; der Hammer lehnt am Tischende.
- Durchsicht nur, wenn etwas den Oberkörper verdeckt (der Tresen bleibt fest).

Zweig von Jerry (Thema 36.5, 36h, 36.7, 36j), getestet in 0.1.587 (passt, keine Abstürze), PR #47 (zusammengeführt 12.10., 15:5x):

**Krogg trifft (36.5, 36h, 36.7, 36j)**
- Beim Ausfallschritt trifft Kroggs Waffe jetzt die Brust des Helden. Beim Ausholen geht er 70 % des Schritts.
- Beim Treffer hat Krogg eine eigene Haltung mit gestrecktem Arm, statt dass der Arm gebrochen wirkt.
- Der Rückweg nach dem Schlag läuft weich zu Ende, auch bei schnellem Weitertippen und wenn der Held fällt.

Zweig von Tom (Thema 13.4, 27.1, 27.2, 27d), getestet in 0.1.576, 0.1.579 und 0.1.584, PR #43 (zusammengeführt 12.10., 14:30):

**Diagonale Sicht je Ort (13.4)**
- Dorf und die vier Räume (Schänke, Ältester, Laden, Tempel) sind immer diagonal; Wald, Tiefer Wald und Höhle bleiben gerade, bis sie fertig sind. Die Sicht wechselt hinter der Blende. Die Testschalter „Sicht“ und „Dorf und Räume“ entfallen.

**Wald und Dorf: Wichtiges steht frei, Held verschwindet nicht (27.1, 27.2, 27d)**
- Diagonal stehen vor Leuten, Feuer, Schildern, Eingängen und dem Steinkreis nur junge Fichten statt hoher Kronen; Kisten dürfen weiter versteckt liegen.
- Was vor dem Helden steht, wird zusammen nur auf 35 % durchsichtig, egal wie viel hintereinander steht, und blendet in 0,3 s weich ein und aus.
- Häuser werden nicht mehr durchsichtig, wenn der Held davor dicht an der Wand steht, nur noch, wenn er dahinter ist.

Zweig von Jerry (Thema 36.4), getestet in 0.1.581, PR #46 (zusammengeführt 12.10., 13:51):

**Krogg feiner gezeichnet (36.4)**
- Krogg wird im Kampf mit 1,5-mal so vielen Pixeln gezeichnet, bei gleicher Größe und an gleicher Stelle; seine Augen bleiben deutlich sichtbar.
- Gegnerbilder belegen nur noch den Platz um die Figur: Speicher je Gegner deutlich kleiner (Krogg 44 → 9 MB trotz feinerer Zeichnung, Goblin 31 → 2 MB).
- Werkzeuge (nur Entwicklung): Vorschau `ARTMEM_FOE=bugbear:0` (Speicher je Gegner).

Zweig von Jerry (Thema 37), getestet in 0.1.578, PR #45 (zusammengeführt 12.10., 13:22):

**Kampfmusik aussortiert (37)**
- Raus aus dem Kampf: Great Labyrinth, Menace, Epic Fight Theme. Ancient Legend spielt nicht mehr im Bosskampf, sondern ist für die Rückkehr des Sonnenamuletts vorgesehen.
- Neu: Eclipse Legion, Orchestral Battle Theme (emmama), The Battlefield (umplix) und The March of Devils Dome (setzt gleich kräftig ein). Im Kampf jetzt 7 Stücke, zufällig gewählt; alle CC0, Quellen in `tools/klang/QUELLEN.md`.

Zweig von Jerry (Thema 34, 35), getestet in 0.1.571, PR #41 (zusammengeführt 12.10., 11:52):

**Kampf: Zug beenden (34)**
- Im Kampfmenü steht neben „Zurück“ der Knopf „Zug beenden“: Der Held tut nichts, der Gegner ist sofort dran, ohne Rückfrage.

**Weihwasser nur gegen Untote (35)**
- Weihwasser wirkt wie im SRD nur gegen Untote, mit 2W6 gleißendem Schaden (Hausregel ×1,5 bleibt, also 3–18). Gegen andere Gegner ist es ausgegraut mit dem Hinweis „nur gegen Untote“.
- Werkzeuge (nur Entwicklung): Kerntest `HolyWaterTest`.

Zweig von Tom (Thema 29, 29.3, 29.4, 24.8.6, 30.8), getestet in 0.1.563, 0.1.567 und 0.1.569, PR #42 (zusammengeführt 12.10., 11:35):

**Anschlagbrett mit Nebenaufträgen (29)**
- Vor der Schänke steht ein Anschlagbrett. Antippen zeigt alle Aushänge, jeder lässt sich annehmen; im Menü unter System stehen die angenommenen Aufträge mit Fortschritt und einem Knopf zum Aufgeben.
- Erste Aushänge: Thessa sucht fünf Wolfsfelle (60 Gold), Gwenna den Ring ihres Mannes aus der Goblinhöhle (40 Gold und ein Heiltrank), Borin drei Keilerhauer (50 Gold). Abgegeben wird beim Auftraggeber.
- Nach Krogg kommen neue Aushänge (29.3): Morwen will drei Giftdrüsen (50 Gold, zwei Kräutertränke), Jorin schickt den Helden zum Steinkreis im Flüsterwald (Lohn: ein Kopfschutz aus der Wachstube). Nichts verfällt, nichts kommt doppelt.
- Ein heller Zettel mit rotem Siegel am Brett zeigt ungelesene Aushänge; sonst erinnert nichts daran.
- Bei der Abgabe spricht zuerst der Held, dann der Auftraggeber (29.4).

**Kleinigkeiten (24.8.6, 30.8)**
- An Dorftüren dunkelt das Bild 0,5 statt 0,3 s ab.
- Test-Reiter: Ende der App heißt „App aktualisiert“ statt „anderer Grund (16)“.
- Werkzeuge (nur Entwicklung): Kerntest `JobsTest`, Vorschau `BRETT=1`, `ISODINGE=platz`.

Zweig von Jerry (Thema 26.1), getestet in 0.1.561, PR #39 (zusammengeführt 12.10., 09:51):

**Magierrüstung hält 8 Stunden (26.1)**
- Einmal gewirkt, schützt die Magierrüstung wie im SRD 8 Stunden Spielzeit (etwa 8 Minuten echte Zeit), auch in den folgenden Kämpfen ab der ersten Runde, solange keine Rüstung getragen wird. Zu Kampfbeginn meldet sie sich („hält noch“), auf der Karte zeigt das Statusfeld „Schutz“.
- Simulation (Sieg des Magiers): Grottenschrat Stufe 3 von 44 auf 63 %, Hobgoblin-Hauptmann Stufe 4 von 35 auf 50 %, Stufe 5 von 45 auf 69 %.
- Werkzeuge (nur Entwicklung): Kerntest `MageArmorTest`, Simulation `SIM=1 SIM_MA=1` in `ChapterSimTest`.

Zweig von Tom (Thema 30, 24.5, 24.16–24.20), getestet in 0.1.559, PR #40 (zusammengeführt 12.10., 09:29):

**Keine Abstürze mehr beim Kartenwechsel und im Kampf (30)**
- Die App bekommt doppelt so viel Speicher (512 statt 256 MB am Handy des Nutzers) und gibt Bilder nach einem Kartenwechsel früher frei.
- Fehler beim Zeichnen im Hintergrund beenden die App nicht mehr; sie werden gezählt und gemeldet.
- Test-Reiter: „Letztes Ende der App“ mit Grund und „Letzter Absturz“ mit Bericht zum Kopieren.

**Kampf beginnt ohne Warten (24.5, 24.16–24.20)**
- Die Kampfbilder von Held und nahem Gegner werden schon auf der Karte gezeichnet und auf dem Gerät gespeichert: Eröffnung, Held und Gegner sind beim Kampfbeginn sofort bereit (am Handy 0,0 s).
- Werkzeuge (nur Entwicklung): Test-Reiter „Kampf bereit“ und „Vorgezeichnet …“.

Zweig von Jerry (Thema 24.8.5, 30.6, 32.7, 13e Entwurf), getestet in 0.1.555, PR #38 (zusammengeführt 12.10., 08:42):

**Ortsklang klingt weich aus (24.8.5)**
- Wind, Hallenluft und Feuerknistern brechen beim Kartenwechsel nicht mehr hart ab, sondern klingen in 0,6 s aus; der neue Ort schwillt weich an.
- Fehlt eine Klangdatei oder ist der Speicher voll, bleibt es still, statt dass die App sich beendet (30.6).
- Werkzeuge (nur Entwicklung): Kerntest `PlaceSoundTest.leavingDiesAwayWithoutAJump`; Vorschau `KARTENZOOM` zeigt die Karte statt der Blende (32.7); erster Entwurf der diagonalen Höhle nur in der Vorschau (`CAVEDRAFT=1`, 13e).

Zweig von Jerry (Thema 24.8, 24.8.4), getestet in 0.1.549, PR #37 (zusammengeführt 11.10., 23:13):

**Jeder Ort klingt nach sich (24.8)**
- Der Klang des Ortes setzt schon unter der Blende ein, vor dem Bild: draußen Wind, im Tempel leise Luft einer hohen Halle, in Häusern ab und zu knarrendes Holz, in der Höhle gleich ein Tropfen.
- Schänke ohne Stimmengewirr, nur was die Anwesenden tun: Rowena wischt, schenkt ein, stellt Becher ab; Gäste stellen Becher ab, rücken den Stuhl, husten selten. Je drei Fassungen aus echten Aufnahmen (CC0), in unregelmäßigen Abständen.
- Werkzeuge (nur Entwicklung): Kerntest `PlaceSoundTest`, `tools/klang/orte.py`, Quellen in `tools/klang/QUELLEN.md`.

Zweig von Jerry (Thema 28), getestet in 0.1.540, PR #36 (zusammengeführt 11.10., 21:31):

**Musik aus echten Aufnahmen (28)**
- 40 orchestrale Stücke und Klangflächen (CC0) statt der erzeugten Melodien: eigene Titelmusik, mittelalterliche Musik im Dorf, düstere im Wald und in der Höhle, Kampf- und Bossmusik, Sieg nach gewonnenem Kampf, Musik zum Kapitelende.
- Je Ort zufällig gewählt, nie dasselbe Stück zweimal hintereinander, dazwischen 10–30 s Stille; Ort zu Ort weich überblendet, in den Kampf rasch.
- In der Höhle liegt immer eine Klangfläche darunter, Musik kommt nur ab und zu.
- Werkzeuge (nur Entwicklung): Kerntest `MusicDirectorTest`, `tools/klang/musik_holen.sh` und `musik_bauen.py`, Quellen in `tools/klang/QUELLEN.md`.

Zweig von Tom (Thema 24.14, 24.15), getestet in 0.1.538, PR #35 (zusammengeführt 11.10., 21:00):

**Held viel schneller gezeichnet (24.14, 24.15)**
- Das Zeichnen von Figuren erzeugt keine Unmengen Wegwerf-Daten mehr (je Heldenbild 3,7 statt 218 MB). Am Handy gemessen: erster Start Held ganz gezeichnet nach 5,9 s statt 27 s, Waffenwechsel 2,9 s statt 15,7 s. Aussehen unverändert; Gegner und Leute profitieren ebenso.
- Neue Beute in der Tasche wird im Hintergrund schon am Helden gezeichnet: Anlegen geht sofort (0,0 s).

Zweig von Tom (Thema 24.4, 24.9–24.13), getestet in 0.1.530, 0.1.532 und 0.1.534, PR #34 (zusammengeführt 11.10., 20:37):

**Held ohne Mischfigur und schneller bereit (24)**
- Nach einem Spielstandwechsel keine Mischung aus altem und neuem Helden mehr (24.9).
- Die Blende nach Spielstart und Spielstandwechsel wartet, bis der Held in allen Richtungen gehen kann (24.10).
- Nach einem Ausrüstungswechsel wechselt der Held in allen Richtungen zugleich, ohne Hin und Her (24.11).
- Die Heldenbilder werden auf dem Gerät gespeichert: ein Neustart oder schon getragene Ausrüstung braucht kein Zeichnen mehr (0,1 s statt 27 s; 24.4).
- Neue Ausrüstung wird schon im Menü gezeichnet, mit voller Geschwindigkeit (24.12).
- Werkzeuge (nur Entwicklung): Test-Reiter „Held ganz gezeichnet nach X s“ (24.13); Kerntest `HeroShelfTest`.

Zweig von Jerry (Thema 9i Rest, 9i.2), getestet in 0.1.529 und 0.1.531, PR #33 (zusammengeführt 11.10., 19:07):

**Spinne, Hundertfüßer, Fledermaus, Stirge und Gallerte auf der Karte (9i)**
- Die fünf übrigen Gegner laufen als neue Modelle über die Karte: die Spinne setzt die Beine, der Hundertfüßer wellt sich, Fledermaus und Stirge fliegen waagerecht auf Kopfhöhe über ihrem Schatten, die Gallerte wälzt sich.
- Im Stehen leben sie: umsehen, lauern, drohen; die Flieger schlagen weiter mit den Flügeln.
- Spinne, Fledermaus und Gallerte bleiben auf ihrem Platz, wenden sich aber dem Helden zu, wenn er näher als etwa 4 Felder kommt (9i.2).
- Werkzeuge (nur Entwicklung): Vorschau `MAPFOE=vermin`, `FOEFILM=1 FOEIDS=…`; Sprungtest um die fünf Arten erweitert.

Zweig von Tom (Thema 24.1), getestet in 0.1.527, PR #32 (zusammengeführt 11.10., 18:11):

**Blende beim Spielstart und Ortswechsel (24.1)**
- Beim Spielstart und bei jedem Kartenwechsel ein dunkler Zwischenbildschirm: beim ersten Besuch Ortsname und ein Satz, später nur der Name, bei Türen im Dorf nur ein kurzes Abdunkeln. Er bleibt, bis Held, Boden und Leute gezeichnet sind, höchstens etwa 4 s; Antippen überspringt ihn, sobald alles gezeichnet ist. Ersetzt das Namensschild oben links.
- Gemessen am Handy (bereit nach): Wald → Höhle 0,4 s, Wald → tiefer Wald 0,1 s, Dorf → Wald 0,0 s.
- Werkzeuge (nur Entwicklung): Kerntest `InterludeClockTest`, Test-Reiter „Blende: bereit nach X s“, Vorschau `BLENDE=1`, `BLENDEFILM=1`.

Zweig von Jerry (Thema 24, Teil), PR #31 (zusammengeführt 11.10., 17:27, ohne Test auf dem Handy, nichts sichtbar):

**Kampfsätze für den Zwischenbildschirm (24)**
- Vorbereitung für die Blende vor Kämpfen: je Kampfbeginn (Hinterhalt, Erstschlag, normal, Rudel) und je Gegner (alle 18) fünf Sätze auf Deutsch und Englisch (noch nicht sichtbar).

Zweig von Jerry (Thema 9i), getestet in 0.1.516 und 0.1.518, PR #29 (zusammengeführt 11.10., 17:16):

**Übrige Gegner auf der Karte (9i)**
- Wildschwein, Riesenratte, Kobold, Skelett, Zombie, Ghul, Goblin-Schamane, Grottenschrat und Hobgoblin-Hauptmann laufen als echte Figuren über die Karte: weiches Drehen, Beine in Bewegung, atmen und sehen sich um. Spinne, Hundertfüßer, Fledermaus, Stirge und Gallerte folgen.
- Gegner mit Waffe halten sie unterwegs etwas vom Bein weg, sodass keine Klinge mehr durch Oberschenkel oder Schienbein geht; der Schamane hebt seinen Stab senkrecht.
- Testmenü (9i.1): In der Monsterliste lässt sich jedes Monster neben den Helden holen, mit Rudel, 2 Minuten friedlich; der alte Knopf für Wolfsrudel und Goblin entfällt.
- Werkzeuge (nur Entwicklung): Kollisionsprüfung `FOECLASH=1` prüft auch die Karte (vorher 841 Treffer, jetzt 0), `JumpTest` alle neuen Arten.

Zweig von Tom (Thema 24, Teil), getestet in 0.1.517, PR #30 (zusammengeführt 11.10., 17:08):

**Held auf der Karte schneller bereit (24.2, 24.3)**
- Nach Spielstart werden zuerst die Bilder gezeichnet, die man sofort sieht: der Held stehend in allen Richtungen und gehend in seiner Blickrichtung; der Rest folgt im Hintergrund.
- Nach einem Ausrüstungswechsel läuft der Held mit der alten Ausrüstung weiter, bis die neue gezeichnet ist, statt ohne Beinbewegung zu gleiten.
- Vorbereitung für den Zwischenbildschirm (24.1): Sätze für alle Orte auf Deutsch und Englisch (noch nicht sichtbar).

Zweig von Tom (Thema 25), getestet in 0.1.512, PR #28 (zusammengeführt 11.10., 16:31):

**Laternen und Fenster leuchten nachts (25)**
- Das Glas der Laternen leuchtet nachts selbst und glimmt in der Dämmerung auf, mit kleinem Schein am Laternenkopf.
- Die Fenster der Häuser leuchten nachts warm.
- Werkzeuge (nur Entwicklung): Kerntest `LampGlowTest`, Vorschau `KARTENZOOM=1 DIAG=1 TOWNDRAFT=1 ONLY=zoom_nah_d7` (Nacht) / `d8` (Dämmerung).

Zweig von Jerry (Thema 18k), getestet in 0.1.511, PR #27 (zusammengeführt 11.10., 16:08):

**Feuerknistern als nahtlose Schleife (18k)**
- Das Knistern bleibt bei einer Fassung, solange es läuft, und läuft ohne hörbaren Übergang weiter (10-s-Schleifen aus den CC0-Aufnahmen 181563 und 370938); eine neue Fassung erst beim nächsten Anschwellen.

Zweig von Jerry (Thema 18h, 18i), getestet in 0.1.507, PR #25:

**Feuer und Höhle klingen lebendiger (18h, 18i)**
- Das Knistern von Lagerfeuer und Herd schwillt beim Näherkommen weich an und klingt beim Weggehen ab (ab 6 Feldern still); bei Kampf oder Menü blendet es aus.
- In der Höhle tropft es alle paar Sekunden, auch in Feuernähe (dort leiser).

**Werkzeuge (nur Entwicklung, im Spiel ändert sich nichts)**
- Neustart-Haken (14, PR #26): erinnert die Sitzung, sobald das Gespräch seit dem Start um etwa 100.000 Token gewachsen ist, erst selten, dann immer öfter; beim Sitzungsstart Warnung, wenn `docs/OFFEN.md` über 15 KB groß ist.

Zweig von Tom (Thema 5), getestet in 0.1.501 und 0.1.504, PR #24 (zusammengeführt 11.10., 14:52):

**Dorf diagonal (5)**
- Häuser in der diagonalen Sicht, Fenster außen wie im Raum dahinter, nachts warm erleuchtet; Glockenturm.
- Dinge auf dem Platz (Marktstände, Bänke, Laternen u. a.), je in drei Varianten.
- Rauch steigt aus den Schornsteinen.
- Werkzeuge (nur Entwicklung): Vorschau `ISODINGE=dorf|platz`.

Zweig von Jerry (Thema 18), getestet in 0.1.503, PR #23 (zusammengeführt 11.10., 14:48):

**Weitere Klänge aus echten Aufnahmen (18 Runde 2)**
- Kampfbeginn, Bemerkt, Hinterhalt, Held fällt, Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf, Vögel, Grillen, Eule, Tropfen und Knistern kommen aus CC0-Aufnahmen (Quellen: `tools/klang/QUELLEN.md`). Systemklänge in einer Fassung, die übrigen in drei.
- Werkzeuge (nur Entwicklung): Rezepte `tools/klang/rezepte.py`; die Vorschau lässt sich wieder übersetzen.

**Ablauf (21, nur Entwicklung, PR #22)**
- Zusammenführen auf `main` veröffentlicht kein Release mehr; Releases nur noch auf Zuruf. Pull Requests werden nicht mehr doppelt gebaut.

Zweig von Tom (Thema 13), getestet in 0.1.482, PR #20 (zusammengeführt 11.10., 14:00; stand irrtümlich schon unter v0.1.494):

**Räume diagonal: Haus des Ältesten, Laden, Tempel (13)**
- Alle drei Räume in der diagonalen Sicht mit eigenem Grundriss, klein und dicht eingerichtet; Möbel je in drei Varianten.
- Ältester: Pult, Truhe, Sessel, breites Bett an der Rückwand. Laden: Ladentisch, Warenregal, Werkzeugständer, Warenkisten. Tempel: Steinwände, Altar, Kerzenständer, Lesepult, Weihwasserbecken, Gebetsbänke, Seitengänge.
- Werkzeuge (nur Entwicklung): Kerntest `RoomPlanTest` (Held erreicht Person und Tür), Vorschau `ISODINGE=aeltester|laden|tempel`.

**Ablauf (20, nur Entwicklung, PR #21)**
- Die APK im Artefakt-ZIP eines Zweig-Builds zeigt auf dem Handy die Berliner Uhrzeit (vorher 2 h zu früh).

## v0.1.494 – 11.10.2026, 13:20

Zweig von Jerry (Thema 18), getestet in 0.1.486, PR #19:

**Klänge aus echten Aufnahmen (18.7)**
- Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg und „Gegner fällt“ kommen aus CC0-Aufnahmen statt aus erzeugten Tönen (Quellen und Lizenzen: `tools/klang/QUELLEN.md`).
- Neue Monster-Laute für Wolf (Schreckenswolf tiefer), Goblin (auch Späher und Schamane) und Skelett: Knurren beim Ausholen, Schmerz nach dem Trefferklang, Todesschrei einmal.
- Systemklänge (Stufenaufstieg, Klick, epische Beute, Kampfbeginn, Held fällt) nur noch in einer Fassung, alle übrigen in drei.
- Werkzeuge (nur Entwicklung): `tools/klang` (Aufnahmen holen, schneiden, umwandeln), Kerntest `RecordedTest`.

## v0.1.483 – 11.10.2026, 12:41

Zweig von Jerry (Thema 12.3), getestet in 0.1.481, PR #18:

**Kampf: Sprungangriff der Tiere weicher (12.3b)**
- Wolf und Riesenratte: beim Sprungangriff je ein Zwischenbild mehr beim Abheben und Landen, eines weniger beim Ducken (Angriff etwa 0,08 s länger).
- Werkzeuge (nur Entwicklung): Kampfteil aus `JumpTest.listOthers` gestrichen (12.3c); Kampfbewegungen prüft `BattleJumpTest` streng (0 Meldungen). Befund 12.3a: die 265 Meldungen waren schnelle, aber weiche Bewegungen, gemessen mit den Grenzen der Karte.

## v0.1.479 – 11.10.2026, 11:35

Zweig von Jerry (Thema 18 und Hörproben), getestet in 0.1.472, PR #16:

**Kampf: Pechsträhnen dämpfen (18)**
- Nach drei Fehlschlägen des Helden in Folge trifft der nächste Angriff unsichtbar etwas leichter (+2, je weiterer Fehlschlag +1, höchstens +4), bis er wieder trifft; nur innerhalb eines Kampfes.
- Werkzeuge (nur Entwicklung): Kerntest `MissStreakTest` mit Vergleich mit und ohne Dämpfung.

**Hörproben (nur Entwicklung, im Spiel unverändert)**
- 17 weitere Klänge je dreimal neu und Monster-Laute für Wolf, Goblin und Skelett; Vorschau `KLANGPROBEN=`.

## v0.1.471 – 10.10.2026, 22:33

Zweig von Tom (Thema 13 und Vorarbeiten), getestet in 0.1.461, PR #17; als Release getestet am 11.10. („lief gut“):

**Karte: diagonale Sicht (13)**
- Die Karte wird schräg von oben gezeigt; der Held läuft frei statt von Feld zu Feld (13g).
- Figuren stehen in der Mitte ihres Feldes und laufen bis an Möbel heran, wo diese gezeichnet sind (13q.1–3).

**Schänke diagonal (13, 6.14, 13n, 13p)**
- Hintere Wände mit Balken, Kamin und Fenster, vordere Wände kniehoch; Möbel in drei Varianten, im Maßstab des Helden.
- Feuer im Kamin flackert, sein Licht fällt auf Wände und Boden.
- Bänke mit Lehne, Rowena hinter der Theke, Fass, Hocker, Eimer, Korb, Säcke und Pflanze rund und richtig geneigt; Tippen trifft das gezeichnete Ding.

**Leute (12b, 3a, 4)**
- Stehen und Gehen ohne Sprünge (Gehen in 8 Bildern), Glühwürmchen, Garrick hockt am Feuer.

**Werkzeuge (nur Entwicklung)**
- Vorschau `KARTENZOOM=1 DIAG=1 TOWNDRAFT=1`, `ISODINGE=1`, `FEUER=1`; Kerntests `InnCornerTest`, `FireFlickerTest`.

## v0.1.460 – 10.10.2026, 21:14

Zweig von Jerry (Thema 16), getestet in 0.1.458:

**Kampf: Trefferstopp (16)**
- Treffer halten beim Aufprall je nach Wucht inne: ein normaler Treffer nur kurz, ein harter (ein Drittel der Lebenspunkte oder mehr) zwei Bilder lang, ein kritischer drei; für Held und Gegner gleich.
- Ein kritischer Treffer zieht die Ansicht kurz etwas heran und ruckt einmal in Schlagrichtung, statt das Bild wackeln zu lassen.
- Werkzeuge (nur Entwicklung): Kerntest `HitWeightTest` (Stufen, Zeiten bei jedem Tempo, Ruck ohne Hin- und Herwackeln).

## v0.1.455 – 10.10.2026, 20:29

Zweig von Jerry (Themen 12a und 19), getestet in 0.1.441 und 0.1.454:

**Kampf: Bewegungen ohne Sprünge (12a)**
- Waffe und Schild drehen zwischen zwei Haltungen gleichmäßig, statt in einem Bild umzukippen: beim Zaubern und Werfen mit Waffe in der Hand, beim Armbrust-Block, beim Fallen der Gegner auf der Puppe.
- Todesstoß mit Drehung ohne Rückwärtsdrehung am Ende; Überfall und Trinken mit Zwischenbildern.

**Kampf: jeder Schlag trifft sichtbar (19)**
- Todesstoß von oben neu getaktet: kurz oben halten, Hieb über vier Bilder, die Klinge fährt schräg in den Gegner statt senkrecht neben ihm vorbei.
- Alle Schläge zielen in den Körper des Gegners, nicht an seinen Rand; beim Todesstoß mit Drehung bleibt der Held vor dem Gegner und die Klinge fährt geradeaus in ihn.
- Todesstöße hingen: Der Held blieb bis zu 2 s im ausgeholten Bild stehen, während der Gegner fiel (die Bilder waren noch nicht gezeichnet). Jetzt werden sie beim Ausholen gezeichnet, und der Speicher fasst alle Bilder eines Kampfes.
- Ausfallschritt: kommt beim gehaltenen Ausholen zur Ruhe und setzt weich wieder ein, statt hart zu stoppen und anzurucken.

**Werkzeuge (nur Entwicklung)**
- Kerntests `BattleJumpTest` (Sprünge im Kampf, streng) und `HitReachTest` (Klinge im Trefferbild im Gegner, Held nicht im Gegner, Ausfallschritt weich, alle Bilder eines Kampfes im Speicher).
- Vorschau `SPRUNGBILD=…` (Bilder rund um eine Fundstelle) und `TREFFERBILD=…` (Schläge mit Gegner, gestellt wie in der App). Kampffilme mit `FILMBATCH` brauchen hinter dem Plan das Wort `attack`.

## v0.1.438 – 10.10.2026, 16:21

Zweig von Jerry (Thema 9k), getestet in 0.1.433:

- Goblins auf der Karte: Die zweite Klinge (Dolch) steckt beim Herumlaufen in der Scheide an der Hüfte, der Schild ist auf den Rücken geschnallt. Von der Seite ragte in Hüfthöhe nichts mehr nach vorn. Im Kampf unverändert.

## v0.1.430 – 10.10.2026, 15:28

Zweig von Jerry (Themen 9 und 12), getestet in 0.1.425:

**Monster auf der Karte (9)**
- Wolf, Goblin und Goblin-Späher laufen als ihre Kampfmodelle über die Karte, im gleichen Maßstab und Blickwinkel wie der Held, und drehen sich fließend in 16 Richtungen. Der Wolf setzt die vier Pfoten nacheinander, der Goblin geht geduckt in weichen Schritten.
- Goblins auf der Karte haben eine dunklere, erdigere Haut und einen dunklen Umriss und tragen die Waffe gesenkt am Bein, damit sie sich vom Gras abheben.
- Im Stehen sind die Monster nie starr: Ein Wolf atmet, sieht sich um, schnüffelt am Boden, wittert oder fletscht die Zähne; ein Goblin verlagert das Gewicht, späht, duckt sich oder hebt die Waffe. Jedes Tier im eigenen Takt, jede Haltung mit Zwischenbildern hinein und heraus.
- Rudel: Jungwölfe, Späher und Grimmzahns Leibwache gehen auf eigenem Weg zu ihrem Platz hinter dem Anführer, im eigenen Tempo, weich auslaufend, und schauen, wohin sie gehen. Dreht der Anführer, kommen sie im Bogen hinterher.
- Grimmzahn und seine Leibwache als Kampfmodelle; kommt der Held nahe, drehen sie sich zu ihm, und Grimmzahn fletscht die Zähne.

**Testreiter**
- „Monster beachten mich nicht“: Monster laufen und stehen wie sonst, greifen aber nicht an.
- „Wolfsrudel und Goblin mit Späher herholen“: setzt beide 3 bis 5 Schritte vom Helden ab.
- „Sichtlinie aus (alles sichtbar)“: kein Nebel, keine Sichtlinie; erkundet wird trotzdem wie sonst.

**Werkzeuge (nur Entwicklung)**
- Sprungtest (12): Kerntest `JumpTest` findet Sprünge in Bewegungen und Übergängen, Bild für Bild, ohne Bild in Sekunden; für die Monster auf der Karte 0 Sprünge.
- Vorschau: `MAPFOE=scene|dirs|walk|yaws|idle|ease|others|cave|wood`, Film `FOEFILM=1` (mit `FOEIDLE=1` im Stehen).


Zweig `tom-diagonal` (Tom), noch nicht auf `main`:

- **Diagonale Sicht (13, Schalter „Sicht“ im Testreiter, im Bau):** Die Karte ist um 45° gedreht, die Kacheln liegen als Rauten. Dinge und Figuren stehen aufrecht und verdecken sich richtig, die Figuren drehen sich mit. Tippen und Joystick sind umgerechnet. Möbel und Wände sind noch die alten Bilder.
- **Freies Laufen (13g):** In der diagonalen Sicht läuft der Held in jede Richtung, wohin der Joystick zeigt, und gleitet an Wänden entlang. Getippte Wege gehen in geraden Linien. Türen, Begegnungen und alles andere funktionieren wie bisher.
- **Gehen und Stehen ohne Sprünge (12b):** Held und Leute gehen in acht statt vier Bildern. Der Blick zur Seite, das Gewichtverlagern und die Hände am Gürtel gehen weich hinein und heraus.

Zweig `tom-sculpt-raeume` (Tom), noch nicht auf `main`:

- **Garrick am Feuer bewegt sich weich (3a):** Er lässt sich über knapp eine Sekunde auf die Fersen nieder und steht ebenso wieder auf, lehnt sich zum Schüren vor und zurück, der Stock fährt gleichmäßig durch die Glut. Beim Einnicken sinkt der Kopf langsam; schreckt er hoch, sinkt er langsam wieder. Vor dem Aufstehen wird er erst wach.
- **Blätter im Wald gehören zur Welt (4):** Die treibenden Blätter hingen am Bildschirm und wanderten mit, in der Dämmerung sahen sie aus wie Glühwürmchen. Jetzt bleiben sie an ihrem Ort, in trockenen, mit dem Licht dunkleren Farben.
- **Kartenzoom in vier Stufen (6.15):** Der Knopf im Testreiter schaltet durch 5,6, 6,75, 8,4 und 10,5 Kacheln Bildschirmbreite.
- **Räume (6.14, Schalter „Dorf und Räume“):** Regal, Brennholz, Tisch und Fass mit `Sculpt` gebaut, räumlich, mit Gebrauchsspuren, je drei Varianten.

## v0.1.409 – 10.10.2026, 10:52

Zweig `karte-neuer-stil` auf `main`, mit der Testumgebung von Account B:

**Wetter**
- Der Regen-Schalter im Testreiter hat drei Stellungen: zufällig (wie im Spiel), immer, nie. Bei „nie“ regnet es wirklich nicht mehr. Die Beschriftung zeigt die Stellung.
- Neuer Regen: drei Schichten (fern fein und blass, nah lang und schnell), jeder Tropfen eigen in Länge und Helligkeit, Böen, die ihn dichter machen und schräger stellen. Er setzt langsam ein und hört langsam auf. Unter dem Regen wird das Bild grauer; Tropfen spritzen auf dem Boden, auf dem Wasser ziehen Ringe. In der Höhle und in Räumen regnet es nicht.
- Sehr selten, bei starkem Regen im Freien, Wetterleuchten in der Ferne: der Himmel hellt zweimal kurz auf, ein paar Sekunden später rollt leiser Donner heran. Testknopf „Wetterleuchten mit Donner“: das Leuchten kommt, sobald die Karte wieder zu sehen ist, und ist bei Tag kräftiger.

**Karte**
- Der Held trägt seine Waffe beim Herumlaufen verstaut, bei allen Klassen: Schwerter und Dolche in einer Lederscheide an der linken Hüfte, den Griff nach vorn oben; Äxte, Streitkolben und Hämmer am Gürtel, den Kopf oben. Lange Waffen (Zweihänder, Speer, Stab, Bogen) bleiben an der Schulter, der Schild auf dem Rücken.
- Garrick hockt sich ab und zu ans Feuer und schürt mit einem Stock die Glut; nachts öfter und länger, dann nickt er ein: der Kopf sinkt tief auf die Brust, ab und zu zuckt er kurz hoch. Testknopf „Garrick döst jetzt“ (wird wieder entfernt). Kommt der Held, steht er auf und schaut ihm entgegen; kommt ein Monster, steht er auf und greift die Fackel.
- Glühwürmchen neu: Sie schwirren an festen Plätzen in der Welt (über Blumen, am Wasser, am Waldrand, im Dorf über Feldern und am Fluss), in kleinen Gruppen, langsam taumelnd. Jedes blitzt eine halbe Sekunde auf und ist dann Sekunden dunkel, in eigenem Takt; manchmal antwortet ein Nachbar. Ein heller Kern mit weichem Schein, der das Gras darunter leicht aufhellt. Nicht jede Nacht und nicht bei Regen.

**Innenräume (Entwurf, Schalter „Dorf und Räume“)**
- Licht und Schatten (6e–6f): Der Herd leuchtet gedämpfter und weniger weit, sein Schein flackert, sodass der Raum mit dem Feuer atmet; Kerzen auf Tischen und Theke geben kleine warme Lichtinseln, dazwischen Halbdunkel; tiefere Schatten unter Tischen und Bänken und hinter der Theke. Aus dem Kessel steigt Dampf, über dem Feuer Rauch und Funken, im Licht von Fenster und Tür tanzt Staub. Gebrauchsspuren: umgekippte Becher, Krümel, ein Lappen auf der Theke.
- Die Schänke im neuen Stil: ein Steinkamin in der Rückwand mit Feuer und Kessel als Hauptlicht, dunkle Ecken, fahles Tageslicht durchs Fenster. Möbel im Maßstab der Figuren (hüfthohe lange Tische und Theke, mannshohe Regale, ein Bett von zwei Feldern Länge), Bänke, Fässer, Kisten. Kleinkram am Boden (Feuerholz, Säcke, Korb, Eimer, Stroh, Schemel), über den man langsamer läuft. An der Wand Kräuter, Umhang, Pfannen, Geweih. Der Raum ist enger; man wacht neben dem Bett auf.

**Werkzeuge (nur Entwicklung, im Spiel ändert sich nichts)**
- Testumgebung für Cloud-Sitzungen: Gradle lädt über einen Spiegel von Maven Central, beim Sitzungsstart werden die Kerntests im Hintergrund vorübersetzt, `tools/t` wählt je Anlass das passende Werkzeug.
- Reine Änderungen an Werkzeugen (`tools/`, `.claude/`) bauen keine APK mehr und erzeugen auf `main` kein Release.
- Neuer Kerntest: Ein Zufallsspieler spielt ohne Bild durch Dorf, Wald und Höhle, kämpft, kauft und speichert und meldet Abstürze, hängende Dialoge und unmögliche Werte.

## v0.1.377 – 09.10.2026, 22:31

**Neu – Höhle im neuen Stil**
- Die Blutzahnhöhle hat einen neuen Boden in doppelter Auflösung und ohne Raster: Fels in flachen Absätzen, lange Risse, Grus, Staub auf den Wegen, feuchte Stellen, Pfützen und Moos, ein schwarzer Tümpel; am Ausgang ziehen Erde, Laub und Wurzeln aus dem Wald herein.
- Die Wände haben eine dunkle Oberseite und eine sichtbare Felskante mit Schichten und nassen Streifen, damit man die Räume erkennt; Schatten unter allem, was steht.
- Felswände in der Höhle bleiben nach dem Erkunden nicht mehr schwarz: Gestein gilt als so erkundet wie der Boden davor, das Licht fällt ein Stück weit auf den Fels, und der Rand des Lichts ist weich statt eckig.
- Alle Dinge der Höhle sind neu gezeichnet wie Ausrüstung und Gegner, je in drei Varianten: Stalagmiten, Kisten und Fässer, Knochen, Schlafplätze, Felsen, Geröll, Leuchtpilze, Kristalle, Stützbalken, Gitter, Lagerfeuer (flackernd), Truhen (auch geöffnet), Wandfackeln, Wurzeln am Lichtschacht.

**Neu – der Held auf der Karte als Puppe**
- **Garrick als Puppe auf der Karte:** Der Jäger am Lagerfeuer ist jetzt dieselbe Puppe wie der Held: kurzer Vollbart, Kapuze und Umhang in dunklem Oliv, dunkles Leder, Langbogen und Köcher quer über dem Rücken, die Hände frei. Er dreht sich fließend und schaut dem Helden nach, solange der in seiner Nähe (bis 4 Felder) ist. Die übrigen Leute sind noch die alten Figuren. Nach einem Gespräch dreht er sich wieder zum Feuer, sobald der Held weggeht. Held und Garrick erscheinen sofort als Puppe, nicht mehr kurz als alte Figur (Puppen werden beim Laden und Kartenwechsel vorgezeichnet). Allein gelassen wärmt Garrick sich die Hände am Feuer oder dreht sich weg und späht, die Hand über den Augen, in den Wald, zu unregelmäßigen Zeiten und verschieden lang. Steht der Held 20 Sekunden still bei ihm, verliert er das Interesse und wendet sich wieder dem Feuer zu.
- **Lebendige Welt (09.10.):** Wer auf der Karte steht, steht nicht mehr starr: Held und Leute atmen, verlagern ab und zu das Gewicht, schauen kurz zur Seite, Leute stützen auch die Hände in die Hüften, jede Figur in ihrem eigenen, unregelmäßigen Takt.
- **Fackel und Feuerschein (09.10.):** Jagt ein Monster den Helden bis an Garricks Lagerfeuer, reißt Garrick einen brennenden Ast aus dem Feuer, schwenkt ihn gegen das Biest und legt ihn danach zurück; das Monster weicht zurück. Figuren nahe einer Flamme fangen auf der zugewandten Seite warmes Licht.
- **Behoben (09.10.):** Am Höhleneingang im Wald fehlte seit dem Höhlenumbau die Felswand; sie ist wieder da. Beim Betreten von Wald und Höhle erscheinen keine alten Kartenkacheln mehr, der neue Boden wird vorab und auf mehreren Kernen gezeichnet. Im hohen Gras stehen dunkle Halme vor den Füßen statt des hellgrünen Rechtecks.
- **Felshang am Höhleneingang (09.10.):** Im Flüsterwald öffnet sich die Höhle jetzt in einen Hang aus großen, moosigen Felsbrocken mit Wurzeln, Geröll, Knochen und einem Schädel auf einem Pflock.
- Auf allen Karten ist der Held jetzt dieselbe Figur wie im Kampf, schräg von oben, in wahrer Größe je Volk, mit seiner echten Ausrüstung. Beim Herumlaufen trägt er kurze Waffen (Schwert, Streitkolben, Axt, Dolch) tief in der rechten Hand, die Spitze nach vorn unten, lange Waffen (Zweihänder, Speer, Stab, Hellebarde, Bogen, Armbrust) fast aufrecht an der rechten Schulter, und den Schild auf dem Rücken (Rund-, Spitz- und Turmschild in ihrer Form, Oberkante knapp über den Schultern, mit Riemen über der Brust); die linke Hand ist frei.
- Der Held dreht sich weich in die neue Richtung (16 Richtungen, eine halbe Drehung in etwa einer Viertelsekunde), statt eckig umzuspringen, und geht mit vier Schrittbildern.
- Die Bilder werden beim Betreten der Karte im Hintergrund gezeichnet, die aktuelle Blickrichtung zuerst; bis dahin steht kurz die bisherige Figur da. Nach einem Ausrüstungswechsel werden sie neu gezeichnet.

**Neu – Bäume, Felsen und Unterholz im Wald**
- Im Flüsterwald und im Tiefen Wald stehen neue Bäume in doppelter Auflösung, schräg von oben, mit Licht von links oben: Eichen mit Stamm, gefurchter Rinde, Wurzeln und knolliger Krone in zehn Varianten und drei Größen; Fichten in hängenden Stufen; tote, graue Bäume mit kahlen Ästen (im Tiefen Wald öfter, dort auch dunkleres Laub). Auf manchen Waldkacheln stehen zwei Bäume, leicht versetzt.
- Felsen sind Blockgruppen mit beschatteter Vorderseite und Moos auf der Nordseite, umgestürzte Stämme tragen Moos, Steinkreise haben hohe, verwitterte Steine mit Flechten.
- Auf der Wiese, dichter am Waldrand, wachsen Büsche und Farne; nie auf dem Weg.
- Bäume, Felsen und Steine werfen Schatten nach rechts unten auf den Boden, kräftig am Tag, in der Dämmerung schwächer, nachts keine.
- Lagerfeuer, Truhen und Schilder im Wald neu: Feuer in einem Ring rußiger Steine mit Asche, verkohlten Scheiten, flackernden Flammen, Glut und Funken; Truhen aus verwitterten Planken mit Eisenbändern, Schloss und Moos, offen mit hochgeklapptem Deckel; Schilder als grobe Bretter auf schiefem Pfahl, mit eingeritzter Schrift und Krallenspuren.
- Steht der Held hinter einer Baumkrone, einem Felsen oder Busch, wird genau dieses Bild halb durchsichtig, damit er nicht verloren geht.
- Die Bäume sind deutlich höher, passend zum Helden als Puppe: eine alte Eiche oder Fichte überragt ihn um mehr als das Doppelte. Wo eine Krone etwas verdecken würde, das man finden muss (Truhe, Feuer, Schild, Leute, Ausgänge), steht stattdessen eine junge Fichte.

**Neu – Boden im Wald ohne Raster**
- Im Flüsterwald und im Tiefen Wald ist der Boden neu gezeichnet, in doppelter Auflösung und ohne sichtbare Kacheln: Waldboden aus Moos, nackter Erde und altem Laub, unter dem Waldrand dunkler. Wiese, hohes Gras, Blumen und Wasser gehen unregelmäßig ineinander über.
- Der Weg ist ein breiter, geschwungener Karrenweg aus festgetretener Erde, etwa eine Kachel breit, statt einer Treppe aus Kacheln: niedergetretenes Gras am Rand, hellere, ausgetretene Mitte, zwei tiefe Fahrspuren mit Pfützen, Steine, hineinwachsendes Gras. An seinen Enden läuft er schmaler aus. Kreuzungen, Gabelungen und lange Querwege hängen zusammen (vorher rissen sie im Tiefen Wald mit geraden Kanten ab); an Kreuzungen und breiten Stellen keine Fahrspuren. Wo man laufen kann, richtet sich weiter nach den Kacheln.
- Hohes Gras ist dicht und dunkel mit einzelnen, im Wind geneigten Halmen; überall auf der Wiese kurze Grasbüschel. Der Weiher ist dunkel und tief, mit schlammigem Rand und dünnen Lichtstreifen auf dem Wasser.
- Der Boden wird beim Betreten im Hintergrund vorgezeichnet, die nächste Umgebung zuerst; bis dahin stehen dort kurz die alten Kacheln.

**Geändert – Karte näher heran, Gelände bremst (Stufe 1 der neuen Karte)**
- Die Karte ist näher herangezoomt: etwa 5½ statt 10½ Kacheln Bildschirmbreite. Die Kamera folgt dem Helden wie bisher, man scrollt mehr und sieht mehr vom Einzelnen. Im Testreiter lässt sich mit „Kartenzoom“ zwischen nah und weit (bisher) wechseln.
- Das Gelände bestimmt das Tempo: Auf Weg, Pflaster und Brücke geht ein Schritt etwas schneller (× 0,85), über Blumen, Knochen und Leuchtpilze etwas langsamer (× 1,1), über Geröll langsamer (× 1,3) und durch hohes Gras deutlich langsamer (× 1,5). Wandernde Monster bremst der Boden genauso.
- Gemächlicheres Tempo auf der Karte: Jeder Schritt dauert 1,6-mal so lange wie bisher, für den Helden wie für wandernde Monster. Nah herangezoomt wirkte das alte Tempo hektisch.
- Vorbereitung für feinere Kartenbilder: Der nahe Zoom ist immer gerade, damit Bilder in doppelter Auflösung später auf ganze Bildschirmpunkte fallen.

## v0.1.325 – 09.10.2026, 17:17

**Behoben**
- Goblin-Späher (Begleiter des Goblins): Sein Pfeil flog vom Haupt-Goblin los, als hätte dieser geschossen. Jetzt verlässt er den Bogen des Spähers.

## v0.1.317 – 09.10.2026, 16:23

**Neu – Killerschlag**
- Tötet ein kritischer Treffer mit einer Nahkampfwaffe den Gegner, schlägt der Held einen besonderen Schlag: Überkopfhieb, Durchbohren (bei Axt, Streitkolben und Hammer stattdessen ein Aufwärtshieb) oder Drehhieb, zufällig. Mit dem Speer Aufspießen oder Überkopfstoß, mit dem Stab Überkopfhieb oder Durchstoßen. Der Schlag hält beim Aufprall länger inne (etwa eine Drittelsekunde), das Bild bebt stärker.
- Mehr Wucht (gemeldet 09.10.: „wenig Animation drin“; Vorschläge 1–4 von dir gewählt): Der Held holt aus und verharrt kurz oben, dann kommt der Schlag schneller als jeder andere; danach läuft alles in Zeitlupe weiter (der Held kommt langsam aus dem Schlag, Blut und Teile fliegen anfangs halb so schnell); das Bild zoomt auf Held und Gegner heran und nach dem Fall wieder zurück; die Klinge zieht eine dunkelrote Spur im Bogen durch den Gegner, die rasch verblasst.
- Was mit dem Gegner geschieht, richtet sich nach der Blutstufe: „Aus“ – er sackt verdunkelt zusammen; „Dezent“ – ein Blutschwall und eine große Lache, dann sein Sturz; „Deutlich“ – er wird entlang des Hiebs zerteilt, beim Durchbohren reißt ein Loch und er kippt um; die Teile fallen und bleiben in der Lache liegen.
- Tiere (Wolf, Wildschwein, Ratte, Spinne, Hundertfüßer, Fledermaus, Stirge) werden bei „Deutlich“ nicht zerteilt (das wirkte ausgeschnitten), sondern bekommen eine tiefe, klaffende Wunde entlang des Hiebs, die beim Sturz mitgeht, mit Blutschwall und Lache.
- Skelette zerspringen bei jeder Blutstufe in Knochen (Waffe und Schild fallen für sich), die Ockergallerte platzt (außer bei „Aus“), Zombie und Ghul bluten dunklen Schleim. Gilt für alle Gegner.
- Testreiter: Schalter „Held trifft immer kritisch“, um den Killerschlag gezielt zu sehen.

**Behoben**
- Überkopfhieb (Killerschlag): Beim Ausholen hing die Klinge hinter dem Kopf nach unten wie im Untergriff, im Schlag schien der Griff zu wechseln. Jetzt steht die Klinge beim Ausholen nach oben und der Griff bleibt bis zum Treffer gleich.
- Die Wundflecken eines Gegners erschienen schon, während der Held noch ausholte; jetzt erst, wenn der Schlag trifft.

## v0.1.279 – 09.10.2026, 11:16

**Neu – Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte im neuen Stil**
- Die fünf haben jetzt eigene, räumliche Körper nach dem von dir freigegebenen Entwurf, je drei Aussehen, und bewegen sich wie die übrigen Gegner im neuen Stil: drei Angriffe, drei Arten, getroffen zu werden, drei Ausweichbewegungen und drei Stürze; sie bleiben liegen.
- Spinne: Biss nach dem Aufbäumen, Sprung, Stich mit den Vorderbeinen; stirbt mit eingezogenen Beinen. Hundertfüßer: Stoß von oben, flach an die Beine, Peitschen; rollt sich im Tod ein. Fledermaus und Stirge schweben mit schlagenden Flügeln, stoßen herab, beißen oder stechen; im Tod stürzen sie zu Boden. Gallerte: schlägt zu, wälzt sich über den Helden, kriecht an die Beine; zerfließt im Tod zu einer Lache.
- Auf der Karte behalten sie vorerst ihre alten Figuren.
- Ockergallerte: Verletzt bekommt sie fast schwarze Wunden wie Löcher im Schleim (vorher ockerfarben und kaum zu sehen). Je stärker verletzt, desto flacher sinkt sie zusammen, mit größerer Lache und mehr Tropfen.

**Geändert – Tatendrang nach SRD**
- Tatendrang (Kämpfer) gilt jetzt einmal pro Rast statt einmal pro Kampf: Nach dem Einsatz steht er erst nach einer Rast am Lagerfeuer oder im Gasthaus wieder bereit (ein Stufenaufstieg füllt ebenfalls auf). Die Beschreibung stimmt jetzt auch ab Stufe 5: eine zusätzliche Angriffsaktion, mit „Zusätzlicher Angriff“ also zwei weitere Schläge.

**Geändert – Treffer ohne Flackern**
- Ein Treffer lässt Held oder Gegner nicht mehr viermal weiß aufblinken. Stattdessen halten beide beim Aufprall eines Nahkampfschlags einen Augenblick inne (etwa 70 ms), dann färbt sich der Getroffene kurz dunkel blutrot und blasst in etwa einer Drittelsekunde wieder aus. Schattierung und Einzelheiten bleiben dabei sichtbar.
- Der Getroffene zuckt jetzt erst, wenn der Schlag landet; Blut, Hiebspur und Treffergeräusch kommen ebenfalls mit dem Aufprall.
- Kritische Treffer erschüttern kurz das ganze Kampfbild.
- Der Held wackelt bei einem Treffer nicht mehr seitlich hin und her; nur kritische Treffer erschüttern das Bild.
- Die weißen Trefferzeichen der ersten Fassung sind weg: Zahnreihe beim Biss, Ring mit Sternchen bei stumpfen Waffen, Striche beim Hieb, Stern beim Stich, weiße Splitter. Den Treffer zeigen jetzt Innehalten, die dunkelrote Färbung und Blut (bei Skeletten Knochensplitter, bei Untoten und der Gallerte dunkle Spritzer), und zwar erst im Augenblick des Aufpralls. Bei Blutstufe „Aus“ bleiben Innehalten und Färbung.

**Behoben**
- Gift, Brennen und Bluten am Helden: Der Schaden zu Beginn einer Runde sah aus wie ein zweiter Angriff des Gegners (er stürmte erneut vor). Jetzt bleibt der Gegner stehen, nur der Held zuckt und färbt sich kurz rot.
- Ghul: Der Klauenangriff war nicht zu sehen. Er stürmte so dicht an den Helden heran, dass Arme und Klauen hinter ihm verschwanden. Jetzt treffen die Klauenspitzen, und der Hieb ist vor dem Helden zu sehen (alle drei Varianten).
- Goblin-Späher: Der Pfeil flog aus der Körpermitte statt vom Bogen los. Jetzt startet er an der Bogenhand. Ebenso kommt der Feuerpfeil des Schamanen vom Schädel auf dem Stab und sein Fluch aus der Hand.

## v0.1.226 – 08.10.2026, 18:53

**Geändert – mehr Abwechslung in den Bewegungen**
- **Gegner:** Angriff, Getroffenwerden und Ausweichen werden jedes Mal zufällig aus den drei Varianten gewählt, nie zweimal hintereinander dieselbe. Bisher hing die Wahl beim Getroffenwerden und Ausweichen an der Nummer der Meldung, sodass bei gleichförmigen Runden oft dieselbe kam. Der Sturz bleibt eine von drei, fest pro Gegner (Taumeln und Fallen gehören zusammen).
- **Held, getroffen:** drei Bewegungen statt einer: zurückgeworfen, zusammengekrümmt, zur Seite gerissen.
- **Held, Abwehr:** drei Haltungen je Waffenart statt einer. Mit Schild: hoch (gegen Tiere und Kleine tief), dahinter geduckt, schräg zum Abgleiten. Mit Zweihänder: quer hoch (oder tief), schräg, hängende Deckung.
- **Held, Schläge:** drei Schläge je Nahkampfwaffe statt zwei (Hieb, Stoß, Schlag von oben), beim Kampfstab mit einem Stoß, bei dem das Stabende frei bleibt. Gewählt wird zufällig, nie zweimal hintereinander derselbe. Der Speer behält seine zwei Stöße, Bogen und Armbrust ihren Schuss.
- Alle neuen Bewegungen sind für alle Völker auf Kollisionen geprüft (Waffe durch Körper oder Schild: 0).
- Der Stab des Schamanen fällt beim seitlichen Sturz nicht mehr durch den Körper.

**Neu – Goblin-Schamane im neuen Stil**
- Der Schamane steht auf der Puppe: fast schwarze, rußige Robe (oder ein räudiges Fell), gehörnter Tierschädel als Kappe, Knochenkette, rußig eingesunkene Augen mit grün glühendem Blick, ein Streifen alten Bluts über der Nase. Auf seinem Knotenstab sitzt ein Schädel, dessen Augen grün glimmen.
- Er zeigt, was er tut: Beim Feuerpfeil sammelt er die Kraft am erhobenen Stab und stößt ihn vor, beim Fluch zieht er grünes Licht in der freien Hand hoch und schleudert es auf den Held, im Nahkampf schlägt er mit dem Stab zu. Für Zauber tritt er nicht vor.
- Drei Varianten: Robe, Fell, Robe mit Fell. Treffer, Ausweichen und Sturz je dreimal.

**Behoben – Schüsse und Zauber der Gegner**
- Ein Gegner, der aus der Entfernung angreift (Schamane, nach dem Code auch der Goblin-Späher mit dem Bogen), lässt Pfeil, Feuerpfeil oder Fluch jetzt im Moment los, in dem er abfliegt. Bisher stand er in der Ausholhaltung, bis das Geschoss schon eingeschlagen war, und schoss erst dann.
- Der Held blinkt beim Treffer wieder so lange wie früher; durch den längeren Rückweg der Gegner (v0.1.210) blinkte er doppelt so lange.

**Neu – Ghul im neuen Stil**
- Der Ghul steht jetzt auf der Puppe wie Goblin, Skelett und Zombie: hager und grau, mit aufgerissenem, blutigem Maul, spitzen Ohren und langen, schwarzen, gespreizten Klauen. Er kauert tief und vorgebeugt, die Klauen vor sich.
- Drei Varianten: fast nackt in Lumpen, in einer verrotteten Lederrüstung oder in einer zerschlissenen Robe. Größe und Körperbau variieren.
- Drei eigene Klauenangriffe: Hieb mit einer Klaue über den Kopf hinweg, Rechen mit beiden Klauen, Sprung aus der Hocke. Dazu je drei Arten, getroffen zu werden, auszuweichen und zu sterben.
- Kreaturen in Roben tragen darunter keine farbigen Hosen mehr, sondern dunkles Tuch.

## v0.1.210 – 08.10.2026, 16:46

**Geändert – flüssigere Bewegungen im Kampf**
- **Schritt beim Angriff gleitet:** Geht der Held oder ein Gegner zum Schlag vor und wieder zurück, gleitet die Figur jetzt durch, statt im Takt der Bewegungsbilder in großen Sprüngen über den Bildschirm zu setzen (bisher bis zu einem Sechstel der Bildbreite auf einmal). Gilt für den Helden und alle Gegner im neuen Stil.
- **Gegner: zweiter Teil des Schritts mit dem Schlag:** Hält ein Gegner nach dem Ausholen inne und schlägt dann zu, kommt der Rest des Schritts gleitend mit dem Schlag, statt sofort ganz nach vorn zu springen.
- **Gegner im gleichen Takt wie der Held:** Gegner im neuen Stil holen aus und gehen zurück mit derselben Zeit pro Bewegungsbild wie der Held (92 ms bei „Normal“, Rückweg 1,6-mal langsamer). Bisher lief ihr Angriff etwa 1,5-mal so schnell und lief über eine Kurve, die schnell anlief und langsam auslief; jetzt geht er gleichmäßig durch. Kleine, flinke Tiere (Wolf, Riesenratte) sind um 15 % schneller, Bosse (Krogg, Grak, Grimmzahn) um 12 % langsamer und wuchtiger. Der Schlag selbst trifft so schnell wie bisher, damit Treffer, Blut und Zucken des Helden zusammenpassen. Das Kampftempo (Ruhig, Schnell) wirkt wie gehabt auf alles.
- **Kein Aufblitzen der Endhaltung:** Am Anfang jeder neuen Meldung war für einen Augenblick schon das Ende der Bewegung zu sehen (etwa ein Gegner, der kurz am Boden lag, wieder stand und dann fiel, oder kurz in die Ruhe zurücksprang). Jede Bewegung beginnt jetzt sauber am Anfang.

## v0.1.204 – 08.10.2026, 15:44

**Geändert – Kampftempo für alle Animationen**
- Die Einstellung Ruhig / Normal / Schnell wirkt jetzt auf alle Kampf-Animationen: Schläge, Zauber, Würfe, Reaktionen (Treffer, Ausweichen, Block), Effekte, Blutspritzer, Stürze und das Heulen, nicht mehr nur auf Textgeschwindigkeit und Lesepausen. Ruhig dehnt die Zeiten auf das 1,35-fache, Schnell kürzt sie auf das 0,7-fache.
- Schläge und Zauber sind bei „Normal“ etwas langsamer als bisher, damit sie zu den ruhigeren Reaktionen passen (Held: Schlag- und Zauberbilder, Gegner: Ausholen und Zuschlagen).

## v0.1.200 – 08.10.2026, 13:47

**Geändert**
- **Blutlache bleibt am Boden:** Bei „Blutend“ liegt die Lache jetzt fest am Platz der Figur auf dem Boden und hüpft nicht mehr mit, wenn Held oder Gegner vorspringen, ausweichen oder taumeln. Die fallenden Tropfen gehen weiter mit dem Körper.

## v0.1.199 – 08.10.2026, 13:39

**Geändert – Abschlussmeldung nach Untote vertreiben**
- Das Siegesfeld hat nach Untote vertreiben eine klare Abschlusszeile wie nach einem normalen Sieg: „Zombie wurde vertrieben!“ bzw. ab Stufe 5 „Zombie wurde vernichtet!“. Darunter stehen die Worte des Vertreibens, die EP und (nur beim Vernichten) Gold und Beute.

## v0.1.198 – 08.10.2026, 13:20

**Behoben**
- **Zustände bewegen sich mit:** Flammen, Dunst, Tropfen und die anderen Zustandsbilder blieben am Ruheplatz stehen, wenn der Gegner (oder der Held) zum Angriff vorsprang, auswich oder taumelte. Jetzt werden sie mit der Figur selbst gezeichnet und gehen jede Bewegung mit.

## v0.1.197 – 08.10.2026, 13:13

**Neu – Testreiter**
- Schalter „Gegner bestehen keine Rettungswürfe“: Solange er an ist, misslingt jeder Rettungswurf eines Gegners gegen die Zauber des Helden. So lassen sich Untote vertreiben (unter Stufe 5: Flucht) und Untote zerstören (ab Stufe 5: Zerfall zu Staub) gezielt testen, ebenso Heilige Flamme und Co. Die Stufe lässt sich im Testreiter mit −1/+1 einstellen.

## v0.1.196 – 08.10.2026, 13:07

**Behoben**
- **Tödlicher Treffer mit „Das ist sehr effektiv!“:** Traf ein Zauber oder Schlag eine Schwäche des Gegners (etwa die Heilige Flamme ein Skelett), stand der Hinweis als eigene Zeile zwischen Treffer und Sturz. Dadurch kam der Text, während der Gegner noch taumelte. Der Hinweis steht jetzt in der Trefferzeile, der tödliche Treffer läuft wieder ohne Text bis zum Sturz durch. Ein neuer Test prüft das für alle Klassen und Gegner.

## v0.1.195 – 08.10.2026, 12:50

**Behoben**
- **Spirituelle Waffe:** Beim Herbeirufen sah es aus, als würde die Waffe schon zuschlagen, und danach schlug sie noch einmal zu. Jetzt nimmt sie beim Herbeirufen neben dem Helden Gestalt an und schwebt dort; zuschlagen tut sie erst danach, und „Die spirituelle Waffe schlägt zu!“ steht mit Treffer und Schaden in einer Zeile.

**Neu – Testreiter**
- Knopf „Alle Vorräte auf mindestens 10“: füllt Tränke, Flaschen, Essen und Zutaten auf je mindestens 10 auf (keine Schlüssel).

## v0.1.194 – 08.10.2026, 12:42

**Neu – Fähigkeits-Effekte im düsteren Stil**
- **Magier:** Feuerpfeil mit glühendem Kopf, Flammenspur, Rauch und kurz haftenden Flammen; Magisches Geschoss als drei kalt-violette Kraftsplitter; Sengender Strahl flackernd mit Hitzeflimmern und Glut; Magierrüstung als Runenschleier mit Schimmer. Beim Zaubern blitzt nicht mehr der ganze Bildschirm weiß.
- **Feuerball:** brodelnde Feuermasse mit Rauchspur statt Kugel mit Ringen; Explosion aus Flammenwolken, die zu Rauch dunkeln, brennender Boden, Rauchsäule.
- **Kleriker:** Heilen und Heiltränke als warmes, goldenes Licht statt grünem Kreis; Segnen als Lichteinfall von oben mit Sonnenzeichen statt Heiligenschein; Untote vertreiben als Lichtwelle über den Boden; Spirituelle Waffe als Geister-Streitkolben mit Nachbildern; Geisterwächter als kreisende Geistgestalten.
- **Wurfgegenstände:** Flaschen aus Glas, die im Bogen fliegen und in Scherben zerspringen; Alchemistenfeuer spritzt brennend und haftet, Weihwasser spritzt und zischt zu Dampf.

**Neu – Zustände am Körper**
- Solange ein Zustand anhält, ist er an Held und Gegner zu sehen: Brennend (Flammen am Umriss und an den Füßen), Vergiftet (grünlicher Dunst), Blutend (Tropfen und Lache, nach Blutstufe), Betäubt (Schwanken), Verlangsamt (Reif, langsamere Ruhebewegung), Geschwächt (violetter Schleier), Geblendet (Restlicht vor den Augen).

**Behoben**
- **Tasche und Laden:** Nach dem Anlegen eines Gegenstands verrutschten die Bilder um eine Zeile (der Glutstab zeigte eine Armbrust). Jede Zeile zeigt jetzt ihr eigenes Bild.

**Neu – flüssigere Kämpfe**
- **Eine Aktion ist ein Stück:** Nach der Wahl läuft die ganze Bewegung (Ausholen, Schlag, Treffer oder Fehlschlag), und erst mit dem Aufprall erscheint der Text, alles in einer Zeile: „Alrik greift mit Kampfstab an! Krogg erleidet 8 Schaden.“ Zwischenworte wie „kritischer Treffer“ oder „Überraschungsschlag“ stehen in derselben Zeile.
- **Zwei Tipper pro Runde statt vier:** Jede Ergebniszeile (deine und die des Gegners) wartet auf ein Tippen; was dazwischen liegt (Ausholen, Schlag, der Gegner holt aus und schlägt), läuft von selbst. Im Menü lässt sich „Kampftext: weiter automatisch“ einstellen: dann geht es nach einer Lesepause von selbst weiter, Tippen beschleunigt; das Kampfende (tödlicher Schlag, Sturz, Beute) wartet immer auf ein Tippen.
- **Kampftempo** im Menü: Ruhig, Normal, Schnell (Textgeschwindigkeit und Lesepausen).
- **Angriffe, Zauber und Würfe etwas langsamer**, passend zu den ruhigeren Bewegungen.

**Neu – Kampfende am Stück**
- **Sieg:** Nach dem tödlichen Schlag läuft alles ohne Tippen durch: Der Gegner stürzt und bleibt liegen (bis zum Ende des Kampfbildschirms), der Held geht in seine Siegpose, dann kommt das **Siegesfeld** mit EP, Gold und Beute auf einen Blick (Beute in Seltenheitsfarbe). Ein Stufenaufstieg mit neuen Fähigkeiten bekommt ein eigenes Feld.
- **Der tödliche Treffer läuft ohne Text durch:** Schlag oder Zauber, Taumeln und Sturz gehen ohne Unterbrechung ineinander über; die Trefferzeile („… erleidet 9 Schaden.“) steht dann oben im Siegesfeld, bei einer Niederlage zusammen mit dem Sturz des Helden.
- **Niederlage:** Der Held stürzt in drei Varianten (vornüber, zur Seite geworfen, auf ein Knie und seitlich um) und bleibt liegen; die Waffe sinkt neben ihn zu Boden. Erst wenn er liegt, kommt der Text (auch wenn der Sturz noch nicht vorgerechnet war).

**Neu – Untote zerstören (SRD)**
- Ab Klerikerstufe 5 zerfallen schwache Untote (Herausforderungsgrad ½ oder weniger, also Skelett und Zombie) bei misslungenem Rettungswurf gegen „Untote vertreiben“ zu Staub, statt zu fliehen: Sie glühen im heiligen Licht weiß auf und zerfallen zu Asche und Glut. Das zählt als Sieg mit Gold und Beute. Stärkere Untote (Ghul) fliehen weiterhin, dann ohne Gold und Beute.

**Geändert – Heiliger Strahl**
- Statt eines geraden, unten hart abgeschnittenen Lichtbands senkt sich das Licht von oben auf den Gegner, wird nach unten schmaler und weicher, und am Boden schlagen weiß-goldene Flammenzungen um seine Füße hoch, mit Lichtschein am Boden und aufsteigender Glut. Weicht der Gegner aus, schlägt die Flamme neben ihm am Boden ein.

**Behoben**
- **Untote vertreiben:** Der vertriebene Untote fiel tot um und blieb liegen, obwohl er laut Text flieht. Jetzt zuckt er im heiligen Licht zurück, weicht in die Ferne und verblasst; danach Siegpose und Siegesfeld.
- **Höhle, Nebel des Krieges:** Gegner in ihrem Lager (Krogg, Grak) waren auch ohne Sichtlinie zu sehen, und Lichtquellen (Lichtschacht, Fackeln, Feuer) leuchteten durch den Nebel in nie gesehene oder gerade nicht sichtbare Räume. Jetzt erscheinen solche Gegner nur, wenn der Held sie sieht; Lichter in nie gesehenen Bereichen bleiben dunkel, außer Sicht nur gedämpft.

**Neu – Trinken im Kampf**
- Der Held greift zur Gürteltasche, zieht den Korken und trinkt, in drei Varianten (ein langer Zug, zwei hastige Schlucke mit Blick zum Gegner, gierig trinken und die Flasche wegwerfen). Die Flasche ist rot für Heiltränke, grünlich für das Gegenmittel. Danach Heil-Leuchten und eine Zeile mit dem Ergebnis.

## v0.1.186 – 08.10.2026, 11:09

**Neu – Wildschwein und Riesenratte im neuen Stil**
- **Wildschwein:** schwerer, hoher Vorderleib unter einem Kamm aus Borsten, der sich im Zorn aufstellt, langer Keilkopf mit Rüsselscheibe, gebogene Hauer aus Unter- und Oberkiefer, kleine rot glühende Augen, dünne Beine auf Klauen, Schwanz mit Quaste. Drei Fellvarianten (fast schwarz, grau mit Narben, rostbraun mit zerfetztem Ohr), Größe 88–110 %.
- **Riesenratte:** groß wie ein Hund, gekrümmter Rücken, räudiges Fell mit wunden, verschorften Stellen, langer spitzer Kopf mit orangen Nagezähnen, rot glühende Knopfaugen, runde nackte Ohren (eines zerfetzt), rosa Krallenhände und ein langer, nackter, geringelter Schwanz, der über den Boden schleift. Drei Fellvarianten (braun, grau und räudig, schwarz), Größe 140–170 % einer gewöhnlichen.
- Je drei Angriffe: das Wildschwein stürmt an und reißt die Hauer hoch, schlitzt seitlich, rammt; die Ratte springt vor und beißt, springt an, nagt tief an den Beinen. Dazu je drei Treffer, Ausweichen und Stürze. Durch die echte Oberfläche gefilmt.
- Auf der Karte behalten beide vorerst ihre kleine Figur.

## v0.1.173 – 07.10.2026, 22:48

**Geändert – keine EP mehr ab Erreichen von Stufe 6**
- Ab Erreichen von Stufe 6, der Stufengrenze von Kapitel 1, gibt es keine weiteren EP mehr; die EP bleiben genau auf dem Wert für Stufe 6 stehen, es wird nichts für Kapitel 2 aufgehoben. Kämpfen lohnt sich weiter für Beute und Ausrüstung.
- Der Kampf nennt dann keine EP mehr, sondern „Höchststufe für Kapitel 1 erreicht – keine weiteren EP in diesem Kapitel. Beute und Ausrüstung gibt es weiterhin.“ Ebenso der Heldenreiter.
- Bei älteren Spielständen werden schon aufgehobene EP beim Laden auf die Grenze gekürzt.

## v0.1.172 – 07.10.2026, 22:38

**Neu – Kobold, Zombie, Krogg und Grak im neuen Stil**
- **Kobold** (SRD: klein, etwa 72–88 cm): kleiner Drachenkopf mit weit offenem Rachen voller Nadelzähne, zurückgebogenen Hörnern, Stachelkamm und glühenden Schlitzaugen; Schuppen in Rostrot, Ocker, Ziegel oder Umbra, Klauenfüße und langer Schwanz. Drei Ausrüstungen: Speer mit Lederkappe, Speer mit grobem Schild, Dolch mit Fellumhang. Auch die Kobolde im Rudel.
- **Zombie**: ausgezehrt, graugrün bis fleckig violett, zerrissene, verschmierte Kleidung mit Löchern bis aufs Fleisch, strähnige Haarreste, herabhängender Unterkiefer mit gebrochenen Zähnen, freiliegender Wangenknochen, altes Blut am Kinn. Drei Ausrüstungen: Lumpen, verrottetes Lederwams, alter Soldat mit rostigem Kettenhemd und Helm.
- **Krogg der Grobian** (SRD-Grottenschrat, etwa 2,10 m): Bärenkopf mit gefletschten Reißzähnen, glühend roten Augen und Krallennarben, zottiges Fell, Mähne, Fellumhang und ein neuer **Morgenstern** mit Stachelkopf.
- **Hauptmann Grak** (Hobgoblin): rötliche Haut, flaches Gesicht mit langen Hauern, schwarzer Kriegsbemalung und Narbe, Kriegerzopf, Halbplatte, roter Hauptmannsumhang und die Streitaxt beidhändig.
- Alle bewegen sich in je drei Varianten (Angriff, Treffer, Ausweichen, Sterben), jeder in seiner Art: der Kobold geduckt mit vorgestreckter Schnauze, der Zombie schlaff mit hängendem Kopf, Krogg mit gebeugten Schultern, Grak aufrecht und gedrillt. Kollisionsprüfung: 0 Durchdringungen in 13 364 Bildern aller Gegner.
- Krogg und Grak sind feste Bosse und sehen immer gleich aus; die übrigen variieren in Haut, Statur, Größe und Ausrüstung.
- Neu als Waffe nach SRD: der Morgenstern (1W8 Stich), auch als Beute.
- Der Schwanz des Kobolds liegt beim Sturz entlang der Beine statt in den Himmel oder in den Boden zu zeigen.

**Behoben – Gegner täuschte den Schlag an**
- Kam zwischen dem Ausholen des Gegners und seinem Schlag eine Meldung (etwa „Ein brutaler Überraschungsschlag!“ oder „Ein kritischer Treffer!“), ging er dabei zurück in die Ruhe und schlug erst danach zu. Jetzt hält er das Ausholen, bis der Schlag trifft oder verfehlt. Mit Krogg gegen den Kleriker nachgefilmt.
- Alle Gegner mit allen Klassen und allen Aktionen (Angriff, Abwehr, Fähigkeiten, Tränke, Wurfflaschen, Elite-Eigenschaften) automatisch durchgespielt: Jedes Ausholen, ob von Held, Gegner oder Rudel, endet jetzt in einem Treffer oder Fehlschlag. Ein neuer Test hält das fest.
- Einziger weiterer Fall war der Fluch des Goblin-Schamanen: Er holte aus, und es kam nur Text. Jetzt lässt er den Fluch sichtbar los; widersteht der Held, weicht er ihm aus.

## v0.1.168 – 07.10.2026, 22:00

**Behoben – gehaltene Haltungen fielen in die Ruhe zurück**
- Ausholen, Abwehr, Zauber sammeln und Wurf bleiben jetzt stehen, bis die nächste Meldung sie auflöst. Seit den ruhigeren Bewegungen sprang die Figur nach dem Ende einer Bewegung durch einen Rechenfehler (Zahlenüberlauf) aufs erste Bild zurück, also in die Ruhe: Der Held holte aus, stand wieder ruhig da und schlug erst mit der nächsten Meldung zu; die Abwehr sank vor dem Zug des Gegners. Mit der echten Oberfläche in Echtzeit nachgefilmt (Kleriker, Kämpfer, Magier, Schurke; Angriff und Abwehr).
- Zusätzlich werden Abwehr und Treffer nach einer Verwundung früher neu gezeichnet, und eine gehaltene Haltung fällt auch dann nicht in die Ruhe, wenn ihr Bild noch fehlt.

**Behoben – Konter wirkte wie zwei Angriffe**
- „… nutzt die Lücke!“ kam zwischen Ausholen und Schlag. Jetzt kommt die Ansage zuerst, dann Ausholen und Schlag in einem Zug. Ebenso bei Feuerpfeil und Sengenden Strahlen.

## v0.1.159 – 07.10.2026, 20:45

**Behoben**
- Der Dialog einer vielseitigen Waffe zeigte immer den Einhand-Schaden, auch wenn der Schild abgelegt war und die Waffe beidhändig geführt wird. Jetzt steht oben der Schaden, der gerade gilt (z. B. „1W8 Wucht (beide Hände)“), darunter der andere Fall.

## v0.1.158 – 07.10.2026, 20:38

**Behoben**
- Wurde der Held in Abwehrhaltung trotzdem getroffen, ließ er die Deckung fallen und stand in Ruhehaltung, obwohl die Abwehr bis zu seinem nächsten Zug gilt. Jetzt bleibt er in Deckung; der Treffer zeigt sich am Aufblitzen.

## v0.1.157 – 07.10.2026, 20:31

**Verbessert – Vorräte im neuen Stil**
- Alle Vorräte haben jetzt räumliche Bilder wie die Ausrüstung, jedes sein eigenes: Heiltrank (rund, rot), Großer Heiltrank (rosé, Goldband), Überragender Heiltrank (hoch, violett, vergoldete Kappe), Kräutertrank (grün, mit Kräuterzweig), Alchemistenfeuer (glühend orange, Lumpen als Docht), Weihwasser (schlanke Phiole mit goldener Sonne), rohes und gebratenes Fleisch, Heilkräuterbund, Wolfsfell, Keilerhauer, Giftdrüse, Fledermausflügel, rostiger Schlüssel, Sonnenamulett und versiegelter Brief. Die Tränke zeigen Glas mit Flüssigkeitsstand.
- Gilt überall: Tasche, Laden, Brauen bei Hedda, Gegenstände im Kampf und die Dialoge.
- Die Bilder werden beim Start im Hintergrund vorbereitet, damit Listen sofort vollständig erscheinen.

## v0.1.156 – 07.10.2026, 20:25

**Neu – Gegenstände vergleichen**
- Im Dialog eines Gegenstands aus der Tasche steht eine Tabelle „Angelegt | Neu“ mit allem, was sich beim Anlegen ändert: Rüstungsklasse, Angriff, Schaden (mit Durchschnitt), Trefferpunkte, bei Zauberern Zauberangriff und Zauberpunkte, jedes Attribut und jede weitere Eigenschaft (Krit, Schadensreduktion, Gift, Lebensraub, Goldfund …) beider Stücke. Gewinne grün, Verluste rot.
- Boni, die eine Obergrenze des Kapitels verschluckt, werden benannt („Bonus wirkt nicht: Obergrenze für dieses Kapitel erreicht“), statt stillschweigend zu fehlen.
- Ganz oben das Urteil in einem Satz („Besser: …“, „Schlechter: …“, „Gemischt: mehr …, aber weniger …“) und was dafür abgelegt wird, bei Zweihändern auch der Schild (rot).
- Der grüne oder rote Pfeil in der Tasche kommt aus derselben Rechnung; bei gemischten Stücken steht keiner.

**Behoben**
- Der Rundschild schnitt beim Drehen der Figur (Ausrüstungsbild) in Bauch und Hüfte. Er hält jetzt Abstand zum Rumpf, mit Platz für die Rüstung.

## v0.1.155 – 07.10.2026, 20:07

**Neu – vielseitige Waffen (SRD)**
- Kampfstab und Speer (1W6 → 1W8), Langschwert, Streitaxt und Kriegshammer (1W8 → 1W10) machen mehr Schaden, wenn die andere Hand leer ist, also ohne Schild, Zweitwaffe oder Fokus. Der Held führt sie dann sichtbar mit beiden Händen. Wer den Schild behält, hat dafür die bessere Rüstungsklasse.
- Im Dialog steht „Vielseitig: eine oder beide Hände“ und der Schaden mit beiden Händen; in der Liste beide Würfel, z. B. „1W6/1W8 Wucht“.

**Verbessert**
- **Tasche und Laden ohne Dopplungen:** Unter dem Namen stehen nur noch Art (wenn der Name sie nicht schon nennt), Platz und der wichtigste Wert, z. B. „Topfhelm · Kopf“ bei „Eisenbrecher“ oder „Plattenpanzer +2 · Oberkörper · RK 20“. Seltenheit und Zweihändigkeit zeigt das Symbol.
- **Gegenstandsdialog:** Seltenheit nur einmal in Worten (und gar nicht, wenn der Name sie schon trägt), eine Zeile zum Tragen („Haupt- oder Nebenhand“, rot „Beide Hände“), der doppelte Satz zur Händigkeit ist weg.
- **Symbole besser lesbar:** Bögen stärker gekrümmt und kräftiger, der Kristall des Magierstabs groß und leuchtend, Streitkolben, Kriegshammer und Handbeil mit größerem Kopf.

## v0.1.154 – 07.10.2026, 19:49

**Neu – der Held als bewegliche Figur**
- In Wald und Höhle kämpft der Held als neu gezeichnete Figur, von hinten über die Schulter gesehen: Zu Beginn wendet er sich dem Spieler zu und dreht sich dann zum Gegner, im Hinterhalt wird er nach vorn geworfen.
- Echte Bewegungen statt Standbilder: Hieb, Stich und Überkopfschlag im Wechsel mit gleichbleibendem Griff, Bogenschuss mit Auflegen, Ausziehen und Lösen, Armbrust an der Schulter, Zauber je nach Stab, Zauberstab, Buch, Kugel oder Heiligensymbol mit Leuchten, Treffer, Sieg.
- Der Kleriker startet mit mannshohem Kampfstab und Rundschild mit goldener Sonne statt Streitkolben und Wappenschild; Rundschilde gibt es auch als Beute (gleiche Werte wie der Schild). Mit Stab und Schild blockt er mit dem Schild, der Stab bleibt aufrecht stehen, und Flaschen wirft er mit der Schildhand.
- Der Wappenrock des Klerikers trägt die goldene Sonne auf Brust und Rücken. Alte Spielstände: unveränderter Streitkolben und Schild eines Klerikers werden beim Laden zu Kampfstab und Rundschild; verbesserte oder gefundene Stücke bleiben.
- Neue Liste [Offen](docs/OFFEN.md): was gerade in Arbeit, zu testen oder zu entscheiden ist.
- Die Heldenfigur steht in Menüs, Ausrüstungsbild, Titelbild und Spielständen mittig und wird für jedes Volk gleich groß gezeichnet, so ist auch ein Halbling gut zu sehen. Bei der Erstellung bleibt sie maßstabsgetreu (Halbling klein, Halbork groß), steht aber ebenfalls mittig.
- Wunden nach Blutstufe: Bei „Dezent“ zeigen Held und Gegner nur leichte Wunden, bei „Deutlich“ die vollen.
- Aus der Abwehrhaltung gehen Schild oder Waffe erst fließend herunter, dann beginnt die nächste Bewegung (Angriff, Zauber, Wurf, Trank); bei einem Treffer bricht die Abwehr schneller. Erneute Abwehr hält die Haltung einfach.
- Auch in Testkämpfen im Dorf und in den Häusern kämpft der Held als neue Figur, dort mit kurzem Schritt nach vorn.
- Heldenerstellung: Figur und Werte bleiben oben stehen, nur die Eingaben darunter scrollen.
- Auf der Karte trägt der Kleriker den Rundschild: hell mit goldener Sonne, von hinten Holz.
- Heilige Flamme ist auch zu sehen, wenn der Gegner ausweicht: Sie schlägt neben ihm ein, während er zur Seite springt, mit ihrem Klang. Bisher sah man dann nur das Ausweichen, als wäre der Zauber ausgeblieben.
- Auf der Karte trägt der Kampfstab des Klerikers Eisenkappen statt des Kristalls vom Magierstab.
- Neue [Stil-Leitlinien](docs/STIL.md) für alle künftigen Arbeiten: erwachsener und düsterer, bessere Übergänge, Kollisionen selbst prüfen, Klänge ohne Chiptune.
- **Goblins, Goblin-Späher und Skelette im neuen Stil:** gebaut auf der Puppe des Helden, dem Helden zugewandt, im Licht der Szene. Jeder Gegner sieht anders aus: je drei Ausrüstungen nach SRD (z. B. Krummsäbel mit grobem Holzschild, Handbeil, Säbel und Dolch; Kurzschwert mit rostigem Helm, Speer), dazu Hautton, Größe und Körperbau im Rahmen des SRD. Rostiges Eisen und grobe Schilde sind reine Optik, die Werte bleiben.
- Ihre Bewegungen in je drei Varianten: Angriff passend zur Waffe (Hieb, Überkopfschlag, Stich; Speer hoch, tief, von oben; Bogen stehend, kniend, schnell; Säbel und Dolch), Treffer, Ausweichen oder Schildblock und Sterben: Sie stürzen vornüber aufs Gesicht, fallen rücklings oder kippen zur Seite und bleiben liegen, bevor sie ausblenden. Alle Abläufe sind auf Durchdringungen geprüft.
- Der Kampftext nennt die Waffe, die der Gegner wirklich trägt (z. B. „Handbeil“, „Speer“).
- Goblins und Skelette treten mit dem Schlag an den Helden heran: Während der Ansage holen sie aus und beginnen den Schritt, mit dem Ergebnis landet die Waffe am Helden, dann treten sie zurück. Goblin-Späher schießen vom Platz.
- Der Speer ist jetzt ein echter Körper statt einer flachen Zeichnung: runder Eschenschaft, eiserne Tülle mit Lederbindung, blattförmige Spitze mit Mittelgrat, Eisenschuh am Ende. Beim Stoß zeigt er schräg nach unten auf den Helden statt quer übers Bild. Gilt auch für Helden mit Speer; wird es hinter der Hand eng, greift die Hand weiter hinten am Schaft, damit das Ende nicht durch den Körper geht.
- Alle Nahkampfwaffen sind jetzt echte Körper statt flacher Zeichnungen, bei Held und Gegnern: Dolch, Kurzschwert, Krummsäbel, Rapier (mit Korb und Bügel), Langschwert, Bihänder (mit Parierhaken), Handbeil, Streitaxt, Großaxt (Doppelblatt), Streitkolben (sechs Flansche), Kriegshammer (Schlagfläche, Dorn, Spitze), Schlägel und Hellebarde (Spitze, Beil, Haken). Klingen haben Schneide, Hohlkehle, Parierstange und Knauf. Damit sie in Kampfgröße lesbar bleiben, sind Klingen und Köpfe etwas breiter als echt, und die Waffe dreht sich leicht in der Faust, um ihre Breitseite zu zeigen. Rostiges Eisen der Gegner ist grauer Stahl mit Rostflecken.
- Speerkampf mit zwei echten Stößen statt Hieben: von unten aus der Hüfte, waagerecht nach vorn (bei Gegnern auch tief auf die Beine), und über Kopf wie ein Speerwerfer, die Hand über der Schulter, die Spitze nach vorn leicht unten. Gilt für Helden und Skelette.
- Die Kollisionsprüfung umfasst jetzt die ganze Waffe mit Parierstange, Knauf, Axtblatt und Kopf. Wo ein Knauf in den Körper ragen würde, greift die Hand weiter hinten am Griff; bei beidhändigen Stichen gehen die Hände etwas nach vorn.
- **Wölfe als räumliche Vierbeiner:** tiefe Brust, zottiges Fell mit dunklem Sattel, Halskrause, buschige Rute, Läufe mit echten Gelenken. Im Kampf mit gefletschten Lefzen, großen Fangzähnen, gekräuseltem Nasenrücken und finsteren Brauen. Jeder Wolf etwas anders groß (92–108 %) und im Fell verschieden (grau, dunkel, rostrot, aschfahl, selten schimmernd), mit Narben und eingerissenen Ohren. Grimmzahn ist als Schreckenswolf anderthalbmal so groß, schwarz, mit roten Augen.
- Wölfe bewegen sich in je drei Varianten: Biss aus dem Knurren, Sprung auf den Helden, tiefer Biss nach den Beinen mit Reißen; Treffer (Kopf hochgerissen, Wegdrehen, Einknicken), Ausweichen (Satz zur Seite, Ducken, Zurückspringen) und Sterben (auf die Seite fallen, nach vorn zusammenbrechen, sich aufbäumen und umkippen). Dazu Ruheatmen und Heulen. Ihre Bisse erreichen den Helden. Schwer verletzte Wölfe lassen Kopf und Ohren hängen und schonen eine Vorderpfote.
- **Testmodus, Kampf auslösen:** Die Eröffnung ist wählbar (normal, Hinterhalt mit dem Gegner zuerst, Held zuerst). Die Waffe des Helden lässt sich aus allen Waffen sofort ausrüsten, die andere Hand mit Schild, Rundschild, Dolch oder leer. Goblin, Goblin-Späher und Skelett lassen sich mit einer bestimmten Ausrüstung rufen (z. B. „Speer, Helm“).
- Abwehr nach Gegner: gegen Wölfe und anderes Getier mit tiefem Schild oder tiefer Zweihandparade, gegen große Gegner hoch; beim Zweihänder stützt der freie Unterarm die Waffe am Kopf ab.
- Jede Waffe in wahrer Größe, Kleidung und Rüstung in Schichten, Umhang fällt über Rücken und schwingt nach. Schwungsound beim Schlag.
- Bei der Heldenerschaffung wählbar: Geschlecht, Statur, Haut- und Haarton je Volk, mit drehender Vorschau. Die Körpergrößen folgen dem SRD (Halbling 60 % eines Menschen).
- Im Ausrüstungsmenü steht der Held als drehende Figur zwischen den Ausrüstungsplätzen und zeigt alles, was er trägt.
- Bestehende Spielstände laden weiter; ihr Held bekommt einen festen Haut- und Haarton.

**Neu – Abwehr im Kampf**
- „Kämpfen“ öffnet jetzt „Angreifen“ und „Abwehr“. In Abwehrhaltung (nach SRD „Ausweichen“) greift der Gegner bis zum nächsten Zug mit Nachteil an, Geschicklichkeitsrettungswürfe haben Vorteil. Verfehlt er, bietet sich ein Konter: der nächste Angriff hat Vorteil.
- Jeder Angriff ist zu sehen, auch ein verfehlter: Pfeile, Bolzen und Zauber fliegen am Ziel vorbei. Ansage mit Ausholen, dann Schlag mit Treffer oder Fehlschlag – beim Helden wie bei den Gegnern.

**Verbessert**
- **Ausrüstungssymbole wie die 3D-Modelle:** In Ausrüstungsplätzen, Tasche, Laden und Dialogen ist jedes Stück aus denselben Körpern gebaut, mit denen der Held es trägt. So sieht der Kampfstab aus wie in der Hand, Schilde, Helme, Rüstungen, Stiefel und Umhänge wie an der Figur. Lange Waffen (Speer, Hellebarde, Stäbe) sind groß gezeigt, ihr Schaft läuft aus dem Bild. Die Armbrust liegt gespannt und geladen schräg im Bild. Ringe, Amulette, Stirnreif und Heiligensymbol sind neu in 3D gebaut, ihr Stein in der Farbe der Seltenheit.
- Die Seltenheit zeigt ein Zeichen unten rechts: ein farbiger Stein pro Stufe über gewöhnlich (ungewöhnlich 1 bis göttlich 5). Das „2H“ der Zweihänder steht jetzt oben rechts.
- Bewegungen im Kampf laufen ruhiger, die Schläge selbst bleiben so schnell wie bisher: Treffer-Reaktionen, Ausweichen und Schildblock von Held und Gegnern, der Schritt zurück nach einem Schlag, das Taumeln im Hinterhalt, die Drehung zu Kampfbeginn und das Einnehmen der Abwehrhaltung.
- Neue Klänge, wenn ein Angriff abgewehrt wird oder danebengeht: statt eines hellen „Ping“ wie von einer alten Ladenkasse ein dumpfes „Klonk“ auf Schild oder Klinge, und beim Fehlschlag nur ein Luftzug („Wusch“). Je drei verschiedene Varianten, die zufällig wechseln: bei der Abwehr Klonk, hölzernes Pochen und kurzes Klirren von Klinge auf Klinge; beim Fehlschlag voller Luftzug, kurzes Zischen und schwerer, tiefer Luftzug.

**Behoben**
- Im Hinterhalt hatte sich der Held schon zum Gegner umgedreht, bevor dieser zuschlug. Jetzt steht er noch ahnungslos dem Spieler zugewandt, der Schlag trifft ihn von hinten, er taumelt nach vorn und dreht sich erst dann zum Gegner. Fällt er schon durch diesen Schlag, bleibt er im Taumeln.
- Beim tödlichen Treffer knickte ein Gegner erst mit der Trefferbewegung ein, stand wieder auf und brach dann mit dem Sturz ein zweites Mal zusammen. Jetzt taumelt er mit dem tödlichen Treffer, bleibt so, und fällt mit „besiegt“ in einem Zug zu Boden (Goblins, Skelette, Wölfe).
- Ein besiegter Gegner konnte stehend ausblenden, ohne zu fallen: wenn man nach „besiegt“ zügig weitertippte, oder wenn die Sturzbilder noch nicht berechnet waren. Jetzt wartet die nächste Meldung, bis der Sturz zu Ende gespielt ist, und der Sturz beginnt erst, wenn seine Bilder fertig sind (sie werden gleich nach dem ersten Ruhebild vorbereitet, fehlende sofort berechnet).
- Der doppelte Zusammenbruch kam vor allem daher, dass zu Beginn jeder Meldung kurz das Endbild der Bewegung gezeigt wurde (bei Zaubern wie der Heiligen Flamme sogar länger): erst eingeknickt, dann von vorn stehend und wieder einknickend. Jetzt bleibt der Gegner bis zum Start im vorigen Bild. Ebenso springt ein Gegner zwischen Ausholen und Schlag (etwa während ein Pfeil fliegt) nicht mehr kurz in die Ruhehaltung.
- In kurzen Kämpfen waren die Sturzbilder oft noch nicht fertig berechnet, sodass der Gegner beim Sturz zwischen Stehen und Fallen sprang. Jetzt wird gleich nach den Ruhebildern der Sturz vorbereitet, und zwar nur die eine Variante, die der Gegner nutzt; beim Wolf auch nicht mehr neu für jede Verwundungsstufe.
- Goblins, Skelette und Wölfe wurden im Kampf etwas gestaucht und versetzt gezeichnet, weil ihr Bild (mit Platz für Ausfallschritt und Biss) breiter als die Szene ist. Dadurch saßen Treffer, Zauber, Funkeln und Schimmer nicht genau auf dem Körper. Jetzt werden sie in voller Größe gezeichnet, und alle Effekte landen auf dem Gegner; das Schimmerband läuft nur noch über den Körper.
- Beim schimmernden Wolf (und schimmernden Goblins und Skeletten) funkelte es weit links am Bildrand statt am Tier. Das Funkeln sitzt jetzt um den Körper.
- Überraschte der Held einen Gegner von hinten (Erstschlag), sprang er schon bei der Ansage zum Angriff vor, noch bevor man Angreifen oder Abwehr wählen konnte. Jetzt wartet er in Ruhehaltung, und erst die Wahl löst die passende Bewegung aus.

## v0.1.63 – 06.10.2026, 15:20

**Neu – Kapitel 1 in neuem Gewand**
- Alle Karten sehen erwachsener und etwas düsterer aus: moosiges Gras, dunkleres Laub, erdige Wege, dunkles Wasser, gedämpfte Dächer, verwitterte Wände.
- Neue Bäume: lichte, klumpige Kronen mit Schatten darunter, Rinde und Wurzeln, Tannen in Stufen. Im Tiefen Flüsterwald stehen knorrige alte Bäume mit hängendem Moos.
- Mehr Leben am Boden: Farne, Pilze und Laub unter den Bäumen, hohes Gras mit natürlichen Rändern und Samenständen, locker verstreute Blumen, Seerosen und Schilf an den Waldteichen.
- Licht wie in den Kämpfen auf allen Karten: Schatten unter dichtem Laub mit Lichtflecken, der Tiefe Flüsterwald deutlich dunkler, warme Abende und kalte, dunkle Nächte. Nachts leuchten Lagerfeuer, Straßenlaternen und Fenster, deren Licht vor die Häuser fällt. Im Wald trägt der Held eine Laterne. In Häusern brennen Kerzen auf Tischen, Theke und Altar, tagsüber fällt Licht durch die Tür.
- Der Nebel über Unerkundetem geht weich in das Licht über.

**Karte und Kampf passen zusammen – auch im Wald**
- Neu in beiden Wäldern: umgestürzte, bemooste Baumstämme und Steinkreise aus alten Menhiren.
- Der Kampfort ergibt sich jetzt aus dem, was in der Nähe steht: am Teich der Teich, beim Steinkreis der Steinkreis, beim Stamm der umgestürzte Baum, bei Felsen die Felsen, zwischen vielen Bäumen der Waldrand, sonst eine Lichtung.

## v0.1.61 – 06.10.2026, 14:35

**Neu – die Blutzahnhöhle lebt**
- Die Höhle ist jetzt dunkel und wird von dem beleuchtet, was darin steht: Fackeln, das Lagerfeuer der Goblins, leuchtende Pilze, violette Kristalle, ein Lichtstrahl durch einen Deckenriss und das Tageslicht am Ausgang. Felswände halten das Licht auf, und die Laterne des Helden leuchtet die nähere Umgebung aus.
- Jeder Raum hat einen eigenen Charakter: Graks Halle mit Fackeln und Tropfsteinen, ein Pilzraum mit Kristallen, ein unterirdischer See, Kroggs Höhle im Lichtstrahl mit Knochen und Geröll, ein Goblinlager mit Feuer, Schlaffellen und Kisten, ein Mittelgang mit alten Holzstützen.
- Fackeln und Feuer flackern und sprühen Funken, Pilze pulsieren und verlieren Sporen, im Lichtstrahl tanzt Staub, von der Decke fallen Tropfen. Am Lagerfeuer knistert es.
- **Karte und Kampf passen zusammen:** Wo du kämpfst, siehst du denselben Ort: am See den See, im Pilzraum das Pilzlicht, bei Krogg den Lichtstrahl, im Lager das Feuer, im dunklen Gang nur die Laterne.

**Verbessert**
- Der Nebel über unerkundeten und nicht sichtbaren Bereichen hat weichere Kanten.

## v0.1.59 – 06.10.2026, 14:02

**Behoben**
- Am unterirdischen See sah es aus, als flösse das Wasser in den dunklen Gang hinein. Der Gang liegt jetzt neben dem See.

## v0.1.58 – 06.10.2026, 13:58

**Neu – Höhlenkämpfe im neuen Stil**
- Kämpfe in der Blutzahnhöhle haben eine neue Kulisse mit durchgehendem Felsboden, Tropfsteinen, Geröll und einem Gang, der ins Dunkel führt.
- Fünf Orte je nach Stelle auf der Karte: der Höhleneingang mit Blick nach draußen (nachts mit Sternenhimmel), enge Stollen mit alten Holzstützen, große Hallen mit Säulen, ein unterirdischer See, der die Höhle spiegelt, und ein Lager mit Feuer und Kisten.
- Vier Lichtstimmungen: Fackeln, leuchtende Pilze und Kristalle, ein Lichtstrahl durch einen Deckenriss und fast völlige Dunkelheit, in der nur das Lagerfeuer oder die Laterne des Helden leuchtet. Das Licht fällt wirklich auf Felsen und Boden.
- Gegner und Held stehen im Licht des Ortes: warm bei Fackeln, kalt-türkis bei den Pilzen, dunkler in der Finsternis.

## v0.1.56 – 06.10.2026, 13:36

**Verbessert – Wolfsgeheul**
- Das Heulen klingt jetzt wie ein Wolf statt wie ein Gebläse: ein weicher, fast reiner Ton ohne Rauschen, der lauter wird, wenn er steigt, ungleichmäßig zittert und weich ausklingt. Dazu kommt ein Nachhall wie im Wald.
- Die drei Varianten sind ein langes Heulen, ein kurzer Ruf mit längerem, höherem Heulen und ein tiefes, klagendes Heulen mit Stimmsprung.

## v0.1.54 – 06.10.2026, 13:04

**Neu – Wolfsgeheul**
- Wölfe heulen wieder, aber nicht jedes Mal: manchmal beim Auftauchen und manchmal, wenn ein Jungwolf fällt oder flieht. Der Kopf geht hoch, das Heulen hält und klingt wieder ab.
- Drei verschiedene Heul-Geräusche, zufällig gewählt: ein langes Auf und Ab, ein kurzes abgesetztes und ein tiefes, zitterndes, jeweils mit leisem Waldecho. Sie laufen über die Lautstärke für Effekte.

## v0.1.53 – 06.10.2026, 12:46

- Keine Änderungen im Spiel; nur interne Vorschau-Werkzeuge.

## v0.1.52 – 06.10.2026, 12:41

**Behoben**
- Griff ein Jungwolf an, biss der Leitwolf in der Animation mit zu. Jetzt holt nur der Jungwolf aus und beißt zu, wenn sein Treffer gemeldet wird; der Leitwolf bleibt ruhig. Gleiches gilt für Rudel im alten Stil (Kobolde, Goblin-Späher).

## v0.1.51 – 06.10.2026, 12:31

**Verbessert – flüssigere Bewegungen**
- Der Wolf hat deutlich mehr Zwischenbilder bei gleichem Tempo: 16 statt 6 beim Atmen, 17 statt 9 bei Biss und Sprung, doppelt so viele bei Heulen und Treffer-Reaktion.
- Alle Bilder eines Gegners und seines Rudels werden zu Kampfbeginn im Hintergrund vorbereitet (bei schwerer Verletzung erneut), damit beim ersten Angriff nichts mehr ruckelt.

## v0.1.50 – 06.10.2026, 12:22

**Behoben**
- Wunden, Elite-Leuchten und Schimmer verschwanden schlagartig, sobald ein Gegner auf 0 TP fiel. Sie bleiben jetzt beim Zusammenbrechen sichtbar und verblassen mit dem Gegner.

## v0.1.49 – 06.10.2026, 12:00

**Neu – Kämpfe in neuer Grafik (Schritt 1: Wald und Wolf)**
- Kämpfe im Flüsterwald und im Tiefen Flüsterwald spielen in neuen Szenen: durchgehender Boden mit Tiefe statt Plattformen, Waldrand, Berge im Dunst, Baumstämme und Laub als Rahmen, Lichtstrahlen.
- Sechs Arten von Orten: Lichtung, Waldrand, Teich, umgestürzter Baum, Felsen und alter Steinkreis – je nachdem, wo auf der Karte der Kampf beginnt (am Wasser am Teich, bei Felsen zwischen Felsen).
- Tag, Abend und Nacht mit eigenem Himmel, Licht und Farben; nachts Sterne, Mond und Glühwürmchen. Der Tiefe Wald ist dunkler, mit geschlossenem Blätterdach, Nebel und Pilzen.
- Der Wolf ist neu gezeichnet: größer, düsterer, mit vier Fellvarianten (grau, schwarz, rostbraun, aschgrau), Narben und eingerissenen Ohren. Grimmzahn ist größer, schwarz, mit roten Augen.
- Flüssigere Bewegungen mit vielen Zwischenbildern: atmen in Ruhe, zwei Angriffsarten (Biss und Sprungangriff), Heulen, wenn das Rudel angreift, Zurückzucken bei Treffern.
- Held und Gegner werfen Schatten; auch in Höhle und Dorf gibt es keine Plattformen mehr.
- Elite-Gegner im neuen Stil leuchten pulsierend entlang ihres Umrisses in der Farbe ihrer Eigenschaft. Schimmernde Wölfe haben silberblaues Fell, Glitzer um den Körper und einen Lichtschimmer, der regelmäßig über das Fell wandert.
- **Blut bei Treffern** (dezent), im Menü unter „System“ einstellbar: Aus, Dezent oder Deutlich (mit Spritzern am Boden). Skelette splittern, Untote verlieren dunkle Brühe, der Schleim spritzt.
- Man sieht, wie schwer ein Gegner verletzt ist: Je weniger Lebenspunkte er hat, desto mehr Blut spritzt bei Treffern. Unter der Hälfte zeigen sich Wunden am Körper, unter einem Viertel mehr davon, mit frischem Blut (Skelette bekommen Risse, Untote dunkle Flecken). Schwer verletzte Gegner atmen schneller; der Wolf lässt den Kopf hängen und schont eine Vorderpfote. Bei „Blut: Aus“ bleibt nur die Haltung.

## v0.1.41 – 06.10.2026, 07:49

**Verbessert**
- Die Leiste oben hat jetzt immer dieselbe Höhe, auch wenn Zustände wie Gift oder Satt dazukommen oder wegfallen. Die Karte springt dadurch nicht mehr.

## v0.1.40 – 06.10.2026, 07:43

**Geändert – Anzeige als feste Leiste**
- Lebens-, Zauber- und Erfahrungsbalken, Tag und Uhrzeit, Zustände und die Tasche sitzen jetzt in einer festen Leiste über der Karte. Sie überdeckt keinen Teil der Karte mehr, auch nicht am oberen Rand (z. B. am Höhleneingang).
- Die Karte scrollt dafür wieder nur bis zu ihrem Rand, ohne dunklen Streifen.

## v0.1.34 – 06.10.2026, 07:18

**Verbessert – mehr Sicht auf der Karte**
- Die Anzeige oben rechts ist deutlich flacher: Lebens-, Zauber- und Erfahrungsbalken links, Tag und Uhrzeit sowie offene Attributspunkte und Zustände rechts daneben, die Tasche etwas kleiner.
- Am oberen Kartenrand scrollt die Karte ein Feld weiter, sodass die oberste Reihe (z. B. der Schlagbaum oder der Höhleneingang) nicht mehr unter der Anzeige verschwindet.

## v0.1.33 – 06.10.2026, 07:03

**Behoben**
- Nach jedem Stufenaufstieg kam der Hinweis, Attributspunkte zu verteilen, auch wenn es gar keine gab. Er erscheint jetzt nur noch auf den Stufen mit neuen Punkten (4, 8, 12, 16, 19) und nennt die richtige Anzahl.
- Im Laden brach der gewählte Reiter („▶ Verkaufen“) in zwei Zeilen um. Der Pfeil vor gewählten Reitern und Knöpfen ist jetzt überall weg; die Auswahl zeigt einheitlich die gelbe Reiterfarbe.

**Geändert – Zaun am Schlagbaum**
- Statt eines langen Zauns quer durchs Dorf führt jetzt links und rechts vom Weg je ein kurzer Zaun vom Waldrand hinunter zum Schlagbaum. Der Norden des Dorfes bleibt offen.
- Wache Jorin geht seine Runde direkt vor dem Schlagbaum und ist dabei immer gut zu sehen. Vorher verschwand er zeitweise hinter den Dächern.
- Das Schild „Norden: Flüsterwald“ steht ein Feld rechts vom Zaun, frei neben dem Weg.

## v0.1.28 – 05.10.2026, 20:53

**Neu – Schlagbaum am Nordweg**
- Am Nordrand von Bornim sperren jetzt ein rot-weißer Schlagbaum und ein Dorfzaun den Weg in den Flüsterwald.
- Nach dem Gespräch mit Ältestem Aldric öffnet **Wache Jorin** den Schlagbaum, wenn du ihn ansprichst. Danach bleibt der Weg dauerhaft frei. Das Ziel im Menü weist darauf hin.
- Läufst du gegen den geschlossenen Schlagbaum, erfährst du, was fehlt.
- **Jorin geht Streife:** Er läuft am Zaun entlang, bleibt am Weg stehen und schaut nach Norden. Sprichst du ihn an, bleibt er stehen.
- Wer die Quest in einem bestehenden Spielstand schon hat, findet den Schlagbaum offen.

## v0.1.27 – 05.10.2026, 20:29

**Geändert – Namen mit Fantasy-Klang**
- Die Bewohner von Bornim tragen jetzt Namen, die besser in eine Fantasy-Welt passen:
  - Wirtin Berta → **Rowena**, Händlerin Tilda → **Thessa** („Thessas Kramladen“), Bruder Odo → **Bruder Osric**
  - Kräuterfrau Hedda → **Morwen**, Jäger Wilhelm → **Garrick**, Bauer Ludwig → **Bram**
  - Greta → **Gwenna**, Lene → **Liska**, das Dorfkind Finn → **Pim**
- Verschlossene Häuser: Bäcker Anton → **Edrik**, Schmied Bruno → **Dorran**; in der kleinen Hütte wohnt jetzt der **alte Kael**.
- Aldric, Jorin, Borin, Lyra und die Bosse behalten ihre Namen. Spielstände bleiben gültig.

## v0.1.26 – 05.10.2026, 20:10

**Neu – die Figur zeigt deine Ausrüstung**
- Dein Held sieht auf der Karte so aus, wie er ausgerüstet ist: Helm, Kapuze oder Reif, die Art der Rüstung (Stoff, Leder, Kette, Platte), Umhang, Waffe in der Hand (Schwert, Dolch, Axt, Streitkolben, Stab, Zauberstab, Bogen, Speer) und Schild.
- Höhere Seltenheit färbt Metall und Säume ein; wer etwas Episches oder Göttliches trägt, funkelt.
- Seitlich gehaltene Waffen zeigen nach vorn, statt das Gesicht zu verdecken.
- Gilt überall: auf der Karte, in der Spielstand-Übersicht, im Reiter „Held“ und schon bei der Charaktererstellung mit der Startausrüstung.

## v0.1.25 – 05.10.2026, 20:00

**Neu – drei Spielstand-Plätze**
- Bis zu drei Helden lassen sich parallel spielen.
- **Titelbild:** „Fortsetzen“ lädt den zuletzt gespielten Helden und zeigt Name und Stufe. Neu ist der Knopf **„Spielstände“** mit einer Übersicht aller Plätze: Held, Volk, Klasse, Stufe, Ort, Spieltag und Zeitpunkt des letzten Speicherns, dazu „Laden“ und „Löschen“ (mit Sicherheitsabfrage). Auf einem leeren Platz startet „Neues Spiel“ direkt dort.
- **Neues Spiel** belegt den ersten freien Platz. Sind alle drei belegt, wählst du, welcher Held ersetzt wird.
- Der bisherige Spielstand wird beim ersten Start automatisch auf Platz 1 übernommen.

**Sonstiges**
- Merkliste: Anmeldung mit Google Play (Cloud-Spielstände, Erfolge) samt Voraussetzungen ergänzt.

## v0.1.24 – 05.10.2026, 19:46

**Neu – Sicherheitsabfragen**
- **Wegwerfen** in der Tasche fragt nach und nennt, was ein Händler für den Gegenstand zahlen würde.
- **„Gewöhnliche verkaufen“** im Laden fragt nach und zeigt alle betroffenen Gegenstände samt Gesamterlös.
- **Neues Spiel** über einen vorhandenen Spielstand fragt immer nach, bevor der alte Held überschrieben wird (vorher geschah das ohne Warnung).
- Neue Einstellung **„Sicherheitsabfragen: An/Aus“** im System-Reiter (für Wegwerfen und Sammelverkauf; die Abfrage beim Überschreiben des Spielstands bleibt immer aktiv).

## v0.1.23 – 05.10.2026, 18:46

**Neu – ein schöneres Bornim (Teil 2)**
- **Ein Bach** fließt durch den Süden des Dorfs, mit runden Ufern und einer Holzbrücke an der Hauptstraße. Er ersetzt den eckigen Teich; Greta angelt jetzt am Bach.
- **Südlicher Dorfrand:** eingezäunter Gemüsegarten mit Kohl und Möhren, ein goldenes Getreidefeld, Heuballen und **Hühner**, die um die Ballen scharren.
- **Wäscheleine** mit bunter Wäsche bei Gretas Haus.
- **Zwei neue Bewohner:** Bauer Ludwig an seinem Feld und Lene an der Wäscheleine, jeweils mit eigenen Sätzen vor und nach dem Ende von Kapitel 1.
- Felder, Beete, Heuballen und Wäsche lassen sich ansehen.
- Wasser hat jetzt überall runde Ufer statt eckiger Kanten (auch im Wald).

## v0.1.22 – 05.10.2026, 18:41

**Neu – ein schöneres Bornim (Teil 1)**
- **Größeres Dorf** (36 × 28 statt 24 × 20 Felder) mit gepflastertem **Dorfplatz**: Brunnen in der Mitte, vier Marktstände (Obst, Stoffe, Kräuter), Bänke und Laternen, die nachts leuchten.
- **Verschiedene Häuser:** rote Ziegel, blauer und grauer Schiefer, Stroh oder Holzschindeln; Fachwerk, Naturstein oder Holzbretter; Fensterläden in verschiedenen Farben, Brennholz an der Wand, Schornsteine mal links, mal rechts.
- **Gebäude mit Charakter:** Gasthaus mit Wirtshausschild und Fässern, Tildas Laden mit gestreifter Markise, Tempel aus hellem Stein mit Glockenturm und Bogenfenstern.
- **Fünf neue Wohnhäuser** von Bäcker Anton, Schmied Bruno, Greta, Finns Familie und eine kleine Hütte. Sie sind vorerst verschlossen, ein kurzer Text verrät, wer dort wohnt.
- Marktstände, Laternen, Fässer und Bänke lassen sich ansehen.
- Alte Spielstände: Steht der Held an einer Stelle, die jetzt bebaut ist, wird er auf das nächste freie Feld gesetzt.

## v0.1.21 – 05.10.2026, 17:09

**Neu – jedes Attribut zählt**
- **Erklärung im Heldenreiter:** Tippt man auf ein Attribut, steht dort, was es bringt, mit den aktuellen Zahlen.
- **Charisma:** pro Punkt 5 % günstiger einkaufen und teurer verkaufen (höchstens 20 %, bei negativem Modifikator umgekehrt). Normale Gegner zögern mit 8 % Chance pro Punkt eingeschüchtert und verlieren ihre erste Runde.
- **Intelligenz:** Ab INT 12 erkennt der Held zu Kampfbeginn Schwächen, Resistenzen und Immunitäten des Gegners. Pro Punkt 10 % Chance auf einen zusätzlichen Trank beim Brauen und 3 % mehr Erfahrung.
- **Weisheit:** pro Punkt ein halbes Feld mehr Sicht im Nebel, 15 % seltener Hinterhalte (bis 60 %) und 15 % Chance auf ein zusätzliches Kraut.
- **Stärke:** Wurfgeschosse (Alchemistenfeuer, Weihwasser) bekommen den Stärke-Modifikator als Bonusschaden.
- **Geschicklichkeit:** Schleichen: Jagende Monster bemerken den Helden pro 2 Punkte ein Feld später (normal 4, mindestens 2).
- **Konstitution:** Gift und Blutung klingen nach dem Kampf pro Punkt eine Runde schneller ab; Mahlzeiten heilen zusätzlich den Modifikator.

**Neu – Version sichtbar**
- Titelbild und System-Reiter zeigen die genaue installierte Version mit Unternummer und Build-Nummer (vorher stand dort immer „v0.1“).

**Sonstiges**
- Neue [Merkliste](docs/MERKLISTE.md) mit allen bisher nicht umgesetzten Ideen.

## v0.1.20 – 05.10.2026, 16:51

**Geändert – Blumenwiesen und Heilkräuter**
- **Echte Blumenwiesen:** Statt einzelner, kaum erkennbarer Felder gibt es im Flüsterwald drei und im Tiefen Flüsterwald fünf Wiesen aus 4–7 Feldern. Die Blüten sind dichter, größer und bunter, gut sichtbar auch auf dem Handy.
- **Heilkräuter sieht man jetzt:** Wo Kräuter wachsen, steht eine hellgrüne Heilpflanze mit weißer Blüte (etwa auf jedem zweiten Wiesenfeld). Drüberlaufen pflückt sie, dann ist sie weg und wächst am nächsten Tag nach. Kein Glücksspiel mehr wie vorher (50 % Zufall pro Feld).
- **Hedda** erklärt jetzt genau, wo die Kräuter wachsen und woran man sie erkennt.

## v0.1.19 – 05.10.2026, 16:28

**Geändert – Spielbalance** (per Kampfsimulation für alle vier Klassen abgestimmt)
- **Point-Buy bei der Charaktererstellung:** 24 Punkte frei verteilen, Werte 8–15 vor Volksbonus (14 kostet 7, 15 kostet 9 Punkte). Der Knopf „Vorschlag“ verteilt passend zur Klasse. Neue Helden starten damit etwas kleiner als bisher.
- **Attributspunkte wie im SRD:** je 2 Punkte auf Stufe 4, 8, 12, 16 und 19 statt 1 Punkt auf jeder Stufe.
- **Feuerball:** nur noch einmal pro Kampf. Begleiter (Rudel, Späher, Leibwache) fliehen nur noch, wenn ihr Rettungswurf misslingt.
- **Beute nach Kapiteln:** In Kapitel 1 ist normale Beute bis Stufe 2 gewöhnlich, danach nur gelegentlich ungewöhnlich. Bosse, Eliten, Truhen und schimmernde Monster geben höchstens „selten“. Bessere Seltenheiten kommen mit späteren Kapiteln. Bosse lassen ein Highlight und etwas normale Beute fallen statt drei bis vier seltener Gegenstände. Tildas Laden führt in Kapitel 1 höchstens Ungewöhnliches.
- **Obergrenzen für Ausrüstung:** In Kapitel 1 bringt alle Ausrüstung zusammen höchstens +1 je Attribut, auf Angriff, Zauberangriff und RK sowie +2 Schaden. Im Heldenreiter markiert ein Sternchen, wenn deine Ausrüstung mehr könnte.
- **Story-Gegenstände aus Kapitel 1** (Glutstab, Klinge von Bornim, Graks Kriegsaxt, Grimmzahns Fang usw.) sind jetzt „selten“ mit kleineren Werten.
- **Normale Monster** wachsen mit der Heldenstufe stärker mit (TP), damit Kämpfe auf Stufe 5–6 nicht nach einer Runde vorbei sind. Bosse bleiben wie bisher.
- **Schurke:** „Unglaubliches Ausweichen“ halbiert ab Stufe 5 den ersten Treffer in jeder Runde (vorher nur einmal pro Kampf).
- **Bestehende Spielstände:** Beim Laden werden die Attributspunkte nach der neuen Regel neu berechnet (zu viel Verteiltes wird zurückgenommen, zuerst beim am stärksten gesteigerten Attribut), und die Story-Gegenstände werden angepasst. Ein Hinweis erscheint einmalig.

## v0.1.18 – 05.10.2026, 15:55

**Geändert**
- Gegenstandsbeschreibungen wiederholen die Werte nicht mehr (vorher z. B. „heilt 2W4+2“ und darunter „Heilt 2W4+2 TP.“). Stattdessen steht dort, was der Wert nicht verrät: etwa dass der Kräutertrank alle Zustände heilt oder Alchemistenfeuer in Brand setzt.

## v0.1.17 – 05.10.2026, 15:50

**Fehlerbehebungen**
- Heddas Laden zeigt jetzt schon beim ersten Besuch den Reiter „Brauen“ und keine Ausrüstung mehr (vorher erst ab dem zweiten Gespräch).

## v0.1.16 – 05.10.2026, 15:30

**Neu – Zutaten**
- **Beute von Tieren:** Wölfe lassen Fleisch und Wolfsfelle fallen, Wildschweine Fleisch und Keilerhauer, Riesenratten manchmal Fleisch, Riesenspinnen Giftdrüsen, Riesenfledermäuse Flügel. Grimmzahn hinterlässt immer Fell und Fleisch.
- **Braten am Lagerfeuer:** Beim Rasten an einem Lagerfeuer wird mitgebrachtes Fleisch gebraten. Gebratenes Fleisch heilt 2W4+2 TP und stärkt für den nächsten Kampf (+1 auf Angriffe und Schaden, oben rechts als „Satt“ angezeigt). Man kann es auch verkaufen.
- **Heilkräuter:** Auf Blumenwiesen im Wald wachsen Kräuter; jede Wiese kann einmal am Tag abgeerntet werden. Im Flüsterwald gibt es dafür neue Blumenwiesen.
- **Brauen bei Hedda:** Neuer Reiter „Brauen“ in Heddas Laden: Heiltrank (2 Kräuter + 5 Gold), Kräutertrank (2 Kräuter + 2 Gold), Großer Heiltrank (3 Kräuter + Fledermausflügel + 15 Gold), Alchemistenfeuer (Giftdrüse + 5 Gold).
- Felle, Hauer und alle anderen Zutaten lassen sich bei Tilda und Hedda verkaufen.
- Hedda verkauft keine Ausrüstung mehr (vorher erschien dort Tildas Sortiment).

## v0.1.15 – 05.10.2026, 15:25

**Neu**
- **Wolfsrudel:** Ein Wolf kommt mit ein oder zwei Jungwölfen, die im Kampf von der Seite zuschnappen.
- **Goblin mit Späher:** Goblins haben einen Späher dabei, der aus dem Hintergrund Pfeile schießt.
- **Grimmzahns Leibwache:** Zwei Wölfe begleiten den Leitwolf, auf der Karte und im Kampf.
- Wie beim Kobold-Rudel gilt: Fällt der Anführer, fliehen die Begleiter, und ein Feuerball verjagt sie sofort. Begleiter bringen etwas mehr Erfahrung.
- **Stufengrenze in Kapitel 1:** Der Held steigt in Kapitel 1 höchstens bis Stufe 6, damit die Bosse eine Herausforderung bleiben. Weitere EP werden aufgehoben und ab Kapitel 2 angerechnet. Kampf und Heldenreiter zeigen „Höchststufe für Kapitel 1 erreicht“. Das Testmenü kann weiterhin jede Stufe einstellen.

**Geändert**
- Damit Rudel nicht zu schwer werden, haben Wolf und Grimmzahn etwas weniger TP (per Simulation abgestimmt).

## v0.1.14 – 05.10.2026, 15:16

**Neu**
- **Zustände wirken nach dem Kampf weiter:** Gift und Blutung kosten auf der Karte alle 4 Schritte ein bis drei TP, bis sie abklingen. Der Held fällt dadurch nie unter 1 TP. Ein Fluch („Geschwächt“) bleibt, bis man rastet, schläft, einen Kräutertrank trinkt oder Bruder Odo aufsucht, und gilt auch im nächsten Kampf. Brand, Betäubung, Verlangsamung und Blendung enden mit dem Kampf.
- **Anzeige oben rechts:** Balken für TP, ZP (bei Zauberkundigen) und den Fortschritt zur nächsten Stufe (EP), dazu farbige Schilder für anhaltende Zustände.
- Den Kräutertrank kann man jetzt auch mit vollen TP trinken, wenn ein Zustand auf dem Helden liegt.

**Geändert**
- Der Tastenton im Menü ist leiser und weicher.

## v0.1.13 – 05.10.2026, 15:00

**Geändert**
- Nächtliches Grillenzirpen klingt natürlicher und leiser (vorher erinnerte es an ein altes Handyklingeln).

## v0.1.12 – 05.10.2026, 14:56

**Neu**
- **Kämpfe bei Abend und Nacht:** Im Freien passt sich der Kampfhintergrund der Tageszeit an – in der Dämmerung mit rosa-violettem Himmel, nachts mit dunklem Sternenhimmel und Mondsichel. Held und Monster werden passend getönt. In der Höhle bleibt alles wie bisher.

## v0.1.11 – 05.10.2026, 14:48

**Neu**
- **Nebel des Unbekannten** in Wald und Höhle: Unerkundetes ist schwarz, Gesehenes bleibt abgedunkelt sichtbar. Der Held sieht in einem Kegel von 160° in Blickrichtung etwa 5 Felder weit (nachts und in der Höhle 4) und rundum ein Feld; Bäume, Felsen und Wände verdecken die Sicht. Monster sieht man nur, wenn sie im Blick sind – das „!“ eines Verfolgers hört man aber auch aus dem Nebel. Erkundetes wird gespeichert. Antippen zum Hinlaufen geht nur in bereits erkundetes Gebiet.
- **Tiefer Flüsterwald:** neues, gut doppelt so großes Gebiet östlich des Flüsterwalds (Ausgang beim Jägerlager), Gebietsstufe 2, 13 umherstreifende Monster, nachts Untote und Ghule, vier Truhen.
- **Kräuterfrau Hedda** am Lagerfeuer im Tiefen Flüsterwald: verkauft Tränke und Kräutertränke; ihr Kräuterrauch macht das Lager zur Schutzzone.
- **Grimmzahn, der Leitwolf:** optionaler Boss im Norden des Tiefen Flüsterwalds mit eigenem Beutestück „Grimmzahns Fang“ (episches Amulett mit Blutungschance). Lässt sich im Testmenü mit „Bosse zurücksetzen“ erneut herausfordern.

## v0.1.10 – 05.10.2026, 14:28

**Fehlerbehebungen**
- Ausrüstungsreiter: Nach dem Ablegen eines Gegenstands wird die Ausrüstungsgrafik sofort aktualisiert (vorher blieb das alte Bild stehen).
- Tasche und Laden: Die Pfeile ▲/▼ (besser/schlechter als das Angelegte) sind nach dem Anlegen sofort aktuell.

## v0.1.9 – 05.10.2026, 14:19

**Neu**
- **Kobold-Rudel:** Kobolde kommen mit ein oder zwei sichtbaren Begleitern. Diese stehen im Kampf hinter dem Anführer und stechen mit zu; fällt der Anführer, fliehen sie. Ein Feuerball verjagt das Rudel sofort. Auf der Karte laufen Kobolde als Grüppchen. (Ersetzt den bisherigen unsichtbaren „Vorteil“-Wurf.)
- **Schutzzonen:** Am Lager von Jäger Wilhelm, an den Waldausgängen und am Höhleneingang greifen keine Monster an und es gibt keine Hinterhalte. Am Lager erscheint der Hinweis „Jäger Wilhelm schwenkt seine Fackel – die Biester weichen zurück!“.
- **Ein- und Zweihänder erkennbar:** „2H“-Plakette am Symbol, „Zweihändig“/„Einhändig“/„Nebenhand“ im Untertitel, eigene Zeile in den Details und Warnung, was beim Anlegen abgelegt wird.

**Geändert**
- Monster sehen den Helden erst ab 4 Feldern (vorher 5) und verfolgen ihn etwas langsamer.
- Verfolger geben auf, wenn der Held mehr als 7 Felder Vorsprung hat oder sie mehr als 9 Felder von ihrem Revier entfernt sind.

**Fehlerbehebungen**
- Monster, die die Verfolgung abbrechen, kehren zu ihrem Startpunkt zurück, statt am Abbruchpunkt stehen zu bleiben.

## v0.1.8 – 05.10.2026, 13:25

**Neu – lebendige Welt**
- **Tag und Nacht:** Eine Spielstunde dauert eine Minute; Uhrzeit und Tag stehen oben rechts. Nachts wird es dunkel, um den Helden liegt ein Laternenschein, Fenster und Lagerfeuer leuchten.
- **Nachtmonster:** Nachts streifen Skelette, Zombies und Fledermäuse durch den Wald.
- **Schlafen:** Nachts kann man im Gasthaus-Bett bis zum Morgen schlafen (volle TP und ZP).
- **Dorfleben:** Finn und Greta laufen im Dorf umher und bleiben stehen, wenn man neben ihnen steht.
- **Kleinigkeiten:** Schmetterlinge, auffliegende Vögel, Schornsteinrauch, Glühwürmchen, fallende Blätter, gelegentlicher Regen.
- **Umgebungsgeräusche:** Vögel am Tag, Grillen und Eule in der Nacht, Tropfen in der Höhle.
- **Testmenü:** „Uhrzeit +3 h“ und „Regen an/aus“.

## v0.1.7 – 05.10.2026, 13:11

**Neu – sichtbare Monster**
- Monster streifen sichtbar durch Wald und Höhle:
  - **Jäger** (Wolf, Goblin, Ghul, Skelett …) entdecken den Helden mit rotem „!“ und Signalton und verfolgen ihn.
  - **Lauerer** (Spinne, Fledermaus, Gallerte) warten versteckt und springen erst aus der Nähe heran.
  - **Wanderer** ziehen friedlich umher.
- **Erstschlag:** Wer ein Monster von hinten angreift, überrascht es (es setzt eine Runde aus). Wer von hinten erwischt wird, gerät in einen **Hinterhalt**.
- Elite-Monster leuchten schon auf der Karte in ihrer Farbe, schimmernde funkeln.
- Antippen eines Monsters greift es an; die Aktionstaste zeigt dann gekreuzte Schwerter.
- Ist der Held der Gegend weit überlegen, weichen normale Monster aus.
- Besiegte Monster kehren nach 60 Schritten zurück.

**Geändert**
- Zufallskämpfe gibt es nur noch sehr selten (0,4 % pro Schritt im hohen Gras), immer als Hinterhalt mit eigenem Klang.

## v0.1.6 – 05.10.2026, 13:02

**Neu – Statuseffekte**
- Sieben Zustände mit Rundenzähler, als farbige Schilder an den Lebensbalken: Vergiftet, Brennend, Blutend, Betäubt, Verlangsamt, Geschwächt, Geblendet.
- Quellen:
  - **Monster:** Spinnengift und Netz, Ghul-Lähmung (Elfen immun), Schamanenfluch und Feuerpfeil, Fledermaus blendet, Stirge und Grak lassen bluten, Krogg betäubt.
  - **Kritische Treffer** – Klingen lassen bluten, Wuchtwaffen betäuben (für Held und Monster).
  - **Zauber:** Feuerzauber und Alchemistenfeuer setzen in Brand, Heilige Flamme kann blenden.
  - **Elite-Eigenschaften:** Giftig, Glühend.
- Neue Eigenschaften auf Ausrüstung: Gift-, Blutungs- und Betäubungschance, Standhaftigkeit (wehrt Zustände ab).
- Neuer **Kräutertrank** im Laden (20 Gold): heilt alle Zustände.

**Geändert**
- Spinnengift wirkt jetzt über mehrere Runden statt als Sofortschaden.
- Giftige und glühende Eliten abgeschwächt, damit sie nicht zu hart sind.

## v0.1.5 – 05.10.2026, 12:45

**Geändert**
- Reiter „Held“: Der Anteil der Ausrüstung an jedem Attribut steht blau neben dem Wert.

**Fehlerbehebungen**
- Testmenü: Beim Herabstufen werden zu viel verteilte Attributspunkte zurückgenommen (zuerst beim am stärksten gesteigerten Wert). Ein Held auf Stufe X hat danach genau X − 1 Punkte.

## v0.1.4 – 05.10.2026, 11:23

**Geändert**
- „Über das Spiel“: neue Beschreibung, passend zum README.

## v0.1.3 – 05.10.2026, 11:15

- Nur README (neue Kurzbeschreibung); die App ist unverändert zu v0.1.2.

## v0.1.2 – 05.10.2026, 11:09

**Geändert**
- APK mit eigenem, dauerhaftem Signierschlüssel. Einmalig v0.1.1 deinstallieren, danach funktionieren Updates normal.

## v0.1.1 – 05.10.2026, 10:45

**Neu**
- Umzug in dieses Repository. Funktionsumfang wie der letzte Stand des Vorgängerprojekts (siehe unten).
- Eigene App-Kennung `de.bornim.game`: Die App wird als neue App installiert, alte Spielstände werden nicht übernommen.
- Signiert noch mit einem temporären Schlüssel.

---

## Vorgeschichte (Vorgängerprojekt, bis 05.10.2026)

Die Entwicklung begann in einem früheren Repository. Die wichtigsten Schritte bis zum Umzug:

1. **Grundspiel:** Kapitel 1 „Der Blutzahn-Stamm“ (Dorf, Flüsterwald, Blutzahnhöhle, Krogg und Hauptmann Grak), 5 Völker, 4 Klassen, vereinfachte Regeln nach SRD 5.1, rundenbasierte Kämpfe, Deutsch und Englisch, Speichern und Laden.
2. **Spielgefühl:** flüssige Bewegung, volle Heilung beim Stufenaufstieg, Attributspunkte mit Bestätigung, Ladenkauf mit Gegenstandsdetails.
3. **Musik und Grafik:** lizenzfreie, selbst komponierte Musik (Oberwelt, Kampf, Bosskampf, epische Titelmusik), abschaltbar; Grafik in 32 px mit Schrägansicht; Copyright auf dem Titelbild.
4. **Beutesystem:** 9 Ausrüstungsplätze, Ein- und Zweihänder, Kampf mit zwei Waffen, zufällige Eigenschaften, 6 Seltenheitsstufen von gewöhnlich bis göttlich, Elite-Gegner, mitwachsende Monster.
5. **Klang und Kampf:** neu synthetisierte Musik, 26 Soundeffekte, Kampfanimationen mit Variationen.
6. **Name:** Das Dorf und das Spiel heißen jetzt Bornim.
7. **Fehlerbehebung:** TP-Anzeige oben rechts aktualisiert nach Lagerfeuer oder Heilung beim Priester.
8. **Neue Kampfgrafik:** 64-px-Monster mit Licht, Schatten und Animationen; Varianten pro Begegnung; Held zeigt seine Ausrüstung; 8 neue Monsterarten (insgesamt 17); Elite-Eigenschaften mit Aura; schimmernde Varianten.
9. **Testmenü** (7-mal auf das Copyright tippen); Eliten erst ab Heldenstufe 2.
10. **Touch-Steuerung:** Ziehen und Tippen zum Laufen, Aktionstaste mit Symbol statt A/B, klassisches Steuerkreuz als Option.
