# 1284a · Wie soll der Biss der Riesenratte sichtbar werden, wenn der Held davorsteht?
Jerry · 15.11., 23:03 · E Kampf · aus deinem Wort zum Film 1284 (15.11., 14:54)
Kurz: Die Ratte beißt von hinter dem Helden und ist verdeckt; Platz zur Seite reicht nur, wo er frei ist.
Beim Chef, weil: Aussehen

Geprüft an: [Commit 17736510a](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/17736510a) (Zweig `claude/jerry-1284-anlauf`, Messung `biss_1284` am Rechner mit der gekauften Ratte)

**Frage:** Im Kampf schaut die Kamera flach (25° von oben) über die Helden auf die Gegner. Die Riesenratte ist klein (0,5 m hoch) und kommt von der anderen Seite. Beißt sie den Helden von vorn, steht der Held genau zwischen Kamera und Ratte: man sieht nicht, ob sie trifft. Du hast gesagt (14:54): „man sieht nicht, ob sie trifft oder nicht, weil da steht ja genau der Held dann davor“ und „wenn ich zubeiße, laufe ich doch auf jemanden zu, nicht neben jemanden“. Wie soll der Biss sichtbar werden?

**Votum:** „1284a A“: die Ratte nimmt einen Platz schräg vor dem Helden, wo er frei ist (gebaut), und wenn keiner frei ist, rückt der Nachbar beim Biss kurz zur Seite.

**Berührt:** 1284 (Jerry), 1072 Plätze am Gegner (Jerry, ruht bis 930.6), 709 Treffer sichtbar (ruht).

**Begründung:** Die Ratte läuft auf ihr Ziel zu und beißt von vorn auf ihr Ziel, nur schräg statt genau von hinten. Das ist dein Wort, und die Kamera bleibt, wie du sie abgenommen hast.

**Sachverhalt:**
- Vor dem Bau lagen bei 7 von 11 Bissen Kopf und Kiefer der Ratte im Bild ganz hinter dem Helden (Messung `biss_1284`, Probekampf Ratten, Kämpfer und Kleriker).
- Am Stabträger (ohne Schild) fand die Ratte gar keinen Platz und biss aus 1,35 m: Die Zähne blieben 0,39 m vor ihm, darum „steht neben ihm“. Das ist behoben: jetzt 0,02 m.
- Gebaut: Die Ratte sucht bis 90° zur Seite den ersten Platz, an dem ihre Zähne sichtbar bleiben. Im Probekampf ist danach nur noch 1 von 11 Bissen verdeckt.
- Aber im Stand von Build 290 (andere Würfe, mehr Treffer) sind 8 von 20 verdeckt: Neben dem Helden steht der Söldner, oder der Platz liegt am Bildrand. Der Bau ist darum nicht in Build 290.
- Alte Fassung: ein flaches Bild ohne Tiefe, dort konnte nichts verdecken (`BattleScreen.kt` 948).

**Auswertung:**
- **A (Empfehlung): Platz schräg vor dem Ziel, Nachbar rückt.** Ist kein Platz frei, tritt der Nachbar für den Biss einen halben Schritt zur Seite und danach zurück. Kosten: etwa eine Sitzung, Messung mit `biss_1284` auf mehreren Würfen.
- **B: Kamera beim Biss.** Beim Biss eines kleinen Tiers hebt sich die Kamera kurz steiler (etwa 40° statt 25°), dann sieht man über den Helden. Kosten: etwa eine Sitzung, aber die Kamera bewegt sich öfter.
- **C: so lassen, wie gebaut.** Seitenplatz, wo er frei ist, sonst verdeckt wie bisher. Kosten: keine, aber etwa jeder dritte Biss bleibt unsichtbar.
- **Stärkstes Gegenargument gegen A:** Der Nachbar bewegt sich bei jedem Rattenbiss ein wenig, das kann unruhig wirken, und es greift in die Plätze am Gegner (1072) vor.

**Stellungnahme Sokrates (15.11., 23:06):** Stärkstes Gegenargument: Das „Nachbar rückt“ aus A ist das Platzmachen aus 1072 (Plätze am Gegner, deine Idee 13.11., 23:23 „einer … ein Stück rutscht“). Dort hast du um 23:35 gestoppt, damit nicht jedes Tier einzeln geflickt wird. Seit 930.6 ist 1072 wieder startbar. Das Thema hat schon über 160 $ gekostet (709.1, 709, 1072). Empfehlung: A, aber das Rücken baut Jerry einmal in 1072 für alle Gegner, nicht nur für die Ratte in 1284; der Seitenplatz geht schon jetzt in den nächsten Build.

**Folgerungen:** Nach A oder B baut Jerry, misst mit `biss_1284` auf mehreren Würfen und legt einen Film vor. Nach C geht der Bau so in den nächsten Build.

Antwort: …
