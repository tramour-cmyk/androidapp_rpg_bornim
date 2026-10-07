# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 07.10.2026, 14:00 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Für alle Arbeiten gelten die [Stil-Leitlinien](STIL.md): erwachsener, düsterer, bessere Grafik und Übergänge, Kollisionen selbst prüfen.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

## In Arbeit

- **Branch `hero-figure`** (noch nicht in `main`, also noch nicht veröffentlicht): der Held als bewegliche Figur im Kampf, im Ausrüstungsbild, bei der Erstellung, auf dem Titelbild und bei den Spielständen; Kampfmenü „Angreifen/Abwehr“ mit Konter; Kleriker mit Kampfstab, Rundschild und Sonne auf dem Wappenrock.

- **Gegner im neuen Stil:** Goblin, Goblin-Späher und Skelett sind eingebaut (Aussehen, Ausrüstung, Bewegungen in je drei Varianten). Als Nächstes die übrigen menschenähnlichen Gegner (Kobold, Zombie, Krogg, Grak), danach die Tiere als 3D-Vierbeiner.

## Zu testen

Mit der APK vom letzten Build des Branches `hero-figure` (Seite des CI-Laufs, Artefakt `bornim-apk`):

- **Kleriker:** neuer Held mit Kampfstab und Rundschild; Block (Schild hoch, Stab bleibt stehen), Flasche werfen (mit der Schildhand), Zauber (Leuchten an der Stabspitze), Sonne auf dem Rücken im Kampf.
- **Alter Spielstand mit Kleriker:** unveränderter Streitkolben und Schild werden beim Laden zu Kampfstab und Rundschild; verbesserte oder gefundene Stücke bleiben.
- **Titelbild und Spielstände:** neue Figuren, still in Ruhehaltung.
- **Figurgröße in den Menüs:** Halbling und Zwerg im Reiter „Held“ und im Ausrüstungsbild groß und mittig; bei der Erstellung maßstabsgetreu und mittig.
- **Kampfablauf:** Ansage mit Ausholen → Tippen → Schlag oder Zauber zusammen mit Treffer/Fehlschlag; auch beim Kobold.
- **Abwehr:** Untermenü „Angreifen/Abwehr“, Konter-Hinweis; danach fließender Übergang in den nächsten Zug.
- **Karte:** Kleriker mit Rundschild (hell, goldene Sonne) und Kampfstab mit Eisenkappen.
- **Heldenerstellung:** Figur und Werte bleiben oben stehen, nur die Eingaben darunter scrollen.
- **Heilige Flamme:** bei Treffer mitten auf dem Gegner, beim Ausweichen schlägt sie neben ihm ein (bei allen Gegnern, auch Grimmzahn, Krogg, Grak).
- **Goblins und Skelette im Kampf:** verschiedene Ausrüstungen, Größen und Hauttöne; Angriffe, Treffer, Ausweichen und Zusammenbrechen in Varianten; Goblin-Späher schießt mit dem Bogen; Angriffsname im Text passt zur Waffe.
- **Blutstufen:** „Dezent“ zeigt bei Held und Gegner leichte Wunden, „Deutlich“ die vollen.

## Zu entscheiden


1. **Veröffentlichen:** `hero-figure` nach `main` übernehmen. Das baut automatisch die nächste Version (v0.1.x). Danach bekommt die Änderungshistorie den Versionseintrag mit Datum und Uhrzeit. Vorschlag: nach deinem Test.

## Geplant

- **Klänge überarbeiten** nach den [Stil-Leitlinien](STIL.md): weg von quietschenden Nintendo-Tönen, hin zu glaubwürdigen Geräuschen. Die Kampfgeräusche (Hiebe, Stiche, Schläge, Biss, Pfeil, Schwung, Wolfsheulen) wurden schon einmal realistischer gemacht und werden mit geprüft. Noch im alten Stil sind vermutlich:
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

- **Kartenfigur:** bleibt vorerst das alte Männchen.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
