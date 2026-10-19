# 215 · Übergänge: Schalter zum Betreten und Verlassen?
Sokrates · 19.10., 13:24 · G Bedienung · K (Bau Tom)

Chef 13:19: „Idee/Design: Beim Betreten oder Verlassen von Objekten einen druckbaren Schalter, damit man bewusst einen Bereich verlässt oder betritt?“

**Heute** (nachgesehen in `Game.kt`, `afterStep`): Der Ortswechsel geschieht von selbst, sobald der Held auf das Feld des Übergangs tritt. Übergänge sind Türen, Höhleneingänge, Wege und Kartenränder. Gesperrte Übergänge melden sich schon heute mit einem Text („klopfen“, Südrand). In Kapitel 1 gibt es etwa 17 Übergänge.

**Frage:** Wo soll ein Schalter den Wechsel auslösen?

- **A, überall:** An jedem Übergang erscheint ein Knopf („Eintreten: Schmiede“, „Verlassen“). Erst das Tippen wechselt den Ort.
- **B, nur bei Gebietswechseln:** Der Knopf kommt nur dort, wo eine andere Gebietskarte oder Gefahr beginnt: Höhleneingang, Wege und Kartenränder zwischen Wald und Dorf, vor dem Boss. Türen im Dorf und in Innenräumen bleiben wie heute.
- **C, so lassen.**

**Empfehlung: B.** Ein versehentlicher Wechsel ärgert vor allem dort, wo er etwas kostet. Am Höhleneingang beginnen Gefahr und Dunkel, am Kartenrand lädt eine neue Karte, und man verliert die Stelle. Dort ist ein bewusster Schritt richtig, und er gibt dem Ort Gewicht. An einer Haustür im Dorf wäre derselbe Knopf nur ein Tippen mehr bei jedem Besuch, ohne Nutzen. Übliche Rollenspiele machen es genauso: Türen gehen von selbst auf, Zonen und Verliese fragen nach.

*Stärkstes Gegenargument:* A ist einheitlich, der Spieler lernt eine einzige Regel. B verlangt, dass er erkennt, welcher Übergang fragt. Ausgleich: Der Knopf nennt immer das Ziel, und ein Übergang ohne Knopf ist immer eine Tür. Zweitens ist es neu und kein Fehler (179). Also Kür, außer du hast schon versehentliche Wechsel erlebt: Dann ist es ein Fehler, und ich empfehle es als Muss.

**Berührt:** Bewegung und Übergänge (`Game.kt` `afterStep`, Knopf in `WorldScreen.kt`, nur nach Absprache), Wald und Kartenränder (27), Höhle (Jerry).
