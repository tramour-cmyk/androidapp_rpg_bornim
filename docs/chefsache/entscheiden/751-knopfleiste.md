# 751 · Knopfleiste im Zug der Gegner · Jerry · 09.11., 14:4x
E Oberfläche

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/31bbe358d (Messung `haenger_751`)

**Anlass:** Chef 14:00, Build 271: „sieht man, dass ich überhaupt keine Menüfunktion habe … manchmal verschwindet das einfach alles.“

**Befund (am Rechner nachgestellt, Wolfsrudel):** Der Kampf hängt nicht, er läuft immer weiter. Die Knöpfe fehlen, solange die Gegner dran sind; dann steht dort nur „…“.
- In Build 271 verlor Alrik durch das Anspringen Zug um Zug, so stand „…“ bis zu 2½ Minuten am Stück. Das behebt 702 C (kommt in den nächsten Build).
- Danach dauert eine Runde der Gegner im Mittel 20 Sekunden: je Wolf die Ansage, das Bild dazu („Er drückt sich an den Boden …“), „Anspringen!“, dann der Biss. Ein unnötiges Warten von bis zu 8 Sekunden je Biss habe ich schon gestrichen.

**Frage:** Was soll die Leiste zeigen, während die Gegner dran sind?

- **A (Empfehlung):** Die Knöpfe bleiben stehen, nur matt und gesperrt, bis du dran bist. So verschwindet nie etwas, und du siehst schon, was du gleich wählen kannst. Gegenargument: Man tippt vielleicht auf einen matten Knopf und denkt, er geht nicht.
- **B:** Wie heute „…“, aber mit dem Namen dessen, der gerade dran ist („Wolf 2 ist dran“). Gegenargument: Die Leiste wechselt weiter zwischen leer und voll.
- **C:** Die Runde der Gegner kürzer machen: Ansage und das Bild dazu in einer Zeile statt in zweien (Text von Homer), etwa 3 Sekunden weniger je Wolf. Geht mit A oder B zusammen. Gegenargument: Weniger Zeit, die Ansage zu lesen und darauf zu reagieren.

Bild: keins. Die Leiste mit „…“ siehst du in deinem Bild von 14:00 unter Alriks Leiste.
