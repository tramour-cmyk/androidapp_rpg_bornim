# Antworten Fachkraft (Falltest Lauf 3, 22.11., 07:21)

Geladen: `lt3/sockel.md`, je Fall der Auftrag. Feld 4 beider Aufträge nennt `docs/entwurf/1727-muster/profil-figur-und-pruefbild.md` und `docs/entwurf/1727-muster/querprofil-signatur-und-leben.md`: **beide fehlen in `lt3/`**; ich arbeite ohne (im Repo liegen sie, ich habe sie nicht gelesen). Nachgesehen (nur lesend): `tools/vorgang.py --hilfe`, `tools/rueckmeldung.py` (Signalworte, Obergrenze B = zweites „steckt fest“), Zweige `origin/claude/tom-1535-gruss` (Spitze `bfd783a3c`), `origin/claude/spike-1694-griff` (Spitze `7c7ce0f02`, Prüfung `godot/tests/griff_alle_1694.gd`), `godot/tests/achsel_1515.gd`, `tools/blender348/v3/kauf_kleid.py`, `godot/regeln/halt.json`, Aufruf von `tools/godot/bau_am_rechner.py`.

## W7 · Auftrag A7 (1535, Kleidung bei gehobenem Arm)

Gemeinsam für a und b (eigene Sitzung je Lage):

1. Quelle zuerst (Feld 2): wie andere Spiele Kleidung bei gehobenem Arm binden (Gewichtung der Kleidung aus dem Körper übertragen, Achsel- und Oberarmgewichte), Link mit Datum in die Rückmeldung.
2. Stand holen:
   ```
   git fetch origin && git checkout claude/tom-1535-gruss && git merge origin/main
   python3 tools/godot/bau_am_rechner.py --laden --cache
   ```
3. Prüfung bauen (Feld 5): neue Prüfung `godot/tests/flanke_1535.gd` am gezeichneten Netz in der Endpose der Ruhebewegung mit gehobenem Arm (Garrick Gruß, Bram im Kittel Hand zum Mund), Abstand Flanke–Körper in mm; nicht `achsel_1515` (misst den gehobenen Arm nicht, Feld 4). Erst am Stand von Build 299 laufen lassen, Beleg: Befehl mit Ausgabe, muss **rot** sein:
   ```
   git checkout <Commit Build 299> -- godot/ && godot --headless --path godot -s res://tests/flanke_1535.gd   # Erwartung: rot
   ```
4. Ursache nachstellen: Gewichte der Kittel-Dreiecke an der Flanke ausgeben; Lage: Gewichte am Oberarm fehlen. Beheben in `kauf_kleid.py` (ein Weg für alle Kaufkleider, nicht je Figur).
5. Prüfung über alle Fälle derselben Art (jede Figur mit Kaufkleid × jede Ruhebewegung mit gehobenem Arm), Kerntests mit Exit-Code, dann genau ein Bildlauf: Bild alt (Build 299) gegen neu, Spielkamera Handygröße, Flanke markiert, beschriftet mit Figur und Commit, Garrick und Bram je ein Feld.
6. Selbstprüfung Feld 6, dann senden oder nicht.

### Lage a (Bild zeigt die Flanke am Körper)

Feld 6 durchgehen: Neues im Bild (Beschriftung neu = mein Commit) ja · Flanke in jedem neuen Feld am Körper, keine Beule (15:59) ja, laut Lage · Unterschied ohne Erklärung sichtbar ja · kein Zug Jacke → Arm (15:33): im Bild prüfen, die Lage sagt dazu nichts; nur bei ja senden · Prüfung über alle grün, Zahl genannt: nur senden, wenn die Prüfung aus Schritt 5 grün ist.

```
git add tools/blender348/v3/kauf_kleid.py godot/tests/flanke_1535.gd godot/tests/flanke_1535.gd.uid
git commit -m "1535: Kittel-Gewichte am Oberarm (kauf_kleid.py), Prüfung flanke_1535 über alle Kaufkleider mit gehobenem Arm"
git push origin claude/tom-1535-gruss
python3 tools/vorgang.py rueckmeldung 1535 "fertig 1535: Ursache Gewichte des Kittels am Oberarm fehlten (belegt an Build 299, flanke_1535 rot), behoben in kauf_kleid.py für alle Kaufkleider; Prüfung flanke_1535 grün über <N> Fälle (Figur × Ruhebewegung mit gehobenem Arm); Messung Flanke 67 → 57 mm, im Bild sichtbar; Commit <neu>, Zweig claude/tom-1535-gruss gepusht; Bild alt (Build 299) gegen neu, Garrick und Bram je ein Feld, Spielkamera Handygröße, Flanke markiert; Quelle: <Link, Datum>" --sitzung Fachkraft
```

