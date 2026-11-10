# 709b · Wo soll der Wolf den Helden mit Schild beißen, wenn er unter dem Schild nicht durchkommt?
Jerry · 10.11., 17:00 · E Kampf · aus 709a A (dein Wort 14:22: „709a A“, tiefer Biss unter dem Schild)
Kurz: Unter dem Schild durch geht nicht, der Schild reicht bis 0,56 m herab; seitlich ins freie Bein, Schild beim Treffer beiseite oder Biss in den Schildrand?

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/claude/jerry-709a-tiefbiss (Entwurf `8bbafbcb6`, Messung `tests/treffen_709.gd` am Rechner, 10.11., 16:45–16:58)

**Frage:** Ich habe den tiefen Biss gebaut (Vorstoß aus „Attack“, Kopf gesenkt, Rumpf tiefer). Die Messung zeigt: Der Schild des Helden reicht bis 0,56 m über den Boden herab, der Schädel des Wolfs ist 0,26 m dick. Selbst mit der Kieferspitze auf Wadenhöhe (0,19–0,37 m) steckt der Schädel noch im Schild. Der Wolf kommt unter dem Schild nicht durch. Wie soll er den Helden sichtbar treffen?

**Votum:** „709b A“: seitlich am Schild vorbei, tief ins freie Bein (die Seite mit dem Schwert).

**Berührt:** 709 (Jerry), 406.2 B (Schild immer vorn, Chef 13:35), 595 (Bewegungen der gekauften Gegner)

**Begründung:** Ein Treffer zieht im MARS Leben ab; sichtbar ist er nur, wenn die Zähne den Körper erreichen. Dein Wort 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“.

**Sachverhalt:**
- Schild des Helden (Messung): Unterkante 0,56 m, Oberkante 1,54 m; Schädel des Wolfs im tiefen Biss 0,43–0,74 m hoch.
- Ratten (0,55 m hoch) laufen jetzt unter dem Schild durch und beißen alle ins Bein (gebaut, `dd74fc8d0`); Wölfe und Grimmzahn sind dafür zu groß.
- Seitlich treffen die Wölfe schon heute auf 0,05 m, wenn dort Platz ist; oft steht dort ein anderer Wolf oder der Platz liegt außerhalb des Bildes, dann schnappt der Wolf vor dem Schild (0,2–0,4 m Luft).

**Auswertung:**
- **A (Empfehlung):** tiefer Biss seitlich am Schild vorbei ins freie Bein; der Wolf sucht dafür zuerst die Schwertseite, auch weiter herum (bis 90°). Nur Lage im Kampfort, die Bewegung ist gebaut. Etwa eine halbe Sitzung.
- **B:** beim Treffer reißt der Biss den Schild kurz beiseite (der Held taumelt, Schild schwingt auf), dann fassen die Zähne Arm oder Bein; bei Abwehr bleibt der Schild vorn. Liest sich wie „Abwehr misslungen“, braucht aber eine neue Bewegung des Helden. Etwa eine Sitzung.
- **C:** Biss in den Schildrand mit Zerren (wie 709a B). Billig, aber der Held verliert Leben, obwohl der Schild hält.
- Stärkstes Gegenargument gegen A: Ist die Schwertseite besetzt (anderer Wolf, Bildrand), bleibt es beim Schnappen vor dem Schild; im Rudel kommt das vor. Dann bräuchte es zusätzlich B oder C als Ausweg.

**Folgerungen:** Bei A baue ich den seitlichen tiefen Biss und schicke dir einen Film mit Wölfen, Ratten, Krogg und Grak, bevor etwas in eine Testfassung kommt. Bei B baue ich zuerst die Bewegung des Helden. Bei C setze ich den Biss an den Schildrand.

Antwort: …
