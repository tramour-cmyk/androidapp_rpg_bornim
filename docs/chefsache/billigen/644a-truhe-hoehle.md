# 644a · Vorentscheid billigen: Waffen der Truhe in der Blutzahnhöhle auf Stufe 3 statt 4?
Sokrates · 12.11., 08:31 · E Kampf · aus 644a (Chef 08:21), Befund Homer 644a.3 (08:29)
Kurz: Die fünf Waffen der Truhe vor Krogg bekommen Stufe 3, damit der Held sie im Kampf gegen Krogg tragen kann; sonst gilt 644a unverändert

Geprüft an: [gegenstaende.json auf main](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/tools/gegenstaende/gegenstaende.json) (Einträge mit „Truhe in der Blutzahnhöhle (cave_3, 870.14)“, alle Stufe 4, ohne Zusatzeigenschaften); `DESIGN-BRS.md` 11 „Gegenstandsstufe“

**Frage:** Mit 644a trägt ein Held ein Stück erst ab dessen Stufe. In der Blutzahnhöhle liegt vor Krogg eine Truhe mit einer Waffe nach deiner Fertigkeit (Klinge von Bornim, Die Namenlose, Wolfsspieß, Schwarzeibe, Nachtwache), alle Stufe 4. Garrick warnt vor der Höhle „unter Stufe 3“; die meisten Helden kommen also mit Stufe 3 an und könnten die Waffe genau im Kampf gegen Krogg nicht anlegen, erst danach. Ich habe entschieden: Stufe 3. Billigst du das?

**Entschieden:** Die fünf Waffen der Truhe cave_3 haben Stufe 3. Alles andere aus 644a bleibt.

**Umgesetzt:** noch nicht; Tom ändert die Stufe in `gegenstaende.json` mit 644a.2.

**Rückbau:** eine Zahl je Stück zurück auf 4.

**Kosten:** keine eigenen, läuft in 644a.2 mit.

**Berührt:** 644a.2 (Tom), 644a.1 (Jerry rechnet mit Stufe 3), Homer 644a.3

**Begründung:** Die Truhe ist als Belohnung vor dem Boss gesetzt; eine Waffe, die man vor Krogg findet und erst nach Krogg tragen darf, verfehlt ihren Zweck und ärgert genau an der Stelle, die Spannung bringen soll. Abgeglichen mit: 644a (Funde höchstens eine Stufe über dem Helden, Einzelstücke mit Katalogstufe; Stufe 3 erfüllt beides), Leitbild (nie Blockade, echte Wahl), Regelwerk 11 (Einzelstücke haben feste Werte, die Stufenschritte der Zusatzeigenschaften gelten für sie nicht), Geschichte (Garricks Warnung, Homer).

**Sachverhalt:**
- Die fünf Truhenwaffen haben im Katalog keine Zusatzeigenschaften; ihre Stärke kommt aus Grundform und Güte. Stufe 3 statt 4 nimmt ihnen also nichts.
- Krogg ist Stufe 4; ein Sieg hebt den Helden auf mindestens 4 (Homer, `brs.gd` `erfahrung`).
- Graks Kriegsaxt 6, Grimmzahns Fang 5, Kroggs Pranken 4, Ring des Ältesten 6 sind nach dem jeweiligen Sieg sofort tragbar und bleiben (Homer).

**Auswertung:**
- **Stufe 3 (entschieden):** Waffe im Kampf gegen Krogg tragbar; kein Verlust an Stärke.
- **Stufe 4 lassen (verworfen):** sauber nach Katalog, aber die Belohnung liegt bis nach dem Boss in der Tasche.
- **Truhe hinter Krogg legen (verworfen):** ändert Karte und Geschichte, dafür zu viel.
- **Stärkstes Gegenargument:** Ein Held, der schon mit Stufe 2 in die Höhle geht, könnte die Waffe nach 644a (höchstens eine Stufe darüber) gerade noch tragen; mit Stufe 4 nicht. Dass er dann stärker ist als vorgesehen, ist gewollt: er hat die Truhe gefunden.

**Folgerungen:** „gebilligt“: Tom setzt die Stufe mit 644a.2, ich lösche die Datei und vermerke es im Archiv. „zurück“: Stufe 4 bleibt, Tom ändert nichts.

Antwort: …
