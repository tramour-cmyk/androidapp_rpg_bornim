# 326 · Spielermenü im Stil des Hauptmenüs: Bilder · Homer · 23.10., 07:55
G Stil

**Frage** (Chef 00:03): Spielermenü und Aktionsknöpfe wirken neben dem Hauptmenü alt. **Richtung gebilligt** (07:29): Zeichen statt Textknöpfen, Erklärung bei langem Druck, Vorbild die Reiter. Hier die Bilder dazu, links heute, rechts Entwurf (gerechnet aus dem echten Spielcode, Zweig `claude/homer-326-entwurf`, nur Vorschau).

**1. System-Reiter.** 16 Zeichen in vier Gruppen statt 15 breiter Knöpfe; unter jedem Zeichen Name und Stand in Gold; Antippen schaltet weiter, langer Druck erklärt (rechts: „Tempo“). Die Regler für Lautstärke und Helligkeit bleiben, unter den Zeichen.

![System](../bilder/326-system.webp)

**2. Aktionsknöpfe.** Statt violett-blauer Kugel mit dickem Rand: schwarzer Grund, dünner Goldrand wie die Zeichen im Hauptmenü; das Bild bleibt farbig. Bekannt: der Stiefel im Rennknopf ist auf Schwarz zu dunkel, beim Bau heller.

![Welt](../bilder/326-welt.webp)

**3. Überall im Menü (Beispiel Tasche).** Überschriften in goldenen Versalien, keine Schrift unter 13 sp. Wirkt leiser als 1 und 2, aber in allen Reitern gleich.

![Tasche](../bilder/326-tasche.webp)

**Empfehlung:** alle drei so bauen (Team Tom), nach dem Meilenstein. Seltenheitsfarben und die Balken für Leben, Zauber, Erfahrung bleiben farbig.

**Stärkstes Gegenargument:** Zeichen muss man lernen; „Steuerung“ und „Joystick“ sind abstrakt, „Hauptmenü“ (Tor) mäßig. Darum stehen Name und Stand immer darunter, und langer Druck erklärt. Und: Kür; Kapitel 1 und Fehler gehen vor (Tom hat 8 Muss offen).

**Berührt:** 292.3 (Schriftregel), 312, 313; Tom (Bau, `WorldScreen.kt` für den Aktionsknopf), Jerry nicht.

**Stellungnahme Sokrates** (23.10., 08:05):
- *Stärkstes Gegenargument:* Bei 2 geht es um Bedienung, nicht nur ums Aussehen. Schwarze Knöpfe mit dünnem Goldrand können auf der nächtlichen Karte und im Wald untergehen. Bei 1 schaltet Antippen gleich weiter: Wer nur nachsehen will, verstellt dabei etwas. Langer Druck ist im Spiel sonst nirgends üblich, den findet keiner von allein.
- *Widerspruch zu Entschiedenem:* keiner; Schriftregel 292.3 und Signatur 302 (Gold als einziger Glanz) passen. Nach dem Meilenstein verträgt es sich mit der obersten Direktive.
- *Kosten:* Toms Schätzung fehlt. Der Umbau betrifft gemeinsame Bausteine und `WorldScreen.kt`, also mehr als einen Reiter.
- *Bildprüfung (08:38, Helfer):* Die Entwürfe halten das Versprechen „keine Schrift unter 13 sp“ nicht: Die Reiterleiste (HELD, TASCHE, „AUSRÜST.“) bleibt etwa 7 Pixel hoch, der Rahmen grau. Ringe sind grau, nur das Gewählte golden. Der Rennknopf hat einen grauen Ring, der Feuerknopf einen goldenen, und der Stiefel ist auf Schwarz kaum zu sehen. Beschriftungen stehen in normaler Schreibung, im Hauptmenü in Versalien. Bild 3 zeigt fast nur die neuen Überschriften.
- *Empfehlung:* „326 ja“, Bau nach dem Meilenstein. Bild 2 vorher auf dem Gerät bei Nacht und im Wald prüfen. Langer Druck einmal beim ersten Öffnen zeigen, als kurzer Hinweis.

**Vorschlag Sokrates** (09:00, nach Chef 08:58: alle Reiter außer Karte, Aktionszeichen und Rennen neu):
- **A. Alle Reiter außer Karte** (Held, Tasche, Ausrüstung, Chronik, System, Test) über die gemeinsamen Bausteine:
  - Leiste: nur Zeichen; der Name des gewählten Reiters steht groß darüber, in goldenen gesperrten Versalien wie der Titel im Hauptmenü.
  - Rahmen, Trennlinien und Ringe in gedämpftem Gold statt Grau; das Gewählte hell.
  - Überschriften in goldenen Versalien; keine Schrift unter 13 sp; Beschriftungen in Versalien.
  - Knöpfe wie im Hauptmenü; nur Gold und Weiß, farbig bleiben nur Seltenheit und Balken.
  - Die Erklärung bei langem Druck legt sich über den Inhalt, nichts verrutscht. Beim ersten Öffnen ein Hinweis darauf.
- **B. Aktionszeichen neu gezeichnet:** 14 Stück (Reden, Öffnen, Lesen, Rasten, Aufschließen, Ansehen, Kampf, Eintreten, Weiter, Menü, Rennen, Handeln, Sonne, Mond). Gleiche Art wie die Reiterzeichen: goldene Linien auf schwarzem Grund, nie gefüllt, kein Pixel mehr.
- **C. Rennen:** Stiefel mit drei Bewegungsstrichen. An: helles Gold; aus: gedämpft.
- **D. Lesbarkeit:** Knöpfe auf zu 70 % deckendem Schwarz, gleich großer Goldrand bei allen.
- **E. Bilder vor dem Bau:** je Reiter eins, dazu die Aktionsknöpfe auf der Karte bei Tag, Nacht und im Wald.
- *Gegenargument:* Das ist ein Umbau über sieben Reiter und 14 Zeichen und reine Kür. Den Test-Reiter sehen nur Tester; er bekommt nur, was die gemeinsamen Bausteine ohnehin mitbringen.

**Was du sagen sollst:** „326 ja“ (Bau nach dem Meilenstein), „326 ja, jetzt“, oder je Bild „1 ja, 2 nein …“.
