# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Aufbau, Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `OFFEN.md`, Gestaltung in den Beschlüssen, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARCHIV.md` („Aus BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Sitzungen** (ältere im Archiv): 13.10. 18:08–19:0x „Kapitel 2 Plot“ (2a–2d, 3a–3e, 71 für Diogenes, 72 Marktvergleich, Rolle geschärft). **Nachfolger:** „Sokrates – Kapitel 2 und Profil“ (Nutzer startet mit „Sokrates“)

**Nächster Punkt:** (1) **Marktvergleich als Bericht umbauen** nach dem Schema des Nutzers (18:55): erfassen, auswerten, folgern, jede Empfehlung begründet. (2) Offene Rückfragen mit vollem Wortlaut und Empfehlung zeigen: **72a–72j** im [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b). (3) Kultlager (41).

**Zuletzt gelesen bis:** dieser Commit (13.10., 19:0x)

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“), dann nur Änderungen seit „Zuletzt gelesen bis“ (`git log … <Stand>..origin/main`, `tools/story.sh <Stand>`). Kurz melden, Texte gegen `STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): Entscheidungen und Lehren eintragen, Veraltetes kürzen (Volltext ins Archiv), „Zuletzt gelesen bis“ setzen, pushen, Hauptkopie `git reset --hard HEAD`. **Nachfolger:** Titel „Sokrates – <Grobthema>“ unter „Sitzungen“, nächsten Punkt hier eintragen; der Nutzer startet ihn selbst mit „Sokrates“ (sonst verschwindet er unter „Geplant“), nur auf Wunsch selbst starten (`create_session`, ersatzweise `create_trigger` in 2 Minuten).
- **Größere Entwürfe als Claude-Docs-Dokument** (Nutzer 12.10.; Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will), Link in `OFFEN.md` und hier; nach Freigabe als `docs/<NAME>.md` ins Repo.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist

- **Module:** `core` (Regeln, Kampf, Welt, alle Zeichnungen und Klänge als Daten), `app` (Compose), `tools/preview` (Bilder, Filme, Hörproben; Schalter in `UMGEBUNG.md`).
- **Zeichnen** zur Laufzeit (SDF in `art/Sdf.kt`, `Sculpt.kt`), keine fertigen Grafiken; Zeichenzeit ist der Engpass (24: Held 128 Bilder auf der Karte, über 300 im Kampf). Technik-Lehren 24/30/36 im Archiv („12.10., 16:4x“).
- **Grenzen:** Tom = Leute, Dorf, Innenräume, Technik der Blende; Jerry = Monster, Höhle, Kampf, Klang (13e seit 13y bei Tom). `WorldScreen.kt` nur nach Absprache.
- **Ablauf:** Code auf Zweigen, Build über GitHub, Nutzer testet APKs (A56, MuMu), Merge durch die Sitzung, Release nur auf Zuruf.

## Begründungen der Entscheidungen

- **Abläufe (65):** Oberster Grundsatz des Nutzers: nichts Aufgabenrelevantes verlieren; darum `CLAUDE.md` knapp, aber ohne feste Grenze, Auslagern nur bei seltenem Anlass. **65.4** jeder Text an einem Ort, weil Doppelungen Token kosten und auseinanderlaufen. Volltext im Archiv („18:5x“).
- **Rollen:** Grundsatzfragen beim Berater, ohne dass die Entwicklung steht; Diogenes ohne eigenen Account, Befund = Verdacht, Ablauf ausgelagert; Sitzungsnamen thematisch. Volltext im Archiv.
- **Entscheidungsseite (63):** Fragen gingen in Chats unter; „Beschlüsse“ statt „Bildbuch“; kein „Erledigt“ (65.7). Volltext im Archiv.
- **Karte und Händler (62c, 59e, 64):** Karte erinnert statt führt; Bekannte am gewohnten Ort; Wissen vor Beschriftung; Chronik als eigener Reiter. Volltext im Archiv.
- **Kartenbegriffe (62p/62q):** Stufen nach Enthaltensein (draußen Gebiet, hinter einem Eingang Grundriss); „Ebene“ für übereinanderliegende Teile, „Stockwerk“ klingt in Höhlen schief.
- **Oberfläche (59, 60):** schwarz, Gold, Serife wie der Textkasten; Serife mitliefern, weil Geräteschriften je Gerät anders aussehen.
- **Leitbild (44):** ein roter Faden; SRD Gerüst, nicht Ziel; Blut „Deutlich“ als Obergrenze. Volltext im Archiv.
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Zufallshöhlen (48, 41m):** erst Questhöhlen zufällig, Story-Höhlen mit festem Kern; je eine pro Landschaft (Erkundung).
- **Heldenbau (49, 50; `HELDENBAU.md`):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Merkmale nie kaufbar, gekaufte Klassen nie stärker. Volltext im Archiv („18:5x“).
- **Balance (38):** SRD als Fundament, Stufen 5–14 als Kern über mindestens 7 Kapitel, Abweichungen mit Grund in `BALANCE.md`; Schwierigkeitsgrad erst nach Messung von „Normal“.
- **Profil (72; [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b)):** Lücke = fürs Handy gebautes Rollenspiel mit eigenem Look und Geschichte (zwischen Darkest Dungeon und Exiled Kingdoms); größte Schwäche der Menü-Zweikampf; Vorschläge 72.1–72.9, Rückfragen 72a–f offen.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen vor jeder Story-Änderung, damit Entwickler keine Texte erfinden. Kult mit weitergegebenem Titel trägt sieben Kapitel (Mischung, 14:08); Held erfährt in Kapitel 2 nur vom Kult; Vorlage je Kapitel geteilt, feste Marke je Text. **Kapitel 2 (2a–2d, 3a–3e):** Hinweise doppelt, damit jede Reihenfolge stimmt (freie Welt); Schilfrode verschlossen ohne Jorrit, sperrt aber nie den Weg (Anreiz statt Pfeil). **Rabenschanze (4a–4d, 19:25):** Mauerbruch als zweiter Weg (72.5), Silber aus Aschfurt und Liste „Ring fehlt“ binden die Station an Vorgeschichte und Kult. Volltext im Archiv („18:5x“).
- **Intro (69):** Überfall verschlafen statt gesehen, weil die Chronik sagt „während er schlief“ und Rowenas Stein-Satz so die Pointe bleibt; eigene leise Klänge, „Ancient Legend“ bleibt der Tempelszene 68.
- **Tempelszene (68, 70):** Zwischensequenzen gleich gebaut, damit sie als Reihe wirken; Osric im Bild statt Erklärung (Begründungen im Text wirken konstruiert); **Blende statt Termin**, sonst wartet man in freier Welt tagelang; Einstieg Kapitel 2 erinnert statt führt. Volltext im Archiv („18:5x“).
- **Chronik-Texte (64d/62i):** Chronist in dritter Person, ein Eintrag je Wendepunkt, Hörensagen mit Quelle. **67 Südstraße:** zweiter Weg für Versorgung und Herkunft, Umkehr durch den Helden statt Wand. Volltext im Archiv.

**Offen bei mir:** 72a–72j; Heldenbau-Rest (Erkennungszeichen, Messung); Prüfungsquests und Umlern-Tempel (41); 45b nach Messung 38 (Empfehlung 72i: streichen).

## Lehren

- **Bilder und Karten zusätzlich als PNG in den Chat** (13.10.): Artefakte lassen sich auf dem Handy nicht zoomen, Chatbilder schon (`cairosvg`, Faktor 3).
- **Markierungen zum Prüfen fett mit Markierung, nie nur kursiv** (13.10.): Nutzer erkennt Kursives auf dem Handy kaum; Docs-Editor kann keine rote Schrift.
- **Empfehlungen wiederholen, nicht verweisen** (13.10.): „die Empfehlungen sind ja wieder weg“. Offene Rückfragen jedes Mal mit vollem Wortlaut und Empfehlung zeigen, nie „stehen weiter“.
- **Ideen sind der Auftrag** (13.10.): „du bist mein Berater“, „dein Job, Ideen zu entwickeln“. Jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen, Eigenes mit Empfehlung ergänzen, Korrekturen des Nutzers offen übernehmen.
- **Stand prüfen, bevor ich ihn als offen nenne** (13.10., 17:0x): Heldenbau war längst freigegeben, die Notiz veraltet. Offenes vor dem Nennen in Commits/Beschlüssen gegenprüfen; Entschiedenes sofort in `OFFEN.md` nachtragen.
- **Entscheidungen einzeln abwarten** (13.10.): „ich folge deiner Empfehlung“ galt einem Punkt, nicht allen.
- **Rückfragen des Beraters** (13.10.) im Gespräch stellen (nummeriert, Empfehlung), nicht über die Entscheidungsseite; erst nach Entscheidung in die Notizen.
- **Notizen vor dem Ändern frisch holen** (12.10.): erst `git pull`, Treffer prüfen (`assert`), nie nach fehlgeschlagenem Ersetzen blind committen.
- **Entwürfe sofort in die Notizen** (13.10.): der Rabenschanze-Entwurf stand nur im Chat und war nach dem Neustart nur als Kurznotiz da; Entwürfe gleich in Storyplan oder `OFFEN.md`.
- **Docs:** Dialogzeilen mit Leerzeile trennen (41).
- **Freie Welt mitdenken** (13.10., 68): bei jeder Szene fragen, was passiert, wenn der Spieler nicht hingeht oder trödelt.
- **Sprachmodus** (13.10.): Aufträge kommen dann als Nachricht der Sprachsitzung; als entschieden gilt nur ein ausdrückliches Ja des Nutzers, Unklares (3d) offen benennen.

## Deine Linie (der Nutzer)

- **Rolle (Nutzer 13.10., Sprachmodus):** Fachberater für Rollenspiele (AD&D, Das Schwarze Auge, Dungeon Crawler wie Descent) und den Markt für Handy/Tablet; prüft gegen statt zuzustimmen, entwickelt mit, hat das strategische Ziel im Blick, greift ein, wenn der Schwerpunkt kippt. Positionierung: Rollenspiel und taktischer Kampf in Balance, weder Diablo-Grind noch Pen and Paper; Kampf nie langweilig; eigener Wiedererkennungswert. **Methoden und Werkzeuge wählt der Berater selbst** (Recherche, Dokumente, Analysemodelle wie SWOT, Porter, Positionierungskarte, Nutzwertanalyse für Optionen); Fragen nicht zurückspielen, klare Empfehlung. **Wirtschaft:** kein Geld drucken, aber faire Schrauben benennen (Mehrwert gegen Geld, nie Blockade gegen Geld).
- **Berichte (Nutzer 13.10., 18:55):** Ergebnisse als schlüssigen, nachvollziehbaren Bericht nach den klassischen Schritten **erfassen, auswerten, folgern**; Entscheidungen und Empfehlungen immer begründen.
- Stehende Regeln zum Umgang in `CLAUDE.md` („Umgang mit dem Nutzer“); Richtung in `LEITBILD.md`/`STIL.md`. Wahl des Spielers, Optionen, individuell und lebendig (49/50).
