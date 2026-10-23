# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (23.10., 19:15, „Tom – 345 Fackel ablegen“ `session_019jqa9XZ1Gfiw7Q9RtQXn7b`):** 344.1 und 345 gebaut (`claude/tom-345-fackel`, 1148230), Bitte an Jerry, beide in den Build mit 336 zu mischen. Nachfolger: „Tom – Build-Rückmeldung 344.1/345“ (erst nach dem Test des Chefs; sonst nichts startbar vor 24.10.).

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 344.1 | M | **von Sokrates (Chef 23.10., 18:27, Vorgangsarchiv 344):** Fackel brennt überall außer in hellen Grundrissen (`Light.burns`), dunkle Grundrisse wie Höhle; löst „draußen am Tag aus“ (255) ab | gebaut, fährt im nächsten Build (1148230, Kerntest; Prüfzeile Zu 344.1); Build mit Jerry 336 | `claude/tom-345-fackel` |
| 345 | M? | **von Chef (23.10., 17:35, B84, Dorf):** Fackel im Menü abgelegt, im Spiel erst nach 2–3 s weg, dann ganz (Zu 345) | gebaut, fährt im nächsten Build (1148230): Held ohne Fackel stand beim Vorzeichnen hinter der Beute und flog bei mehr als 4 Stücken heraus; jetzt zuerst, nie verdrängt (Kerntest) | `claude/tom-345-fackel` |
| 342 | M | **von Perikles (23.10., 10:15):** Termine „marktreif“ schätzen, je eigenem Muss in (a)–(e) Arbeitstage und machbares Fertigdatum; eine Zeile je Block unter „Zu 342“ | frühestens 25.10.: Termine stehen in `LISTE-ABNAHME-KAPITEL1.md` „Stand zum Marktstart“; Ergebnis bis So 25.10., 20:00 | – |
| 267 | M | **von Chef (20.10., 21:46, B48, Tablet):** „Das Game laggt ziemlich auf dem Tablet...“ | wartet auf Chef: Gefühl am Tablet, abends (77.7, Zu 267) | – |
| 302.3 | M | **von Sokrates (Chef 23.10., 10:45, Vorgangsarchiv 302.3):** alle Bilder von Intro und Outro mit Tusche im Zeichner, Licht aus der Quelle, etwas kräftiger als Intro 4 | ruht: Sparbetrieb bis Sa 24.10., 21:00; dann von c8cc89dd ausgehen | claude/tom-3023-kraeftiger |
| 302.2 | K | **von Chef über Sokrates (22.10., 23:50):** Tusche auf der Gebietskarte | zurückgestellt (Chef 10:45, gefällt ihm); Probe a478e244 ist Filterart | claude/tom-3022-tuschebild |
| 338.1 | M | **von Perikles (Stand zum Marktstart):** Schätzung Englisch durchgehend und Handys/Tablets bis 26.10. (Rest geschätzt 10:2x, Vorrat Perikles „Zu 338.1, Schätzung“) | frühestens 24.10.: Bestandsaufnahme | – |
| 302.1 | M | **von Sokrates (Vorgangsarchiv 302.1; 338 b):** Tuschelinie für Menschengestalten über `Doll`, Charaktererstellung zuerst, Hauptmenü mit (Chef 10:45) (Zu 302.1) | frühestens 26.10. (Perikles, 338): große Figuren zuerst; fertig bis 15.11. | claude/tom-3021-tusche |
| 292.2 | K | **von Chef (21.10., 22:28):** Hauptmenü: seltene, gute Bewegung je Klasse (Zu 292.2) | ruht: Vorrang Perikles | – |
| 292.4 | K | **aus 292.3:** Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (Zu 292.4) | ruht: Vorrang Perikles | claude/tom-2923-titelmodus |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2 (Zu 145) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2 (`STORY-WAHLEN.md`) | wartet auf 41 (Kapitel 2 nicht im Spiel) und 49 (ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts | wartet auf 41 (Kapitel 2 nicht im Spiel) | – |

## Einzelheiten

- **Von Team Jerry (23.10., 19:46), wackliger Kerntest:** `HeroShelfTest.newLootIsDrawnAheadAndWornAtOnce` (Zeile 76, `lastFromShelf`) fiel im vollen Lauf auf `jerry-337-angriff` + main + `tom-345-fackel` (Rechner unter Last, 23 s), allein grün. Bitte zeitfest machen, sonst trifft es den nächsten Build.

- **Zu 345** (Chef 23.10., 17:35, Rückmeldung Build 84, Wortlaut): „Im Dorf schurkerte Fackel dran. Ich gehe ins Menü, Ausrüstung, Fackel ablegen. Dann hat es 2-3 Sekunden gedauert, dann im Spiel wieder, bis die Fackel weg war. Aber es war dann einheitlich weg. Das kann man auf jeden Fall mal feststellen. Also nicht irgendwie so ein Flackern oder so.“ Kein Flackern, nur Verzug. Prüfen: wartet das Ablegen auf neu gezeichnete Bilder (332: neue Ausrüstung erst, wenn das Gehen gezeichnet ist), obwohl 322 (B81) ohne Neuzeichnen ablegte? **Prüfzeile:** Dorf, Fackel in der Hand, nach dem Start eine Minute spielen (der Held ohne Fackel wird still vorgezeichnet), Menü, Ausrüstung, Fackel ablegen, zurück: richtig: Fackel sofort weg; falsch: 2–3 s noch in der Hand. Gleich nach dem ersten Start eines Builds kann es noch dauern (alles wird neu gezeichnet).
- **Zu 344.1, Prüfzeile:** Dorf am Tag, Fackel anlegen: richtig: brennt mit Flamme; in die Schänke: gehalten ohne Flamme; wieder hinaus: brennt; falsch: draußen am Tag ohne Flamme oder in der Schänke mit Flamme.

- **Zu 145:** [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn), Querlink [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer).

- **Zu Build 82/83, Messungen des Chefs (A56, Test-Reiter):** B82 (13:45): Blende 8,8 s, über 50 ms 88 (Held), **Held ganz gezeichnet 23,9 s** (früher 5,9 s), Rennen nach dem Start nur Gehen. B83 (14:09, bei 343): Blende 6,2 s (Held), über 50 ms 36 (Held), Held gespeichert 0,1 s, Wärme mäßig. **Befund Tom (14:15):** 23,9 s nur beim ersten Start nach dem Einspielen (Bilder je Build eigener Ordner, `HeroShelf`), kein Rückschritt durch 332 (B66 frisch: 46,4 s); zweiter Start 0,1 s (B83). Rennen zeigt bis dahin das Gehen (245). 332 damit erledigt (Kür „Rennbilder früher“ in `LISTE-IDEEN.md`). **0.1.1008 (Chef 19:43):** Held ganz gezeichnet 29,0 s; Kampf bereit: Eröffnung 1,1 s, Held 8,7 s, Gegner 4,0 s; vorgezeichnet Held 1/314, Riesenratte 147 nicht fertig, Gegner nahe 59,0 s; über 50 ms 68 (Atmen 68, Leute 45, Kampf 23); längste Pause 225 ms.

- **Zu 302.1** (Chef 23.10., 09:01 und 10:46, über Sokrates): Die Charaktererstellung ist das Erste, was der Spieler sieht. Die Figur dreht sich dort und wirkt beim Drehen „noch rechteckig“: Sie muss rund drehen und gut aussehen, mit Tusche im Zeichner (im Schatten dicker), nicht als Filter. Danach das Hauptmenü. Früherer Wortlaut in Git (vor „Tom: Übergabe, 330 Stand“).
- **Zu 302.3** (Chef 23.10., 07:34, an Sokrates): Filterprobe (`inkEdges`) malt Rowenas warmen Lichtrand schwarz, so nicht vergleichbar. Neu: Bild 4 richtig zeichnen: Umrisse im Zeichner, Licht danach darüber, Linie auf der Schattenseite; Fenster und Lichtrand so hell wie ohne. In die Chefsache, dann an Chef.
- **Zu 302.3** (Chef 23.10., 08:59, an Sokrates): „Bei dem Entwurf … mit Tusche … kräftiger. So wie du es empfohlen hast, nochmal vorlegen.“ Gemeint ist die Stellungnahme Sokrates in `ansehen/302-tusche-vergleich.md`: Linie im Schatten sichtbar dicker (auf Handygröße erkennbar, heute überall 1–2 px), im Licht keine. Den 2 px breiten Lichtspalt links zwischen Türblatt und Rowena nicht zuschmieren, Fenster und Lichtrand bleiben so hell wie ohne Tusche. Neues Bild in dieselbe Chefsache, dann an den Chef.
- **Zu 267, 77.7** (Prüfpunkt aus Build 77, abends am Tablet): Menü → Test → Bildrate an, „Weiterspielen“, Wald → Tiefer Wald, 1 Minute laufen; dann „Absturzbericht zeigen …“ und den Text schicken. Richtig: so flüssig wie am Handy, „über 50 ms“ klein. **Chef 22.10., 23:16 (t79.7, SM-X210, 0.1.989):** „Blende: bereit nach 11,2 s (Held 0,0 s, Boden 11,2 s, Leute 2,0 s) … Danach 10 s: längste Bildpause 55 ms, über 50 ms: 1 (abgebrochen nach 1,4 s) … Held ganz gezeichnet nach 80,1 s … Vorgezeichnet: Held 51/293, Gegner giant_centipede 110 (nicht fertig)“. Befund Tom: nach der Blende flüssig (gemessen nur 1,4 s, dann Kampf); Blende wartet 11,2 s auf den Boden (Wald ganz, 267.2); Gefühl des Chefs fehlt noch.

- **Zu 292.4** (Feuer, B): Wortlaute Chef 12:08–13:54, Entwurf 5, Befunde in Git; Vorschau `TITLECAMP=1` auf `claude/tom-2923-titelmodus`. Homer (302): nur Gold, Feuer, Magie glänzen; Vorher-nachher-Bild an Homer, wenn 292.4 läuft.

- **Zu 292.2, Stufe 2** (Chef 22.10., 11:43, an Sokrates; Wortlaut in Git vor Commit „Tom: Übergabe, 330 Stand“): Kämpfer und Schurke halten das Schwert nicht gleich, einer stützt sich auf die gesenkte Waffe; je Held eine seltene, gute Signatur-Bewegung (`DESIGN-BLENDE.md` Punkt 8). Gilt auch für Entwurf B in Chefsache 292.3.


- **Zu 267, Messwerte** (Tablet SM-X210 und A56, Build 48 bis 68, 20.–21.10.): Wortlaute und Befunde in Git vor Commit „Tom: Vorrat nachgezogen“. Stand: Tablet nach der Blende flüssig mit Stromsparen aus (65.6), Kampf vorab neben Leuten und Boden behoben in Build 68; Gefühl am Tablet „nicht so flüssig wie am Handy“ (Chef 21.10., 22:12) offen, daher t77.7.

- **Zu 267, Idee Blende, lieber warten, t68** (Chef 21.10., 15:47/15:48; 22.10., 06:50): Wortlaute und Stellungnahme Sokrates in Git vor Commit „Tom: 325 gebaut, 322 Ablegen gebaut“; umgesetzt mit Build 60 (Blende wartet auf Held, Boden, Leute); Tablet-Prüfpunkte als „abends“ kennzeichnen.

- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.
