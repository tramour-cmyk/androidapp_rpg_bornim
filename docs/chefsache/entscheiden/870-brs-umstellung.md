# 870 · Ganz auf das BRS umstellen und dafür alles andere anhalten?
Sokrates · 10.11., 14:05 · E Kampf · aus deinem Wort 14:03
Kurz: Umstellung in einem Zug: Liste und Regelfragen (Sokrates), Bau Kampf (Jerry) und Held/Oberfläche (Tom) zugleich, alles andere ruht außer Testfehlern

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main (Godot-Code ohne Tests, Suche nach SRD-Begriffen, 10.11., 14:04)

**Frage:** Du willst den Parallelbetrieb von BRS und SRD beenden und bist bereit, dafür andere Arbeit anzuhalten (14:03: „Und wenn man die anderen dafür wieder anhalten müssen, dann halte ich die gerne an“). Soll die Umstellung so laufen wie unten in A?

**Votum:** „870 A“

**Berührt:** Tom, Jerry (Vorrang), Perikles (Wochenziel, Stopp), Homer (Begriffe im Spiel), 644, 534, 467, 469, 868, 867, 663

**Begründung:** Dein Wort 14:03: „ich hätte jetzt gerne mal tatsächlich die Systemumstellung auf das neue System“. Solange beides läuft, findest du in jedem Test Reste (13:48: „in jedem Kampf … Rüstungsklasse und Würfelwerte“).

**Sachverhalt:**
- Schon BRS: Erschaffung (470, „passt“ 13:37), Fertigkeiten steigen durch Tun (471, t274.18 ✓), Heldenstufe aus Erfahrung (1.3 gebaut), Monsterwerte (1.4 abgenommen), Treffer und Schaden im Kampf (478, t269 ✓).
- Noch SRD: Der Held ist ein Doppelwesen. Neben dem BRS-Stand laufen die alten Heldwerte mit (Klasse, Stärke bis Charisma, Rüstungsklasse, Übungsbonus, Rettungswürfe, Zauberplätze). Im Code an rund 30 Dateien, am meisten im Kampf (`mars.gd`, `klassisch.gd`, `aufruf.gd`), im Menü (`menue.gd`), in den Heldwerten (`heldwerte.gd`), bei Beute (`beute.gd`) und der alten Erschaffung (`erschaffung.gd`).
- Was dazugehört: Anzeigen im Kampf und im Heldenblatt (868), Gegenstände mit AC und Zusatzwerten (644), Zauber und Fähigkeiten nach Klassen (534), Ausdauer (467), Ring ohne Klassen (469), klassischer Kampfmodus, alte Erschaffung, alte Spielstände.
- Offene Regelfragen, die den Bau aufhalten (`DESIGN-BRS.md` Abschnitt 13, bei Sokrates): Fähigkeiten ohne Klassen (was bleibt von Riposte, Lebensraub, Untote vertreiben), Ausdauerformel, Zusatzeigenschaften der Gegenstände in BRS-Werten, Übernahme alter Spielstände, Gefährten ohne Klassen.

**Auswertung:**
- **A (Empfehlung) Umstellung in einem Zug:** (1) Sokrates legt in einem Tag die Umstellungsliste vor (jede SRD-Stelle mit ihrem BRS-Ersatz) und alle offenen Regelfragen in einer Chefsache. (2) Danach bauen Jerry (Kampf: Rechnung, Anzeigen, Zauber und Fähigkeiten, Ausdauer, Ring; klassischer Modus weg) und Tom (Held und Oberfläche: alte Heldwerte weg, Menüs, alte Erschaffung weg, Gegenstände und Beute, Spielstände, Hauptmenü 867) zugleich. (3) Alles andere ruht, nur Fehler aus Tests gehen vor; 709 bringt Jerry vorher zu Ende. (4) Am Schluss Wächter: die Commit-Prüfung hält jeden neuen SRD-Begriff im Godot-Code an; Hinweis „SRD 5.1 · CC BY 4.0“ raus. Fertig, wenn die Suche nichts mehr findet und du Dorf bis Wolfskampf nur mit BRS spielst. Kosten: Schätzung kommt mit der Liste; zum Vergleich: der Rechenkern allein (478) brauchte etwa 6,50 $.
- **B Nur die Anzeigen jetzt (868), Rest nach Plan:** klein und schnell, du siehst im Kampf keine Rüstungsklasse mehr; der Parallelbetrieb bleibt darunter, Reste tauchen weiter auf.
- **C Noch nicht:** erst Kampfbewegungen (709 und Folgende), dann Umstellung.
- **Stärkstes Gegenargument gegen A:** Alles andere steht mehrere Tage, und das Guthaben reicht diese Woche nur knapp (826). Antwort: genau die Arbeit, die jetzt läuft, müsste nach der Umstellung zum Teil ohnehin neu gemacht werden (Menüs, Anzeigen, Gegenstände bauen heute auf den alten Werten auf); Spike und Tuffy bleiben aus.

**Folgerungen:** A: Sokrates schreibt Liste und Regelfragen (870), Perikles hält alles andere bei Tom und Jerry an (außer Testfehlern und 709), danach Bau. B: 868 bei Jerry nach vorn. C: 870 ruht.

Antwort: …
