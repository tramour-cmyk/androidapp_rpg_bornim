# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 23** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | Schänke, Ältester, Laden, Tempel auf `main` (PR #20, 11.10., 14:00). Weiter mit Dorf draußen (5) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | `tom-dorf` (von `tom-diagonal`, mit `main`) | 5.1 Häuser im Spiel (13:40): nach Grundriss und Hausstil, Streifen-Sortierung; 5h.1 Fenster außen wie innen (`HouseWindowsTest`); 5g Glockenturm. Zweig-Build läuft. Danach 5.2 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; nach 13 |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 13e | Höhle diagonal (Phase 2 von 13: Orte aufteilen) | Jerry | – | 13e.1 ja (13:52): nach 18 Runde 2, erst Entwürfe (Standbilder), wenn Tom einverstanden. **Anfrage an Tom:** einverstanden? Welche Dateien (Gerüst, `WorldScreen`, Kacheln) fasst Jerry nicht an? |
| 18 | Klänge aus echten Aufnahmen (CC0) | Jerry | `claude/eloquent-dirac-eg6m37`, PR #23 (Entwurf) | 18f (14:05): alle neuen passen, außer: Kampfbeginn nur neu 3; Held fällt ist kein Systemklang (alle drei); Magie 1 (Harfe/Nintendo) und Stärkung 2 neu machen. In Arbeit: Ersatz als Hörprobe, Einbau, Zweig-Build |
| 22 | Selbstarbeit statt nur Nachtarbeit: Routinen alle 3 h, Vorrat und Liste „Für gemeinsame Zeit“ | Tom | `main` (Notizen), Routinen | 22a, 22b ja (13:31). `docs/SELBST.md` statt `NACHT.md`; Toms Routinen umgestellt (13:38); Nutzer: neue Routinen einstellen (Repo, automatisch). Jerrys Routinen umgestellt (13:44), Vorrat eingetragen |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 11:40)

- Alles gepusht. `main` = v0.1.471 (13 Schänke diagonal, getestet und freigegeben). Zweig `tom-diagonal`: Entwürfe Ältester, Laden, Tempel nur in der Vorschau (`World.drafts`; `ISODINGE=aeltester|laden|tempel`, `ONLY=zoom_nah_e|l|t`), neue Felder `DESK d`, `TRUNK a`, `ARMCHAIR s`, `HANGING V`, `RACK U`, `CANDLES N`, `FONT &`.
- **Als Nächstes:** Grundriss A von Ältestem, Laden und Tempel ins Spiel (unter dem Schalter „Dorf und Räume“), Tempelwände Stein, Kerntest (Held erreicht Person und Tür), Zweig-Build. Dann 17, dann 14.
- Feste Weck-Routinen für Tom eingerichtet und getestet (`docs/SELBST.md`).

### Jerry (11.10., 13:28)

- `main`: v0.1.494 veröffentlicht (18.7 Klänge); danach PR #22 (21) zusammengeführt. Kein offener Zweig.
- **Hinweis an Tom (21):** Seit PR #22 erzeugt Zusammenführen auf `main` kein Release mehr; Release nur auf Zuruf des Nutzers, und vor jedem Zweig-Build `main` in den Zweig holen. Regeln in `CLAUDE.md` („Release nur auf Zuruf“).
- Als Nächstes: 18 Runde 2 (17 Klänge) und Stimmen der übrigen Gegner, erst Hörproben (`tools/klang`, Aufnahmen mit `tools/klang/holen.sh`); 9i nach Toms 13; 10, 11 nach 13e.
- APK in den Chat: Release `gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/androidapp_rpg_bornim/releases/assets/<id>`; Zweig-Artefakt `gh api repos/…/actions/artifacts/<id>/zip`.

## Zu testen

– nichts offen –

## Rückfragen an den Nutzer





- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
