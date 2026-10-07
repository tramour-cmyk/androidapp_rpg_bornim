# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 07.10.2026, 12:12 (Berliner Zeit).

Die drei Listen:
- **Offen** (diese Liste): was jetzt ansteht. Wird bei jeder Änderung mit gepflegt.
- [Merkliste](MERKLISTE.md): Ideen für später, noch nicht beschlossen.
- [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist.

Ist ein Punkt erledigt, wandert er in die Änderungshistorie. Wird eine Idee vertagt, kommt sie auf die Merkliste.

## In Arbeit

- **Branch `hero-figure`** (noch nicht in `main`, also noch nicht veröffentlicht): der Held als bewegliche Figur im Kampf, im Ausrüstungsbild, bei der Erstellung, auf dem Titelbild und bei den Spielständen; Kampfmenü „Angreifen/Abwehr“ mit Konter; Kleriker mit Kampfstab, Rundschild und Sonne auf dem Wappenrock.

## Zu testen

Mit der APK vom letzten Build des Branches `hero-figure` (Seite des CI-Laufs, Artefakt `bornim-apk`):

- **Kleriker:** neuer Held mit Kampfstab und Rundschild; Block (Schild hoch, Stab bleibt stehen), Flasche werfen (mit der Schildhand), Zauber (Leuchten an der Stabspitze), Sonne auf dem Rücken im Kampf.
- **Alter Spielstand mit Kleriker:** unveränderter Streitkolben und Schild werden beim Laden zu Kampfstab und Rundschild; verbesserte oder gefundene Stücke bleiben.
- **Titelbild und Spielstände:** neue Figuren, still in Ruhehaltung.
- **Figurgröße in den Menüs:** Halbling und Zwerg im Reiter „Held“ und im Ausrüstungsbild groß und mittig; bei der Erstellung maßstabsgetreu und mittig.
- **Kampfablauf:** Ansage mit Ausholen → Tippen → Schlag oder Zauber zusammen mit Treffer/Fehlschlag; auch beim Kobold.
- **Abwehr:** Untermenü „Angreifen/Abwehr“, Konter-Hinweis; danach fließender Übergang in den nächsten Zug.
- **Heldenerstellung:** Figur und Werte bleiben oben stehen, nur die Eingaben darunter scrollen.
- **Blutstufen:** „Dezent“ zeigt bei Held und Gegner leichte Wunden, „Deutlich“ die vollen.

## Zu entscheiden

1. **Veröffentlichen:** `hero-figure` nach `main` übernehmen. Das baut automatisch die nächste Version (v0.1.x). Danach bekommt die Änderungshistorie den Versionseintrag mit Datum und Uhrzeit. Vorschlag: nach deinem Test.
2. **Rundschild auf der Karte:** Das Kartenmännchen (alter Stil) zeigt den Rundschild noch als Wappenschild. Anpassen oder so lassen, bis die Karte die neue Figur bekommt?

## Bei dir

- **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht) – machst du zu Hause.

## Bewusst so gelassen

- **Kartenfigur:** bleibt vorerst das alte Männchen.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
