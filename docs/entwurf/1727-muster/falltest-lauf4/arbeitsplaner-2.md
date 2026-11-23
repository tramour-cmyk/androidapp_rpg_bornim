# Arbeitsplaner, Gruppe 2 (A8–A16), Falltest Lauf 4 (22.11., 14:22)

Für jeden Fall habe ich zuerst dasselbe gelesen (in `kopie/`, nur lesend): `python3 tools/vorgang.py <Nr>` (Liste, Archiv, „Zu“-Absätze), `ls docs/vorgang/<Nr>.md` (gibt es bei keiner der neun Nummern), `git log --all --oneline --grep="^<Nr>[:. ]"` und `git log --oneline -6 origin/<Zweig>` für Zweig und Commit. Die Vorlage (`vorgang.py auftrag <Nr>` ohne Datei) habe ich im Test nicht aufgerufen, weil sie nicht unter den erlaubten Befehlen steht; Felder und Grenze habe ich aus `tools/auftrag.py` gelesen. `docs/LISTE-LEHREN.md` gibt es in der Kopie nicht, also keine Lehren.
Echt käme nach dem Prüfen `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad>` (trägt „## Auftrag“ oben in `docs/vorgang/<Nr>.md` ein und pusht) und dann die Rückmeldung. Im Test nur `--pruefen`.

## A8

(a) Gelesen: `python3 tools/vorgang.py 1650`; `git log --oneline -4 origin/claude/tom-1650-stiefel`; `find . -name held_klassen.py`, `find godot -name "held*"`, `grep -n boden godot/skripte/heldfigur.gd`; Profile `profil-figur-und-pruefbild.md`, `profil-zugang-kaufrepo.md`. Dann Auftrag geschrieben und geprüft:
`python3 tools/vorgang.py auftrag 1650 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A8.auftrag.md --pruefen`
Echt danach: `python3 tools/vorgang.py auftrag 1650 --datei …/A8.auftrag.md`, dann
`python3 tools/vorgang.py rueckmeldung 1650 "Auftrag steht 1650, Sohle des Helden schwebt in der Ruhepose: Test über alle Figuren auf Füßen, Ursache mit Commit, dann Bild alt gegen neu."`

(b) Auftrag: `A8.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1650: gültig (2042 Byte, davon Zitate unter „Bisher“ 0)` (erste Fassungen: 2365 und 2079 Byte, „hält an“, gekürzt).

(c) Lücken:
- Die Pfade aus dem Vorgang gibt es nicht (`tools/bau/held_klassen.py`, `godot/scenes/held.tscn`); der Kern sagt nur „Nicht raten, sondern belegen“ (Sockel 3), nicht, ob ich die echten Pfade einsetzen darf. Ich habe beide genannt.
- Das Bild `ansehen/1650-stiefel.webp` gibt es nicht; vorhanden ist `docs/chefsache/bilder/1650-stiefel.webp` (gehört zur gebilligten Hosenarbeit). Ich habe es nicht ansehen können.
- Unter derselben Nummer liegt schon andere, gebilligte Arbeit (Hose im Schaft). Kern: „Vorgänge mit Nummer und Titel in Worten“ – ob ein neuer Fund unter eine gebilligte Nummer gehört, sagt mein Text nicht.
- „Systemfrage: … Mit Quelle, sonst erster Schritt der Fachkraft“: ich durfte nichts außerhalb lesen, also überall erster Schritt.
- Feld 4: „der Pfad des Profils“ (Einzahl); welches Fachprofil zu welchem Thema gehört, sagt mein Text nicht; Zugang Kaufrepo und Figur habe ich nach ihrem Inhalt gewählt.

## A9

(a) Gelesen: `python3 tools/vorgang.py 1653`; `git log --oneline -6 origin/claude/jerry-1653-kleid`; `git show origin/claude/jerry-1653-kleid --stat`; `find . -name kauf_kleid.py`; `ls godot/tests/durchstich_1631.json`. Geprüft:
`python3 tools/vorgang.py auftrag 1653 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A9.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 1653 "Auftrag steht 1653, Thessa: Kragen sticht durch den Umhang: Test über alle Figuren mit Umhang über Kragen, Ursache mit Commit, an den Chef nur alt gegen neu."`

(b) Auftrag: `A9.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1653: gültig (2163 Byte, davon Zitate unter „Bisher“ 120)`.

(c) Lücken:
- Das frühere Nein des Chefs (18.11., 21:48) steht im Archiv, nicht in einer Vorgangsdatei; Kern: „Jedes frühere Nein des Chefs oder Prüfers steht wörtlich unter ‚Bisher‘“. Das Prüfer-Nein (der Fund) hat keinen Wortlaut im Vorgang, nur die Lage.
- Im Archiv steht der umgekehrte Befund (Kleid sticht durch den Kragen) und „gebilligt, in den nächsten Build“; ob der neue Fund dieselbe Stelle meint, sagt der Vorgang nicht. Ich habe den gebilligten Stand als Grundlage gesetzt.
- „Bild an den Chef nur alt gegen neu“ steht im Vorgang; mein Kern sagt es schon (Feld 6), das Querprofil Figur auch. Kein Widerspruch.

## A10

(a) Gelesen: `python3 tools/vorgang.py 1613`; `git log --oneline -3 origin/claude/spike-1613-glanz`; `git branch -r --contains 25b05a124`; Profile `querprofil-signatur-und-leben.md`, `profil-technik.md`. Geprüft:
`python3 tools/vorgang.py auftrag 1613 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A10.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 1613 "Auftrag steht 1613, Glanz der Waffen im Dorf bei Nacht: Glanz nur an sichtbarer Lichtquelle (Signatur), Schein epischer Waffen bleibt; Beleg Bild statt des freigegebenen Films."`

(b) Auftrag: `A10.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1613: gültig (2229 Byte, davon Zitate unter „Bisher“ 200)`.

(c) Lücken:
- Freigegeben ist ein Filmlauf, mein Kern verlangt „die erste, mit der der Chef allein urteilt: Bild, Film …“. Ob die Freigabe eines Films einen Bildlauf deckt, sagt mein Text nicht; ich habe „genau ein Lauf, Beleg Bild statt Film“ geschrieben.
- „Das glänzt wie Plastik“ ist Geschmack; Kern: „Geschmack ohne Maß („düsterer“): zwei bis drei Varianten“. Ich habe das Maß aus der Signatur genommen („Nur Gold, Feuer, Magie glänzen“, „Licht aus sichtbarer Quelle“), keine Varianten. Ob die Signatur als Maß reicht, sagt mein Text nicht.
- Das Chefwort vom 17.11. steht nicht in Liste oder Archiv (dort nur 18.11.); ohne Uhrzeit. Büro: „Chefworte wörtlich mit Zeit“.
- 1613 ist Kür (K); ob das den Auftrag ändert, sagt mein Text nicht.

## A11

(a) Gelesen: `python3 tools/vorgang.py 1655`; `git log --oneline -4 origin/claude/tom-1655-kapuze`; `git ls-tree -r --name-only origin/claude/tom-1655-kapuze | grep spielbild_1655`. Geprüft:
`python3 tools/vorgang.py auftrag 1655 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A11.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 1655 "Auftrag steht 1655, Morwen: Kopf sticht durch die Kapuze: Kapuze im Bauskript neu, Test über alle Kaufkapuzen, ein Bildlauf alt gegen neu."`

(b) Auftrag: `A11.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1655: gültig (2106 Byte, davon Zitate unter „Bisher“ 61)`.

(c) Lücken:
- Chefwort „Chef 18.11.“ ohne Wortlaut und Zeit; Büro: „Chefworte wörtlich mit Zeit in die Vorgangsdatei“. Ich konnte es nicht wörtlich unter „Bisher“ setzen.
- Die Messung „0 Ecken“ am Stand `10d4710c0` widerspricht dem Chefbefund nicht sicher, weil es nie ein Bild neu gab; Kern sagt „Widersprechen sich Messung und Bild, gilt das Bild“, aber nicht, was gilt, wenn das Bild fehlt.
- Kaufdateien: Sockel 7 erlaubt `add_repo`; ob die Fachkraft das im Auftrag lesen muss oder das Profil reicht, sagt mein Text nicht (ich habe das Profil genannt).

## A12

(a) Gelesen: `python3 tools/vorgang.py 1569` (nur Archiv: erledigt, t299 bestanden); `grep -n "Umhang" docs/VORGANGSARCHIV.md | grep -i "wach\|kauf\|Tuch"` (1651 gebilligt; 431 Kleiderschrank). Kein Auftrag, sondern:
`python3 tools/vorgang.py rueckmeldung 1569 "Frage 1569, Umhang des Wachsoldaten aus dem gekauften Modell statt des einfachen Tuchs: …"` (wörtlich in `A12.auftrag.md`).

(b) Rückmeldung wörtlich: siehe `A12.auftrag.md`. Keine Prüfausgabe (kein Auftrag).

(c) Lücken:
- Der Vorgang nennt keine Herkunft. Kern: „Ziel: … mit Herkunft (Chef, Sokrates, Fund mit Beleg)“ und „Nicht deins: … Aussehen“, „Fehlt ein Chefwort zu seiner Frage: ‚Frage‘ statt Auftrag“. Ob „keine Herkunft“ dasselbe ist wie „fehlt ein Chefwort“, sagt mein Text nicht genau; ich habe es so gelesen.
- 1569 ist im Archiv erledigt; das Werkzeug kennt Rückläufer (`wieder`), mein Text sagt nicht, ob ich einen erledigten Vorgang neu beauftrage.
- Wäre ein Auftrag verlangt gewesen: Kern Feld 4 nennt Fremde Inhalte, aber nicht das Profil Zugang Kaufrepo.

## A13

(a) Gelesen: `python3 tools/vorgang.py 1621` (wartet auf 1694, ruht; drei Neins des Chefs); `python3 tools/vorgang.py 1694` nicht nötig, der Stand steht in 1621; `git log --oneline -3 origin/claude/spike-1621-griff`; `git ls-tree -r --name-only origin/claude/spike-1621-griff | grep -i "waffen_staffel\|bild_laenge"`. Geprüft:
`python3 tools/vorgang.py auftrag 1621 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A13.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 1621 "Auftrag steht 1621, Zweihandwaffen kürzer: Längen nach Wahl A, Faust am Griff auf dem Stand von 1694, Bild alt gegen neu mit Ausschnitt Hände."`

(b) Auftrag: `A13.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1621: gültig (2349 Byte, davon Zitate unter „Bisher“ 316)`.

(c) Lücken:
- „Die Waffen sind viel zu lang“ hat kein Maß; das Maß (Wahl A, 18.11., 07:37) steht im Archiv. Kern: „ein Chefwort geht vor“ – welches, wenn zwei Chefworte zusammengehören, sagt mein Text nicht; ich habe A als Maß des ersten genommen.
- 1621 wartet auf 1694 (ruht). Mein Text sagt nicht, ob ich für einen wartenden Vorgang einen Auftrag schreibe; ich habe „auf dem Stand von 1694“ gesetzt. Ist 1694 nicht gebaut, kommt von der Fachkraft „Frage“.
- Die drei Neins gehören zum Griff, nicht zur Länge; Kern: „Jedes frühere Nein … wird eine Prüffrage“ – also stehen sie drin, obwohl die Systemlösung in 1694 liegt.
- Keine Uhrzeit beim Chefwort 17.11.

## A14

(a) Gelesen: `python3 tools/vorgang.py 431` (Völker; Umhang ruht seit 16.11. bis nach dem Meilenstein); `git log --oneline -3 origin/claude/tom-431-umhang`; `git log --all --oneline --grep="^431"`. Geprüft:
`python3 tools/vorgang.py auftrag 431 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A14.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 431 "Auftrag steht 431, Umhang schwingt beim Gehen: Prüfung über alle Körper mit Umhang, Ursache mit Commit, ein Filmlauf von der Seite."`

(b) Auftrag: `A14.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 431: gültig (2260 Byte, davon Zitate unter „Bisher“ 245)`.

(c) Lücken:
- Der Umhang ruht laut Archiv „bis nach dem Meilenstein“ (Sokrates 16.11., 00:08); der Vorgang sagt jetzt „ein Filmlauf frei“, ohne Quelle. Kern Feld 3: „Deckel und Freigabe mit Quelle“. Ich habe „(laut Vorgang)“ geschrieben.
- 431 ist der Vorgang „Völker als Modelle“; ob der Umhang ein eigener Vorgang sein müsste, sagt mein Text nicht.
- Chefwort „(Chef)“ ohne Wortlaut und Zeit.
- Kein Deckel genannt, obwohl der Umhang schon etwa 130 $ kostete; mein Text verlangt Deckel nur „mit Quelle“, setzt keinen.

## A15

(a) Gelesen: `python3 tools/vorgang.py 1619` (gebaut, wartet auf Test t301); `git log --oneline -3 origin/claude/spike-1619-gang-main` (`bad5be71b` Gangprüfung 1632); `grep -n "Fuss\|Boden" godot/skripte/heldfigur.gd`. Geprüft:
`python3 tools/vorgang.py auftrag 1619 --datei /home/user/bornim-main/docs/entwurf/1727-muster/falltest-lauf4/A15.auftrag.md --pruefen`
Echt danach: eintragen, dann
`python3 tools/vorgang.py rueckmeldung 1619 "Auftrag steht 1619, Gang des Helden über die Wiese, Füße gleiten: gang_1632 rot zeigen, Ursache mit Commit, ein Filmlauf mit Tusche von der Seite, Testhilfe Schnell aus."`

(b) Auftrag: `A15.auftrag.md`. Prüfausgabe: `vorgang.py auftrag 1619: gültig (2121 Byte, davon Zitate unter „Bisher“ 157)`.

(c) Lücken:
- Chefwort „(Chef)“ ohne Wortlaut und Zeit; Freigabe ohne Quelle (wie A14).
- 1619 steht in Build t301 „zu testen“; mein Text sagt nicht, ob ich einen Vorgang beauftrage, der im Test des Chefs liegt.
- Testhilfen: dass „Schnell“ aus sein muss, steht nur im Profil Tester („schaltest die Testhilfen aus“), nicht in meinem Text; ich habe es aus dem Chefwort 13:00 übernommen.

## A16

(a) Gelesen: `python3 tools/vorgang.py 760` (ruht, nach Arena 1714, wartet auf 1589.4); `python3 tools/vorgang.py 1589.4 1714 1605` (1714: Chef 18.11., 22:17, alles zu Plätzen und Bewegungen ruht bis zur Arena; 1589.4 startbar, wartet auf 1589.2); Profil `profil-kampf.md` („Bis Vorgang 1589.4 … ruht alles zu Plätzen und Bewegungen im Kampf: kein Auftrag, kein Lauf“). Kein Auftrag, sondern:
`python3 tools/vorgang.py rueckmeldung 760 "Frage 760, Wolfsbiss trifft den Helden nicht sichtbar: …"` (wörtlich in `A16.auftrag.md`).

(b) Rückmeldung wörtlich: siehe `A16.auftrag.md`. Keine Prüfausgabe (kein Auftrag).

(c) Lücken:
- Die Ruhe bis zur Arena steht nicht in meinem Text, nur im Profil Kampf (das ich nur lesen sollte, „um zu entscheiden, ob du es nennst“) und im Archiv (1714). Mein Kern sagt nur „Fehlt ein Chefwort zu seiner Frage: ‚Frage‘“, nichts über ein Chefwort, das die Arbeit anhält.
- Der Fall sagt nicht, ob ein Filmlauf frei ist („drei Wolfsangriffe im Film zeigen“); eine Lauffreigabe kennt mein Text nicht.
- Die Rückmeldung geht an Sokrates (Werkzeug leitet „Frage“ weiter); ob ich dem Disponenten zusätzlich etwas sage, sagt mein Text nicht.
