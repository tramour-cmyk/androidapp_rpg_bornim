# Chroniken von Bornim / Chronicles of Bornim

Ein Rollenspiel für Android im Stil klassischer Handheld-RPGs (Draufsicht, rundenbasierte Kämpfe), mit einem vereinfachten Regelsystem auf Basis des D&D 5e SRD 5.1. Deutsch und Englisch.

**Download:** [bornim.apk (neueste Version)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/latest/download/bornim.apk)

## Features

- **Kapitel 1: Der Blutzahn-Stamm** – eigene Geschichte: Dorf Bornim, Flüsterwald, Blutzahnhöhle, Zwischenboss Krogg, Boss Hauptmann Grak, Rettung von Schwester Lyra, Cliffhanger um den „Grauen Propheten“
- **Charaktererstellung**: 5 Völker (Mensch, Elf, Zwerg, Halbling, Halbork) mit Attributsboni und Merkmalen, 4 Klassen (Kämpfer, Magier, Schurke, Kleriker)
- **Vereinfachtes D&D-System**: sechs Attribute mit Standard-Array, Modifikatoren, Übungsbonus, Rüstungsklasse, W20-Angriffe, kritische Treffer, Rettungswürfe, Schadensarten mit Resistenz/Verwundbarkeit, Zauberpunkte (SRD-Variante)
- **Charakterentwicklung**: Stufen 1–10, pro Stufe ein Attributspunkt, neue Klassenfähigkeiten (z. B. Tatendrang, Feuerball, Spirituelle Waffe)
- **Beutesystem im Stil klassischer Action-RPGs**: 9 Ausrüstungsslots (Kopf, Oberkörper, Arme, Beine, Umhang, Amulett, Ring, Haupt- und Nebenhand; Zweihänder belegen beide Hände, Kampf mit zwei Waffen), 55 Grundtypen nach SRD, zufällige Eigenschaften (Attribute, RK, Schaden, Feuer/gleißend, Lebensraub, kritischer Bereich, Magie-/Goldfund …), generierte Namen, 6 Seltenheitsstufen (gewöhnlich bis göttlich), Elite-Gegner, mitwachsende Monster, Laden mit wechselndem Sortiment
- **Bis Stufe 20**, Zaubertricks skalieren nach SRD
- **17 Monsterarten** (u. a. Wildschwein, Kobold, Stirge, Riesen-Hundertfüßer, Goblin-Schamane, Ghul, Riesenfledermaus, Ockergallerte) mit eigenen Fähigkeiten wie Ansturm, Rudeltaktik, Blutsaugen, Lähmung, Säure oder Heilzaubern; klassische Zufallsbegegnungen im hohen Gras und in der Höhle
- **Lebendige Kampfgrafik**: 64-px-Sprites mit Licht und Schatten, Atem-, Angriffs- und Treffer-Animationen; jedes Monster sieht etwas anders aus (Farbe, Größe, Waffen, Helm, Kriegsbemalung); der Held zeigt seine angelegte Ausrüstung
- **Elite-Gegner mit Eigenschaften**: Wild, Uralt, Flink, Giftig, Glühend, Blutdurstig, jeweils mit farbiger Aura und eigener Wirkung im Kampf
- **Schimmernde Varianten**: sehr selten (1 : 150), funkeln in fremden Farben und lassen garantiert seltene Beute fallen
- **Moderne Touch-Steuerung**: Ziehen auf der Karte lenkt den Helden (weit ziehen = rennen), Tippen läuft automatisch zum Ziel, Tippen auf Personen, Truhen oder Schilder läuft hin und interagiert. Eine Aktionstaste zeigt per Symbol, was vor dem Helden möglich ist (Sprechen, Öffnen, Lesen, Rasten, Aufschließen, Ansehen). Wahlweise klassisches Steuerkreuz, Aktionstaste links für Linkshänder, Vibration abschaltbar
- Speichern/Laden, Sprachwechsel jederzeit im Spiel

## Testmodus

Für Tests gibt es ein verstecktes Cheat-Menü: Im Titelbild **7-mal auf die Copyright-Zeile tippen** (erneut 7-mal schaltet es wieder aus). Danach hat das Spielmenü einen Reiter **Test** mit:

- Stufe ändern (−5, −1, +1, +5), +1000 Gold, vollständig heilen
- Bosse zurücksetzen (Krogg und Grak erscheinen wieder in der Höhle)
- Teleport ins Dorf, in den Wald oder in die Höhle
- Kampf gegen ein beliebiges Monster auslösen, wahlweise normal, als Elite mit bestimmter Eigenschaft oder schimmernd
- Beute einer gewählten Seltenheit erzeugen

## Aufbau

| Modul | Inhalt |
|---|---|
| `core/` | Spiellogik in reinem Kotlin: Regeln, Kampf, Welt, Story, prozedurale Pixel-Art. Ohne Android testbar. |
| `app/` | Android-App (Jetpack Compose): Rendering, Steuerkreuz, Menüs |
| `tools/preview/` | Desktop-Harness: kompiliert die App-Oberfläche mit Compose Multiplatform und rendert Screenshots (für Umgebungen ohne Android SDK) |

## Bauen

```bash
./gradlew -p core test          # Spiellogik testen (inkl. automatischem Durchspielen von Kapitel 1)
./gradlew :app:assembleDebug    # APK bauen (benötigt Android SDK + Zugriff auf Google Maven)
(cd tools/preview && ../../gradlew run)   # Screenshots nach tools/preview/build/screens
```

Ein GitHub-Actions-Workflow (`.github/workflows/android.yml`) baut die APK bei jedem Push und stellt sie als Artefakt bereit.

## Lizenzen

© WireStormTCS/rahasof 2026

Dieses Werk enthält Material aus dem System Reference Document 5.1 („SRD 5.1“) von Wizards of the Coast LLC, verfügbar unter https://dnd.wizards.com/resources/systems-reference-document. Das SRD 5.1 ist lizenziert unter der Creative Commons Attribution 4.0 International License (https://creativecommons.org/licenses/by/4.0/legalcode).

Geschichte, Orte, Figuren und Grafiken sind eigene Werke. Schrift: Jersey 10 (SIL Open Font License 1.1, siehe `app/src/main/assets/OFL-Jersey10.txt`).

Dies ist ein Fanprojekt und steht in keiner Verbindung zu Wizards of the Coast, Nintendo oder Blizzard Entertainment.
