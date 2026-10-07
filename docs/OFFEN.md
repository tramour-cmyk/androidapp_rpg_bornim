# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 07.10.2026, 20:35 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

## In Arbeit

- **Gegner im neuen Stil:** Goblin, Goblin-Späher, Skelett und Wolf (mit Grimmzahn) sind eingebaut. Als Nächstes die übrigen menschenähnlichen Gegner (Kobold, Zombie, Krogg, Grak), dann Wildschwein und Ratte als Vierbeiner.

## Zu testen

Mit der neuesten Version (Releases auf GitHub, `bornim.apk`):

- **Hinterhalt:** Der Held steht zugewandt, bis der Schlag von hinten trifft, taumelt dann nach vorn und dreht sich um.
- **Ruhigere Bewegungen im Kampf:** Treffer, Ausweichen, Block, Schritt zurück, Taumeln, Drehung langsamer; die Schläge selbst so schnell wie bisher.
- **Vielseitige Waffen:** Langschwert, Streitaxt, Kriegshammer, Speer, Kampfstab ohne Schild: mehr Schaden (Kampfwerte im Ausrüstungsreiter) und beidhändige Haltung im Kampf; mit Schild wie bisher.
- **Tasche, Laden, Dialog:** kürzere Zeilen ohne Dopplungen.
- **Gegenstandsvergleich:** Tabelle „Angelegt | Neu“ im Dialog, Urteil oben, Obergrenzen-Hinweise; Pfeil in der Tasche passt zum Urteil.
- **Vorräte:** neue räumliche Bilder in Tasche, Laden, Brauen und Kampf.
- **Rundschild beim Drehen:** im Ausrüstungsbild nicht mehr im Bauch.
- **Blutstufen:** „Dezent“ zeigt bei Held und Gegner leichte Wunden, „Deutlich“ die vollen.

## Geplant

- **Killerschlag:** Ein kritischer Treffer, der ein Monster tötet, bekommt einen besonderen Schlag des Helden in mindestens drei Varianten. Das Trefferbild zerfetzt den Gegner, abgestuft nach der Blutstufe: bei „Aus“ ohne Blut, etwa ein Zerbrechen oder Zusammensacken; bei „Dezent“ und „Deutlich“ immer stärker. Skelette zerspringen in Knochen. Gilt für alle Gegner im neuen Stil.
- **Sterbeanimationen für alle Gegner:** Goblin, Späher und Skelett haben sie schon (drei Varianten: vornüber, rücklings, seitlich, mit echtem Sturz zu Boden). Die Wölfe haben sie jetzt auch (drei Stürze); die übrigen Gegner bekommen sie beim Umzug auf die Puppe.

- **Klänge überarbeiten** nach den [Stil-Leitlinien](STIL.md): weg von quietschenden Nintendo-Tönen, hin zu glaubwürdigen Geräuschen. Die Kampfgeräusche (Hiebe, Stiche, Schläge, Biss, Pfeil, Schwung, Wolfsheulen) wurden schon einmal realistischer gemacht und werden mit geprüft; Abwehr („Klonk“) und Fehlschlag („Wusch“) sind schon neu. Noch im alten Stil sind vermutlich:
  - Menü und Bedienung: Klick.
  - Belohnungen: Stufenaufstieg, Beute, epische Beute, Münzen, Truhe.
  - Welt: Tür, Begegnung, Alarm (Gegner bemerkt dich), Hinterhalt.
  - Zauber und Tränke: Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf.
  - Kampfende: Gegner fällt, Held fällt.
  - Umgebung: Vögel, Grillen, Eule, Tropfen, Knistern.
  - Musik prüfen, ob sie zum düstereren Stil passt.
  - Vorgehen: erst Hörproben einzelner Geräusche zum Vergleich, dann nach deiner Freigabe umstellen.

## Bei dir

- **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht) – machst du zu Hause.

## Bewusst so gelassen

- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
