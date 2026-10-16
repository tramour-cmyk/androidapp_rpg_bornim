# Betrieb: Handwerk von Ford und Ford 2

Mechanik zu `ROLLE-BETRIEB.md`: Stellung, Uhr, Neustart, Ablauf eines Laufs, Ford 2, Meldungen. Liest Ford beim Start ganz; andere nur bei Anlass. Vorgänge 81a–81v, 99f, 110, 124, 126, 128 (`VORGANGSARCHIV.md`).

## Stellung (81g)

Steht oben in `ARBEIT-BETRIEB.md` („Ford: aus / Co-Pilot / Pilot“). Der Chef sagt sie einem beliebigen Agenten („Ford, Pilot“) oder Ford selbst; der Agent trägt sie ein, pusht und schickt bei steigender Stellung „Ford-Lauf“ an Fords Sitzung.

| Stellung | Ford tut (stündlich geweckt) |
|---|---|
| aus | nur Stellung lesen |
| Co-Pilot | Neustarts und „Auftrag Diogenes“ auf Meldung; sonst nur Push: etwas wartet, Build fertig, Sitzung hängt |
| Pilot | startet Sitzungen, wo Vorrat ist, auch nachts; nachts nur lautlos |

## Uhr, Selbstneustart, Tiefe, Wache (81p, 81s, 110, D10.1, D16)

- Kennungen von Fords Sitzung, Uhr und Wache stehen oben in `ARBEIT-BETRIEB.md` (Zeile „Ford lebt in einer Sitzung“; Weiter-Haken und Wache lesen sie dort). Umgebung „Voll“: `create_session`, `list_sessions`, Telegram-Schlüssel. Keine `send_later`-Kette.
- **Selbstneustart** (81r): zeigt `get_session` (eigene Sitzung) über 300.000 `used_tokens`, legt Ford „Ford – Betriebsleiter (TT.MM., HH:MM)“ mit `create_session` neu an (erste Nachricht: sein Auftrag mit Verweis auf diese Datei). Die neue Sitzung legt zuerst ihre Uhr an (`create_trigger`, `persistent_session_id` = eigene Kennung, Minute :03, Nachricht „Ford-Lauf“), prüft sie mit `list_triggers`, löscht dann die alte Uhr, archiviert den alten Ford, trägt beides in `ARBEIT-BETRIEB.md` ein, pusht; keine Meldung. Der alte Ford archiviert sich nie selbst (sonst schaltet sich seine Uhr ab).
- **Tiefe** (110): jede Sitzung trägt `lineage.depth` (Grenze 8); wer gestartet wird, liegt eins tiefer. Auf Tiefe 8 gehen weder `create_session` noch Uhr, Weckruf oder `send_later`. Ford bleibt darum höchstens auf 6, seine Teams auf 7: Selbstneustart nur bis Tiefe 5. Ab Tiefe 6 einmal `--laut` „Chef: Ford bitte von Hand starten (Tiefe n)“ und Datei `docs/chefsache/entscheiden/110-ford-von-hand.md` anlegen; weiterlaufen bis dahin. Der Chef startet in claude.ai/code eine Sitzung (Umgebung „Voll“, Repo) mit „Ford“ (Tiefe 0). Ford 2 ebenso auf Pro und trägt seine Tiefe in seine Kennungszeile (D16.2).
- **Wache:** die Sitzung „Ford-Wache“ wird Mo–Fr 07:08, Sa, So und im Urlaub 09:08 geweckt, prüft `updated_at` und Uhr von Ford und meldet bei Stillstand `--laut` plus „Ford-Lauf“. Niemand archiviert sie (D13.2). Ausfall: Team Tom und Perikles wecken Ford (Start in ihren Rollendateien).
- **Keine Routinen:** Routinen-Sitzungen haben kein `create_session`/`list_sessions` (Proben 15.10.).

## Neustart auf Meldung (81r)

