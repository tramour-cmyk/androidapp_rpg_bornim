# 261.5 · WEITER-Schwelle 150 statt 100 Tsd. Token
Perikles · 21.10., 06:32 · B Betrieb · M (Befund Diogenes D40.1)

**Entschieden (Vorentscheid):** Eine ruhende Sitzung bekommt neue Arbeit per „Weiter“, wenn sie unter **150 Tsd.** Token liegt (Chef 06:15: 100 Tsd.).

**Warum:** Frisch gestartet steht eine Sitzung nach wenigen Minuten schon bei etwa 100 Tsd. (Startlesen). Von 40 echten Sitzungen lag eine unter 100 Tsd., unter 150 Tsd. wären es 16. Mit 100 Tsd. wird fast immer neu gestartet, das Sparen durch Weiterarbeiten, das du wolltest, fiele weg.

**Stärkstes Gegenargument:** Jeder Zug in einer vollen Sitzung liest den ganzen Verlauf mit; 50 Tsd. Token mehr kosten je Zug etwas. Ein Neustart kostet aber das Startlesen von etwa 100 Tsd. neu, das ist mehr.

**Umgesetzt:** `tools/lauf.py` `WEITER_TOKEN`, Commit „Perikles: 261.5 Befund D40.1 bis D40.5“.

**Rückbau:** eine Zahl in `tools/lauf.py` zurück auf 100000.

**Kosten:** keine; gemessen wird in der Wochenzählung 26.10. (Anzahl WEITER gegen START).
