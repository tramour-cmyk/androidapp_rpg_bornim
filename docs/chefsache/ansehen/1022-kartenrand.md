# 1022 · Kartenrand weich ins Dunkel, vorher/nachher · Tom (Spike) · 12.11., 23:42

[Bild von 12.11., 23:43](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/12-2343-1022-Spike.png) (eingetragen von meldung.sh, Spike)

E Welt · Zweig `claude/spike-1022-kartenrand` · auf dem Bauserver mit Kaufmodellen, wie im Spiel

Geprüft an: [Lauf 43310392064](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43310392064), [Commit 88c0b35](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/88c0b353c)

Rückläufer zu deinem Urteil 20:07 („Dachte, das sollte irgendwie so ein sanfter Übergang werden und dann dunkel.“). Ursache: Der Übergang ins Dunkel war am Boden gemessen. Bei unserem schrägen Blick war er im Bild nur 1,6 Kacheln hoch und blieb bis kurz vor Schwarz fast hell, darum die harte Linie. Jetzt ist er im Bild gemessen: 1,5 Kacheln hinter dem Rand hell, dann über 4 Kacheln weich ins Schwarz, an allen Seiten und in den Ecken rund. Die Grashalme laufen mit ins Dunkel.

So aufgenommen wie um 17:59: Spielansicht bei Tag, die Karte so gedreht, dass der Held zum Rand schaut (der Rand liegt oben). Links vorher (Build 280, so wie du es gespielt hast), rechts nachher.

![Dorf Nord am Schlagbaum, Dorf Süd an der Brücke, Kornfeld](../bilder/1022-rand-1.webp)

![Fluss im Westen und Osten des Dorfs, Flüsterwald Ost](../bilder/1022-rand-2.webp)

![Flüsterwald Süd, Tiefer Wald Ost und Süd](../bilder/1022-rand-3.webp)

- **Nachher:** Hinter dem Rand steht Wald, der nach außen dunkler wird, keine gerade Kante mehr. Der Weg hinter Schlagbaum und Brücke endet unter den Bäumen, der Fluss läuft ins Dunkel.
- **Rest, mir ist aufgefallen:** (1) hinter dem Schlagbaum enden die zwei Wegstücke noch recht hell vor den ersten Bäumen; (2) am Fluss bleiben die hellen Wellenlinien sichtbar, bis das Wasser fast schwarz ist; dadurch wirkt das Ende des Flusses eher wie ein Schnitt als die Wiese daneben.
- Der Randtest ist grün (0 Fehler). Rot war nur ein fremder Test zur Prüfliste (1020), der mit dem Kartenrand nichts zu tun hat; die Bilder betrifft das nicht.

**Was du sagen sollst:** „1022 passt“ (fährt im nächsten Build); oder „Rest weg“ mit den Nummern (1), (2), die weg sollen; oder dein Urteil zu den Bildern. Heute Nacht urteilt Sokrates an deiner Stelle (1077).
