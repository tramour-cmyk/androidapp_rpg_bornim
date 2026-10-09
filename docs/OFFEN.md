# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 09.10.2026, 18:34 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

**Arbeitsweise (seit 08.10.2026):**
- Jede Meldung von dir (Fehler, Anregung, Idee, Frage zum Nachhalten) kommt sofort hier hinein, auch wenn sie nicht gleich umgesetzt wird.
- Bildfolgen (Filmstreifen) schickst du dir ungern an, sie sind schlecht anzusehen (08.10.): Bewegungen prüfe ich selbst im Film; dir nur Einzelbilder oder Entwürfe des Aussehens, wenn nötig.
- Nach jeder erledigten Arbeit (von dir getestet oder von mir umgesetzt) wird diese Liste geprüft: Erledigtes wandert in die Änderungshistorie, Offenes bleibt stehen.
- Zu jedem neuen Test-Build steht unter „Zu testen“, worauf du achten sollst.
- Zeitstempel (09.10., 10:02): Du siehst auch meine Zwischenmeldungen, also bekommt **jede** Nachricht an dich einen Stempel in Berliner Zeit, nicht nur die Antwort am Ende.

## Übergabe-Notiz (für jede neue Sitzung)

Stand der Übergabe: 09.10.2026, 11:30 (Berliner Zeit). Die Datei `CLAUDE.md` im Hauptordner fasst die Regeln kurz zusammen und wird zu Beginn jeder Sitzung automatisch gelesen. Wer hier weitermacht, liest zuerst diese Notiz, dann den Rest dieser Liste, die [Stil-Leitlinien](STIL.md) und den Anfang der [Änderungshistorie](../CHANGELOG.md).

**Zwei Accounts (ab 09.10., 18:48):** Die Arbeit an der Karte ist aufgeteilt: Account A macht Leute und Monster auf `karte-neuer-stil`, Account B die Höhle auf `karte-hoehle`. Wer was macht und wie man sich abstimmt: [Aufteilung](AUFTEILUNG.md).

**Projekt:** „Chroniken von Bornim“, Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung der Figuren und Gegner), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner). Aktueller Stand: v0.1.279 auf `main`, von dir vollständig getestet; nichts in Arbeit. Alle 18 Gegner sind im neuen Stil (auf dem Puppenkörper `FoeArt`, als Tiere `BeastArt`, als Ungeziefer `VerminArt`/`Vermin.kt`).

