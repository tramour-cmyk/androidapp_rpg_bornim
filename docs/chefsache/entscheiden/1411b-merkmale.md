# 1411b · Sollen Gegner je Exemplar ein Merkmal bekommen (jung, alt, kräftig, rostige Waffe …), als Abwechslung, auch wenn das Lesen der Merkmale kaum Siege bringt?
Sokrates · 16.11., 20:43 · G Balance · aus deinem Wort 18:30–18:41 („sonst 100 % geklont“, „Abwechslung ist Teil unserer Welt!“), Rechnung Tuffy 20:32
Kurz: Merkmale sind harmlos und tragen Abwechslung, aber kaum Taktik; Votum: bauen als Abwechslung, Wahrnehmung lohnt weiter über die Ansage.
Beim Chef, weil: neue Richtung im Spielgefühl (Gegner gleicher Art haben verschiedene Werte; ersetzt „Die Werte bleiben gleich“ in `DESIGN-STIL.md`)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/53b522917db9f9ff5944dbd99f2d12ceba45af25/tools/sim444/merkmale_1411_ergebnis.md (Rechnung Tuffy auf `claude/tuffy-1411-1-merkmale`, `tools/sim444/merkmale_1411.py`, Bericht `merkmale_1411_ergebnis.md`, je Zelle 2000 Kämpfe, acht Herkünfte, zwölf Begegnungen bis Grak)

**Frage:** Heute hat jedes Exemplar einer Art dieselben Werte (jedes Wildschwein dasselbe Leben), Streuung gibt es nur im Schaden (± 20 %). Du wolltest am 16.11., 18:30–18:37, dass ein älterer Wolf schwächer ist als ein junger, ein Skelett eine kaputte Waffe haben kann, und dass man das mit mehr Wahrnehmung lesen kann, „dann bringt die Fertigkeit was“. Tuffy hat das gerechnet. Ergebnis: die Merkmale verändern die Kämpfe kaum, und wer sie lesen kann, gewinnt dadurch so gut wie nicht öfter. Sollen wir sie trotzdem bauen, als Abwechslung, oder anders?

**Votum:** „1411b A“: Merkmale bauen als Abwechslung, nicht als Taktik; Wahrnehmung lohnt weiter über die Ansage des gegnerischen Schlags (1288b), nicht über Merkmale.

**Berührt:** Jerry (Daten, Anzeige im Kampf, Kerntest, `sim.py`), Homer (Beschreibungen je Merkmal), `DESIGN-STIL.md` „Abwechslung“ (Zeile „Die Werte bleiben gleich“), `DESIGN-GLUT.md` „Lesewert“, `DESIGN-BRS.md` (trage ich nach); neu angelegt aus derselben Rechnung: 1486 (Schwierigkeit bei gleicher Stufe), 1487 (Heiler wächst nicht).

**Begründung:** Dein Ziel war zweierlei: „nicht 100 % geklont“ und „die Fertigkeit bringt was“. Das erste erfüllen die Merkmale, ohne die Balance zu stören. Das zweite erfüllen sie nicht, und auch doppelt so starke Merkmale ändern daran nichts; der Lohn für Wahrnehmung liegt schon in der Ansage (1288b A, gerechnet etwa 10 Siege je 100). Dein Wort 18:41: „es muss ausreichend Varianz geben bei der Beschreibung … nicht 50 Mal alter Wolf lesen“.

