# Berater

Gedächtnis der Beratungssitzung: wie das Spiel gebaut ist, was warum entschieden wurde, was wir gelernt haben. **Höchstens etwa 10 KB.** Nicht wiederholen, was in `CHANGELOG.md` oder `STIL.md` steht, sondern mit Themennummer darauf verweisen. Veraltetes kürzen oder ins `ARCHIV.md`.

Tom und Jerry dürfen unter „Lehren“ selbst eintragen, wenn sie etwas Grundsätzliches lernen (eine Zeile, mit Datum und Thema).

**Letzte Sitzungsnummer:** 02 (01 = Sitzung ab 15:10 am 12.10., Zählung ab da; 02 = „Talentliste und Fertigkeiten“, 18:02)

**Zuletzt gelesen bis:** `7de4f5c` (12.10., 16:39)

## Ritual

- **Start** (Nutzer schreibt „Berater“): diese Datei, dann `docs/OFFEN.md` (zuerst „Für den Berater“: was Tom/Jerry an mich abgegeben haben) (das Leitbild `LEITBILD.md` nur bei Grundsatzfragen), dann nur die Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`). Dazu `tools/story.sh <Stand>` (nur Textänderungen im Spiel, auch `EN alt`); bei Bedarf gegen laufende Zweige (`origin/<zweig>`). Kurz melden, was neu ist, Textänderungen gegen `docs/STORY.md` und Storyplan prüfen.
- **Ende** („Berater, festhalten“): neue Entscheidungen und Lehren eintragen, Veraltetes kürzen, „Zuletzt gelesen bis“ neu setzen, auf `main` pushen. **Dann immer den Nachfolger selbst starten** (Nutzer 12.10., 15:0x), Titel **„<lfd. Nr. zweistellig> Berater - <Grobthema>“** (Nutzer 12.10., 18:0x), z. B. „03 Berater - Talentliste“; Nummer aus „Letzte Sitzungsnummer“ oben plus 1, dort hochzählen: `create_session` (mit `source_url`, Zweig, Titel) oder ersatzweise `create_trigger` mit `run_once_at` in 2 Minuten, Name = Titel; Auftrag wie der eigene Start plus nächster Punkt. Dem Nutzer den Weg nennen: „Geplant“ → Aufgabe → „Verlauf“ (steht nicht in der Chatliste).
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

- **Nur diagonal** (13, 13.4, 13u, 13w, 12.10.): Gerade Ansicht wirkte flach. Testschalter weg (PR #43), fertige Orte diagonal, Wald/Tiefer Wald/Höhle gerade bis fertig; neue Orte nur diagonal (doppelte Arbeit vermeiden, Nutzer: keine Arbeit in Ansichten gegen das Ziel); alte Ansicht eingefroren (nur Absturz-Fixes), dann gelöscht. Danach Zoomstufe (6l).
- **Sichtbarkeit** (43, 12.10.): diagonal rückt der frühere rechte Rand vor die Kamera. Wichtiges (Leute, Questziele, Eingänge, Feuer) steht frei, Karten werden dafür umgestellt (27b, gegen Toms 27.3); Durchsicht nur um den Helden; Kisten dürfen versteckt sein. Morwen (Tiefer Wald) später bei Tom.
- **Leitbild** (44, 12.10.): `LEITBILD.md` als roter Faden (12 Grundsätze), Einzelheiten in `STIL.md` (Aussehen, Klang, Spiel) und `ENTWICKLUNG.md` (Ansicht, „Ort fertig“, Prüfen, Leistung). SRD = Gerüst, nicht Ziel (44f; Nutzer wollte weg von „nah am SRD“), keine AD&D-Erwähnung (kein zwingender Grund). Freigabe 16 (44a): Killerschlag und Blut „Deutlich“ als Obergrenze, Zerteilen in 3D vorher prüfen. Effekte und Hintergrundklänge bieten Tom/Jerry aktiv an (44d).
- **Geschäftsmodell** (45, 12.10., 13:30): Kapitel 1 kostenlos, dann einmal Vollversion, Kapitel nachkaufbar (45a); nie Werbung, Beutekisten, Wartezeiten (45c, Leitbild 13). Grund: Wer Abkürzungen verkauft, macht das Spiel sonst künstlich zäh.
- **Offen bei mir:** Heldenbau nach Freigabe als `docs/HELDENBAU.md` ablegen (Rest offen: Namen kursiver Talente, Erkennungszeichen-Standbilder, Jerrys Messung); Prüfungsquests und Umlern-Tempel sind Story (41, mit Nutzer); **45b nach Jerrys Messung 38 von mir aus ansprechen**; 41 Kapitel 2 stößt der Nutzer an.
- **Zufallshöhlen** (48, 12.10.): erst Questhöhlen ganz zufällig, Story-Höhlen später halb-halb (fester Kern), alles zufällig nein. 6–8 Kammern, verschlungen, Schleife nur manchmal, Sackgassen auch leer, Rückweg durch Durchgang nach dem Boss, Beute knapp (Jerry prüft gegen 38). Normale Blende reicht (Boden wird ohnehin bei jedem Betreten neu gezeichnet). Jerry baut 13e allgemein (48b). Nach Kapitel 1.
- **Heldenbau** (49, 50, 12.10.; [Dokument](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)): keine neuen Attribute (49d); Fertigkeiten 6–8 bei Lehrern (49e); Talente statt Attributspunkten als kleiner Baum, kein großer Skilltree (49f: zu teuer, führt zu wenigen besten Wegen); Rüstung höchstens eine Stufe über der Klasse, kein Schild für Magier (49g: Magier nie bester Tank). Neue Klassen als Klassenpaket (50a: zu wenige Kapitel für je eine), je Klasse zwei Pfade ab Stufe 3 (SRD + eigener), Pfad am Aussehen erkennbar (50b); Werwolf als Fluch mit Questreihe (50c); gekaufte Klassen nie stärker (Leitbild 13). **50d entschieden (16:xx):** Merkmale aus dem Code (Rüstungsstufe, Schild, Zauberer, Nah/Fern) plus Heilig/Arkan/Wild, je Pfad höchstens eins, Bestie (Fluch); jedes Merkmal öffnet mindestens zwei Dinge (50i), nie kaufbar (50f: Sperre gegen Magier-Tank), Spieler sieht ausgegraute Talente mit Grund (50g); Herkunft bei der Erstellung, 5 Stück (50j: individueller, lebendiger). **Talente als Linien** je Merkmal (49h/49i; 49n–49q, 18:1x: 9 Linien, 3 Stufen, Pfad-Linien 2, 7 einstufige, Zäh gestrichen: Lebenspunkte bleiben Klassensache); Talent auf jeder geraden Stufe (49r, Nutzer: 16/19 kämen sonst ewig spät, Kapitel ohne Wahl); Fertigkeit öffnet Möglichkeiten, Attribut gibt Zahlen (49s, Nutzer: „wenn umsetzbar“; geprüft: Gesprächsauswahl gibt es noch nicht): jedes Talent ändert eine Entscheidung, keine reinen Zahlen; höchste Stufe immer nur über Prüfungsquest beim Lehrer (49j/49l, Nutzer: „ultimative Ausbaustufe“); Umlernen nur im teuren Tempel ab Kapitel 3, letzte Wahl bis zur Rast zurücknehmbar mit Hinweis (49m; Nutzer: man kann jederzeit neu anfangen). Gold-Senke hilft gegen zu viel Gold (38).
- **Neustart nur bei großer Sitzung** (11.10.): Startlektüre ~12.000 Token. Nach „ja“ startet die Sitzung ihren Nachfolger selbst (46, 12.10.).
- **Textkasten (42), Klang (18, 24w, 28), Kampf nah am SRD (34, 35):** Begründungen im Archiv (16:4x); Klang-Einzelheiten in `STIL.md`.
- **Grundsatz „spielerfreundlich, einfach, frei“** (33, 12.10.): vier Fragen vor jeder Umsetzung von Ablauf und Bedienung (`STIL.md`).
- **Balance** (38, 12.10.): SRD als Fundament, Stufe 20 Obergrenze, mindestens 7 Kapitel, Stufen 5–14 als Kern, 15–20 erst am Ende; Abweichungen mit Grund in `BALANCE.md`. Plan fertig; Jerrys Messung (Messplan dort) nach 37 und 36.1, vor 13e (38e/38f). Schwierigkeitsgrad (39) nach Messung von „Normal“, Lautstärke-Regler (40).
- **Storyplan** (41, 12.10.): Dokument auf Toms Account ([Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)), Nutzer kommentiert dort; je Kapitel Zusammenfassung, Quests, Dialoge wortgetreu. **4 Augen:** Story-Änderungen erst nach Abstimmung Nutzer + Berater an Tom/Jerry (Kapitel 1 erst nach dem Test der 12 Tester): Dokument → „freigegeben“ → `docs/STORY.md` → Tom/Jerry bauen → Berater prüft mit `tools/story.sh`. Kapitel 2: Einstieg drei Entwürfe „Wer ist der Graue Prophet?“ (Motiv, Amulett, Priesterin, Tag der Asche), Stufe 8 am Ende; Kapitel 1 dafür aus `Story.kt`/`Jobs.kt` lesen, nicht das ganze Dokument. Nachtragen: Heldensätze 29.4 (Anmerkung 7).

## Lehren

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
- Wahl des Spielers, Optionen, individuell und lebendig (49/50). Generisches Maskulinum, nie weibliche oder gegenderte Formen (12.10.).
