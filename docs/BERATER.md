# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Aufbau, Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `OFFEN.md`, Gestaltung in den Beschlüssen, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARCHIV.md` („Aus BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Sitzungen** (ältere im Archiv): 13.10. 18:58–19:5x „Kapitel 2 und Profil“ (4a–4d, Bericht 72, Figurenliste, N1–N4, 73a, 74); 19:52–20:5x „Kapitel 2 und Profil“ (72 als PDF, 75 Diogenes fertig, „Dein Zug“, 76a–f ja). 21:01–21:3x „Entwicklerrollen und CLAUDE.md“ (76g/h, 73b-Texte, D2.4/D2.13, 77a–d ja). **Nachfolger:** „Sokrates – Entwicklerrollen und Dokumentnamen“ (Nutzer startet mit „Sokrates“): Entwurf 76+77 als Claude-Docs-Dokument

**Nächster Punkt:** (0) **76g/76h ja (21:02):** Prompt „Wer du bist“ für den Berater ersetzt „Deine Linie“ und Teile der Lehren (Datei wächst nicht); Berater-Absatz in `CLAUDE.md` auf zwei Sätze; beides in den Entwurf 76. (1) **76a–76f ja (20:56):** vollständigen Entwurf von `CLAUDE.md` (gemeinsamer Kern, Schrittregeln als Kurzzeile) und neuer `docs/ENTWICKLER.md` (Prompt „Wer du bist“ für Tom und Jerry mit Prüftreppe und Maß „Test passt beim ersten Mal“, ausführliche Abläufe) als Claude-Docs-Dokument zum Lesen und Drucken vorlegen (Grundlage im Archiv „Entwurf Berater 76“); erst nach Freigabe umbauen. Ab dann beim Start Rückläufer je Build zählen (76f). (1b) **77 Dokumentnamen: 77a–d ja (21:29)**, Entwurf zusammen mit 76; Schnitt nur bei Toms Sitzungswechsel, Wächter in `notiz.sh` gegen alte Namen; Codekommentare (Sfx, Recorded, PlaceSound, Chronicle, Interlude, InterludeClock, InterludeUi) passt Tom an; **77e danach** Inhalte neu zuordnen. `ENTWICKLUNG.md` nie einschmelzen (Abnahme auch für Diogenes und Leitbild), nur umbenennen. (2) **72**: Freigabe Marktvergleich (PDF 20:00), dann `docs/MARKT.md`; **72a–72j** mit Wortlaut und Empfehlung zeigen. (3) Kultlager (41). Jerry braucht ab Fr. Schreibrecht auf den Prüfbericht (75g).

**Zuletzt gelesen bis:** dieser Commit (13.10., 21:3x)

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“), Verwerfquote im Prüfbericht Diogenes (viele verworfen: Prüfweise nachschärfen, 75g), dann nur Änderungen seit „Zuletzt gelesen bis“ (`git log … <Stand>..origin/main`, `tools/story.sh <Stand>`). Kurz melden, Texte gegen `STORY.md` und Storyplan prüfen.
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
- **Rollen:** Grundsatzfragen beim Berater, ohne dass die Entwicklung steht; Sitzungsnamen thematisch. **Diogenes (75):** Claude als Tester neigt zu Rauschen, Bestätigen, Entwickleraugen, stillen Lücken; darum Erfolgsmaß, Beleg und Regel, blind zuerst; drei Klassen, damit weder Nutzer Verteiler noch wir Nadelöhr sind. **Kosten (75h, 76e):** Token sind knapp; billigster Prüfweg zuerst, bei Entwicklern zählt „Test passt beim ersten Mal“, weil Rückläufer am teuersten sind. Volltext im Archiv.
- **Seite „Dein Zug“ (63):** Fragen gingen in Chats unter; „Beschlüsse“ statt „Bildbuch“; kein „Erledigt“ (65.7). Volltext im Archiv.
- **Karte und Händler (62c, 59e, 64):** Karte erinnert statt führt; Bekannte am gewohnten Ort; Wissen vor Beschriftung; Chronik als eigener Reiter. Volltext im Archiv.
- **Kartenbegriffe (62p/62q):** Stufen nach Enthaltensein (draußen Gebiet, hinter einem Eingang Grundriss); „Ebene“ für übereinanderliegende Teile, „Stockwerk“ klingt in Höhlen schief.
- **Oberfläche (59, 60):** schwarz, Gold, Serife wie der Textkasten; Serife mitliefern, weil Geräteschriften je Gerät anders aussehen.
- **Leitbild (44):** ein roter Faden; SRD Gerüst, nicht Ziel; Blut „Deutlich“ als Obergrenze. Volltext im Archiv.
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Zufallshöhlen (48, 41m):** erst Questhöhlen zufällig, Story-Höhlen mit festem Kern; je eine pro Landschaft (Erkundung).
- **Heldenbau (49, 50; `HELDENBAU.md`):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Merkmale nie kaufbar, gekaufte Klassen nie stärker. Volltext im Archiv („18:5x“).
- **Balance (38):** SRD als Fundament, Stufen 5–14 als Kern über mindestens 7 Kapitel, Abweichungen mit Grund in `BALANCE.md`; Schwierigkeitsgrad erst nach Messung von „Normal“.
- **Profil (72; [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b)):** Lücke = fürs Handy gebautes Rollenspiel mit eigenem Look und Geschichte (zwischen Darkest Dungeon und Exiled Kingdoms); größte Schwäche der Menü-Zweikampf; Vorschläge 72.1–72.9, Rückfragen 72a–f offen.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen, damit Entwickler keine Texte erfinden; Kult mit weitergegebenem Titel trägt sieben Kapitel; Kapitel 2: Hinweise doppelt (freie Welt), Anreiz statt Pfeil, zweiter Weg (72.5). Volltext im Archiv („20:5x“).
- **Intro, Chronik-Texte (69, 64d/62i, 67):** im Archiv („Aus BERATER.md, 13.10., 19:4x“).
- **Tempelszene (68, 70):** Zwischensequenzen gleich gebaut, damit sie als Reihe wirken; Osric im Bild statt Erklärung (Begründungen im Text wirken konstruiert); **Blende statt Termin**, sonst wartet man in freier Welt tagelang; Einstieg Kapitel 2 erinnert statt führt. Volltext im Archiv („18:5x“).