„Neustart <Name>, <Commit>“ (per `send_message`, sofort): `git fetch`; liegt der Commit auf `origin/main` und nennt die Übergabe im Vorrat der Rolle „Nachfolger: <Titel>“? Nein → Antwort „Übergabe fehlt“. Ja → Startmarke wie Schritt 4, `create_session` nach `LISTE-RELEASE-NEUSTART.md` „Neustart“ 2 (Titel aus der Übergabe, erste Nachricht das Startwort: „Tom“, „Perikles“, „Homer“), Antwort an den Absender, lautlose Meldung mit Link. **Kosten erfassen** (124): `usage.cost_usd` des Absenders (vor dem Archivieren lesen, `archive_session` liefert es auch) in die Spalte „Kosten“ seines Vorgangs in `LISTE-VORGAENGE.md` addieren; mehrere Vorgänge zu gleichen Teilen; fehlt die Zahl: „fehlt“. Dann den Absender archivieren (81v; vorher prüfen, ob dort eine Frage des Chefs offen steht). Erledigte Sitzungen ohne Nachfolger archiviert der nächste Lauf ebenso mit Kosten.

„Auftrag Diogenes <Nr>“: sofort Schritt 4 nur für Diogenes; Antwort an den Absender. Beides ab Co-Pilot, auch nachts.

## Ablauf eines Laufs

1. `tools/notiz.sh`, Stellung lesen; „aus“ → beenden.
2. **Pause:** trägt der Kopf eines Vorrats „Pause bis <Zeit>“, lässt Ford die Rolle bis dahin aus.
3. **Laufende Sitzungen:** `list_sessions` (`mine`); laufend = passender Titel und `working`/`blocked`, `updated_at` jünger als 60 Minuten oder offener Wecker (`list_triggers`). Daraus `ARBEIT-BESETZUNG.md` (Rolle, Titel mit Link, Zeile, Zweig, seit).
4. **Starten:** je Rolle offene Zeile ohne Entscheidung des Chefs, keine laufende Sitzung, keine Startmarke jünger als 20 Minuten? **Erst Muss, dann Kür** (126): eine Muss-Zeile im Wochenziel oder mit „jetzt“ des Chefs geht vor; Kür nur, wenn nirgends Muss startbar ist; „M?“ zählt als Kür. Diogenes: Zeile in `ARBEIT-PRUEFUNG.md`, Bedingung „nach …“ jeden Lauf gegen `main` bzw. den PR prüfen. Pilot: **Startsperre** „HH:MM Start <Name>“ ins Protokoll, pushen (abgelehnt → `git pull`, neu prüfen), erst dann `create_session`. Co-Pilot: Push „<Name> hat Vorrat, keine Sitzung“.
5. **Stillstand** (Kennzahl, 128): liegt startbares Muss ohne Sitzung, Zeile ins Protokoll „Stillstand <Rolle> seit HH:MM, Ursache Guthaben / eingeteilt / Fehler“; endet er, „Stillstand <Rolle> Ende“.
6. **Leer gemeldet** (81n): meldet ein Team keinen Vorrat, in dessen Vorrat und `LISTE-ABNAHME-KAPITEL1.md` nach Zeilen ohne „passt“/„erledigt“ und ohne Entscheidung des Chefs suchen; Pilot startet mit „Prüfe <Nummern>, bevor du leer meldest“, Co-Pilot pusht es.
7. **Eingang** zuteilen; was keinem gehört, im selben Lauf dem Chef vorlegen (einmal mit Ton, Nummer, Vorschlag; Zeile bleibt mit „wartet auf Chef“).
8. **Nachhalten** (107, im ersten Lauf ab 8 Uhr): alle Zeilen „von …“ (Befunde von Diogenes, Anstöße, Lehren für alle, Eingang) auf Zuteilung und Alter prüfen. Ohne Bewegung seit zwei Tagen → lautlos an den Bereich („<Nr> liegt seit …“) und Zeile ins Protokoll; Fragen an den Chef ohne Datei in der Chefsache → Zeile an den, der sie hat.
9. **Melden:** neu „Jetzt installieren“ oder eine Übergabe „wartet auf Chef“ → `--laut` mit Nummer (nachts lautlos). Neue Grundsatzzeile nur lautlos. **Sitzung hängt** (zwei Läufe `working`/`blocked` ohne neues `updated_at` und ohne Commit) → `--laut` mit Name und Link. Alle Vorräte leer → einmal am Tag „Vorrat leer“ (spätestens 21 Uhr).
10. **Morgenmeldung** `--laut` Mo–Fr 7 Uhr, Sa, So und im Urlaub (Zeile „Urlaub bis …“ oben in `ARBEIT-BETRIEB.md`) 9 Uhr: wer woran, was über Nacht fertig wurde, was auf den Chef wartet; letzte Zeile „Bitte Bild der Nutzung beider Accounts (Woche %)“ (128). Kommt das Bild: Zeile „Guthaben: Max n %, Pro m %, Datum“ in `ARBEIT-BETRIEB.md`; bis 12 Uhr keins → einmal lautlos erinnern.
11. **Wochenstart** (Mo, erster Lauf ab 8 Uhr; 126, D19.3): Diogenes „Wochenzählung“ starten (Zeile in `ARBEIT-PRUEFUNG.md`), danach Perikles „Perikles – Wochenziel TT.MM.“ (erste Nachricht „Perikles Wochenziel“). **Tagesrückblick** (90, Probe bis 22.10.): erster Lauf ab 8 Uhr startet Perikles „Perikles – Tagesrückblick TT.MM.“ (erste Nachricht „Perikles Tagesrückblick“; läuft Perikles schon, `send_message` „Tagesrückblick“); am 23.10. „Perikles – Bilanz Tagesrückblick“, danach nur, wenn Zeile 90 in `ARBEIT-PROJEKT.md` „weiter“ sagt.
12. Etwas getan → Zeile ins Protokoll, pushen; sonst nichts schreiben.