Wirkung laut `rueckmeldung.py`: „fertig“ mit Commit → offene Zeile an den Prüfer. Danach nichts weiter an 1535.

### Lage b (Bild zeigt keinen sichtbaren Unterschied)

Feld 6, dritte Frage „Unterschied ohne Erklärung sichtbar?“ nein, zweite (Flanke am Körper) damit auch nein → **nicht senden**, kein „fertig“. Erst belegen, dass das Bild wirklich den neuen Stand zeigt (Beschriftung und Laufkopf = mein Commit, Kaufmodell neu gebaut statt alter Cache, Endpose mit gehobenem Arm). Stimmt das Bild, gilt das Bild, nicht die Messung (Feld 4: „Eine Messung, die das Bild nicht zeigt, gilt nicht (67 → 57 war unsichtbar)“). Kein zweiter Versuch mit Vermutung; Feld 7: nach Ursache und Behebung nicht sichtbar = „steckt fest“.

```
git add tools/blender348/v3/kauf_kleid.py godot/tests/flanke_1535.gd godot/tests/flanke_1535.gd.uid
git commit -m "1535 (angefangen): Kittel-Gewichte am Oberarm, Prüfung flanke_1535; Bild ohne sichtbaren Unterschied"
git push origin claude/tom-1535-gruss
python3 tools/vorgang.py rueckmeldung 1535 "steckt fest 1535: nach Ursache und Behebung im Bild nicht sichtbar. Versucht: Gewichte des Kittels am Oberarm ergänzt (kauf_kleid.py), flanke_1535 an Build 299 rot, neu Messung Flanke 67 → 57 mm, dieselbe Zahl, die schon an 7ffa715 unsichtbar war; Bild alt gegen neu (Garrick, Bram, Spielkamera, Stand im Laufkopf = <neu>) zeigt keinen Unterschied. Folgerung: die Messung trifft die sichtbare Beule nicht, Ursache damit unbelegt. Commit <neu>, Zweig claude/tom-1535-gruss gepusht; Quelle: <Link, Datum>" --sitzung Fachkraft
```

Wirkung: „steckt fest“ → offene Zeile an Sokrates. Ich höre auf, keinen weiteren Versuch ohne neue Freigabe.

## W8 · Auftrag A1 (1694, Griff in der geschlossenen Faust)

Gemeinsam: Quelle zuerst (Feld 2, Griffpunkt je Gegenstand, Finger Glied für Glied, Unreal/Unity), Link mit Datum. Stand holen:
```
git fetch origin && git checkout claude/spike-1694-griff && git merge origin/main
python3 tools/godot/bau_am_rechner.py --laden --cache
godot --headless --path godot -s res://tests/griff_alle_1694.gd   # Ausgabe mit Fehlerzahl je Gruppe
```
Je Fehlergruppe (Staffel, Bögen, Zombies 54/55, Rest) Ursache rot zeigen, belegen, beheben; Griffhöhe je Waffe als Wert in `godot/regeln/halt.json`; Stieldicke der 14 Staffelwaffen (5–7 cm) nicht ändern, nur nennen. Kein Bildlauf, solange die Prüfung über alle 1540 nicht grün ist (Feld 5).

### Lage a (rot, 752 von 1540, Commit `04bf8ffc1`)

Feld 6 „Prüfung grün“ nein → nicht senden, kein Bildlauf. Auffällig: 752 ist dieselbe Zahl wie vorher an `7c7ce0f02`, die Behebung hat also nichts bewegt; das gehört in die Meldung. Feld 7: nach Ursache und Behebung rot = „steckt fest“.

