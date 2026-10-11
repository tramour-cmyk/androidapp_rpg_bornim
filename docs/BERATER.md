# Berater

Gedächtnis der Beratungssitzung: wie das Spiel gebaut ist, was warum entschieden wurde, was wir gelernt haben. **Höchstens etwa 10 KB.** Nicht wiederholen, was in `CHANGELOG.md` oder `STIL.md` steht, sondern mit Themennummer darauf verweisen. Veraltetes kürzen oder ins `ARCHIV.md`.

Tom und Jerry dürfen unter „Lehren“ selbst eintragen, wenn sie etwas Grundsätzliches lernen (eine Zeile, mit Datum und Thema).

**Zuletzt gelesen bis:** `d57e05b` (11.10., 22:48)

## Ritual

- **Start** (Nutzer schreibt „Berater“): diese Datei, dann `docs/OFFEN.md`, dann nur die Änderungen seit „Zuletzt gelesen bis“: `git log --format='%h %ad %s' --date=format-local:'%d.%m. %H:%M' <Stand>..origin/main` (bei Bedarf `git diff <Stand>..origin/main -- docs CHANGELOG.md`). Kurz melden, was neu ist.
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
- **APK nie im Chat, nur Link** (11.10., 21:25): Platz sparen. Artefakt-Downloads scheitern noch an der Netzregel (`*.blob.core.windows.net`); der Nutzer stellt das am Rechner ein.
- **Filme sparsam** (09.10.): 36 s Spielzeit kosteten etwa 5 min. Logik per Kerntest, filmen nur bei sichtbarer Bewegung.
- **Neustart nur bei großer Sitzung** (11.10.): Jede Startlektüre kostet etwa 12.000 Token.
- **Selbstarbeit** mit Routinen alle 3 h und Vorrat je 8 Punkte (22, 23).
- **Klang:** echte CC0-Aufnahmen statt Synthese (18); Systemklänge nur in einer Fassung; Ortsklang nur von sichtbaren Quellen und anwesenden Leuten, **kein Stimmengewirr** (24w nein, 22:06); Musik orchestral und düster, Dorf mittelalterlich (28). Einzelheiten `STIL.md` → Klang.
- **Fremde Inhalte** nur mit Lizenz für kommerzielle Nutzung (Play Store), Quelle je Datei.
- **Kampfkulisse der Höhle angleichen:** zurückgestellt (Merkliste). Höhle-Flammen und Lichtstrahl (10, 11) bis zur diagonalen Höhle zurückgestellt.

## Lehren

- **Vorzeichnen muss ein festes Ziel haben** (24.5, 11.10.): Im Wolfsrudel wechselte der „nächste Gegner“ ständig, jeder Wechsel brach das Zeichnen ab, Gegner wurden nie fertig. Lösung 24.18: feste Reihenfolge.
- **Erst messen, dann beschleunigen** (24.14): Erster Start sank von 27 s auf 5,9 s, Waffenwechsel von 15,7 s auf 2,9 s, erst nachdem der Test-Reiter Zeiten zeigte.
- **Bilder auf dem Gerät speichern lohnt** (24.4): Neustart 0,1 s statt 27 s.
- **Abstürze ohne Bericht sind blind** (30, 11.10.): Bis heute gab es keinen Absturz-Fänger. Erst Fehlertext holen, dann suchen.

## Beobachtungen des Beraters (ungeprüft)

- **Zu Thema 30 (geprüft 22:58):** Die Bildspeicher von `HeroBattle`, `MapGround`, `MapFolk`, `MapFigure` sind sauber gesperrt (`synchronized`), gleichzeitiger Zugriff dort ist kaum die Ursache. Offen: unbegrenzte Speicher (`WorldArt`, `MapFlora`, `MapTown`, `MapTownIso`) und Lastspitze nach Niederlage (Kartenwechsel); `BattleAhead.run` ohne Fehlerfang.

## Deine Linie (der Nutzer)

- Düster, erwachsen, glaubwürdig; nie niedlich (`STIL.md` → Richtung).
- Erst reden, dann arbeiten; eine Rückfrage ist keine Freigabe. Vor großen optischen Änderungen Standbilder, keine Filmstreifen.
- Was funktioniert, muss er nicht erfahren; kurze, nummerierte Rückfragen mit Empfehlung.
