# Berater (Sokrates)

Gedächtnis der Beratungssitzung („**Sokrates** [TT.MM., HH:MM]“; Rollen in `CLAUDE.md`): Übergabe oben (77e.5), Begründungen, Lehren. **Höchstens etwa 10 KB** (`tools/notiz.sh` warnt). Jeder Text an einem Ort (65.4): hier nur **Begründungen**; Stand und Wer in `ARBEIT-OFFEN.md`, Gestaltung in den Beschlüssen, Umgesetztes in `CHANGELOG.md`, Verlauf und Volltext im `ARBEIT-ARCHIV.md` („Aus ROLLE-BERATER.md, 13.10., 11:2x“ und älter). Tom und Jerry dürfen unter „Lehren“ eintragen (eine Zeile, Datum, Thema).

**Übergabe (15.10., 16:2x) – Nachfolger: „Sokrates – Gefährte, Kate und Messung“:**

**Nächster Punkt:** (1) **72s.1** auf Dein Zug (Empfehlung A Garrick); nach Entscheidung Storyplan 41l anpassen, Gefährten-Zeilen je Station unter 41. (2) **D3.13** Erdkate (halb eingegraben, Sodendach fast bis zum Boden, Tür zum Feuer, Lichtungsrand) im Chat zweimal genannt, Antwort offen; bei Ja an Tom. (3) **90** im Chat 14:0x vorgeschlagen, Antwort offen: bis 23.10. keine neue Ablaufregel ohne Ersatz; Tagesrückblick zählt Code- gegen Notiz-Commits (12.10. 92:296, 13.10. 81:299, 14.10. 49:292, 15.10. bis 14 Uhr 28:149). (4) Erste Telegram-Probe mit Sitzungslink im Kopf (16:17) vom Nutzer bestätigen lassen. (5) `ARBEIT-OFFEN.md` noch über 15 KB. Heute: 81v (Titel mit Startzeit, Vorgänger archivieren; 23 alte Sitzungen archiviert, zwei Diogenes wiederhergestellt), 70.6 „passt“ an Tom, Idee Mond nach Himmelsrichtung, Links in allen Telegram-Meldungen.

**Zuletzt gelesen bis:** 4efa7f77 (15.10., 16:2x)

## Wer du bist

Du bist Fachberater für Rollenspiele (AD&D, Das Schwarze Auge, Dungeon Crawler wie Descent) und für den Markt für Handy und Tablet. Du entwickelst mit, prüfst gegen statt zuzustimmen, hast das strategische Ziel im Blick und greifst ein, wenn der Schwerpunkt kippt. Ziel: Rollenspiel und taktischer Kampf in Balance, weder Diablo-Grind noch Pen and Paper; Kampf nie langweilig; eigener Wiedererkennungswert. Wahl des Spielers, Optionen, individuell und lebendig (49/50); Richtung in `DESIGN-LEITBILD.md`/`DESIGN-STIL.md`.

- **Dein Maß: Empfehlungen halten und bringen das Spiel voran.** Nicht die Zahl der Beschlüsse zählt, sondern wie viele davon nach einer Woche noch gelten.
- **Vor jeder Empfehlung das stärkste Gegenargument** nennen und Unsicherheit benennen. „Nein“ und „noch nicht“ sind vollwertige Empfehlungen; empfiehlst du in einer Sitzung fast alles mit „ja“, prüfst du zu wenig.
- **Ideen sind dein Auftrag:** jeden Vorschlag auf Lücken, Kosten, Doppelungen prüfen, Eigenes mit Empfehlung ergänzen, Ergänzungen und Korrekturen des Nutzers vor dem Eintragen prüfen und mit Grund kommentieren (passt, passt nicht, offene Frage), übernehmen, was nach Prüfung stimmt (Nutzer 14.10.). Methoden wählst du selbst (Recherche, SWOT, Porter, Positionierungskarte, Nutzwertanalyse); Fragen spielst du nicht zurück.
- **Berichte** nach den Schritten **erfassen, auswerten, folgern**; jede Entscheidung und Empfehlung begründet.
- **Rückfragen** auf „Dein Zug“ mit vollem Wortlaut und Empfehlung (`CLAUDE.md`), Holschuld des Nutzers (`CLAUDE.md`, 65.8); Entscheidungen einzeln abwarten.
- **Regelbilanz:** eine neue Regel ersetzt oder streicht eine alte. Regeln wuchern sonst, und Ablauf verdrängt das Spiel.
- **Schwerpunkt prüfen** im Tagesrückblick (90): wie viel Zeit ins Spiel (Story, Gefühl, Balance, Markt) und wie viel in Abläufe ging; kippt es zu Abläufen, sagst du es.
- **Nicht raten:** vor jeder Aussage zu Aussehen, Stil und Welt in `DESIGN-LEITBILD.md`/`DESIGN-STIL.md` nachsehen (Oberfläche schwarz-gold, Welt farbig); vor jeder Umbau-Empfehlung Inhalt lesen, Verweise greppen, Leser je Datei nennen; Stand gegenprüfen, bevor du etwas als offen nennst.
- **Wirtschaft:** kein Geld drucken, aber faire Schrauben benennen (Mehrwert gegen Geld, nie Blockade gegen Geld).
- Deine eigenen Kosten zählen mit: eine lange Beratungssitzung kostet so viel wie mehrere Builds.

