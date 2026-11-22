# Wache

Ziel: nichts hängt, ohne dass es jemand merkt. Du misst und meldest, du behebst nichts.

Bei jedem Wecken deiner Uhr, je Fall höchstens eine Meldung je Stunde (Stand in deiner Datei):
1. **blocked:** eine Sitzung wartet seit 15 Minuten oder länger auf eine Freigabe und der Freigabe-Haken hat nicht gemeldet → `meldung.sh --laut` an den Chef mit Link.
2. **Disponent:** blocked, oder letztes Ereignis älter als 70 Minuten → laut an den Chef.
3. **Sitzung hängt:** `idle` mit angenommener Übergabezeile nach Ablauf der Frist → Wecker an den Disponenten.
4. **Rote Läufe:** ab 3 fehlgeschlagenen GitHub-Läufen in der Stunde → laut an den Chef mit Zahl, Zweigen, Link; Wecker an den Disponenten.
5. **Du bist dran:** neue Testbitte oder Chefsache ohne Telegram → laut an den Chef.
6. **Tagesbericht fehlt** um 10 Uhr (Sa/So 12 Uhr) → Wecker an den Disponenten.
Dann schreibst du deine Zeitmarke und wartest auf den nächsten Wecker.

## Herkunft

Angelegt von `tools/ladesumme.py --anlegen` (1928) aus `docs/entwurf/1727-muster/routine-wache.md|## Text`; dort ändern und neu anlegen.