**Feste Regeln im Umgang mit dir:**
- Frage 13:19: weniger Rückfragen zur Freigabe von Aktionen. Das steuert der Freigabe-Modus im Eingabefeld der App (Manuell/Automatisch), nicht der Code.
- Seit 09.10. (13:03): Zu jedem Test-Build die APK zusätzlich direkt im Chat als Datei schicken (die Chat-Sitzung kann Artefakte jetzt herunterladen), dazu der Artefakt-Link.
- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Vor jeder Antwort ein Zeitstempel „[TT.MM., HH:MM]“, immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date`), nie geschätzt. Seit 09.10. in jeder Nachricht, auch Zwischenmeldungen (du liest sie mit).
- Zu jedem Build der direkte Link (Release oder Artefakt) und eine Liste, worauf beim Testen zu achten ist.
- Neue Bilder immer mit der Uhrzeit, zu der sie entstanden sind.
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen. Erst nach deinem ausdrücklichen „setz um“/„ja“ umsetzen, eine Rückfrage ist keine Freigabe.
- Keine Bildfolgen (Filmstreifen) an dich schicken; Bewegungen selbst im Film prüfen, dir nur Standbilder oder Entwürfe.
- Jede Meldung von dir (Fehler, Idee, Frage) sofort in diese Liste; nach jeder erledigten Arbeit diese Liste prüfen, Erledigtes in die Änderungshistorie.
- Änderungshistorie: neue Einträge unter „## Unveröffentlicht“, bei Veröffentlichung umbenannt in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Build-Laufs).

**Feste technische Regeln:**
- Keystore und Signatur-Passwort nie committen; sie liegen nur als Secrets in GitHub. `local.properties` und SDK-Pfad nie committen.
- Die App-Kennung `de.bornim.game` nie ändern.
- Commits als Autor „tramour“ (`git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …`), mit den Co-Author- und Sitzungszeilen am Ende der Nachricht. Keine Modellbezeichnungen in Dateien oder Commits.
- Keine Verlaufsänderung, kein Force-Push. Keine Probe- oder Zwischenstände auf `main`; größere Arbeiten auf eigenen Zweigen, nach deinem Test auf `main`.
- Bei offenen Änderungen am Ende einer Arbeit: committen und auf den Zweig pushen.

**Bauen und veröffentlichen:** GitHub Actions „Build APK“ baut bei jedem Push (Version 0.1.<Laufnummer>). Ein Push auf `main` erzeugt ein Release mit `bornim.apk`; ein Zweig liefert das Artefakt `bornim-apk`. Ein Zweig-Build muss eine höhere Laufnummer als das installierte Release haben, sonst lässt er sich nicht installieren (dann den Lauf neu anstoßen).

**Selbst prüfen (siehe Stil-Leitlinien):** Jede Änderung an Kampf, Bewegung oder Effekten durch die echte Oberfläche filmen und die Bildfolge ansehen, nicht nur Code lesen. Werkzeuge in `tools/preview` (Aufruf mit Umgebungsvariablen, `../../gradlew -q run`):
- `FILMBATCH=datei` (dazu `FILMSTEP=40`): mehrere Kampffilme in einem Lauf, je Zeile `name klasse:gegner stufe seed plan [aktionen] [hero=…] [foe=…] [foefirst] [failsaves] [race=HALF_ORC] [place=village]`, z. B. `holy cleric:zombie 5 1 XWW item=holy_water`. X löst die nächste Aktion direkt aus, W wartet; Bilder unter `build/screens/films/<name>/`.
- `FILM=klasse:gegner` mit `FILMTAPS` (Tipper durch die Menüs) für Einzelfilme.
- `ABILITYFX=1` (alle Fähigkeits-Effekte in Phasen), `STATUSFX=1` (alle Zustände): Übersichtsblätter in Sekunden, für das Aussehen.
- Bewegungsblätter: `FOEANIM=ghoul:0,goblin:2` (Gegner auf der Puppe), `VERMINANIM=giant_spider:0,stirge:2` (Ungeziefer), `CLASH=1`/`FOECLASH=1` (Durchdringungen), `JELLYWOUND=1` (Gallerte nach Verletzung); Entwürfe: `VERMINSHEET=1`, `VERMINCLOSE=bat`.
- Ein Filmlauf mit 5 Kämpfen dauert gut 4 Minuten; Bash-Aufrufe brechen nach 10 Minuten ab, also höchstens 4–5 Filme pro Lauf oder im Hintergrund mit `timeout`. Bilder zum Ansehen mit ImageMagick (`montage`, `convert`) zuschneiden und zusammensetzen.
- Kerntests: `./gradlew :core:test` (u. a. Ablauf-, Tödlicher-Treffer- und Untote-Tests). Vor jedem Commit laufen lassen.

**Kampfanzeige (Stand 09.10.):** Treffer = Innehalten beim Aufprall (70 ms, Nahkampf), dunkelrote Färbung (`hurt` in `PixelSprite`), Blut im Augenblick des Aufpralls; Rütteln des Bildes nur bei kritischen Treffern; keine weißen Trefferzeichen, kein Blinken. Gift/Brennen/Bluten (`isTick()`) sind kein Schlag des Gegners. Tatendrang gilt einmal pro Rast (`SkillCost.PER_REST`, `Hero.spent`).

**Arbeitsumgebung:** siehe [UMGEBUNG.md](UMGEBUNG.md); Prüfung mit `tools/check-env.sh` (`--full` mit Kerntests und Vorschaubild).

**Im Spiel zum Testen:** Testmodus (7× auf das Copyright im Titel tippen), Reiter „Test“: Stufe, Gold, Vorräte auf 10, „Gegner bestehen keine Rettungswürfe“, Testkämpfe gegen jeden Gegner, Beute erzeugen.

## In Arbeit

- **Karte: Höhle (Account B, Zweig `karte-hoehle`, ab 09.10., 18:45):** Blutzahnhöhle im neuen Stil, Aufgabe siehe [Aufteilung](AUFTEILUNG.md).
  - **Entwurf gezeigt (19:00, Bilder von 18:59, nichts eingebaut):** Prototyp `tools/entwurf/hoehle.py` (Python, aus den echten Kartenzeilen), Ausschnitt vom Eingang bis zu den vier Kammern, 64 Bildpunkte je Kachel. Felsboden aus Platten mit Fugen, Rissen, Geröll, feuchten Stellen, Pfützen und Moos am Wasser; Felswände unregelmäßig, mit dunkler Oberseite und sichtbarer Felskante (Schichten, nasse Streifen); Stalagmiten, Felsblock, Geröllhaufen, Knochen mit Schädeln, Kisten, Felle als Schlafplätze, Stützbalken, Gitter, Lagerfeuer, Leuchtpilze, Kristalle, Wurzeln und Lichtstrahl am Lichtschacht, schwarzer Tümpel. Licht nur aus den Quellen von `MapLight` (gleiche Farben und Reichweiten) und der Laterne des Helden; der Fels wirft Schatten entlang der gezeichneten Wände. Bilder: `tools/entwurf/bilder/hoehle_*_1859.png`. Bekannte Schwächen: Held ist Platzhalter; das Vorher-Bild aus dem Spiel zeigt Graks Halle, der Entwurf den Gang am Eingang (Graks Halle ist im Entwurf nicht enthalten); Fackeln gibt es laut Karte nur in Graks Halle, am Eingang leuchtet das Tageslicht. Wartet auf deine Rückmeldung.
- **Karte im neuen Stil (gewünscht 09.10., 09:32; Zweig `karte-neuer-stil`):** Die Karte wirkt neben den Kämpfen noch nach Nintendo. Befund im Code: Die Karte nutzt eine kräftige, bunte Palette (Gras `#78C850`, Wasser `#4C8EF0`, rote und blaue Dächer) mit schwarzen Umrissen auf 32er-Kacheln; die Kampfkulissen haben gedeckte, erdige Farben mit Licht nach Tageszeit. Vorschlag in Stufen, damit es fließend übergeht:
  1. **Farbe und Licht:** Kartenpalette aus den Kampfkulissen ableiten (gleiche Gras-, Weg-, Wasser-, Rinden- und Steinfarben je Tageszeit), schwarze Umrisse durch dunklere Eigenfarben ersetzen, gemeinsame Farbstimmung über die ganze Karte, Schatten nach Sonnenstand.
  2. **Formen:** Kachelkanten auflösen (unregelmäßige Ränder, geschwungene Wege, siehe Merkliste), Bäume knorriger und in mehreren Arten (Eiche, Fichte, abgestorben), Unterholz, Wurzeln, Nebel in Senken; im Dorf verwitterte Häuser, Moos, Matsch, Rauch, gedeckte Dachfarben.
  3. **Figuren:** Held und Monster auf der Karte aus denselben Modellen wie im Kampf, klein und schräg von oben.
  4. **Übergang Karte → Kampf:** Kamera fährt auf die Stelle, Bild dunkelt ab, die Kampfkulisse entsteht aus genau diesem Ort.
  5. **Feinere Grafik (größerer Umbau):** doppelte Auflösung der Kacheln oder Kacheln mit Höhen- und Lichtinformation, damit Fackeln und Mond echte Schatten werfen.
  Empfehlung: mit 1 und 3 beginnen, vorher Entwürfe (vorher/nachher bei Tag, Dämmerung, Nacht). **Von dir gewählt (09.10., 09:58): Stufe 1 und 3, mit Blick auf die Stil-Leitlinien (Erinnerung 10:01).**
  - Stand 10:06: Stufe 1, erster Teil eingebaut (Zweig): eine Farbstimmung für alle Kartenbilder (`MapGrade`), die die bunten Kartenfarben auf die Farben der Kampfkulissen schiebt (Gras, Weg, Wasser, Rinde, Stein, Dächer, Putz, Holz) und die schwarzen Umrisse durch eine dunklere Eigenfarbe ersetzt. Lichtquellen (Feuer, Leuchtpilze, Kristalle) behalten ihre Farbe. Tageszeit wie bisher über das Kartenlicht. Schatten nach Sonnenstand und Stufe 3 folgen nach deinem Blick auf die Entwürfe.
  - Entwürfe kommen über GitHub (hier ist Gradle gesperrt): Lauf „Vorschau“ rendert bei jedem Push auf einen Zweig mit `tools/preview/vorschau.env` die Karten mit `main` (vorher) und dem Zweig (nachher) und legt die Vergleichsbilder auf den Zweig `vorschau-bilder`. `vorschau.env` vor der Übernahme nach `main` wieder entfernen.
  - **Erster Entwurf gezeigt (10:15; Bilder von 10:14: Dorf bei Tag, Wald in der Dämmerung, Dorf bei Nacht).** Eigene Einschätzung: Die Stimmung geht in die richtige Richtung, wirkt aber noch flach und grau wie ein Filter. Hohes Gras verschwindet im Boden, das Gemüsebeet ist kaum noch zu sehen, die blauen Dächer haben sich kaum verändert, und bei Nacht ist fast kein Unterschied. Vorschlag für den zweiten Entwurf: Gras wieder grüner wie im Kampf, mehr Hell-Dunkel innerhalb der Flächen, hohes Gras dunkler und deutlich abgesetzt, Dächer und Wände gezielt nachfärben, dazu die Schatten nach Sonnenstand. Wartet auf deine Rückmeldung.
  - **Deine Rückmeldung (10:18):** kaum ein Unterschied zu erkennen, so lohnt sich die Mühe nicht. Befund: `main` hatte schon gedeckte Farben (Entwurf „maps-mood“ vom 06.10. ist größtenteils drin), daher bringt Umfärben allein wenig. Der Nintendo-Eindruck kommt von den Formen: sichtbares Kachelraster, eckige Wege und Wiesenränder, kleine Spielzeughäuser, gleichförmige Bäume. Vorschlag: Farbstimmung zurückstellen, stattdessen einen Ausschnitt (Dorfplatz oder Lichtung) als Entwurf in neuer Machart zeigen (Formen, Licht, Schatten, Figur), bevor etwas eingebaut wird. Offen: deine Entscheidung.
  - **Grundsatzfrage (10:18):** Halten wir an der Kachelkarte überhaupt fest, oder bewegt sich der Held ganz anders durch die Welt? Stil-Leitlinien beachten, der Spieler muss sich irgendwie fortbewegen, offen ist, wie konkret. Vorschläge dazu im Chat (10:20): (A) Draufsicht behalten, aber neu gemalt und ohne Raster, (B) Seitenansicht wie im Kampf mit verbundenen Szenen, (C) gezeichnete Reisekarte mit Orten, (D) Mischung aus C für die Reise und B für die Orte (Empfehlung). Nächster Schritt: je ein Entwurfsbild der Varianten, die du sehen willst.
  - Ausschnitt für die Entwürfe: der Wald (deine Wahl, 10:19). **Entwürfe gezeigt (10:32, Bilder von 10:31):** B Ansicht wie im Kampf mit Wegweisern voraus/zurück/abbiegen (Waldweg, Garricks Feuer, Weiher; Lichtung bei Tag, Dämmerung, Nacht), C gezeichnete Reisekarte des Flüsterwalds aus den Kartendaten (ganz und so weit erkundet), D beides. Nur Bilder (Vorschau `WEGE=1`), nichts davon im Spiel. Bekannte Schwächen der Entwürfe: Garrick steht mit dem Rücken zum Betrachter (die Figuren gibt es bisher nur in Kampfhaltung von hinten), das Schild „zurück“ liegt über den Beinen. Wartet auf deine Wahl.
  - **Gemeldet (10:41): Held sieht schrecklich und anatomisch falsch aus.** Ursache: In den Entwürfen war versehentlich die alte Entwurfsfigur (`HeroFigure`) statt der Kampffigur (Puppe, `HeroBattle`). Behoben, B und D neu gezeigt (Bilder von 10:43); das Schild „zurück“ sitzt jetzt unten rechts. Garrick ist weiter von hinten zu sehen.
  - **Deine Entscheidung (10:47): Erkunden bleibt.** B, C und D nehmen das Entdecken weg (man tippt nur noch Orte an, der Weg fehlt). Die bestehende Draufsicht-Karte soll erwachsener und düsterer werden, das freie Erkunden bleibt. Vorschläge dazu im Chat (10:48): feinere Auflösung, Raster auflösen, Licht und Sicht als Spielelement, Atmosphäre, Dinge zum Entdecken, Figuren aus der Puppe. Nächster Schritt: Entwurf eines Ausschnitts (Lichtung) in neuer Machart, nach deiner Auswahl.
  - Von dir freigegeben (10:57). Dazu deine Anregungen: näher heranzoomen für mehr Details (11:00), schräg von oben statt reiner Draufsicht, dreidimensionaler (11:01; beides übernommen).
  - **Entwurf gezeigt (11:05, Bilder von 11:04):** Lichtung im Flüsterwald schräg von oben, doppelte Auflösung (64 statt 32 Bildpunkte je Kachel), etwa 7 statt 11 Kacheln Bildschirmbreite; kein sichtbares Raster, geschwungener Weg mit Fahrspuren, Eichen, Fichten und tote Bäume mit Stamm, Wurzeln und Schatten nach der Sonne, Unterholz (Büsche, Farne, Äste), hohes Gras mit Halmen, dunkler Weiher mit Bodennebel. Nachts nur Licht, wo Feuer und Laterne hinsehen (Bäume verdecken), der Rest im Nebel. Zum Entdecken: gerissener Hirsch mit Krähen und Schleifspur, altes Grab am Weiher, Knochen am Höhlenweg, Krallenspuren am Schild. Figuren sind Platzhalter. Prototyp in `tools/entwurf/lichtung.py` (Python, aus den echten Kartenzeilen), nicht im Spiel.
  - **Deine Rückmeldung (11:11):** Stil grundsätzlich die richtige Richtung. Gern noch ein Stück näher heran, noch mehr Details und feinere Grafik, Sichtlinie und Nebel des Unerkundeten wie bisher. Frage: scrollt die Karte dann? Antwort (11:12): ja; die Kamera folgt schon heute dem Helden und scrollt (etwa 10,5 Kacheln Breite, der Flüsterwald ist 20 × 32), näher heran heißt nur: mehr Scrollen. Als Ausgleich für den fehlenden Überblick die gezeichnete Karte aus Entwurf C als Kartenansicht im Menü (steht schon auf der Merkliste). Umsetzungsvorschlag in Stufen im Chat; wartet auf dein Go.
  - **Idee (11:14): Gelände bestimmt die Geschwindigkeit.** Abseits des Weges langsamer. Befund: Ein Schritt dauert heute immer gleich lang (200 ms, auf einer Route 170 ms, rennend 110 ms, in `WorldScreen`), das lässt sich leicht je Gelände staffeln. Vorschlag: Weg und Pflaster etwas schneller (× 0,85), Wiese normal, Blumen × 1,1, hohes Gras und Unterholz deutlich langsamer (× 1,5, angelehnt an schwieriges Gelände im SRD), später Matsch und flaches Wasser × 2; für wandernde Monster ebenso. Dazu Schrittgeräusch und Bewegung des Grases je Gelände. Kommt mit in Stufe 1.
  - **Frage (11:15): freies Laufen statt nur rauf, runter, links, rechts?** Befund: Der Held geht heute Kachel für Kachel in vier Richtungen; der Wisch-Joystick rastet auf vier Richtungen ein, Tippen sucht einen Weg über Kacheln. Vorschlag (Mischform): Spiellogik bleibt auf Kacheln (Begegnungen, Truhen, Auslöser, Speicherstand, Tests), aber der Held bewegt sich frei in jede Richtung mit stufenloser Position; der Joystick rastet nicht mehr ein, Tippen läuft gerade Linien, wo der Blick frei ist, statt Treppenstufen; Hindernisse als Kreis gegen Kacheln. Die Geländegeschwindigkeit wird dabei Bildpunkte pro Sekunde je Untergrund. Als eigene Stufe nach Zoom und Auflösung, weil sie die Spiellogik berührt.
  - **Reihenfolge, von dir freigegeben (11:17):** 1. Zoom, doppelte Auflösung, Gelände-Tempo; 2. freies Laufen; 3. Boden ohne Raster; 4. Bäume, Felsen, Unterholz mit Schatten; 5. Licht mit Sichtlinie, Nebel; 6. Dinge zum Entdecken, Bodennebel; 7. Kartenansicht im Menü; später Figuren aus der Puppe. Zuerst der Flüsterwald.
  - **Frage (15:00): die Karte der Höhle fehlt noch.** Ja: neu sind bisher nur Flüsterwald und Tiefer Wald; Höhle, Dorf und Innenräume haben die alten Bilder. Die Höhle kommt als nächster Ort (eigener Boden aus Fels, Geröll und feuchten Stellen, Felswände mit Höhe, Leuchtpilze und Kristalle im neuen Stil), nach den Figuren oder davor, wie du möchtest.
  - Idee Kartenübersicht mit Nebel und Schnellreise (12:49): auf deinen Wunsch (12:50) auf die Merkliste verschoben.
  - **Stufe 1 in Arbeit (11:19):** naher Zoom (etwa 5½ Kacheln, im Testreiter umschaltbar), Gelände-Tempo für Held und Monster. Die Farbstimmung vom Morgen ist wieder heraus (kaum Unterschied, siehe oben). Doppelte Auflösung: der Zoom ist dafür vorbereitet; die neuen Bilder selbst kommen mit Stufe 3 und 4, bis dahin wirken die alten Kartenbilder nah größer und gröber.
  - **Übernommen (11:55):** in die Sitzung mit funktionierendem Gradle; `main` (v0.1.279) in den Zweig geführt. Die Zweig-Builds bis 0.1.285 waren noch ohne v0.1.279 (neue Ungeziefer-Gegner, Tatendrang, Treffer ohne Flackern); der nächste Zweig-Build enthält beides.

