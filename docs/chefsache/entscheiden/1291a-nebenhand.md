# 1291a · Was darf der Held in die Nebenhand nehmen: nur Schild und Fackel, oder auch einen Dolch, der im Kampf als Parierdolch wirkt?
Tuffy · 16.11., 08:30 · E Kampf · aus Toms Fund 785.5, Auftrag Perikles 15.11., 13:05 („zuerst Vorlage, nicht nach eigenem Urteil bauen“)
Kurz: Eine Waffe in der Nebenhand tut heute nichts, weder im Kampf noch am Helden; Empfehlung: die Nebenhand nimmt nur noch Schild und Fackel.
Beim Chef, weil: neue Richtung im Spielgefühl (was der Spieler ausrüsten kann und was es im Kampf bewirkt)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/f386da1ee (`godot/kampf/aufruf.gd` 181, `godot/regeln/brs_held.gd` 417–456, `godot/skripte/menue.gd` 904, 1015, 1272, 1285, `godot/skripte/heldfigur.gd` 492, `godot/daten/werte.json` `welt.start`; alte Fassung `core/.../Hero.kt` 130–155, 198)

**Frage:** Im Ausrüstungsmenü kann der Spieler jede Einhandwaffe (Dolch, Kurzschwert, Streitkolben …) mit dem Knopf „Nebenhand“ in die linke Hand legen. Seit dem Umzug auf unser Regelwerk bewirkt das nichts: kein zweiter Schlag, keine bessere Abwehr, kein Abzug; am Helden in der Welt sieht man die Waffe auch nicht (dein Wort 04.11., 11:55 zu 522: „Streitkolben und Dolch angelegt, am Helden nichts“). Der Spieler glaubt, er habe etwas gewonnen, und hat nur den Schild abgelegt. Soll die Nebenhand künftig nur Schild und Fackel nehmen, oder soll ein Dolch dort eine echte Wirkung bekommen?

**Votum:** „1291a A“: die Nebenhand nimmt nur noch Schild und Fackel.

**Berührt:** 1291 (Team Jerry, Bau), 1380 (Homer: Stellung, Texte im Ausrüstungsmenü), 431h (Tom: was am Helden sichtbar ist, Nebenhand dann nur Schild und Fackel).

**Begründung:** Du hast am 10.11., 15:08 die Regeln für den Umzug beschlossen (870a 3 A, Wortlaut in `DESIGN-BRS.md`: „Extra-Angriff, Doppelzug, Zweiwaffenkampf entfallen“). Eine Waffe in der Nebenhand ist damit eine Wahl ohne Folge, also eine falsche Wahl; das Leitbild verlangt echte Wahl. Die Abwehr unseres Regelwerks kennt nur Schild, Ausweichen und Parieren mit der Waffe in der Hand.

**Sachverhalt:**
- Kampf: `aufruf.gd` 181 gibt die Nebenwaffe als „off“ ins Kampfblatt; gelesen hat sie nur der alte Würfelkampf (`klassisch.gd` 554, zweiter Schlag nach den alten Regeln), der nach 870a 2 A entfällt. Unser Kampfblatt (`mein_kampfblatt`) liest sie nicht.
- Auch kein Nachteil mehr: der Zweihandschaden „vielseitig“ hing an der leeren Nebenhand (`beide_haende_mit`), wird aber nirgends mehr gerufen.
- Welt: ein Dolch in der Nebenhand ist kein Schild und wird nicht gezeigt (`heldfigur.gd` 492, seit 522); in Innenräumen ohnehin ausgeblendet (1168).
- Start: keine Herkunft beginnt mit zwei Waffen (`werte.json` `welt.start`); eine Nebenwaffe entsteht nur, wenn der Spieler sie selbst dorthin legt.
- Alt: die Kotlin-Fassung hatte den Zweiwaffenkampf der alten Regeln (`Hero.kt` 155: Schlag der Nebenhand ohne Grundwert im Schaden); das ist der Teil, den 870a 3 A gestrichen hat.
- Unser Regelwerk: Parieren ist „halbe Fertigkeit der Nahkampfwaffe in der Hand“ (`DESIGN-BRS.md` 439), nur für die Haupthand beschrieben; der Pfad Duellant hat „Doppelschlag“ als eigene Fähigkeit (`DESIGN-BRS.md` 229), nicht als Grundregel.

**Auswertung:**
- **A (Empfehlung):** Nebenhand nur Schild und Fackel. Der Knopf „Nebenhand“ erscheint nur bei Schild und Fackel; Einhandwaffen gehen nur in die Haupthand. Liegt in einem Spielstand schon eine Waffe in der Nebenhand, kommt sie beim Laden in die Tasche, mit einer Zeile Meldung. Texte („Haupt- oder Nebenhand“) über Homer. Kein neues Modell, keine Bewegung. Aufwand etwa 3 $, ein Build, Prüfart: im Menü einen Dolch anfassen, kein Knopf „Nebenhand“.
- **B:** Dolch als Parierdolch: nur ein Dolch darf in die Nebenhand; im Nahkampf zählt dann als Abwehr auch die halbe Fertigkeit Dolche (wie Parieren mit der Haupthand), dafür kein Schildabzug. Echte Wahl für den Helden ohne Schild (Herumtreiber, Kräutersammler). Neue Regel, Zahlen erst mit der Rechnung 444, Dolch im Kampf in der linken Hand zeigen (Haltung, Paradebewegung, Bestand prüfen). Aufwand etwa 30 bis 50 $, großes Vorhaben (Gespräch vorher, 1236), mehrere Proben.
- **C:** Zweiwaffenkampf mit zweitem Schlag: widerspricht 870a 3 A, nur der Vollständigkeit halber.
- **Stärkstes Gegenargument gegen A:** der Spieler verliert eine Möglichkeit, und später (Duellant, Assassine) kommen zwei Klingen vielleicht doch; dann müsste die Nebenhand wieder Waffen nehmen. Dagegen: das wäre dann eine Fähigkeit des Pfads mit eigener Wirkung, die man zu diesem Zeitpunkt baut; heute ist es eine Wahl ohne Folge in Kapitel 1. B bleibt als Idee für diese Pfade (`LISTE-IDEEN.md`).

**Folgerungen:** A: Team Jerry baut 1291 (Menü, Laden, Kampfblatt ohne „off“), Homer liefert die Texte (1380), Tom nimmt in 431h nur Schild und Fackel für die Nebenhand. B: 1291 wartet auf „Chef Gespräch“, Jerry rechnet mit 444. Wortlaut ins Vorgangsarchiv, diese Datei weg.

Antwort: …
