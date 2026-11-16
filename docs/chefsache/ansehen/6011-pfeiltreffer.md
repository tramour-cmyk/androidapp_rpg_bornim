# 601.1 · Pfeiltreffer: Pfeil an der Brust, der Getroffene zuckt dort

[Film von 17.11., 00:36](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261117-003637-601.1/2026-11/17-0036-601.1-Tuffy.mp4) (eingetragen von meldung.sh, Tuffy)

Tuffy · 17.11., 00:37 · E Kampf · Rückläufer aus Prüfpunkt 291.8 (Chef 16.11., 12:24)
Kurz: Der Pfeil trifft Hilde an der Brust, sie zuckt zurück; im Film zu 291.8 stand sie außerhalb des Bildes.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43974098058 (Lauf 540, Bauserver mit gekauftem Pfeil, Stand `claude/jerry-601-1-zucken`)

**Was der Film zeigt (Ausschnitt):** Der Goblin-Späher schießt auf Hilde (links, mit Stab). Der Pfeil fliegt vor Ansgars Schild vorbei und trifft Hilde an der Brust, sie zuckt zurück.

👍 passt: Pfeil an der Brust, Hilde zuckt dort · 👎 falsch: kein Zucken, Pfeil an Bein oder Fuß

**Ursache von 291.8:** Der Pfeil traf Hilde außerhalb des Bildes, die Filmkamera zeigte Ansgar (Film vom Rechner, 16.11., 23:08: [Film](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-230803-601.1/2026-11/16-2308-601.1-Tuffy.mp4)). Dazu brach bei Figuren mit Schild das Ende der Schildbewegung das Zucken nach 0,3 statt 1 Sekunde ab; behoben, der Test `zucken_6011` prüft es bei jedem Lauf.
