# 326 · Spielermenü im Stil des Hauptmenüs? · Homer · 23.10., 04:10
G Stil

**Frage** (Chef 23.10., 00:03): Das Spielermenü (System, Held, Tasche, Ausrüstung, Chronik, Erklärfenster) wirkt neben dem neuen Hauptmenü alt. Passt es zu Stil und Design? Karte ausgenommen.

**Befund** (Code gegen Stilhandbuch `DESIGN-STIL.md` „Oberfläche“ und Hauptmenü 292.3):

- **Gleich wie das Hauptmenü:** schwarz, dünner Goldrand, gebrochenes Weiß, Alegreya überall; keine hellen Tafeln, kein Cinzel, keine Pixelschrift. Das Grundgerüst stimmt.
- **Darum wirkt es alt:**
  1. **Zu klein.** Reiterleiste 8,5 sp; die meisten Knöpfe knapp 11 sp; Werte und Beschreibungen 11–12 sp. Hauptmenü: Knöpfe 17 sp, Titel 33 sp.
  2. **Überschriften ohne Würde.** „Vorräte“, „Ausrüstung“, „Kampfwerte“, „Lautstärke“ usw. stehen fett in Weiß, klein geschrieben. Im Hauptmenü sind Titel goldene, gesperrte Versalien.
  3. **Fremde Farben.** Blau für Ausrüstungswerte und Zauberpunkte, Grün für Boni, Hellblau für Erfahrung, rötlich für Hinweise; das Hauptmenü kennt nur Gold und Weiß.
  4. **Kleinkram:** Gegenstandskacheln abgerundet und nicht ganz schwarz (Hauptmenü durchweg eckig); Zahlen springen, weil die Ziffern nicht gleich breit sind.
- **Ursache:** Das Hauptmenü hat eigene, private Knöpfe und Titel (`MainButton`); das Spielermenü nutzt die älteren, gemeinsamen Bausteine. Fünf Stellen im Code würden das ganze Menü auf einmal nachziehen (Knopf, Reiter, Überschrift, Text, Farbtabelle), ohne jeden Reiter einzeln anzufassen.

**Empfehlung:** Ja, angleichen, als ein Umbau an den gemeinsamen Bausteinen (Team Tom):
- Schrift mindestens 13 sp, Knöpfe wie im Hauptmenü (Versalien, weiter gesperrt);
- Überschriften in gedämpftem Gold, Versalien;
- Farben auf Gold und Weiß; **bleiben dürfen** nur Seltenheit der Gegenstände und die Balken für Leben/Zauber/Erfahrung (bekanntes Muster, liest man ohne Text);
- gleich breite Ziffern, eckige Kacheln.
Vorher zeigt Tom je Reiter ein Standbild heute und eines mit Entwurf, du sagst dann „bauen“.

**Stärkstes Gegenargument:** Größere Schrift kostet Platz. Fünf Reiter mit 13 sp passen auf schmalen Handys nicht mehr nebeneinander; Tasche und Ausrüstung zeigen weniger Zeilen, man scrollt mehr. Ausweg: Reiter nur als Zeichen mit Name des gewählten Reiters darüber; das zeigen die Entwurfsbilder. Und: Es ist Kür; Kapitel 1 und Fehler gehen vor (Tom hat 8 Muss offen).

**Berührt:** 292.3 (Schriftregel), 312 (Über das Spiel), 313; Tom (Bau), Jerry nicht.

**Was du sagen sollst:** „326 ja“ (Bilder, dann Bau nach dem Meilenstein), „326 ja, jetzt“ oder „nein“.
