# 438a · Hinfallen und Aufstehen des gekauften Helden
Jerry · 01.11., 09:50 · K Kampf

**Frage:** Der gekaufte Held hat keine Bewegung zum Hinfallen und Aufstehen. Beim Sprung eines Wolfs („geht in die Knie“) zuckt er nur getroffen, bei „steht wieder auf“ steht er einfach. Woher sollen die beiden Bewegungen kommen?
1. Aus der gekauften Bibliothek: Hinlegen zum Kriechen und Aufstehen daraus (Crawl_Enter, Crawl_Exit).
2. Aus der gekauften Bibliothek: Hinsetzen auf den Boden und Aufstehen (GroundSit_Enter, GroundSit_Exit).
3. Eigene Schlüsselbilder wie die übrigen Kampfbewegungen des Helden (kampf.py): nach hinten in die Knie, Hand am Boden, wieder hoch.

**Votum Jerry:** 3. Nur so passt es zum Sprung von vorn (der Wolf wirft ihn nach hinten), Waffe und Schild bleiben in der Hand. 1 fällt nach vorn auf den Bauch, 2 setzt sich ruhig hin.
**Berührt:** `tools/blender348/v3/kampf.py`, `held_kampf.py`, `godot/kampf/figur.gd` (knocked_down, rise).

## Sachverhalt

- Gesucht in der freien Universal Animation Library und in der gekauften UAL Pro (alle 125 Bewegungen): kein Sturz, kein Aufstehen; Nächstes sind Crawl_Enter/Exit, GroundSit_Enter/Exit, Death01/02.
- Der Held fällt im Spiel bei jedem Sprung, der trifft, ohne ihn umzubringen; im Film 438 einmal (Kleriker).

## Auswertung

- Stärkstes Gegenargument gegen 3: eigene Bewegungen kosten eine Runde mit Film und Prüfer mehr als 1 oder 2, und der Bestand geht nach 408 vor. Dagegen: der Bestand hat nichts Passendes, nur Ersatz, der zur Meldung „geht in die Knie“ nicht passt.
- Folgen: mit 3 ein Film nur der beiden Bewegungen (alle vier Klassen) vor dem Einbau.