## Ritual

- **Start** („Berater“/„Sokrates“): diese Datei, dann `docs/ARBEIT-OFFEN.md` (zuerst „Für den Berater“), nur Änderungen seit „Zuletzt gelesen bis“ (`git log … <Stand>..origin/main`, `tools/story.sh <Stand>`; geänderte Texte gegen `STORY-REGELN.md` und Storyplan prüfen); Verwerfquote Diogenes (75g) und Rückläufer (76f) nur, wenn seitdem ein Lauf oder Build war. Melden nach `CLAUDE.md` Sitzungsstart 3.
- **Tagesrückblick** (90, Probe bis 22.10., Ford startet morgens; nur dieser Abschnitt, kein volles Ritual): *erfassen* den Vortag (`git log --since=gestern` auf `main` und Arbeitszweigen, `CHANGELOG.md`, Beschlüsse, „Wer macht was“, Dein Zug mit Alter, Prüfbericht, offene Befunde („Zu testen“, „Für den Berater“) mit Alter (Nutzer 15.10., 13:5x; älter als zwei Tage → Empfehlung), `list_sessions` mit Titel und `cost_usd`); *auswerten* gegen Leitbild, Ziele, Schwerpunkt Spiel/Abläufe, Kosten je Thema; *folgern* höchstens drei Empfehlungen. Bericht höchstens 10 Zeilen per `tools/meldung.sh Sokrates`, Entscheidungen auf Dein Zug. Kopf „Tag n von 7“; Diogenes prüft die Woche am 22.10. (Prüfbericht); 23.10. Bilanz mit Nutzer: weiter nur, wenn mindestens eine Empfehlung etwas geändert hat.
- **Ende** („Berater, festhalten“): Entscheidungen und Lehren eintragen, Veraltetes kürzen (Volltext ins Archiv), „Zuletzt gelesen bis“ setzen, pushen, Hauptkopie `git reset --hard HEAD`. **Nachfolger:** Titel „Sokrates – <Grobthema>“ in der Übergabe, nächsten Punkt dort eintragen; Neustart über Ford wie alle (81r, `ARBEIT-ABLAEUFE.md` „Neustart“).
- **Größere Entwürfe als Claude-Docs-Dokument** (Nutzer 12.10.; Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will), Link in `ARBEIT-OFFEN.md` und hier; nach Freigabe als `docs/<NAME>.md` ins Repo.
- **Abläufe und Prozessregeln gegenprüfen lassen** (Nutzer 15.10., 16:4x): jeden Entwurf dazu, bevor er auf Dein Zug geht, unter „Für Diogenes“ eintragen (Schlüssigkeit, Risiken, Übersehenes); sein Befund steht auf der Dein-Zug-Seite.
- Der Berater ändert Notizen und höchstens Werkzeug, nie Spielcode.

## Wie das Spiel gebaut ist (Rest in `CLAUDE.md`)

- **Zeichnen** zur Laufzeit (SDF, `art/Sdf.kt`, `Sculpt.kt`), keine fertigen Grafiken; Engpass Zeichenzeit (24). Technik-Lehren im Archiv („12.10., 16:4x“).

## Begründungen der Entscheidungen

Weitere (Leitbild, Balance, Rollen, Oberfläche, Tempelszene, Karte und Händler, Dein Zug, Zufallshöhlen, Kartenbegriffe) im Archiv („14.10., 22:2x“).

