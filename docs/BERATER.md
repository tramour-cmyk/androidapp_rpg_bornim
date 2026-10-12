# Berater

Gedächtnis der Beratungssitzung: wie das Spiel gebaut ist, was warum entschieden wurde, was wir gelernt haben. **Höchstens etwa 10 KB.** Nicht wiederholen, was in `CHANGELOG.md` oder `STIL.md` steht, sondern mit Themennummer darauf verweisen. Veraltetes kürzen oder ins `ARCHIV.md`.

Tom und Jerry dürfen unter „Lehren“ selbst eintragen, wenn sie etwas Grundsätzliches lernen (eine Zeile, mit Datum und Thema).

**Zuletzt gelesen bis:** `b9c72c9` (12.10., 15:05)

## Ritual

- **Start** (Nutzer schreibt „Berater“): diese Datei, dann `docs/OFFEN.md` (das Leitbild `LEITBILD.md` nur bei Grundsatzfragen), dann nur die Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`). Dazu `tools/story.sh <Stand>` (nur Textänderungen im Spiel, auch `EN alt`); bei Bedarf gegen laufende Zweige (`origin/<zweig>`). Kurz melden, was neu ist, Textänderungen gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): neue Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ neu setzen, auf `main` pushen. **Dann immer die Nachfolgerin selbst starten** (Nutzer 12.10., 15:0x), Titel nach den Themen, damit der Nutzer sie wiederfindet, z. B. „Berater: 50d Merkmale, 49 Talente“: `create_session` (mit `source_url`, Zweig, Titel) oder ersatzweise `create_trigger` mit `run_once_at` in 2 Minuten, Name = Titel; Auftrag wie der eigene Start plus nächster Punkt.
- **Größere Entwürfe als Dokument** (Nutzer 12.10.): Matrizen, Listen, Erklärungen, die der Nutzer wiederfinden will, als Claude-Docs-Dokument (Artefakt), Link in `OFFEN.md` und hier bei den Entscheidungen; nach Freigabe als `docs/<NAME>.md` ins Repo.
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

- **Nur diagonal** (13, 13.4, 13u, 13w, 12.10.): Gerade Ansicht wirkte flach. Testschalter weg (PR #43), fertige Orte diagonal, Wald/Tiefer Wald/Höhle gerade bis fertig; neue Orte nur diagonal (doppelte Arbeit vermeiden, Nutzer: keine Arbeit in Ansichten gegen das Ziel); alte Ansicht eingefroren (nur Absturz-Fixes), dann gelöscht. Danach Zoomstufe (6l).
- **Sichtbarkeit** (43, 12.10.): diagonal rückt der frühere rechte Rand vor die Kamera. Wichtiges (Leute, Questziele, Eingänge, Feuer) steht frei, Karten werden dafür umgestellt (27b, gegen Toms 27.3); Durchsicht nur um den Helden; Kisten dürfen versteckt sein. Morwen (Tiefer Wald) später bei Tom.
- **Leitbild** (44, 12.10.): `LEITBILD.md` als roter Faden (12 Grundsätze), Einzelheiten in `STIL.md` (Aussehen, Klang, Spiel) und `ENTWICKLUNG.md` (Ansicht, „Ort fertig“, Prüfen, Leistung). SRD = Gerüst, nicht Ziel (44f; Nutzer wollte weg von „nah am SRD“), keine AD&D-Erwähnung (kein zwingender Grund). Freigabe 16 (44a): Killerschlag und Blut „Deutlich“ als Obergrenze, Zerteilen in 3D vorher prüfen. Effekte und Hintergrundklänge bieten Tom/Jerry aktiv an (44d).
- **Geschäftsmodell** (45, 12.10., 13:30): Kapitel 1 kostenlos, dann einmal Vollversion, Kapitel nachkaufbar (45a); nie Werbung, Beutekisten, Wartezeiten (45c, Leitbild 13). Grund: Wer Abkürzungen verkauft, macht das Spiel sonst künstlich zäh.
- **Offen bei mir:** **50d** Merkmale genauer besprechen (Nutzer will reden), dann Talentliste und Fertigkeiten im [Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14) mit dem Nutzer durchgehen; **45b nach Jerrys Messung 38 von mir aus ansprechen** (Beschleuniger ja/nein, nur ohne Popups, feste Preise, nie beste Ausrüstung); 41 Kapitel 2 stößt der Nutzer an. 47 erledigt (README).
- **Zufallshöhlen** (48, 12.10.): erst Questhöhlen ganz zufällig, Story-Höhlen später halb-halb (fester Kern), alles zufällig nein. 6–8 Kammern, verschlungen, Schleife nur manchmal, Sackgassen auch leer, Rückweg durch Durchgang nach dem Boss, Beute knapp (Jerry prüft gegen 38). Normale Blende reicht (Boden wird ohnehin bei jedem Betreten neu gezeichnet). Jerry baut 13e allgemein (48b). Nach Kapitel 1.
- **Heldenbau** (49, 50, 12.10.; [Dokument](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)): keine neuen Attribute (49d); Fertigkeiten 6–8 bei Lehrern (49e); Talente statt Attributspunkten als kleiner Baum, kein großer Skilltree (49f: zu teuer, führt zu wenigen besten Wegen); Rüstung höchstens eine Stufe über der Klasse, kein Schild für Magier (49g: Magier nie bester Tank). Neue Klassen als Klassenpaket (50a: zu wenige Kapitel für je eine), je Klasse zwei Pfade ab Stufe 3 (SRD + eigener), Pfad am Aussehen erkennbar (50b); Werwolf als Fluch mit Questreihe (50c); gekaufte Klassen nie stärker (Leitbild 13).
- **Textkasten im Stil der Blenden** (42, 12.10.): heller Kasten mit rotem Sprecher war Game-Boy-Look gegen `STIL.md`. Ganz schwarz (nicht durchscheinend: lesbarer, näher an der Blende), dünner Goldrand, Sprecher Gold in Kapitälchen im Kasten, Text gebrochenes Weiß, Serife, Erzähltext kursiv. Erst nur Textkasten, Menüs später; Tom nach 13, erst Standbilder.
- **Lastverteilung** (23b, 12.10.): Jerry hat mehr (Kampf, Klang, Balance, 13e), aber kein Warten aufeinander; Nutzer will nichts umverteilen. Einzige Kreuzung: Lyra diagonal (Tom) für 13e (Jerry), Merkposten bei Tom. Engpass ist eher der Test des Nutzers.
- **Release nur auf Zuruf** (21): Die Releaseflut störte; Zweig-Builds sind Artefakte.
- **Neustart nur bei großer Sitzung** (11.10.): Startlektüre ~12.000 Token. Nach „ja“ startet die Sitzung ihre Nachfolgerin selbst (46, 12.10.).
- **Selbstarbeit** mit Routinen alle 3 h und Vorrat je 8 Punkte (22, 23).
- **Klang:** echte CC0-Aufnahmen statt Synthese (18); Systemklänge nur in einer Fassung; Ortsklang nur von sichtbaren Quellen und anwesenden Leuten, **kein Stimmengewirr** (24w nein, 22:06); Musik orchestral und düster, Dorf mittelalterlich (28). Einzelheiten `STIL.md` → Klang.
- **Grundsatz „spielerfreundlich, einfach, frei“** (33, 12.10.): vier Fragen vor jeder Umsetzung von Ablauf und Bedienung (`STIL.md`).
- **Kampf nah am SRD** (12.10.): „Zug beenden“ jetzt (34, auch um Testkämpfe schnell zu verlieren), „Abwarten“/„Helfen“ erst mit Begleitern (Merkliste). Weihwasser nur gegen Untote, 2W6, sonst ausgegraut mit Hinweis (35): vorher 2W6 gegen alle, unglaubwürdig.
- **Krogg schärfen** (36, 12.10.): erst aufräumen bei gleicher Auflösung (Fellkörnung 0,55 war Hauptgrund), Standbilder Handy/Emulator; nur falls nötig 1,5× mit zugeschnittenen Bildern, vorher messen. Doppelte Auflösung abgelehnt: Krogg ~50 MB → ~200 MB, 4× Zeichenzeit.
- **Balance** (38, 12.10.): SRD als Fundament, Stufe 20 Obergrenze, mindestens 7 Kapitel, Stufen 5–14 als Kern, 15–20 erst am Ende; Abweichungen mit Grund in `BALANCE.md`. Plan fertig; Jerrys Messung (Messplan dort) nach 37 und 36.1, vor 13e (38e/38f). Schwierigkeitsgrad (39) nach Messung von „Normal“, Lautstärke-Regler (40).
- **Storyplan** (41, 12.10.): Dokument auf Toms Account ([Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)), Nutzer kommentiert dort; je Kapitel Zusammenfassung, Quests, Dialoge wortgetreu. **4 Augen:** Story-Änderungen erst nach Abstimmung Nutzer + Berater an Tom/Jerry (Kapitel 1 erst nach dem Test der 12 Tester): Dokument → „freigegeben“ → `docs/STORY.md` → Tom/Jerry bauen → Berater prüft mit `tools/story.sh`. Kapitel 2: Einstieg drei Entwürfe „Wer ist der Graue Prophet?“ (Motiv, Amulett, Priesterin, Tag der Asche), Stufe 8 am Ende; Kapitel 1 dafür aus `Story.kt`/`Jobs.kt` lesen, nicht das ganze Dokument. Nachtragen: Heldensätze 29.4 (Anmerkung 7).
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
- **Notizen vor dem Ändern frisch holen** (12.10.): Tom/Jerry ändern `OFFEN.md` im Minutentakt; zweimal schlug mein Ersetzen fehl, weil sich die Übergabe geändert hatte. Erst `git pull`, Treffer prüfen (`assert`), dann committen; nie nach fehlgeschlagenem Ersetzen blind committen.
- **Große Dokumente teuer** (12.10.): Storyplan ganz einlesen kostet viel; nur lesen, wenn am Dokument gearbeitet wird.
- **Vor dem Absenden gegenlesen** (12.10., 13:10): Ein Bruchstück eigener Überlegungen („ab 20 KB teuer“) rutschte sinnlos in eine Antwort, eine Rückfrage stand ohne Nummer im Fließtext. Prüfen: jedes Fragezeichen in der nummerierten Liste? Jeder Satz mit Bezug?
- **Selbstverständliches nicht fragen** (44d): „nur Klänge oder auch sichtbare Effekte?“ war unnötig; im Sinne des Nutzers entscheiden und nennen.
- **Berater-Werkzeug:** Nach Push aus `../bornim-main` zeigt die Hauptkopie die eigenen Notizen als „geändert“ (gleicher Zweig, alter Index). Nie committen (dreht Änderungen zurück), sondern `git reset --hard HEAD` in der Hauptkopie; vom Nutzer freigegeben 12.10., 13:5x.
- **Erst prüfen, dann Kosten nennen** (48, 12.10.): Ladezeit als Kostenpunkt genannt, ohne nachzusehen; sie war keiner. Technische Behauptungen vorher kurz im Code prüfen.

## Deine Linie (der Nutzer)

- Düster, erwachsen, glaubwürdig; nie niedlich (`STIL.md` → Richtung).
- Erst reden, dann arbeiten; eine Rückfrage ist keine Freigabe. Keine Arbeit in Sackgassen (Ansichten, die wegfallen). Vor großen optischen Änderungen Standbilder, keine Filmstreifen.
- Was funktioniert, muss er nicht erfahren; kurze, nummerierte Rückfragen mit Empfehlung.
