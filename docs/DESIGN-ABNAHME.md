# Abnahme

Wie gebaut und geprüft wird: die Einzelheiten zum [Leitbild](DESIGN-LEITBILD.md) (Grundsätze 5, 10, 11, 12). Wie das Spiel aussieht und klingt, steht in [Stil](DESIGN-STIL.md); Abläufe (Notizen, Builds, Nummern) in `CLAUDE.md`, seltene (Release, Neustart) in `LISTE-RELEASE-NEUSTART.md`.

## Vor jeder Vorlage (461)

Gilt für jede Probe, jedes Bild und jeden Film zu Figuren, Bewegung und Kampfort (Chef 01.11., 20:3x, Archiv 461; ein Ort 461d, Prüfung vor dem Versand 461a, 01.11., 22:5x; 480). Die Punkte stehen je einmal, hier nur Kennung, Stichwort und Ort.

**Wie geprüft wird** (373, 396 gelten weiter, außer wo hier anders):
- Wer vorlegt, prüft vor dem Versand jeden Punkt, der im Bild vorkommt; die Vorlage nennt „Geprüft an: <Link auf Film, Bild oder Lauf>“ (340.4, ersetzt „461 geprüft“), ein Verstoß steht dabei als „Punkt X verletzt, weil …“.
- **Prüfung vor dem Versand (783 W1, Chef 09.11., 20:12; ersetzt 461a, 480, 511):** Punkte mit „Prüfer: ja“ **und jede Auflage aus dem letzten Urteil des Chefs zu dieser Vorlage** (576, Vorentscheid Sokrates 04.11., 20:5x; Chef 20:49: „wieso wird mir so eine Grütze nochmal vorgelegt?“) prüft der Ersteller selbst **vor** dem Versand am Einzelbild (`PROBEBILD=`), nur ja/nein oder gemessen, nie die Wirkung (373), ohne Helfer; einen Verstoß behebt er vorher. Bewegung geht dann gleich als Film an den Chef, ohne Probebild. Je Aussehen-Thema eine Probe vor dem Chef (621 A, Chef 07.11., 16:4x); offene Punkte als Vermerk in einfachen Worten (646); keine Frage „neue Läufe?“ an ihn (480). Passt die Probe nicht: Rückfrage mit Wegen und Kosten; weitere Läufe gibt sein Urteil oder Sokrates frei (407, 480.1). Alle anderen Befunde kommen wie bisher nach dem Versand als Text (396).
- **Bild oder Film als Test** (1128 A, Chef 13.11., 13:36): ein Prüfpunkt der Art Bild oder Film ist eine Vorlage wie hier, aus dem Lauf, der die APK baut (`LISTE-CHECK-BUILD-TEST.md` 9); je Gegenstand ein Bild, Vergleich alt gegen neu in einem Bild (`CLAUDE.md` 9).
- „Maß“ = Zahl von uns, nur Richtwert, hält nicht an; „–“ = Wirkung, nur Selbstprüfung.
- Abweichen darf nur der Chef; dann die Zeile an ihrem Ort ändern, mit Wortlaut und Zeit, am alten Archiveintrag „→ ersetzt durch …“ (461b). Perikles gleicht montags mit dem Wochenziel gegen das Archiv ab, Diogenes zählt Widersprüche (461b).

**Kennungen** (Prüfer ja, außer – und Maß):
- `DESIGN-STIL.md` „Figuren und Bewegung“: A1 Spielshader · A2 Tusche nach Licht · A3 Signatur auch an Kaufmodellen · A4 Schatten unter dem Körper · A5 Held überall gleich (–) · A6 Ausrüstung räumlich (–) · B1 Kaufkörper, Köpfe, Hauttöne · B2 Grundkörper je Volk · B3 Tracht, Haar, Frisuren · B4 Kleidung geschlossen · B5 Schilde Kleriker und Krieger · B6 ruhend vor bewegt (–) · B7 Größen · C1 Atmen immer · C2 kein Stillstand (1 s Maß) · C3 kein Gleichtakt · C4 Ruhebewegungen wechseln (–) · D1 Übergänge weich (–) · D2 Gang aus dem Waffenpaket · D3 Gehen aufrecht, langsamer (–) · D4 Ortswechsel gelaufen, kein Gleiten · D5 Boss schreitet (–) · D6 nicht durcheinander.
- `DESIGN-KAMPF.md` „Waffe, Schild und Kampf im Bild“: E1 Waffe getragen, nicht jeder gleich (417a) · E2 nach Paketvorlage · E3 nichts durch etwas (2 cm Maß) · E4 Sword & Shield · E5 Hinfallen, Aufstehen · E6 Kriegsaxt, Zweihänder · E7 Waffenformen nach Stufe · E8 Schild am Arm oder auf dem Rücken (417a) · F1 Schild vor dem Biss · F2 trifft das Ziel · F3 Reihenfolge · F4 Zusammenbruch · F5 Ausweichen · F6 Zauber nicht aus dem Körper.
- Hier, G Film und Vorlage:

| Nr. | Prüfpunkt | Woher | Prüfer |
|---|---|---|---|
| G1 | Ausschnitt so, dass jede Figur ganz im Bild ist | 385.1 (28.10.) | ja |
| G2 | Keine fremden Bilder an den Schnitten | Prüferbefund (d) zu 406, kein Chefwort | Maß |
| G3 | Text der Vorlage im generischen Maskulinum („Held“, nie „Heldin“) | 348.12f (28.10.), 408 (29.10.) | ja |
| G4 | Film zeigt nur den Prüfgegenstand, etwa dreimal hintereinander, bis 15 s; Kamera so, dass man ihn gut sieht, nicht die Standardsicht | 1076 (Chef 12.11., 20:42 zu 1039, 20:54 zu 758); 1078 | ja |

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