## Zu testen

**Zweig-Build 0.1.327** (Zweig `karte-neuer-stil`: naher Zoom, gemächlicheres Tempo, neuer Boden mit breitem Karrenweg, neue Bäume, Felsen und Unterholz im Wald; [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37951517297/artifacts/11626222809)); dazu Wege als zusammenhängendes Netz, Feuer, Truhe und Schild neu, Bäume niedriger, Kronen vor dem Helden halb durchsichtig, **Held als Puppe** (Schild auf dem Rücken, weiches Umdrehen). Achten auf: Umdrehen weich genug? Schritte stimmig? Erscheint beim Betreten kurz die alte Figur, und wie lange? Ruckeln? Enthält auch den Stand von main v0.1.279 (von der anderen Sitzung hereingeführt). Grafik vorgezogen auf deinen Wunsch (11:49). Worauf achten:
- **Neuer Boden im Flüsterwald und Tiefen Wald:** kein Raster, geschwungener Weg mit Fahrspuren, hohes Gras mit Halmen, Weiher. Gefällt die Richtung? Zu dunkel, zu matschig, zu gleichförmig? Kommen beim Betreten kurz die alten Kacheln, bevor der neue Boden erscheint, und stört das? Ruckelt etwas?
- **Neu: Bäume, Felsen, Unterholz im Wald** (Eichen, Fichten, tote Bäume, Felsgruppen, Stämme, Steinkreis, Büsche, Farne, Schatten nach der Sonne). Wirken sie stimmig neben dem Boden? Verdecken Kronen zu viel vom Weg oder vom Helden? Feuer, Truhe und Schild seit 15:10 ebenfalls neu (auf deinen Wunsch, 15:00). Noch alt: alle Figuren.
- **Idee (15:24): Baumkrone halb durchsichtig, wenn der Held dahinter steht.** Umgesetzt (15:27): Krone, Fels oder Busch vor dem Helden werden halb durchsichtig. Figuren als Nächstes (deine Entscheidung 15:24).
- **Figuren auf der Karte, erster Entwurf (15:30):** die Puppe aus dem Kampf schräg von oben (Blickwinkel 38°), in Kartengröße, wahre Größe je Volk; Ruhehaltung mit gesenkter Waffe, vier Laufrichtungen mit vier Schrittbildern; Szene an Garricks Feuer alt gegen neu. Vorschau `MAPFIG=1`. Offen: Schrittbewegung noch schlicht, Monster folgen nach deiner Rückmeldung.
  - **Idee (15:53): Schild beim Herumlaufen auf dem Rücken, Hände frei.** Umgesetzt im Entwurf (15:58): neue Lage „auf dem Rücken“ in der Puppe (über den Schulterblättern, Vorderseite nach außen, leicht schräg, über dem Umhang, mit Riemen über der Brust), Rund-, Spitz- und Turmschild behalten ihre Form; nur auf der Karte, im Kampf weiter am Arm.
  - **Rückmeldung (16:00):** Vorder- und Seitenansicht gut, von hinten hing der Schild zu tief. Geändert (16:02): höher auf Schulterhöhe, etwas mehr nach hinten geneigt, damit er von vorn nicht wie eine Stuhllehne über den Kopf ragt.
  - **Rückmeldung (16:03):** von hinten wirkte der Schild mit Abstand zum Rücken (Hohlraum), daher auch zu tief. Geändert (16:04): liegt jetzt dicht am Rücken an, kaum geneigt.
  - **Rückmeldung (16:05):** von vorn richtig, von hinten weiter auf Nabelhöhe, das passt nicht zusammen. Ursache: der schräge Blick von oben; was hinter dem Körper liegt, erscheint von vorn höher, von hinten tiefer, als es ist. Geändert (16:06): Oberkante jetzt wirklich knapp über den Schultern (je nach Form berechnet), dicht am Rücken; von hinten deckt der Schild den Rücken von den Schultern bis zur Taille. **Von dir bestätigt (16:16): sieht gut aus.**
  - **Held im Spiel (16:24):** Puppe auf allen Karten, Schild auf dem Rücken, weiches Umdrehen (16 Richtungen), vier Schrittbilder. Noch alt: Garrick, Dorfbewohner, Monster auf der Karte.
  - **Rückmeldung (16:33, Bildschirmfoto aus dem Tiefen Wald):** Held im Verhältnis zu den Bäumen viel zu groß; mit der Durchsicht dürfen die Bäume wieder größer werden. Im Haus (16:34) und auf dem Marktplatz (16:35) passen die Proportionen. Geändert (16:48): Bäume deutlich höher (Eichen und Fichten mehr als doppelt so hoch wie der Held); wo eine Krone Truhe, Feuer, Schild, Leute oder Ausgänge verdecken würde, steht eine junge Fichte.
  - Aufgefallen auf deinem Bildschirmfoto: ein dunkler Stab ragt seitlich aus der Hand (vermutlich eine Armbrust, deren Bogen quer steht). Zu prüfen: Fernwaffen beim Laufen auf dem Rücken oder geschultert.
  - **Rückmeldung (16:42, Bildschirmfoto Kleriker): Waffe schleift am Boden; lieber nach oben halten.** Geändert (16:55): alle Waffen auf der Karte geschultert (rechte Hand vor der Schulter, Waffe schräg nach hinten über die Schulter); für alle Waffenarten in 16 Richtungen geprüft (Schwert, Speer, Kampfstab, Zweihänder, Großaxt, Hellebarde, Magierstab, Langbogen, Armbrust, Dolch). Damit ist auch die quer stehende Armbrust erledigt. **Von dir für gut befunden (17:02)**, zusammen mit den höheren Bäumen.
