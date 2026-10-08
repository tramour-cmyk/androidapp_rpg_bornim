# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 08.10.2026, 11:20 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

## In Arbeit

- **Zweig `kampffluss`** (Test-Build v0.1.187, noch nicht auf main): Kampffluss am Stück, Kampftempo und „Kampftext: weiter automatisch“, Kampfende mit Siegesfeld und Sturz des Helden, Trinken im Kampf, tödlicher Treffer ohne Zwischentext, Untote vertreiben (Flucht) und Untote zerstören (ab Stufe 5), neue Heilige Flamme, Nebel in der Höhle. Kommt nach deinem Test auf main.
- **Gegner im neuen Stil:** eingebaut sind Goblin, Goblin-Späher, Skelett, Kobold, Zombie, Krogg, Grak, Wolf, Grimmzahn, Wildschwein und Riesenratte (v0.1.186). Noch im alten Stil: Goblin-Schamane und Ghul (Entwürfe auf der Puppe liegen vor), Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte (eigene Körper geplant).

## Zu testen

Mit dem Test-Build v0.1.187 (Zweig `kampffluss`):

- **Kampffluss:** Jede Aktion läuft am Stück (Bewegung, dann eine Textzeile); jede Ergebniszeile wartet auf Tippen. Im Menü „Kampftext: weiter automatisch“ und Kampftempo (Ruhig, Normal, Schnell).
- **Kampfende:** Der tödliche Treffer läuft ohne Text durch, der Gegner bleibt liegen, Siegpose, dann das Siegesfeld (Trefferzeile, EP, Gold, Beute; Stufenaufstieg eigenes Feld). Bei einer Niederlage stürzt der Held und bleibt liegen, erst dann der Text.
- **Trinken:** drei Varianten, Schildträger mit Schild am Arm; rot für Heiltrank, grün für Gegenmittel.
- **Untote vertreiben / zerstören:** unter Stufe 5 (und beim Ghul) flieht der Untote; ab Stufe 5 zerfallen Skelett und Zombie zu Staub, mit Gold und Beute.
- **Heilige Flamme:** Licht von oben mit Flammenfuß am Boden, beim Ausweichen neben dem Gegner.
- **Höhle:** Krogg und Grak nur in Sicht; Lichtschacht und Feuer leuchten nicht mehr in verborgene Räume.

Mit v0.1.186 (main): **Wildschwein und Riesenratte** in freier Wildbahn.

Älter, noch nicht bestätigt:
- **Stufengrenze (v0.1.173):** Ab Stufe 6 keine EP mehr, Beute weiter.
- **Ruhigere Bewegungen im Kampf:** Treffer, Ausweichen, Block, Schritt zurück, Taumeln, Drehung langsamer.

## Zu entscheiden

- **Fähigkeits-Effekte im düsteren Stil** (Prüfung vom 08.10.): Feuerpfeil, Magisches Geschoss, Sengender Strahl, Magierrüstung, Heilen, Segnen, Untote vertreiben, Spirituelle Waffe, Geisterwächter, Alchemistenfeuer und Weihwasser wirken noch wie Spielzeug oder Spielesymbole; Vorschläge im Chat, Entwürfe nach deiner Freigabe. Feuerball (Variante C) und Heilige Flamme passen.
- **Goblin-Schamane und Ghul:** Rückmeldung zu den Entwürfen, dann Einbau in den Kampf.
- **Hörproben:** Auswahl für Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt.
- **Kampftempo:** Soll es neben Text und Pausen auch die Bewegungen beschleunigen oder verlangsamen?

## Geplant

- **Killerschlag:** Ein kritischer Treffer, der ein Monster tötet, bekommt einen besonderen Schlag des Helden in mindestens drei Varianten. Das Trefferbild zerfetzt den Gegner, abgestuft nach der Blutstufe: bei „Aus“ ohne Blut, etwa ein Zerbrechen oder Zusammensacken; bei „Dezent“ und „Deutlich“ immer stärker. Skelette zerspringen in Knochen. Gilt für alle Gegner im neuen Stil.
- **Sterbeanimationen für alle Gegner:** Alle Gegner im neuen Stil haben je drei Stürze und bleiben liegen. Die übrigen (Schamane, Ghul, Spinne, Hundertfüßer, Fledermaus, Stirge, Ockergallerte) bekommen sie beim Umzug in den neuen Stil.

- **Klänge überarbeiten (Rest)** nach den [Stil-Leitlinien](STIL.md): weg von quietschenden Nintendo-Tönen, hin zu glaubwürdigen Geräuschen. Die Kampfgeräusche (Hiebe, Stiche, Schläge, Biss, Pfeil, Schwung, Wolfsheulen) wurden schon einmal realistischer gemacht und werden mit geprüft; Abwehr („Klonk“) und Fehlschlag („Wusch“) sind schon neu. Noch im alten Stil sind vermutlich:
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
