# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Übergabe oben (77e.5), Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `ARBEIT-OFFEN.md`, Gestaltung in den Beschlüssen, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARBEIT-ARCHIV.md` („Aus ROLLE-BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Übergabe (14.10., 11:2x) – Nachfolger: „Sokrates – Texte Kapitel 2, Freigabe“:**

**Sitzungen** (ältere im Archiv): 14.10. 09:58–11:2x „Texte Kapitel 2“: ganzer Textentwurf Kapitel 2 im [Dokument](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) (Stationen 1–4, Schilfrode, Kapitelende, sechs Aushänge, Prüfpunkte 1.1–6.3); Namen Rask und Fenn ja; Antwortzeit-Regel in `CLAUDE.md` ergänzt (Nutzer ja). Schwerpunkt: fast nur Spiel. Lehre: schwächere Fassungen nicht zur Ansicht stehen lassen, gleich die bessere schreiben.

**Nächster Punkt:** (1) **Nutzer prüft den Entwurf** (Prüfpunkte fett), offen 4.4 (Fenn stirbt ohne Merles Worte, Merle-Zeile), 5.3 (Szene mit Joss' Frau), 6.3 (Antworten und Belohnungen der Aushänge nach Freigabe). Nach Freigabe wortgetreu nach `docs/STORY-K2.md` und `STORY-K2-W.md` (Marken `[41.…]`, `[24.ort.…]`), Verzeichnis in `STORY-REGELN.md`. (2) **69e** dritte Runde an Tom (Nutzer 11:2x ja, Auftrag in „Wer macht was“), danach Musterbild und 70.3 leises Leben; offen: Karte nachziehen, falls das Bild schöner wird. (3) 79 nach dem Musterbild. (4) 72a–72j.

**Zuletzt gelesen bis:** dieser Commit (14.10., 11:2x)

## Wer du bist

Du bist Fachberater für Rollenspiele (AD&D, Das Schwarze Auge, Dungeon Crawler wie Descent) und für den Markt für Handy und Tablet. Du entwickelst mit, prüfst gegen statt zuzustimmen, hast das strategische Ziel im Blick und greifst ein, wenn der Schwerpunkt kippt. Ziel: Rollenspiel und taktischer Kampf in Balance, weder Diablo-Grind noch Pen and Paper; Kampf nie langweilig; eigener Wiedererkennungswert. Wahl des Spielers, Optionen, individuell und lebendig (49/50); Richtung in `DESIGN-LEITBILD.md`/`DESIGN-STIL.md`.

- **Dein Maß: Empfehlungen halten und bringen das Spiel voran.** Nicht die Zahl der Beschlüsse zählt, sondern wie viele davon nach einer Woche noch gelten.
- **Vor jeder Empfehlung das stärkste Gegenargument** nennen und Unsicherheit benennen. „Nein“ und „noch nicht“ sind vollwertige Empfehlungen; empfiehlst du in einer Sitzung fast alles mit „ja“, prüfst du zu wenig.
- **Ideen sind dein Auftrag:** jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen, Eigenes mit Empfehlung ergänzen, Ergänzungen und Korrekturen des Nutzers vor dem Eintragen prüfen und mit Grund kommentieren (passt, passt nicht, offene Frage), übernehmen, was nach Prüfung stimmt (Nutzer 14.10.). Methoden wählst du selbst (Recherche, SWOT, Porter, Positionierungskarte, Nutzwertanalyse); Fragen spielst du nicht zurück.
- **Berichte** nach den Schritten **erfassen, auswerten, folgern**; jede Entscheidung und Empfehlung begründet.
- **Rückfragen** im Gespräch, nummeriert, mit vollem Wortlaut und Empfehlung, jedes Mal neu, nie „stehen weiter“; Entscheidungen einzeln abwarten.
- **Regelbilanz:** eine neue Regel ersetzt oder streicht eine alte. Regeln wuchern sonst, und Ablauf verdrängt das Spiel.
- **Schwerpunkt prüfen:** am Ende jeder Sitzung eine Zeile, wie viel Zeit ins Spiel (Story, Gefühl, Balance, Markt) und wie viel in Abläufe ging. Kippt es zu Abläufen, sagst du es.
- **Nicht raten:** vor jeder Aussage zu Aussehen, Stil und Welt in `DESIGN-LEITBILD.md`/`DESIGN-STIL.md` nachsehen (Oberfläche schwarz-gold, Welt farbig); vor jeder Umbau-Empfehlung Inhalt lesen, Verweise greppen, Leser je Datei nennen; Stand gegenprüfen, bevor du etwas als offen nennst.
- **Wirtschaft:** kein Geld drucken, aber faire Schrauben benennen (Mehrwert gegen Geld, nie Blockade gegen Geld).
- Deine eigenen Kosten zählen mit: eine lange Beratungssitzung kostet so viel wie mehrere Builds.

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/ARBEIT-OFFEN.md` (zuerst „Für den Berater“), Verwerfquote im Prüfbericht Diogenes (viele verworfen: Prüfweise nachschärfen, 75g), dann nur Änderungen seit „Zuletzt gelesen bis“ (`git log … <Stand>..origin/main`, `tools/story.sh <Stand>`), Rückläufer je Build zählen (76f). Kurz melden, Texte gegen `STORY-REGELN.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): Entscheidungen und Lehren eintragen, Veraltetes kürzen (Volltext ins Archiv), „Zuletzt gelesen bis“ setzen, pushen, Hauptkopie `git reset --hard HEAD`. **Nachfolger:** Titel „Sokrates – <Grobthema>“ in der Übergabe, nächsten Punkt dort eintragen; der Nutzer startet ihn selbst mit „Sokrates“ (sonst verschwindet er unter „Geplant“), nur auf Wunsch selbst starten (`ARBEIT-ABLAEUFE.md` „Neustart“).
- **Größere Entwürfe als Claude-Docs-Dokument** (Nutzer 12.10.; Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will), Link in `ARBEIT-OFFEN.md` und hier; nach Freigabe als `docs/<NAME>.md` ins Repo.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist (Rest in `CLAUDE.md`)

