# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 08.10.2026, 13:07 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

**Arbeitsweise (seit 08.10.2026):**
- Jede Meldung von dir (Fehler, Anregung, Idee, Frage zum Nachhalten) kommt sofort hier hinein, auch wenn sie nicht gleich umgesetzt wird.
- Nach jeder erledigten Arbeit (von dir getestet oder von mir umgesetzt) wird diese Liste geprüft: Erledigtes wandert in die Änderungshistorie, Offenes bleibt stehen.
- Zu jedem neuen Test-Build steht unter „Zu testen“, worauf du achten sollst.

## In Arbeit

- **Gegner im neuen Stil:** eingebaut sind Goblin, Goblin-Späher, Skelett, Kobold, Zombie, Krogg, Grak, Wolf, Grimmzahn, Wildschwein und Riesenratte. Noch im alten Stil: Goblin-Schamane und Ghul (Entwürfe auf der Puppe liegen vor), Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte (eigene Körper geplant).

## Zu testen

**Version v0.1.196** (veröffentlicht). Worauf achten:
- **Tödlicher Treffer gegen eine Schwäche** (z. B. Heilige Flamme gegen Skelett, Wucht gegen Skelett): kein Text, während der Gegner taumelt; „Das ist sehr effektiv!“ steht im Siegesfeld in der Trefferzeile.
- **Spirituelle Waffe:** Beim Herbeirufen erscheint die Waffe neben dem Helden und schwebt, ohne zuzuschlagen. Danach schlägt sie einmal zu, der Text „schlägt zu“ steht mit dem Schaden in einer Zeile.
- **Testreiter:** „Alle Vorräte auf mindestens 10“ füllt Tränke, Alchemistenfeuer, Weihwasser, Essen und Zutaten auf.
- **Alchemistenfeuer** (jetzt leicht zu bekommen): Flasche mit brennendem Lappen, Scherben, haftende Flammen, danach brennt der Gegner.
- **Weitere Zustände**, sobald sie vorkommen: Vergiftet (Spinne, Hundertfüßer), Blutend (nach Blutstufe; bei „Aus“ nichts), Betäubt, Verlangsamt, Geschwächt (Fluch des Schamanen), Geblendet (Heilige Flamme). Zu schwach, zu stark, stören sie?
- **Noch nicht bestätigt aus v0.1.194:** Kampftempo und „Kampftext: weiter automatisch“, Untote vertreiben/zerstören, Nebel in der Höhle.

Von dir bestätigt: Magier- und Kleriker-Effekte, Feuerball, Weihwasser, Zustand „Brennend“, Tasche (Bilder), Kampfende mit Siegesfeld und Sturz des Helden, Trinken im Kampf (schon am Vormittag: „Trank trinken sah top aus“).

Mit v0.1.186 (main): **Wildschwein und Riesenratte** in freier Wildbahn.

Älter, noch nicht bestätigt:
- **Stufengrenze (v0.1.173):** Ab Stufe 6 keine EP mehr, Beute weiter.
- **Ruhigere Bewegungen im Kampf:** Treffer, Ausweichen, Block, Schritt zurück, Taumeln, Drehung langsamer.

## Gemeldet und geklärt (08.10.)

- **Trank wird zweimal getrunken (Magier gegen Skelett):** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“. Bleibt so.
- **Gegner hinter der Wand sichtbar (Höhle):** behoben (v0.1.194).
- **Treffermeldung mitten im tödlichen Treffer:** behoben (v0.1.194).
- **Glutstab zeigt Armbrust-Bild:** behoben, von dir bestätigt.
- **Spirituelle Waffe schlägt scheinbar doppelt zu:** behoben in v0.1.195 (zu testen).
- **Wunsch: Vorräte im Testreiter auffüllen:** umgesetzt in v0.1.195 (zu testen).
- **Text kam beim finalen Schlag, während das Skelett noch taumelte (Heilige Flamme):** behoben in v0.1.196 (zu testen).

## Zu entscheiden

- **Zustände am Körper:** Sind Verlangsamt, Geschwächt und Geblendet auf kleinen Gegnern stark genug?
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
