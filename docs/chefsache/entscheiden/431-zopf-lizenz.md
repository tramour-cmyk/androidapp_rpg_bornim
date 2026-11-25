# 431 · Zöpfe der Zwergin: fremden Zopf trotz unklarer Lizenz behalten oder selbst bauen?
Sokrates · 25.11., 10:02 · E Figuren · aus Prüfer 431-Ü17 (09:58)
Kurz: Der MakeHuman-Zopf hat zwei widersprüchliche Lizenzangaben; Vorschlag: eigener Zopf.
Beim Chef, weil: Lizenz, Obergrenze B

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/45569661658 (Commit 45cc2d1a8; Paketseite hair01 gelesen 25.11.)

**Frage:** Die Zwergin trägt seit heute zwei Zöpfe aus einem fremden Gratis-Paket (MakeHuman). Bisher nur auf dem Arbeitszweig, nicht im Spiel und nicht im Testbuild. Auf der Paketseite steht „CC0“, also frei auch für den Verkauf. In der Zopfdatei selbst steht aber „AGPL3“. Diese Lizenz würde verlangen, dass wir unser Spiel offenlegen. Darf der Zopf drin bleiben, oder bauen wir einen eigenen?

**Votum:** „431 A“: eigener Zopf, der fremde fliegt raus.

**Berührt:** 431 (Figur, Britta), LISTE-QUELLEN, Testbuild Sa.

**Begründung:** CLAUDE.md 6: fremde Dateien nur mit Lizenz für kommerzielle Nutzung. Bei zwei widersprüchlichen Angaben ist das nicht belegt. Ich hatte um 08:08 „CC0“ allein nach der Paketseite entschieden. Die Lizenz entscheidest aber du; das war mein Fehler.

**Sachverhalt:**
- Paketseite static.makehumancommunity.org/assets/assetpacks/hair01.html: Zeile „elvs_double_mh_braid, Elvaerwyn, CC0“, Download hair01_cc0.zip (gelesen 25.11.).
- Kopf der Datei .mhclo: „AGPL3“ (Britta, Prüfer 09:58). Vermutlich die Vorgabe des Werkzeugs MakeClothes, aber nicht belegt. Die Seite des Urhebers (node/1336) liefert 404.
- Sonst hat der Prüfer zwei Mängel gefunden, die die Fachkraft ohnehin behebt: Das Haar der Zwergin ist gefleckt wie ein Fell, und die Beschriftung der Belegbilder läuft über den Rand.

**Auswertung:**
- **A (Empfehlung):** eigener Zopf in Blender, zwei Schläfenzöpfe bis auf die Brust, in den 30 $ von 431. Etwa eine Sitzung, kein Lizenzrisiko. Urteil an den Bildern.
- **B:** fremden Zopf behalten und die CC0-Angabe der Seite als ausreichend nehmen. Kostet nichts, aber das Risiko bleibt, falls AGPL3 gilt.
- **C:** Kauf „Hair - Double Braid - Gen2“ (CGTrader, 19 $, Royalty Free). Das Modell ist sehr fein und muss fürs Handy erst vereinfacht werden.
- **Stärkstes Gegenargument gegen A:** Ein selbst gebauter Zopf sieht wahrscheinlich gröber aus als der fertige. Entkräftet: Du urteilst am Bild in Spielkamera. Gefällt er nicht, bleibt C.

**Abgleich:** siehe Abschnitt unten.

**Folgerungen:** A: Britta entfernt den fremden Zopf, baut einen eigenen und behebt die Flecken und den Beleg, dann ein Beleglauf und Bilder an dich. B: nur Flecken und Beleg beheben. C: Kauf durch dich, dann Einbau.

## Abgleich

- `vorgang.py lehre suche Lizenz Zopf CC0`: nur R48 (dieser Fall, Prüfer 09:58: „unsichere Lizenz → Frage zurück“).
- Archiv lizenz zopf cc0: 348.12a (26.10., 11:40, Chef: „am Schluss kein Lizenzproblem“) und 348.12h: „Lizenz je Datei“. Beides stützt A.

Antwort: …  (kurz „431 A“, „431 B“ oder „431 C“)
