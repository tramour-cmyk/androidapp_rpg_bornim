# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 24** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | Schänke, Ältester, Laden, Tempel auf `main` (PR #20, 11.10., 14:00). Weiter mit Dorf draußen (5) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | `tom-dorf` | 5.1 Häuser, 5h.1 Fenster, 5g Glockenturm, 5.2 Dinge auf dem Platz: Zweig-Build 0.1.501 zu testen (14:22). Danach 5.3, 5.4 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; frei, seit 13 auf `main` ist |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 13e | Höhle diagonal (Phase 2 von 13: Orte aufteilen) | Jerry | – | 13e.1 ja (13:52): nach 18 Runde 2, erst Entwürfe. **Tom einverstanden (14:16).** Jerry: neue Datei `MapCaveIso.kt` und eine Zeile in `WorldArt.buildObjects` (wie Räume/Dorf). Nicht anfassen ohne Absprache: `WorldScreen.kt` (Sortierung, `hides`, `put`/`corner`, `Cam`), `MapSight`, `FreeWalk`, `MapRoomIso`, `MapTownIso`, `MapGround`. Vorlage: `MapTownIso` (`Tile1`, `plane`/`box`/`cylinder`, Tiefe `(tx+ty)*T+1.5T−1`, `corner = true`, `group` für Mehrfeld-Dinge) |
| 18 | Klänge aus echten Aufnahmen (CC0) | Jerry | `claude/eloquent-dirac-eg6m37`, PR #23 (Entwurf) | Runde 2 komplett eingebaut (18f, 18g). Zweig-Build 0.1.503 zu testen (14:28) |
| 22 | Selbstarbeit statt nur Nachtarbeit: Routinen alle 3 h, Vorrat und Liste „Für gemeinsame Zeit“ | Tom | `main` (Notizen), Routinen | 22a, 22b ja (13:31). `docs/SELBST.md` statt `NACHT.md`; Toms Routinen umgestellt (13:38); Nutzer: neue Routinen einstellen (Repo, automatisch). Jerrys Routinen umgestellt (13:44), Vorrat eingetragen |
| 23 | Aufgaben so aufteilen, dass Tom und Jerry auch in Selbstarbeit genug Vorrat haben | Tom | `main` (Notizen) | 23a ja (14:18): je 8 Punkte im Vorrat (`docs/SELBST.md`), neue nur als Entwürfe/Hörproben. **Jerry:** deine Punkte 4–8 sind eingetragen |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 14:36)

- **5 Dorf:** Zweig `tom-dorf` (mit `main`), [PR #24](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/24) offen. Test 0.1.501 positiv (vor 14:36); danach Rauch berichtigt (stieg an alten Stellen auf, jetzt aus den Schornsteinen, `drawTownSmoke` + `MapTownIso.chimneyTops`). **Als Nächstes:** PR-Build ansehen, Rauch kurz vom Nutzer bestätigen lassen (oder Standbild), dann PR #24 selbst zusammenführen, „Unveröffentlicht“ ergänzen, Zeile „Zu testen“ löschen.
- Rückmeldung Test 0.1.501 (noch zu besprechen, **5l**): Marktplatz sehr groß, wenig darauf, „wenig los im Dorf“; Gänse rechts unten gefallen; Wunsch nach Hühnern, Katzen, Hunden u. Ä. Nachts sehr dunkel, aber stimmig. Vorschlag für die neue Sitzung: 5.5 „Leben im Dorf“ (Tiere, Leute bei der Arbeit, Platz dichter: mehr Stände, Karren, Kisten oder Platz verkleinern).
- Code: `core/.../art/MapTownIso.kt` (Häuser in Streifen, `Tile1` mit `plane`/`box`/`cylinder`, Dinge auf dem Platz), Fenster aus dem Raum `windowsFromRoom`, Durchsicht in `WorldScreen.hides` (Gruppe + Pixeltest). Vorschau `ISODINGE=dorf|platz`, `KARTENZOOM=1 DIAG=1 TOWNDRAFT=1 ONLY=zoom_nah_d`.
- Danach Vorrat in `docs/SELBST.md` (5.3 Dorfbewohner als Puppen, 5.4, 17, 14, …). Routinen alle 3 h eingerichtet; die fünf neuen (09:24–21:24) braucht der Nutzer noch mit Repo und „automatisch“.

### Jerry (11.10., 14:24)

- Zweig `claude/eloquent-dirac-eg6m37`, Entwurfs-PR #23 (mit `main` gemischt): 18 Runde 2 im Spiel, alle 17 Klänge aus Aufnahmen (18f, 18g; Held fällt kein Systemklang mehr). Kerntests grün. **Zweig-Build von 9ce1f55 läuft (14:23):** neue Sitzung prüft ihn (`subscribe_pr_activity` PR #23 neu abonnieren), Link, APK und Testliste an den Nutzer (Kampfbeginn, Bemerkt, Hinterhalt, Held fällt, Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf, Vögel, Grillen, Eule, Tropfen, Knistern, Lautstärke).
- Aufnahmen: `tools/klang/holen.sh <ordner>` (Freesound braucht Pausen, sonst 403), Rezepte `tools/klang/rezepte.py` (`--proben`, `--nur`; Einbau überschreibt alle OGG: danach `git checkout -- app/src/main/assets/sfx/` und nur neue Dateien behalten). Routinen umgestellt (xx:27).
- Als Nächstes nach Test und Zusammenführen: Vorrat in `SELBST.md` (2 Stimmen übrige Gegner, 3 9i, 4 13e Höhle mit Toms Dateigrenzen, …).

## Zu testen

- **0.1.501** (Tom, 5, `tom-dorf`, [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38138465071/artifacts/11702163109)): Dorf diagonal (Häuser, Fenster außen wie innen, Glockenturm, Platz); Prüfliste im Chat 14:22. **Getestet vor 14:36: positiv**, Rückmeldung unter Tom (5l).
- **0.1.503** (Jerry, 18, PR #23, [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38139097892/artifacts/11702370389)): alle 17 Klänge aus Aufnahmen; Prüfliste im Chat 14:28.

– nichts offen –

## Rückfragen an den Nutzer






- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
