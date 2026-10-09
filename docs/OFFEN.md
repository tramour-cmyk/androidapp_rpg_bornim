# Offen

Was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Stand: 09.10.2026, 22:10 (Berliner Zeit). Regeln: [CLAUDE.md](../CLAUDE.md) und [Stil-Leitlinien](STIL.md). Ideen für später: [Merkliste](MERKLISTE.md). Umgesetztes und von dir Bestätigtes: [Änderungshistorie](../CHANGELOG.md); bestätigte Punkte wandern sofort dorthin, damit diese Liste kurz bleibt.

## Übergabe-Notiz (für jede neue Sitzung)

**Stand:** v0.1.325 auf `main`, von dir getestet. Alle 18 Gegner sind im neuen Stil (Puppenkörper `FoeArt`, Tiere `BeastArt`, Ungeziefer `VerminArt`/`Vermin.kt`). Die Kartenarbeit (Garrick, neuer Kartenstil, Höhle) läuft auf `karte-neuer-stil` und `karte-hoehle`.

**Prüfen:** `tools/t` (siehe [UMGEBUNG.md](UMGEBUNG.md)). Vorschau-Schalter für `tools/t bild`/`film`:
- `FILMBATCH=datei` (dazu `FILMSTEP=40`): mehrere Kampffilme, je Zeile `name klasse:gegner stufe seed plan [aktionen] [hero=…] [foe=…] [foefirst] [failsaves] [crits] [race=HALF_ORC] [place=village] [blood=…] [weapon=…] [kill=…]`, z. B. `holy cleric:zombie 5 1 XWW item=holy_water`. X löst die nächste Aktion aus, W wartet; Bilder unter `tools/preview/build/screens/films/<name>/`. Filme laufen in Echtzeit (4 Kämpfe ≈ 1 min); Bash-Aufrufe brechen nach 10 min ab.
- `FILM=klasse:gegner` mit `FILMTAPS` (Tipper durch die Menüs) für Einzelfilme.
- Übersichtsblätter in Sekunden: `ABILITYFX=1`, `STATUSFX=1`, `FOEANIM=ghoul:0,goblin:2`, `VERMINANIM=giant_spider:0`, `CLASH=1`/`FOECLASH=1` (Durchdringungen, Ziel 0), `JELLYWOUND=1`; Entwürfe `VERMINSHEET=1`, `VERMINCLOSE=bat`.
- Bilder zum Ansehen mit ImageMagick (`montage`, `convert`) zuschneiden.

**Kampfanzeige (Stand 09.10.):** Treffer = Innehalten beim Aufprall (70 ms, Nahkampf), dunkelrote Färbung (`hurt` in `PixelSprite`), Blut im Augenblick des Aufpralls; Rütteln nur bei kritischen Treffern; kein Blinken. Gift/Brennen/Bluten (`isTick()`) sind kein Schlag des Gegners. Tatendrang einmal pro Rast (`SkillCost.PER_REST`, `Hero.spent`).

**Im Spiel zum Testen:** Testmodus (7× auf das Copyright im Titel tippen), Reiter „Test“: Stufe, Gold, Vorräte auf 10, „Gegner bestehen keine Rettungswürfe“, „Held trifft immer kritisch“, Testkämpfe gegen jeden Gegner, Beute erzeugen.

**Änderungshistorie:** neue Einträge unter „## Unveröffentlicht“, bei Veröffentlichung umbenannt in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Build-Laufs).

## In Arbeit

