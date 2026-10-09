# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 09.10.2026, 12:31 (Berliner Zeit).

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

**Projekt:** „Chroniken von Bornim“, Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung der Figuren und Gegner), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner). Aktueller Stand: v0.1.279 auf `main`, von dir vollständig getestet; nichts in Arbeit. Alle 18 Gegner sind im neuen Stil (auf dem Puppenkörper `FoeArt`, als Tiere `BeastArt`, als Ungeziefer `VerminArt`/`Vermin.kt`).

**Feste Regeln im Umgang mit dir:**
- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Vor jeder Antwort ein Zeitstempel „[TT.MM., HH:MM]“, immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date`), nie geschätzt. Stempel und Korrekturen stehen in der Antwort am Ende, nicht in Zwischenmeldungen (die siehst du nicht).
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
  - **Stufe 1 in Arbeit (11:19):** naher Zoom (etwa 5½ Kacheln, im Testreiter umschaltbar), Gelände-Tempo für Held und Monster. Die Farbstimmung vom Morgen ist wieder heraus (kaum Unterschied, siehe oben). Doppelte Auflösung: der Zoom ist dafür vorbereitet; die neuen Bilder selbst kommen mit Stufe 3 und 4, bis dahin wirken die alten Kartenbilder nah größer und gröber.
  - **Übernommen (11:55):** in die Sitzung mit funktionierendem Gradle; `main` (v0.1.279) in den Zweig geführt. Die Zweig-Builds bis 0.1.285 waren noch ohne v0.1.279 (neue Ungeziefer-Gegner, Tatendrang, Treffer ohne Flackern); der nächste Zweig-Build enthält beides.

## Zu testen

**Zweig-Build 0.1.289** (Zweig `karte-neuer-stil`: naher Zoom, gemächlicheres Tempo, neuer Boden im Wald mit breitem Karrenweg; [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37916429682/artifacts/11610515269)). Enthält auch den Stand von main v0.1.279 (von der anderen Sitzung hereingeführt). Grafik vorgezogen auf deinen Wunsch (11:49). Worauf achten:
- **Neuer Boden im Flüsterwald und Tiefen Wald:** kein Raster, geschwungener Weg mit Fahrspuren, hohes Gras mit Halmen, Weiher. Gefällt die Richtung? Zu dunkel, zu matschig, zu gleichförmig? Kommen beim Betreten kurz die alten Kacheln, bevor der neue Boden erscheint, und stört das? Ruckelt etwas?
- Bäume, Felsen, Schild und Figuren sind noch die alten Bilder (kommen in der nächsten Stufe).
- **Weg (gemeldet 12:02: zu klein und mickrig):** jetzt ein breiter Karrenweg, etwa eine Kachel breit, mit Trampelrand, hellerer Mitte, tiefen Fahrspuren, Pfützen und Steinen; läuft an den Enden aus. Passt das so?
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
- **Zwei Sitzungen am selben Zweig (Frage 12:30):** Chat-Sitzung und Code-Sitzung haben beide auf `karte-neuer-stil` gearbeitet. Unterschied: In der Chat-Sitzung sind Maven und Google Maven weiter gesperrt (12:30 geprüft), dort laufen weder Kerntests noch Vorschau, alles geht über GitHub Actions und dauert pro Durchgang einige Minuten. Die Code-Sitzung hat laut `docs/UMGEBUNG.md` Netz und kann lokal testen und rendern. Vorschlag: Die Karte macht eine Sitzung allein (am besten die Code-Sitzung); die andere arbeitet an etwas anderem auf einem eigenen Zweig.
- **Netzwerkzugriff im zweiten Claude-Account (09.10.):** In dieser Umgebung sind Gradle und Maven gesperrt, daher laufen hier weder Vorschau noch Tests. Netzwerk in den Umgebungseinstellungen wie beim ersten Account freigeben.

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). In Testkämpfen im Dorf erreichen sich Held und Gegner beim Angriff nicht (alte Kulisse ohne berechneten Schritt); kein Fehler, so gelassen (08.10.). Testkämpfe im Wald oder in der Höhle machen. Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
