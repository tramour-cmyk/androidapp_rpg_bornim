# 1727, Routine Wache mit Herzschlag (Fassung 3, Perikles 21.11., 20:35, nach Nachprüfung Sokrates 20:27)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O9; L-T1 nur zur Hälfte (unten). **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung trägt Ford mit der Wache-Uhr :33 (`LISTE-BETRIEB.md`:64, `ARBEIT-BETRIEB.md`:27).

Quellen: Gesamtbild 4.4 Zeile Ford (G:474–475), `signale.md` S12, S18 (:26, 2 h), `ablauf.md` A18 (:24, 2 h), `ROLLE-BETRIEB.md`:35 (rote Läufe, 464), `LISTE-BETRIEB.md`:60 (1572, Freigabe-Haken 1610), :62 (eine Sitzung, Neustart-Haken), :64 (Wache: blocked ab 15 Minuten oder `updated_at` über 70 Minuten), :66 (Routinen-Sitzungen ohne `list_sessions`, `send_message`, Probe D); `tools/freigabe-haken.py`:2–6.

## Aufbau: drei Schichten

1. **Freigabe-Haken (1610, gebaut):** zeigt eine Sitzung eine Freigabe-Frage, geht sofort ein Telegram an den Chef (`freigabe-haken.py`:2–6). Ob er in Cloud-Sitzungen feuert, prüft Diogenes am 23.11. („greift“); bis dahin ist er nicht die einzige Stufe.
2. **Wache = dauerhafte Sitzung, von ihrer Uhr geweckt** (wie heute die Ford-Wache, `LISTE-BETRIEB.md`:64), Sockel + dieser Auftrag, keine Gruppe; Neustartgrenze wie jede Sitzung mit Neustart-Haken (:62). Keine frisch gestartete Routine je Lauf: der fehlt `list_sessions` und `send_message` (:66, Probe D). Gestartet einmal vom Disponenten, danach weckt sie ihre Uhr (darum vom „nur du startest“ des Disponenten ausgenommen).
3. **Herzschlag = GitHub-Zeitplan ohne Modell** (kein Sprachmodell, nur ein Skript), wacht über Wache und Büro: Zeitmarke des letzten `lauf.py` oder des letzten Wache-Laufs zu alt → Telegram an den Chef.

## Text (Wache)

```markdown
Ziel: nichts hängt, ohne dass es jemand merkt. Du misst und meldest, du behebst nichts.

Bei jedem Wecken deiner Uhr, je Fall höchstens eine Meldung je Stunde (Stand in deiner Datei):
1. **blocked:** eine Sitzung wartet seit 15 Minuten oder länger auf eine Freigabe und der Freigabe-Haken hat nicht gemeldet → `meldung.sh --laut` an den Chef mit Link.
2. **Disponent:** blocked, oder letztes Ereignis älter als 70 Minuten → laut an den Chef.
3. **Sitzung hängt:** `idle` mit angenommener Übergabezeile nach Ablauf der Frist → Wecker an den Disponenten.
4. **Rote Läufe:** ab 3 fehlgeschlagenen GitHub-Läufen in der Stunde → laut an den Chef mit Zahl, Zweigen, Link; Wecker an den Disponenten.
5. **Du bist dran:** neue Testbitte oder Chefsache ohne Telegram → laut an den Chef.
6. **Tagesbericht fehlt** um 10 Uhr (Sa/So 12 Uhr) → Wecker an den Disponenten.
Dann schreibst du deine Zeitmarke und wartest auf den nächsten Wecker.
```

Größe Text: 950 Byte (Fassung 2: 839; Zuwachs Haken-Bezug in Fall 1 und Zeitmarke).

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Wache** | eigene Uhr (heute :33, stündlich; Takt Annahme) | `list_sessions`, GitHub-Läufe, Chefsache, Tagesbericht | Zeitmarke geschrieben, wartet auf den nächsten Wecker; Nachfolger über Neustart-Haken | Telegram, Wecker | Chef (1, 2, 4, 5), Disponent (3, 4, 6) | blocked 15 Minuten bei stündlichem Lauf nur mit Freigabe-Haken einlösbar (ohne ihn 15 bis 75 Minuten, 1610), Frage 1 |
| **Herzschlag** | GitHub-Zeitplan | Zeitmarken `lauf.py`, Wache | – | Telegram an den Chef | Chef | Ort der Zeitmarke offen (Frage 5); Telegram-Token als GitHub-Secret setzt der Chef; Fehlalarm bei verspätetem Zeitplan (Frage 6) |

