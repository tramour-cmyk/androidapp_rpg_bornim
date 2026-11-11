# 984 · Sollen Illusion und Beschwörung in Kapitel 1 gesperrt werden, und soll Jerry nach 952 messen, ob die Gewandtheit jeden Kampfstil trägt?
Sokrates · 11.11., 18:39 · E Kampf · aus deinem Wort 18:28 nach 952: „schon wieder was gefunden, was noch keiner bedacht hat, obwohl ja alle schon 50 Mal drüber gelesen habt“
Kurz: Jede Kampfregel gegen jeden Kampfstil gehalten (Tabelle „Querschnitt“ in `DESIGN-BRS.md` oben). Zwei Funde brauchen dich; einer ist mit 952 C schon gestellt.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/f189ebdcd (`tools/sim444/werte.json`, `godot/regeln/brs_kampf.gd` 124–137, `mars.gd` 2068–2090 und 2125–2131, `brs_held.gd` 183–192, `skripte/erschaffung_brs.gd` 67)

**Frage:** (1) Dürfen Illusion und Beschwörung in Kapitel 1 bei der Erschaffung gewählt werden, obwohl es dort keinen Zauber dafür gibt? (2) Reicht 952 C gegen die Ein-Wert-Stile, oder soll Jerry zuerst messen?

**Votum:** „984 A“: (1) Illusion und Beschwörung in Kapitel 1 nicht wählbar wie Bergbau; (2) erst 952 C, dann misst Jerry, ob die Gewandtheit noch jeden Stil trägt.

**Berührt:** Erschaffung (`werte.json` „nicht_waehlbar“, Tom), Simulation 444 (Jerry); Spieltexte nur, falls die Erschaffung einen Hinweis braucht (Homer).

**Begründung:** Regelwerk Abschnitt 3, Prüfregel: „Eine Fertigkeit gibt es nur, wenn sie eine Tätigkeit im Spiel hat, die sie übt, und eine Wirkung, die man merkt.“ Leitbild: echte Wahl, auch bei der Erschaffung.

**Sachverhalt:**
- **Fund 1, Illusion und Beschwörung:** In `werte.json` gibt es Zauber nur für Evokation, Schutzmagie und Heilmagie. Gesperrt bei der Wahl ist nur Bergbau (`nicht_waehlbar`, 461c). Ein Wanderer oder ein Mensch (Zusatzfertigkeit) kann Illusion oder Beschwörung wählen und hat dann eine Fertigkeit, die nie wirkt und nie wächst; die Truhe in der Blutzahnhöhle gibt ihm dafür trotzdem den Glutstab (`geschichte.gd` 33–35).
- **Fund 2, ein Grundwert trägt den ganzen Stil:**
  - Späher (Dolch): die Gewandtheit gibt Schaden, kritischen Treffer, Abwehr, Initiative und Flucht.
  - Magier und Heiler: der Wille gibt Schaden, Heilung, Mana und die Abwehrprobe gegen Furcht und Zauber; der Verstand zählt im Kampf nur ab 6 (Schwäche vorher sehen).
  - Krieger und Schütze brauchen je zwei Werte (Kraft und Gewandtheit, Gewandtheit und Wahrnehmung).
  - Die Gewandtheit zählt für **jeden** Stil (Abwehr, Initiative, Flucht, heute kritisch).
- **Fund 3, klein, ohne Frage:** Der Schild hebt die Abwehr nur, wenn die Schild-Fertigkeit über Ausweichen + 2 × Gewandtheit liegt. Wachsoldat (Schild 10, Gewandtheit 3): 10 gegen 6, der Schild hilft. Herumtreiber ohne Ausweichen-Fertigkeit (Gewandtheit 7): 14. Ein Abwehrpunkt ist ein halber Prozentpunkt Trefferchance, also wenig; der Schild wirkt vor allem über den Abzug. Ich beobachte das mit der Messung aus (2).
- **Fund 952** (schon gestellt): Zauber treffen nie kritisch, Waffen nur über die Gewandtheit.

**Auswertung:**
- **A (Empfehlung):** (1) sperren: eine Zeile in `werte.json`, wie bei Bergbau; ab Kapitel 2 frei, wenn es dort Zauber gibt; unter einer Stunde Tom mit Test. (2) erst 952 C: C nimmt dem Späher den kritischen Treffer (dann aus der Wahrnehmung) und gibt dem Magier den Verstand (kritisch). Danach rechnet Jerry mit 444 je Herkunft die Siegquote, wenn die 9 Punkte auf die Gewandtheit gehen, gegen die Punkte auf den Hauptwert; liegt die Gewandtheit in jedem Stil vorn, lege ich einen Vorschlag vor, sonst bleibt es. Etwa eine Sitzung Jerry.
- **B:** je ein Zauber für Illusion und Beschwörung in Kapitel 1: Name von Homer, Zahlen von Jerry, Bild und Klang dazu; mehrere Sitzungen und neue Effekte, also Neues gegen die oberste Direktive.
- **Stärkstes Gegenargument gegen A:** Wer einen Illusionisten spielen will, kann das in Kapitel 1 nicht. Antwort: Er könnte es auch heute nicht, er hätte nur eine leere Fertigkeit. Gegen das Ganze: noch eine Prüfrunde. Antwort: Die Tabelle bleibt im Regelwerk stehen; wer eine Kampfregel, Waffe oder Schule einführt, füllt seine Zeile, und ein leeres Feld fällt vor dem Bau auf.

**Folgerungen:** Nach „984 A“ sperrt Tom die beiden Schulen in `werte.json` (mit Test), Jerry misst nach 952 C, ich trage beides ins Regelwerk ein.

Antwort: …