## Ford 2 (Niederlassung, 99f, 128)

Startet nur Team Jerry auf Pro, wenn dessen Vorrat offen ist, keine Jerry-Sitzung läuft (auch keine der Zentrale laut Besetzung) und der Wochenverbrauch von Pro (Guthabenzeile) höchstens dem Anteil der verstrichenen Woche plus 10 % entspricht (Woche ab Fr. 03:00); sonst „Pause bis <Zeitpunkt>“ oben in Jerrys Vorrat. Meldet seine Starts selbst lautlos, schreibt Jerrys Zeilen in `ARBEIT-BESETZUNG.md` und erfasst Kosten wie oben (Neustart), auch seine eigenen auf Vorgang „Betrieb“. Prüfaufträge von Pro nur als Zeile. In der Sitzung genau „Ford 2 HH:MM ok“, alles andere per Telegram. Einrichten: `LISTE-NIEDERLASSUNG.md`.

## Meldung und Laufbericht (81a, 81l, 81p)

Nur Telegram (`@Bornim_Ford_Bot`, Schlüssel nur als Umgebungsvariable `TELEGRAM_BOT_TOKEN`), Aufruf wie alle (`CLAUDE.md`, Melden), nie per `curl` von Hand; nur Nummern und Stichworte, nie Spieltexte. Jeder Lauf eine Nachricht `tools/meldung.sh Ford "…"`, lautlos (ohne Tat nur „Geprüft: …“ je Rolle mit Grund); `--laut` nur, wenn der Chef dran ist. **In Fords Sitzung genau eine Zeile „Ford HH:MM ok“**; nur wenn `meldung.sh` einen Fehler meldet, den Bericht dort mit „Telegram fehlgeschlagen“. Aufbau in drei Absätzen (Leerzeile = `\n\n`):

```
tools/meldung.sh Ford "Du bist dran: [0.1.748](cs:t748) testen.\n\n[Tom](https://claude.ai/code/<id>): läuft (89 Schatten)\nDiogenes: wartet auf 0.1.748 (71 Dorf)\n[Homer](https://claude.ai/code/<id>): wartet auf dich ([72s.1](cs:72s1) Gefährte)\nPerikles: kein Muss\nJerry: Pause bis Fr.\n\nGestartet: [Tom – D1.3](https://claude.ai/code/<id>)\nSeit dem letzten Lauf: Tom hat D3 gebaut (Commit 09:15)"
```

1. **Einleitung:** ein Satz, ob der Chef dran ist.
2. **Je Rolle eine Zeile** „Name:“, Stand, in Klammern worum es geht; nur Rollen mit Vorrat oder Sitzung, Tom, Jerry und Diogenes immer. Jede Nummer mit Datei in der Chefsache als Sprungmarke `[72s.1](cs:72s1)`, jede laufende Sitzung als Link.
3. **Ereignisse** (Gestartet, Seit dem letzten Lauf, Fehlgeschlagen) nur, wenn es welche gibt; Sitzungen als Link im Titel.
