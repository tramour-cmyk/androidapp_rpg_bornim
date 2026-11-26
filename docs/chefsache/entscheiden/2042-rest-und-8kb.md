# 2042 · Sollen Warnungen in der Konsole des Disponenten bleiben, und fällt das 8-KB-Ziel für den Auftrag?
Sokrates · 26.11., 16:27 · B Werkzeuge · aus Prüfer-Nein Doris 16:24 (2042-Ü78)
Kurz: Fassung 5 fast fertig; zwei Punkte offen: Warnungen sichtbar lassen, 8-KB-Ziel aufgeben.
Beim Chef, weil: Obergrenze A (5. abgelehnter Auftrag, 2042-Ü80)

Geprüft an: claude/emil-2042 fd0eb367e3; Prüfung Doris 16:24 (docs/vorgang/archiv/2042.md)

**Frage:** Emil hat Fassung 5 gebaut: die Ausgabe von lauf.py schrumpft von 10.749 auf 2.960 Byte, der Rest geht in eine Datei; 2042.md von 66 auf 29 KB; Tests grün. Doris sagt zweimal nein: (1) Warnungen („WARNUNG“, „AUSGESCHLOSSEN“) wandern mit in die Datei, obwohl der Disponent sie heute melden muss (etwa: eine Sitzung wartet auf Freigabe). Dann sähe er sie nicht mehr. (2) Das Ziel „`vorgang.py auftrag 2042` unter 8 KB“ ist nicht erreichbar: der Auftrag allein hat 9.730 Byte (meist deine Worte im Wortlaut), jetzt 14.525 statt 22.922 Byte.

**Votum:** „2042 A“: Warnungen bleiben gekürzt in der Konsole; das 8-KB-Ziel fällt, gemessen wird nur noch die Startgröße des Disponenten (≤30 Tsd. Token je Stunde).

**Berührt:** 2042 (Emil, Werkzeug), Disponent, 2059 wartet auf 2042.

**Begründung:** Chef 13:56: „Muss der das alles lesen, um arbeiten zu können …? Wenn nein, ändert was.“ Warnungen muss er lesen, um zu handeln; der Auftragstext ist dein Wortlaut, den streicht niemand.

**Sachverhalt:**
- Prüfung Doris 16:24: Mangel 1 Warnungen im Rest; Haken, list_events eng, Tests: ja.
- Auftrag 15:32 9.730 Byte; Kosten Emil 8,16 $ von Deckel 15 $.

**Auswertung:**
- **A (Empfehlung):** Emil nimmt Warnungen in die Konsole (gekürzt, eine Zeile je Warnung), etwa 1–2 $; dann Prüfer, dann main.
- **B:** Warnungen bleiben im Rest, der Disponent liest sie nur bei der Zeile REST; spart Platz, aber eine wartende Sitzung kann untergehen.
- **Stärkstes Gegenargument gegen A:** Die Konsole wird wieder größer. Dagegen: Warnungen sind wenige Zeilen, die 2.960 Byte steigen kaum.

**Folgerungen:** Bei A: Sokrates schreibt Emil den Nachtrag, Prüfer prüft, Sokrates mischt nach main; 2059 startet danach.

Antwort: …
