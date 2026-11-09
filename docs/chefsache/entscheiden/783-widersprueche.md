# 783 · Acht Widersprüche im Regelwerk: welche Seite gilt?
Diogenes · 09.11., 20:11 (Vorlage 18:15, W5, W6, W8 entschieden, W1 neu) · B Abläufe · 745 A2 Schritt 2
Kurz: acht Widersprüche zwischen zwei Regeln, je einer gilt

Geprüft an: Lauf 111 in `docs/PRUEFBERICHT.md` (jede Stelle am Wortlaut nachgelesen, Stand `main` 09.11., 18:13)

**Entschieden:** W6 wie Vorschlag (Chef 20:00, Archiv). W5 andersherum: Regel A gilt (Chef 20:05, Archiv); CLAUDE.md Zusammenarbeit 3 „Nie selbst“ nimmt in Schritt 3 den Vorentscheid Sokrates aus. W8 wie Vorschlag mit Zusatz (Chef 20:07, Archiv): Sokrates legt auch für andere an; wer nach einer Antwort löscht, trägt jeden daraus folgenden Auftrag dem Betroffenen ein. Offen: W1–W4, W7.

**W1 neuer Vorschlag (Sokrates 20:11, nach Chef 20:10: „über eine Animation kann nur ein Film entscheiden, da brauche ich vorher kein Probebild … im Zweifelsfall auch mich fragen“):** (1) Bewegung (Animation, Ablauf, Kampf): gleich Film, kein Probebild an den Chef. Vorher macht der Ersteller für sich ein Einzelbild am Rechner (`PROBEBILD=`, kostet keinen Lauf) und sieht selbst nach, ob Inhalt da ist (kein Weißbild, richtiger Ort); kein Helfer. (2) Aussehen eines Standes (Farbe, Form, Licht): Standbild als Vorlage, kein Film. (3) Unklar: eine Zeile „Probebild oder gleich Film?“ in der Vorlage an den Chef. Werkzeug: `probelauf.py` kehrt 511/578 um (Film frei ohne Freigabe des Probebilds; Laufgrenze 389 bleibt). Gegenargument: Anlass 511 waren kaputte Filme; das eigene Einzelbild fängt leere Bilder, nicht falsche Bewegung. Die fängt aber auch ein Probebild nicht.

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

**Stellungnahme Sokrates (09.11., 19:07):** Stärkstes Gegenargument: W1, W4, W5 und W8 sind keine offene Frage. `CLAUDE.md` steht über allen Dateien und sagt es schon: Probebild selbst ansehen, kein Helfer danach (Zusammenarbeit 9); Neustart mit Link; nie selbst Balance oder Spielgefühl; Chefsache beantwortet heißt weg. Diese vier könnte Perikles ohne Frage an den Chef angleichen, die Datei kostet ihn vier Urteile, die nicht nötig sind. Gegen Entschiedenes verstößt kein Vorschlag. W5 schränkt meinen Vorentscheid ein, und so ist es richtig. W6 trifft meine Lehren; Diogenes' Trennung ist die, nach der ich schon arbeite. Kosten: Schritt 3 sind kleine Textänderungen bei Perikles, keine Werkzeuge. Empfehlung: „783 wie Vorschlag“, echte Fragen sind nur W2, W3, W6 und W7; die anderen vier hätten als Liste an Perikles gereicht.

Antwort: „783 wie Vorschlag“ oder je Punkt „W<n> A“ / „W<n> B“.
