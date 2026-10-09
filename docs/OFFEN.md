# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 09.10.2026, 10:55 (Berliner Zeit).

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

- **Killerschlag:** umgesetzt (09.10.), im Film geprüft, Zweig-Build 0.1.292 zu testen.

## Zu testen

**Zweig-Build 0.1.292** (09.10., 13:07): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37921434357/artifacts/11612556973). **Killerschlag** (Entwürfe von dir am 09.10. freigegeben). Zum Testen im Test-Reiter „Held trifft immer kritisch“ einschalten, Blutstufe im Menü umstellen. Worauf achten:
- Die drei Schläge des Helden (je Waffe): passen Bewegung und Wucht, ist das längere Innehalten gut?
- Blutstufe Aus (Zusammensacken, dunkler), Dezent (Blutschwall, Lache), Deutlich (Zerteilen bzw. Loch beim Durchbohren).
- Skelett zerspringt, Gallerte platzt, Zombie/Ghul dunkler Schleim; Tiere und Fledermäuse. (Frage 09.10.: Skelett liegt im Entwurf als Haufen am unteren Bildrand – im Spiel liegen die Teile dort, wo es stand; Standbild 13:05 geschickt. Ob ein flacher Streifen aus Knochen und Schildstücken so passt, wartet auf deine Rückmeldung.)
- Bleiben die Teile liegen, bis das Siegesfeld kommt?
- **Nachbesserung (gemeldet 09.10.: Zerteilen beim Wolf wirkt künstlich; Zombie passt):** Tiere bei „Deutlich“ jetzt mit klaffender Wunde statt Zerteilen (Vorschlag 3, von dir gewählt); menschenähnliche Gegner werden weiter zerteilt. Im Zweig-Build 0.1.298 (09.10., 14:42): [Artefakt bornim-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/37931400026/artifacts/11616671720).

**Version v0.1.279** (veröffentlicht 09.10., 11:16): [bornim.apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/download/v0.1.279/bornim.apk). Vollständig von dir bestätigt (09.10.), zuletzt Tatendrang einmal pro Rast („funktioniert“).

**Noch nicht bestätigt aus älteren Versionen:**
- Zustände Verlangsamt und Geschwächt (Fluch des Schamanen), sobald sie vorkommen: zu schwach, zu stark, stören sie? Sind sie und „Geblendet“ auf kleinen Gegnern stark genug?
- „Kampftext: weiter automatisch“ (seit v0.1.194).

## Zu entscheiden

- **Noch mehr Zwischenbilder?** Die Haltungen selbst (Arme, Beine, Waffe) wechseln 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung kurz ab. Nach deinem Test von 0.1.208 vorerst nicht nötig; bei Bedarf als eigener, größerer Umbau (mehr Bilder, längeres Vorabzeichnen zu Kampfbeginn).
- **Hörproben:** Auswahl für Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt.

## Geplant

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

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). In Testkämpfen im Dorf erreichen sich Held und Gegner beim Angriff nicht (alte Kulisse ohne berechneten Schritt); kein Fehler, so gelassen (08.10.). Testkämpfe im Wald oder in der Höhle machen. Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
