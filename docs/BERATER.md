# Berater (Sokrates)

Der Nutzer nennt den Berater seit 13.10. **Sokrates**; Meldungen als „**Sokrates** [TT.MM., HH:MM]“. Vierte Rolle **Diogenes** (Tester, nur melden) siehe `CLAUDE.md`.

Gedächtnis der Beratungssitzung: wie das Spiel gebaut ist, was warum entschieden wurde, was wir gelernt haben. **Höchstens etwa 10 KB.** Nicht wiederholen, was in `CHANGELOG.md` oder `STIL.md` steht, sondern mit Themennummer darauf verweisen. Veraltetes kürzen oder ins `ARCHIV.md`.

Tom und Jerry dürfen unter „Lehren“ selbst eintragen, wenn sie etwas Grundsätzliches lernen (eine Zeile, mit Datum und Thema).

**Sitzungen** (seit 13.10. thematisch benannt, keine Nummern; Regel „Sitzungsname“ in `CLAUDE.md`): 12.10. ab 15:10 Grundsatz; 12.10. Talentliste und Fertigkeiten; 12.10. 22:13–13.10. 09:0x Händler/Oberfläche/Rollen; 13.10. 09:1x–10:0x Questlog, Karte 62c, Händler 59e, Sitzungsname, Ablaufprüfung. **Nachfolger:** „Sokrates – Abläufe verschlanken“ (startet der Nutzer)

**Zuletzt gelesen bis:** `4ccabb6` (13.10., 10:0x) plus dieser Commit

## Ritual

