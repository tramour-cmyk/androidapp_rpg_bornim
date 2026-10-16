# Tom · 0.1.806 · Bram schubsen · [PR #96](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/96)

Tom · 16.10., 20:22 · beliebig vor oder nach Jerrys Testreihe (`jerry-testreihe.md`), lässt sich über alle bisherigen Builds installieren.

Kurz: Dauerlaufen gegen Dorfleute schiebt sie zur Seite (Test 0.1.791 nicht bestanden, Ursache behoben)

**Zu tun:** installieren, Punkte prüfen, je Punkt „92.1 passt“ oder „92.1 nicht, weil …“ schreiben.

APK: **0.1.806**: [Lauf 806](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38946470050) → „Artifacts“ (grün).

Ursache: Beim freien Laufen zählte das Anlaufen nur gegen Monster, Sperren und Türen, nie gegen Dorfleute.

| # | Wo und wie | Richtig | Falsch |
|---|---|---|---|
| 92.1 | Dorf, Brücke, früh am Morgen (Testmenü Uhrzeit auf etwa 6 Uhr): Bram steht auf dem Weg an der Brücke; von Norden mit dem Steuerkreuz dauerhaft gegen ihn laufen | nach etwa einer halben Sekunde tritt Bram zur Seite (oder tauscht mit dir den Platz), du läufst ohne Ruck weiter; er geht nach ein paar Sekunden seiner Wege | nichts bewegt sich; oder der Held springt sichtbar |
| 92.2 | wie 92.1, aber nur einmal kurz antippen und vor ihm stehen bleiben, dann „Sprechen“ | Bram bleibt stehen, Gespräch geht wie bisher | Bram weicht schon beim ersten Antippen aus |
| 92.3 | irgendeinen anderen Dorfbewohner unterwegs anlaufen; eine Wache auf ihrer Runde anlaufen | Dorfbewohner weicht; Wache bleibt stehen | Wache weicht aus |
