# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 26** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | Schänke, Ältester, Laden, Tempel auf `main` (PR #20, 11.10., 14:00). Weiter mit Dorf draußen (5) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | – | 5.1, 5.2, 5g, 5h.1 auf `main` (PR #24, 11.10., 14:52). 5l/5.5 Leben im Dorf: nach 24 (Nutzer 14:55), erst Standbilder. Dann 5.3, 5.4 |
| 25 | Laternen und Fenster nachts als Quelle zu dunkel | Tom | `claude/fervent-einstein-bewehx` | 25.1 Laternen und 25b Fenster umgesetzt (15:31, `LampGlowTest`, Vorschau `ONLY=zoom_nah_d7`/`d8`), Standbilder an den Nutzer, Zweig-Build läuft |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; frei, seit 13 auf `main` ist |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 13e | Höhle diagonal (Phase 2 von 13: Orte aufteilen) | Jerry | – | 13e.1 ja (13:52): nach 18 Runde 2, erst Entwürfe. **Tom einverstanden (14:16).** Jerry: neue Datei `MapCaveIso.kt` und eine Zeile in `WorldArt.buildObjects` (wie Räume/Dorf). Nicht anfassen ohne Absprache: `WorldScreen.kt` (Sortierung, `hides`, `put`/`corner`, `Cam`), `MapSight`, `FreeWalk`, `MapRoomIso`, `MapTownIso`, `MapGround`. Vorlage: `MapTownIso` (`Tile1`, `plane`/`box`/`cylinder`, Tiefe `(tx+ty)*T+1.5T−1`, `corner = true`, `group` für Mehrfeld-Dinge) |
| 18 | Klänge aus echten Aufnahmen (CC0) | Jerry | – | 18h/18i (PR #25) und 18k (PR #27, getestet 0.1.511, 16:08) auf `main` |
| 22 | Selbstarbeit statt nur Nachtarbeit: Routinen alle 3 h, Vorrat und Liste „Für gemeinsame Zeit“ | Tom | `main` (Notizen), Routinen | 22a, 22b ja (13:31). `docs/SELBST.md` statt `NACHT.md`; Toms Routinen umgestellt (13:38); Nutzer: neue Routinen einstellen (Repo, automatisch). Jerrys Routinen umgestellt (13:44), Vorrat eingetragen |
| 23 | Aufgaben so aufteilen, dass Tom und Jerry auch in Selbstarbeit genug Vorrat haben | Tom | `main` (Notizen) | 23a ja (14:18): je 8 Punkte im Vorrat (`docs/SELBST.md`), neue nur als Entwürfe/Hörproben. **Jerry:** deine Punkte 4–8 sind eingetragen |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 24 | Animationen fehlen nach Spielstart und Kartenwechsel; Übergangsbild, bis alles gezeichnet ist; auch vor Kämpfen | Tom (24.1–24.3, 24.5); Jerry (24.6) | – | 24a–c ja (14:39), 24e ja (15:16). **Plan:** Tom beginnt nach 25b in neuer Sitzung (ca. 16:00): erst messen, dann 24.2/24.3 (mehrere Fäden, Bilder behalten), 24.1 Übergangsbild, 24.5 Kampfbilder auf der Karte vorladen. **Jerry:** 24.6 (Kampferöffnung wartet auf Stehen und ersten Schlag, höchstens ca. 2 s) nach 18h/18i, auf Toms Zeichen-Faden aus 24.2 aufbauen. **Entwurf Zwischenbildschirm** (Tom und Jerry haben ihn beide erhalten) (Berater-Tom, 16:15): [`ZWISCHENBILD.md`](ZWISCHENBILD.md); Orte = Tom (24.1), Kampf + Kampftext (24.7) und Klang in der Blende (24.8) = Jerry, Rückfragen 24f–24h |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 15:40)

- **25 Laternen und Fenster:** Zweig `claude/fervent-einstein-bewehx` (mit `main`, alles gepusht), Zweig-Build **0.1.512** zu testen, noch kein PR. Nach Test: PR anlegen, grün → selbst zusammenführen, „Unveröffentlicht“ ergänzen. Code: `WorldArt.Glow` (Bild, was nachts selbst leuchtet), `MapTownIso.lampGlow`/`litWindows` (Nacht- minus Tagbild je Hausstreifen), in `WorldScreen` nach dem Licht gezeichnet (`glowing`, Stärke `MapLight.strength(NIGHT)`). Kerntest `LampGlowTest`, Vorschau `KARTENZOOM=1 DIAG=1 TOWNDRAFT=1 ONLY=zoom_nah_d7` (Nacht) / `d8` (Dämmerung).
- **24 als Nächstes (neue Sitzung):** Plan in „Wer macht was“: erst messen (Zeit bis alles gezeichnet: `MapFigure.prepare`, `MapRest`, `MapFolk.prepareFor`, `MapGround.prepare`, Kampf `HeroBattle.prepare`/`MonsterArt.prepare` in `BattleScreen` ~1204/~901), dann 24.2/24.3, 24.1 Übergangsbild, 24.5 Kampfbilder auf der Karte vorladen; 24.6 macht Jerry. Vorher `STIL.md`-Abgleich (Blende im Stil, Übergang weich), Kerntest „Übergangsbild endet, wenn fertig oder nach ca. 4 s“.
- **5l / 5.5 Leben im Dorf** nach 24 (Nutzer 14:55): Tiere (Hühner, Katzen, Hunde), Leute bei der Arbeit, Platz dichter; erst Standbilder. Dann 5.3, 5.4.
- Routinen: die fünf neuen (09:24–21:24) braucht der Nutzer noch mit Repo und „automatisch“.

