# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 09.10.2026, 10:44 (Berliner Zeit).

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

Stand der Übergabe: 08.10.2026, 14:14 (Berliner Zeit). Die Datei `CLAUDE.md` im Hauptordner fasst die Regeln kurz zusammen und wird zu Beginn jeder Sitzung automatisch gelesen. Wer hier weitermacht, liest zuerst diese Notiz, dann den Rest dieser Liste, die [Stil-Leitlinien](STIL.md) und den Anfang der [Änderungshistorie](../CHANGELOG.md).

**Projekt:** „Chroniken von Bornim“, Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung der Figuren und Gegner), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner). Aktueller Stand: v0.1.210 auf `main`.

**Feste Regeln im Umgang mit dir:**
- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Vor jeder Antwort ein Zeitstempel „[TT.MM., HH:MM]“, immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date`), nie geschätzt. Stempel und Korrekturen stehen in der Antwort am Ende, nicht in Zwischenmeldungen (die siehst du nicht).
- Zu jedem Build der direkte Link (Release oder Artefakt) und eine Liste, worauf beim Testen zu achten ist.
- Neue Bilder immer mit der Uhrzeit, zu der sie entstanden sind.
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen.
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
- `FILMBATCH=datei`: mehrere Kampffilme in einem Lauf, je Zeile `name klasse:gegner stufe seed plan [aktionen] [hero=…] [foe=…] [foefirst] [failsaves]`, z. B. `holy cleric:zombie 5 1 XWW item=holy_water`. X löst die nächste Aktion direkt aus, W wartet; Bilder unter `build/screens/films/<name>/`.
- `FILM=klasse:gegner` mit `FILMTAPS` (Tipper durch die Menüs) für Einzelfilme.
- `ABILITYFX=1` (alle Fähigkeits-Effekte in Phasen), `STATUSFX=1` (alle Zustände): Übersichtsblätter in Sekunden, für das Aussehen.
- Kerntests: `./gradlew :core:test` (u. a. Ablauf-, Tödlicher-Treffer- und Untote-Tests). Vor jedem Commit laufen lassen.

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

- **Läuft immer dieselbe Variante? (gefragt 08.10., 17:2x)** Im Code nachgesehen:
  - Gegner-Angriffe: Zufall unter drei, kann aber zweimal hintereinander gleich sein.
  - Gegner getroffen/ausweichen: nicht zufällig, sondern nach der Nummer der Meldung (durch drei geteilt); bei gleichförmigen Runden kann das immer dieselbe Variante treffen.
  - Gegner-Sturz: eine von drei, fest pro Gegner (auch für Taumeln beim tödlichen Treffer); wechselt nur von Kampf zu Kampf.
  - Held-Angriff: nur zwei Schläge je Waffe, abwechselnd. Held getroffen: nur eine Bewegung. Held-Abwehr: fest je Waffe und Gegnerart. Held-Zauber: fest je Fokus. Held-Ausweichen: ein Hüpfer, zwei Seiten.
  - Vorschlag: (1) Gegner: Angriff, Treffer und Ausweichen zufällig, aber nie zweimal hintereinander gleich. (2) Held: zwei weitere Treffer-Bewegungen, eine dritte Abwehr je Waffenart, ein dritter Schlag je Waffe. Von dir freigegeben (08.10.), beide umgesetzt, von dir freigegeben und auf `main` übernommen. Noch offen: Ausweichen des Helden ist weiter nur ein Hüpfer (zwei Seiten); Speer zwei Stöße; Zauber eine Bewegung je Fokus.
- **Gegner im neuen Stil:** eingebaut sind Goblin, Goblin-Späher, Skelett, Kobold, Zombie, Krogg, Grak, Wolf, Grimmzahn, Wildschwein und Riesenratte. Ghul seit 08.10. ebenfalls (von dir bestätigt, Zweig). Goblin-Schamane seit 08.10. ebenfalls (von dir bestätigt, Zweig). Noch im alten Stil: Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte (eigene Körper geplant).

## Zu testen

**Zweig-Build 0.1.222** (Ghul, Schamane, Fernangriffe, mehr Varianten): von dir freigegeben, am 08.10. auf `main` übernommen.



**Version v0.1.210** (veröffentlicht 08.10., 16:46; enthält die bestätigten Zweig-Builds 0.1.207 und 0.1.208). Worauf achten:
- **Weitere Zustände**, sobald sie vorkommen: Vergiftet (Spinne, Hundertfüßer), Blutend (nach Blutstufe; bei „Aus“ nichts), Verlangsamt, Geschwächt (Fluch des Schamanen). Zu schwach, zu stark, stören sie?
- **Noch nicht bestätigt aus v0.1.194:** „Kampftext: weiter automatisch“.

Von dir bestätigt: Goblin-Schamane im neuen Stil, Ghul und Goblin-Späher (08.10., „passt soweit, alles okay“, Zweig-Build 0.1.218), Ghul im neuen Stil (08.10., „passt soweit“, Zweig-Build 0.1.214/0.1.218), Zustand „Betäubt“ (08.10., „funktioniert sehr gut“), Flüssigere Bewegungen (Schritt gleitet, kein Aufblitzen der Endhaltung; Zweig-Build 0.1.207) und Gegner im Takt des Helden (Wolf/Ratte flinker, Bosse langsamer; Zweig-Build 0.1.208; beides seit v0.1.210 auf main), Kampftempo für alle Animationen und langsamere Schläge/Zauber (Zweig-Build 0.1.201, „läuft alles soweit“; seit v0.1.204 auf main), Wildschwein und Riesenratte (neue Figuren, Begegnungen), Stufengrenze 6 (keine EP mehr ab Stufe 6, Beute weiter; seit v0.1.173, steht im Changelog), Tödlicher Treffer gegen eine Schwäche (kein Text beim Taumeln), Zustand „Geblendet“, Blutlache bleibt am Boden liegen, Nebel in der Höhle (Gegner und Lichter nur in Sicht), Abschlusszeile nach Vertreiben und Vernichten, Alchemistenfeuer, Untote zerstören ab Stufe 5, Zustände gehen beim Monster jede Bewegung mit (beim Helden von mir im Film geprüft: Angriff, Ausfallschritt, Zauber), Untote vertreiben unter Stufe 5 (Flucht, nur EP), Zustände am Körper (Aussehen; „behalten wir bei“), Magier- und Kleriker-Effekte, Feuerball, Weihwasser, Zustand „Brennend“, Tasche (Bilder), Kampfende mit Siegesfeld und Sturz des Helden, Spirituelle Waffe (Erscheinen ohne Schlag), Vorräte-Knopf im Testreiter, Trinken im Kampf (schon am Vormittag: „Trank trinken sah top aus“).

Älter, noch nicht bestätigt:

## Gemeldet und geklärt (08.10.)

- **Bewegungen wirken teils springend:** Schritt beim Angriff sprang im Bildtakt, Endhaltung blitzte beim Meldungswechsel auf. Behoben im Zweig-Build 0.1.207, von dir bestätigt.
- **Gegner schneller als der Held:** verschiedene Grundzeiten (Gegner etwa 1,5-mal so schnell, dazu schneller Anlauf). Angeglichen im Zweig-Build 0.1.208 (Wolf/Ratte 15 % flinker, Bosse 12 % langsamer), von dir bestätigt.
- **Trank wird zweimal getrunken (Magier gegen Skelett):** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“. Bleibt so.
- **Gegner hinter der Wand sichtbar (Höhle):** behoben (v0.1.194), von dir bestätigt.
- **Treffermeldung mitten im tödlichen Treffer:** behoben (v0.1.194).
- **Wie das Projekt weiterbetreiben (neue Sitzungen, richtige Stelle)?** `CLAUDE.md` angelegt (08.10.); für jedes größere Thema eine neue Sitzung, alles Wichtige steht im Repository.
- **Glutstab zeigt Armbrust-Bild:** behoben, von dir bestätigt.
- **Spirituelle Waffe schlägt scheinbar doppelt zu:** behoben in v0.1.195, von dir bestätigt.
- **Wunsch: Vorräte im Testreiter auffüllen:** umgesetzt in v0.1.195, von dir bestätigt.
- **Nach Untote vertreiben fehlte eine Abschlussmeldung für den Kampf** (nur „EP erhalten“): Siegesfeld beginnt jetzt mit „… wurde vertrieben!“ bzw. „… wurde vernichtet!“, umgesetzt in v0.1.199, von dir bestätigt. Kein Gold und keine Beute beim Vertreiben ist so gewollt.
- **Blutlache hüpfte bei Bewegungen mit:** behoben in v0.1.200, von dir bestätigt.
- **Zustandsbild blieb beim Angriff am Ruheplatz stehen:** behoben in v0.1.198, beim Monster von dir bestätigt, beim Helden im Film geprüft.
- **Untote vertreiben schwer zu testen (nur einmal pro Kampf, Rettungswurf gelang):** Testschalter „Gegner bestehen keine Rettungswürfe“ in v0.1.197 (zu testen).
- **Text kam beim finalen Schlag, während das Skelett noch taumelte (Heilige Flamme):** behoben in v0.1.196, von dir bestätigt.

## Zu entscheiden

- **Noch mehr Zwischenbilder?** Die Haltungen selbst (Arme, Beine, Waffe) wechseln 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung kurz ab. Nach deinem Test von 0.1.208 vorerst nicht nötig; bei Bedarf als eigener, größerer Umbau (mehr Bilder, längeres Vorabzeichnen zu Kampfbeginn).
- **Zustände am Körper:** Sind Verlangsamt, Geschwächt und Geblendet auf kleinen Gegnern stark genug?
- **Goblin-Schamane (Rückmeldung 08.10.):** erster Entwurf nicht gut, wirkt nicht bedrohlich, ein Arm schien zu fehlen (er lag in der Robe). Zweiter Entwurf (17:03): fast schwarze Robe, rußige Augenhöhlen mit grün glühenden Augen, Blutstreifen über die Nase, Schädelstab mit grün glühenden Augen, grünes Fluchlicht in der freien Hand; drei Haltungen (Stehen, Fluch sammeln, Fluch schleudern). Von dir am 08.10. für gut befunden und freigegeben; eingebaut (Zweig, zu testen).
- **Hörproben:** Auswahl für Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt.

## Geplant

- **Killerschlag:** Ein kritischer Treffer, der ein Monster tötet, bekommt einen besonderen Schlag des Helden in mindestens drei Varianten. Das Trefferbild zerfetzt den Gegner, abgestuft nach der Blutstufe: bei „Aus“ ohne Blut, etwa ein Zerbrechen oder Zusammensacken; bei „Dezent“ und „Deutlich“ immer stärker. Skelette zerspringen in Knochen. Gilt für alle Gegner im neuen Stil.
- **Sterbeanimationen für alle Gegner:** Alle Gegner im neuen Stil haben je drei Stürze und bleiben liegen. Die übrigen (Schamane, Ghul, Spinne, Hundertfüßer, Fledermaus, Stirge, Ockergallerte) bekommen sie beim Umzug in den neuen Stil.

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

- **Netzwerkzugriff im zweiten Claude-Account (09.10.):** In dieser Umgebung sind Gradle und Maven gesperrt, daher laufen hier weder Vorschau noch Tests. Netzwerk in den Umgebungseinstellungen wie beim ersten Account freigeben.
- **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht) – machst du zu Hause.

## Bewusst so gelassen

- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
