# 1284b · Der Held selbst verdeckt den Rattenbiss, nicht sein Nachbar: wie soll man ihn sehen?
Jerry · 16.11., 11:56 · E Kampf · aus deinem „1284a A“ (16.11., 10:11), Messung danach
Kurz: Nachbar zur Seite gebaut, hilft kaum (verdeckt 14 statt 15 von 54 Bissen); die Zähne liegen hinter dem Helden selbst.
Beim Chef, weil: Aussehen

Geprüft an: [Commit a71c46f61](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/a71c46f61) (Zweig `claude/jerry-1072-mess`, Messung `biss_1284` am Rechner mit der gekauften Ratte, Würfe 7, 9, 13)

**Frage:** Du hast „1284a A“ gesagt: die Ratte beißt schräg von vorn, und wo kein Platz frei ist, tritt der Nachbar zur Seite. Das ist gebaut. Die Messung zeigt aber: Es ist fast nie der Nachbar, der verdeckt. Die Kamera schaut flach (25°) über die Helden auf die Gegner; die Ratte ist 0,5 m hoch und kommt von der Gegnerseite. Von vorn bis ganz von links (90°) liegen ihre Zähne hinter dem Körper des Helden, der sich zu ihr dreht; rechts steht sein Schild davor, noch weiter rechts ist der Platz aus dem Bild. Wie soll man den Biss sehen?

**Votum:** „1284b A“: beim Biss eines kleinen Tiers hebt sich die Kamera kurz steiler, aber nur, wenn die Planung meldet, dass das Ziel die Zähne verdeckt (etwa jeder vierte Rattenbiss).

**Berührt:** 1284 (Jerry), 1402 Kampfkamera (großes Thema, Vorlage), 1072 (Nachbar zur Seite bleibt drin).

**Begründung:** Du hast 15.11., 14:54 gesagt: „man sieht nicht, ob sie trifft oder nicht, weil da steht ja genau der Held dann davor“. Mit fester Kamera gibt es von der Gegnerseite aus fast keinen Platz, an dem das geht. Die Planung weiß schon vorher, ob verdeckt ist; dann bewegt sich die Kamera nur, wenn es nötig ist.

**Sachverhalt:**
- Verdeckte Bisse (Zähne zu über der Hälfte hinter dem Ziel), Würfe 7/9/13, 54 Bisse: vor dem Bau 8/2/5, mit Nachbar zur Seite und geprüfter Drehung 6/2/6. Der Nachbar trat in 54 Bissen 2-mal zur Seite.
- Bisse, die vor Körper oder Schild in die Luft gingen: vorher 1/2/1, jetzt 0/0/0 (das ist besser geworden).
- Ursache nachgestellt (Wurf 7, Held mit Schild, erster Biss): an jedem Platz von 0° bis −90° „Zähne hinter dem Helden“; bei +40° steht der Schild davor, ab +60° liegt der Platz aus dem Bild.
- Alte Fassung: flaches Bild ohne Tiefe, dort konnte nichts verdecken (`BattleScreen.kt` 948).

**Auswertung:**
- **A (Empfehlung): Kamera nur bei verdecktem Biss kurz steiler** (etwa 40° statt 25°, hin und zurück je 0,3 s). Kosten: etwa eine Sitzung, Film zum Ansehen. Bewegt sich nur bei etwa 14 von 54 Bissen.
- **B: Der Held dreht sich nicht zur Ratte**, sie beißt seine Seite. Kosten: eine Sitzung; offen, ob es reicht (Messung erst danach); der Held wirkt dann teilnahmslos.
- **C: so lassen**, Ausgang steht im Bericht. Kosten: keine; etwa jeder vierte Rattenbiss bleibt unsichtbar.
- **D: warten auf 1402** (Kampfkamera als großes Thema). Kosten: keine jetzt; bis dahin wie C.
- **Stärkstes Gegenargument gegen A:** Es nimmt einen Teil von 1402 vorweg; eine Kamera, die sich ab und zu hebt, kann unruhig wirken.

**Folgerungen:** Nach A baut Jerry, misst mit `biss_1284` (Ziel: höchstens 1 verdeckt je Wurf) und schickt einen Film. Nach B ebenso. Nach C oder D geht der jetzige Stand (Nachbar zur Seite, keine Luftbisse) in den nächsten Sammelbuild.

Antwort: …