### Jerry (11.10., 15:20)

- Zweig `claude/loving-lovelace-k8iwgd`, Entwurfs-PR #27: **18k** Feuerknistern als nahtlose 10-s-Schleife (`tools/klang/schleifen.py`, Quellen 181563/370938 in `QUELLEN.md`), eine Fassung bis zum Ausklingen. Kerntests grün. Zweig-Build 0.1.511 ausgeliefert (15:24), Test beim Nutzer; nach „passt“ PR #27 zusammenführen (vorher aus Entwurf holen).
- 18 Runde 2 (PR #23) und 18h/18i (PR #25) auf `main`, unter „Unveröffentlicht“.
- Als Nächstes: Vorrat in `SELBST.md` (2 Stimmen übrige Gegner als Hörproben, 3 9i, 4 13e …); **24.6** (Kampferöffnung wartet auf Kampfbilder, 24e ja) nach Toms 24.1–24.3, vorher messen.

## Zu testen

- **0.1.512** (Tom, 25, `claude/fervent-einstein-bewehx`, [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38143518053/artifacts/11703464207)): Laternenglas und Hausfenster leuchten nachts, glimmen in der Dämmerung auf.

– nichts offen –

## Rückfragen an den Nutzer

- **24f–24h** (Jerry, 16:17): 24f Kampf-Zwischenbild voll nur beim ersten Kampf je Gegnerart und bei Bossen, sonst ca. 1 s (Empfehlung)? 24g Jerry schreibt Sätze für die 7 Gegner ohne Text (Wildschwein, Stirge, Riesen-Hundertfüßer, Kobold, Riesenfledermaus, Ghul, Ockergallerte)? 24h Wind/Stimmengewirr erst nach dem Bau als CC0 suchen?


- **24 Animationen fehlen am Anfang (gemeldet 11.10., 14:36; Befund Tom-Beratung 14:45):** Stimmt. Der Held auf der Karte hat 16 Richtungen × 8 Schrittbilder = 128 Bilder; `MapFigure.prepare` zeichnet sie in einem einzigen Hintergrund-Faden mit niedriger Priorität. Bis ein Bild fertig ist, zeigt `frameNow` das Standbild dieser Richtung, deshalb gleitet der Held ohne Beinbewegung. Atmen und Gewicht verlagern (`MapRest`) werden erst beim ersten Bedarf in einem weiteren Faden gezeichnet; Leute (`MapFolk.prepareFor`) und Boden (`MapGround.prepare`) beim Kartenwechsel ebenso. Ein Wechsel der Ausrüstung verwirft alle Heldenbilder (`cache.keys.removeAll`), danach fehlt das Laufen wieder. Vorschläge: 24.1 Übergangsbild beim Spielstart und Kartenwechsel (dunkle Blende im Stil, Ortsname, kurzer Satz), bleibt, bis das Nötige fertig ist (Laufen des Helden in allen Richtungen, Atmen, Leute der Karte, Boden um den Helden), höchstens etwa 4 s, danach weiter im Hintergrund; 24.2 schneller zeichnen: mehrere Fäden (Zahl der Kerne), höhere Priorität, solange das Übergangsbild steht; 24.3 bei Ausrüstungswechsel alte Bilder behalten, bis die neuen fertig sind; 24.4 gezeichnete Bilder auf dem Gerät speichern, damit der nächste Start sofort geht. **Entschieden 14:39:** 24a ja, 24b ja (24.2 und 24.3 gleich mit), 24c ja (24.4 erst nach Messung, steht auf der Merkliste). **An die Tom-Arbeitssitzung:** 24.1–24.3 bauen; vorher Abgleich mit `STIL.md` (Blende im Stil, Übergang Blende → Karte weich), Kerntest für „Übergangsbild endet, sobald das Nötige fertig ist oder spätestens nach etwa 4 s“, Zeiten vorher/nachher im Bericht (wie lange bis alles gezeichnet ist). Für die Kampfbilder dieselbe Lösung mit Jerry abstimmen. **24d (Nutzer 14:55):** auch vor Kämpfen sinnvoll? (kleiner Kampfbildschirm, Bewegungen im Hintergrund vorladen). Antwort Tom 14:56: ja; Vorschläge 24.5 (Kampfbilder schon vorladen, sobald ein Gegner den Helden bemerkt oder nahe ist, Karte = Tom) und 24.6 (Kampferöffnung wartet, bis Stehen und erster Schlag fertig sind, höchstens etwa 2 s, Kampf = Jerry), vorher messen; Rückfrage 24e. **24e ja, beides (Nutzer 15:06):** 24.5 Tom, 24.6 Jerry (nach 24.1–24.3, vorher messen).





- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