**Sachverhalt:**
- Gerechnete Merkmale (mein Entwurf, keine Regel): je Exemplar höchstens eines, die Hälfte gewöhnlich. Tiere: jung (Leben −15 %, Angriff −10 %, Abwehr +10 %), alt (Leben −10 %, Angriff −10 %), kräftig (Leben +15 %, Schaden +15 %), angeschlagen (Leben −30 %). Untote, Goblins, Kobold: rostige Waffe (Schaden −25 %), gute Waffe (+20 %), brüchig (Leben −20 %), zäh (Leben +20 %). Bosse fest (wie `DESIGN-STIL.md` „Ausnahme einmalige Monster“).
- Lesen nach `DESIGN-GLUT.md` „Lesewert“ (Wahrnehmung + Spähen/5 gegen den Gegenwert der Art): Stufe 0 nichts, 1 Pfeil stärker/schwächer, 2 Name des Merkmals, 3 dazu die Wirkung.
- Wirkung auf die Kämpfe: Siege +0,1 je 100, Niederlagen −0,1, Runden −0,06; in keiner Zelle mehr als 2 Niederlagen je 100 dazu. Harmlos, aber in Zahlen unmerklich.
- Lesen 0 → 3 (Held greift zuerst das schwächste oder das gefährlichste Exemplar an, acht Begegnungen mit mehreren Gegnern): +0,2 Siege je 100, höchstens +4; mein Ziel waren mindestens 5, erreicht in keiner von 128 Zellen. Grund: selbst die beste gegen eine zufällige Zielwahl bringt nur 2–7 Siege; doppelt starke Merkmale: Lesen +0–1; stärkere Exemplare ganz meiden: +1–2.
- Schadensstreuung kommt nur beim Helden an (Held gegen Gegner 5–16 verschiedene Zahlen). Gegner gegen Held: Riesenratte 2 Zahlen, eine davon in 65–72 % der Treffer; Wolf 2–4, Krogg 3–4 (kleiner Grundschaden, Rundung, Rüstung). Darum sind Schadensmerkmale bei kleinen Gegnern kaum zu spüren; Lebensmerkmale schon (angeschlagen: ein Treffer weniger).
- Nebenbefunde derselben Rechnung (eigene Vorgänge, nicht Teil dieser Frage): Wachsoldat und Klosterschüler gewinnen bei gleicher Stufe 100 % in allen zwölf Begegnungen, auch gegen Grak (1486, Jerry rechnet). Der Heiler wächst in Kapitel 1 nie im Willen, weil er Stumpfe Waffen statt Heilmagie übt (1487, Jerry).

**Auswertung:**
- **A (Empfehlung): bauen als Abwechslung.** Merkmale wie gerechnet; bei Gegnern mit kleinem Schaden (Riesenratte, Riesenfledermaus) nur Lebensmerkmale, weil Schadensmerkmale dort in der Rundung verschwinden; Bosse fest. Lesestufen 1–3 wie oben. Homer schreibt je Merkmal mindestens drei Beschreibungen je Art, zufällig, nie dieselbe zweimal hintereinander (wie bei Gesprächen, `DESIGN-STIL.md`). `DESIGN-STIL.md` bekommt statt „Die Werte bleiben gleich: Varianten sind Optik“: „Varianten sind Optik; dazu höchstens ein Merkmal je Exemplar, das Werte ändert (1411b)“. Kosten: ein Bau Jerry (Daten, Anzeige, Kerntest, `sim.py`), ein Textauftrag Homer; die Balance bleibt.
- **B: nur Beschreibung, Werte gleich.** Abwechslung im Text („ein alter Wolf“), aber ohne Wirkung. Billiger, keine Rechnung mehr nötig. Widerspricht deinem Wort „ein älterer Wolf ist vielleicht nicht mehr so stark“, und der Spieler merkt bald, dass der Text lügt.
- **C: Merkmale mit Verhalten**, damit das Lesen eine Entscheidung ändert: etwa ein angeschlagenes Tier flieht früher, eine rostige Waffe kann brechen, ein junger Wolf zögert. Das wäre der Weg zu „die Fertigkeit bringt was“, braucht aber eigene Ideen von Homer, Bau und Rechnung von Jerry und ist neues Kampfverhalten; nach Kapitel 1 oder als eigener Vorgang.
- **Stärkstes Gegenargument gegen A:** Wir bauen und texten etwas, das in keiner Siegzahl auftaucht; der Spieler liest „kräftig“, merkt aber kaum einen Unterschied, und Lesestufe 3 („Wirkung“) zeigt Zahlen, die nichts entscheiden. Dagegen: die Kämpfe werden nicht schlechter, die Welt wirkt weniger geklont, und angeschlagen oder zäh spürt man an der Zahl der Treffer. Wer mehr will, nimmt später C dazu; A verbaut C nicht.

**Folgerungen:** Bei A: Bauvorgang an Jerry (Merkmale in den Monsterdaten, Anzeige nach Lesestufe, Kerntest, `sim.py` nachziehen), Textvorgang an Homer (je Merkmal und Art mindestens drei Beschreibungen), `DESIGN-STIL.md` und `DESIGN-BRS.md` trage ich nach. Bei B: nur Textvorgang an Homer. Bei C: Ideenvorgang an Homer, Rechnung Jerry, neue Vorlage.

Antwort: …
