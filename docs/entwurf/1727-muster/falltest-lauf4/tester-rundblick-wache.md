# Falltest Lauf 4: Tester, Rundblick, Wache (22.11., 14:14–14:20)

Je Rolle nur deren Ladetexte aus `lt4/` gelesen (Tester: `sockel.md`, `kern-abnahme.md`, `profil-tester.md`; Rundblick: `sockel.md`, `routine-rundblick.md`; Wache: `sockel.md`, `routine-wache.md`). Werkzeug nur lesend in der Umschalt-Kopie (`--help`, `vorgang.py <Nr>`, `grep`); Schreibbefehle unten sind, was ich täte, nicht ausgeführt.

## T1

(a) Was ich tue:
1. Nicht urteilen, solange eine Testhilfe an ist (Profil: „Vor jedem Urteil schaltest du die Testhilfen aus und nennst ihren Zustand im Beleg“). Ich habe nachgesehen, was „Schnell“ tut: `godot/skripte/held.gd:20` `static var schnell := 1.0  # 555 Testmenue „Schnell“: Gehen und Laufen dreifach`; der Test `godot/tests/testmenue_555.gd:60–63` setzt es auf 3,0 und wieder auf 1,0. „Ausschlag“ ist der Ausschlag des Steuerknüppels in dp (`godot/tests/joystick_1285.gd:3, 27`). Zu schnell ist also genau die Wirkung dieser Testhilfe, kein Befund.
2. Im Testmenü „Schnell“ aus, alle anderen Testhilfen ebenso aus (Unsterblich, Kartenzoom, Monster, Kritisch, Rettung …), Zustand notieren.
3. Testpunkt neu: im Dorf Steuerknüppel in mehreren Ausschlägen (klein, halb, voll) je 2 s halten, Film in Spielkamera und Handygröße; Weg zur Stelle notieren. Vergleich mit dem Gehen im vorigen Build (Beleg des vorigen Builds), wegen Rückschritt.
4. Eine Nahtstelle prüfe ich gleich mit: steht „Schnell“ nach Neustart, Laden oder Ortswechsel wieder an, ohne dass ich es eingeschaltet habe? Dann wäre das ein Fehler (Testhilfe bleibt hängen) und gehört gezählt.
5. Meldung mit `python3 tools/vorgang.py rueckmeldung <Nr der Testaufgabe> "<Meldung>"`, die ausgegebene WECKER-Zeile als Nachricht (send_message) an die genannte Sitzung.

(b) Meldung (Fall: nach dem Ausschalten geht der Held wie vorgesehen, „Schnell“ bleibt aus):

```
python3 tools/vorgang.py rueckmeldung <Nr> "Befunde: 0
Testaufgabe „Dorf bis Wolfskampf“, Testpunkt „Gehen nach Ausschlag wie vorgesehen“: erfüllt. Testhilfen beim Urteil: alle aus (vorgefunden: „Schnell“ an, = Gehen und Laufen dreifach, held.gd:20; vor dem Urteil ausgeschaltet). Beleg: Film Spielkamera, Handygröße, Dorf, Ausschlag klein/halb/voll je 2 s; Weg: Neues Spiel, Dorfplatz.
Abnahmeliste: <je Punkt des Ganzen erfüllt / nicht erfüllt (Nr.) / nicht prüfbar, mit Beleg>
Hinweis: Testmenü stand beim Start auf „Schnell“, Testmenü
Nicht prüfbar: –"
```

Steht „Schnell“ nach Neustart oder Ortswechsel von selbst wieder an, statt dessen „Befunde: 1“ mit der Zeile „Fehler, Testmenü/Dorf, Testhilfe „Schnell“ steht nach <Neustart|Ortswechsel> wieder an, Gehen dreifach; Beleg Film, Weg …“. Geht der Held auch mit allen Testhilfen aus zu schnell: „Befunde: 1“, Art Rückschritt (wenn der vorige Build richtig ging) sonst Fehler, mit Messwert m/s je Ausschlag. Das Tool gibt „Befunde: n“ an den Disponenten (Hilfe zu 1795).