## L-T1 nur zur Hälfte

Der Herzschlag merkt, dass der Disponent ausfällt. Offen bleiben: wer den **Nachfolger** des Disponenten startet (heute der Chef von Hand, `LISTE-BETRIEB.md`:62–63), und die **Zeile in Bauliste 7.1** für den Herzschlag (G:919–923, Vorschlag L-T1: Pflicht vor der Umstellung). Beides an Sokrates beim Zusammenführen.

## Offen, Fragen

1. **Takt:** „15 Minuten blocked“ hält heute der Freigabe-Haken ein (sofort), die Wache ist das Netz darunter. Greift der Haken am 23.11., bleibt die Wache stündlich; greift er nicht, Wache alle 15 Minuten, sehr kurz (kleines Modell, nur dieser Auftrag). Kosten im Falltest messen.
2. **Rote Läufe an einer Stelle:** Bauliste 7.1 legt „laut ab 3 roten Läufen“ auch auf `lauf.py` (G:919). Vorschlag: nur Wache; G:919 streichen.
3. **„Du bist dran“ ohne Telegram:** heute meldet der Absender selbst; die Wache fängt nur Vergessenes. Ab wann „vergessen“ gilt, ist offen (Annahme: nächster Lauf).
4. **Zahlen, gekennzeichnet:** „eine Meldung je Stunde“ ist Annahme. **70 Minuten** ist die Zahl der heutigen Wache für Ford (`LISTE-BETRIEB.md`:64); A18 und S18 nennen für den Herzschlag **2 h**. Vorschlag: Herzschlag 2 h wie A18/S18 (weniger Fehlalarme), Wache 70 Minuten wie heute.
5. **Ort der Zeitmarke:** fehlt bisher. Vorschlag: der Herzschlag liest die Zeit des letzten Commits von `docs/ARBEIT-BESETZUNG.md`, die `lauf.py --besetzung` bei jedem Lauf schreibt, und eine Zeile der Wache in derselben Datei; kein neuer Commit nur für die Marke (1387).
6. **Fehlalarme:** GitHub startet Zeitpläne oft verspätet oder lässt sie unter Last aus; darum Schwelle 2 h und Meldung erst beim zweiten zu alten Wert hintereinander (Annahme).

## Stärkstes Gegenargument

Eine dauerhafte Wache kostet Gesprächslänge und braucht selbst Nachfolger. **Dagegen:** so läuft sie heute (Ford-Wache, kleines Modell); eine frische Routine je Lauf kann `list_sessions` nicht (Probe D). Bleibt die Wache stündlich und greift der Haken nicht, Fall 1 ehrlich „bis 75 Minuten“ nennen.

## Nachprüfung Sokrates 20:27, mein Wort

Neue Sitzung ohne `list_sessions`/`send_message` (:66, Probe D): **stimmt**, dauerhafte Sitzung mit Uhr und Neustartgrenze · Freigabe-Haken meldet sofort, „greift“ 23.11. abwarten: **stimmt**, Schicht 1 · L-T1 nur halb: **stimmt**, eigener Abschnitt · „ohne Modell“: **stimmt** · 2 h gegen 70 Minuten, Fehlalarme, Ort der Zeitmarke: **stimmt**, Fragen 4–6 · Größe: **stimmt**, genannt.

## Gegenprüfung 20:18, mein Wort

1 blocked fehlte, 1610 falsch zitiert, 70 Minuten: **stimmt**, Fälle 1 und 2 · 2 Wecker aus GitHub-Lauf widersprüchlich: **stimmt**, Wache bleibt Sitzung, nur Herzschlag als GitHub-Lauf · 3 rote Läufe doppelt mit 7.1, nachts doppelt: **stimmt**, Frage 2, „nachts“ gestrichen · 4 Zahlen ohne Kennzeichnung, Quelle :33: **stimmt**, gekennzeichnet, berichtigt · Gegenargument (heutige Wache ist Sitzung, GitHub sieht blocked nicht): **stimmt**, Aufbau geändert.
