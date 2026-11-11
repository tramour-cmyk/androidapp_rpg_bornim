# 930a · Sollen die übrigen Gegner nach einem Tod stehen bleiben, statt sich neu aufzustellen?
Sokrates · 11.11., 14:00 · E Kampf · aus 930 (Handgemenge), dein Wort 13:57
Kurz: Heute rücken die übrigen Wölfe nach jedem Tod auf neue Plätze. Vorschlag: Sie bleiben stehen, wo sie sind, und bewegen sich nur noch, wenn ihr eigener Zug einen Grund dafür liefert.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9a34fec2a

**Frage:** Du hast um 13:57 gesagt: „gegen 3 Wölfe … dann stirbt einer … Die müssen nicht zwangsweise hintereinander stehen … vielleicht will ja einer den Verletzten schützen … wenn es dann einer ist, der muss dann auch nicht automatisiert wieder in die Mitte rücken … unnötige Bewegungen … kann man sich sparen einfach.“ Das widerspricht Regel F3 („Angriff, Treffer, Tod, Neuformation“). Die hast du am 31.10. selbst entschieden (439). Soll F3 geändert werden?
- **A:** F3 lautet dann „Angriff, Treffer, Tod; die Übrigen bleiben stehen“. Eine Figur bewegt sich nur noch aus einem dieser Gründe: Angriff, Platztausch oder Flucht im eigenen Zug, Ausweichen vor einem Angriff (F5) oder Weichen beim Platztausch (F9).
- **B:** F3 bleibt, wie es ist.

**Votum:** „930a A“.

**Berührt:** F3, F5, F7, F8, F9 (`DESIGN-KAMPF.md`), 930 (Abstand), 784 (Sollbild Rudel).

**Begründung:**
- Das Nachrücken nach einem Tod wirkt wie auf einer Schiene, und Schienenbahnen verbietet F7.
- F8 erlaubt das Zurechtrücken im eigenen Zug. Mit A entfällt es nach einem Tod ganz.
- Das Nachrücken kostet Zeit und entscheidet im Kampf nichts. Nach den Regeln ändert ein Tod die Plätze ohnehin nicht, das Nachrücken passiert nur im Bild.

**Sachverhalt:**
- **Nach den Regeln** bleibt jeder Gegner auf seinem Platz. Einen Platz ändern nur ein Platztausch oder ein Sprung von hinten nach vorn (`godot/regeln/mars.gd` 1205–1207 und 1856–1860, Zweig `claude/tom-870-4-held`). Bei einem Tod setzt der Code keinen Platz neu. Ist die vordere Reihe leer, trifft der Nahkampf die hintere (`mars.gd` 939–945).
- **Im Bild** hängt die Stelle davon ab, wie viele Gegner noch stehen, etwa „allein vorn“, „allein hinten“ oder „Paar hinten“ (`godot/kampf/kampfort.gd` 807–832).
  - Stirbt einer, rechnet das Bild die Stellen neu, und die Übrigen gehen dorthin (`kampfort.gd` 1198–1206). Das ist die Neuformation.
  - Hat der Held getötet, gehen sie erst zu Beginn ihres nächsten Zugs los (`kampfort.gd` 1073–1078, 1209–1211). Darum siehst du nach deinem Treffer zuerst Stillstand und dann ein Nachrücken.

**Auswertung:**
- **A (Empfehlung):**
  - Weniger Bewegung, kürzere Runden (F9). Das Rudel wirkt wie Tiere, nicht wie eine Reihe Spielsteine.
  - Bauen würde Jerry: Beim Tod werden die Stellen festgehalten statt neu gerechnet. Dazu kommt ein Test „nach einem Tod keine Bewegung ohne Grund“. Aufwand etwa 1 Stunde (meine Schätzung, Jerry prüft sie).
  - Gebaut wird nach dem laufenden Umzugsbuild B1, damit er nicht noch einmal aufgeht.
- **B:** Kein Aufwand. Das Rudel steht immer ordentlich da, wirkt dafür aber steif.
- **Stärkstes Gegenargument gegen A:** Steht vorn keiner mehr, bleibt ein Wolf hinten stehen. Der Held läuft dann weiter zu ihm hin, und das Bild ist weniger aufgeräumt.
  - **Weg:** Genau das ist der Abstand, den du in 930 willst: Wer hinten steht, ist weiter weg.
  - Der Held geht trotzdem nach F9 hin und zurück. Ob die Runde dabei höchstens 14,6 s dauert, misst der Test `sollbild_784`.
  - Einen verletzten Wolf schützen („will … den Verletzten schützen“) wäre eine neue Absicht der Gegner. Das kommt als Idee in 930 und wird jetzt nicht gebaut.

**Folgerungen:**
- Mit A trage ich F3 neu in `DESIGN-KAMPF.md` ein. Jerry bekommt einen Vorgang „nach B1“.
- Mit B bleibt alles, wie es ist.

Antwort: …
