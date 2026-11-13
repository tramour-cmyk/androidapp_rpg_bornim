# 1100 · Soll Ford seinen Stundenlauf mit weniger Schritten und weniger Ausgabe machen?
Perikles · 13.11., 08:36 · B Abläufe · aus 1098 (Ford verbraucht 400 Tsd. Token in 3 bis 5 Stunden)
Kurz: Ford kostet gemessen etwa 0,90 $ je Stunde (rund 22 $ am Tag); fünf Änderungen am Lauf sparen geschätzt ein Drittel bis die Hälfte

Geprüft an: [Ford-Sitzung](https://claude.ai/code/session_01Hmoj78Qg516rLn1yGt11hL), Ereignisse der Läufe 07:04 und 08:04, Kosten bis 08:29), `tools/lauf.py` am Rechner (Ausgabe 6.853 Zeichen), `LISTE-BETRIEB.md` „Jeder Lauf“

**Frage:** Darf Perikles Fords Stundenlauf so umbauen, dass er weniger Schritte braucht und weniger liest? Es ist ein Vorentscheid-Fall, aber die Vorentscheid-Bremse steht, darum liegt es bei dir.

**Votum:** „1100 A“: alle fünf Änderungen; mit „1100 A ohne 5“ bleiben die Warnzeilen wie heute.

**Berührt:** 1100 (Perikles), Ford (Ablauf), 1098 (Neustart-Schwelle hängt am Starter), Diogenes (prüft danach Kosten je Lauf)

**Begründung:** Fords Sitzung wird nie kleiner: jeder Zug hängt 10 bis 21 Tsd. Token an, und jeder Schritt eines Zuges liest den ganzen Verlauf (heute 165 bis 240 Tsd.) noch einmal. Teuer sind also die Zahl der Schritte und die Länge des Verlaufs, weniger ein einzelner Befehl.

**Sachverhalt:**
- Kosten: 2,45 $ um 08:06, 3,01 $ um 08:29 für die Sitzung seit 05:09, also etwa 0,90 $ je Stunde; ein Zug kostet 0,26 bis 0,46 $.
- Lauf 08:04: 14 Schritte (bis zu 17 Werkzeugaufrufe), der Verlauf wuchs um 21 Tsd. Token. Lauf 07:04: 8 Schritte, plus 9 Tsd.
- Was Ausgabe macht: Sitzungsdaten von `get_session`, `list_sessions`, `create_session`, `archive_session` (je etwa 3.000 Zeichen); `lauf.py` (2.000 bis 3.700); Nachsehen in `LISTE-BETRIEB.md` und der Vorgangsliste mitten im Lauf (etwa 6.000); die Liste offener PRs jede Stunde (2.400); zwei- bis dreimal `git pull` je Lauf, einmal mit abgelehntem Push (1.000 Zeichen Fehlertext).
- `lauf.py` gibt heute 22 gleiche Warnzeilen „gebaut ohne Build“ aus (etwa 3.500 Zeichen), jede Stunde wieder.

**Auswertung:**
- **A (Empfehlung):**
  1. Ein Befehl statt drei: Kurzzeilen schreiben und `lauf.py` in einem Bash-Aufruf; `notiz.sh` entfällt im Lauf (`lauf.py` holt `main` selbst); pushen mit `git pull --no-rebase` und einem zweiten Versuch.
  2. Sitzungen nur über `list_sessions`; `get_session` nur, wenn eine Ausgabezeile es verlangt.
  3. Nichts nachschlagen im Lauf: was Ford tun soll, steht in der Ausgabezeile von `lauf.py`; fehlt etwas, Vorgang an Perikles statt Suche.
  4. Offene PRs nur einmal am Tag beim Nachhalten (Schritt 8), nicht stündlich.
  5. `lauf.py` zeigt gleiche Warnzeilen „gebaut ohne Build“ einmal am Tag ganz, sonst als eine Zeile „22 Zeilen gebaut ohne Build (abgleich.py zeigt sie)“.
  Geschätzt: Schritte je Lauf von 8 bis 14 auf 5 bis 7, Zuwachs je Lauf etwa ein Drittel kleiner; zusammen ein Drittel bis die Hälfte der Kosten, also 7 bis 11 $ am Tag. Kostet eine Perikles-Sitzung (etwa 4 $).
- **B:** nur die Neustart-Schwelle senken (250 statt 400 Tsd.): kleinerer Verlauf im Mittel, etwa 30 % weniger; braucht aber den Ford-Starter (1098), sonst sinkt die Tiefe noch schneller. Später zusätzlich zu A denkbar.
- **C:** nichts ändern; 22 $ am Tag für den Betrieb bleiben.
- **Stärkstes Gegenargument gegen A:** jede Änderung an Fords Lauf kann einen Start oder eine Warnung verschlucken, und Punkt 5 zeigt dir einen bekannten Rückstand seltener. Dagegen: die Zeilen verschwinden nicht, sie stehen täglich einmal ganz und stündlich als Zahl; Diogenes prüft die ersten Läufe danach.

**Folgerungen:** Bei A baut Perikles `LISTE-BETRIEB.md` „Jeder Lauf“ und `lauf.py` um, Ford bekommt die neue Fassung beim nächsten Lauf, Diogenes vergleicht Kosten und Schritte je Lauf vorher und nachher. Bei C bleibt 1100 liegen.

Antwort: …
