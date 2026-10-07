# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 07.10.2026, 21:55 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

## In Arbeit

- **Gegner im neuen Stil:** Goblin, Goblin-Späher, Skelett, Wolf (mit Grimmzahn), Kobold, Zombie, Krogg und Grak sind eingebaut. Als Nächstes Wildschwein und Riesenratte als Vierbeiner; danach Goblin-Schamane und Ghul auf der Puppe, später Spinne, Hundertfüßer, Fledermaus, Stirge und Ockergallerte mit eigenen Körpern.

## Zu testen

Mit dem Testbuild vom Zweig `neue-gegner` (Link im Chat):

- **Gehaltene Haltungen:** Ausholen beim Angriff bleibt stehen bis zum Schlag (kein Zurück in die Ruhe dazwischen); Abwehr bleibt stehen bis zum nächsten eigenen Zug, auch nach Treffer oder Verfehlen; ebenso Zauber sammeln und Wurf. Am besten mit Kleriker und Kampfstab und mit einer weiteren Klasse.
- **Konter:** Abwehr, Gegner verfehlt („Lücke“), dann angreifen: erst „nutzt die Lücke!“, dann Ausholen und Schlag in einem Zug. Auch mit Feuerpfeil.
- **Neue Gegner:** Kobold (auch im Rudel), Zombie, Krogg und Grak im Kampf: Aussehen, Ausrüstungsvarianten, Bewegungen, Stürze (Kobold-Schwanz); Morgenstern als Beute.
- **Ruhigere Bewegungen im Kampf:** Treffer, Ausweichen, Block, Schritt zurück, Taumeln, Drehung langsamer; die Schläge selbst so schnell wie bisher.

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