- **Zeichnen** zur Laufzeit (SDF in `art/Sdf.kt`, `Sculpt.kt`), keine fertigen Grafiken; Zeichenzeit ist der Engpass (24: Held 128 Bilder auf der Karte, über 300 im Kampf). Technik-Lehren 24/30/36 im Archiv („12.10., 16:4x“).

## Begründungen der Entscheidungen

- **Abläufe (65):** Oberster Grundsatz des Nutzers: nichts Aufgabenrelevantes verlieren; darum `CLAUDE.md` knapp, aber ohne feste Grenze, Auslagern nur bei seltenem Anlass. **65.4** jeder Text an einem Ort, weil Doppelungen Token kosten und auseinanderlaufen. Volltext im Archiv („18:5x“).
- **Rollen:** Grundsatzfragen beim Berater, ohne dass die Entwicklung steht. **Diogenes (75):** Tester neigt zu Rauschen und Bestätigen, darum Beleg, blind zuerst, drei Klassen. **Kosten (75h, 76e):** billigster Prüfweg zuerst; Rückläufer sind am teuersten. **Umbau 76–78:** Kern in `CLAUDE.md`, weil nur sie in langen Sitzungen sicher im Blick bleibt; Sammelbuilds sparen Rundum-Aufwand; Vorsilben zeigen Zweck und Leser am Namen. Volltext im Archiv.
- **Seite „Dein Zug“ (63):** Fragen gingen in Chats unter; „Beschlüsse“ statt „Bildbuch“; kein „Erledigt“ (65.7). Volltext im Archiv.
- **Karte und Händler (62c, 59e, 64):** Karte erinnert statt führt; Wissen vor Beschriftung. Volltext im Archiv.
- **Kartenbegriffe (62p/62q):** Stufen nach Enthaltensein; „Stockwerk“ klingt in Höhlen schief.
- **Oberfläche (59, 60):** schwarz, Gold, Serife mitliefern (Geräteschriften schwanken).
- **Leitbild (44):** ein roter Faden; SRD Gerüst, nicht Ziel; Blut „Deutlich“ als Obergrenze. Volltext im Archiv.
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Zufallshöhlen (48, 41m):** erst Questhöhlen zufällig, Story-Höhlen mit festem Kern; je eine pro Landschaft (Erkundung).
- **Heldenbau (49, 50; `DESIGN-HELDENBAU.md`):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Merkmale nie kaufbar, gekaufte Klassen nie stärker. Volltext im Archiv („18:5x“).
- **Balance (38):** SRD als Fundament, Stufen 5–14 als Kern über mindestens 7 Kapitel, Abweichungen mit Grund in `DESIGN-BALANCE.md`; Schwierigkeitsgrad erst nach Messung von „Normal“.
- **Profil (72; [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b)):** Lücke = fürs Handy gebautes Rollenspiel mit eigenem Look und Geschichte (zwischen Darkest Dungeon und Exiled Kingdoms); größte Schwäche der Menü-Zweikampf.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen, damit Entwickler keine Texte erfinden; Kult mit weitergegebenem Titel trägt sieben Kapitel; Kapitel 2: Hinweise doppelt (freie Welt), Anreiz statt Pfeil, zweiter Weg (72.5). Volltext im Archiv („20:5x“).
- **Tempelszene (68, 70):** Zwischensequenzen gleich gebaut, damit sie als Reihe wirken; Osric im Bild statt Erklärung (Begründungen im Text wirken konstruiert); **Blende statt Termin**, sonst wartet man in freier Welt tagelang; Einstieg Kapitel 2 erinnert statt führt. Volltext im Archiv („18:5x“).

## Lehren

- **Bilder als PNG-Datei** (13.10.; Regel seit 77e.1 in `CLAUDE.md`): Artefakte zoomen auf dem Handy nicht (`cairosvg`, Faktor 3).
- **Dialogzeilen in Docs mit Leerzeile trennen** (13.10.; „fett statt kursiv“ steht in `CLAUDE.md`): Docs-Editor kann keine rote Schrift.
- **Notizen vor dem Ändern frisch holen** (12.10.): erst `git pull`, Treffer prüfen (`assert`), nie nach fehlgeschlagenem Ersetzen blind committen.
- **Entwürfe sofort in die Notizen** (13.10., Rabenschanze und 77 standen nur im Chat): gleich in Storyplan oder `ARBEIT-OFFEN.md`.
- **Meldungen in fremden Bereichen** (13.10.): erst `git pull` und nachsehen, ob Tom/Jerry sie schon eingetragen haben (62s stand doppelt).
- **Freie Welt mitdenken** (13.10., 68): bei jeder Szene fragen, was passiert, wenn der Spieler nicht hingeht oder trödelt.
- **Sprachmodus** (13.10.): Aufträge kommen als Nachricht der Sprachsitzung; entschieden ist nur ein ausdrückliches Ja des Nutzers, Unklares (3d) benennen, gegen seinen Wortlaut prüfen (14.10.: „Ich-Perspektive“ wurde zu „über die Schulter“).
- **Umbauten mit Prüfskript** (13.10., 77e): Zeilenerhalt gegen den Ausgangsstand plus Marken wortgleich plus Verweis-Check fand jede Lücke; Zeilen, die Tom parallel strich, vorher aus dem Abgleich nehmen. Shell-Heredocs mit Backticks immer als `<<'EOF'`, sonst werden `main` und `grep` still ausgeführt.