**Offen bei mir:** 72a–72j; Heldenbau-Rest (Erkennungszeichen, Messung); Prüfungsquests und Umlern-Tempel (41); 45b nach Messung 38 (Empfehlung 72i: streichen).

## Lehren

- **Bilder und Karten zusätzlich als PNG in den Chat** (13.10.): Artefakte lassen sich auf dem Handy nicht zoomen, Chatbilder schon (`cairosvg`, Faktor 3).
- **Markierungen zum Prüfen fett mit Markierung, nie nur kursiv** (13.10.): Nutzer erkennt Kursives auf dem Handy kaum; Docs-Editor kann keine rote Schrift.
- **Empfehlungen wiederholen, nicht verweisen** (13.10.): „die Empfehlungen sind ja wieder weg“. Offene Rückfragen jedes Mal mit vollem Wortlaut und Empfehlung zeigen, nie „stehen weiter“.
- **Ideen sind der Auftrag** (13.10.): „du bist mein Berater“, „dein Job, Ideen zu entwickeln“. Jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen, Eigenes mit Empfehlung ergänzen, Korrekturen des Nutzers offen übernehmen.
- **Stand prüfen, bevor ich ihn als offen nenne** (13.10., 17:0x): Heldenbau war längst freigegeben, die Notiz veraltet. Offenes vor dem Nennen in Commits/Beschlüssen gegenprüfen; Entschiedenes sofort in `OFFEN.md` nachtragen.
- **Entscheidungen einzeln abwarten** (13.10.): „ich folge deiner Empfehlung“ galt einem Punkt, nicht allen.
- **Rückfragen des Beraters** (13.10.) im Gespräch stellen (nummeriert, Empfehlung), nicht über die Seite „Dein Zug“; erst nach Entscheidung in die Notizen.
- **Notizen vor dem Ändern frisch holen** (12.10.): erst `git pull`, Treffer prüfen (`assert`), nie nach fehlgeschlagenem Ersetzen blind committen.
- **Entwürfe sofort in die Notizen** (13.10.): der Rabenschanze-Entwurf stand nur im Chat und war nach dem Neustart nur als Kurznotiz da; Entwürfe gleich in Storyplan oder `OFFEN.md`.
- **Meldungen in fremden Bereichen** (13.10.): erst `git pull` und nachsehen, ob Tom/Jerry sie schon eingetragen haben (62s stand doppelt).
- **Docs:** Dialogzeilen mit Leerzeile trennen (41).
- **Nicht raten bei Umbauten** (13.10., 21:22, 77): „`ENTWICKLUNG` geht in `ROLLE-ENTWICKLER` auf“ war geraten und falsch (Abnahme auch für Diogenes und Leitbild). Vor jeder Umbau-Empfehlung: Inhalt lesen, alle Verweise greppen, Leser je Datei nennen.
- **Freie Welt mitdenken** (13.10., 68): bei jeder Szene fragen, was passiert, wenn der Spieler nicht hingeht oder trödelt.
- **Sprachmodus** (13.10.): Aufträge kommen dann als Nachricht der Sprachsitzung; als entschieden gilt nur ein ausdrückliches Ja des Nutzers, Unklares (3d) offen benennen.

## Deine Linie (der Nutzer)

- **Rolle (Nutzer 13.10., Sprachmodus):** Fachberater für Rollenspiele (AD&D, Das Schwarze Auge, Dungeon Crawler wie Descent) und den Markt für Handy/Tablet; prüft gegen statt zuzustimmen, entwickelt mit, hat das strategische Ziel im Blick, greift ein, wenn der Schwerpunkt kippt. Positionierung: Rollenspiel und taktischer Kampf in Balance, weder Diablo-Grind noch Pen and Paper; Kampf nie langweilig; eigener Wiedererkennungswert. **Methoden und Werkzeuge wählt der Berater selbst** (Recherche, Dokumente, Analysemodelle wie SWOT, Porter, Positionierungskarte, Nutzwertanalyse für Optionen); Fragen nicht zurückspielen, klare Empfehlung. **Wirtschaft:** kein Geld drucken, aber faire Schrauben benennen (Mehrwert gegen Geld, nie Blockade gegen Geld).
- **Berichte (Nutzer 13.10., 18:55):** Ergebnisse als schlüssigen, nachvollziehbaren Bericht nach den klassischen Schritten **erfassen, auswerten, folgern**; Entscheidungen und Empfehlungen immer begründen.
- Stehende Regeln zum Umgang in `CLAUDE.md` („Umgang mit dem Nutzer“); Richtung in `LEITBILD.md`/`STIL.md`. Wahl des Spielers, Optionen, individuell und lebendig (49/50).
