# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (20.10., 19:09, „Tom – 255 Fackel im Hellen (20.10., 18:03)“):** PR #136 (Build 48) grün, konfliktfrei mit main (19:08), wartet auf Test; Abo und Kontrolle enden mit dieser Sitzung, Nachfolger abonniert #136 neu. 255 gebaut auf `claude/tom-255-fackel-hell` (von Build 48 abgezweigt), Standbild in der Chefsache; Vorschau `FACKEL255=1`. Notizkopie hatte wieder die 11 alten Commits vom 19.10.; gesichert in `backup-lokal-main`, auf origin/main zurückgesetzt. Nachfolger: Tom – Build 48 Rückmeldung und 255 in den nächsten Build.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 239.1 | M | **von Chef (20.10., 17:16, t45.4, Rückläufer 239):** Garrick springt beim ersten Hinhocken und Eindösen in die Ausgangsbilder, beim zweiten Mal weich (Wortlaut Zu 239.1) | gebaut, Build 48 (t48.4): Garrick zeigt bis zum fertigen Bild den nächsten fertigen Schritt, nie das Stehbild; eigene Ablage für seine Bilder | `claude/tom-216-3-hoehle` |
| 216.3 | M? | **von Chef (20.10., 14:57, über Sokrates, Bild Laterne im Dorf):** Dinge im Freien sperren viel zu weit, allgemein prüfen; Felder bleiben (216.2) (Wortlaut Zu 216.3) | gebaut, Build 48 (t48.2, .5, .7): Höhle (Tropfstein, Kisten) und runde Dinge (Rückläufer Feuer t45); im Freien sonst freigegeben mit Build 45 | `claude/tom-216-3-hoehle` |
| 254 | M? | **von Chef (20.10., 17:02, t45, Bilder):** Hinweis in Goldschrift über der Aktionstaste wird von der Lauftaste verdeckt (Wortlaut Zu 254) | gebaut, Build 48 (t48.1): Hinweis links neben der Aktionstaste, Lauftaste bleibt (`WorldScreen.kt`, Jerry im Bilde) | `claude/tom-216-3-hoehle` |
| 258 | M? | **von Chef (20.10., 17:16):** Fackel in der Hand des Helden bewegt sich im Stand nicht, nur beim Gehen (Wortlaut Zu 258; bis 20.10. doppelt als 257, Commits nennen 257) | gebaut, Build 48 (t48.6): Flamme wechselt im Stand alle 120–220 ms | `claude/tom-216-3-hoehle` |
| 215.2 | K | **von Chef (20.10., 17:16, t45):** Klopfen an Türen sehr leise (Wortlaut Zu 215.2) | gebaut, Build 48 (t48.3): Klopfen etwa 6 dB lauter (Spitzen weich gestaucht) | `claude/tom-216-3-hoehle` |
| 255 | K | **von Chef (20.10., 17:08, über Sokrates):** Mit Fackel ins Gebäude gehen ist komisch; Fackel ablegen, Leuchtfunke erlöschen? (Wortlaut Zu 255) | gebaut 20.10., Standbild in der Chefsache (ansehen/255-fackel.md) (Vorgangsarchiv 255: Fackel brennt nur draußen nachts und in der Höhle, Leuchtfunke im Grundriss an der Schulter); fährt im nächsten Tom-Build | `claude/tom-255-fackel-hell` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (`STORY-WAHLEN.md`, Vorgangsarchiv 133) | wartet auf 41 (Kapitel 2 ist nicht im Spiel: keine Rabenschanze, kein Kultlager, kein Vesk, Ansel, Rask) und 49 (Fertigkeiten, ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (Kapitel 2 ist nicht im Spiel) | – |

## Einzelheiten

- **Zu 255** (Chef 20.10., 17:08, an Sokrates, Wortlaut): „… ist mir jetzt so aufgefallen, mit Fackeln in Gebäude gehen, ist eigentlich ein bisschen komisch. Also da wir entweder ein automatisches Ablegen und wieder anlegen, gut, keine Ahnung. Ich meine, gut, jetzt wenn man den Leuchtfunken getrunken hat, den kann man nicht an- und ausstellen. Dann wäre auch die Frage, ob der nicht erlischt, wenn man ein Gebäude betritt. Also natürlich keine Höhle, aber halt ein Wohnraum wegen Brandgefahr oder so. Ja, kaum mal drauf rum, was deine Meinung ist.“

- **Zu 216.3** (Chef 20.10., 14:57, an Sokrates, Bild: Held im Dorf etwa ein Feld neben der Laterne am Pflaster, Wortlaut): „Näher komme ich nicht an die Lampe ran. Das war schon ein Test der Feedback, dass manche Objekte einfach viel zu großen Sperrkreis haben, sozusagen. Das müsste allgemein geprüft werden. Das hängt zusammen mit meiner Frage, ob man die Felder nicht kleiner machen kann.“ **Befund Sokrates** (`FreeWalk.kt`, main): `footprint()` gibt nur in Räumen den gezeichneten Umriss (Regal, Theke, Tisch, Fass, Pflanze); im Freien füllt jedes gesperrte Ding das **ganze Feld**, dazu der Radius des Helden 0,3. Ein Laternenpfahl hält ihn so mindestens 0,8 Felder von seiner Mitte fern. **Vorschlag:** Umriss je Ding auch im Freien (Laterne, Pfahl, Schild, Brunnen, Fass, Bank, Stand, Baumstamm, Zaunpfosten …) nach dem Bild; ein Werkzeug legt für jedes Ding Umriss und Bild übereinander (Standbild an den Chef) und meldet zu große. Die Mitte des Helden betritt das Feld weiter nie (Wege, Aktionstaste 216.1 unverändert). Felder kleiner machen braucht es dafür nicht (216.2: Felder bleiben). Klasse M? (Perikles, 126): Bedienfehler sind Fehler (216, Direktive 179).
- **Zu 216.3, Rest Höhle** (Tom 20.10.): Höhle fehlt in Build 45: Tropfstein (`STALAGMITE`) und Kisten (`CRATE`) füllen dort noch das ganze Feld (Kristall, Fackel, Felswand bleiben Wand); gebaut 20.10. auf `claude/tom-216-3-hoehle` (`MapCaveIso.stalagmiteSpot`, `crateSpot`, Kerntest auch für die Höhle), fährt im nächsten Tom-Build; Vorschau `UMRISS=1` mit Höhle; Jerry im Bilde (Höhle).

- **Zu 216.3, Rückläufer t45** (Chef 20.10., 17:02, Bild: Held nachts rechts neben Garricks Feuer, etwa ein Feld Abstand, Wortlaut): „Feedback zu t45.4 Näher an das Feuer (und wahrscheinlich andere Objekte) komme ich aus dieser Richtung nicht ran.“ **Befund Tom:** bildschirm-rechts ist auf der Karte schräg (Ost und Nord zugleich); dort trifft der Held die Ecke des eckigen Umrisses (Feuer 0,11–0,89), Abstand zur Mitte 0,85; dazu betritt seine Mitte das Feld nie (Ecke 0,71). Gebaut 20.10., 17:10: Feuer, Brunnen, Fass, Heu, Stein sperren rund; schräg am Feuer 0,71 statt 0,85 (näher lässt die Regel „Mitte nie ins Feld“ nicht zu). Vorschau alle Dinge: 0,50–0,75, Tropfstein 0,82.
- **Zu 216.3, Brunnen** (Chef 20.10., 17:19, an Jerry, Build 46, Bild: Held am Tag auf dem Pflaster links neben dem Dorfbrunnen, etwa ein halbes Feld Luft zur Mauer, Wortlaut, eingetragen von Jerry): „Soweit komme ich an den Brunnen von der Seite in Build 46“. Build 46 hat Toms runden Umriss (17:10) noch nicht; damit prüfen, ob der Brunnen von der Seite reicht.
- **Zu 254** (Chef 20.10., 17:02, Bilder: Schänke innen „…rnim“, Dorf „Zum Schlafenden Greif“ halb unter der Lauftaste, Wortlaut): „Jetzt erst entdeckt, da wird ja ein Text eingeblendet, wenn man wo reingeht, in goldener Schrift über den Aktionsbutton. Aber das kann man nicht lesen, weil da ist der Laufbutton. Da muss der Laufbutton entweder ein Tick höher oder die Schrift woanders hin, das weiß ich nicht. Aber so schaut es doof aus.“ Nachtrag 17:03: „Nochmal ergänzend wegen der Schrift rechts unten.“ (Bild Dorf)

- **Zu 239.1** (Chef 20.10., 17:16, Wortlaut): „Garricks Animation, als ich das testen sollte, wenn ich bei ihm stehe, wenn er sich hinkniet und dann eindüst. Also beides mal sprang immer rauf, runter und beim Eindüsen das erste Mal auch so wie durch die Matrix. Und beim zweiten Durchgang war es smooth. Aber das erste Mal hat er es anscheinend nicht vorberechnet und dann ist er immer in die Ausgangsbilder zurückgesprungen. Ich werde es jetzt nochmal in der Schenke anschauen. Aber bei Garrick war es so.“
- **Zu 258** (Chef 20.10., 17:16, Wortlaut): „Grundsätzliches Feedback, die Fackel in der Hand des Helden, wenn man einfach steht, hat keine Animation, die bewegt sich nicht. Nur beim Gehen, das sieht ein bisschen tot aus.“
- **Zu 215.2** (Chef 20.10., 17:16, Wortlaut): „Klopfen an Türen ist sehr leise...“ Dazu: „Somit Build 45 getestet und mut Anmerkungen freigegeben.“

- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.