- **Start** (Nutzer schreibt „Berater“ oder „Sokrates“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“: was Tom/Jerry an mich abgegeben haben) (das Leitbild `LEITBILD.md` nur bei Grundsatzfragen), dann nur die Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`). Dazu `tools/story.sh <Stand>` (nur Textänderungen im Spiel, auch `EN alt`); bei Bedarf gegen laufende Zweige (`origin/<zweig>`). Kurz melden, was neu ist, Textänderungen gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): neue Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ neu setzen, auf `main` pushen. **Dann immer den Nachfolger selbst starten** (Nutzer 12.10., 15:0x), Titel **„Sokrates – <Grobthema>“** (seit 13.10. ohne Nummer), oben unter „Sitzungen“ eintragen: `create_session` (mit `source_url`, Zweig, Titel) oder ersatzweise `create_trigger` mit `run_once_at` in 2 Minuten, Name = Titel; Auftrag wie der eigene Start plus nächster Punkt. Dem Nutzer den Weg nennen: „Geplant“ → Aufgabe → „Verlauf“ (steht nicht in der Chatliste).
- **Größere Entwürfe als Dokument** (Nutzer 12.10.): Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will, als Claude-Docs-Dokument (Artefakt), Link in `OFFEN.md` und hier bei den Entscheidungen; nach Freigabe als `docs/<NAME>.md` ins Repo.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist

- **Module:** `core` (Regeln, Kampf, Welt, alle Zeichnungen und Klänge als Daten, ohne Android), `app` (Compose-Oberfläche, Abspielen), `tools/preview` (Bilder, Filme, Hörproben am Rechner; Schalter in `UMGEBUNG.md`). Rund 39.000 Zeilen.
- **Größte Dateien:** `MapRoomIso.kt` (Räume diagonal), `WorldScreen.kt` (Karte, Bedienung, Hintergrund-Anstöße), `BattleScreen.kt`, `WorldArt.kt` (Kartenobjekte), `Dress.kt`/`Doll.kt` (Kleidung, Puppen), `Battle.kt` und `Game.kt` (Regeln, Spielzustand).
- **Zeichnen:** Alles wird zur Laufzeit gezeichnet (SDF-Formen in `art/Sdf.kt`, `Sculpt.kt`), nichts kommt als fertige Grafik. Deshalb ist Zeichenzeit der Engpass (Thema 24): Held auf der Karte 16 Richtungen × 8 Schritte = 128 Bilder, im Kampf über 300.
- **Technik-Einzelheiten** (Fäden, Zwischenspeicher, Leistungs-Lehren 24/30/36): im Archiv, „Aus BERATER.md (12.10., 16:4x)“.
- **Grenzen:** Tom = Leute, Dorf, Innenräume, Technik der Blende. Jerry = Monster, Höhle, Kampf, Klang. Gemeinsame Dateien (`WorldScreen.kt`) nur nach Absprache.
- **Ablauf:** Code auf Zweigen, Build über GitHub, Nutzer testet APK auf Samsung A56 und in MuMu (kein Android Studio), dann Merge durch die Sitzung. Release nur auf Zuruf (21).

## Entscheidungen mit Begründung

- **Nächster Punkt: Ablaufprüfung entscheiden** (13.10., 09:5x, Nutzer will in neuer Sitzung entscheiden). Befund und Empfehlungen (alle „ja“): (1) Entscheidungsseite 63 einziger Eingang für Tom/Jerry/Diogenes, Abschnitt „Rückfragen“ in OFFEN weg (6l auf die Seite), oben „Jetzt installieren: Build, Link, worauf achten“; (2) Sprachsitzung bespricht nur, festgehalten erst nach Commit der Textsitzung (sie meldete zweimal Nichtvorhandenes); (3) Entscheidungstext nur an einem Ort („Wer macht was“ bzw. Bildbuch), THEMEN nur Einwort-Stand, BERATER nur Begründung; (4) Weck-Routinen abschalten, solange keine Selbstarbeit vergeben (16 Läufe/Tag lesen je ~35 KB, bevor sie „fertig“ sehen), sonst früher Abbruch per Stand-Zeile; (5) Startlektüre real ~71 KB (~20.000 Token, nicht 12.000): CHANGELOG nicht mehr beim Start (Teil „Unveröffentlicht“ 20 KB), STIL nur passender Abschnitt; CLAUDE.md (19 KB, in jedem Zug) auf ≤10 KB, Selten-Gebrauchtes (Neustart, Release, Weckruf, Selbstarbeit) nach `ENTWICKLUNG.md`/`SELBST.md`, erst als Entwurf. (6) Neu vom Nutzer: Release-Anstoß – Tom meldet einmal „Zeit für ein Release?“, wenn „Unveröffentlicht“ z. B. mehr als fünf getestete Themen hat oder eine Woche alt ist (Vorschlag, noch nicht bestätigt).
- **Sprachausgabe** (Nutzer 13.10.): im gesprochenen Dialog keine Ansage „Sokrates [Datum, Uhrzeit]“; beim Schreiben bleibt sie.
- **59e, 62c, 64** (13.10., Sprachsitzung): Händler „Alle“ nur noch beim Verkaufen mit Sicherheitsabfrage; Vorrat an 38/39 gekoppelt (Nachfüllen nie nach Rast, Rast geht jederzeit). Karte erinnert statt führt: Marken nur für Entdecktes (Geber blau, Ziel gold), keine Schnellreise (eigene Grundsatzfrage). Questlog als eigenes Thema 64, Entwurf bei mir mit Nutzer. Einzelheiten in `OFFEN.md`.
- **Sitzungsname** (13.10.): thematisch statt Nummer, für alle Rollen; Grund: Liste in der App sprechend, Reihenfolge zeigt das Datum.
- **Rollen** (13.10.; Regeln in `CLAUDE.md`): Berater heißt **Sokrates**, berät bei Strategie, Grundsatz und grundlegendem Design (Story, Richtung, einheitliches Aussehen, Balance, Geschäftsmodell, große Umbauten), nie Code. Tom/Jerry entscheiden Kleines selbst, Grundsätzliches tragen sie unter „Für den Berater“ ein und arbeiten weiter (nicht blockieren). Grund: Nutzer will Grundsatzfragen gebündelt bei uns, ohne dass die Entwicklung steht.
- **Diogenes** (13.10.): vierte Rolle Tester, kein eigener Account (Nutzer: zwei Accounts teuer genug), nur melden, Ablauf in `docs/DIOGENES.md`. Mein Beitrag (Nutzer wollte eigene Ideen statt Zustimmung): ein Prüfbericht statt zwei, Prüfstand (nur Neues prüfen), feste Prüflisten, Befund = Verdacht, Einzelheiten aus `CLAUDE.md` ausgelagert (spart Token jeder Sitzung). Nutzer: „Archimedes“ verworfen, baut statt prüft.
- **Eine Entscheidungsseite (63, 13.10.):** jede Rückfrage an den Nutzer auf eine gemeinsame Seite („Zu entscheiden“/„Anzusehen“), wie Bildbuch aufgebaut; Grund: Fragen gehen in vielen Chats und neuen Sitzungen unter. Tom zieht es vor (heute, nicht Freitag: Nutzer will nicht warten).
- **Oberfläche (59, 60, 12.10.):** Händler und alle Oberflächen schwarz, Gold, Serife wie Textkasten (`STIL.md` „Oberfläche“); Serife mitliefern (Gerätschrift sieht je Gerät anders aus), Pixelschrift nur für kleine Kampfzahlen; Angelegtes nicht verkaufbar (59c). Gebaut im Sammelbuild 0.1.650, Test gut.

- **Nur diagonal** (13, 13.4, 13u, 13w, 12.10.): Gerade Ansicht wirkte flach. Testschalter weg (PR #43), fertige Orte diagonal, Wald/Tiefer Wald/Höhle gerade bis fertig; neue Orte nur diagonal (doppelte Arbeit vermeiden, Nutzer: keine Arbeit in Ansichten gegen das Ziel); alte Ansicht eingefroren (nur Absturz-Fixes), dann gelöscht. Danach Zoomstufe (6l).
- **Sichtbarkeit** (43, 12.10.): diagonal rückt der frühere rechte Rand vor die Kamera. Wichtiges (Leute, Questziele, Eingänge, Feuer) steht frei, Karten werden dafür umgestellt (27b, gegen Toms 27.3); Durchsicht nur um den Helden; Kisten dürfen versteckt sein. Morwen (Tiefer Wald) später bei Tom.
- **Leitbild** (44, 12.10.): `LEITBILD.md` als roter Faden (12 Grundsätze), Einzelheiten in `STIL.md` (Aussehen, Klang, Spiel) und `ENTWICKLUNG.md` (Ansicht, „Ort fertig“, Prüfen, Leistung). SRD = Gerüst, nicht Ziel (44f; Nutzer wollte weg von „nah am SRD“), keine AD&D-Erwähnung (kein zwingender Grund). Freigabe 16 (44a): Killerschlag und Blut „Deutlich“ als Obergrenze, Zerteilen in 3D vorher prüfen. Effekte und Hintergrundklänge bieten Tom/Jerry aktiv an (44d).
- **Geschäftsmodell** (45, 12.10., 13:30): Kapitel 1 kostenlos, dann einmal Vollversion, Kapitel nachkaufbar (45a); nie Werbung, Beutekisten, Wartezeiten (45c, Leitbild 13). Grund: Wer Abkürzungen verkauft, macht das Spiel sonst künstlich zäh.
- **Offen bei mir:** Questlog-Entwurf (64); Heldenbau nach Freigabe als `docs/HELDENBAU.md` ablegen (Rest offen: Namen kursiver Talente, Erkennungszeichen-Standbilder, Jerrys Messung); Prüfungsquests und Umlern-Tempel sind Story (41, mit Nutzer); **45b nach Jerrys Messung 38 von mir aus ansprechen**; 41 Kapitel 2 stößt der Nutzer an.
- **Zufallshöhlen** (48, 12.10.): erst Questhöhlen ganz zufällig, Story-Höhlen später halb-halb (fester Kern), alles zufällig nein. 6–8 Kammern, verschlungen, Schleife nur manchmal, Sackgassen auch leer, Rückweg durch Durchgang nach dem Boss, Beute knapp (Jerry prüft gegen 38). Normale Blende reicht (Boden wird ohnehin bei jedem Betreten neu gezeichnet). Jerry baut 13e allgemein (48b). Nach Kapitel 1.
- **Heldenbau** (49, 50, 12.10.; [Dokument](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)): keine neuen Attribute, Talente als Linien je Merkmal auf jeder geraden Stufe, höchste Stufe nur über Prüfungsquest, Umlernen im Tempel ab Kapitel 3; Klassenpaket mit zwei Pfaden je Klasse, Werwolf als Fluch, gekaufte Klassen nie stärker. Begründungen im Archiv („Aus BERATER.md, 13.10.“).
- **Neustart nur bei großer Sitzung** (11.10.): Startlektüre ~12.000 Token. Nach „ja“ startet die Sitzung ihren Nachfolger selbst (46, 12.10.).
- **Textkasten (42), Klang (18, 24w, 28), Kampf nah am SRD (34, 35):** Begründungen im Archiv (16:4x); Klang-Einzelheiten in `STIL.md`.
- **Grundsatz „spielerfreundlich, einfach, frei“** (33, 12.10.): vier Fragen vor jeder Umsetzung von Ablauf und Bedienung (`STIL.md`).
- **Balance** (38, 12.10.): SRD als Fundament, Stufe 20 Obergrenze, mindestens 7 Kapitel, Stufen 5–14 als Kern, 15–20 erst am Ende; Abweichungen mit Grund in `BALANCE.md`. Plan fertig; Jerrys Messung (Messplan dort) nach 37 und 36.1, vor 13e (38e/38f). Schwierigkeitsgrad (39) nach Messung von „Normal“, Lautstärke-Regler (40).
- **Storyplan** (41, 12.10.): [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d); 4 Augen: Story-Änderungen erst nach Nutzer + Berater an Tom/Jerry (Dokument → „freigegeben“ → `docs/STORY.md` → bauen → `tools/story.sh` prüfen). Kapitel 2: Einstieg „Wer ist der Graue Prophet?“ (drei Entwürfe), Stufe 8 am Ende; Kapitel 1 aus `Story.kt`/`Jobs.kt` lesen. Nachtragen: Heldensätze 29.4. Einzelheiten im Archiv.

## Lehren

- **Eigene Ideen einbringen** (13.10.): Nutzer: „du findest alles sinnvoll, was ich vorschlage … du bist mein Berater“. Jeden Vorschlag des Nutzers auf Lücken, Kosten und Doppelungen prüfen und Eigenes ergänzen, nicht nur zustimmen.
- **Sprachsitzung parallel** (13.10.): Der Nutzer spricht oft per Sprache mit einer zweiten Sokrates-Sitzung, die Aufträge herüberreicht. Aufträge nur ausführen, wenn der Nutzer sie im Gespräch freigegeben hat; danach knapp mit Commit melden. Behauptungen der Sprachsitzung über Werkzeuge prüfen (13.10.: „Umbenenn-Werkzeug“ gab es hier nicht).

- **Wiederholte Rückfragen prüfen** (12.10.): Vor dem Wiederholen einer Rückfrage in `OFFEN.md` nachsehen, ob Tom/Jerry sie schon mit dem Nutzer geklärt haben (26b, 34.1, 35a waren es).
- **Docs-Werkzeug** (41): Einfache Zeilenumbrüche in Markdown verschmelzen zu einem Absatz; Dialogzeilen mit Leerzeile trennen.
- **Notizen vor dem Ändern frisch holen** (12.10.): Tom/Jerry ändern `OFFEN.md` im Minutentakt; zweimal schlug mein Ersetzen fehl, weil sich die Übergabe geändert hatte. Erst `git pull`, Treffer prüfen (`assert`), dann committen; nie nach fehlgeschlagenem Ersetzen blind committen.
- **Große Dokumente teuer** (12.10.): Storyplan ganz einlesen kostet viel; nur lesen, wenn am Dokument gearbeitet wird.
- **Vor dem Absenden gegenlesen** (12.10., 13:10): Ein Bruchstück eigener Überlegungen („ab 20 KB teuer“) rutschte sinnlos in eine Antwort, eine Rückfrage stand ohne Nummer im Fließtext. Prüfen: jedes Fragezeichen in der nummerierten Liste? Jeder Satz mit Bezug?
- **Selbstverständliches nicht fragen** (44d): „nur Klänge oder auch sichtbare Effekte?“ war unnötig; im Sinne des Nutzers entscheiden und nennen.
- **Berater-Werkzeug:** Nach Push aus `../bornim-main` zeigt die Hauptkopie die eigenen Notizen als „geändert“ (gleicher Zweig, alter Index). Nie committen (dreht Änderungen zurück), sondern `git reset --hard HEAD` in der Hauptkopie; vom Nutzer freigegeben 12.10., 13:5x.
- **Erst prüfen, dann Kosten nennen** (48, 12.10.): Ladezeit als Kostenpunkt genannt, ohne nachzusehen; sie war keiner. Technische Behauptungen vorher kurz im Code prüfen.

- **Rückfragen des Beraters** (Nutzer 13.10.): an den Nutzer immer hier im Gespräch stellen (nummeriert, mit Empfehlung), nicht über die Entscheidungsseite 63 – die ist der Eingang für fertige Fragen von Tom, Jerry und Diogenes. Erst nach der Entscheidung in die Notizen eintragen.

## Deine Linie (der Nutzer)

- Düster, erwachsen, glaubwürdig; nie niedlich (`STIL.md` → Richtung).
- Erst reden, dann arbeiten; eine Rückfrage ist keine Freigabe. Keine Arbeit in Sackgassen (Ansichten, die wegfallen). Vor großen optischen Änderungen Standbilder, keine Filmstreifen.
- Was funktioniert, muss er nicht erfahren; kurze, nummerierte Rückfragen mit Empfehlung.
- Wahl des Spielers, Optionen, individuell und lebendig (49/50). Generisches Maskulinum, nie weibliche oder gegenderte Formen (12.10.).