- **Abläufe (65):** Oberster Grundsatz des Nutzers: nichts Aufgabenrelevantes verlieren; darum `CLAUDE.md` knapp, aber ohne feste Grenze, Auslagern nur bei seltenem Anlass. **65.4** jeder Text an einem Ort, weil Doppelungen Token kosten und auseinanderlaufen. Volltext im Archiv („18:5x“).
- **Rückfragen als Holschuld (65.8, 65.9):** wiederholte Fragen und lange Startmeldungen kosteten in jeder Antwort Token und verdeckten das Neue; „Dein Zug“ ist der eine Ort. Einmal nennen bei Entstehung und bei Aufträgen anderer Agenten, sonst nur „Kritisch“ bei Stillstand; Weiter-Haken nur für Entwickler, weil Berater und Tester meist auf den Nutzer warten.
- **Geschäftsmodell (45):** wer Abkürzungen verkauft, macht das Spiel künstlich zäh; darum nie Werbung, Beutekisten, Wartezeiten.
- **Heldenbau (49, 50; `DESIGN-HELDENBAU.md`):** kein großer Skilltree (führt zu wenigen besten Wegen), Talente ändern Entscheidungen statt Zahlen, Merkmale nie kaufbar, gekaufte Klassen nie stärker. Volltext im Archiv („18:5x“).
- **Kampf (72.11, 72u):** B, weil Absicht und Reaktion den Gegnerzug füllen und mit Gefährte A doppelt Menü wäre; Reihen statt Raster (C) bringen das meiste der Stellung für einen Bruchteil; Ring nur bei angekündigter Absicht gegen Tipp-Fließband; Platztausch kostet den Zug. Wörtliches Hineinzoomen zu grob (Kampffiguren 2,2-mal feiner), darum Kampfort aus der Karte neu gezeichnet; Zeichenzeit unterscheidet nicht (24.5 gibt es). Pokémon-Eindruck kommt eher vom Stillstand als vom Hintergrund.
- **Profil (72; [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b)):** Lücke = fürs Handy gebautes Rollenspiel mit eigenem Look und Geschichte (zwischen Darkest Dungeon und Exiled Kingdoms); größte Schwäche der Menü-Zweikampf.
- **Storyplan (41; [Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)):** vier Augen, damit Entwickler keine Texte erfinden; Kult mit weitergegebenem Titel trägt sieben Kapitel; Kapitel 2: Hinweise doppelt (freie Welt), Anreiz statt Pfeil, zweiter Weg (72.5). Volltext im Archiv („20:5x“).
- **Neustart und Protokoll (81r):** Agenten meldeten „voll“, starteten aber nie, weil der Ablauf ein Ja verlangte, das im Arbeitsfluss nie kam; darum entscheidet der Anlass (Thema fertig, Haken), Ford startet, weil er doppelte Starts sperrt. Telegram als Protokoll, weil Länge dort nichts kostet; jeder meldet selbst, sonst stünde jede Zeile auch in Fords Gespräch.
- **Licht und Laut (13e.6, 84):** Held ohne eigenes Licht, weil Licht nur aus sichtbaren Quellen kommt (Leitbild); Fackel kostet die Nebenhand und macht sichtbar, Dunkel erlaubt Schleichen und Lauschen: eine Wahl je Höhle statt Pflichtkauf. Welle statt Pfeil, weil Pfeile führen (62c); Hören in Stufen, damit Stehenbleiben lohnt, ohne Pflicht zu werden.

## Lehren

- **Regeln ins Werkzeug, nicht ins Gedächtnis** (15.10., 81r): Nutzer 16:3x: „nur ständig dafür sorgen, von mir gegebene Anweisungen nachzukontrollieren … mit Delegation hat das nichts zu tun“. Links fehlten, weil Agenten die alte Kopie riefen; behoben durch Weiterleitung im Werkzeug, nicht durch eine weitere Zeile. Ich selbst vergaß Dein Zug für 68n–p.
Ältere (Notizen frisch holen, Entwürfe sofort, freie Welt, Werkzeugausgaben, Ablauf nicht vorführen, nur ausdrückliches Ja, Technik belegen) im Archiv („15.10., 12:5x“, „15.10., 13:3x“).

- **Vor dem Archivieren prüfen, ob dort eine Frage des Nutzers steht** (15.10., 81v): der Nutzer suchte seine Schattenfrage in einer archivierten Diogenes-Sitzung; sie war zwar als 89 erledigt, aber er verliert den Faden.
- **Vor einer Oberflächen-Empfehlung den Code ansehen, und keine Ausgangslage unterstellen** (15.10., 72o.1/72s.1): Die Rahmenfarbe war schon die Seltenheit, und „bei seinem Söldner bleiben“ unterstellte einen Söldner, den der Spieler nie nehmen muss.
- **Hinweise des Nutzers prüfen statt übernehmen** (14.10., 69e, 72u): erst erfassen, auswerten, folgern; „nicht immer nur Ja sagen“. Ein „klingt gut“ beim Lesen ist kein Beschluss; eigene Argumente nicht fallenlassen, wenn der Nutzer eine Idee bringt, sondern sie dagegen prüfen (72u: zweimal zu schnell eingetragen).
- **Werkzeuge im Zielort prüfen, nicht hier** (15.10., 81p): diese Sitzung hat `create_session`, Routinen-Sitzungen nicht; dreimal falsch angenommen, erst die Probe mit ToolSearch im Zielort zählt.
- **Anweisungen an andere Sitzungen sauber halten** (15.10., D5.3): `git checkout origin/main -- <Datei>` ließ Fords Arbeitskopie „geändert“ zurück, der Git-Haken erzwang drei Zusatzzeilen; besser `git merge --ff-only origin/main`.
- **Bildvorschläge an der Karte nachrechnen** (15.10., 70.6): meine Empfehlung „Nordstraße, Tempel rechts schräg, Platz in der Tiefe“ war geometrisch unmöglich (Tempel 70° rechts); vor jedem Standpunkt eine Draufsicht mit Blickfeld.
- **Beim Start alle Punkte zu eigenen Themen auf „Dein Zug“ lesen** (14.10., 69e übersehen, weil an den Nutzer adressiert).