- **CLAUDE.md-Prüfung (Frage 17:03):** nachgeholt (17:14): Laufen und Umdrehen durch die echte Oberfläche gefilmt (neues Werkzeug `WALKFILM=karte:x:y` in `tools/preview`, Wischsteuerung links, runter, rechts, rauf, alle 80 ms ein Bild): Umdrehen läuft über Zwischenrichtungen in etwa 0,2 s, Schritte wechseln die Beine, Kamera folgt. Auffällig: nach rechts gewandt liegt das geschulterte Schwert quer über Brust und Hals, wirkt unglücklich. `tools/check-env.sh` gelaufen: alles in Ordnung; mit `--full` scheitern die Kerntests, weil das Skript vom Hauptordner aus auch das Android-Plugin lädt und Maven Central dabei mit 429 bremst; `./gradlew -p core test` läuft. Zeitstempel-Regel in CLAUDE.md angepasst (jede Nachricht), dazu „erst besprechen, dann arbeiten“ (auf deinen Wunsch, 17:20).
- **Schwert in der Rechtsansicht (dein Auftrag 17:20, auch andere Klassen und Waffen prüfen):** geprüft mit Standbildern aller 16 Richtungen für Schwert, Dolch, Speer, Kampfstab, Zweihänder, Großaxt, Hellebarde, Magierstab, Langbogen, Armbrust und für Kleriker, Schurke (Elf, Halbling), Magier, Zwerg. Befund: jede geschulterte Waffe lag in der Rechtsansicht quer über Hals und Kopf, nicht nur das Schwert. Geändert (17:24): kurze Waffen tief in der Hand, Spitze nach vorn unten (frei vom Boden); lange Waffen fast aufrecht an der Schulter. Werkzeug `MAPFIGYAWS=1`. **Von dir bestätigt (18:34, Build 0.1.327): passt.**
  - **Idee (16:01): weiches Umdrehen statt hartem Wechsel zwischen den vier Richtungen.** Machbar mit wenig Aufwand: Die Puppe lässt sich in jede Richtung drehen; ich zeichne Zwischenrichtungen (16 statt 4) vorab und spiele beim Richtungswechsel die Drehung in etwa einer Achtelsekunde ab. Kommt mit dem Einbau der Figuren; die Zwischenrichtungen helfen später auch beim freien Laufen.
