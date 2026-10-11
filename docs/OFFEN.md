# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 26** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | Schänke, Ältester, Laden, Tempel auf `main` (PR #20, 11.10., 14:00). Weiter mit Dorf draußen (5) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | – | 5.1, 5.2, 5g, 5h.1 auf `main` (PR #24, 11.10., 14:52). Offen: 5l/5.5 Leben im Dorf (Rückfrage), 5.3, 5.4 |
| 25 | Laternen geben nachts Licht, wirken als Quelle aber dunkel | Tom | – | gemeldet 11.10., 14:52; Befund und Vorschlag 25.1 im Chat, wartet auf Entscheidung 25a |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; frei, seit 13 auf `main` ist |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 13e | Höhle diagonal (Phase 2 von 13: Orte aufteilen) | Jerry | – | 13e.1 ja (13:52): nach 18 Runde 2, erst Entwürfe. **Tom einverstanden (14:16).** Jerry: neue Datei `MapCaveIso.kt` und eine Zeile in `WorldArt.buildObjects` (wie Räume/Dorf). Nicht anfassen ohne Absprache: `WorldScreen.kt` (Sortierung, `hides`, `put`/`corner`, `Cam`), `MapSight`, `FreeWalk`, `MapRoomIso`, `MapTownIso`, `MapGround`. Vorlage: `MapTownIso` (`Tile1`, `plane`/`box`/`cylinder`, Tiefe `(tx+ty)*T+1.5T−1`, `corner = true`, `group` für Mehrfeld-Dinge) |
| 18 | Klänge aus echten Aufnahmen (CC0) | Jerry | neu von `main` | Runde 2 getestet, auf `main` (PR #23, 14:48). Offen: **18h** Tropfen in der Höhle nicht zu hören, **18i** Feuerknistern setzt schlagartig ein statt allmählich (Nutzer 14:45) |
| 22 | Selbstarbeit statt nur Nachtarbeit: Routinen alle 3 h, Vorrat und Liste „Für gemeinsame Zeit“ | Tom | `main` (Notizen), Routinen | 22a, 22b ja (13:31). `docs/SELBST.md` statt `NACHT.md`; Toms Routinen umgestellt (13:38); Nutzer: neue Routinen einstellen (Repo, automatisch). Jerrys Routinen umgestellt (13:44), Vorrat eingetragen |
| 23 | Aufgaben so aufteilen, dass Tom und Jerry auch in Selbstarbeit genug Vorrat haben | Tom | `main` (Notizen) | 23a ja (14:18): je 8 Punkte im Vorrat (`docs/SELBST.md`), neue nur als Entwürfe/Hörproben. **Jerry:** deine Punkte 4–8 sind eingetragen |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 24 | Animationen fehlen nach Spielstart und Kartenwechsel (Held schwebt ohne Beinbewegung, Atmen fehlt); Übergangsbild, bis alles gezeichnet ist | Tom (Karte); Kampfbilder mit Jerry abstimmen | – | entschieden 11.10., 14:39: 24.1–24.3 bauen (Tom-Arbeitssitzung, nach dem laufenden Schritt), 24.4 auf die Merkliste |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 14:36)

