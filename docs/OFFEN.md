# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 08.10.2026, 16:39 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

**Arbeitsweise (seit 08.10.2026):**
- Jede Meldung von dir (Fehler, Anregung, Idee, Frage zum Nachhalten) kommt sofort hier hinein, auch wenn sie nicht gleich umgesetzt wird.
- Nach jeder erledigten Arbeit (von dir getestet oder von mir umgesetzt) wird diese Liste geprüft: Erledigtes wandert in die Änderungshistorie, Offenes bleibt stehen.
- Zu jedem neuen Test-Build steht unter „Zu testen“, worauf du achten sollst.

## Übergabe-Notiz (für jede neue Sitzung)

Stand der Übergabe: 08.10.2026, 14:14 (Berliner Zeit). Die Datei `CLAUDE.md` im Hauptordner fasst die Regeln kurz zusammen und wird zu Beginn jeder Sitzung automatisch gelesen. Wer hier weitermacht, liest zuerst diese Notiz, dann den Rest dieser Liste, die [Stil-Leitlinien](STIL.md) und den Anfang der [Änderungshistorie](../CHANGELOG.md).

**Projekt:** „Chroniken von Bornim“, Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung der Figuren und Gegner), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner). Aktueller Stand: v0.1.204 auf `main`.

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

- **Gegner im neuen Stil:** eingebaut sind Goblin, Goblin-Späher, Skelett, Kobold, Zombie, Krogg, Grak, Wolf, Grimmzahn, Wildschwein und Riesenratte. Noch im alten Stil: Goblin-Schamane und Ghul (Entwürfe auf der Puppe liegen vor), Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte (eigene Körper geplant).

## Zu testen

**Zweig-Build 0.1.208** (Zweig `claude/status-next-steps-pqvzz8`, PR #2): von dir getestet, „alles gut, keine Fehler“ (08.10., 16:39). Wartet auf die Übernahme nach `main`.

**Version v0.1.204** (veröffentlicht). Worauf achten:
- **Weitere Zustände**, sobald sie vorkommen: Vergiftet (Spinne, Hundertfüßer), Blutend (nach Blutstufe; bei „Aus“ nichts), Betäubt, Verlangsamt, Geschwächt (Fluch des Schamanen). Zu schwach, zu stark, stören sie?
- **Noch nicht bestätigt aus v0.1.194:** „Kampftext: weiter automatisch“.

Von dir bestätigt: Flüssigere Bewegungen (Schritt gleitet, kein Aufblitzen der Endhaltung; Zweig-Build 0.1.207) und Gegner im Takt des Helden (Wolf/Ratte flinker, Bosse langsamer; Zweig-Build 0.1.208), Kampftempo für alle Animationen und langsamere Schläge/Zauber (Zweig-Build 0.1.201, „läuft alles soweit“; seit v0.1.204 auf main), Wildschwein und Riesenratte (neue Figuren, Begegnungen), Stufengrenze 6 (keine EP mehr ab Stufe 6, Beute weiter; seit v0.1.173, steht im Changelog), Tödlicher Treffer gegen eine Schwäche (kein Text beim Taumeln), Zustand „Geblendet“, Blutlache bleibt am Boden liegen, Nebel in der Höhle (Gegner und Lichter nur in Sicht), Abschlusszeile nach Vertreiben und Vernichten, Alchemistenfeuer, Untote zerstören ab Stufe 5, Zustände gehen beim Monster jede Bewegung mit (beim Helden von mir im Film geprüft: Angriff, Ausfallschritt, Zauber), Untote vertreiben unter Stufe 5 (Flucht, nur EP), Zustände am Körper (Aussehen; „behalten wir bei“), Magier- und Kleriker-Effekte, Feuerball, Weihwasser, Zustand „Brennend“, Tasche (Bilder), Kampfende mit Siegesfeld und Sturz des Helden, Spirituelle Waffe (Erscheinen ohne Schlag), Vorräte-Knopf im Testreiter, Trinken im Kampf (schon am Vormittag: „Trank trinken sah top aus“).

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
- **Goblin-Schamane und Ghul:** Rückmeldung zu den Entwürfen, dann Einbau in den Kampf.
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

- **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht) – machst du zu Hause.

## Bewusst so gelassen

- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