- **Testumgebung** (PR #9, Zweig `claude/ecstatic-albattani-2ob0np`, grün): Google-Spiegel für Gradle, Vorwärmen von `core`, `tools/t`, Zufallsspieler `PlayerSimTest`, CLAUDE.md-Regeln aus `karte-neuer-stil`, kein APK-Build für reine Werkzeug-Änderungen. Wartet aufs Zusammenführen durch dich (die Sitzung darf nicht selbst auf `main` zusammenführen).
- **Film-Uhr (A), freigegeben 09.10., 22:08:** Kampffilme laufen in Echtzeit, weil `app/.../BattleScreen.kt` die Abfolge mit `delay` und `System.currentTimeMillis()` taktet; die Bewegungen (`Animatable`, `tween`) laufen schon auf der Bilduhr. Plan: Uhr `BattleClock` (auf dem Gerät die Systemuhr), Wartezeiten über Bilder statt `delay` (±1 Bild), die Vorschau stellt die Uhr selbst. Referenzfilme vom alten Stand liegen vor (Nahkampf, Fernkampf, Zauber, Killerschlag; 56 s). Eigener Zweig, Filmvergleich vorher/nachher, dann Zweig-Build für dich. Danach (B) Ablaufprotokoll mit Prüfregeln, (D) Bildvergleich.
- **Film-Uhr, Zwischenstand 09.10., 22:57 (Zweig `claude/film-uhr`, nicht installieren):** Kampfbildschirm auf `BattleClock`/`pause` umgestellt, Zufall der Anzeige säbar, Film zeichnet vollständig (140 statt 76–102 Bilder) und speichert nebenher. Offen: Filme mit Angriffen bleiben beim ersten Hieb stehen (Ursache noch nicht gefunden); in 5 von 140 Bildern weichen einzelne Pixel ab (parallele Figurenzeichnung). Deine Fragen dazu (22:57): „Was machst du die ganze Zeit?“ und „Haben wir sitzungs- und accountübergreifende Tests?“, beantwortet im Chat.
- **Fassungen zusammenführen (freigegeben 09.10., 22:08):** Nach PR #9 `main` in `karte-neuer-stil` übernehmen und die doppelten Fassungen von `CLAUDE.md`, `UMGEBUNG.md`, `check-env.sh` und `OFFEN.md` zusammenführen.

## Zu testen

Nichts offen.

## Zu entscheiden

- **Noch mehr Zwischenbilder?** Die Haltungen selbst (Arme, Beine, Waffe) wechseln 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung kurz ab. Nach deinem Test von 0.1.208 vorerst nicht nötig; bei Bedarf als eigener, größerer Umbau (mehr Bilder, längeres Vorabzeichnen zu Kampfbeginn).
- **Hörproben:** Auswahl für Klick, Beute, epische Beute, Münzen, Truhe, Tür, Stufenaufstieg, Gegner fällt.

## Geplant

- **Sterbeanimationen für alle Gegner:** Alle Gegner im neuen Stil haben je drei Stürze und bleiben liegen. Seit 09.10. sind alle Gegner im neuen Stil; Schamane und Ghul fallen wie die Goblins, die Tiere aus dem Entwurf haben ihre eigenen Stürze.

- **Klänge überarbeiten (Rest)** nach den [Stil-Leitlinien](STIL.md): weg von quietschenden Nintendo-Tönen, hin zu glaubwürdigen Geräuschen. Die Kampfgeräusche (Hiebe, Stiche, Schläge, Biss, Pfeil, Schwung, Wolfsheulen) wurden schon einmal realistischer gemacht und werden mit geprüft; Abwehr („Klonk“) und Fehlschlag („Wusch“) sind schon neu. Noch im alten Stil sind vermutlich:
  - Menü und Bedienung: Klick.
  - Belohnungen: Stufenaufstieg, Beute, epische Beute, Münzen, Truhe.
  - Welt: Tür, Begegnung, Alarm (Gegner bemerkt dich), Hinterhalt.
  - Zauber und Tränke: Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf.
  - Kampfende: Gegner fällt, Held fällt.
  - Umgebung: Vögel, Grillen, Eule, Tropfen, Knistern.
  - Musik prüfen, ob sie zum düstereren Stil passt.
  - Vorgehen: erst Hörproben einzelner Geräusche zum Vergleich, dann nach deiner Freigabe umstellen.

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, das ist die Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Kartenfigur:** bleibt vorerst das alte Männchen. Auch die Wölfe auf der Karte behalten vorerst ihr gezeichnetes Bild.
- **Dorf und Häuser:** Dort gibt es keine Kämpfe (nur Testkämpfe über den Test-Reiter). In Testkämpfen im Dorf erreichen sich Held und Gegner beim Angriff nicht (alte Kulisse ohne berechneten Schritt); kein Fehler, so gelassen (08.10.). Testkämpfe im Wald oder in der Höhle machen. Die alten Kulissen bleiben; bekommt das Dorf später echte Begegnungen, gibt es eine Kulisse im neuen Stil.
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag mit Treffer/Fehlschlag): so bestätigt.