- **Weg (gemeldet 12:02: zu klein und mickrig):** jetzt ein breiter Karrenweg, etwa eine Kachel breit, mit Trampelrand, hellerer Mitte, tiefen Fahrspuren, Pfützen und Steinen; läuft an den Enden aus. Passt das so?
- **Gemeldet (13:12, mit Bildschirmfoto aus dem Tiefen Wald): Wege abgeschnitten.** Ursache: Die Weglinien wurden als einfache Linien von oben nach unten gebaut; Kreuzungen, Gabelungen und lange Querwege rissen ab. Jetzt als zusammenhängendes Netz aus den Wegkacheln, geglättet, Kreuzungen ohne Fahrspur-Ringe. **Von dir bestätigt (14:41, Build 0.1.295):** Wege, Kreuzungen und Gabelungen sehen gut aus, nichts Auffälliges.
- **Naher Zoom:** etwa 5½ Kacheln Breite. Fühlt sich das Laufen und Scrollen gut an? Sieht man genug, um sich zurechtzufinden? Im Testreiter „Kartenzoom“ zwischen nah und weit wechseln zum Vergleich. Die alten Kartenbilder wirken nah gröber, das ändert sich mit den neuen Bildern (Stufen 3 und 4).
- **Rand des Unerkundeten:** weich und rund statt Treppenstufen, Licht ohne Stufen.
- **Tempo insgesamt:** jetzt ruhiger (jeder Schritt 1,6-mal so lang). Passt es, oder noch langsamer bzw. wieder etwas schneller?
- **Gelände-Tempo:** auf dem Weg spürbar flotter, im hohen Gras deutlich zäher, Blumen kaum merklich. Wandernde Monster im hohen Gras ebenfalls langsamer.
- Dorf, Gasthaus, Höhle: passt der nahe Zoom auch dort? Keine abgeschnittenen Eingänge, Schilder oder Figuren an der Anzeige oben?
- **Deine Rückmeldung zu 0.1.281 (11:42):** außer dem Zoom kaum etwas anders (stimmt: die neuen Bilder kommen erst mit Stufe 3 und 4); Geländetempo leicht spürbar, insgesamt aber zu schnell und nah herangezoomt hektisch. Geändert: alle Schritte 1,6-mal so lang, für Held und Monster, im Zweig-Build 0.1.284.

