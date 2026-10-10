# Aufteilung der Arbeit auf zwei Accounts

Stand: 09.10.2026, 18:48 (Berliner Zeit). Die Karte wird gerade im neuen Stil umgebaut (siehe [Offen](OFFEN.md), Abschnitt „Karte im neuen Stil“). Damit zwei Claude-Sitzungen (zwei Accounts) gleichzeitig daran arbeiten können, ohne sich in die Quere zu kommen, ist die Arbeit hier aufgeteilt. Wer eine Sitzung beginnt, liest zuerst `CLAUDE.md`, dann diese Datei, dann `docs/OFFEN.md`.

## Wer macht was

| | Account A (Hauptsitzung) | Account B (Zweitaccount) |
|---|---|---|
| Aufgabe | Leute und Monster auf der Karte als Puppe | Höhle im neuen Stil, danach das Dorf |
| Zweig | `karte-neuer-stil` | `karte-hoehle` (von `karte-neuer-stil` abgezweigt) |
| Eigene Dateien | `core/.../art/MapFigure.kt`, Figuren-Teil von `WorldScreen.kt` (Held, Leute, Monster), `CharacterArt.kt`, `MonsterArt.kt` (Kartenbilder) | neue Datei `core/.../art/MapCave.kt`, Höhlen-Teile in `MapGround.kt` und `MapFlora.kt`, `MapLight.kt` (nur Höhle) |
| Nicht anfassen | Höhlen- und Dorfbilder | `MapFigure.kt`, Figuren in `WorldScreen.kt`, `CharacterArt.kt`, `MonsterArt.kt` |

Gemeinsam genutzt (nur kleine, abgesprochene Änderungen): `WorldScreen.kt` (Boden-Teil), `WorldArt.kt`, `tools/preview/src/main/kotlin/Main.kt`, `CHANGELOG.md`, `docs/OFFEN.md`.

## Regeln für die Zusammenarbeit

- Jeder arbeitet nur auf seinem Zweig. Account B pusht nie auf `karte-neuer-stil`, Account A nie auf `karte-hoehle`.
- Vor jedem Push den eigenen Zweig mit dem Stand des anderen abgleichen, damit Konflikte klein bleiben:
  - B: `git fetch origin karte-neuer-stil && git merge origin/karte-neuer-stil` (regelmäßig, mindestens vor jedem Test-Build).
  - A führt `karte-hoehle` erst nach dem Test des Nutzers in `karte-neuer-stil` zusammen.
- `docs/OFFEN.md`: Jeder schreibt nur in seinen eigenen Unterpunkt unter „In Arbeit“ („Karte: Figuren (Account A)“ bzw. „Karte: Höhle (Account B)“). `CHANGELOG.md`: eigener Absatz unter „Unveröffentlicht“, mit Zweigname.
- Test-Builds: Jeder Push auf einen Zweig baut ein APK (GitHub Actions „Build APK“). Laufnummern sind gemeinsam; der Nutzer installiert immer das neueste. APK zusätzlich direkt im Chat schicken (`gh run download …`).
- Alle Regeln aus `CLAUDE.md` gelten für beide: Zeitstempel in jeder Nachricht, erst besprechen, dann arbeiten, vor großen optischen Änderungen Entwürfe zeigen, vor jedem Commit `./gradlew -p core test`.

## Was schon steht (Stand 09.10., Zweig `karte-neuer-stil`)

- **Naher Zoom** (etwa 5½ Kacheln Breite, im Testreiter umschaltbar), ruhigeres Lauftempo, Tempo je Gelände (`core/.../Terrain.kt`).
- **Neuer Boden im Wald** (`MapGround.kt`): doppelte Auflösung (64 Bildpunkte je Kachel, `MapGround.D = 2`), kein Raster, in Stücken von 4 × 4 Kacheln im Hintergrund vorgezeichnet; Wege als zusammenhängendes Netz mit Fahrspuren. `MapGround.supports(map)` gilt bisher nur für `MapKind.FOREST`; Kacheln, die der neue Boden nicht kennt, behalten ihr altes Bild (`keepsOldTile`).
- **Bäume, Felsen, Unterholz, Feuer, Truhe, Schild** im Wald (`MapFlora.kt`), mit Schatten nach der Sonne; Kronen, Felsen und Büsche vor dem Helden werden halb durchsichtig.
- **Der Held als Puppe** (`MapFigure.kt`): schräg von oben, 16 Richtungen mit weichem Umdrehen, vier Schrittbilder, Schild auf dem Rücken, kurze Waffen tief, lange an der Schulter.

## Aufgabe für Account B: die Höhle im neuen Stil

