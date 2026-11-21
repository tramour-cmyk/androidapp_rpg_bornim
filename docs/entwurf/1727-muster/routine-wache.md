# 1727, Routine Wache mit Herzschlag (Fassung 2, Perikles 21.11., 20:19, nach Gegenprüfung 20:18)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O9 und mit dem Herzschlag L-T1. **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung trägt Ford mit der Wache-Uhr :33 (`LISTE-BETRIEB.md`:64, `ARBEIT-BETRIEB.md`:27).

Quellen: Gesamtbild 4.4 Zeile Ford (G:474–475), `signale.md` S12, S18, `ablauf.md` A18, `ROLLE-BETRIEB.md`:35 (rote Läufe, 464), `LISTE-BETRIEB.md`:60, 64 (1572: Sitzung `blocked` ab 15 Minuten laut an den Chef, Chef 17.11., 17:05 „Da muss mir das mal jemand sagen“; Ford blocked oder älter als 70 Minuten), 1610.

## Aufbau: zwei Stufen

1. **Wache = kleine Sitzung je Lauf** (wie heute, Sockel + dieser Auftrag, keine Gruppe), gestartet von ihrer Uhr, nicht vom Büro (G:475). Sie braucht `list_sessions` und `send_message`, darum eine Sitzung, kein GitHub-Lauf.
2. **Herzschlag = GitHub-Zeitplan ohne Token**, wacht über Wache und Büro: Zeitmarke des letzten `lauf.py` oder des letzten Wache-Laufs älter als 70 Minuten → Telegram an den Chef.

## Text (Wache)

```markdown
Ziel: nichts hängt, ohne dass es jemand merkt. Du misst und meldest, du behebst nichts.

Bei jedem Lauf, je Fall höchstens eine Meldung je Stunde (Stand in deiner Datei):
1. **blocked:** eine Sitzung wartet seit 15 Minuten oder länger auf eine Freigabe → `meldung.sh --laut` an den Chef mit Link.
2. **Disponent:** blocked, oder letztes Ereignis älter als 70 Minuten → laut an den Chef.
3. **Sitzung hängt:** `idle` mit angenommener Übergabezeile nach Ablauf der Frist → Wecker an den Disponenten.
4. **Rote Läufe:** ab 3 fehlgeschlagenen GitHub-Läufen in der Stunde → laut an den Chef mit Zahl, Zweigen, Link; Wecker an den Disponenten.
5. **Du bist dran:** neue Testbitte oder Chefsache ohne Telegram → laut an den Chef.
6. **Tagesbericht fehlt** um 10 Uhr (Sa/So 12 Uhr) → Wecker an den Disponenten.
Dann endest du.
```

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Wache** | eigene Uhr (heute :33, stündlich; Takt Annahme) | `list_sessions`, GitHub-Läufe, Chefsache, Tagesbericht | Lauf endet nach sechs Prüfungen | Telegram, Wecker | Chef (1, 2, 4, 5), Disponent (3, 4, 6) | blocked 15 Minuten bei stündlichem Lauf nicht einlösbar (1610: 15 bis 75 Minuten), Frage 1 |
| **Herzschlag** | GitHub-Zeitplan | Zeitmarken `lauf.py`, Wache | – | Telegram an den Chef | Chef | Telegram-Token als GitHub-Secret setzt der Chef |

## Offen, Fragen

1. **Takt:** „15 Minuten blocked“ verlangt einen Lauf alle 15 Minuten (1610); heute stündlich. Vorschlag: Wache alle 15 Minuten, dafür sehr kurz (kleines Modell, nur dieser Auftrag). Annahme, Kosten im Falltest messen.
2. **Rote Läufe an einer Stelle:** Bauliste 7.1 legt „laut ab 3 roten Läufen“ auch auf `lauf.py` (G:919). Vorschlag: nur Wache; G:919 streichen.
3. **„Du bist dran“ ohne Telegram:** heute meldet der Absender selbst; die Wache fängt nur Vergessenes. Ab wann „vergessen“ gilt, ist offen (Annahme: nächster Lauf).
4. Zahlen „eine Meldung je Stunde“ und „Takt 15 Minuten“ sind Annahmen.

## Stärkstes Gegenargument

Eine Sitzung alle 15 Minuten kostet mehr als heute stündlich. **Dagegen:** 1572 ist eine Forderung des Chefs; stündlich hält sie nur zufällig ein (1610). Bleibt die Wache stündlich, Fall 1 ehrlich „bis 75 Minuten“ nennen.

## Gegenprüfung 20:18, mein Wort

1 blocked fehlte, 1610 falsch zitiert, 70 Minuten: **stimmt**, Fälle 1 und 2, Herzschlag 70 Minuten · 2 Wecker aus GitHub-Lauf widersprüchlich: **stimmt**, Wache bleibt Sitzung, nur Herzschlag als GitHub-Lauf · 3 rote Läufe doppelt mit 7.1, nachts doppelt: **stimmt**, Frage 2, „nachts“ gestrichen · 4 Zahlen ohne Kennzeichnung, Quelle :33: **stimmt**, gekennzeichnet, berichtigt · Gegenargument (heutige Wache ist Sitzung, GitHub sieht blocked nicht): **stimmt**, Aufbau geändert.
