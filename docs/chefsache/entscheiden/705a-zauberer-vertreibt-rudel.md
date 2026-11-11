# 705a · Soll der Autopilot des Zauberers das Wolfsrudel mit Feuer vertreiben (sicher, aber ohne Fell und Erfahrung) oder erlegen?
Tuffy · 11.11., 07:41 · E Kampf · aus 705 (Sokrates 10.11., 11:47; dein Wort „829 A, ein Zauberer zaubert und greift nicht an im Nahkampf“)
Kurz: Zaubert der Zauberlehrling, gewinnt er gegen das Rudel 9 von 10 Kämpfe, aber 85 % davon fliehen die Wölfe vor dem Feuer: kein Fell, keine Erfahrung.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/1269c28a1 (Zweig `claude/tuffy-705-zauberer`, Messung `tests/anspringen_702.gd`, `tests/sim444_870.gd`)

**Frage:** Seit 870c (3 A) flieht das Rudel vor Feuer, sobald der Leitwolf unter halbem Leben ist; dann gibt es weder Fell noch Erfahrung. Der Funkenpfeil des Zauberlehrlings ist Feuer. Soll der Autopilot das nutzen?

**Votum:** „705a A“ oder „705a B“.

**Berührt:** 705, 870c (Gegenwirkung Wolf), 829 A, 830 A (Lehrsatz Wolfssprung)

**Begründung:** Du willst, dass der Zauberer zaubert (829 A) und dass man grinden darf, aber nicht muss (Leitbild). A macht den Wolfskampf für den Zauberer sicher, aber wertlos; B lässt ihn Erfahrung holen, mit mehr Risiko.

**Sachverhalt:** (Held Stufe 1, Startfertigkeiten, Rudel aus Leitwolf und 1–2 Jungwölfen, 2 Heiltränke, ohne Söldner, je 300 Kämpfe, Regel 702 C)

| Zauberlehrling spielt | Siege Rudel | davon vertrieben | Siege Wolf allein |
|---|---|---|---|
| nur Stab | 25 % | – | 30 % |
| Stab, weicht dem Sprung aus | 67 % | – | 83 % |
| **A:** zaubert, Feuer auf den Leitwolf (heute gebaut) | 90 % | 85 % | 98 % |
| zaubert, Feuer auf den schwächsten Jungwolf (Autopilot vorher) | 68 % | 63 % | 98 % |
| **B:** Arkanpfeil (kein Feuer) auf den Leitwolf, Feuer erst unter halbem Leben | 60 % | 3 % | 91 % |

- Ziel aus 705 B war etwa 40 % ohne Ausweichen.
- Der Autopilot zielt jetzt mit Feuer und Waffe auf den Leitwolf (fällt er, flieht sein Gefolge). Davon haben auch alle anderen Herkünfte etwas: Rudel Stufe 1 Jägerkind 49 → 83 %, Kräutersammler 9 → 30 %, Herumtreiber 55 → 72 %, nahe an der Simulation 444 (88, 35, 80). Grimmzahn, Krogg, Grak bleiben gleich.

**Auswertung:**
- **A (gebaut):** Der Autopilot nimmt das sichere Mittel. Wer Fell und Erfahrung will, spielt von Hand mit dem Arkanpfeil. Stärkstes Gegenargument: Wer den Autopiloten laufen lässt, bekommt als Zauberer im Wald keine Erfahrung, ohne es zu merken.
- **B (Empfehlung):** Der Autopilot will Beute und nimmt Feuer nur in Not (unter halbem Leben). 60 % Siege, fast alle mit Erfahrung, nahe am Ziel 40 % aus 705 B. Stärkstes Gegenargument: 4 von 10 Kämpfen verloren, und der Zauberer hat das sichere Mittel in der Hand.

**Folgerungen:** Bei B baue ich den Autopiloten um (Zweig wie oben, etwa eine Stunde) und messe noch einmal; bei A bleibt alles, wie es ist. Danach geht der Zweig in den nächsten Sammelbuild von Team Jerry.

Antwort: …
