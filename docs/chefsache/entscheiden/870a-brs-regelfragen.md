# 870a · Wie sollen die sieben offenen Regelfragen des BRS-Umzugs gelten?
Sokrates · 10.11., 14:45 · E Kampf · aus deinem Wort 14:03, 14:08 (Master-Umzugsplan)
Kurz: sieben Fragen, je mit Votum; ohne sie bauen Tom und Jerry Schritt 4–7 des Plans auf Vermutung

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/dcc60878f (drei Bestandsaufnahmen im Godot-Code, 10.11., 14:33–14:41; Plan `LISTE-UMZUG-BRS.md`)

**Frage:** Der Plan ist fertig ([`LISTE-UMZUG-BRS.md`](../../LISTE-UMZUG-BRS.md)). Sieben Punkte regelt das BRS noch nicht oder du hast sie anders entschieden, als der Umzug es braucht. Wie sollen sie gelten?

**Votum:** „870a 1A 2A 3A 4A 5A 6A 7A“

**Berührt:** Tom, Jerry (Bau Schritt 4–8), Homer (Texte zu 3, 6), Perikles (Projektplan 2.3, 2.17), 534, 467, 469, 644, 649, 212, 481, 508

**Begründung:** Dein Wort 14:08: „soll jetzt schon Hand und Fuß haben“. Und eine Berichtigung meiner Vorlage 870 (14:05): Dort stand, Erschaffung und Kampf seien schon BRS. Im Spiel stimmt das nicht. „Neues Spiel“ öffnet die alte Erschaffung mit Klasse und Punktkauf. Der Kampf rechnet nur mit einem versteckten Testschalter nach BRS, und auch dann laufen Initiative, Flucht, Rettungswürfe, die meisten Zauber und alle Klassenfähigkeiten mit W20 weiter. Der Umzug ist darum größer, als ich gesagt habe: etwa 17–24 Entwicklersitzungen, realistisch 120–200 $, zwei Testbuilds für dich (Plan, Abschnitt 3).

**Sachverhalt:** Bestand je Stelle im Plan, Abschnitt 1 und 4; je Frage unten der Kern.

**Auswertung:**

**1. Alte Spielstände.** Heute steht in jedem Spielstand nur der SRD-Held (Klasse, Stärke bis Charisma, Zauberpunkte). Einen BRS-Helden kann man daraus nicht verlässlich zurückrechnen; die Herkunft fehlt ganz.
- **A (Empfehlung):** Alte Spielstände laden nicht mehr. Die Karte zeigt „Aus der alten Regelfassung, nicht mehr spielbar“ mit Löschen. Das Spiel ist nicht veröffentlicht, betroffen sind nur deine Testspielstände; das Testmenü erzeugt Helden jeder Herkunft auf Stufe 1–6.
- **B:** Umrechnen: Ort, Quests, Gold, Beutel bleiben, der Held wird neu erschaffen und an der alten Stelle eingesetzt. Etwa eine Sitzung mehr, und jede alte Feldart muss bedacht werden.
- **Stärkstes Gegenargument gegen A:** Du verlierst deinen Durchspielstand. Antwort: Wer mit dem neuen System durchspielen soll, muss ohnehin neu erschaffen; B ist nachrüstbar, falls du es vermisst.

**2. Klassischer Kampf (212 A, 19.10.: beide Kampfsysteme bleiben, der Spieler wählt; „der klassische Kampf behält die Regeln aus Kapitel 1“).** In Godot gibt es den klassischen Kampf nicht als Spielmodus; `klassisch.gd` ist nur Rechenkern für einen Test. Er ist SRD durch und durch. Meine Vorlage 870 sagte „klassischer Modus weg“, ohne 212 A zu nennen; das hole ich hiermit nach.
- **A (Empfehlung):** 212 A ruht als Idee. `klassisch.gd` wird gelöscht. Wenn je ein zweiter Kampfmodus kommt, dann auf BRS-Regeln. Projektplan 2.3 heißt dann nur „MARS auf den Regeln des BRS“.
- **B:** Klassischen Kampf in Godot neu bauen, auf BRS. Mehrere Sitzungen für etwas, das heute keiner spielt.
- **Stärkstes Gegenargument gegen A:** Du wolltest zwei Zielgruppen bedienen. Antwort: Das gilt weiter als Idee; erst muss eines rund sein.

