# Vorrat Homer

Spiel und Design: Story, Texte, Stil, Aussehen, Spielgefühl, Balance, Ideen (`ROLLE-KREATIV.md`). Reihenfolge = Vorrang. Größe höchstens etwa 15 KB.


**Gelesen bis:** `4e1733a8` (23.10., 07:55)

**Übergabe (23.10., 07:55):** 332.1 Umrüstzeilen in `STORY-SPIEL.md`; 326 drei Entwurfsbilder (Vorschau aus dem Spielcode, Zweig `claude/homer-326-entwurf`) in Chefsache 326. Nachfolger: Homer – auf Abruf.


## Zeilen

| Nr. | Kl. | Thema | Stand |
|---|---|---|---|
| 326 | K | **von Chef über Sokrates (23.10., 00:03):** Spielermenü und Aktionsknöpfe im Stil des Hauptmenüs (Zu 326) | wartet auf Chef: drei Bilder heute/Entwurf in Chefsache 326; Entwurf im Zweig `claude/homer-326-entwurf` (`ENTWURF326=1`); bei Ja Zeile an Tom |
| 302 | K | **von Chef über Sokrates (22.10., 12:12):** Bildsignatur: ist unser Stil wiedererkennbar, wie machen wir ihn einzigartig? (Zu 302) | wartet auf Tom (302.1 Schätzung) und Meilenstein: Bestand entschieden 20:25 (Vorgangsarchiv), Figuren zuerst; Umriss schätzt Tom (302.1); `DESIGN-STIL.md` „Signatur“ nachgezogen (Bestand, Linie im Zeichner, 07:58) |
| 41 | K | Storyplan; Texte Kapitel 2 | ruht: Storyplan und Texte Kapitel 2 fertig, Bau nach dem Meilenstein (179); 5b bleibt „noch nicht“ (Zu 41) |
| 72 | K | Profil und Kampfsystem | ruht: nichts offen bei Homer; 72g–72j gehören zu 45 (Sokrates); Bau bei Jerry; `DESIGN-KAMPF.md`, [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) |

- **Zu 326** (Auftrag 00:03): Spielermenü (System samt Aufbau, Held, Tasche, Ausrüstung, Chronik, Tooltips) wirkt neben dem Hauptmenü alt; prüfen, nicht bauen; Karte ausgenommen (Chef 00:06).
- **Zu 326** (Chef 23.10., 07:25, an Sokrates): (1) Ohne Vorschaubild kann er sich die Empfehlungen nicht vorstellen: je Empfehlung vorher/nachher als Bild (über Tom, Bild höchstens 60 KB). (2) Es fehlt, was das Hauptmenü vormacht: große Textknöpfe durch schöne Zeichen ersetzen, wie Sprache, Musik, Effekte dort. (3) Frage: die Aktionsknöpfe im Spiel wirken neben den Zeichen des Hauptmenüs klotzig; angleichen? Mitprüfen, mit Bild.
- **Zu 326** (Chef 23.10., 07:29, an Sokrates): Richtung gebilligt („lasst das mal so machen“): Zeichen statt Textknöpfen, Erklärung bei langem Druck („finde ich … clever“); Vorbild die Reiter im Spielermenü (sprechende Zeichen mit etwas Text). Auftrag: zwei, drei Bilder fertigen (vorher/nachher), dann wieder an Chef.
- **Zu 326, von Sokrates (23.10., 08:38):** Bildprüfung in der Chefsache 326 (Stellungnahme): Reiterleiste ~7 px und grauer Rahmen unverändert, Ringe grau statt golden, Rennknopf anders als Feuerknopf, Stiefel zu dunkel. Vor dem Bau nachziehen, sonst wirkt es nicht durchgängig.
- **Zu 326** (Chef 23.10., 08:58, an Sokrates): Richtung „echt gut“, neues Systemmenü „deutlich besser“. Aber: alle Reiter angleichen (Held, Tasche, Ausrüstung, Chronik, System, für Tester Test), nur die Karte nicht. Das Zeichen für Aktion ist „altbacken, grob pixelig“, Rennen sieht „ganz komisch“ aus, beides überarbeiten. Dazu die Punkte der Bildprüfung von 08:38. Konkreter Vorschlag von Sokrates im Chat 09:0x.
- **Zu 41** (Thema, Stand im Wortlaut): Storyplan; Texte Kapitel 2 | **168 D** (18.10.): Garrick fest in K2, Söldner ab K3; Grund und Satz „kommt mit“ in Storyplan und Texte. Storyplan `STORY-PLAN-K2.md` Kapitel 2 fertig (ohne 5b). Textentwurf `STORY-K2-ENTWURF.md` frei seit 72s.1 (entschieden 18.10.), nach dem Meilenstein; Prüfpunkt 6.4 = 41.2, ja (19.10.); Zeilen zu 41.1 geschrieben (19.10.); nichts offen. **D4.1 A** (Chef 15.10., 10:5x): Texte zur Quest vor der Höhle (Morwen, Garrick warnt unter Stufe 3) mit dem Chef, dann Tom
- **Zu 72:** 72a eingetragen (Leitbild, 19.10.); 72c, 72e entschieden 19.10.; Entschiedenes im Vorgangsarchiv; Chefsache 72g (19.10., 21:34).
- **Zu 302** (Chef 22.10., 12:12, an Sokrates, Wortlaut): „Ich meine, wir versuchen ja hier was Einzigartiges in Gänsefüßchen zu kreieren. Und kann unser Zeichenstil, unser Animationsstil, unsere Art und Weise, wie wir Figuren und Umgebung präsentieren, eigentlich auch so eine Art Signature sein, dass man das sozusagen wiedererkennt? Oder ist das, wie wir oder wie du jetzt die Grafiken und so machst, Standard, dass bei allen anderen auch so aussieht grundsätzlich? … Aber ist unsere Grafik sozusagen auch einzigartig? Oder können wir die in irgendeiner Art und Weise dann einzigartig machen?“ Einschätzung Sokrates im Chat 12:1x: heute nicht wiedererkennbar (glatte Puppen wie viele Indiespiele); einzigartig ist das Verfahren (alles aus Code gezeichnet, jede Ausrüstung sichtbar); Signatur aus wenigen festen Zwängen: Licht nur aus sichtbarer Quelle, Tuschelinie wie in einer Chronik (`MapSheet.ink`), Gold als einziger Glanz.