- **5 Dorf:** Zweig `tom-dorf` (mit `main`), [PR #24](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/24) getestet (0.1.504) und zusammengeführt (14:52). **Als Nächstes:** 24.1–24.3 bauen (entschieden), 25 nach Entscheidung.
- Rückmeldung Test 0.1.501 (noch zu besprechen, **5l**): Marktplatz sehr groß, wenig darauf, „wenig los im Dorf“; Gänse rechts unten gefallen; Wunsch nach Hühnern, Katzen, Hunden u. Ä. Nachts sehr dunkel, aber stimmig. Vorschlag für die neue Sitzung: 5.5 „Leben im Dorf“ (Tiere, Leute bei der Arbeit, Platz dichter: mehr Stände, Karren, Kisten oder Platz verkleinern).
- Code: `core/.../art/MapTownIso.kt` (Häuser in Streifen, `Tile1` mit `plane`/`box`/`cylinder`, Dinge auf dem Platz), Fenster aus dem Raum `windowsFromRoom`, Durchsicht in `WorldScreen.hides` (Gruppe + Pixeltest). Vorschau `ISODINGE=dorf|platz`, `KARTENZOOM=1 DIAG=1 TOWNDRAFT=1 ONLY=zoom_nah_d`.
- Danach Vorrat in `docs/SELBST.md` (5.3 Dorfbewohner als Puppen, 5.4, 17, 14, …). Routinen alle 3 h eingerichtet; die fünf neuen (09:24–21:24) braucht der Nutzer noch mit Repo und „automatisch“.

### Jerry (11.10., 14:24)

- Zweig `claude/eloquent-dirac-eg6m37`, Entwurfs-PR #23 (mit `main` gemischt): 18 Runde 2 im Spiel, alle 17 Klänge aus Aufnahmen (18f, 18g; Held fällt kein Systemklang mehr). Kerntests grün. **Zweig-Build von 9ce1f55 läuft (14:23):** neue Sitzung prüft ihn (`subscribe_pr_activity` PR #23 neu abonnieren), Link, APK und Testliste an den Nutzer (Kampfbeginn, Bemerkt, Hinterhalt, Held fällt, Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf, Vögel, Grillen, Eule, Tropfen, Knistern, Lautstärke).
- Aufnahmen: `tools/klang/holen.sh <ordner>` (Freesound braucht Pausen, sonst 403), Rezepte `tools/klang/rezepte.py` (`--proben`, `--nur`; Einbau überschreibt alle OGG: danach `git checkout -- app/src/main/assets/sfx/` und nur neue Dateien behalten). Routinen umgestellt (xx:27).
- Als Nächstes nach Test und Zusammenführen: Vorrat in `SELBST.md` (2 Stimmen übrige Gegner, 3 9i, 4 13e Höhle mit Toms Dateigrenzen, …).

## Zu testen


– nichts offen –

## Rückfragen an den Nutzer

- **18j** (Jerry, 14:50): 18h.1 Tropfen unabhängig vom Feuer, öfter und etwas lauter; 18i.1 Knistern als Schleife, die mit der Nähe zum Feuer weich lauter und leiser wird (auch Herd). Erst Hörprobe (Gang aufs Feuer zu), dann Zweig-Build. Empfehlung: ja.

- **24 Animationen fehlen am Anfang (gemeldet 11.10., 14:36; Befund Tom-Beratung 14:45):** Stimmt. Der Held auf der Karte hat 16 Richtungen × 8 Schrittbilder = 128 Bilder; `MapFigure.prepare` zeichnet sie in einem einzigen Hintergrund-Faden mit niedriger Priorität. Bis ein Bild fertig ist, zeigt `frameNow` das Standbild dieser Richtung, deshalb gleitet der Held ohne Beinbewegung. Atmen und Gewicht verlagern (`MapRest`) werden erst beim ersten Bedarf in einem weiteren Faden gezeichnet; Leute (`MapFolk.prepareFor`) und Boden (`MapGround.prepare`) beim Kartenwechsel ebenso. Ein Wechsel der Ausrüstung verwirft alle Heldenbilder (`cache.keys.removeAll`), danach fehlt das Laufen wieder. Vorschläge: 24.1 Übergangsbild beim Spielstart und Kartenwechsel (dunkle Blende im Stil, Ortsname, kurzer Satz), bleibt, bis das Nötige fertig ist (Laufen des Helden in allen Richtungen, Atmen, Leute der Karte, Boden um den Helden), höchstens etwa 4 s, danach weiter im Hintergrund; 24.2 schneller zeichnen: mehrere Fäden (Zahl der Kerne), höhere Priorität, solange das Übergangsbild steht; 24.3 bei Ausrüstungswechsel alte Bilder behalten, bis die neuen fertig sind; 24.4 gezeichnete Bilder auf dem Gerät speichern, damit der nächste Start sofort geht. **Entschieden 14:39:** 24a ja, 24b ja (24.2 und 24.3 gleich mit), 24c ja (24.4 erst nach Messung, steht auf der Merkliste). **An die Tom-Arbeitssitzung:** 24.1–24.3 bauen; vorher Abgleich mit `STIL.md` (Blende im Stil, Übergang Blende → Karte weich), Kerntest für „Übergangsbild endet, sobald das Nötige fertig ist oder spätestens nach etwa 4 s“, Zeiten vorher/nachher im Bericht (wie lange bis alles gezeichnet ist). Für die Kampfbilder dieselbe Lösung mit Jerry abstimmen.





- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
