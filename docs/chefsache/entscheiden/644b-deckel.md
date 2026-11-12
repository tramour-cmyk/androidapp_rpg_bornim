# 644b · Fällt der Deckel trotz der Zahlen, und soll der Schutzwert seltener gewürfelt werden?
Tuffy · 12.11., 10:49 · E Kampf · aus deinem Wort 08:21 zu 644a („A mit Spanne, D, F“), Rechnung im Vorgang 644a.1
Kurz: Deckel weg wie entschieden; dazu würfelt der Schutzwert beim Fund wie die Grundwerte mit halbem Gewicht, sonst schlägt ein Drittel der Durchgänge von Schütze, Späher und Wanderer Krogg sicher (mindestens 95 % der Kämpfe)

Geprüft an: [d0307b2c6](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/d0307b2c6) (Zweig `claude/jerry-644a-stufe`), Rechnung `python3 tools/sim444/stufe644a.py --laeufe 1000 --kaempfe 1000 --durch 300 --je 200`

**Frage:** Du hast um 08:21 entschieden: „644a, A mit Spanne, D, F.“ Zu D (Deckel weg) stand in der Vorlage: „Vorher rechnet Jerry den schlimmsten Fall durch. Erst wenn der vertretbar ist, fällt der Deckel“, und: liegt der übliche Fall über +3 auf einem Grundwert, bekommst du die Zahlen. Die Rechnung ist fertig. Mit Ausrüstung allein trägt ein Held am Ende von Kapitel 1 üblich höchstens +3 auf seinem wichtigsten Grundwert; mit dem Wachsen durch Üben kommen Schütze und Späher auf +4, eins über der Grenze. Dazu zeigt die Rechnung: Ohne Deckel ist der Schutzwert der stärkere Hebel (der Schütze ohne Ausrüstung schlägt Krogg in 30 % der Kämpfe, mit +2 Gewandtheit in 51 %, mit +2 Schutzwert in 64 %). Soll der Deckel trotzdem fallen, und soll der Schutzwert seltener gewürfelt werden? (Die Buchstaben unten gelten nur für 644b.)

**Votum:** „644b A“: Deckel weg für Grundwerte und Schutzwert, wie entschieden; der Schutzwert würfelt beim Fund wie die Grundwerte mit halbem Gewicht.

**Berührt:** Vorgang 644a.1 (Jerry, gebaut bis auf den Deckel), Vorgang 644a.2 (Tom: Laden ohne Stücke mit Grundwert, Meldung „Grundwert gestiegen“), Vorgang 644.2 (Zahlen in der Simulation), Regelwerk Abschnitt 11 (Sokrates)

**Begründung:** Dein Wort vom 11.11., 21:01: „das, was ich trage, das habe ich. Bin ich grundsätzlich nicht für einen Deckel“ und, zu den Grundwerten: „dann darfst du halt nicht so viele Gegenstände geben, die irgendwelche Grundwerte erhöhen“. Für die Grundwerte ist das mit halbem Gewicht schon gebaut. Derselbe Weg beim Schutzwert hält die Regel „Stufe 4–6 doppelt“ ein und lässt Krogg einen Kampf, den man verlieren kann.

