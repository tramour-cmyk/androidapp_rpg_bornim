# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 38** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 13 | Diagonale Sicht | Tom | – | Schänke, Ältester, Laden, Tempel auf `main` (PR #20, 11.10., 14:00). Weiter mit Dorf draußen (5). **Meldung Nutzer 12.10., 08:43:** Tempel diagonal: Altar steht direkt vor dem Fenster, wirkt komisch; ansehen (eingetragen von Jerry) |
| 5 | Dorf draußen, Dorfbewohner als Puppen (auch Aldric mit Stock) | Tom | – | 5.1, 5.2, 5g, 5h.1 auf `main` (PR #24, 11.10., 14:52). 5l/5.5 Leben im Dorf: nach 24 (Nutzer 14:55), erst Standbilder. Dann 5.3, 5.4 |
| 17 | Nachschwingen: Umhang, Haare, Köcher, Riemen beim Stoppen und Drehen | Tom | neu von `main` | freigegeben 10.10.; nach 13 |
| 15 | `OFFEN.md` entschlacken, Archiv, Themenliste | Tom | `main` (Notizen) | erledigt 11.10.; Jerrys Teil geprüft 11.10. |
| 10, 11 | Höhle: Flammen feiner, Lichtstrahl am Schacht | Jerry | – | zurückgestellt bis zur diagonalen Höhle (13e) |
| 13e | Höhle diagonal (Phase 2 von 13: Orte aufteilen) | Jerry | `ccr-8b450567-umf1s6` | **Entwurf 1 (23:43, Vorschau `KARTENZOOM=1 DIAG=1 CAVEDRAFT=1 ONLY=zoom_nah_c`):** Wände stehen (hinten 2,4 m, Trennwände 1 m, vorn Rand), Gitter und Stützen schräg. **Lücken:** Fels noch kantig/zu dunkel (runder, `Sculpt`); Kisten, Truhen, Felsen, Stalagmiten, Knochen, Lager noch alte Bilder; Lichtschacht als helles Rechteck; Weiher ohne Ufer; Krogg (Jerry) und Lyra (Tom) noch alte Bilder. 13e.1 ja (13:52): nach 18 Runde 2, erst Entwürfe. **Tom einverstanden (14:16).** Jerry: neue Datei `MapCaveIso.kt` und eine Zeile in `WorldArt.buildObjects` (wie Räume/Dorf). Nicht anfassen ohne Absprache: `WorldScreen.kt` (Sortierung, `hides`, `put`/`corner`, `Cam`), `MapSight`, `FreeWalk`, `MapRoomIso`, `MapTownIso`, `MapGround`. Vorlage: `MapTownIso` (`Tile1`, `plane`/`box`/`cylinder`, Tiefe `(tx+ty)*T+1.5T−1`, `corner = true`, `group` für Mehrfeld-Dinge) |
| 18 | Klänge aus echten Aufnahmen (CC0) | Jerry | – | 18h/18i (PR #25) und 18k (PR #27, getestet 0.1.511, 16:08) auf `main` |
| 22 | Selbstarbeit statt nur Nachtarbeit: Routinen alle 3 h, Vorrat und Liste „Für gemeinsame Zeit“ | Tom | `main` (Notizen), Routinen | 22a, 22b ja (13:31). `docs/SELBST.md` statt `NACHT.md`; Toms Routinen umgestellt (13:38); Repo und Vollzugriff vom Nutzer eingestellt (bestätigt 16:38, 8 Routinen aktiv). Jerrys Routinen umgestellt (13:44), Vorrat eingetragen |
| 23 | Aufgaben so aufteilen, dass Tom und Jerry auch in Selbstarbeit genug Vorrat haben | Tom | `main` (Notizen) | 23a ja (14:18): je 8 Punkte im Vorrat (`docs/SELBST.md`), neue nur als Entwürfe/Hörproben. **Jerry:** deine Punkte 4–8 sind eingetragen |
| 19e | „Bewegungen teilweise unrund“ (ohne Beispiel) | Jerry | – | zur Beobachtung |
| 24 | Animationen fehlen nach Spielstart und Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | Tom (Technik); Jerry (Inhalt) | – | 24.1–24.4, 24.9–24.15 auf `main` (PR #30, #32, #34, #35); 24.8 Ortsklang auf `main` (PR #37). **Tom:** 24.5, 24.16–24.20 auf `main` (PR #40). 24.8.6 (Türen 0,5 s) auf `claude/tender-goodall-a8zuny`. **Jerry:** 24.8.5 auf `main` (PR #38, 12.10.), danach 24.6 Kampferöffnung wartet + Herzschlag (nach Toms 24.5), knapper Kampftext in `Battle.kt`. Entscheidungen 24f/24i/24j in [`ZWISCHENBILD.md`](ZWISCHENBILD.md) und im Archiv. |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`KAPITEL1.md`](KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | festgelegt 11.10., 16:50 (Berater); erledigte Punkte dort abhaken |
| 27 | Wald „Ort fertig“ (Liste in `STIL.md`): vor allem diagonale Zeichnung, Bäume rund | Tom | – | 11.10., 16:50; nach 24 und 5l; zuerst Standbilder Wald gegen Dorf, Lückenliste; **Meldung Nutzer (16:55):** in der diagonalen Sicht Garrick mit Lagerfeuer schlecht zu sehen, Ausrichtung falsch; Höhleneingang fehlt (eingetragen von Jerry) |
| 29 | Nebenquests über ein Anschlagbrett (mind. drei Aufträge, Wald und Höhle) | Tom | `claude/tender-goodall-a8zuny` (lokal, Push nach Test 0.1.559) | 29a–29d ja. **Gebaut 09:02** (Kerntest `JobsTest`, Vorschau `BRETT=1`): Brett Variante 2 vor der Schänke (4,7), Fenster mit Annehmen je Aushang, Menü System: Fortschritt + Aufgeben (29e ja), Abgabe beim Auftraggeber. Thessa 5 Felle 60 G, Gwenna Ring 40 G + Trank, Borin 3 Hauer 50 G (Aufwertung gibt es nicht); Texte ok (29f ja). **Rückfrage 29g:** neue Aushänge nach erledigten? **Jerry:** Gwennas Ring kommt aus Truhe `cave_3`, sobald der Auftrag angenommen ist (nur in `Game.openChest`, Höhlendaten unverändert); bitte Bescheid, falls `cave_3` sich ändert |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1, 30.2, 30b auf `main` (PR #40, 12.10., 09:29, getestet 0.1.559: kein Absturz, 512 MB). 30.8 Anzeige „App aktualisiert“ (Grund 16) auf `claude/tender-goodall-a8zuny`. Offen: Dorf-Absturz aus 0.1.555 (ohne Fänger) beobachten; 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 34 | Kampf: Knopf „Zug beenden“ (nichts tun, Gegner ist dran; auch um Testkämpfe schnell zu verlieren) | Jerry | neu von `main` | ja (Nutzer 12.10., 09:19, über Berater). Abgesetzt anordnen oder kurz bestätigen (33). „Abwarten“ und „Helfen“ auf der Merkliste (Gruppenkämpfe) |
| 35 | Weihwasser wirkt nur gegen Untote (SRD), 2W6 gleißend; gegen andere ausgegraut mit Hinweis „Wirkt nur gegen Untote“, Beschreibung anpassen | Jerry | neu von `main` | ja (Nutzer 12.10., 09:19, über Berater; heute 2W6 gegen alle, 4W6 gegen Untote, `Battle.kt` Z. 485, `Items.kt`) |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt, vor allem groß im Emulator | Jerry | – | Meldung Nutzer 12.10., 09:17. Ursache (Berater): Gegner mit 0,66 px/cm, hart ganzzahlig vergrößert (Emulator bis ca. 11×), Krogg mit Fellkörnung 0,55 (Goblin 0,14). Vorschläge 36.1 aufräumen bei gleicher Auflösung, 36.2 weich vergrößern, 36.3 Bosse doppelt (Speicher). **36a ja (09:24):** 36.1, erst Standbilder vorher/nachher in Handy- und Emulatorgröße. **36b ja (09:33):** reicht 36.1 nicht, 36.3 als 1,5× mit zugeschnittenen Bildern, vorher mit `ARTMEM` messen |
| 37 | Kampfmusik aussortieren | Jerry | neu von `main` | Nutzer 12.10., 09:33 (über Berater): raus `kampf_great_labyrinth`, `kampf_menace` (Techno), `kampf_epic_fight` (Lounge); `boss_ancient_legend` sehr schön, aber zu tragend für Kampf → aus `Music.boss`, anders verwenden (37a). Übrig: 3 Kampf-, 3 Bossstücke; Ersatz 37b |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (12.10., 07:48, vor Neustart)

- **Zweig `claude/sharp-davinci-s83a1t`:** 30.1 + 30.2 + 24.5 (enthält `great-shannon`), Build 0.1.552 zu testen (Nutzer testet später). Vorschau-Ersatz `CrashLogStub` (785e0c4) liegt auf dem Zweig.
- **Testreihenfolge (Nutzer 12.10., 07:5x):** erst Jerrys 0.1.555, dann Toms neuer Build mit 30b (nicht 0.1.552 extra).
- **Als Nächstes:** 30b `largeHeap` im Manifest (ja 07:5x) einbauen, Kerntests, Vorschau bauen (32.5), Build, Link. Dann 29a (Anschlagbrett, Rückfrage offen), 27 Wald (braucht 32.7 aus Jerrys PR #38 zuerst auf `main`).
- **32:** 32.1–32.8 in `SELBST.md`, Toms 8 Routinen auf neuen Text (07:47). Ungeprüft: ob Weck-Sitzungen `send_later`/`create_session` haben (beim nächsten Lauf im Bericht prüfen). Jerry stellt seine Routinen selbst um.
### Jerry (12.10., 07:43, vor Neustart)

- **PR #38** (Zweig `ccr-8b450567-umf1s6`, Entwurf), Build 0.1.555 ([Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38178006618/artifacts/11716242658)): 24.8.5 Ortsklang klingt aus, 30.6 Klang-Laden abgesichert, 13e Entwurf 1 (im Spiel aus), Vorschau zeigt in `KARTENZOOM` die Karte statt der Blende (32.7, braucht Tom für 27). **Getestet, passt (12.10.); zusammengeführt.** 13e Entwurf 2 (Fels heller) liegt auf `claude/quirky-goodall-fqncrd`, vor dem Weiterarbeiten in den eigenen Zweig holen.
- **26.1** in PR #39 (Zweig `ccr-21220742-4xthje`), Build 0.1.561 zu testen; Simulation Magier Grottenschrat St. 3 44 → 63 %, Hobgoblin St. 4 35 → 50 %, St. 5 45 → 69 %. Rückfrage 26b (8 h = 8 min echte Zeit). **Als Nächstes:** Routinen (32), dann 13e Entwurf 2 (Kisten/Truhen/Felsen/Stalagmiten diagonal), dann 24.6 nach Toms 24.5.
- **30:** Klang 24 MB nativ, kein Absturzgrund; 30.6 in PR #38; **30.7** (22 kHz, −5 MB) mit Tom regeln (Nutzer 12.10.).

## Zu testen

- **0.1.561 (Jerry, PR #39, 26.1):** Magier wirkt Magierrüstung; nächster Kampf meldet „hält noch“, nicht erneut wirkbar; Karte oben „Schutz“, nach ca. 8 min weg. [Artefakt](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38214542422/artifacts/11731896008)

## Rückfragen an den Nutzer

- **37a (Berater, 12.10.):** `boss_ancient_legend` wofür? Vorschlag: Kapitelende nach Grak (heute `ende_new_sunrise`) oder Rückkehr des Sonnenamuletts in den Tempel. **37b:** nur 3 Kampfstücke wiederholen sich schnell: Jerry sucht 2–3 neue CC0-Stücke (düster, orchestral, treibend), erst Hörproben? Empfehlung: ja.

- **26b (Jerry, 12.10.):** 8 h Spielzeit sind 8 min echte Zeit (1 s = 1 Spielminute); die Rüstung hält also meist 2–4 Kämpfe. Reicht das, oder länger (z. B. bis zur nächsten Rast)? Empfehlung: erst testen.

- **32 Nacht 11./12.10. fast ohne Arbeit (Tom und Jerry, je ~25 min):** Weck-Sitzungen beenden nach einem Schritt; Routine 00:27 durch 40-Minuten-Regel gesperrt. Vorschläge 32.1–32.7 (Stand `übergeben`, `send_later` an sich selbst bis „Bis“, Nachfolger sofort starten, blockiert → nächster Punkt, Vorschau vor Push bauen, Gradle 6 GB in `setup-session.sh`, Blende-Fix aus PR #38). **32a/32b: Tom macht es (Nutzer 12.10., 07:40).** 32.8 Vertretung bei Nutzungsgrenze; **32b, 32c ja (07:5x)**, 32.1–32.8 in `SELBST.md` übernommen, Toms Routinen umgestellt. **Jerry:** deine 8 Routinen auf den Text in `SELBST.md` umstellen. Befunde im Archiv.

- **26a (Jerry, Selbstarbeit 23:51), Ausgleich Magier:** Simulation (Sieg %, Magier/Kämpfer/Schurke/Kleriker): Krogg St. 3 heute 44/80/80/51, Grak St. 4 35/61/46/50, St. 5 45/92/82/88. Ursache: Magierrüstung kostet im Kampf die erste Runde. Vorschlag **26.1**: Magierrüstung hält wie im SRD 8 Stunden, einmal gewirkt gilt sie ab Kampfbeginn (ohne Rüstung). Probe: Krogg St. 3 → 63 %, Grak St. 4 → 50 %, St. 5 → 69 %. Empfehlung: ja. **26a ja (Nutzer 12.10., 07:40): Jerry baut 26.1 in der nächsten Sitzung.**


- **APK im Chat (Tom, 11.10.):** Artefakte von Zweig-Builds liegen auf `productionresultssa*.blob.core.windows.net`, die Netzregel sperrt sie (alle 12 Builds vom 11.10. geprüft); Release-APKs gehen. Vorschlag: `*.blob.core.windows.net` unter „Allowed domains“. **Zurückgestellt (11.10., vor 21:12):** Nutzer stellt es am Rechner ein. Bis dahin Link zum Artefakt.

- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
