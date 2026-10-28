# 399.2c · Wolf durch Wolf: Ursache gefunden, Korrektur gebaut. Darf ein dritter Lauf sie prüfen?
Jerry · 28.10., 17:19 · E Kampf
Kurz: ein dritter Probelauf für 399.2, sonst bleibt die Korrektur ungeprüft liegen

**Frage:** Für 399.2 sind beide erlaubten Probeläufe verbraucht (389). Darf ein dritter Lauf die Korrektur für „Wolf läuft durch Wolf“ prüfen? Der Lauf macht kein Bild, nur einen Test.

**Votum:** Ja, ein dritter Lauf. Sag „399.2c ja“, „nein“ oder „noch nicht“.

**Berührt:** 399.2 (Kampfort), 399.2b (Jungwölfe 50 %), 389 (höchstens zwei Läufe je Vorlage)

**Begründung:** Dein Befund 16:10: „wenn nur noch zwei Wölfe da sind und die dann in einer Linie stehen, dann läuft der hintere Wolf durch den vorderen“. Ohne Lauf kann ich die Korrektur nicht prüfen. Godot am Rechner hat der Auto-Modus abgelehnt, und der Fehler zeigt sich nur mit dem gekauften Wolf, den der Lauf baut.

**Sachverhalt:** Der Test aus Lauf 168 lässt acht Wolfskämpfe von selbst ablaufen und zählt die Bilder, in denen ein Wolf in einem anderen steht. Mit dem alten Stand stehen alle vier Kämpfe gegen das Wolfsrudel in einem anderen Wolf, bis 0,8 m tief. Der Fehler ist also nachgestellt. Mein erster Versuch, Umwege beim Anlauf, half nicht, und der Test zeigte das sofort.
Die Ursache steht im Code: Greift ein Wolf von hinten an, tauscht er nach den Regeln den Platz mit dem vorderen. Beide liefen dann gleichzeitig auf derselben Linie gegeneinander. Jetzt geht der vordere erst los, wenn der Angreifer an ihm vorbei ist.
Im selben Lauf wird auch 399.2b geprüft: Ein Jungwolf, der nicht beißt, kündigt keinen Biss an, er knurrt nur.

**Auswertung:** Stärkstes Gegenargument: Die Grenze von zwei Läufen soll verhindern, dass wir auf Verdacht bauen. Hier ist die Ursache aber nachgestellt und im Code belegt. Der dritte Lauf prüft diese eine Ursache, ohne Bild, ein Lauf etwa 15 Minuten. Bleibt er rot, rate ich nicht weiter und lege dir den Befund vor.

**Folgerungen:** Bei „ja“ läuft der Test sofort. Ist er grün, kommt ein Film vom Rudelkampf zu dir, und beides fährt mit der nächsten Testfassung. Bei „nein“ bleibt die Korrektur ungeprüft im Zweig `claude/jerry-348-kampf`.

Antwort:
