# 783 · Acht Widersprüche im Regelwerk: welche Seite gilt?
Diogenes · 09.11., 18:15 · B Abläufe · 745 A2 Schritt 2
Kurz: acht Widersprüche zwischen zwei Regeln, je einer gilt

Geprüft an: Lauf 111 in `docs/PRUEFBERICHT.md` (jede Stelle am Wortlaut nachgelesen, Stand `main` 09.11., 18:13)

**Frage:** Welche Seite gilt jeweils? Die andere streicht Perikles in Schritt 3.

**Votum:** „783 wie Vorschlag“, oder je Punkt abweichend („W3 andersherum“). Vorschlag = die jüngere oder genauere Entscheidung des Chefs; wo keine dasteht, mein Vorschlag mit Gegenargument.

| Nr. | Regel A | Regel B | Vorschlag |
|---|---|---|---|
| W1 | Film nur mit geprüftem Probebild, ein Helfer prüft es; „ersetzt die Ausnahme 461a, 480“ (`LISTE-BAUEN-TESTEN.md` Prüftreppe 4; 511, 03.11.) | Ausnahme 461a, 480 gilt weiter; „ein Helfer danach entfällt“ (`ROLLE-ENTWICKLUNG.md` „Was du nicht tust“ und „Aussehen urteilt nur der Chef“; 655, 08.11.) | Probebild bleibt Pflicht, der Ersteller sieht es selbst an (655 ist jünger); Ausnahme 461a/480 gestrichen (511). Gegenargument: ohne Helfer fängt niemand einen kaputten Film vor dem Senden. |
| W2 | weniger als 4 Punkte im Build, wenn der älteste 2 Tage wartet (dann 3) (`LISTE-CHECK-BUILD-TEST.md` Punkt 3) | weniger als 4 nur auf „jetzt“ des Chefs (dieselbe Liste, Punkt 10) | Punkt 3 gilt (genauer); Punkt 10 verweist darauf. |
| W3 | Kür nur, wenn auch keine Übernahme startbar ist (`ROLLE-ENTWICKLUNG.md` „Was du tust“) | Übernahme erst, wenn das eigene Team nichts Startbares hat, also auch keine Kür (`ROLLE-ENTWICKLUNG.md` „Übernahme“) | Muss des anderen Teams vor eigener Kür (126 Muss vor Kür). Gegenargument: mehr Wechsel zwischen den Bereichen. |
| W4 | Neustart im Chat: „Weiter in <Titel>: <Link>“ (`CLAUDE.md` Zusammenarbeit 9) | „weiter in <Titel>“ bzw. „nur den Namen“ (`LISTE-RELEASE-NEUSTART.md` Neustart 1a und 3) | `CLAUDE.md` gilt (mit Link). |
| W5 | Sokrates entscheidet vor: „Abläufe jeder Größe und Einzelheiten zu Balance und Spielgefühl“ (`ROLLE-BERATUNG.md` „Entscheidet selbst“) | Abläufe gehören Perikles (dieselbe Datei, „Was du nicht tust“); „Nie selbst: … Spielgefühl, Balance“ (`CLAUDE.md` Zusammenarbeit 3) | `CLAUDE.md` gilt: Sokrates ohne Vorentscheid zu Abläufen, Balance, Spielgefühl. Gegenargument: mehr Fragen beim Chef (Kennzahl „ersparte Fragen“). |
| W6 | Chefwort sofort als Auftrag in den Vorrat des Besitzers (`CLAUDE.md` Zusammenarbeit 5) | erst Votum mit Gegenargument, „nie gleich als Bauauftrag“; erst im Chat antworten, dann eintragen (`ROLLE-BERATUNG.md`, Lehren 04.11., 02.11., 15.10.) | Beides, klar getrennt: Frage oder Idee des Chefs → erst Votum; Auftrag → sofort eintragen (Anlass 717). Gegenargument: die Grenze Frage/Auftrag zieht weiter die Sitzung. |
| W7 | Morgenmeldung „nur eine Zeile: ‚Tagesbericht kommt 7:30‘ oder ‚Ford steht‘“ (`LISTE-WOCHENPLAN.md` Tag 7:00; 448) | Morgenmeldung mit Zahl offener Chefsache, Hinweis Marktstart, „Bitte Bild der Nutzung“ (`LISTE-BETRIEB.md` Ablauf 10) | Wochenplan gilt (448 ersetzt den Stand zum Marktstart); Bitte um das Bild der Nutzung wandert in den Tagesbericht. |
| W8 | Chefsache: „jeder nur seine“ (`CLAUDE.md` Feste Regeln „Chefsache“) | beantwortet: Datei löschen „auch die eines anderen“ (`chefsache/README.md`, 383.3, Chef 27.10.) | README gilt (Chefwort 383.3); `CLAUDE.md` „anlegen jeder nur seine“. |

**Berührt:** 745, 783; Schritt 3 (Perikles) erst nach dieser Antwort für W1–W8.

<details><summary>Was nicht hier steht</summary>

- Überholtes (eine spätere Chefentscheidung steht schon da, z. B. „Ford 2“ nach 650.1, Sperre 620.1 B ohne 779, Uhrzeit mit `date` gegen Zeile „Uhr:“) und Doppelungen gehen ohne Frage als Liste an Perikles (Vorgang dazu in der Vorgangsliste).
- Verworfen nach Nachlesen: Ford-Wache (kein Widerspruch), Archivieren „sofort“ (betrifft `send_message`), Release-Rückfrage (Datei verlangt), 383 in der Übersicht (nicht mehr offen).
- Nicht geprüft: `DESIGN-…`, `STORY-…`, `LISTE-` außerhalb der drei Bereiche (Bauen/Testen, Beratung/Prüfung/Kreativ, Betrieb/Projekt).
</details>

Antwort: „783 wie Vorschlag“ oder je Punkt „W<n> A“ / „W<n> B“.
