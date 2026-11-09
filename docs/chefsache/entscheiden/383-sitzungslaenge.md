# 383 · Sitzungslänge: wo liegt die Balance? · Sokrates · 09.11., 18:0x
B Steuerung

Geprüft an: https://claude.ai/code/session_01Hmoj77JcuVxyvcipG9YQ1e (Abrechnungsdaten dieser Sitzung, `list_events` „result“)

**Anlass:** Chef 18:01: „wir haben doch gesagt, dass die Sitzungen länger laufen sollen, weil das Neustarten ja auch ganz viel frisst … das müsst ihr wissen … Du sollst beraten und nicht nur berichten.“ Heute gilt 383.1 (27.10., Vorentscheid Perikles): Neustart-Haken ab 300 Tsd. Token Zuwachs, Weiter in die alte Sitzung bis 400 Tsd.

**Rechnung** (Zahlen aus dieser Sitzung: 18,64 $, Start 88 Tsd. Token, jetzt 397 Tsd., etwa 230 Aufrufe, je Aufruf +1,3 Tsd.; Lesen aus dem Zwischenspeicher etwa 0,25 $ je Mio. Token, neu Anlegen etwa 5 $):
- Jeder Aufruf liest das ganze Gespräch: bei 90 Tsd. etwa 0,02 $, bei 400 Tsd. etwa 0,10 $. Die Kosten je Aufruf wachsen mit der Länge, darum wachsen die Kosten einer Sitzung im Quadrat.
- Ein Neustart kostet einmalig etwa 1 $ (Grundtext neu anlegen, Rollendatei, Vorrat, Liste lesen, Übergabe).
- Günstigste Länge, wo beides sich ausgleicht: **etwa 200 Tsd. Token** (bei 0,5 $ Startkosten 160 Tsd., bei 2 $ 230 Tsd.). Kosten je Aufruf: bei 200 Tsd. 0,048 $, bei 300 Tsd. 0,055 $ (+14 %), bei 400 Tsd. wie diese Sitzung 0,065 $ (+35 %).
- **Größter Einzelposten: Pausen.** Der Zwischenspeicher hält eine Stunde. Nach längerer Pause wird das ganze Gespräch neu angelegt: bei 400 Tsd. etwa 2 $ für einen einzigen Aufruf, mehr als ein frischer Start. Diese Sitzung zahlte das heute um 17:31 (Pause seit 15:01).

**Beides stimmt also:** sehr kurze Sitzungen (100 Tsd., vor dem 27.10.) zahlen zu oft den Start; sehr lange (300–400 Tsd.) zahlen jeden Aufruf doppelt. Die Mitte ist am billigsten.

**Frage:**
- **A (Empfehlung Sokrates):** Neustart-Haken ab **200 Tsd.** Gesprächslänge statt 300 Tsd. Zuwachs; nach mehr als einer Stunde Pause bei über 200 Tsd. nicht in die alte Sitzung weiter, sondern Nachfolger (Ford/`lauf.py`); Bau Perikles. Diogenes misst eine Woche Kosten je Aufruf vorher gegen nachher.
- **B:** wie heute.

**Stärkstes Gegenargument:** jeder Neustart verliert Zusammenhang; heute fehlte der Wortlaut zu MARS. **Antwort:** der MARS-Wortlaut fehlte, weil er nie eingetragen wurde, nicht wegen eines Neustarts; was zählt, steht in Vorrat und Übergabe. Für Gespräche mit dir (Chefrunde) gilt dasselbe: lieber ein Nachfolger mit sauberer Übergabe als eine Sitzung, die nach jeder Pause 2 $ zum Aufwärmen braucht.

**Folgerung bei A:** Perikles stellt `tools/neustart-haken.py` (BORNIM_NEUSTART_AB) und die Weiter-Grenze in `lauf.py` um; 383.1 wird abgelöst.