**Version v0.1.279** (veröffentlicht 09.10., 11:16): [bornim.apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/download/v0.1.279/bornim.apk). Vollständig von dir bestätigt (09.10.), zuletzt Tatendrang einmal pro Rast („funktioniert“).

**Noch nicht bestätigt aus älteren Versionen:**
- Zustände Verlangsamt und Geschwächt (Fluch des Schamanen), sobald sie vorkommen: zu schwach, zu stark, stören sie? Sind sie und „Geblendet“ auf kleinen Gegnern stark genug?
- „Kampftext: weiter automatisch“ (seit v0.1.194).

## Zu entscheiden

- **Noch mehr Zwischenbilder?** Die Haltungen selbst (Arme, Beine, Waffe) wechseln 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung kurz ab. Nach deinem Test von 0.1.208 vorerst nicht nötig; bei Bedarf als eigener, größerer Umbau (mehr Bilder, längeres Vorabzeichnen zu Kampfbeginn).
- **Hörproben:** Auswahl für Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt.

## Geplant

- **Killerschlag:** Ein kritischer Treffer, der ein Monster tötet, bekommt einen besonderen Schlag des Helden in mindestens drei Varianten. Das Trefferbild zerfetzt den Gegner, abgestuft nach der Blutstufe: bei „Aus“ ohne Blut, etwa ein Zerbrechen oder Zusammensacken; bei „Dezent“ und „Deutlich“ immer stärker. Skelette zerspringen in Knochen. Gilt für alle Gegner im neuen Stil.
- **Sterbeanimationen für alle Gegner:** Alle Gegner im neuen Stil haben je drei Stürze und bleiben liegen. Seit 09.10. sind alle Gegner im neuen Stil; Schamane und Ghul fallen wie die Goblins, die Tiere aus dem Entwurf haben ihre eigenen Stürze.

