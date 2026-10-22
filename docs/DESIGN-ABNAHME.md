# Abnahme

Wie gebaut und geprüft wird: die Einzelheiten zum [Leitbild](DESIGN-LEITBILD.md) (Grundsätze 5, 10, 11, 12). Wie das Spiel aussieht und klingt, steht in [Stil](DESIGN-STIL.md); Abläufe (Notizen, Builds, Nummern) in `CLAUDE.md`, seltene (Release, Neustart) in `LISTE-RELEASE-NEUSTART.md`.

## Ansicht

- **Nur diagonal (13u, 13t):** jeder Ort und Raum diagonal (Vorlagen `MapRoomIso`, `MapTownIso`); die alte gerade Ansicht ist ausgebaut (13t, 0.1.709).

## Wann ein Ort fertig ist („Ort fertig“)

Festgelegt mit dem Nutzer 11.10., 16:50 (Maßstab: Dorf und Räume). Gilt für Dorf, Räume, Wald, Höhle und jeden neuen Ort:
1. **Diagonale Sicht:** alles (Bäume, Felsen, Häuser, Möbel, Ufer, Hänge) für die schräge Kamera gezeichnet, nicht die alte Ansicht gekippt.
2. **Boden:** doppelte Auflösung, kein sichtbares Raster, Wege mit natürlichem Verlauf.
3. **Dinge:** rund geformt mit Volumen (`Sculpt`), je mindestens drei Varianten, im Maßstab des Helden.
4. **Licht und Schatten:** Schatten unter allem, was steht; Licht nur aus sichtbaren Quellen; nachts düster, aber lesbar.
5. **Sichtbar (43):** Durchsicht und freier Blick nach „Karte und Räume“ in `DESIGN-STIL.md`; Standbild je Ort aus Sicht des Helden, jede Person und jeder Questort beim Herangehen erkennbar.
6. **Lebendig:** Wind, Rauch, Tiere, Gebrauchsspuren, Wetter, je nach Ort; Effekte selbst vorgeschlagen (44d, `DESIGN-STIL.md`).
7. **Figuren:** alle Leute als Puppen, alle Gegner als neue Kartenmodelle.
8. **Klang:** Umgebung aus echten Aufnahmen, Schritte passend zum Untergrund; Hintergrundklänge selbst vorgeschlagen (44d, `DESIGN-STIL.md`).
9. **Geprüft:** Kollision 0 (nirgends hindurchlaufen), Sprungtest 0, Tippen trifft das gezeichnete Ding; Standbilder bei Tag und Nacht.

## Selbst prüfen, bevor etwas gezeigt wird

- Jede neue Animation, Haltung oder Waffe wird automatisch auf **Kollisionen** geprüft: Waffe durch Körper, Kopf, Beine oder Schild, Stab durch den Körper, Schild durch die Waffe. Für alle Völker, Geschlechter und Staturen.
  - Werkzeuge in der Vorschau (`tools/preview`): `CLASH=1`, `CLERICCLASH=1` und vergleichbare Prüfläufe; Ziel ist immer 0 Treffer.
- Jede Bewegung wird als Bildfolge angesehen, nicht nur ein Standbild: Ausholen, Treffer, Rückweg, Übergänge.
- **Silhouetten prüfen:** Jede Figur und jedes Ding von allen Seiten auf unfreiwillig Komisches oder Anstößiges ansehen (Beispiel 10.10.: ein waagerecht nach vorn zeigender Dolch auf Hüfthöhe beim Goblin).
- Jeder Angriff ist sichtbar, auch ein Fehlschlag: Geschosse fliegen vorbei, Flammen schlagen neben dem Ziel ein.
- Umgang mit Waffen muss stimmen: Griff, Abstützen, Rückstoß, Haltung in Ruhe.
- **Eine Aktion ist ein Stück:** Bewegung zuerst, dann eine einzige Textzeile mit Ausgang und Schaden; kein Tippen mitten in einer Aktion. Der Kampf läuft von selbst weiter, im eingestellten Kampftempo.
- **Kampfabläufe selbst durchspielen**, eigenverantwortlich und genau, bei jedem neuen Monster und jeder Änderung an Kampf oder Bewegung: Passt die Haltung zu jeder Meldung (Angriff, Treffer, Verfehlen, Abwehr, Konter, Zauber, Wurf, Sturz)? Wird keine Bewegung unterbrochen, doppelt gespielt oder fällt zu früh in die Ruhe zurück? Bleiben gehaltene Haltungen (Ausholen, Abwehr, Zauber sammeln) stehen, bis die nächste Meldung sie auflöst?
  - Nicht nur die Logik lesen, sondern durch die echte Oberfläche filmen und die Bildfolge ansehen: Vorschau `FILM=klasse:gegner FILMTAPS=SFASSS` (S Szene/Weiter, F Kampf, A Angriff, D Abwehr) legt in Echtzeit alle 80 ms ein Bild ab. Mehrere Klassen und Waffen, mit und ohne Abwehr.
  - **Einmal in Echtzeit bei Tempo „Normal“ ansehen, nicht nur in Zeitlupe** (321): flüssig und erkennbar. Richtwerte gesamt: Stich, Biss 0,6 s; Schwert-, Axthieb 0,8 s; schwerer Hieb nach dem Ausholen 0,9 s mit kurzem Halt beim Aufschlag; Ausholen länger als der Schlag. Langsame Gegner (Zombie) länger, flinke kürzer, solange man es sieht.

- **Sprungtest (Thema 12, 10.10.):** Jede Bewegung und jeder Übergang (Stehen, Atmen, Gehen, Drehen, Haltungen hinein und heraus, Gehen ↔ Stehen, Rudel folgt) wird Bild für Bild auf Sprünge geprüft: `JumpTest` in `core` (`./gradlew -p core test --tests '*JumpTest*'`), ohne Bild, in Sekunden. Ziel 0 Meldungen, wie bei den Kollisionen. Neue Bewegungen kommen dort als Prüffall hinzu.

## Leistung

- **Erst messen, dann beschleunigen** (24.14): Zeiten im Test-Reiter oder mit `ARTMEM` messen, bevor optimiert wird.
- **Kein Absturz ohne Bericht** (30): Fehlertext holen, dann suchen.
