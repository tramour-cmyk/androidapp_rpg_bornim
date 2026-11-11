# 903 · Probe Checkliste „Build und Test“ ist durch: bleibt sie, und kommen weitere Listen oder die eine Seite?
Perikles · 11.11., 07:36 · B Abläufe · aus 657 D (dein Wort 09.11., 11:46: „657 D“), Auswertung Diogenes Lauf 152
Kurz: Nach der Liste fand der Chef in vier Builds 11 neue Fehler statt 34; ich rate, die Liste fest zu behalten und weitere Listen und die Seite bis nach dem Umzug aufs BRS ruhen zu lassen.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/6b890b6e4 (Prüfbericht Lauf 152, Diogenes; dazu `tools/commit-pruefung.py` Zeile 148, `CHECK_BIS = 275`)

**Frage:** Seit dem 09.11. zeigt die Commit-Prüfung jedem Team vor einer Testbitte die Checkliste „Build und Test“ (`LISTE-CHECK-BUILD-TEST.md`, alle Regeln zu Build und Test an einem Ort). Das war eine Probe über vier Builds (t272–t275); danach solltest du entscheiden, ob weitere solche Listen folgen (Vorlage an den Chef, Aussehen, Texte, Kauf) und ob `CLAUDE.md` zur einen kurzen Seite wird. Die Probe ist abgelaufen: ab Build 276 zeigt die Commit-Prüfung die Liste nicht mehr, bis du entscheidest.

**Votum:** „903 A“: Liste bleibt fest; weitere Listen und die Seite noch nicht, erneut vorlegen nach dem Umzug aufs BRS (870).

**Berührt:** 657 (Probe), 866 (Prüfliste nur gegengelesen), 620 (Lagebild Sokrates), `tools/commit-pruefung.py`, Kopf von `LISTE-CHECK-BUILD-TEST.md`; Perikles baut

**Begründung:** Du wolltest kein großes Umstellen auf Hoffnung hin (09.11., 11:40: „jetzt das einfach umzustellen in der Hoffnung, dass es dann besser wird und danach klappen die einfachsten Dinge nicht mehr, das wäre ganz schlecht“). Die Probe ging gut aus, aber woran es lag, ist nicht geklärt; dazu gilt „Kampf zuerst“ (08.11.) und die oberste Direktive „wenig in Abläufe“.

**Sachverhalt:**
- Was du als Erster gefunden hast, vier Builds mit Liste gegen vier ohne (Diogenes Lauf 152):

| | ohne Liste (t266, t268, t269, t270) | mit Liste (t272, t273, t274, t275) |
|---|---|---|
| neue Vorgänge aus deinem Test | 11, 11, 9 oder 10, 3 (34 oder 35) | 0, 2, 9, 0 (11) |
| durchgefallene oder nicht prüfbare Prüfzeilen | nur t269, t270: 9, 7 (16) | 0, 7, 4, 0 (11) |
| Wiederholfunde (Sokrates 620) | t268–t270: 6, 6, 7 | 1, 4, 3, 2 |

- Die Zahlen aus 657 D (11, 11, 9, 7) mischten zwei Maße; nach beiden Maßen liegt die Probe besser.
- Nicht geklärt (Diogenes, „Nicht geprüft“): die Ursache. In derselben Zeit kamen dazu: Prüflisten nur noch gegengelesen (866, ab 10.11.), Gegenlesen durch Sokrates (620), kleinere Builds (t272: 10 Zeilen, t275: 14 gegen 28 bei t269). t273 hatte trotz Liste 6 nicht prüfbare Zeilen.
- Die Liste kostet beim Start nichts; die Commit-Prüfung zeigt sie nur beim Anlegen einer Testbitte (`commit-pruefung.py` 323–329).

**Auswertung:**
- **A (Empfehlung):** Liste fest behalten (Ablauf in der Commit-Prüfung streichen); keine weitere Liste, keine Seite, bis der Umzug aufs BRS (870) durch ist, dann neu vorlegen. Kosten: wenige Minuten. Bleibt die Wirkung, sehen wir es in den nächsten Builds ohne Zusatzaufwand.
- **B:** wie A, dazu sofort die zweite Liste „Vorlage an den Chef“ (Bild, Film, Chefsache, Antwort ins Archiv) als Probe über vier Builds. Kosten: etwa eine Sitzung Perikles, eine Prüfung Diogenes. Nachteil: während des Umzugs ist jeder Build groß und ungewöhnlich, die Wirkung wäre wieder nicht zuzuordnen.
- **C:** „657 C“ ganz: eine Seite für alle plus etwa sechs Listen in vier Schritten (Sokrates 09.11.). Kosten: drei bis fünf Sitzungen, Abläufe statt Spiel mitten im Umzug.
- **D:** Liste zurücknehmen, alter Zustand. Kein Grund nach den Zahlen.
- **Stärkstes Gegenargument gegen A:** jede Woche liest jede Sitzung beim Start weiter etwa 75 KB Regeln; das kostet Guthaben und Aufmerksamkeit, und ohne Termin schiebt man die Seite ewig. Antwort: der Wiedervorlagetermin ist an 870 gebunden, nicht offen; und die Seite war der Teil, bei dem du Verluste befürchtet hast.

**Folgerungen:** Bei A streiche ich das Enddatum (die Liste erscheint wieder ab t276), trage im Vorgangsarchiv ein und lege Wiedervorlage „Seite und weitere Listen“ als Vorgang an, der auf 870 wartet. Bei B zusätzlich die zweite Liste, Probe bis zum vierten Build danach, Diogenes zählt. Bei C lege ich einen Plan in vier Schritten vor, bevor etwas umgestellt wird.

Antwort: …
