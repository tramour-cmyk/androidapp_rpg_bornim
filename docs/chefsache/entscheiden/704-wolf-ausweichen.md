# 704 · Ausweichen vor dem angekündigten Sprung kostet nichts: so lassen?
Tuffy (Team Jerry) · 09.11., 22:52 · E Kampf · aus Befund Tuffy zu 702 (08.11.)
Kurz: Der alte Befund „Wolf allein harmlos, 300 von 300“ gilt mit 702 C nicht mehr; Ausweichen bleibt aber immer richtig

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/4c9066b38/godot/tests/anspringen_702.gd

**Frage:** Seit 702 C (Build 272: angesprungen steht der Held auf und handelt gleich) ist der Wolf nicht mehr harmlos. Ausweichen vor einem angekündigten Sprung kostet aber nichts: der Held wechselt den Platz und schlägt im selben Zug zu. Soll das so bleiben?

**Votum:** „704 A“: so lassen, 704 schließen.

**Berührt:** 702, 702 C (Archiv 09.11., 06:56), 438 (Wolfsrudel), `DESIGN-LEITBILD.md` „echte Wahl“

**Begründung:** Im Spiel kommt der Wolf nie allein, immer mit ein oder zwei Jungwölfen (`aufruf.gd` rudel). Im Rudel entscheidet das Ausweichen beim Magier über Sieg oder Niederlage, ist also eine Belohnung fürs Hinsehen, kein Freibrief.

**Sachverhalt:** 300 Kämpfe je Zeile, Regeln wie im Spiel (SRD, 702 C), Held Stufe 1, 2 Heiltränke, ohne Söldner; der Rechenspieler greift jeden Zug an, „weicht“ wechselt vorher den Platz, wenn ein Sprung auf ihn angesagt ist (`godot/tests/anspringen_702.gd`).

| Klasse | Rudel, haut nur | Rudel, weicht aus | Wolf allein, weicht aus | Rudel, Ausweichen kostet den Angriff |
|---|---|---|---|---|
| Kämpfer | 85 % | 94 % | 96 % | 55 % |
| Magier | 18 % | 41 % | 75 % | 9 % |
| Schurke | 78 % | 91 % | 91 % | 56 % |
| Kleriker | 55 % | 76 % | 86 % | 31 % |

Siege in Prozent. Vor 702 C waren es mit Ausweichen gegen den Wolf allein 100 % in allen Klassen (der alte Befund). Mit BRS-Rechnung ähnlich (Kämpfer und Kleriker 100 % schon ohne Ausweichen).

**Auswertung:**
- **A (Empfehlung):** so lassen. Kosten: keine. Der Spieler, der die Ansage liest, gewinnt deutlich öfter; der Magier braucht es.
- **B:** Ausweichen kostet den Angriff in diesem Zug (letzte Spalte). Dann wird Ausweichen eine echte Abwägung, aber wer immer ausweicht, verliert fast alles, gegen den Wolf allein zieht sich der Kampf endlos (über 300 Züge). Bräuchte eine mildere Form (etwa Angriff mit Nachteil) und neue Messung.
- **Stärkstes Gegenargument gegen A:** Was nichts kostet, ist keine Wahl, sondern Pflicht; der Spieler weicht bald ohne Nachdenken aus. Weg: später mit B (milde Form) nachschärfen, wenn es sich im Test so anfühlt.

**Folgerungen:** A: 704 erledigt, nichts zu bauen. B: Vorgang an Jerry, mildere Kosten bauen und messen.

Antwort: …
