# 406.1 · Schildring: die Simulation zeigt, dass der Schildträger mit Ring keinen Schaden mehr nimmt; was jetzt?
Jerry · 08.11., 07:35 · E Kampf

**Frage:** Du hast 406.1 A mit Bedingung entschieden (02.11.): „Bau erst, wenn 444 zeigt, dass der Schildträger in Kapitel 1 weiter Schaden nimmt.“ Die Simulation zeigt das Gegenteil. Bauen wir trotzdem, mit anderen Zahlen, oder warten wir?
**Votum Jerry: C, noch nicht bauen.** Erst den Abzug gegen den Schaden der Gegner richten (469, Kampf auf BRS), dann den Schildring mit denselben Zahlen neu messen.
**Berührt:** 406.1, 469, 478 (Rechenkern BRS), Simulation 444 (`tools/sim444`, Teil 7), Balance Kapitel 1.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/2b32b6742

## Begründung

Schon ohne Ring nimmt der Wachsoldat auf gleicher Stufe von 6 der 16 Nahkämpfer keinen Schaden, weil Rüstung und Schild mehr abziehen, als der Gegner trifft. Ein Block, der den Schaden halbiert, macht ihn gegen fast alle unverwundbar. Das liegt an den Zahlen des Abzugs, nicht an der Regel des Rings; dreht man nur am Ring, bleibt der Fehler darunter.

## Sachverhalt

Simulation 444, neuer Teil 7 (`sim.py --nur-schildring`), je Fall 1000 Kämpfe, Wachsoldat (Mittlere Rüstung, Rundschild) auf der Stufe des Gegners, Fertigkeiten aus dem Fortschritt; Ring „gut“ wie die Automatik: halber Schaden vor dem Abzug. Wie oft ein Gegner seinen Angriff ansagt, kennt die Simulation nicht; gerechnet mit einem Drittel und mit allen (Annahme).

| Gegner (Stufe) | ohne Ring: Schaden je Kampf | ⅓ angesagt | alle angesagt | alle, Block fängt ¼ statt ½ ab |
|---|---|---|---|---|
| Ratte, Kobold, Blutflügler (1), Wildschwein, Hundertfüßer, Zombie (2) | 0 | 0 | 0 | 0 |
| Wolf (2) | 2,2 (7 % der Leben) | 1,6 | 0 | 0,1 |
| Goblin, Skelett (2) | 0,5–0,9 | 0,3–0,6 | 0 | 0 |
| Riesenfledermaus (3) | 1,5 | 1,0 | 0 | 0 |
| Riesenspinne (4) | 10,9 (26 %) | 7,4 | 0 | 3,0 |
| Ghul (4), Ockerschleim (5) | 4,3–4,7 | 2,9–3,3 | 0 | 0–0,5 |
| Krogg (4), Grimmzahn (5), Grak (6) | 14–21 (30–49 %) | 9–14 | 0–0,9 | 3–7 |

Ringe je Kampf bei allen angesagten Angriffen: 2–10. Siegquote überall 99–100 %, mit und ohne Ring.

## Auswertung

- **Stärkstes Gegenargument:** Die Annahme „ein Drittel angesagt“ ist nah an heute (der Wolf sagt nur „Anspringen“ an); dann nimmt der Schildträger gegen 10 von 16 weiter Schaden, die Bedingung wäre dort erfüllt, und man könnte bauen.
- **Entkräftet:** Gegen die übrigen 6 nimmt er schon heute nichts, und sagen die Gegner öfter an (Goblins, neue Ansagen mit 478), wächst der Schutz mit. Sokrates' Richtwert war „nie 0 gegen einen Gegner seiner Stufe“; den verfehlen wir schon ohne Ring.
- **A, bauen wie entschieden:** Spieler mit Schild gewinnt einen Augenblick im Kampf, Kapitel 1 wird für ihn noch leichter.
- **B, bauen mit kleinerem Block** (fängt ¼ statt ½ ab): gegen Spinne und Bosse bleibt Schaden, gegen alle anderen kaum (Ghul 0,5, Wolf 0,1).
- **C, noch nicht:** 469 richtet Abzug und Schaden (BRS Modell D nimmt beim Block nur den Schild, die Simulation zieht Rüstung und Schild ab); danach misst Teil 7 neu, dann bauen.

## Folgerungen

- „C“: 406.1 wartet auf 469; ich nehme den Abzug in 469 mit auf und lege die Messung danach wieder vor.
- „B“: ich baue den Schildring mit Block ¼ (Schaden × 0,75), Ring nur bei angesagten Nahangriffen.
- „A“: ich baue wie entschieden.

Antwort: „406.1 A“, „B“ oder „C“.