**Sachverhalt:**
- **Heute** (Build 278): Alle getragenen Stücke zusammen geben in Kapitel 1 höchstens +1 auf jeden Grundwert und +2 auf den Schutzwert (`werte.json` „deckel“). Im Zweig steht dieser Deckel noch unverändert.
- **Gebaut im Zweig** (Vorgang 644a.1, mit Vorgang 633 Bossbeute): Zusatzeigenschaften in der Spanne ihrer Stufe (Leben Stufe 1–3 +4 bis +6, Stufe 4–6 +8 bis +12 …; Schutzwert +1, ab Stufe 4 +2), Grundwerte würfeln beim Fund mit halbem Gewicht (an den Armen etwa Kraft 17 statt 25 %), Beute in der Stufe des stärksten Gegners (höchstens eine über dem Helden), Krogg, Grimmzahn und Grak lassen ihre Einzelstücke fallen, ein Grundwert wächst um 1 je 10 gewonnene Punkte der Waffen- oder Zauberfertigkeit. Das Wachsen durch Üben wirkt auch mit Deckel; es ist unten in jedem Weg mitgerechnet, auch bei „heute“.
- **Rechnung:** Durchgänge je Kampfstil bis Heldenstufe 6 (etwa 20 gewonnene Kämpfe), dazu Bosse, Truhen, Gaben und Einzelstücke von Kapitel 1. Je Durchgang legt der Held an jedem Platz ein Stück an, das seinem wichtigsten Grundwert und dem Schutzwert zusammen am meisten hilft, und kämpft damit 200-mal gegen jeden Boss (auf der Stufe des Bosses, Fertigkeiten wie am Kapitelende, ohne Tränke). 300 Durchgänge je Kampfstil.
- **Gegen Krogg** (Siegquote über alle Durchgänge; in Klammern: Anteil der Durchgänge, die mindestens 95 % der Kämpfe gewinnen):

  | Kampfstil | heute mit Deckel | A: Schutzwert halbes Gewicht | B: Deckel weg wie gebaut | C: Schutzwert je Stück immer +1 |
  | --- | --- | --- | --- | --- |
  | Schütze | 73 % (0 %) | 79 % (18 %) | 86 % (39 %) | 78 % (9 %) |
  | Späher | 64 % (0 %) | 73 % (12 %) | 83 % (30 %) | 73 % (2 %) |
  | Magier | 38 % (0 %) | 42 % (1 %) | 49 % (4 %) | 36 % (0 %) |
  | Wanderer (Einhänder ohne Schild) | 79 % (0 %) | 79 % (16 %) | 86 % (37 %) | 79 % (6 %) |

  Gegen Grimmzahn und Grak liegen diese vier heute bei 75 bis 95 %, unter A bei 74 bis 96 %, unter B bei 79 bis 98 %. Krieger und Heiler gewinnen gegen alle drei Bosse in jedem Weg fast immer.
- **Was ein Held trägt** (üblich, Median über die Durchgänge; höchster Wert in 300 Durchgängen): wichtigster Grundwert aus Ausrüstung und Üben bei Schütze und Späher +4 (höchstens +6 bis +8), Krieger und Wanderer +3 (höchstens +5 bis +6), Magier +1 (höchstens +3), Heiler +0 (höchstens +3). Schutzwert unter B üblich +2 wie heute (höchstens +6 bis +8), unter A +1 oder +2 (höchstens +5 bis +7), unter C +1 (höchstens +4 bis +5).

**Auswertung:**
- **A (Empfehlung): Deckel weg, Schutzwert mit halbem Gewicht.** Was am Stück steht, wirkt. Krogg wird für Schütze und Späher um 6 bis 9 Prozentpunkte leichter, für den Magier um 4, für den Wanderer gar nicht; etwa jeder sechste Durchgang von Schütze und Wanderer gewinnt ihn sicher. **Schlimmster Fall:** Der stärkste Durchgang unter A (Zusatzrechnung, 300 Durchgänge je Kampfstil, 2000 Kämpfe) trug beim Schütze Gewandtheit +6 und Schutzwert +5, beim Späher +5 und +6; beide schlagen Krogg damit in jedem Kampf, der Magier mit Verstand +2 und Schutzwert +5 in 97 %. Der denkbar schlimmste Fall (jeder Platz mit Schutzwert +2, zusammen +10 oder +12) schlägt jeden Boss sicher. Vertretbar finde ich das, weil es je Kampfstil einer von 300 Durchgängen war; in diesem einen Durchgang ist Krogg dann kein Hindernis mehr. Kosten: eine Zeile Code und eine Zahl (Gewicht je Zusatzeigenschaft statt nur für Grundwerte).
- **B: Deckel weg wie gebaut.** Ganz nach „A mit Spanne“ aus 644a, ohne neue Regel. Krogg wird um 7 bis 19 Prozentpunkte leichter; ein Drittel der Durchgänge von Schütze, Späher und Wanderer schlägt ihn sicher.
- **C: Schutzwert je Stück in Kapitel 1 immer +1.** Kappt die sicheren Durchgänge am stärksten (2 bis 9 %), aber der übliche Schutzwert fällt unter heute (+1 statt +2), der Magier verliert gegen Krogg leicht (36 statt 38 %), und es ist eine Ausnahme von „Stufe 4–6 doppelt“.
- **D: Deckel weg nur für Grundwerte, beim Schutzwert bleibt er (+2).** Sicher, aber am Stück steht wieder eine Zahl, die nicht wirkt; gegen dein Wort vom 11.11.
- **E: Deckel bleibt für alles.** Sicher, aber gegen dein Wort; die Spanne wirkt dann bei Grundwerten nicht.
- **Stärkstes Gegenargument gegen A:** A senkt den üblichen Schutzwert bei Heiler und Wanderer von +2 auf +1, also unter heute, und lässt trotzdem jeden sechsten Durchgang von Schütze und Wanderer Krogg sicher schlagen. Wer die Spitze kappen will, nimmt C; wer keine neue Regel will, B. Antwort: Bei A verliert kein Kampfstil gegen einen Boss mehr als 3 Prozentpunkte gegenüber heute (am meisten der Heiler gegen Grimmzahn, 94 statt 97 %), und die sicheren Durchgänge sind halb so häufig wie unter B.
- **Nebenbefund, nicht Teil der Frage:** Der Heiler wächst durch Üben bei Kraft statt bei Wille, weil er im Kampf meist mit dem Streitkolben schlägt (Wille 3 Punkte bis Stufe 6, Kraft 16). Rüstung, Ausweichen, Schild und die übrigen Fertigkeiten hängen noch an keinem Grundwert; das liegt als Vorgang 644a.5 bei Sokrates.

