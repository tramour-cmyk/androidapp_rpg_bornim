# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist, damit im Chat nichts verloren geht. Stand: 07.10.2026, 11:41 (Berliner Zeit).

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
- **Abwehr:** Untermenü „Angreifen/Abwehr“, Konter-Hinweis.

## Zu entscheiden

1. **Veröffentlichen:** `hero-figure` nach `main` übernehmen. Das baut automatisch die nächste Version (v0.1.x). Danach bekommt die Änderungshistorie den Versionseintrag mit Datum und Uhrzeit. Vorschlag: nach deinem Test.
2. **Alte Kampfszenen:** Außerhalb von Wald und Höhle kämpft noch das alte 64-px-Männchen. Auch dort die neue Figur einsetzen? Mittlerer Aufwand (Platzierung und Ausfallschritt je Szene).
3. **Blut-Stufe:** Wunden am Helden gibt es nur bei voll eingeschaltetem Blut. Bei der schwächeren Stufe leichte Flecken zeigen oder keine?
4. **Übergang nach „Abwehr“:** Die Figur springt aus der Abwehrhaltung direkt in den nächsten Angriff. Kurzen fließenden Übergang einbauen? Geringer Aufwand.
5. **Figurgröße im Reiter „Held“:** etwa 90 × 140 dp, jetzt für jedes Volk gleich groß gefüllt. Passt das?
6. **Kampfablauf endgültig?** Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag. So lassen oder ändern?
7. **Rundschild auf der Karte:** Das Kartenmännchen (alter Stil) zeigt den Rundschild noch als Wappenschild. Anpassen oder so lassen, bis die Karte die neue Figur bekommt?
8. **Setup-Skript für das Android-SDK** in den Umgebungseinstellungen eintragen (am PC in der Web-Ansicht)? Dann ist das SDK in neuen Sitzungen sofort da.

## Bewusst so gelassen

- **Kartenfigur:** bleibt vorerst das alte Männchen.