**3. Fähigkeiten ohne Klassen in Kapitel 1.** Heute bringen die Klassen Fähigkeiten in den Kampf: Zweiter Atem, Tatendrang, Finte, Hinterhältiger Angriff, Extra-Angriff, Decken, Lebensraub, Untote vertreiben, „perfekte Antwort“ je Klasse, dazu Zauber. Das BRS gibt Fähigkeiten nur über den Pfad, und den gibt es erst ab Kapitel 2 (Weihe). Ohne Regel hätte der Held in Kapitel 1 nur Angriff, Zauber und Tränke.
- **A (Empfehlung):** Kampfhandlungen hängen an Fertigkeiten, nicht an Klassen. Für alle: **Kraft schöpfen** (einmal je Kampf, Leben zurück). Mit **Rang Geselle** einer Fertigkeit kommt eine Handlung dazu, etwa Einhänder: Finte; Schild: Decken; Dolche: Stich aus dem Hinterhalt; Zweihänder: Wuchtschlag; Bogen: Zielschuss. Zauber nach Schule: Evokation Funkenpfeil (Anfänger), Flammenfächer (Geselle); Schutzmagie Bannschild, Arkanhaut; Heilmagie Wundsegen, Beistand; gegen Untote wirkt Gleißstrahl. Entfallen ganz: Extra-Angriff, Tatendrang/Doppelzug, Zweiwaffenkampf; Riposte bleibt dem Pfad Duellant (E 75). Liste und Zahlen setzt Jerry mit 444 auf, Namen Homer; Projektplan 2.17 zählt danach diese Liste. Das ist genau „du wirst, was du tust“: wer Schild übt, kann decken.
- **B:** In Kapitel 1 keine Handlungen außer Angriff, Zauber und Tränken; alles kommt erst mit dem Pfad. Einfacher, aber der Kampf wird eintönig, gegen das Leitbild („Kampf nie langweilig, echte Wahl“).
- **Deine Idee (14:09–14:14, als Idee, nicht dringend):** „ein Kleriker sollte das halt können“; Weihwasser wie im Witcher, drei Schluck, Wirkung nach der Stufe; „allgemein gültig“ auch für Zweihänder, Einhänder. Das passt in A: Weihwasser als Kampftrank (wie Steinhaut, 481), Wirkung nach Heilmagie statt nach Klasse, für jeden kaufbar. **Gegenargument:** Jede Handlung „für alle“ verwässert, was eine Fertigkeit besonders macht; darum in A an den Rang gebunden. Ich lege es als Idee in `LISTE-IDEEN.md`, Homer urteilt sonntags.
- **Stärkstes Gegenargument gegen A:** Neue Handlungen sind Balance, und Kapitel 1 wurde mit den alten gemessen. Antwort: gemessen wird ohnehin neu (444, Plan Schritt 5), und die Liste ist klein (etwa zehn).

**4. Wachsen die Grundwerte in Kapitel 1?** Im SRD gab es Attributspunkte bei Stufe 4. Das BRS lässt offen, wie Grundwerte wachsen (`DESIGN-BRS.md` 13).
- **A (Empfehlung):** In Kapitel 1 wachsen sie nicht; Fertigkeiten und Heldenstufe tragen den Fortschritt. Die Regel dafür kommt vor Kapitel 2.
- **B:** +1 frei bei Stufe 4, wie bisher. Ein Rest SRD-Denken, und er muss vor Kapitel 2 ohnehin neu geregelt werden.
- **Stärkstes Gegenargument gegen A:** Der Spieler verliert einen gewohnten Aufstiegsmoment. Antwort: Stufe 4 bringt weiter Leben und Kampfkraft, dazu die Fertigkeitsaufstiege mit Hinweis.