**Folgerungen:**
- Bei A: Jerry streicht den Deckel und setzt den Schutzwert auf halbes Gewicht; Sokrates trägt beides ins Regelwerk (Abschnitt 11). Es fährt im nächsten gemeinsamen Build mit Vorgang 644a.1.
- Bei B: Jerry streicht nur den Deckel. Bei C: Jerry streicht den Deckel und baut die Ausnahme beim Schutzwert. Bei D: Jerry streicht den Deckel nur für Grundwerte. Bei E: nichts.

<details><summary>Wachsen durch Üben</summary>

- Bis Heldenstufe 6 gewinnt die Hauptfertigkeit üblich 10 bis 12 Punkte (Krieger, Schütze, Wanderer 10, Späher 11, Magier 12). Bei 10 Punkten je Grundwert wächst der wichtigste Grundwert in 7 von 10 Durchgängen einmal, nie zweimal; beim Heiler fast nie (siehe Nebenbefund).
- Gezählt sind nur Waffengruppen und Schulen, weil nur sie im Regelwerk ihren Grundwert nennen. Mit Rüstung an Zähigkeit und Ausweichen an Gewandtheit kämen Schütze und Späher auf 16 bis 18 Punkte bei Gewandtheit, der Krieger auf 8 bei Zähigkeit.
</details>

**Stellungnahme Sokrates (12.11., 11:08):**
- **Stärkstes Gegenargument gegen A:** A behandelt das Anzeichen, nicht die Ursache. Der Schutzwert ist ohne Deckel nicht stärker, weil er zu oft fällt, sondern weil er je Stück mehr gibt: Grundwert immer +1, Schutzwert ab Stufe 4 +2 (Regelwerk 11, „Stufe 4–6 doppelt“), und +2 Schutzwert hilft dem Schützen mehr als +2 Gewandtheit (64 gegen 51 %). Halbes Gewicht macht diese Stücke nur seltener; wer eines findet, hat denselben Sprung. Und die Vorlage zielt auf die Spitze, während das größere Loch unten liegt: der Magier schlägt Krogg in keinem Weg in mehr als der Hälfte der Kämpfe (36 bis 49 %); das ist der Befund aus 952 und 984 (Zauberlehrling fällt zurück) und kommt durch keinen der fünf Wege in Ordnung.
- **Für A trotzdem, ehrlich:** die Ursache zu beheben hieße, den Schutzwert in Kapitel 1 nicht zu verdoppeln, also C, und C senkt den üblichen Schutzwert unter heute und schwächt den Magier weiter. A ist die mildeste Stellschraube, die dein Wort vom 11.11., 21:01 („dann darfst du halt nicht so viele Gegenstände geben“) schon vorsieht; beim Grundwert ist derselbe Weg gebaut.
- **Widerspruch zu Entschiedenem:** keiner bei A und B. C bricht „Stufe 4–6 doppelt“ (644a, Regelwerk 11); D und E brechen 644a D („Deckel weg“). Ob die Zahlen die Frage auslösen mussten: mit Ausrüstung allein liegt der übliche Fall bei +3, erst das Üben (644a F, gleichzeitig entschieden) hebt Schütze und Späher auf +4. Die Bedingung ist erfüllt, aber knapp und nur durch F; die Vorlage sagt das richtig.
- **Kosten:** A eine Zeile und eine Zahl bei Jerry, eine Zeile Regelwerk bei mir; B nichts; C eine Ausnahme in Code und Regelwerk. Die Frage selbst hält 644a.1 und 633 an (beide gebaut, warten auf den gemeinsamen Build): jeder Tag ohne Antwort ist ein Tag ohne Bossbeute im Test.
- **Empfehlung:** „644b A“, und den Magier gegen Krogg nicht über den Deckel, sondern als eigene Balancevorlage nachziehen (liegt bei mir, Zu 952 und 984).

Antwort: …
