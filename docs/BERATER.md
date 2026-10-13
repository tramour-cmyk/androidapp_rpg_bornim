# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Aufbau, Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `OFFEN.md`, Gestaltung in den Beschlüssen, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARCHIV.md` („Aus BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Sitzungen** (ältere im Archiv): ab 13.10. 16:16 „Kapitel 2 Storyplan“ (41m, 69a–d, 48d–f, 62p).

**Nächster Punkt:** offen beim Nutzer **41n** (Bohlensteg Kultlager–Schilfrode), **41o** (Höhlen frei betretbar), **41p** (Ort im Aushang in Worten), **48d–48f** (Startwert je Spielstand, leer bleibt leer, Erzeuger-Version speichern), Rest **41m** (Kultlager, Aschfurt im Moor, nur Südstraße); alle Empfehlung ja. Danach Umfang 41j–m und Karte in den Storyplan. **68** Tempelszene: Textentwurf.

**Zuletzt gelesen bis:** dieser Commit (13.10., 16:1x)

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“; `LEITBILD.md` nur bei Grundsatzfragen), dann nur Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`), dazu `tools/story.sh <Stand>` (Textänderungen im Spiel, auch `EN alt`; bei Bedarf gegen `origin/<zweig>`). Kurz melden, Texte gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ setzen, pushen. **Dann Nachfolger:** Titel „Sokrates – <Grobthema>“, oben unter „Sitzungen“ eintragen, Auftrag wie der eigene Start plus nächster Punkt. Der Nutzer startet ihn selbst mit kurzer Nachricht („Sokrates“; 13.10.: sonst verschwindet er unter „Geplant“), nichts zum Kopieren: den nächsten Punkt hier unter „Nächster Punkt“ eintragen; nur auf Wunsch selbst starten (`create_session` mit `source_url`, Zweig, Titel; ersatzweise `create_trigger`, `run_once_at` in 2 Minuten).
- **Größere Entwürfe als Claude-Docs-Dokument** (Nutzer 12.10.; Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will), Link in `OFFEN.md` und hier; nach Freigabe als `docs/<NAME>.md` ins Repo.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist

- **Module:** `core` (Regeln, Kampf, Welt, alle Zeichnungen und Klänge als Daten), `app` (Compose), `tools/preview` (Bilder, Filme, Hörproben; Schalter in `UMGEBUNG.md`).
- **Zeichnen** zur Laufzeit (SDF in `art/Sdf.kt`, `Sculpt.kt`), keine fertigen Grafiken; Zeichenzeit ist der Engpass (24: Held 128 Bilder auf der Karte, über 300 im Kampf). Technik-Lehren 24/30/36 im Archiv („12.10., 16:4x“).
- **Grenzen:** Tom = Leute, Dorf, Innenräume, Technik der Blende; Jerry = Monster, Höhle, Kampf, Klang (13e seit 13y bei Tom). `WorldScreen.kt` nur nach Absprache.
- **Ablauf:** Code auf Zweigen, Build über GitHub, Nutzer testet nur APKs auf Samsung A56 und MuMu (kein Android Studio), Merge durch die Sitzung, Release nur auf Zuruf.

## Begründungen der Entscheidungen

- **Abläufe (65):** `CLAUDE.md` lesen nur Sitzungen, darum knapp für uns; Auslagern nur bei seltenem, eindeutigem Anlass mit Auslöserzeile in `CLAUDE.md`; ≤10 KB für `CLAUDE.md` aufgegeben (ginge nur mit Verlust). Oberster Grundsatz des Nutzers: nichts Aufgabenrelevantes verlieren. Weck-Routinen pausieren statt löschen (Repo-Einstellung von Hand gesetzt). **65.4** jeder Text an einem Ort: Doppelungen kosten Token beim Start und laufen auseinander (59e stand an sechs Stellen).
- **Rollen:** Grundsatzfragen gebündelt beim Berater, ohne dass die Entwicklung steht (Tom/Jerry blockieren nicht). Diogenes ohne eigenen Account (zwei sind teuer genug); ein Prüfbericht, Prüfstand, feste Listen, Befund = Verdacht, Ablauf ausgelagert (spart Token jeder Sitzung). „Archimedes“ verworfen (baut statt prüft). Sitzungsnamen thematisch: Liste sprechend, Reihenfolge zeigt das Datum.
- **Entscheidungsseite (63):** Fragen gingen in vielen Chats und neuen Sitzungen unter. **„Bildbuch“ → „Beschlüsse“** (13.10.): Inhalt ist Entschiedenes, Bilder nur Mittel; Paar offen ↔ beschlossen. Link/Freigabe bleiben. **65.7** (16:14): kein Abschnitt „Erledigt“ mehr, weil alles schon in Beschlüssen und `CHANGELOG.md` steht und die Liste nur wuchs.
- **Karte und Händler (62c, 59e):** Karte erinnert statt führt (Marken nur für Entdecktes, keine Schnellreise); Vorrat nie nach Rast, weil Rast jederzeit geht. 62e–62m (13.10.): Bekannte am gewohnten Ort statt live (der Held weiß nicht, wo jemand gerade ist), Beschriftung und Hörensagen erst nach Wissen, drei Ebenen (Nutzer), Lagerfeuer als Dienst (Nutzer), Hilfe nach Schwierigkeitsgrad statt für alle. **64:** eigener Reiter „Chronik“, weil Quests zwischen Einstellungen untergingen; „Bisher geschehen“ für Rückkehrer nach Pausen; keine Questanzeige im Spielbild (erinnert statt führt).
- **Kartenbegriffe (62p):** Stufen nach Enthaltensein (draußen Gebiet, hinter einem Eingang Grundriss; Nutzer: „die Höhle ist nichts anderes als ein Haus“); „Ebene“ gestrichen, weil auch für Stockwerke benutzt.
- **Oberfläche (59, 60):** schwarz, Gold, Serife wie der Textkasten; Serife mitliefern, weil Geräteschriften je Gerät anders aussehen.
- **Leitbild (44):** ein roter Faden statt verstreuter Regeln; SRD ist Gerüst, nicht Ziel; keine AD&D-Erwähnung (kein Grund). Blut „Deutlich“ als Obergrenze, Zerteilen in 3D vorher prüfen. Effekte und Hintergrundklänge bieten Tom/Jerry aktiv an (44d).
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Zufallshöhlen (48, 41m):** erst Questhöhlen zufällig, Story-Höhlen mit festem Kern; je eine pro Landschaft statt alle am Rastort (Erkundung, Nutzer 16:29). Einzelheiten im Archiv.
- **Heldenbau (49, 50; [Dokument](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Talent jede gerade Stufe (sonst Kapitel ohne Wahl), Merkmale nie kaufbar (Sperre gegen Magier-Tank), gekaufte Klassen nie stärker.
- **Balance (38):** SRD als Fundament, Stufen 5–14 als Kern über mindestens 7 Kapitel, Abweichungen mit Grund in `BALANCE.md`; Schwierigkeitsgrad erst nach Messung von „Normal“.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen (Nutzer + Berater) vor jeder Story-Änderung, damit Texte nicht von Entwicklern erfunden werden. Kapitel 2 beginnt mit „Wer ist der Graue Prophet?“: **Mischung ja (Nutzer 13.10., 14:08)** – Kult mit weitergegebenem Titel trägt sieben Kapitel, Ziel das Siegel des Amuletts von vor hundert Jahren (Lyra kennt die alten Gebete), Traumstimme bleibt offen; Held erfährt in Kapitel 2 nur vom Kult (14:16); endet auf Stufe 8; Kapitel 1 aus `Story.kt`/`Jobs.kt` lesen. Nachtragen: Heldensätze 29.4. **Vorlage geteilt** (Nutzer 13.10.): `STORY.md` nur Verzeichnis, Texte je Kapitel in Teildateien (ab ~15 KB weiter nach Ort/Quest), feste Marke je Text, damit bei 8–9 Kapiteln niemand alles lesen muss.
- **Intro (69):** Überfall verschlafen statt gesehen, weil die Chronik sagt „während er schlief“ und Rowenas Stein-Satz so die Pointe bleibt; eigene leise Klänge, „Ancient Legend“ bleibt der Tempelszene 68.
- **Chronik-Texte (64d/62i, Nutzer 13.10.):** Chronist in dritter Person, Einträge je Wendepunkt (Rückkehrer sehen sofort den Stand), Hörensagen mit Quelle; kindlicher Ton bleibt. **67 Südstraße:** zweiter Weg für Versorgung und Herkunft; Umkehr durch den Helden selbst statt Wand (erinnert statt führt). Einzelheiten im Archiv („16:0x“).

**Offen bei mir:** `docs/HELDENBAU.md` nach Durchsicht der kursiven Talentnamen (offen auch Erkennungszeichen-Standbilder, Jerrys Messung); Prüfungsquests und Umlern-Tempel (41, mit Nutzer); **45b nach Jerrys Messung 38 ansprechen**; 41 Kapitel 2 stößt der Nutzer an.

## Lehren

- **Bilder und Karten zusätzlich als PNG in den Chat** (13.10.): Artefakte lassen sich auf dem Handy nicht zoomen, Chatbilder schon (`cairosvg`, Faktor 3).
- **Markierungen zum Prüfen fett mit Markierung, nie nur kursiv** (13.10.): Nutzer erkennt Kursives auf dem Handy kaum; Docs-Editor kann keine rote Schrift.
- **Empfehlungen wiederholen, nicht verweisen** (13.10.): „die Empfehlungen sind ja wieder weg“. Offene Rückfragen jedes Mal mit vollem Wortlaut und Empfehlung zeigen, nie „stehen weiter“.
- **Ideen sind der Auftrag** (13.10.): „du bist mein Berater“, „dein Job, Ideen zu entwickeln“. Jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen, Eigenes mit Empfehlung ergänzen, Korrekturen des Nutzers offen übernehmen.
- **Entscheidungen einzeln abwarten** (13.10.): „ich folge deiner Empfehlung“ galt einem Punkt, nicht allen.
- **Rückfragen des Beraters** (Nutzer 13.10.) an den Nutzer immer im Gespräch stellen (nummeriert, Empfehlung), nicht über die Entscheidungsseite (die ist für Tom, Jerry, Diogenes); erst nach Entscheidung in die Notizen.
- **Notizen vor dem Ändern frisch holen** (12.10.): erst `git pull`, Treffer prüfen (`assert`), nie nach fehlgeschlagenem Ersetzen blind committen.
- **Hauptkopie nach Push aus `../bornim-main`** zeigt Notizen als „geändert“: nie committen, `git reset --hard HEAD` (freigegeben 12.10.).
- **Docs-Werkzeug** (41): einfache Zeilenumbrüche verschmelzen, Dialogzeilen mit Leerzeile trennen.

## Deine Linie (der Nutzer)

- Stehende Regeln zum Umgang in `CLAUDE.md` („Umgang mit dem Nutzer“); Richtung in `LEITBILD.md`/`STIL.md`. Wahl des Spielers, Optionen, individuell und lebendig (49/50).