**5. Proben ohne W20 (Initiative, Flucht, Abwehr gegen Gift, Furcht, Zauber).** Heute alles W20 mit Rettungswurf und Übungsbonus.
- **A (Empfehlung):** wie die Trefferchance im BRS eine Prozentzahl: Initiative nach Gewandtheit mit kleiner Streuung; Flucht nach Gewandtheit gegen den schnellsten Gegner; **Abwehrprobe** (Name aus `DESIGN-BRS.md` 12) mit dem passenden Grundwert: Zähigkeit gegen Gift und Krankheit, Wille gegen Furcht und Zauber, Gewandtheit gegen Flächen. Zahlen aus 444.
- **B:** einen neuen Würfel einführen (etwa 1–100 sichtbar). Widerspricht „Zufall nur als Würze“ nicht, ist aber eine zweite Mechanik neben der Trefferchance.
- **Stärkstes Gegenargument gegen A:** Prozentproben fühlen sich weniger spannend an als ein Wurf. Antwort: Der Kampf zeigt heute schon „n gegen p %“; dieselbe Sprache überall ist leichter zu lernen.

**6. Gegenstände: Zusatzeigenschaften und das alte „+1“.** Heute würfelt die Beute „+1 bis +3“ und Zusatzwerte wie RK, ZP, Weisheit, Charisma; Einzelstücke (Graks Kriegsaxt, Klinge von Bornim) tragen „+1“. Das BRS streicht die Verbesserung und will Zusatzeigenschaften nur in BRS-Werten (`DESIGN-BRS.md` 11, 13).
- **A (Empfehlung):** Zusatzeigenschaften aus einer kleinen Liste: Grundwert +1, Schutzwert +1 oder +2, Leben +5, Mana +5, kritisch +3 %, Zauberschaden +10 %, Abwehrprobe +5 %; „Fertigkeit +1/+2“ nur ab episch (644 C1). Das „+1“ der Einzelstücke wird **Güte Meisterhaft**. Namensfarbe je Seltenheit bleibt. Abnutzung und Zustand kommen nicht im Umzug, sondern danach als eigener Vorgang (sie waren auch im SRD nicht da). Zahlen aus 444.
- **B:** Erst nur die alten Zusatzwerte umbenennen (RK→Schutzwert, ZP→Mana, Charisma→Handeln), Rest später. Schneller, aber Weisheit, Charisma, Angriffsbonus haben keinen sauberen Ersatz.
- **Stärkstes Gegenargument gegen A:** Die Liste ist Balance. Antwort: Sie ist klein, gedeckelt und wird gemessen; ohne Liste schreibt jedes Team eigene Werte.

**7. Die Kotlin-Fassung.** Sie ist SRD durch und durch und wird noch gebaut: jeder Push auf `main` baut die Kotlin-App und lädt sie in den internen Play-Store-Kanal (`android.yml`). Der Godot-Bau holt Karten, Texte und Heldendaten aus ihr.
- **A (Empfehlung):** Im Umzug löst Godot nur die SRD-Texte und Heldendaten aus Kotlin (Plan Schritt 8); Karten, Intro, Bilder kommen weiter von dort. Der Hinweis „SRD 5.1 · CC BY 4.0“ bleibt nur in der Kotlin-App. Ob die Kotlin-App aus dem Play-Store-Kanal genommen und `core`/`app` ins Archiv gehen, lege ich nach dem Umzug gesondert vor (das ist Store und Release, deine Sache).
- **B:** Jetzt alles aus Kotlin lösen und die Kotlin-Fassung stilllegen. Gründlich, aber zwei bis drei Sitzungen mehr für Karten und Bilder, die mit dem BRS nichts zu tun haben.
- **Stärkstes Gegenargument gegen A:** „nichts mehr mit SRD zu tun“ gilt dann fürs Repo noch nicht. Antwort: Fürs Spiel schon; das Repo folgt im eigenen Schritt, den du entscheidest.

**Folgerungen:** Nach deiner Antwort trage ich jeden Punkt in `DESIGN-BRS.md` und das Vorgangsarchiv ein, Diogenes hat den Plan dann gegengelesen (870.1), und ich lege die Vorgänge 870.2 ff. für Schritt 2–9 an; die Pause von Tom und Jerry bleibt bis 13.11., 20:00, danach bis 14.11. eine Entwicklersitzung zugleich (826).

Antwort: …
