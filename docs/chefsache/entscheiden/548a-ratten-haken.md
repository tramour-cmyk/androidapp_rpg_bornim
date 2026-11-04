# 548a · Rattenkampf und Testknöpfe: wo hast du getippt?
Team Jerry · 04.11., 01:16 · E Kampf · berührt 548, 545

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/c5b07332f (Zweig claude/jerry-545-testknoepfe, Tests welt_548, ratten_548)

Kurz: Am Rechner mit den Daten aus Build 249 im Handyformat warten die Ratten immer auf den Helden, und der Haken gewinnt den Probekampf. Ich finde den Fehler nicht ohne deine Hilfe.

**Frage:** Im Rattenkampf (04.11., 00:03): hast du irgendwo hingetippt, zum Beispiel auf den Ring, als die Ratten angriffen, oder unten rechts über dem Kasten (Würfel, Raster, Haken, Kreuz)? Und im Probekampf (00:01): hast du Haken und Kreuz getippt, während die Wölfe noch dran waren oder als du am Zug warst?

**Votum:** Kurze Antwort in eigenen Worten genügt, etwa „Ring getippt, Haken nicht“.

**Berührt:** 548 (Ratten fallen von selbst), 545 (Haken und Kreuz ohne Wirkung).

**Sachverhalt:** Dein Kampfbericht zeigt drei Zeilen hintereinander („Riesenratte 1 sackt winselnd zusammen. Riesenratte 2 fällt. Riesenratte 3 sackt winselnd zusammen.“) ohne einen Treffer davor. Genau so schreibt das Spiel nur, wenn der Haken (Testmodus, „Gegner besiegen“) gilt: dann fallen alle Gegner nacheinander. Tippt man den Haken, während die Gegner noch angreifen, leuchtet er nur und gilt erst danach; das sieht dann aus wie „starben ohne mein Zutun“. Am Rechner nachgestellt: Ratten ohne jede Eingabe in allen Eröffnungen (Überfall, normal, Held zuerst) warten auf den Spieler; der Haken im Probekampf gewinnt; Haken und Kreuz springen mitten im Kampf nicht. Was nur am Handy anders ist (Finger, echte Größe des Bildschirms), sehe ich am Rechner nicht.

**Auswertung:** Stärkstes Gegenargument: Die Frage kostet dich Zeit, und vielleicht erinnerst du dich nicht. Dann baue ich als Nächstes eine Zeile in den Kampfbericht, sobald Haken oder Kreuz gelten („Test: Sieg“), damit man es beim nächsten Mal sieht. Raten und auf Verdacht umbauen will ich nicht.

**Folgerungen:** „Ring getippt“: ich prüfe, ob ein Tippen auf den Ring den Haken treffen kann. „Haken getippt“: der Haken wirkt, nur zu spät und ohne Hinweis; dann frage ich, ob er sofort gelten soll. „Nichts getippt“: ich baue die Zeile im Kampfbericht und suche weiter.

Antwort: …