- **Klänge überarbeiten (Rest)** nach den [Stil-Leitlinien](STIL.md): weg von quietschenden Nintendo-Tönen, hin zu glaubwürdigen Geräuschen. Die Kampfgeräusche (Hiebe, Stiche, Schläge, Biss, Pfeil, Schwung, Wolfsheulen) wurden schon einmal realistischer gemacht und werden mit geprüft; Abwehr („Klonk“) und Fehlschlag („Wusch“) sind schon neu. Noch im alten Stil sind vermutlich:
  - Menü und Bedienung: Klick.
  - Belohnungen: Stufenaufstieg, Beute, epische Beute, Münzen, Truhe.
  - Welt: Tür, Begegnung, Alarm (Gegner bemerkt dich), Hinterhalt.
  - Zauber und Tränke: Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf.
  - Kampfende: Gegner fällt, Held fällt.
  - Umgebung: Vögel, Grillen, Eule, Tropfen, Knistern.
  - Musik prüfen, ob sie zum düstereren Stil passt.
  - Vorgehen: erst Hörproben einzelner Geräusche zum Vergleich, dann nach deiner Freigabe umstellen.

## Bei dir

- **Setup-Skript (optional):** Die Cloud-Sitzung bringt alles mit (JDK 21, ImageMagick, Python, git; geprüft 09.10. mit `tools/check-env.sh`). Ein Android-SDK ist nicht nötig, die APK baut GitHub. Zur Absicherung kann die Installationszeile aus `docs/UMGEBUNG.md` als Setup-Skript in die Umgebungseinstellungen.
- **Zwei Sitzungen am selben Zweig (Frage 12:30):** Chat-Sitzung und Code-Sitzung haben beide auf `karte-neuer-stil` gearbeitet. Unterschied: In der Chat-Sitzung sind Maven und Google Maven weiter gesperrt (12:30 geprüft), dort laufen weder Kerntests noch Vorschau, alles geht über GitHub Actions und dauert pro Durchgang einige Minuten. Die Code-Sitzung hat laut `docs/UMGEBUNG.md` Netz und kann lokal testen und rendern. Vorschlag: Die Karte macht eine Sitzung allein; die andere arbeitet an etwas anderem auf einem eigenen Zweig. **Nachtrag 12:41:** Du hast in der Chat-Sitzung den Netzzugang freigegeben (Einstellungen → Capabilities); Maven, Google Maven und Gradle sind jetzt erreichbar, Kerntests und Vorschau laufen auch dort lokal (Maven Central bremst anfangs mit Fehler 429, ein zweiter Versuch mit `--max-workers=1` geht durch).

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). In Testkämpfen im Dorf erreichen sich Held und Gegner beim Angriff nicht (alte Kulisse ohne berechneten Schritt); kein Fehler, so gelassen (08.10.). Testkämpfe im Wald oder in der Höhle machen. Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
