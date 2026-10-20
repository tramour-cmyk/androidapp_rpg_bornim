# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).


**Übergabe (20.10., 12:21, „Tom – Weiche Haltungswechsel 239 (20.10., 12:07)“):** 239 gebaut auf `claude/tom-239-haltungswechsel` (Garricks Hocke, Aufschrecken, Arbeitsschleifen; Kerntests grün), Bildserie an den Chef. Jerry hatte 239 um 12:09 parallel übernommen; per Nachricht gebeten, seine Datei 239-garrick-hocke.md zurückzuziehen. Nach „passt“: Build mit 215.1 (Zweige zusammenführen, PR, Prüfliste). Nachfolger: keiner, bis der Chef zu 239 antwortet.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 239 | M | **von Sokrates (Chef 20.10., 11:45):** Haltungswechsel weich, Garrick zuerst (Wortlaut Zu 239) | wartet auf Chef: Bildserie [239](chefsache/ansehen/239-haltungswechsel.md) | `claude/tom-239-haltungswechsel` |
| 245 | M? | **von Sokrates (Tester über Chef 20.10., 12:24):** Held läuft „robotermäßig“: Oberkörper steif beim Rennen, Drehungen hart; Gang, Rennen und Schräglauf natürlicher (Wortlaut Zu 245) | gebaut (übernommen von Jerry 20.10., 12:51, 118): Schulterschwung, Rennbilder (Schritt läuft beim Wechsel weiter), weiche Drehung auch der Leute, Schrittgeräusche nach den Füßen; Kerntests; Build 44 (Jerry, PR #132) | `claude/jerry-245-gang` |
| 216.3 | M? | **von Chef (20.10., 14:57, über Sokrates, Bild Laterne im Dorf):** Dinge im Freien sperren viel zu weit („Näher komme ich nicht an die Lampe ran“), allgemein prüfen; Felder bleiben (216.2) (Wortlaut Zu 216.3) | offen: Umriss je Ding im Freien wie in Räumen (`FreeWalk.footprint`), alle Dinge mit Werkzeug gegen ihr Bild prüfen | – |
| 215.1 | K | **von Chef (20.10., 06:42, über Sokrates):** Klopfgeräusch, wenn der Held per Aktionstaste an eine verschlossene Tür klopft | wartet auf Build (gebaut 20.10., fährt im nächsten Sammelbuild mit) | `claude/tom-215-1-klopfen` |
| 26 | M | Kapitel 1 fertig: Zielliste vor Neuem | ruht: Chef spielt von selbst durch (13.5, Zu 26) | – |
| 30 | K | Abstürze beim Testen (Technik) | ruht bis zum nächsten Absturzbericht (`adb logcat`) | – |
| 145 | K | Kartenmappe je Kapitel (druckbar) | ruht bis Karten Kapitel 2; Kapitel 1 fertig, [Kartenmappe](https://claude.ai/artifact/UWcwm5V78KkLtvBNY4NRHn); Querlink: [Roter Faden](https://claude.ai/code/artifact/28aa92f2-4263-4c1d-81a4-db5ac3b9d30d) (von Homer) | claude/tom-145-kartenmappe |
| 133 | K | Umsetzung 133: Charisma-Wahlen Kapitel 2, Gespräche (`STORY-WAHLEN.md`, Vorgangsarchiv 133) | wartet auf 41 (Kapitel 2 ist nicht im Spiel: keine Rabenschanze, kein Kultlager, kein Vesk, Ansel, Rask) und 49 (Fertigkeiten, ruht); geprüft 19.10. | – |
| 41.2 | K | Umsetzung 41.2: Ansel fährt nach N3 auch nachts (Vorgangsarchiv 41.2) | wartet auf 41 (Kapitel 2 ist nicht im Spiel) | – |

## Einzelheiten

- **Zu 216.3** (Chef 20.10., 14:57, an Sokrates, Bild: Held im Dorf etwa ein Feld neben der Laterne am Pflaster, Wortlaut): „Näher komme ich nicht an die Lampe ran. Das war schon ein Test der Feedback, dass manche Objekte einfach viel zu großen Sperrkreis haben, sozusagen. Das müsste allgemein geprüft werden. Das hängt zusammen mit meiner Frage, ob man die Felder nicht kleiner machen kann.“ **Befund Sokrates** (`FreeWalk.kt`, main): `footprint()` gibt nur in Räumen den gezeichneten Umriss (Regal, Theke, Tisch, Fass, Pflanze); im Freien füllt jedes gesperrte Ding das **ganze Feld**, dazu der Radius des Helden 0,3. Ein Laternenpfahl hält ihn so mindestens 0,8 Felder von seiner Mitte fern. **Vorschlag:** Umriss je Ding auch im Freien (Laterne, Pfahl, Schild, Brunnen, Fass, Bank, Stand, Baumstamm, Zaunpfosten …) nach dem Bild; ein Werkzeug legt für jedes Ding Umriss und Bild übereinander (Standbild an den Chef) und meldet zu große. Die Mitte des Helden betritt das Feld weiter nie (Wege, Aktionstaste 216.1 unverändert). Felder kleiner machen braucht es dafür nicht (216.2: Felder bleiben). Klasse M? (Perikles, 126): Bedienfehler sind Fehler (216, Direktive 179).
- **Zu 245** (Chef 20.10., 12:24, an Sokrates, Tester-Feedback, Wortlaut): „Ein Feedback eines Testers war auch, dass das alles ganz toll aussieht, aber der Held an sich, vor allem wenn er dann rennt, sehr robotermäßig läuft. Also die Beine bewegen sich zwar, aber der Oberkörper eher so, ja, robotermäßig. Also das, die Bewegung per se sieht da noch nicht so gut aus. Ich glaube, das ist ja allgemein eine MPC-Animierung. Also die Drehungen, dass die weicher werden und vielleicht die Animation fürs Gehen, schräger Laufen auch. Einfach eher auch schon, wie halt so einer läuft.“ (gelesen: „MPC“ = NPC, gilt also für alle Figuren, die dieselbe Gehanimation nutzen.) Sokrates: verwandt mit 239 (Chef: Animationen weich ineinander übergehen) und 19e (Jerry, Monster); Vorschlag zum Prüfen: Oberkörper mit Gegenschwung der Arme, leichtes Wippen und Vorlage beim Rennen, Drehung über einige Bilder statt sofort. Klasse M? (Perikles, 126): Direktive 179 „spielerfreundlich“, der Held ist ständig im Bild.
- **Zu 239** (Chef 11:45): „Animationsübergang bei Garrick (sitzen/stehen) sehr unrund. Vielleicht grds mal schauen bei animationen, dass sie weich ineinander übergehen.“ Gebaut: Hocke 8 Stufen, Aufschrecken 0,55 s, Arbeitsschleifen weich, Sprungtest 0. Jerrys parallele Übernahme (12:09) zurückgezogen (12:23).

- **Zu 26**: Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14. Höhle (13e) ohne Lücke außer Schacht nachts (D3.14) seit 17.10., 09:28. Offen 13.5 Durchspielen durch den Chef. Chef 18.10., 12:4x: nicht als Aufgabe auf die Chefsache, er spielt es von selbst irgendwann mit einem der nächsten Builds durch; sein Feedback zum Durchspielen darf nicht vergessen werden: wer es hört, trägt es hier ein; keine Testbitte mehr.
- **Zu 30:** beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste.
- **Zu 145** (Chef 17.10., 11:5x, über Sokrates): „im Artefakt, das braucht ja auch nicht die Niederlassung, jeweils die Einzelkarten, Gebietsübersichten, Landeskarte … je Kapitel, damit ich das auch drucken kann.“ Je Kapitel Landkarte, Gebietskarten, Grundrisse als druckbares Artefakt „Kartenmappe“ auf der Zentrale (Bilder aus `tools/preview`). Zweig `claude/tom-145-kartenmappe` (nur `tools/preview`, Schalter `KARTENMAPPE=1`) wartet auf Kapitel 2.





