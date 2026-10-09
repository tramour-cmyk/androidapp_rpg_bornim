# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 09.10.2026, 08:20 (Berliner Zeit).

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

## Übergabe-Notiz (für jede neue Sitzung)

Stand der Übergabe: 08.10.2026, 14:14 (Berliner Zeit). Die Datei `CLAUDE.md` im Hauptordner fasst die Regeln kurz zusammen und wird zu Beginn jeder Sitzung automatisch gelesen. Wer hier weitermacht, liest zuerst diese Notiz, dann den Rest dieser Liste, die [Stil-Leitlinien](STIL.md) und den Anfang der [Änderungshistorie](../CHANGELOG.md).

**Projekt:** „Chroniken von Bornim“, Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung der Figuren und Gegner), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner). Aktueller Stand: v0.1.226 auf `main`.

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


## Zu testen

**Zweig-Build 0.1.241** (09.10., 07:59): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37890923551/artifacts/11598626801). Worauf achten:
- **Treffer ohne Flackern** (gefragt 09.10., Vorschlag 1 + 2 + 3 von dir freigegeben): kein weißes Blinken mehr. Beim Aufprall eines Nahkampfschlags kurzes Innehalten, dann färbt sich der Getroffene kurz dunkelrot. Zu schwach, zu stark, zu lang?
- Kritische Treffer: kurzes Rütteln des Bildes. Störend oder passend?
- Zuckt der Getroffene im richtigen Moment, kommen Blut und Geräusch mit dem Aufprall?
- **Ghul** (gemeldet 08.10.: Klauenangriff nicht zu sehen): Klauenhieb von dir bestätigt (09.10.).
- **Goblin-Späher und Schamane** (gemeldet 08.10.: Pfeil startet nicht am Bogen): Pfeil vom Bogen, Feuerpfeil und Fluch des Schamanen von dir bestätigt (09.10.).
- Treffer am Monster: von dir bestätigt (09.10.).
- **Held zittert bei jedem Treffer (gemeldet 09.10.):** Das war ein altes seitliches Wackeln des Helden bei jedem Treffer, unabhängig vom neuen Rütteln bei kritischen Treffern. Entfernt im Zweig-Build 0.1.246 (09.10., 08:43): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37894682693/artifacts/11599822324). Jetzt gilt für Held und Gegner gleich: normaler Treffer = Innehalten (Nahkampf) und dunkelrote Färbung, kritischer Treffer zusätzlich Rütteln des Bildes.

**Zweig-Build 0.1.251** (09.10., 09:35; enthält auch 0.1.246): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37899502580/artifacts/11601738421). **Neue Tiere im Kampf** (Entwurf am 09.10. von dir freigegeben): Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte im neuen Stil, im Film geprüft. Riesenspinne von dir bestätigt (09.10.: Aussehen, Angriffe, Sterbeanimation passen). Noch offen: Hundertfüßer, Fledermaus, Stirge, Gallerte. Worauf achten: Größe im Bild (gegenüber Wolf und Held kleiner als nach SRD, damit sie ins Bild passen), Angriffe treffen sichtbar, Stürze, Aussehen im Kampflicht (Höhle, Nacht). Testkämpfe im Test-Reiter.

**Zweig-Build 0.1.254** (09.10., 10:01; enthält alles aus 0.1.251): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37902087902/artifacts/11603220049). **Gift greift nicht mehr an** (gemeldet 09.10., zweimal: Riesenspinne schien nach „vergiftet“ und bei jedem Giftschaden erneut anzugreifen). Ursache: Der Giftschaden zu Beginn der Runde wurde wie ein Schlag des Gegners abgespielt; galt auch für Brennen und Bluten. Behoben, im Film geprüft.

**Zweig-Build 0.1.265** (09.10., 10:32; enthält alles aus 0.1.254): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37905252687/artifacts/11604391717). **Weiße Trefferzeichen entfernt** (gefragt 09.10., Vorschlag 1 von dir freigegeben): Kein weißes Zeichen mehr bei Biss, Hieb, Stich und stumpfen Waffen; der Treffer zeigt sich durch Innehalten, Rotfärbung und Blut im Augenblick des Aufpralls. Im Film geprüft (Goblin, Wolf, Skelett). Worauf achten: Fehlt dir etwas, ist der Treffer noch gut genug zu erkennen, auch bei Blutstufe „Aus“?

**Ebenfalls in 0.1.251: Tatendrang einmal pro Rast** (deine Entscheidung 09.10., Möglichkeit c): Tatendrang steht nach dem Einsatz erst nach einer Rast am Lagerfeuer oder im Gasthaus wieder bereit (auch ein Stufenaufstieg füllt auf). Im Kampfmenü steht „0/1“, solange er verbraucht ist.

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

- **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht) – machst du zu Hause.

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). In Testkämpfen im Dorf erreichen sich Held und Gegner beim Angriff nicht (alte Kulisse ohne berechneten Schritt); kein Fehler, so gelassen (08.10.). Testkämpfe im Wald oder in der Höhle machen. Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
