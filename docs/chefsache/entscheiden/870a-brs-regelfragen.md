# 870a · Was wird aus der Kotlin-Fassung, und wie wirken Schwächen der Monster?
Sokrates · 10.11., 15:12 (Fassung 14:45, 1–6 entschieden 15:08) · E Kampf · aus deinem Wort 14:03, 14:08, 15:04
Kurz: zwei Fragen offen; 7 willst du ausführlich besprechen, 8 ist deine Idee von 15:04

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/dcc60878f (Bestandsaufnahmen 10.11., 14:33–14:41); gegengelesen von Diogenes (870.1, `PRUEFBERICHT.md` Lauf 134), eingearbeitet 15:1x

**Frage:** Fragen 1–6 hast du entschieden (Archiv, `DESIGN-BRS.md` 7 und 11). Offen sind 7 (Kotlin-Fassung) und 8 (Schwächen der Monster). Wie sollen sie gelten?

**Votum:** 7 im Gespräch; „870a 8A“

**Berührt:** Tom (Schritt 8, Export), Jerry (Schritt 5), Homer (Texte zu 8), Perikles (`android.yml`, Release), 427 (Bestiarium), 481

**Begründung:** Diogenes hat meinen Plan gegengelesen. Was davon 7 betrifft, steht unten berichtigt. Seine Kostenschätzung ist besser belegt als meine: Tom und Jerry kosten im Mittel 20–22 $ je Sitzung, darum eher **350–500 $** statt 120–200 $.

**Sachverhalt:** wie unten je Frage.

**Auswertung:**

**7. Die Kotlin-Fassung** (berichtigt nach Diogenes).
Was heute stimmt:
- Jeder Push auf `main` baut die Kotlin-App. In den Play-Kanal kommt sie nur, wenn jemand den Upload von Hand startet (`android.yml` 99). Meine Fassung 14:45 hatte „bei jedem Push hochgeladen“ geschrieben; das war falsch.
- Der Godot-Bau holt aus Kotlin Karten, Intro, Bilder, Kampfklang (`godot.yml` 358) und Texte. Darunter sind auch der Über-Text und das Handbuch mit dem Satz „Die Regeln folgen … SRD 5.1“, und die zeigt das Godot-Spiel heute an.
- Das Repo ist öffentlich. Solange `core/` mit SRD-Inhalt darin liegt, verlangt die Lizenz CC BY 4.0 den Hinweis. Der Wächter `regelcheck.py` meldet zu Recht einen Fehler, wenn er fehlt.
- Rechtlich ist das SRD kein Risiko: CC BY erlaubt die Nutzung, auch kommerziell, nur mit Nennung. Dein Ziel „nichts mehr mit SRD … zu tun“ ist darum eine Frage der eigenen Handschrift und der Ordnung, nicht des Rechts.

Drei Wege:
- **A (meine Fassung 14:45):** Im Umzug ersetzt Godot nur Regeltexte und Heldendaten durch eigene (Schritt 8: Handbuch und Über-Text neu, ohne SRD-Satz). Karten, Intro und Bilder kommen weiter aus Kotlin. Der Hinweis bleibt im Repo, im Godot-Spiel fällt er weg. Über die Kotlin-App entscheiden wir nach dem Umzug.
- **B (ganz raus):** Im Umzug zieht Godot auch Karten, Intro, Bilder und Klang in den eigenen Ordner. Danach wird die Kotlin-App nicht mehr gebaut, `core/` und `app/` gehen ins private Zweit-Repo, der Hinweis fällt überall. Kosten: etwa 2–3 Sitzungen mehr (rund 40–70 $). Die alte Fassung ist dann nur noch Nachschlagequelle im Zweit-Repo; heute lesen wir sie oft für den Abgleich (620.2).
- **C (Mitte):** wie B, aber die Kotlin-App wird nur nicht mehr gebaut, und `core/` bleibt bis zur Veröffentlichung lesbar im Repo, samt Hinweis. Billig, und die Teams behalten die Quelle für den Abgleich.

Damit wir im Gespräch schnell sind: Was liegt dir an 7 am meisten am Herzen?
- (a) dass im Spiel nichts mehr nach SRD aussieht oder klingt (Wege A, B und C leisten das alle);
- (b) dass das Repo sauber ist (nur B);
- (c) dass der Play-Kanal nur noch Godot hat (B, C);
- (d) etwas anderes?

~~Mein Stand vor dem Gespräch: C.~~ **Neu 15:1x: B.** Den Ausschlag gibt ein Befund, den ich unterschätzt hatte: Kotlin ist heute noch die *Quelle* für Godot-Inhalte. Seit 01.11. gab es 12 Commits in `core/src/main` für Godot-Arbeit (Schenke 604, Häuser 664, Sammelaufträge 356.2 am 08.11.). Jeder Godot-Bau übersetzt Kotlin mit Gradle und exportiert daraus Karten, Texte, Held, Intro, Kartenblätter, Bilder der Dinge und Klang (`godot.yml` 48–65, 358).
- **Vorteile B:** Eine Sprache und eine Quelle, kein Umweg über Kotlin für Dorf und Quests. Schnellere Godot-Builds ohne Gradle. Keine Golden-Tests gegen Kotlin mehr. Der Hinweis fällt überall. `android.yml` baut nicht mehr bei jedem Push. Der Umzug ist wirklich abgeschlossen.
- **Gefahren und Gegenmittel:** (1) Karten sind in Kotlin Code mit Tests (`VillageRoundTest` u. a.); in Godot werden sie Daten. Gegenmittel: einmal exportieren, die Dateien in `godot/daten` als neue Quelle einchecken, Kartenregeln als Godot-Tests mitnehmen. Vorher prüfe ich, wie Tom künftig Karten bearbeitet (Werkzeug oder Datei). (2) Abgleich mit alt (620.2) wird mühsamer. Gegenmittel: Zweit-Repo und Git-Verlauf bleiben lesbar. (3) Offene Zweige, die `core/` ändern, müssen vorher fertig sein (Schritt 0). (4) Das Godot-Spiel läuft noch unter der Testkennung `de.bornim.game.godot`. Die Store-Kennung `de.bornim.game` hat heute die Kotlin-App; der Wechsel gehört zur Veröffentlichung und ist deine Sache (nicht Teil des Umzugs).
- **Kosten:** etwa 2–4 Sitzungen mehr (rund 50–90 $).

