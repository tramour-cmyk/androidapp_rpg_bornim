# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Aufbau, Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `OFFEN.md`, Gestaltung im Bildbuch, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARCHIV.md` („Aus BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Sitzungen** (thematisch benannt; ältere im Archiv): 13.10. 10:08–11:0x Ablaufprüfung (65); 13.10. ab 11:1x „Sokrates – Abläufe verschlanken“ (65.4). **Nachfolger:** –

**Zuletzt gelesen bis:** `b9e5d783` (13.10., 11:15) plus diese Commits

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“; `LEITBILD.md` nur bei Grundsatzfragen), dann nur Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`), dazu `tools/story.sh <Stand>` (Textänderungen im Spiel, auch `EN alt`; bei Bedarf gegen `origin/<zweig>`). Kurz melden, Texte gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ setzen, pushen. **Dann immer den Nachfolger selbst starten** (Nutzer 12.10.), Titel „Sokrates – <Grobthema>“, oben unter „Sitzungen“ eintragen: `create_session` (mit `source_url`, Zweig, Titel) oder ersatzweise `create_trigger` mit `run_once_at` in 2 Minuten, Name = Titel; Auftrag wie der eigene Start plus nächster Punkt. Dem Nutzer den Weg nennen: „Geplant“ → Aufgabe → „Verlauf“ (steht nicht in der Chatliste).
- **Größere Entwürfe als Claude-Docs-Dokument** (Nutzer 12.10.; Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will), Link in `OFFEN.md` und hier; nach Freigabe als `docs/<NAME>.md` ins Repo.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist

- **Module:** `core` (Regeln, Kampf, Welt, alle Zeichnungen und Klänge als Daten), `app` (Compose), `tools/preview` (Bilder, Filme, Hörproben; Schalter in `UMGEBUNG.md`). Rund 39.000 Zeilen. Größte Dateien: `MapRoomIso.kt`, `WorldScreen.kt`, `BattleScreen.kt`, `WorldArt.kt`, `Dress.kt`/`Doll.kt`, `Battle.kt`, `Game.kt`.
- **Zeichnen** zur Laufzeit (SDF in `art/Sdf.kt`, `Sculpt.kt`), keine fertigen Grafiken; Zeichenzeit ist der Engpass (24: Held 128 Bilder auf der Karte, über 300 im Kampf). Technik-Lehren 24/30/36 im Archiv („12.10., 16:4x“).
- **Grenzen:** Tom = Leute, Dorf, Innenräume, Technik der Blende; Jerry = Monster, Höhle, Kampf, Klang (13e seit 13y bei Tom). `WorldScreen.kt` nur nach Absprache.
- **Ablauf:** Code auf Zweigen, Build über GitHub, Nutzer testet nur APKs auf Samsung A56 und MuMu (kein Android Studio), Merge durch die Sitzung, Release nur auf Zuruf.

## Begründungen der Entscheidungen

- **Abläufe (65):** `CLAUDE.md` lesen nur Sitzungen, darum knapp für uns; Auslagern nur bei seltenem, eindeutigem Anlass mit Auslöserzeile in `CLAUDE.md`; ≤10 KB für `CLAUDE.md` aufgegeben (ginge nur mit Verlust). Oberster Grundsatz des Nutzers: nichts Aufgabenrelevantes verlieren. Weck-Routinen pausieren statt löschen (Repo-Einstellung von Hand gesetzt). Release-Frage bei fünf Themen oder sieben Tagen. **65.4** jeder Text an einem Ort: Doppelungen kosten Token beim Start und laufen auseinander (59e stand an sechs Stellen).
- **Rollen:** Grundsatzfragen gebündelt beim Berater, ohne dass die Entwicklung steht (Tom/Jerry blockieren nicht). Diogenes ohne eigenen Account (zwei sind teuer genug); ein Prüfbericht, Prüfstand, feste Listen, Befund = Verdacht, Ablauf ausgelagert (spart Token jeder Sitzung). „Archimedes“ verworfen (baut statt prüft). Sitzungsnamen thematisch: Liste sprechend, Reihenfolge zeigt das Datum.
- **Entscheidungsseite (63):** Fragen gingen in vielen Chats und neuen Sitzungen unter.
- **Karte und Händler (62c, 59e):** Karte erinnert statt führt (Marken nur für Entdecktes, keine Schnellreise); Vorrat nie nach Rast, weil Rast jederzeit geht. 62c kommt grundsätzlich wieder auf den Tisch, mit Questlog 64.
- **Oberfläche (59, 60):** schwarz, Gold, Serife wie der Textkasten; Serife mitliefern, weil Geräteschriften je Gerät anders aussehen.
- **Nur diagonal (13):** gerade Ansicht wirkte flach; keine doppelte Arbeit in Ansichten gegen das Ziel.
- **Sichtbarkeit (43):** diagonal rückt der rechte Rand vor die Kamera; Wichtiges steht frei, Karten werden umgestellt statt Durchsicht überall.
- **Leitbild (44):** ein roter Faden statt verstreuter Regeln; SRD ist Gerüst, nicht Ziel (Nutzer wollte weg von „nah am SRD“); keine AD&D-Erwähnung (kein Grund). Blut „Deutlich“ als Obergrenze, Zerteilen in 3D vorher prüfen. Effekte und Hintergrundklänge bieten Tom/Jerry aktiv an (44d).
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Zufallshöhlen (48):** erst Questhöhlen zufällig, Story-Höhlen mit festem Kern; normale Blende reicht (Boden wird ohnehin neu gezeichnet, geprüft). Kammern, Schleifen, Beute im Archiv.
- **Heldenbau (49, 50; [Dokument](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Talent jede gerade Stufe (sonst Kapitel ohne Wahl), Merkmale nie kaufbar (Sperre gegen Magier-Tank), gekaufte Klassen nie stärker.
- **Balance (38):** SRD als Fundament, Stufen 5–14 als Kern über mindestens 7 Kapitel, Abweichungen mit Grund in `BALANCE.md`; Schwierigkeitsgrad erst nach Messung von „Normal“.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen (Nutzer + Berater) vor jeder Story-Änderung, damit Texte nicht von Entwicklern erfunden werden. Kapitel 2 beginnt mit „Wer ist der Graue Prophet?“ (drei Entwürfe), endet auf Stufe 8; Kapitel 1 aus `Story.kt`/`Jobs.kt` lesen. Nachtragen: Heldensätze 29.4.
- **Neustart nur bei großer Sitzung:** Startlektüre kostet viel; nach „ja“ startet die Sitzung ihren Nachfolger selbst (46).
- **Sprachausgabe:** im gesprochenen Dialog keine Ansage „Sokrates [Datum]“, beim Schreiben schon.

**Offen bei mir:** 62c Karte/Orte mit 64 Questlog (Entwurf mit Nutzer); `docs/HELDENBAU.md` nach Durchsicht der kursiven Talentnamen (offen auch Erkennungszeichen-Standbilder, Jerrys Messung); Prüfungsquests und Umlern-Tempel (41, mit Nutzer); **45b nach Jerrys Messung 38 ansprechen**; 41 Kapitel 2 stößt der Nutzer an.

## Lehren

- **Eigene Ideen einbringen** (13.10.): „du findest alles sinnvoll, was ich vorschlage … du bist mein Berater“. Jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen und Eigenes ergänzen.
- **Sprachsitzung** (13.10.): reicht Aufträge herüber; nur ausführen, was der Nutzer im Gespräch freigegeben hat, dann knapp mit Commit melden. Ihre Behauptungen über Werkzeuge und Dateien im Repo prüfen (lag zweimal falsch: „Umbenenn-Werkzeug“, „SELBST.md gibt es nicht“).
- **Entscheidungen einzeln abwarten** (13.10.): „ich folge deiner Empfehlung“ galt einem Punkt, nicht allen.
- **Rückfragen des Beraters** (Nutzer 13.10.) an den Nutzer immer im Gespräch stellen (nummeriert, Empfehlung), nicht über die Entscheidungsseite (die ist für Tom, Jerry, Diogenes); erst nach Entscheidung in die Notizen.
- **Wiederholte Rückfragen prüfen** (12.10.): vorher in `OFFEN.md` nachsehen, ob Tom/Jerry sie schon geklärt haben.
- **Notizen vor dem Ändern frisch holen** (12.10.): erst `git pull`, Treffer prüfen (`assert`), nie nach fehlgeschlagenem Ersetzen blind committen.
- **Hauptkopie nach Push aus `../bornim-main`** zeigt Notizen als „geändert“: nie committen, `git reset --hard HEAD` (freigegeben 12.10.).
- **Erst prüfen, dann Kosten nennen** (48): technische Behauptungen vorher im Code prüfen.
- **Auslagern in Startlektüre spart nichts** (65): vorher prüfen, ob das Ziel beim Start gar nicht gelesen wird.
- **Gekürzte Regeln unabhängig gegenprüfen** (65): erste Fassung verlor Abschwächungen; immer zweite Prüfrunde durch einen unabhängigen Prüfer.
- **Vor dem Absenden gegenlesen** (12.10.): jedes Fragezeichen in der nummerierten Liste, jeder Satz mit Bezug. Selbstverständliches nicht fragen (44d).
- **Docs-Werkzeug** (41): einfache Zeilenumbrüche verschmelzen; Dialogzeilen mit Leerzeile trennen. Große Dokumente nur lesen, wenn daran gearbeitet wird.

## Deine Linie (der Nutzer)

- Düster, erwachsen, glaubwürdig; nie niedlich (`STIL.md` → Richtung).
- Erst reden, dann arbeiten; eine Rückfrage ist keine Freigabe. Keine Arbeit in Sackgassen. Vor großen optischen Änderungen Standbilder, keine Filmstreifen.
- Was funktioniert, muss er nicht erfahren; kurze, nummerierte Rückfragen mit Empfehlung.
- Wahl des Spielers, Optionen, individuell und lebendig (49/50). Generisches Maskulinum, nie weibliche oder gegenderte Formen.
