# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 08.10.2026, 12:35 (Berliner Zeit).

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

- **Zweig `effekte`** (aufgebaut auf `kampffluss`, Test-Build v0.1.193, noch nicht auf main): neue Fähigkeits-Effekte (Magier, Kleriker, Wurfgegenstände, Feuerball), Zustände sichtbar am Körper, Fehlerbehebung Taschenbilder. Kommt nach deinem Test zusammen mit `kampffluss` auf main.
- **Zweig `kampffluss`** (Stand v0.1.187): Kampffluss am Stück, Kampftempo, „Kampftext: weiter automatisch“, Kampfende mit Siegesfeld und Sturz des Helden, Trinken, tödlicher Treffer ohne Zwischentext, Untote vertreiben/zerstören, Heilige Flamme, Nebel in der Höhle.
- **Gegner im neuen Stil:** eingebaut sind Goblin, Goblin-Späher, Skelett, Kobold, Zombie, Krogg, Grak, Wolf, Grimmzahn, Wildschwein und Riesenratte (v0.1.186). Noch im alten Stil: Goblin-Schamane und Ghul (Entwürfe auf der Puppe liegen vor), Riesenspinne, Riesenhundertfüßer, Riesenfledermaus, Stirge und Ockergallerte (eigene Körper geplant).

## Zu testen

**Test-Build v0.1.193** (Zweig `effekte`, enthält alles aus `kampffluss`). Worauf achten:
- **Magier:** Feuerpfeil (glühender Kopf, Flammenspur, Rauch, Flammen haften kurz am Gegner), Magisches Geschoss (drei violette Kraftsplitter nacheinander), Sengender Strahl (flackernder Feuerstrahl, Glut am Ziel), Magierrüstung (Runen sammeln sich am Körper, Schimmer läuft hoch). Beim Zaubern blitzt nicht mehr der ganze Bildschirm weiß. Passt das Timing: erscheint der Text erst, wenn der Zauber trifft?
- **Feuerball (neu):** brodelnde Feuermasse statt Kugel, Explosion aus Flammenwolken, brennender Boden, Rauch. Wirkt es nicht mehr wie ein Spielball?
- **Kleriker:** Wunden heilen und Heiltränke (goldenes Licht statt grünem Kreis), Segnen (Lichteinfall von oben, Sonnenzeichen an der Brust), Untote vertreiben (Lichtwelle über den Boden), Spirituelle Waffe (Geister-Streitkolben), Geisterwächter (kreisende Geistgestalten, beim Angriff um den Gegner).
- **Wurfgegenstände:** Alchemistenfeuer (Flasche mit brennendem Lappen, Scherben, haftende Flammen), Weihwasser (Scherben, Spritzer, zischender Dampf).
- **Zustände am Körper:** Brennend, Vergiftet, Blutend (nach Blutstufe; bei „Aus“ nichts), Betäubt (Schwanken), Verlangsamt (Reif, langsamere Ruhebewegung), Geschwächt (violetter Schleier), Geblendet (Restlicht vor den Augen). Bei Held und Gegner. Zu schwach, zu stark, stören sie?
- **Tasche:** Nach dem Anlegen eines Gegenstands zeigt jede Zeile ihr eigenes Bild (vorher zeigte der Glutstab eine Armbrust).

Dazu aus `kampffluss` (noch nicht bestätigt):
- **Kampffluss:** Jede Aktion läuft am Stück; Kampftempo und „Kampftext: weiter automatisch“ im Menü.
- **Kampfende:** tödlicher Treffer ohne Text, Gegner bleibt liegen, Siegpose, Siegesfeld; bei Niederlage stürzt der Held und bleibt liegen.
- **Untote vertreiben / zerstören:** unter Stufe 5 (und beim Ghul) Flucht; ab Stufe 5 zerfallen Skelett und Zombie zu Staub.
- **Höhle:** Krogg und Grak nur in Sicht; Lichter leuchten nicht mehr in verborgene Räume.

Mit v0.1.186 (main): **Wildschwein und Riesenratte** in freier Wildbahn.

Älter, noch nicht bestätigt:
- **Stufengrenze (v0.1.173):** Ab Stufe 6 keine EP mehr, Beute weiter.
- **Ruhigere Bewegungen im Kampf:** Treffer, Ausweichen, Block, Schritt zurück, Taumeln, Drehung langsamer.

## Gemeldet und geklärt (08.10.)

- **Trank wird zweimal getrunken (Magier gegen Skelett):** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“. Bleibt so.
- **Gegner hinter der Wand sichtbar (Höhle):** behoben in `kampffluss`.
- **Treffermeldung mitten im tödlichen Treffer:** behoben in `kampffluss`.
- **Glutstab zeigt Armbrust-Bild:** behoben in `effekte` (zu testen, siehe oben).

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