(c) Lücken:
- Unter welcher Nummer ich melde, nennt der Fall nicht; Profil: „Der Auftrag nennt die Nummer, unter der du meldest.“ Sockel 3 verlangt dann „anhalten, Frage zurückmelden“, Kern sagt aber „statt ‚Frage‘ meldest du mit den Wörtern deines Profils“, und das Profil Tester hat kein Wort für eine Rückfrage („Befunde: n“, „Hinweis“, „nicht prüfbar“). Das Werkzeug kennt „Frage“ (→ Sokrates). Widerspruch Kern gegen Sockel 3 und Werkzeug.
- Ob ein hängengebliebener Testmenü-Schalter, den ich vorfinde, ein Befund oder nur ein Hinweis ist, sagt der Text nicht; ich habe ihn als Hinweis gemeldet, solange er nicht von selbst wiederkommt.
- Was „wie vorgesehen“ ist (Sollwert Gehtempo je Ausschlag), nennt weder Profil noch Kern; Kern: „Zahl stimmt mit dem Regelwerk“, aber welche Quelle das Gehtempo festlegt, muss der Auftrag sagen; ich vergleiche nur mit dem vorigen Build.
- „Beleg je Befund: … Film für Bewegung“: ob auch ein „erfüllt“ einen Film braucht, sagt Nr. 5 („mit Beleg“) nur allgemein.

## T2

(a) Was ich tue:
1. Testhilfen aus, Zustand notieren. Messung wiederholen: Kampf auf Grafik Hoch, Bildrate über eine Minute (Anzeige im Testmenü/Leistungsanzeige), Lage (welcher Kampfort, welche Gegner, Gerät), Film. Zur Einordnung dieselbe Stelle auf Grafik Mittel/Niedrig, damit der Befund die Stufe zeigt.
2. Rückschritt? Belege des vorigen Builds nennen keine Bildrate → kein Vergleichswert, also kein Rückschritt. Profil Nr. 4: „Ruckeln oder lange Ladezeit ohne Vergleichswert: Fehler mit Messwert, Grafikstufe und Lage.“ Kern: Ruckeln bricht das Eintauchen → Mangel, also gezählt.
3. Nummer suchen: ich prüfe die mir mitgegebenen offenen und behobenen Vorgänge des Ganzen auf Bildrate. In der Liste fand ich (lesend, `grep -n -i "bilder/s\|bildrate" docs/LISTE-VORGAENGE.md`): 1484 (Spike, M, startbar: „Welt und Kampf 9–10 Bilder/s (A56 gleicher Build 24–25, Kampf 12–18) … Ursache, Ziel je Gerät“) und 1270.6 (Spike, gebaut: Messbuild „Bildrate fest 30 (Nr. 5) … · zurück t300“). Gehört 1484 zu den Vorgängen, die mir für das Ganze gegeben sind, nenne ich 1484; sonst ohne Nummer (dann legt das Büro einen Vorgang an). 1270.6 nenne ich als Hinweis: in t300 ist die Bildrate auf 30 begrenzt, 18–24 liegt darunter.
4. Den eigentlichen Test (Testaufgabe unter 300, Punkte 300.1–300.11) normal durchführen; Abnahmeliste je Punkt des Ganzen.
5. `python3 tools/vorgang.py rueckmeldung 300 "<Meldung>"`, WECKER-Zeile als Nachricht.

(b) Meldung (nur die Bildrate ausgeführt; die übrigen Befunde aus dem Test kämen dazu und erhöhen n):

```
python3 tools/vorgang.py rueckmeldung 300 "Befunde: 1
Fehler, Kampf (Kampfort <Ort>, <Gegner>), Grafik Hoch nur 18–24 Bilder/s über 60 s, Gerät <Gerät>; kein Vergleichswert, Belege von Build <vorher> nennen keine Bildrate; Beleg: Film mit Bildratenanzeige, Testhilfen alle aus; Weg: <Weg zum Kampf>; <1484, falls im Ganzen, sonst ohne Nummer>
Abnahmeliste: <je Punkt: erfüllt / nicht erfüllt (Nr. oder „ohne Vorgang“) / nicht prüfbar, Beleg>
Hinweis: Build 300 hat laut 1270.6 Bildrate fest 30; Hoch bleibt mit 18–24 darunter, Kampf
Hinweis: Belege des vorigen Builds ohne Bildrate, Vergleich für Rückschritte fehlt, Belege
Nicht prüfbar: <…>"
```

