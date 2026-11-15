# 481.2 · Soll der Deckel kommen, nach dem Rüstung und Schild höchstens die Hälfte eines Treffers abziehen?
Jerry · 15.11., 11:31 · G Balance · aus deinem „481a A“ (10:51)
Kurz: Mit Deckel 50 % tut fast jeder Biss etwas, und der Wachsoldat kann bei falschem Spiel verlieren; mit gutem Spiel gewinnt er weiter fast immer. Der Klosterschüler gewinnt ebenfalls immer, ihn berührt der Deckel nicht.
Beim Chef, weil: neue Richtung im Spielgefühl (Balance)

Geprüft an: `c4ef9b178` (Zweig `claude/jerry-481-2-deckel`, `tools/sim444/deckel_481_2.py`: je Fall 400 Kämpfe, gleicher Zufall für jeden Deckel; Gegenprobe über alle 96 Fälle mit `glut2.py --deckel`)

**Frage:** Du hast entschieden (481a A, 10:51), dass ich den Deckel rechne. Der Deckel heißt: Rüstung und Schild ziehen höchstens einen Teil des Treffers ab. Beispiel Wolfsbiss gegen den Wachsoldaten: Biss 5,7, Rüstung und Schild 5,5; heute bleibt 0, mit Deckel 50 % bleiben 2,85 (gerundet 3). Gerechnet habe ich 60, 50 und 40 %, für Helden und Gegner. Soll der Deckel mit 50 % gebaut werden?

**Votum:** „481.2 A“: Deckel 50 % bauen; dass der Klosterschüler nie verliert, getrennt rechnen (Vorgang an Jerry, Vorlage an dich).

**Berührt:** 481 (Herkünfte ausgleichen, Sokrates), 930.8 (Stufe 3 des Kerbensystems), `DESIGN-BRS.md` 4 (Abzug), `werte.json` (Simulation 444 und Spiel).

**Begründung:** Leitbild „Kampf nie langweilig, echte Wahl“. Ohne Deckel ist beim Wachsoldaten jede Spielweise gleich gut: er gewinnt immer, auch wenn er nur wartet. Mit Deckel zählt, wie er kämpft. Im Film 930.7 beißen die Wölfe ihn für 0; das verschwindet.

**Sachverhalt:** (Siege in Prozent; Spielweise „S“ = zuschlagen und Haltung nach der Ansage, wie die Bedienung vorschlägt; „W“ = nur warten und antworten; Deckel ohne / 60 / 50 / 40 %)
- **Wachsoldat, Held eine Stufe unter dem Gegner:**
  - Riesenfledermaus: S 100 / 100 / 98 / 97, W 100 / 82 / 53 / 30.
  - Wolf mit Goblin-Späher: S 100 / 99 / 92 / 86, W 100 / 95 / 85 / 69.
  - Krogg: S 99 / 99 / 98 / 92, W 97 / 94 / 91 / 83.
  - Grak, Skelett, Rudel: 97 bis 100 bei jedem Deckel.
- **Wachsoldat, gleiche Stufe:** mit S überall 99 bis 100; mit W gegen die Riesenfledermaus 100 / 100 / 97 / 87.
- **Bisse und Leben, Wachsoldat gleiche Stufe, ohne / 50 %:** Bisse des Rudels ohne Schaden 46 % → 4 %; nach dem Kampf gegen das Rudel bleiben 90 % → 79 % des Lebens, gegen Krogg 78 % → 64 %. Ganz verschwinden die Treffer ohne Schaden nicht (gegen Krogg 15 %): die kommen nicht von der Rüstung, der Klosterschüler hat sie ebenso (vermutlich ganz abgewehrte Ringe).
- **Klosterschüler, Schmiedelehrling, Kräutersammler:** bei jedem Deckel genau gleich (sie tragen zu wenig Rüstung, als dass der Deckel greift). Klosterschüler: 100 gegen jeden Gegner, auch eine Stufe drunter (einzige Ausnahme Wolf mit Goblin-Späher, 96).
- **Gegner:** auch die Rüstung der Gegner (etwa Skelett) wird vom Deckel nicht berührt; der Held trifft so hart, dass sie nie mehr als die Hälfte abzieht.
- Die Probe aus 930.5 „keine Spielweise in mehr als einem Viertel aller Fälle vorn“ bleibt mit jedem Deckel erfüllt.

**Auswertung:**
- **A (Empfehlung): Deckel 50 %.** Fast jeder Treffer tut etwas, der Wachsoldat verliert im Kampf merklich Leben, und wer schlecht spielt, kann jetzt verlieren (nur warten, eine Stufe unter der Fledermaus: 53 von 100). Die anderen Herkünfte bleiben unverändert. Bau klein (Schadensrechnung, `werte.json`, Kerntest), etwa 2 $.
- **B: Deckel 40 %.** Härter: auch mit gutem Spiel eine Stufe unter Krogg nur noch 92, mit Warten gegen die Fledermaus 30. Rüstung verliert viel Wert.
- **C: kein Deckel.** Wölfe beißen den Wachsoldaten weiter oft für 0, jede Spielweise gewinnt bei ihm.
- **Stärkstes Gegenargument gegen A:** Mit gutem Spiel gewinnt der Wachsoldat weiter fast immer; dein Anliegen „schwerer werden“ ist damit nur halb erfüllt, und der Klosterschüler bleibt unverlierbar. Antwort: Der Deckel trifft den Wachsoldaten genau dort, wo es fehlte (die Wahl zählt), und lässt alle anderen in Ruhe; der Klosterschüler hat eine andere Ursache und braucht einen eigenen Hebel.

**Folgerungen:** Bei A oder B baut Jerry den Deckel (Prüfart „ohne dich“: Kerntest) und legt einen Vorgang an „Klosterschüler gewinnt immer: Ursache rechnen“ (Jerry, Vorlage an dich). Bei C nur dieser Vorgang.

Antwort: …
