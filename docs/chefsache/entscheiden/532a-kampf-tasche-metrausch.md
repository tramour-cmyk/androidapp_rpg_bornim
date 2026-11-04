# 532a · Kampf: Tasche und Metrausch jetzt wie alt in MARS, oder erst mit dem BRS-Rechenkern (478)?
Team Jerry · 03.11., 23:53 · E Kampf · berührt 532, 478

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/cfc2c499b (Zweig claude/jerry-532-kampfzustand, Test kampfzustand_532)

Kurz: Im Kampf gibt es nur den einfachen Heiltrank; Metrausch wirkt dort nicht. Beides gab es nur im alten klassischen Kampf, nie im MARS.

**Frage:** Sollen die übrigen Sachen aus der Tasche (großer und bester Heiltrank, Gegengift, Alchemistenfeuer, Weihwasser) und der Metrausch jetzt wie im alten Spiel in den Kampf kommen, oder erst mit dem Rechenkern auf BRS (478)?

**Votum:** „532a jetzt“: Kapitel 1 soll ganz spielbar sein. Wer Alchemistenfeuer kauft, muss es im Kampf werfen können.

**Berührt:** 532 (der Rest ist gebaut), 478 (Rechenkern BRS, ruht), 535 (Balance der Gegner).

**Sachverhalt:** Alt war MARS nur der Probekampf mit zwei Heiltränken (`Skirmish.probe`, `PROBE_POTIONS`). Die Tasche und der Metrausch wirkten nur im klassischen Kampf (`Battle.kt` 576–605: trinken, werfen, Gegengift heilt Zustände; 175: betrunken mit Nachteil auf Angriff und Flucht bis zur Rast). Im neuen MARS (`regeln/mars.gd`) gibt es nur `potions["potion"]` und keinen Zustand „betrunken“. Der Rest von 532 ist gebaut: Zauberpunkte, „einmal je Rast“ und Zustände gehen in den Kampf und wieder zurück.

**Auswertung:** Das stärkste Gegenargument ist doppelte Arbeit: 478 baut den Rechenkern auf BRS neu, dann müssen Wurf, Heilung und Nachteil noch einmal angepasst werden. Dagegen: das Ziel ist ein fertiges Kapitel 1, und die Sachen werden schon jetzt im Laden verkauft. Den Ablauf (Knopf, Ziel, Bewegung) braucht es auch mit BRS; neu gerechnet werden nur die Zahlen. Neue Werte erfinde ich nicht: ich übernehme die alten (Würfel aus `Items.kt`).

**Folgerungen:** Bei „jetzt“ baut Jerry die Sachen aus der Tasche und den Metrausch in MARS ein, mit den alten Werten, und zeigt sie im nächsten Build. Bei „mit 478“ bleibt es beim einfachen Heiltrank. Der Laden zeigt dann bei den übrigen Sachen „nicht im Kampf“ (Vorgang an Tom).

Antwort: …