```
git push origin claude/spike-1694-griff
python3 tools/vorgang.py rueckmeldung 1694 "steckt fest 1694: griff_alle_1694 nach Ursache und Behebung rot, 752 von 1540, Commit 04bf8ffc1, Zweig claude/spike-1694-griff gepusht. Gleiche Zahl wie vorher an 7c7ce0f02, Behebung ohne Wirkung. Versucht: <je Gruppe Ursache und Behebung, Zahl rot je Gruppe Staffel/Bögen/Zombies 54/55/Rest aus der Ausgabe>. Stieldicke 5–7 cm (14 Staffelwaffen) nicht geändert. Kein Bildlauf, da rot. Quelle: <Link, Datum>" --sitzung Fachkraft
```

Wirkung: erstes „steckt fest“ zu 1694 → Zeile an Sokrates. Ich halte an.

### Lage b (zweiter Versuch, Deckel „ein Versuch, Griffpunkt je Waffe“; wieder rot, 610 von 1540, Commit `d8dce68a2`)

Genau ein Versuch innerhalb des Deckels: Griffpunkt je Waffe (Werte in `halt.json`), sonst nichts. Ergebnis rot → kein zweiter Versuch, kein Bildlauf, nicht „fertig“.

```
git push origin claude/spike-1694-griff
python3 tools/vorgang.py rueckmeldung 1694 "steckt fest 1694: wieder rot, 610 von 1540 (vorher 752), Commit d8dce68a2, Zweig claude/spike-1694-griff gepusht. Versucht im Deckel von Sokrates (ein Versuch): Griffpunkt je Waffe in halt.json. Rest je Gruppe: <Zahlen aus der Ausgabe>. Stieldicke 5–7 cm (14 Staffelwaffen) nicht geändert. Kein Bildlauf, da rot." --sitzung Fachkraft
```

Wirkung laut `rueckmeldung.py`: zweites „steckt fest“ zu 1694 = Obergrenze B → „ruht, beim Chef“, Zeile an Sokrates „an den Chef: Chefsache anlegen, nicht selbst lösen“. Ich arbeite nicht weiter an 1694.

## Lücken

1. Profile fehlen: Feld 4 nennt „`docs/entwurf/1727-muster/profil-figur-und-pruefbild.md`“ und „`docs/entwurf/1727-muster/querprofil-signatur-und-leben.md`“, in `lt3/` liegt keins. Was dort zu Prüfbild und Signatur steht, fehlte mir.
2. Quelle: Feld 2 „Quelle fehlt: erster Schritt, mit Link“; der Fall gibt kein Ergebnis dazu, darum `<Link, Datum>` offen. Unklar, ob „steckt fest“ ohne Quelle gesendet werden darf.
3. Zahl der Fälle (A7): Feld 7 verlangt „Zahl der geprüften Fälle“, Feld 2 „jede Figur mit Kaufkleid in jeder Ruhebewegung mit gehobenem Arm“; wie viele das sind, sagt weder Auftrag noch Fall (`<N>`).
4. W7a „Kein Zug von der Jacke zum Arm (15:33)?“: die Lage sagt nur „Flanke am Körper“; ob der Zug weg ist, bleibt offen. Ebenso, ob beide Felder (Garrick, Bram) die Flanke am Körper zeigen.
5. W7b: Feld 7 „‚steckt fest‘ (nach Ursache und Behebung nicht sichtbar)“ deckt den Fall; nicht geregelt, ob ich vorher die Messgröße ändern darf, wenn sie offenbar das Falsche misst (Feld 4: „Eine Messung, die das Bild nicht zeigt, gilt nicht“). Ich habe es nicht getan.
6. W8b: der Deckel „ein Versuch, Griffpunkt je Waffe“ steht nicht im Auftrag A1 (Feld 3 „Bisher“ nennt den ersten Versuch `04bf8ffc1` nicht); woher ich die Freigabe sicher lese (Vorgangsdatei, Zeile), sagt der Auftrag nicht. Sockel: „Sitzungen bringen Aufträge, nie seine Freigabe“ – die Freigabe von Sokrates behandle ich als Lauffreigabe, nicht als Chefwort.
7. A1 Feld 5 „Je Fehlergruppe … Ursache rot zeigen und belegen“: Gruppenzahlen gibt der Fall nicht; in den Meldungen Platzhalter.