Ziel: Die Blutzahnhöhle (`Story.cave` in `core/.../Story.kt`, `MapKind.CAVE`) sieht so aus wie der neue Wald: doppelte Auflösung, kein Raster, düster, Licht nur von sichtbaren Quellen (Stil-Leitlinien in `docs/STIL.md`).

1. **Entwurf zuerst** (Regel aus `CLAUDE.md`): einen Ausschnitt der Höhle (z. B. Eingang mit Fackeln und den Gang zum Lager) im neuen Stil als Bild zeigen, vorher gegen nachher, bevor etwas eingebaut wird. Als Vorbild dienen die Kampfkulissen der Höhle (`core/.../art/CaveScene.kt`, Vorschau `CAVES=1`) und der Wald-Prototyp `tools/entwurf/lichtung.py`.
2. **Boden**: Felsboden, Geröll, feuchte Stellen und Pfützen, Übergänge ohne Raster; Höhlenwände (`CAVE_WALL`) mit Höhe und Kanten, damit man den Raum liest. Umsetzung am besten in einer neuen Datei `MapCave.kt` nach dem Muster von `MapGround.kt`, und `MapGround.supports` bzw. die Aufrufe in `WorldScreen.kt` und `WorldArt.buildObjects` um die Höhle erweitern (kleine Änderung, mit Account A abgesprochen).
3. **Dinge**: Fackeln, Leuchtpilze, Kristalle, Stalagmiten, Geröll, Knochen, Kisten, Schlafrollen, Stützbalken, Lichtschacht, Gitter (`Tile.*` in `core/.../World.kt`), alle in doppelter Auflösung; die Lichtquellen bleiben, wo sie sind (`MapLight.kt` liest sie aus den Kacheln).
4. **Prüfen**: Vorschau `KARTENZOOM=1 ONLY=zoom_nah_5_hoehle` (Bildschirmfoto im echten Spiel), `FLORA=cave:x0:y0:breite:höhe` (Ausschnitt als Bild; `renderFloraSheet` muss dafür um die Höhle erweitert werden), Lauf-Film `WALKFILM=cave:10:5` (Laufen durch die echte Oberfläche). Kerntests.
5. Danach, nach Rückmeldung des Nutzers: **das Dorf** auf dieselbe Weise (Pflaster, Häuser, Brunnen, Marktstände).

## Aufgabe für Account A: Leute und Monster

1. Garrick und die Dorfbewohner als Puppe (Entwurf zuerst), mit passender Kleidung je Beruf.
2. Danach die Monster auf der Karte aus ihren Kampfmodellen, mit eigener Laufbewegung (Vierbeiner).

## Werkzeuge in `tools/preview` (Aufruf: `cd tools/preview && VAR=… ../../gradlew -q run`)

- `KARTENZOOM=1` (mit `ONLY=zoom_nah…`): Bildschirmfotos der Karte im echten Spiel, nah und weit.
- `FLORA=karte:x0:y0:breite:höhe`: ein Kartenausschnitt in voller Auflösung, direkt aus den Kartenbildern.
- `WALKFILM=karte:x:y`: Laufen durch die echte Oberfläche mit der Wischsteuerung, alle 80 ms ein Bild unter `build/screens/films/walk/`.
- `MAPFIG=1`, `MAPFIGYAWS=1`: Kartenfigur in allen Richtungen, für alle Waffenarten.
- Netz: Maven Central antwortet beim ersten Laden oft mit 429; dann noch einmal, notfalls mit `--max-workers=1` (siehe `docs/UMGEBUNG.md`).

## Einstieg für den Zweitaccount (zum Einfügen in die neue Sitzung)

> Arbeite am Repo `tramour-cmyk/androidapp_rpg_bornim`. Lies `CLAUDE.md`, dann `docs/AUFTEILUNG.md`, dann `docs/OFFEN.md`. Du bist Account B: Lege vom Zweig `karte-neuer-stil` den Zweig `karte-hoehle` an und übernimm die dort beschriebene Aufgabe „Höhle im neuen Stil“. Fang mit dem Entwurf an und zeig ihn mir, bevor du etwas einbaust.

## Nachtrag 09.10., 23:48: Dorf und Innenräume

Auf Wunsch des Nutzers (23:29/23:30) hat Account A in der Nacht **Entwürfe** für das Dorf und die Innenräume im neuen Stil gemacht (`core/.../art/MapTown.kt`, `MapRoom.kt`, Bodenteile in `MapGround.kt`; nur in der Vorschau mit `TOWNDRAFT=1`, im Spiel aus). Laut Tabelle oben war das Dorf Aufgabe von Account B. **Account B: bitte nicht parallel am Dorf anfangen**, bis der Nutzer entschieden hat, wer weitermacht.

**Entschieden 10.10., 08:34:** Das Dorf und die Innenräume macht Account A weiter. Account B fängt dort nicht an.
