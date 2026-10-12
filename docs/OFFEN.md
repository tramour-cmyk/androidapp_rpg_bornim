# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 43** (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

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
| 27 | Wald „Ort fertig“ (Liste in `STIL.md`): vor allem diagonale Zeichnung, Bäume rund | Tom | – | 11.10., 16:50; nach 24 und 5l; zuerst Standbilder Wald gegen Dorf, Lückenliste; **Meldung Nutzer (16:55):** in der diagonalen Sicht Garrick mit Lagerfeuer schlecht zu sehen, Ausrichtung falsch; Höhleneingang fehlt (eingetragen von Jerry); **Meldung Nutzer (11:30):** in der Diagonalsicht sind Steinkreis (Jorins Auftrag 29.3) und Schild am Waldeingang nicht zu sehen: verdeckt von den Kronen des Waldrands im Süden, Held dort auch unsichtbar (Vorschau bestätigt). Vorschlag: 27 als Nächstes, zuerst Südrand/Steinkreis |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1, 30.2, 30b auf `main` (PR #40, 12.10., 09:29, getestet 0.1.559: kein Absturz, 512 MB). 30.8 Anzeige „App aktualisiert“ (Grund 16) auf `claude/tender-goodall-a8zuny`. Offen: Dorf-Absturz aus 0.1.555 (ohne Fänger) beobachten; **Meldung 09:41:** Absturz beim Test von 0.1.561 (Jerry, 26.1), kein Bericht im Test-Reiter, denn 0.1.561 ist vor PR #40 gebaut (ohne Fänger); Jerry holt `main` in den Zweig und baut neu; 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 34 | Kampf: Knopf „Zug beenden“ (nichts tun, Gegner ist dran; auch um Testkämpfe schnell zu verlieren) | Jerry | `claude/wizardly-edison-tjotls` | 34.1 ja (10:05): neben „Zurück“ im Untermenü Kampf, ohne Rückfrage. Gebaut, PR #41 (Entwurf), 0.1.568 |
| 35 | Weihwasser wirkt nur gegen Untote (SRD), 2W6 gleißend; gegen andere ausgegraut mit Hinweis | Jerry | `claude/wizardly-edison-tjotls` | gebaut (`HolyWaterTest`), 35a: Hausregel ×1,5 bleibt (Nutzer 10:05), also 3–18. PR #41, 0.1.568 |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt, vor allem groß im Emulator | Jerry | – | Meldung Nutzer 12.10., 09:17. Ursache (Berater): Gegner mit 0,66 px/cm, hart ganzzahlig vergrößert (Emulator bis ca. 11×), Krogg mit Fellkörnung 0,55 (Goblin 0,14). Vorschläge 36.1 aufräumen bei gleicher Auflösung, 36.2 weich vergrößern, 36.3 Bosse doppelt (Speicher). **36a ja (09:24):** 36.1, erst Standbilder vorher/nachher in Handy- und Emulatorgröße. **36b ja (09:33):** reicht 36.1 nicht, 36.3 als 1,5× mit zugeschnittenen Bildern, vorher mit `ARTMEM` messen |
| 37 | Kampfmusik aussortieren | Jerry | neu von `main` | Nutzer 12.10., 09:33 (über Berater): raus `kampf_great_labyrinth`, `kampf_menace` (Techno), `kampf_epic_fight` (Lounge); `boss_ancient_legend` sehr schön, aber zu tragend für Kampf → aus `Music.boss`, **37a (09:37):** spielt bei der Rückkehr des Sonnenamuletts in den Tempel (Musik Jerry, Szene im Tempel mit Tom abstimmen); Kapitelende bleibt `ende_new_sunrise`. **37b ja:** Jerry sucht 2–3 neue CC0-Kampfstücke (düster, orchestral, treibend), erst Hörproben. Übrig heute: 3 Kampf-, 3 Bossstücke |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Nutzer 12.10., 09:52: St. 6 nach kurzem Kapitel 1, zu viel Gold? zu starke Ausrüstung? Befund Berater: XP-Schwellen halbiertes SRD, Kapitel-1-Deckel St. 6, Ausrüstungsdeckel je Kapitel vorhanden; Gold wird nirgends gemessen; `ChapterSimTest` mit Ausrüstung, aber nur 2 Tränke, kein Kauf, jeder Kampf mit vollen TP. **38a ja (10:10):** Berater schreibt `BALANCE.md`, Jerry erweitert die Kapitelsimulation um Gold/Einkauf und misst Kapitel 1. **38b:** mindestens 7 Kapitel. **38d ja (10:21):** SRD als Fundament, Stufe 20 Obergrenze, eigenes Tempo, Hausregeln mit Begründung; **38c ja:** Zielkurve in `BALANCE.md`. Plan fertig; **38e/38f ja (11:23):** Jerrys Messung nach 37 und 36.1, vor 13e (in seiner Übergabe) |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan: je Kapitel Grobzusammenfassung, Quests mit Inhalt und Dialogen (Kapitel 1 Ist-Stand aus `Story.kt` und Brett), dann Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Nutzer 12.10., 10:29. **41a ja (10:42):** Entwurf als Dokument zum Lesen/Kommentieren, fertige Kapitel als `docs/STORY.md`. **41b ja:** Plan wird Vorgabe, aber Änderungen gehen nur nach Abstimmung Nutzer und Berater (4 Augen) an Tom/Jerry. **Entwurf steht (10:47):** Kapitel 1 mit Dialogen und 7 Anmerkungen, Kapitel 2 offen ([Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d), Toms Account). **41c, 41d ja (10:54):** Regel „Story und Dialoge“ in `CLAUDE.md` (Tippfehler mit „Text:“ erlaubt), Werkzeug `tools/story.sh` |
| 42 | Textkasten unten im Stil der Blenden: schwarzer Kasten, Sprecher in Gold, Text in gebrochenem Weiß (heute cremefarben mit dunkler Schrift, Sprecher rot) | Tom | – | Nutzer 12.10., 11:24 (über Berater). **42a ja:** erst nur Textkasten (Gespräch, Erzähltext, Aushänge), Menüs später. **42b ja:** ganz schwarz, dünner Goldrand, Sprecher Gold in Kapitälchen im Kasten, Text gebrochenes Weiß, Serife wie Blenden, Erzähltext kursiv, ▼ gold. **42c ja (11:39):** direkt nach 13, erst Standbilder (Handy/Emulator, Dorf/Höhle) |

Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (12.10., 11:35, vor Neustart)

- **29 erledigt:** PR #42 zusammengeführt (11:35), getestet in 0.1.569; CHANGELOG eingetragen. Zweig `claude/great-sagan-n9tkga` ist fertig.
- **Als Nächstes: 27a offen** (Wald vor Tempel, zuerst Südrand mit Steinkreis und Schild, die in der Diagonalsicht unter Kronen liegen; Empfehlung ja, erst Standbilder). Sonst 13 Tempel, dann **42 Textkasten** (42a–42c ja, Standbilder zuerst), dann 5l/5.5, 17.
- **Texte (Regel 41):** Aushänge und Sätze von 29/29.3/29.4 stehen in `Jobs.kt`; der Berater übernimmt sie in `docs/STORY.md`.
### Jerry (12.10., 10:30, vor Neustart)

- **Zweig `claude/wizardly-edison-tjotls`, PR #41 (Entwurf, abonniert):** 34 Zug beenden, 35 Weihwasser nur gegen Untote; Build 0.1.568 unter „Zu testen“. Nach Test: PR zusammenführen, CHANGELOG.
- Erledigt heute: 32 Routinen umgestellt; `notiz.sh` lädt flachen Klon nach.
- **Als Nächstes:** 37 Kampfmusik (2–3 CC0-Hörproben), 36.1 Krogg (Standbilder vorher/nachher), **38 Messung Kapitel 1** (Messplan in `BALANCE.md`; 38e/38f, Nutzer 11:23: nach 37 und 36.1, vor 13e), 13e Entwurf 2 (`claude/quirky-goodall-fqncrd`), 24.6. 30: Abstürze mit Bericht beobachten.

## Zu testen


- **Neubau läuft (Jerry, PR #41, `main` mit PR #42 eingeholt, 12.10., 11:4x):** 0.1.568 war kleiner als das installierte Release. 34 Zug beenden (Kampf → neben Zurück), 35 Weihwasser gegen Nicht-Untote ausgegraut „nur gegen Untote“, gegen Skelett/Zombie 3–18 Schaden.

## Rückfragen an den Nutzer

- **27a (Tom):** 27 Wald vor 13 Tempel, zuerst Südrand (Steinkreis, Schild unter Kronen verdeckt, Jorins Auftrag diagonal sonst nicht lösbar)? Empfehlung ja, erst Standbilder.

- **32 Nacht 11./12.10. fast ohne Arbeit (Tom und Jerry, je ~25 min):** Weck-Sitzungen beenden nach einem Schritt; Routine 00:27 durch 40-Minuten-Regel gesperrt. Vorschläge 32.1–32.7 (Stand `übergeben`, `send_later` an sich selbst bis „Bis“, Nachfolger sofort starten, blockiert → nächster Punkt, Vorschau vor Push bauen, Gradle 6 GB in `setup-session.sh`, Blende-Fix aus PR #38). **32a/32b: Tom macht es (Nutzer 12.10., 07:40).** 32.8 Vertretung bei Nutzungsgrenze; **32b, 32c ja (07:5x)**, 32.1–32.8 in `SELBST.md` übernommen, Toms Routinen umgestellt. Jerrys 8 Routinen auf den Text in `SELBST.md` umgestellt (12.10., 09:59). Befunde im Archiv.


- **6l** (Tom): endgültige Zoomstufe der Karte (vorläufig 6,75 Kacheln). **Zurückgestellt** (Nutzer 11.10., 13:00), bis die Umstellung auf die diagonale Sicht mit allen Facetten fertig ist.
