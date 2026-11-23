# 1068 · Ring bei großen Schlägen in den Testbuild, Zeitmaß getrennt angehen?
Sokrates · 23.11., 16:59 · E Kampf · Prüfer 16:13 „nein, Auftrag“: Arbeit abgenommen, nur Maß 784 offen
Kurz: Arbeit abgenommen; das Kampf-Zeitmaß reißt schon auf main; Votum: 1068 in den Testbuild, Zeitmaß als eigener Vorgang.
Beim Chef, weil: neue Richtung im Spielgefühl

Geprüft an: Zweig claude/zeno-1068-ring d6c9ce258, Prüfung Hanna 23.11., 16:13 (docs/vorgang/1068.md)

**Frage:** Der Ring bei großen Schlägen der Gegner (Leitwolf, Grimmzahn) ist gebaut und von der Prüferin abgenommen. Offen ist nur das Zeitmaß aus 784 (11.11., Runde 14,6 s). Das reißt schon auf main (17 Werte über Maß, Runde 26 s), mit 1068 sind es 18. Ganze Kämpfe dauern mit Ring länger: Rudel +16 %, Grimmzahn mit Leibwache +15 %. Soll 1068 trotzdem in deinen nächsten Testbuild, und das Zeitmaß wird getrennt angegangen?

**Votum:** „1068 A“: 1068 in den nächsten Testbuild; du urteilst beim Spielen; das zu lange Zeitmaß auf main wird ein eigener Vorgang.

**Berührt:** 784 (Sollbild Wolfsrudel, F9 in DESIGN-KAMPF.md), 1048, Build-Macher.

**Begründung:** Chef 11:27: „da will ich immer noch keine Filme sehen, sondern die kann ja einfach nur messen, wie sich jetzt die Zeit verändert hat.“ Gemessen ist es; ob die Spannung die Zeit wert ist, zeigt nur das Spielen.

**Sachverhalt:**
- Messung mit Kaufmodellen, Seeds 1–10, Kampf bis Ende: main 470 s, Ring für alle 571 s, Leitwolf allein 545 s.
- ringschlag_1068 rot→grün (df0802cc0 → d6c9ce258); Automatik-Siege gleich, Patt 0.
- sollbild_784 STRENG=1: main 17 über Maß, Zweig 18.

**Auswertung:**
- **A (Empfehlung):** Testbuild mit Ring; Zeitmaß eigener Vorgang. Kosten: ein Testbuild, den es ohnehin gibt.
- **B:** Ring zurück, erst Zeitmaß auf main reparieren, dann neu messen. Kostet Tage, Ring liegt.
- **Stärkstes Gegenargument gegen A:** 16 % längere Kämpfe auf einem schon zu langsamen Stand.
- **Was es entkräftet:** Der Ring liegt auf eigenem Zweig; nach deinem Test ist er in einem Schritt zurück.

## Abgleich

`vorgang.py lehre suche 1068 ring`: kein Treffer.
Archiv 1068 ring: 1068 Leibwache ohne Ring; 1068 Ring nur beim Leitwolf

**Folgerungen:** Bei A: Build-Macher nimmt den Zweig in den nächsten Testbuild; Sokrates legt den Zeitmaß-Vorgang an. Bei B: Kampf-Fachkraft repariert erst das Zeitmaß.

Antwort: …