(c) Lücken:
- „Testaufgabe unter Vorgang 300“: `python3 tools/vorgang.py 300` zeigt einen erledigten Archiv-Vorgang „Bilder prüfen nur in einer Extra-Sitzung (Helfer) …“ (Perikles), keine Testaufgabe, keine Datei `docs/vorgang/300.md`. Build 300 und Vorgang 300 fallen zusammen; das Werkzeug würde meine Rückmeldung in einen fremden, erledigten Vorgang schreiben. Text sagt nicht, wie Buildnummer und Meldenummer auseinanderzuhalten sind.
- „Du testest ein Ganzes, nicht einen Auftrag“ gegen „Test von Build 300 (Punkte 300.1–300.11)“: ob ich die Prüfpunkte des Builds einzeln abhake oder nur das Ganze, sagt das Profil nicht; Nr. 5 kennt nur Punkte der Abnahmeliste.
- Welches Gerät maßgeblich ist (A56, Tablet) und ab welcher Bildrate „Ruckeln“ beginnt, sagt kein Text; ich habe nur gemessen und gemeldet.
- Ob ein Befund „außerhalb der Testaufgabe“ (nebenbei) gezählt wird oder nach Sockel 5 nur „zurückmelden“ ist: Profil sagt „Du suchst, wo kein einzelner Auftrag hinschaut“, also gezählt; Sockel 5 lässt es offen.
- Fehlender Vergleichswert in den Belegen des vorigen Builds: kein Wort, ob ich das als Lücke (Nr. 3) oder Hinweis melde; als Hinweis gemeldet.

## R1

(a) Was ich tue:
1. Eingang lesen (lesend): neueste Spalte der Wochenzählung `docs/PRUEFBERICHT.md` (Ergebnis: neueste Spalte ist 09.–15.11., gezählt 16.11.; die Woche 16.–22.11. ist noch nicht gezählt); „Systemlösung?“-Zeilen: `grep -n "Systemlösung" docs/LISTE-VORGAENGE.md docs/LISTE-VORGAENGE-ARCHIV.md` (u. a. 1736 Umhang 19 frühere, 1509 Nebel 6, 1510 Teich 5, 1564 Wasser 4, 1711 „Messung meldet passt, Bild zeigt Fehler“); Kosten: Spalte „Kosten“ der Liste und `docs/LISTE-KOSTEN.md` (erzeugt 08.11., also veraltet). Dazu das Archiv der Woche aus dem Fall und `python3 tools/vorgang.py 1289 1296 1734`.
2. Drei Schwächen nach Rang „Funde des Chefs zuerst, dann Wiederholfunde, dann teuerste“:
   - S1: 1289 „Höhle dunkel“, dritter Fund des Chefs (12:34, 13:39, 20:48). Archiv: „Höhle im Renderer mobile ganz anders als bisher … (Bilder bis 12:20 kamen aus Compatibility)“, 8,71 $. Ursache der Art: Prüfbild aus anderem Renderer als das Handy.
   - S2: 1296 „Eingebung“, zweiter Fund des Chefs: „goldene Eingebung … rät ‚Wechsel‘, unter den Knöpfen fehlt ein Wechsel“, 5,13 $. Art: Hinweis und Bedienung widersprechen sich, kein Test fängt es.
   - S3: Wiederholfund Umhang, 1736 „19 frühere Vorgänge“, dazu 1570 (Chef: „ich bin auch für die Systemlösung“); teuerster Wiederholfund (E Figuren 1.031 $ laut Liste insgesamt).
