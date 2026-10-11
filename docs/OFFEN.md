# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 20** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Nachtarbeit](NACHT.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | `tom-diagonal` | Schänke auf `main` (v0.1.471). Laden, Haus des Ältesten, Tempel als Entwurf fertig (nur Vorschau); entschieden 11.10.: Grundriss A für alle drei, Tempelwände aus Stein mit Rundbogenfenstern. Als Nächstes ins Spiel unter „Dorf und Räume“ |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | – | nach den Räumen von 13 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 14 | Neustart-Haken: misst Gesprächsgröße, Hinweis an die Sitzung | Tom | neu von `main` (Werkzeug, PR) | freigegeben 10.10. |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 9i | Übrige Gegner auf der Karte (Entwürfe `MAPFOE=others\|cave\|wood`) | Jerry | – | freigegeben; nach 13 |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 18d, 18e | Hörproben (Runde 1 und 2) und Monster-Laute | Jerry | – | warten auf den Nutzer (anhören) |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 12.3 | Sprünge in den Kampfbewegungen der Tiere (Wolf, Eber, Riesenratte): `JumpTest.listOthers` meldet 265, nur gelistet | Jerry | – | gefunden 11.10. beim Prüfen von 15; Vorschlag an den Nutzer |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (11.10., 11:40)

- Alles gepusht. `main` = v0.1.471 (13 Schänke diagonal, getestet und freigegeben). Zweig `tom-diagonal`: Entwürfe Ältester, Laden, Tempel nur in der Vorschau (`World.drafts`; `ISODINGE=aeltester|laden|tempel`, `ONLY=zoom_nah_e|l|t`), neue Felder `DESK d`, `TRUNK a`, `ARMCHAIR s`, `HANGING V`, `RACK U`, `CANDLES N`, `FONT &`.
- **Als Nächstes:** Grundriss A von Ältestem, Laden und Tempel ins Spiel (unter dem Schalter „Dorf und Räume“), Tempelwände Stein, Kerntest (Held erreicht Person und Tür), Zweig-Build. Dann 17, dann 14.
- Feste Weck-Routinen für Tom eingerichtet und getestet (`docs/NACHT.md`).

### Jerry (11.10., 11:59)

- Kein offener Zweig. `main` = v0.1.479 (18). Hörproben Runde 1, 2 und Monster-Laute als Entwürfe in `core` (`Sfx.proposed`, `Sfx.monsterProposal`, Vorschau `KLANGPROBEN=1|2|MONSTER`).
- Als Nächstes: 9i nach Toms 13; 10, 11 nach 13e; 12.3 nur nach Freigabe. Feste Weck-Routinen 00:27, 03:17, 05:57 eingerichtet und getestet (`docs/NACHT.md`).
- APK in den Chat: `gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/androidapp_rpg_bornim/releases/assets/<id>` (id aus `releases/latest`); Artefakte von Zweig-Builds scheitern (Speicher-Host gesperrt).

## Zu testen

– nichts offen –

## Rückfragen an den Nutzer

- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). Empfehlung: festlegen, wenn die Räume fertig sind.
- **18d** (Jerry): Hörproben auswählen, Runde 1 (Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt) und Runde 2 (17 Klänge, `hoerproben_runde2.zip`). Empfehlung Jerry: erst Runde 1.
- **18e** (Jerry): Monster-Laute Wolf, Goblin, Skelett: Richtung passt? Dann die übrigen Gegner.
- **12.3a** (Jerry): Sprünge in den Kampfbewegungen der Tiere beheben (wie 12a bei den Gegnern auf der Puppe)? Empfehlung: ja, mit Kerntest, der dann scharf prüft.