**8. Schwächen und Stärken der Monster (dein Wort 15:04).** „Monster X hat eine Schwäche gegen Feuer, aber wird gestärkt, wenn das und das passiert“; mit Alchemie herstellen, „was halt das eine Monster dadurch stärkt vielleicht das nächste Monster … dass halt vorher nicht immer die ultimative Lösung ist, also eine kleine Brandbombe“.

Sachverhalt:
- Schwächen gibt es nur in der alten SRD-Form. Die Schadensarten sind Stich, Hieb, Wucht, Gift und Heilig; „verwundbar“ heißt doppelter Schaden, „resistent“ halber, „immun“ keiner. Beispiele: Das Skelett ist verwundbar gegen Wucht, Untote sind immun gegen Gift. Dazu gibt es ein SRD-Talent „ab INT 12 erkennst du Schwächen“.
- Das steht in `Monsters.kt` und `klassisch.gd`. **Im MARS-Kampf, den du spielst, wirkt davon nichts.** Das Bestiarium hat keine Spalte dafür.
- Mein Plan hatte die Schadensarten übersehen; ich habe sie in Schritt 5 nachgetragen.
- Alchemistenfeuer (von Goblins) und Weihwasser (von Untoten) gibt es schon als Beute.

Wege:
- **A (Empfehlung):** Wenige Schadensarten mit eigenen Namen: Schnitt, Stich, Wucht, Feuer, Gift, Säure, Licht.
  - Je Monsterart höchstens eine **Schwäche** (+50 % Schaden) und eine **Stärke** (−50 %). Immun nur, wo die Natur es verlangt (Untote gegen Gift).
  - Dazu dein Kern, die **Gegenwirkung**: Bei zwei bis drei Arten je Kapitel macht das falsche Mittel den Gegner stärker oder kostet etwas.
  - Vorschläge für Kapitel 1 (Zahlen aus 444, Namen und Texte von Homer): Der Ockerschleim teilt sich bei Wucht und Schnitt einmal in zwei kleine; Feuer trifft voll, hier ist die Brandbombe richtig. Die Riesenspinne fürchtet Feuer, aber Feuer verbrennt ihre Spinnseide (Beute). Das Wolfsrudel flieht vor Feuer: Der Kampf ist schnell vorbei, aber Fell und Erfahrung sind weg. Beim Skelett wirkt Gift nicht, Feuer halb, Wucht stark.
  - **Wissen statt Raten:** Die Schwäche zeigt sich im Kampf in Text und Bild („Der Schleim teilt sich“) und steht danach im Bestiarium. Mit der Fertigkeit Wissen sieht man sie schon vorher; das ersetzt das SRD-Talent.
  - Deine Witcher-Idee hängt sich hier an, Weihwasser eingeschlossen: Kampftränke und Wurfmittel haben eine Schadensart. Man kann sie kaufen, erbeuten und später mit Alchemie herstellen.
- **B:** Nur die alten SRD-Werte umbenennen (doppelt, halb, keiner), ohne Gegenwirkung. Weniger Arbeit, aber dann bleibt es bei der einen richtigen Lösung je Monster, genau das, was du nicht willst.
- **C:** Im Umzug fallen die Schadensarten weg, Schwächen kommen danach als eigener Vorgang. Sauber getrennt, aber dann wird zweimal an denselben Monstern, Waffen und Tränken gebaut.

Gegenargumente gegen A:
- **Stärkstes Gegenargument:** Eine Gegenwirkung, die man nicht kennen kann, bestraft Unwissen. Das ist Frust, keine Wahl. Antwort: Sie ist beim ersten Mal sichtbar und nie tödlich: ein geteilter Schleim oder eine verlorene Beute, nie ein Sofortsieg des Gegners. Danach steht sie im Bestiarium, und mit Wissen sieht man sie vorher.
- **Zweites Gegenargument:** Kapitel 1 hat noch kaum Alchemie. Antwort: Die Mittel gibt es in Kapitel 1 als Beute und beim Händler. Das Herstellen kommt mit der Meisterschaft Alchemist dazu, ohne dass sich die Regel ändert.

Aufwand: etwa eine Sitzung mehr in Schritt 5 (Jerry), die Spalte im Bestiarium (ich), Texte von Homer.

**Folgerungen:** Nach 8 trage ich die Regel in `DESIGN-BRS.md` 7 und ins Bestiarium ein; nach dem Gespräch zu 7 berichtige ich Schritt 8 und 9 des Plans. Die Vorgänge 870.2 ff. lege ich für die Schritte 2–6 schon jetzt an, denn die hängen an 7 nicht. Die Pause von Tom und Jerry bleibt bis 13.11., 20:00.

Antwort: …
