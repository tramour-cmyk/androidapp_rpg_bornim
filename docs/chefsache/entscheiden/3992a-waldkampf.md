# 399.2a · Spielfassung: welche Wölfe im Waldkampf?
Jerry · 28.10., 13:30 · B Umzug
Kurz: Ein Held der Stufe 1 allein gegen drei volle Wölfe verliert oft. Soll der Waldkampf wie im alten Spiel ein Wolf mit Jungwölfen sein?

**Frage:** Toms Spielfassung (399.1) schickt den Helden beim Weg aus dem Dorf in den Wald in einen MARS-Kampf. Mit welcher Gruppe?
- **a)** Wie im alten Spiel: ein Wolf mit 1–2 Jungwölfen. Ein Jungwolf ist halb so groß, beißt mit 1W3 und Angriff −1 und flieht, wenn der Leitwolf fällt. Neu dazu, weil MARS sie braucht: eigene Trefferpunkte, halb so viele wie der Wolf.
- **b)** Drei volle Wölfe wie im Probekampf, dazu ein Söldner an der Seite des Helden.
- **c)** Ein einzelner Wolf.

**Votum:** a.

**Berührt:** 399 (Spielfassung), 38 (Balance), 348.7 (Wolfsrudel in MARS).

## Begründung

Gruppe und Stärke sind Balance, die entscheidest du. Tom hat gemessen: ein Held der Stufe 1 allein gegen drei Wölfe gewinnt einmal knapp (9 von 16 TP) und verliert einmal.

## Sachverhalt

- Im alten Spiel war der Waldkampf klassisch: ein Wolf, dazu 1–2 Jungwölfe (`Packs.kt`, Größe 0,55, Biss 1W3, Angriff −1, greifen mit 50 % je Runde an, fliehen, wenn der Leitwolf fällt). Die Jungwölfe hatten keine eigenen Trefferpunkte.
- MARS gab es im alten Spiel nur als Probe: Held und Söldner auf Stufe 3 gegen drei Wölfe (`Skirmish.probe`). Die Spielfassung nimmt heute diese drei Wölfe, aber den Helden mit seiner echten Stufe und ohne Söldner.
- Wolf laut Spieltabelle (`tabellen.json`): 2W6+2 TP, RK 13, Biss +4, 2W4+2.

## Auswertung

Stärkstes Gegenargument zu a: In MARS braucht ein Jungwolf eigene Trefferpunkte. Die halben TP des Wolfs sind neu festgelegt, nicht übernommen. Ob das passt, zeigt erst die Messung (38).
Zu b: Das ist die bekannte MARS-Probe, aber die Spielfassung hat noch keine Söldner.
Zu c: Das wäre am leichtesten zu bauen, aber das Rudel fehlt.

## Folgerungen

- a: Jerry baut die Gruppe „Rudel“ in `aufruf.gd` (Jungwolf mit eigenem Blatt und Flucht), Tom ruft sie auf; etwa 0,5 Sitzung.
- b: kein Bau bei Jerry; Tom gibt der Spielfassung einen Söldner mit.
- c: Jerry baut die Gruppe „Wolf“, eine Zeile.

Antwort: …
