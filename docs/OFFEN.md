# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 20** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Nachtarbeit](NACHT.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | `tom-diagonal` | Schänke auf `main` (v0.1.471). 11.10., 12:40: Ältester, Laden, Tempel mit Grundriss A im Spiel (Tempel Stein, Seitengänge für Lyra), Kerntest `RoomPlanTest`; Zweig-Build 0.1.482 zum Testen. Danach: Dorf draußen |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | – | nach den Räumen von 13 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; nach 13 |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 18 | Klänge neu: Hörproben (18d) und Monster-Laute (18e) abgelehnt 11.10., 12:10 („klingt wie Pokémon“) | Jerry | – | 18.5 echte Aufnahmen (CC0): `hoerproben_18_echt.zip` (Runde 1, Wolf, Goblin, Skelett) 12:27 beim Nutzer; Werkzeug noch im Notizblock der Sitzung |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 12.3 | Sprünge in den Kampfbewegungen der Tiere | Jerry | `claude/session-start-l65s4j`, PR #18 | 12.3b, 12.3c umgesetzt 12:13; Zweig-Build 0.1.481 beim Nutzer |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 11:40)

- Alles gepusht. `main` = v0.1.471 (13 Schänke diagonal, getestet und freigegeben). Zweig `tom-diagonal`: Entwürfe Ältester, Laden, Tempel nur in der Vorschau (`World.drafts`; `ISODINGE=aeltester|laden|tempel`, `ONLY=zoom_nah_e|l|t`), neue Felder `DESK d`, `TRUNK a`, `ARMCHAIR s`, `HANGING V`, `RACK U`, `CANDLES N`, `FONT &`.
- **Als Nächstes:** Grundriss A von Ältestem, Laden und Tempel ins Spiel (unter dem Schalter „Dorf und Räume“), Tempelwände Stein, Kerntest (Held erreicht Person und Tür), Zweig-Build. Dann 17, dann 14.
- Feste Weck-Routinen für Tom eingerichtet und getestet (`docs/NACHT.md`).

### Jerry (11.10., 11:59)

- Kein offener Zweig. `main` = v0.1.479 (18). Hörproben Runde 1, 2 und Monster-Laute als Entwürfe in `core` (`Sfx.proposed`, `Sfx.monsterProposal`, Vorschau `KLANGPROBEN=1|2|MONSTER`).
- Als Nächstes: 9i nach Toms 13; 10, 11 nach 13e; 12.3 freigegeben (11.10., 12:02): Befund je Tier und Bewegung, dann beheben, `listOthers` danach scharf. Nutzer hört gerade die Hörproben (18d, 18e). Feste Weck-Routinen 00:27, 03:17, 05:57 eingerichtet und getestet (`docs/NACHT.md`).
- APK in den Chat: `gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/androidapp_rpg_bornim/releases/assets/<id>` (id aus `releases/latest`); Artefakte von Zweig-Builds gehen seit 11.10. mit `gh api repos/…/actions/artifacts/<id>/zip`.

## Zu testen

- **0.1.482** (Tom, 13, `tom-diagonal`, [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38132308756/artifacts/11699796980)): Ältester, Laden, Tempel mit Grundriss A; Prüfliste im Chat 11.10., 12:42.
- **0.1.481** (Jerry, 12.3b/c): Sprungangriff Wolf und Riesenratte (weicher beim Abheben und Landen); sonst keine sichtbare Änderung. Link: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38131186527

## Rückfragen an den Nutzer

- **18g** (Jerry): Hörproben `hoerproben_18_echt.zip` (echte Aufnahmen): welche je Klang, Richtung passt?


- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). Empfehlung: festlegen, wenn die Räume fertig sind.
