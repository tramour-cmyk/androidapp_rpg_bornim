# 344 · Fackel: wann sie brennt, was sie im Kampf kann · Sokrates · 23.10., 16:06
E Welt

**Frage** (Chef 16:05): Die Fackel soll nur in Innenräumen aus sein, in denen Menschen sind (Häuser, Tempel). Draußen, in Höhlen und Dungeons, also überall, wo Gegner unterwegs sind, brennt sie immer, egal zu welcher Uhrzeit. Kann man mit der Fackel angreifen und verteidigen? Was sagen die Regeln, welche Würfel gelten? Kann ein Getroffener Feuer fangen?

**Befund:**
- *Heute (255, Chef 20.10.):* Die Fackel brennt nur, wo es dunkel ist: draußen nachts und in der Höhle. In hellen Grundrissen und draußen am Tag ist sie gelöscht. „Draußen am Tag aus“ war ein Vorschlag von Sokrates; du hattest nur nach Wohnräumen gefragt („Brandgefahr“).
- *Im Spiel:* Die Fackel sitzt in der Nebenhand, also statt eines Schildes. Im Dunkeln (Nacht draußen, Höhle) erweitert sie die Sicht von 4,2 auf 6,5 Felder, am Tag ändert sie nichts. Sie brennt im Spiel unbegrenzt. Im Kampf tut sie nichts. Einen Zustand „Brennen“ gibt es im Kampf schon (`Status.BURN`).
- *Regeln (SRD 5.1, Ausrüstung „Fackel“):* brennt 1 Stunde, helles Licht 20 Fuß, dämmriges weitere 20 Fuß. Wer mit einer brennenden Fackel im Nahkampf trifft, macht **1 Feuerschaden**, und zwar statt des 1W4 einer improvisierten Waffe, nicht zusätzlich. Ohne Übungsbonus. Verteidigen kann man mit ihr nicht, sie ist kein Schild. In Brand setzen sieht die SRD bei der Fackel nicht vor.

**Empfehlung:**
1. **Brennt überall außer in hellen Grundrissen** (Häuser, Schänke, Laden, Tempel), wie du es sagst. Dunkle Grundrisse wie ein Keller zählen wie die Höhle. Das behebt nebenbei die Fehlerquelle von 343: Das An und Aus nach der Uhrzeit fällt weg, und damit das Neuzeichnen des Helden beim Tageswechsel.
2. **Im Kampf nach SRD:** Ein Treffer mit der Waffe in der Haupthand bleibt, wie er ist. Neu ist eine Aktion „Fackel stoßen“: 1 Feuerschaden nach SRD, ohne Übungsbonus. Dazu als Hausregel: Tiere scheuen Feuer (Vorbild Garrick im Wald, dort heute nur ein fester Ort auf der Karte); ein getroffenes Tier weicht einen Platz zurück. Kein Anzünden des Gegners: Das hätte den Zustand „Brennen“ schon, aber es macht die Fackel stärker als jede Waffe der ersten Stufe.
   **Chef 16:12 (Hausregel, genauer):** Im Kampf zwei Wahlen, „ich vermöbel dich oder ich versuche dich mit dem Feuer zu verscheuchen“: Fäuste oder Fackel. Die Fackel macht Feuerschaden, und das Ziel (Tier, auch Skelett o. ä.) flieht vielleicht; dafür wird eine Fluchtwahrscheinlichkeit geprüft. Angeboten in MARS und im klassischen Kampf. Dazu muss die Fackel im Kampf brennen (folgt aus 1). Vorschlag Sokrates für die Prüfung: Rettungswurf Weisheit gegen SG 10; misslingt er, ist das Ziel bis zu seinem nächsten Zug verängstigt (SRD-Zustand) und weicht zurück. Welche Gegner Feuer scheuen, legen Homer und Jerry fest (Untote nicht von selbst: Skelette sind nach SRD nicht feuerempfindlich).
   Chef 16:12: In MARS spielt die eigene Ausrüstung heute keine Rolle (fest: zwei Heiltränke, Armbrust, Schwert). Die Fackel in MARS setzt also voraus, dass MARS die eigene Ausrüstung übernimmt; das gehört zu MARS als wählbare Alternative (296.2, 338 e) und fehlte bisher in `LISTE-MARS.md`.
   Chef 16:10: Mit Zweihänder keine Fackel? Ja, so ist es heute schon: Wer einen Zweihänder anlegt, legt Fackel oder Schild ab (`Hero.equip`; SRD: zweihändig heißt beide Hände beim Angriff). Ohne Waffe kämpft der Held heute mit den Fäusten (SRD: 1 + Stärke-Modifikator Wucht), die Fackel tut nichts. Mit 2 kämpft er dann mit der Fackel.
3. Die Wahl, die dabei entsteht, ist gut fürs Spiel (Leitbild „echte Wahl“): Schild für die Abwehr oder Fackel für Licht und gegen Tiere.

**Stärkstes Gegenargument:**
- Zu 1: Wer zündet am Mittag eine Fackel an? Am Tag bringt sie keine Sicht, nur Flamme. Das ist aber Stimmung, kein Fehler; einen Wert dafür gibt es nicht.
- Zu 2: Eine Kampfaktion ist Neues, also nach dem 15.11. nur, wenn sie vorher fertig ist (338). 1 Schaden ist schwach; ihr Wert liegt im Zurückdrängen der Tiere, und das ist Hausregel, nicht SRD.

**Kosten:** 1 klein, Tom (Regel in `Light.burns`, eine Zeile, Kerntest). 2 mittel, Jerry (MARS und klassisch), Text Homer.

**Berührt:** 255, 343, 84.1, 338; Tom, Jerry, Homer.

**Was du sagen sollst:** „344 ja“ (1 jetzt, 2 nach dem Marktstart), „344 nur 1“, oder anders.
