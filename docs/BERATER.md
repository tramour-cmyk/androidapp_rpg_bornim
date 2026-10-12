# Berater

Gedächtnis der Beratungssitzung: wie das Spiel gebaut ist, was warum entschieden wurde, was wir gelernt haben. **Höchstens etwa 10 KB.** Nicht wiederholen, was in `CHANGELOG.md` oder `STIL.md` steht, sondern mit Themennummer darauf verweisen. Veraltetes kürzen oder ins `ARCHIV.md`.

Tom und Jerry dürfen unter „Lehren“ selbst eintragen, wenn sie etwas Grundsätzliches lernen (eine Zeile, mit Datum und Thema).

**Zuletzt gelesen bis:** `4523ba6` (12.10., 10:47)

## Ritual

- **Start** (Nutzer schreibt „Berater“): diese Datei, dann `docs/OFFEN.md`, dann nur die Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`). Dazu `tools/story.sh <Stand>` (nur Textänderungen im Spiel, auch `EN alt`); bei Bedarf gegen laufende Zweige (`origin/<zweig>`). Kurz melden, was neu ist, Textänderungen gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): neue Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ neu setzen, auf `main` pushen.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist

- **Module:** `core` (Regeln, Kampf, Welt, alle Zeichnungen und Klänge als Daten, ohne Android), `app` (Compose-Oberfläche, Abspielen), `tools/preview` (Bilder, Filme, Hörproben am Rechner; Schalter in `UMGEBUNG.md`). Rund 39.000 Zeilen.
- **Größte Dateien:** `MapRoomIso.kt` (Räume diagonal), `WorldScreen.kt` (Karte, Bedienung, Hintergrund-Anstöße), `BattleScreen.kt`, `WorldArt.kt` (Kartenobjekte), `Dress.kt`/`Doll.kt` (Kleidung, Puppen), `Battle.kt` und `Game.kt` (Regeln, Spielzustand).
- **Zeichnen:** Alles wird zur Laufzeit gezeichnet (SDF-Formen in `art/Sdf.kt`, `Sculpt.kt`), nichts kommt als fertige Grafik. Deshalb ist Zeichenzeit der Engpass (Thema 24): Held auf der Karte 16 Richtungen × 8 Schritte = 128 Bilder, im Kampf über 300.
- **Hintergrund-Fäden:** `MapGround` (fester Pool „map-ground“), `MapRest` (ein Faden „map-rest“), `MapFigure.prepare` (eigene Fäden für den Helden), `HeroShelf` (gespeicherte Bilder, 24.4), `BattleAhead` (Kampfbilder vorzeichnen, 24.5), ab 24.17 zwei Kerne. Klang: Ortsklang-Schleife in `WorldScreen` (24.8, Jerry).
- **Zwischenspeicher:** Viele Kunst-Objekte halten Bilder in Maps. Begrenzt (LRU): `FoeArt`, `MonsterArt`, `HeroBattle`, `CaveScene`. **Unbegrenzt** (einfache `HashMap`): u. a. `WorldArt`, `MapFlora`, `MapTown`, `MapTownIso`, `ActionArt`.
- **Grenzen:** Tom = Leute, Dorf, Innenräume, Technik der Blende. Jerry = Monster, Höhle, Kampf, Klang. Gemeinsame Dateien (`WorldScreen.kt`) nur nach Absprache.
- **Ablauf:** Code auf Zweigen, Build über GitHub, Nutzer testet APK auf Samsung A56 und in MuMu (kein Android Studio), dann Merge durch die Sitzung. Release nur auf Zuruf (21).

## Entscheidungen mit Begründung

- **Diagonale Sicht** statt 0/90/180/270 (13, 10.10.): Auf den Spieler zu und von ihm weg wirkte alles flach. Räume fertig (PR #20), Dorf läuft (5), Höhle folgt (13e, Jerry), Wald (27).
- **Zoomstufe der Karte** (6l): bleibt vorläufig 6,75 Kacheln, bis die diagonale Sicht überall fertig ist.
- **Kapitel 1 vor Neuem** (26, 11.10.): Zielliste in `KAPITEL1.md`; neue Inhalte erst danach.
- **Release nur auf Zuruf** (21): Die Releaseflut störte; Zweig-Builds sind Artefakte.
- **APK nie im Chat, nur Link** (11.10., 21:25): Platz sparen. Artefakt-Downloads gehen seit 12.10. (Vollzugriff).
- **Filme sparsam** (09.10.): 36 s Spielzeit kosteten etwa 5 min. Logik per Kerntest, filmen nur bei sichtbarer Bewegung.
- **Neustart nur bei großer Sitzung** (11.10.): Jede Startlektüre kostet etwa 12.000 Token.
- **Selbstarbeit** mit Routinen alle 3 h und Vorrat je 8 Punkte (22, 23).
- **Klang:** echte CC0-Aufnahmen statt Synthese (18); Systemklänge nur in einer Fassung; Ortsklang nur von sichtbaren Quellen und anwesenden Leuten, **kein Stimmengewirr** (24w nein, 22:06); Musik orchestral und düster, Dorf mittelalterlich (28). Einzelheiten `STIL.md` → Klang.
- **Fremde Inhalte** nur mit Lizenz für kommerzielle Nutzung (Play Store), Quelle je Datei.
- **Grundsatz „spielerfreundlich, einfach, frei“** (33, 12.10.): vier Fragen vor jeder Umsetzung von Ablauf und Bedienung (`STIL.md`).
- **Kampf nah am SRD** (12.10.): „Zug beenden“ jetzt (34, auch um Testkämpfe schnell zu verlieren), „Abwarten“/„Helfen“ erst mit Begleitern (Merkliste). Weihwasser nur gegen Untote, 2W6, sonst ausgegraut mit Hinweis (35): vorher 2W6 gegen alle, unglaubwürdig.
- **Krogg schärfen** (36, 12.10.): erst aufräumen bei gleicher Auflösung (Fellkörnung 0,55 war Hauptgrund), Standbilder Handy/Emulator; nur falls nötig 1,5× mit zugeschnittenen Bildern, vorher messen. Doppelte Auflösung abgelehnt: Krogg ~50 MB → ~200 MB, 4× Zeichenzeit.
- **Kampfmusik** (37, 12.10.): raus `great_labyrinth`, `menace` (Techno), `epic_fight` (Lounge); `boss_ancient_legend` zu tragend für Kampf → Rückkehr des Sonnenamuletts in den Tempel (Jerry Musik, Tom Szene); Jerry sucht 2–3 neue CC0-Kampfstücke, erst Hörproben.
- **Balance** (38, 12.10.): SRD als Fundament, Stufe 20 Obergrenze, mindestens 7 Kapitel, Stufen 5–14 als Kern, 15–20 erst am Ende; Hausregeln nur mit Begründung in `BALANCE.md`. Schwierigkeitsgrad (39) nach Messung von „Normal“, Lautstärke-Regler (40). AD&D nur im Geist (nicht frei lizenziert).
- **Storyplan** (41, 12.10.): Dokument auf Toms Account ([Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)), Nutzer liest und kommentiert dort; je Kapitel Zusammenfassung, Quests, Dialoge wortgetreu, Anmerkungen gesammelt am Ende. Kapitel 1 = Ist-Stand aus `Story.kt` und `Jobs.kt` (Zweig `great-sagan`). Fertige Kapitel als `docs/STORY.md` ins Repo. **4 Augen:** Story-Änderungen gehen erst nach Abstimmung Nutzer und Berater an Tom/Jerry, Kapitel 1 erst nach dem Test der 12 Tester. Ablauf: Dokument → „freigegeben“ → `docs/STORY.md` mit Themennummer → Tom/Jerry bauen → Berater prüft mit `tools/story.sh`, Nutzer im Test. Englisch übersetzen Tom/Jerry. Nächster Schritt: Plot Kapitel 2 gemeinsam, wenn Tom und Jerry in Selbstarbeit sind; Einstieg Frage „Wer ist der Graue Prophet?“ (Vorgabe Stufe 8 am Ende).
- **Kampfkulisse der Höhle angleichen:** zurückgestellt (Merkliste). Höhle-Flammen und Lichtstrahl (10, 11) bis zur diagonalen Höhle zurückgestellt.

## Lehren

- **Vorzeichnen muss ein festes Ziel haben** (24.5, 11.10.): Im Wolfsrudel wechselte der „nächste Gegner“ ständig, jeder Wechsel brach das Zeichnen ab, Gegner wurden nie fertig. Lösung 24.18: feste Reihenfolge.
- **Erst messen, dann beschleunigen** (24.14): Erster Start sank von 27 s auf 5,9 s, Waffenwechsel von 15,7 s auf 2,9 s, erst nachdem der Test-Reiter Zeiten zeigte.
- **Bilder auf dem Gerät speichern lohnt** (24.4): Neustart 0,1 s statt 27 s.
- **Abstürze ohne Bericht sind blind** (30, 11.10.): Bis heute gab es keinen Absturz-Fänger. Erst Fehlertext holen, dann suchen.
- **Test-Builds von vor einer Korrektur haben sie nicht** (30, 12.10.): 0.1.561 (Jerry) entstand vor PR #40, stürzte ohne Bericht ab. Darum vor jedem Zweig-Build `main` holen (21.5) und beim Testangebot sagen, ob der Fänger drin ist.
- **Gegner sind grobe Pixelkunst** (36): 0,66 px/cm, hart ganzzahlig vergrößert (`width/170`, im breiten Emulator bis ~11×). Starkes Rauschen (`grain`) wird bei wenigen Punkten zu Krisel.
- **Wiederholte Rückfragen prüfen** (12.10.): Vor dem Wiederholen einer Rückfrage in `OFFEN.md` nachsehen, ob Tom/Jerry sie schon mit dem Nutzer geklärt haben (26b, 34.1, 35a waren es).
- **Docs-Werkzeug** (41): Einfache Zeilenumbrüche in Markdown verschmelzen zu einem Absatz; Dialogzeilen mit Leerzeile trennen.
- **Berater-Werkzeug:** Nach Push aus `../bornim-main` zeigt die Hauptkopie die eigenen Notizen als „geändert“ (gleicher Zweig, alter Index). Nicht committen, sondern `git reset --hard HEAD` in der Hauptkopie (Stand ist schon auf `origin/main`).

## Beobachtungen des Beraters (ungeprüft)

- **Zu Thema 30 (geprüft 22:56):** Die Bildspeicher von `HeroBattle`, `MapGround`, `MapFolk`, `MapFigure` sind sauber gesperrt (`synchronized`), gleichzeitiger Zugriff dort ist kaum die Ursache. Offen: unbegrenzte Speicher (`WorldArt`, `MapFlora`, `MapTown`, `MapTownIso`) und Lastspitze nach Niederlage (Kartenwechsel); `BattleAhead.run` ohne Fehlerfang.
- **Zu Thema 30 (12.10., 09:41):** 30.1/30.2/30b (`largeHeap`, 512 MB) auf `main` (PR #40); 0.1.559 ohne Absturz, aber ein Test beweist nichts. Erst nach 2–3 Runden mit Fänger ohne Absturz gilt 30 als erledigt.

## Deine Linie (der Nutzer)

- Düster, erwachsen, glaubwürdig; nie niedlich (`STIL.md` → Richtung).
- Erst reden, dann arbeiten; eine Rückfrage ist keine Freigabe. Vor großen optischen Änderungen Standbilder, keine Filmstreifen.
- Was funktioniert, muss er nicht erfahren; kurze, nummerierte Rückfragen mit Empfehlung.