3. Je Schwäche nachsehen, wie andere es lösen (Websuche 22.11., 14:16):
   - S1: Godot-Doku „Overview of renderers“ (https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html): Mobile und Forward+ teilen RenderingDevice, Compatibility läuft auf OpenGL mit anderem Lichtmodell; ein Wechsel zu oder von Compatibility braucht die meisten Anpassungen. Andere prüfen Bilder nur im Zielrenderer und vergleichen automatisch gegen ein Referenzbild (Bildvergleichstest).
   - S2: GdUnit4 Scene Runner (https://mikeschulze.github.io/gdUnit4/advanced_testing/sceneRunner, MIT): Szene laden, Eingaben simulieren, Knöpfe und Texte prüfen. Andere testen „jeder Hinweis zeigt auf eine sichtbare, bedienbare Aktion“ als Szenentest.
   - S3: Godot `SpringBoneSimulator3D` (https://docs.godotengine.org/en/4.4/classes/class_springbonesimulator3d.html): für Haar, Stoff, Schwänze, mit eigenen Kollisionen (`SpringBoneCollision3D`), keine verzweigten Ketten (Umhang = mehrere lineare Ketten), Skelett darf nicht skaliert sein. Liegt neben 1736 („Systemlösung Federknochen“), daher als Messprobe, nicht als neuer Weg.
4. Je Vorschlag `vorgang.py uebergabe 1734 Disponent "Vorschlag: …"`, dann `vorgang.py rueckmeldung 1734 "fertig"`.

(b) Ergebnis wörtlich:

```
python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Prüfbild nur aus dem Zielrenderer. Schwäche: 1289 Höhle dunkel, dritter Fund des Chefs (12:34, 13:39, 20:48), Bilder kamen aus Compatibility statt mobile. Quelle: Godot-Doku Overview of renderers (stable, gelesen 22.11.): Compatibility hat ein anderes Lichtmodell als Mobile/Forward+. Probe: Höhle als Referenzbild im Renderer mobile, Test im Bau vergleicht jedes neue Höhlenbild damit (Helligkeit, Bildabstand) und hält an, wenn ein Bild aus einem anderen Renderer kommt. Maß: Funde des Chefs zu Licht/Höhle je Woche, vorher 3 (1289), nachher Ziel 0 über zwei Wochen. Kosten: etwa ein Auftrag Technik, 5–10 $. Entscheidung: Ablauf (Prüfbild nur aus mobile)."
python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Szenentest Hinweis gegen Knopf. Schwäche: 1296 Eingebung, zweiter Fund des Chefs: Hinweis rät „Wechsel“, Knopf fehlt. Quelle: GdUnit4 Scene Runner (MIT, Doku gelesen 22.11.): Szene laden, Eingabe simulieren, sichtbare Knöpfe prüfen. Probe: ein Test lädt den Kampfort, ruft je Eingebung den Hinweis und prüft, dass die genannte Aktion als sichtbarer, bedienbarer Knopf da ist. Maß: Funde des Chefs der Art „Hinweis ohne Aktion“, vorher 2 (1296), nachher 0; Testlauf findet den alten Fehler in Build 287 nach (Gegenprobe). Kosten: etwa 5 $ (bestehendes Testgerüst godot/tests, GdUnit4 nur, wenn das eigene nicht reicht). Entscheidung: nein (Test im Bau)."
python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Umhang mit SpringBoneSimulator3D messen. Schwäche: Umhang, Wiederholfund 1736 (19 frühere Vorgänge), Chef 1570 „ich bin auch für die Systemlösung“. Quelle: Godot-Klassendoku SpringBoneSimulator3D (4.4, gelesen 22.11.): für Haar und Stoff, eigene Kollisionen, nur lineare Ketten, Skelett unskaliert. Probe: ein Umhang als 3–5 lineare Ketten mit Kollision an Rücken und Beinen, gleiche Lauf- und Kampfbewegung wie der heutige Weg (1736 Federknochen), Vergleich im Bild der Spielkamera. Maß: Durchstiche je Bewegung (Prüfung durchstich_1631) und neue Umhang-Vorgänge je Woche, vorher 19 frühere, nachher 0 neue in zwei Wochen. Kosten: etwa ein Auftrag Figuren, 10–15 $. Entscheidung: nein (Messprobe), Weg erst nach Bild beim Chef."
python3 tools/vorgang.py rueckmeldung 1734 "fertig"
```

(c) Lücken:
- „die neueste Spalte der Wochenzählung“: die neueste ist 09.–15.11.; die Woche, aus der der Fall stammt, ist noch nicht gezählt. Text sagt nicht, ob ich dann die Vorwoche nehme oder das Archiv der Woche selbst zähle.
- „Kosten je Vorgang der Woche (… geschätzt in `docs/LISTE-KOSTEN.md`)“: die Datei ist „Erzeugt 08.11., 16:45“, also nicht von dieser Woche; neu erzeugen (`kostenbericht.py`) wäre ein Schreibbefehl, den ich nicht darf.
- Rangfolge zwischen 1289 (dritter Fund) und 1296 (zweiter): klar, aber ob zwei Funde des Chefs zwei der drei Plätze nehmen, auch wenn ein Wiederholfund viel teurer ist (Umhang), sagt der Text nur über „Funde des Chefs zuerst“; so gehandelt.
- Ob „Kosten“ des Vorschlags in Dollar oder Aufwand gemeint sind, sagt der Text nicht.
- Werkzeug: `uebergabe NR AN` schreibt eine Zeile in `docs/vorgang/1734.md` und gibt WECKER-Zeilen; der Text sagt nicht, dass ich die WECKER-Zeilen als Nachricht schicken soll (der Kern Abnahme sagt es für Rückmeldungen, der Rundblick hat keinen Kern). Auch „Disponent“ als Empfänger ist laut Hilfe „bis zur Umschaltung … Ford“.
- Titel von 1734 lautet „Forschung … bei Sokrates“, Besitzer Sokrates, Stand startbar; ob mein „fertig“ ohne Commit den Vorgang schließen lässt: Werkzeughilfe sagt „Routine, Titel ‚(Routine, Auftrag …)‘: ‚fertig‘ ohne Commit → Disponent legt die Vorschläge an und schließt“; 1734 trägt diesen Titel nicht, dann ginge „fertig“ ohne Commit an den Disponenten, „nimmt es nicht an“. Widerspruch Routine-Text und Werkzeug.
- „wie andere genau das lösen“ verlangt eine Quelle; ob eine Websuche erlaubt ist und was ich dabei über unser Spiel preisgeben darf, sagt der Text nicht (ich habe nur allgemeine Begriffe gesucht).

## R2

(a) Was ich tue: die sechs Prüfungen meiner Routine der Reihe nach:
1. blocked (Freigabe seit ≥ 15 Min, Haken stumm): im Fall nichts davon → nein.
2. Disponent blocked oder letztes Ereignis > 70 Min: im Fall nicht genannt → nein (ich sehe es nach, `list_sessions`/`list_events` der Ford-Sitzung).
3. Sitzung hängt (idle mit angenommener Übergabezeile nach Frist): `python3 tools/vorgang.py offen` → im Fall nichts → nein.
4. Rote Läufe ≥ 3 je Stunde: nicht genannt → nein.
5. Du bist dran (neue Testbitte oder Chefsache ohne Telegram): nein.
6. Tagesbericht fehlt (Sa/So 12 Uhr): nicht genannt → nein.

Die drei Vorgänge 1650, 1653, 1654 „abgenommen“ seit 7–9 h, in keinem Build, ohne Termin, fallen unter keine der sechs Regeln. Mein Ziel sagt aber „nichts hängt, ohne dass es jemand merkt“, Sockel 5: „Fund außerhalb des Auftrags: zurückmelden, nicht beheben.“ Ich melde es darum einmal als Fund an den Disponenten (den Weg „Wecker an den Disponenten“ kennt meine Routine), nicht laut an den Chef, weil keine Regel das deckt, und behebe nichts:

```
python3 tools/vorgang.py uebergabe 1650 Disponent "Wache 21.11., <Uhrzeit>: Fund außerhalb meiner Regeln: 1650, 1653, 1654 seit 7–9 h abgenommen, in keinem Build, ohne Termin."
```
WECKER-Zeile aus der Ausgabe als Nachricht (send_message) an den Disponenten. Dann Zeitmarke und Stand „Fund 1650/1653/1654 gemeldet <Uhrzeit>“ in meine Datei (höchstens eine Meldung je Stunde), warten auf den nächsten Wecker.

(b) Nachricht an den Disponenten (Wecker):

```
Wache [21.11., <Uhrzeit>]: sieh in 1650 (<Kennung>): 1650, 1653, 1654 seit 7–9 h abgenommen, in keinem Build, ohne Termin. Fund außerhalb meiner Regeln, nicht behoben.
```

An den Chef: nichts.

(c) Lücken:
- Keine der sechs Regeln deckt „abgenommen, aber in keinem Build“; das Ziel „nichts hängt, ohne dass es jemand merkt“ verlangt es, die Liste nicht. Ich habe nach Sockel 5 gehandelt; ob die Wache das überhaupt melden soll, sagt der Text nicht.
- „Wecker an den Disponenten“: welcher Befehl, sagt die Routine nicht; das Werkzeug kennt Wecker nur als Ausgabe von `uebergabe NR AN` (Zeile in `docs/vorgang/NR.md`). Ohne eigene Vorgangsnummer der Wache musste ich den Wecker an einen der drei fremden Vorgänge (1650) hängen.
- „Stand in deiner Datei“: welche Datei, sagt der Text nicht.
- Werkzeug zeigt für 1653 Stand „startbar, gebilligt 18.11. 22:37, in nächsten Build“ und für 1650 „gebaut“; ein Stand „abgenommen“ steht so nicht in der Liste. Wie die Wache „abgenommen“ erkennt, sagt der Text nicht.
- Ab wann etwas „hängt“ (Schwelle in Stunden), sagt der Text nur für Freigaben (15 Min), Disponent (70 Min) und Übergabefrist.

## R3

(a) Was ich tue: die sechs Prüfungen:
1. blocked: nein. 2. Disponent: nicht genannt, nachsehen → nein. 3. Sitzung hängt: `python3 tools/vorgang.py offen` → nein. 5. Du bist dran: Builds 286–292 sind getestet und freigegeben, keine neue Testbitte → nein. 6. Tagesbericht: nicht genannt → nein.
4. Rote Läufe: Lauf 293 rot, ein roter Lauf in der Stunde; Schwelle ist „ab 3 fehlgeschlagenen GitHub-Läufen in der Stunde“ → keine Meldung.

Freigegeben seit Archiv, aber seit 3 h keiner auf `main`: keine Regel. Wie in R2 nach Ziel und Sockel 5 einmal als Fund an den Disponenten, nicht laut an den Chef, nicht beheben (kein Merge, kein Push). Ich hänge den Wecker an den Vorgang, unter dem die Builds laufen; den kennt mein Text nicht, daher Platzhalter:

```
python3 tools/vorgang.py uebergabe <Nr des Builds 292> Disponent "Wache 21.11., <Uhrzeit>: Fund außerhalb meiner Regeln: Builds 286–292 vom Chef freigegeben (Archiv), seit 3 h keiner auf main; Lauf 293 rot (1 in der Stunde, unter der Schwelle)."
```
WECKER als Nachricht, Zeitmarke und Stand in meine Datei (Lauf 293 notiert, damit ich beim nächsten Wecken die Zahl je Stunde fortzähle), warten.

(b) Nachricht an den Disponenten:

```
Wache [21.11., <Uhrzeit>]: Builds 286–292 freigegeben, seit 3 h keiner auf main. Lauf 293 rot, 1 in der Stunde (Schwelle 3, keine Meldung an den Chef). Fund außerhalb meiner Regeln, nicht behoben.
```

An den Chef: nichts.

(c) Lücken:
- „freigegeben, aber nicht auf `main`“ deckt keine Regel; Ziel ja. Wie R2.
- Regel 4 zählt „in der Stunde“; ob gleitend (letzte 60 Min) oder Uhrstunde, sagt der Text nicht; ebenso, ob abgebrochene Läufe zählen.
- Ob der rote Lauf 293 mit dem Stau 286–292 zusammenhängt (etwa das Zusammenführen bricht), darf ich als Messende nicht untersuchen; der Text sagt nicht, ob ich den Zweig des roten Laufs im Wecker nennen soll (Regel 4 verlangt Zweige nur ab 3).
- Wieder kein Befehl für „Wecker an den Disponenten“ und keine eigene Vorgangsnummer der Wache; Werkzeug kennt Wecker nur über `uebergabe NR AN`.
- Sockel 8 „Spielcode ohne Test des Chefs nach `main`“ verbietet nur; wer freigegebene Builds nach `main` bringt und bis wann, steht nicht in meinem Text.
