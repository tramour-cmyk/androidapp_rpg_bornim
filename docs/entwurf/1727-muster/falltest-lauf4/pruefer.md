# 1727 · Falltest Lauf 4: Prüfer (Abnahme)

Geladen: `sockel.md`, `kern-abnahme.md`, `profil-pruefer.md`; dazu, weil die Aufträge sie unter „Beachte“ nennen: `querprofil-signatur-und-leben.md`, `profil-fremde-inhalte.md`. Repo nur lesend in `kopie/` (`8e3f182b1`). Rückmeldungen unten sind die Befehle, die ich absetzen würde (nicht abgesetzt); die erwartete Ausgabe steht nach `tools/rueckmeldung.py` darunter, die Zeilen `WECKER <Sitzung> | sieh in <Nr> (<Kennung>)` schicke ich je als `send_message` an die genannte Sitzung.

## P1

(a) Prüfung, Reihenfolge nach Profil Prüfer:
1. Erst sehen: Bild angesehen, bevor ich die Rückmeldung lese. Zwei Felder je Figur, „alt `7ffa715`“ und „neu `3c1f0aa`“, Spielkamera; unter dem gehobenen Arm in beiden Feldern dieselbe Beule über Körperbreite.
2. Neues drin (Schritt 1): gemeldeter Commit `3c1f0aa` ≠ Bisher `547033f9f`, also kein Belegmangel aus Gleichheit. `git -C kopie log -1 3c1f0aa` → „unknown revision“ (im Test angenommen, nicht in der Kopie). Das neue Feld trägt `3c1f0aa`, also kein „anderer Stand“ im Sinne von „Beleg fehlt und Ende“. Ist das Neue darin? Nicht nachweisbar: alt und neu gleich, nur die Beschriftung unterscheidet sie (Prüffrage 1 verlangt „neues Modell im Bild“, nicht Beschriftung). → nein, weiter mit 2–4.
3. Beleg (Schritt 2): altes Feld mit `7ffa715` beschriftet; `git log -1 7ffa715` → `7ffa71528 15.11. 21:19 431 Tuch letzter Lauf …`, also ein Commit zu 431, nicht Stand 299 (Prüfart: „Bild alt (299) gegen neu“; Bisher sagt dasselbe). Flanke markiert, Handygröße, Bewegung in der Beschriftung: im Beleg nicht genannt. Feld 7 fehlt: roter Commit, Zweig gepusht, Zahl der Fälle, Quelle mit Datum (Systemfrage), Testausgabe fehlt. Messung „67 → 57“ ist wortgleich die Messung unter Bisher (`547033f9f`).
4. Ziel und Prüffragen (Schritt 3): Ziel „keine Beule“ nicht erreicht.
   - Neues nachweislich im Beleg? Nein, beide Felder gleich, nur beschriftet.
   - Unterschied alt gegen neu? Nein, dieselbe Beule in beiden Feldern.
   - Flanke neu innerhalb der Körperbreite, ohne Faden? Nein, Beule über Körperbreite.
   - Prüfung über alle Figuren null Fehlfälle? Nein, keine Angabe.
   - Chef-Neins aus Bisher/Chefworte erneut geprüft: 15:59 „Das sieht man ja die Beule direkt“ und 21:47 „kein Unterschied zwischen alt und neu“ treffen weiter zu.
   - Auftrag Punkt 5 (4) „Beule nicht sichtbar kleiner: nicht senden“ wurde nicht beachtet.
5. Nur am Geänderten (Schritt 4): Signatur und Leben: Beule ist ein Sachverhalt, der das Eintauchen bricht → Mangel (schon oben). Fremde Inhalte: Kaufkleid, keine neue Datei gemeldet; nichts weiter zu sehen.
6. Steckt fest? Unter Bisher steht „Nein des Chefs: ‚299.3 ✗‘“ zu derselben Arbeit → „nein“ mit „steckt fest“.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1535 "nein, steckt fest. (1) Bild Garrick und Bewohner im Kittel, Feld neu 3c1f0aa: dieselbe Beule unter dem gehobenen Arm über Körperbreite wie im Feld alt; Flanke an den Körper bringen, ohne Faden. (2) Feld alt gegen neu: kein Unterschied zu sehen, das neue Modell ist nur durch die Beschriftung belegt; am Rechner nachweisen, dass das Bild das neue Modell zeigt. (3) Messung 67 → 57 gleicht der unter Bisher (547033f9f); Ursache als roten Test am Netz zeigen, mit Commit. (4) Prüfung über alle Figuren mit Kaufkleid: Zahl der Fälle und Fehlfälle fehlen. (5) Beleg: Feld alt trägt 7ffa715, laut git ein Commit zu 431, nicht Stand 299; alt aus 299 zeigen, Flanke markieren, Handygröße und Bewegung nennen. (6) Rückmeldung ohne roten und behobenen Commit, Zweig, Quelle mit Datum und Testausgabe. (7) Auftrag 5 (4): Beule nicht sichtbar kleiner, hätte nicht gesendet werden dürfen. Steckt fest, weil Chef-Nein 299.3 ✗ (18.11.) zu derselben Arbeit: es fehlte die Handwerksregel, erst die Ursache als roten Test am gezeichneten Netz nachzustellen und vor dem Bildlauf zu belegen, dass das Bild das neue Modell zeigt (1711)."
```
Erwartet: `EINGETRAGEN 1535, OFFEN 1535-Ü<k> an Sokrates`, `OFFEN 1535-Ü<k+1> an Tom` (Mängelsätze an den Macher, wartet auf Sokrates; 1873), `LISTE 1535: … steckt fest, wartet auf Sokrates`, dann die WECKER-Zeilen → je `send_message`.

Lücken:
- „Zeigt der Beleg einen anderen Stand: ‚Beleg fehlt‘ und Ende“: der Text sagt nicht, ob das für das Feld alt gilt. Hier zeigt alt `7ffa715` (431) statt 299. Ich habe es nur auf das Feld neu bezogen und den Fehler alt als Belegmangel gemeldet.
- Ob eine Beschriftung allein „das Neue darin (bei Modellen Name oder Kennung)“ belegt, wenn das Bild gleich ist, sagt der Text nicht. Ich habe „nein“ gemeldet, weil Prüffrage 1 „neues Modell im Bild“ verlangt.
- „ein Satz, welche Handwerksregel fehlte“: mein Text nennt keine Handwerksregeln und keine Quelle dafür (das Profil Figur und Prüfbild, das der Auftrag nennt, lädt mein Text nicht). Die Regel habe ich aus Auftrag und Vorgang (1711) genommen.
- Text gegen Werkzeug: Mein Text zählt jedes Nein des Chefs „unter ‚Bisher‘ oder in der Vorgangsdatei“. `rueckmeldung.py` zählt (`zaehlen`, `chefwort.chef_nein`) nur Chefworte, die mit „nein“, 👎 oder „✗“ am Zeilenanfang beginnen; „Das sieht man ja die Beule direkt“ und „kein Unterschied zwischen alt und neu“ zählen dort nicht, und Bisher liest das Werkzeug gar nicht. Für „steckt fest“ ist das egal, weil das Wort in meiner Meldung steht, für Laufbremse und Obergrenze A aber nicht.
- Kein `--sitzung`: mein Text nennt die Option nicht; ohne Zeile in der Besetzung trägt das Werkzeug „unbekannt“ als Absender ein.

## P2

(a) Prüfung:
1. Erst sehen: Bild beschriftet, Spielkamera; Waffen kürzer; bei allen vier Figuren berührt keine Hand den Griff, die Waffen schweben etwa eine Fingerbreite vor der Hand.
2. Neues drin: `9e2d1b4` ≠ Bisher `560dc884b` (`git log -1 9e2d1b4` → unbekannt, im Test angenommen; `560dc884b 18.11. 16:16 1621: ZWEI_GRIFF über Umgebung …`). Neues ist zu sehen (kürzere Waffen, neues Feld beschriftet) → ja.
3. Beleg: Prüfart verlangt „Held trägt je Zweihandwaffe“ (drei: Großaxt, Kriegshammer, Zweihänder), „Ausschnitt Hände“, Handygröße. Das Bild zeigt vier Figuren, Ausschnitt und Handygröße sind nicht genannt. Feld 7 fehlt: Ausgabe `waffen_522`, Zahl der geprüften Waffen, Zweig gepusht; Testausgabe der Faustprüfung fehlt.
4. Ziel und Prüffragen:
   - Neues nachweislich im Beleg? Ja, Waffen sichtbar kürzer, beschriftet.
   - `waffen_522` 110, 100, 115 cm, Speer und Hellebarde unverändert? Nein, keine Ausgabe. Die Rückmeldung sagt „um 20 % kürzer“, das Maß Wahl A ist 131 → 110 (−16 %), 115 → 100 (−13 %), 128,5 → 115 (−10,5 %), Speer und Hellebarde bleiben. Die Längen galten schon (Bisher, Chef 18.11., 11:55); der Auftrag war der Griff.
   - Umschließt jede Faust den Griff, auch die rechte (Chef 16:50)? Nein, keine Hand berührt den Griff.
   - Hält jede Hand ihre Waffe, keine schwebt (Chef vor 10:03)? Nein, alle schweben eine Fingerbreite vor der Hand.
   - Obere Hand am Griff, nicht an der Parierstange (Chef 11:56)? Nein, keine Hand am Griff.
   - Neins unter Bisher erneut geprüft: „Jede Waffe schwebt“ (vor 10:03) trifft wörtlich weiter zu.
5. Am Geänderten: Waffe schwebt vor der Hand → bricht das Eintauchen (Mangel, schon oben). Fremde Inhalte: keine neue Datei gemeldet.
6. Steckt fest: Bisher hat drei Neins des Chefs zum Griff → „nein“ mit „steckt fest“.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1621 "nein, steckt fest. (1) Bild, alle Figuren: keine Hand berührt den Griff, jede Waffe schwebt eine Fingerbreite vor der Hand; Griff in die Handinnenfläche, Finger ganz geschlossen, auch die rechte Hand. (2) Zweihänder: obere Hand nicht am Griff (Chef 11:56); an den Griff setzen, nicht an die Parierstange. (3) Längen: Rückmeldung nennt „20 % kürzer“, das Maß ist 110, 100, 115 cm, Speer und Hellebarde unverändert; Ausgabe waffen_522 beilegen. (4) Faustprüfung an allen Zweihandwaffen: rot und grün mit Testausgabe fehlen. (5) Beleg: Prüfart verlangt den Held je Zweihandwaffe (drei), Ausschnitt Hände, Handygröße; das Bild zeigt vier Figuren, Ausschnitt und Größe nicht genannt. (6) Rückmeldung ohne Zweig und Zahl der geprüften Waffen. Steckt fest, weil der Chef vor 10:03 „Jede Waffe schwebt“ sagte und das weiter zutrifft: es fehlte die Handwerksregel, erst die Faust am gezeichneten Netz der Hand rot zu prüfen und grün zu machen, dann genau einen Bildlauf."
```
Erwartet: Zeile an Sokrates und Rückläufer an den Macher, Liste „steckt fest, wartet auf Sokrates“, WECKER → `send_message`. Der Wiederholungswächter kann eine Zeile an den Disponenten geben („Systemlösung?“).

Lücken:
- „Held trägt je Zweihandwaffe“, das Bild zeigt „vier Figuren“: mein Text sagt nicht, ob mehr Figuren als verlangt ein Belegmangel sind oder egal; ich habe es als Belegsatz gemeldet.
- Grundlage „Stand von 1694“: ob der gemeldete Commit darauf steht, kann ich ohne Commit in der Kopie nicht prüfen; mein Text sagt nicht, ob ich das prüfen soll (Prüffragen fragen es nicht).
- Handwerksregel: wie in P1, keine Liste in meinem Text.

## P3

(a) Prüfung (Gegenlesen einer Testbitte, Handypunkte; Profil Prüfer „Handy“: nur „warum nicht Bild“, Testausgabe grün, Weg zur Stelle im Code je Punkt):
1. Satz „warum nicht Bild“: in beiden Zeilen nicht zu sehen (299.3 ist mit „…“ gekürzt). 299.3 „zusehen, während sie stehen“ ist Ansehen einer Ruhebewegung, kein Bedienen; das zeigt ein Film (Auftrag A7 verlangt für denselben Fund sogar nur ein Bild) → trägt nicht. 299.4 „Umhang ablegen und anlegen“ ist Bedienen im Menü → Handy trägt, der Satz fehlt aber.
2. Testausgabe: keine beigelegt.
3. Weg zur Stelle im Code:
   - Lagen sind keine Namen, sondern Zeilen „- 299.3: schlüssel=wert …“ im Abschnitt „## Lagen“ der Prüfliste (`tools/pruefliste.py:13-14`, `godot/skripte/testmodus.gd:709-717`, Schlüssel `LAGE_SCHLUESSEL`), hergestellt von `spiel.gd:1536` `lage_herstellen`.
   - 299.3 „Lage Schlagbaum“: es gibt keinen Schlüssel und keine Station „Schlagbaum“ (`testmodus.gd:182` `STATIONEN`: Garrick, Morwen, Grimmzahn, Höhle, Krogg, Grak, Lyra, Tempel). Der Schlagbaum ist Kartenzeichen „z“ im Dorf (`spiel.gd:530-531`), Jorin steht dort (`tests/lage_542.gd:145`). Herstellbar nur mit `ort=village:x:y[:Blick]`; ohne die Lagezeile nicht belegt.
   - 299.4 „Lage `vorraete`“: der Schlüssel `vorraete` ruft `Testmodus.vorraete` (`spiel.gd:1545`, `testmodus.gd:331-339`): jedes Ding aus `daten/texte.json` „dinge“ auf 10 (24 Verbrauchsdinge, kein Umhang), zwei Fackeln, ein Rauchbündel. Kein Lageschlüssel legt einen Umhang an oder in die Tasche (`LAGE_SCHLUESSEL` ohne Umhang; `ruestung=` nur Brustrüstung, `testmodus.gd:304`). Die Lage stellt also nicht her, was der Punkt verlangt → nein.
4. Wohin melden: 299.3 gehört zu 1535 (`python3 tools/vorgang.py 1535`: „Gilt als ✗ zu 299.3 für Garrick (1535 steckt in 299)“). Zu 299.4 finde ich keine Nummer (`grep "| 299 |"` in der Vorgangsliste findet keinen passenden Eintrag; vermutlich 431 Umhang, nicht belegt).

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1535 "Beleg fehlt: Testbitte Build 299, Punkt 299.3: Zusehen bei stehenden Figuren ist Ansehen, kein Bedienen; ein Film der Ruhebewegung (Spielkamera mit Tusche) zeigt es, der Satz warum nicht Bild fehlt bzw. trägt nicht. „Lage Schlagbaum“ ist keine Lage: Station Schlagbaum gibt es nicht (testmodus.gd:182), Lagezeile mit ort=village:x:y unter „## Lagen“ nennen. Testausgabe fehlt."
python3 tools/vorgang.py rueckmeldung <Nr. zu 299.4> "nein: Testbitte Build 299, Punkt 299.4: Lage vorraete füllt nur Verbrauchsdinge, Fackeln und ein Rauchbündel (testmodus.gd:331-339, spiel.gd:1545), kein Lageschlüssel gibt einen Umhang (LAGE_SCHLUESSEL); Umhang ablegen und anlegen ist so nicht herstellbar; Lage so bauen, dass der Held einen Umhang trägt. Satz warum nicht Bild fehlt; Testausgabe fehlt."
```
Die zweite Meldung erst, wenn die Nummer zu 299.4 feststeht; bis dahin melde ich nichts unter einer fremden Nummer.

Lücken:
- Mein Text kennt nur „einen Auftrag“ mit Rückmeldung (Profil Prüfer: „Du prüfst einen Auftrag“). Gegenlesen einer Testbitte vor dem Versand an den Chef kommt nicht vor: weder Ablauf noch Empfänger noch unter welcher Nummer ich melde, wenn ein Punkt mehrere oder keinen Vorgang hat.
- Die Testbitte nennt keine Vorgangsnummern je Punkt; mein Text sagt nicht, wie ich sie finde. `vorgang.py` sucht nicht nach Build-Punkten.
- „Beleg fehlt“ für einen Handypunkt ohne tragenden Satz und „nein“ für einen falschen Weg treffen hier in einer Testbitte mit zwei Punkten zu zwei Vorgängen zusammen; der Text regelt nur je Auftrag.
- Den Lagenabschnitt der Prüfliste (`ansehen/t299-….md`) gibt es in der Kopie nicht; ob „Lage Schlagbaum“ dort als Zeile steht, kann ich nicht sehen.

## P4

(a) Prüfung:
1. Erst sehen: Film, Umhang flattert; Laufkopf „Stand `5b0e2c1`“.
2. Neues drin: gemeldeter Stand `7ffa71528` = letzter Stand unter Bisher („zuletzt `7ffa71528` (Tuch)“; `git log -1 7ffa71528` → `15.11. 21:19 431 Tuch letzter Lauf …`) → Belegmangel, weiter. Der Film zeigt aber `5b0e2c1`, einen anderen (älteren) Stand → „Beleg fehlt“ und Ende.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 431 "Beleg fehlt: Film zeigt im Laufkopf Stand 5b0e2c1, nicht den gemeldeten 7ffa71528; der gemeldete Stand ist derselbe wie unter Bisher, also kein neuer Commit. Film am neuen, gepushten Commit zeigen, beschriftet mit Figur und Commit, mit den Angaben aus Feld 7 (roter und behobener Commit, Zahl der Körper, Bilder/s vorher und nachher, Quelle mit Datum)."
python3 tools/vorgang.py rueckmeldung 431 "Hinweis: Auftrag 431, Freigabe genau ein Filmlauf: der Lauf ist mit einem alten Stand (5b0e2c1) verbraucht; ein weiterer Lauf braucht eine neue Freigabe."
```
Erwartet: erste Zeile an den Macher (Rückläufer „Beleg fehlt“), zweite an den Disponenten („wie einen Eingang behandeln“).

Lücken:
- „Beleg fehlt und Ende“ gegen „alle Mängel auf einmal“: mein Text sagt nicht, ob ich nach „Ende“ die fehlenden Angaben aus Feld 7 noch nennen darf. Ich habe sie als Erwartung in denselben Satz genommen, ohne Ziel und Prüffragen zu prüfen.
- Ob der verbrauchte einzige Filmlauf mich angeht, sagt mein Text nicht; ich habe ihn als „Hinweis“ gemeldet (Kern: „Anderes Gesehenes als eigene Rückmeldung“).

## P5

(a) Prüfung:
1. Erst sehen: Füße gleiten nicht mehr; keine Tusche (keine Signaturlinien), freie Kamera von oben, nicht Spielkamera.
2. Neues drin: `a77c3e0` ≠ Bisher `b11447e6c` (`git log -1 b11447e6c` → `18.11. 08:24 1619: Gehen mit Waffe …`; `a77c3e0` in der Kopie unbekannt). Ob das Neue im Film ist: Beschriftung nicht genannt → Belegmangel.
3. Beleg: nicht die Spielansicht (freie Kamera von oben, ohne Tusche); der Vermerk „nur Gang zählt“ ändert das nicht (Profil: „auch bei Vermerken wie ‚nur X zählt‘“). Prüfart verlangt Wiese, Spielkamera mit Tusche, von der Seite, je Gangart drei Schritte, alt gegen neu, beschriftet mit Gangart und Commit. Feld 7 fehlt: roter und behobener Commit, Zweig, Zahl der Gangarten, Testausgabe `gang_1632`, Quelle mit Datum. „Schnell“ aus nicht genannt.
4. Ziel und Prüffragen:
   - Neues nachweislich? Nein, keine Beschriftung genannt.
   - Steht jeder Fuß fest? Von oben ohne Spielkamera nicht zu schließen (Belegmangel).
   - „Schnell“ aus und im Beleg genannt? Nein.
   - `gang_1632` alt rot, neu grün, alle Gangarten? Nein, keine Ausgabe.
   - Film mit Tusche in Spielkamera? Nein.
5. Am Geänderten: ohne Tusche ist nach Profil ein Mangel nach 4 (Signatur: „Tuschelinie mitgezeichnet“) → „nein“.
6. Steckt fest? Unter Bisher steht die Sperre des Wächters 457 (ohne Tusche), kein „nein“ eines Prüfers oder des Chefs → nein ohne „steckt fest“.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1619 "nein. (1) Film Wiese: ohne Tusche, keine Signaturlinien; mit Spiel-Shader und Tusche filmen. (2) Prüffrage 5: freie Kamera von oben, nicht Spielkamera von der Seite; ob ein Fuß gleitet, lässt sich so nicht schließen. (3) Testhilfe Schnell: Zustand nicht genannt. (4) gang_1632: Ausgabe alt rot, neu grün, für alle Gangarten fehlt. (5) Beleg: je Gangart drei Schritte, alt gegen neu, beschriftet mit Gangart und Commit; Rückmeldung ohne roten und behobenen Commit, Zweig, Zahl der Gangarten und Quelle mit Datum."
python3 tools/vorgang.py rueckmeldung 1619 "Hinweis: Auftrag 1619, Freigabe genau ein Filmlauf: der Lauf ist ohne Tusche verbraucht, derselbe Fehler wie der vom Wächter 457 gesperrte Wiesenfilm 08:27; ein weiterer Lauf braucht eine neue Freigabe."
```
Erwartet: erste an den Macher (erstes „nein“ dieses Vorgangs, sofern kein Chef-Nein in der Datei; sonst Laufbremse an Sokrates), zweite an den Disponenten.

Lücken:
- „fehlt darin die Tusche, ist das ein Mangel nach 4“: mein Text sagt nicht, ob das ein Mangel des Spiels oder nur des Films ist; ich habe nach Wortlaut „nein“ gemeldet, auch wenn die Füße stimmen könnten.
- Eine Sperre des Wächters zählt nach meinem Text nicht als „nein“ für „steckt fest“, obwohl derselbe Fehler (ohne Tusche) zum zweiten Mal auftritt. Der Text sagt nicht, ob das gewollt ist.

## P6

(a) Prüfung:
1. Erst sehen: beschriftet, Spielkamera; die Hand greift weiter durch den Stab.
2. Neues drin: `c0ffee1` (in der Kopie unbekannt; im Test angenommen); ob „Bisher“ einen Commit nennt, gibt der Fall nicht an → kein Gleichheitsmangel feststellbar. Neues im Bild: Feld neu beschriftet, aber keine Änderung an der Hand zu sehen → nicht nachweisbar.
3. Beleg: Prüfart Bild alt gegen neu, beschriftet, Spielkamera → passt. Testausgabe fehlt (der Fall nennt keine).
4. Ziel: „Hand umschließt den Stab, keine Durchdringung“ → nein, die Hand greift weiter durch. Chefwort 20.11., 18:02 „Nein, die Hand greift immer noch durch den Stab.“ erneut geprüft: trifft weiter zu. Prüffragen nennt der Fall nicht; geprüft am Ziel.
5. Am Geänderten: Durchdringung bricht das Eintauchen (Mangel, schon oben).
6. Steckt fest: Chef-Nein unter Bisher und in der Vorgangsdatei → „nein“ mit „steckt fest“. Das Werkzeug zählt das Chefwort auch (beginnt mit „Nein“, `chefwort.chef_nein`).

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1657 "nein, steckt fest. (1) Bild neu c0ffee1, Hand am Stab: die Finger greifen weiter durch den Stab, wie im Feld alt; Stab in die geschlossene Faust, ohne Durchdringung. (2) Kein Unterschied an der Hand zwischen alt und neu; nachweisen, dass das Bild den neuen Stand zeigt. (3) Testausgabe fehlt. Steckt fest, weil Chef 20.11., 18:02: „Nein, die Hand greift immer noch durch den Stab.“ weiter zutrifft: es fehlte die Handwerksregel, die Durchdringung erst als roten Test am gezeichneten Netz der Hand zu zeigen und das Bild vor dem Senden selbst anzusehen."
```
Erwartet: Zeile an Sokrates und Rückläufer an den Macher, Liste „steckt fest, wartet auf Sokrates“, WECKER → `send_message`.

Lücken:
- Der Fall gibt nur Ziel, Bisher, Prüfart; Feld 6 ohne Prüffragen. Mein Text sagt nicht, was ich bei einem Auftrag ohne Prüffragen tue (prüfe ich nur das Ziel, oder ist es „nein, Auftrag“?). Ich habe am Ziel geprüft, weil der Mangel sichtbar ist.
- Was Feld 7 verlangt, kenne ich hier nicht; fehlende Angaben kann ich darum nicht vollständig nennen.

## P7

(a) Prüfung (Auftrag aus `falltest-lauf2/auftraege/A16.auftrag.md`):
1. Erst sehen: Angriff 1 und 2 von der Seite, Zähne enden eine Handbreit vor dem Körper; Angriff 3 von hinten, Biss nicht zu sehen.
2. Neues drin: gemeldeter Commit `be2c0d8` = Bisher `be2c0d8f0` (`git log -1 be2c0d8f0` → `18.11. 20:49 760: … (SPRUNG_TIEF)`, aus Build 300 zurückgenommen mit `dbdff8bc2`) → Belegmangel, weiter. Commit im Film eingeblendet: nicht genannt → Neues nicht nachweisbar → nein.
3. Beleg: Prüfart „Kamera seitlich je Angriff“; Angriff 3 von hinten, Biss nicht zu sehen → für diesen Teil kein Schluss. „alt gegen neu“ nicht genannt. Feld 7 fehlt: Zahl der Fälle, Filmpfad, Zweig; `sollbild_784` mit STRENG=1 ohne Ausgabe.
4. Ziel und Prüffragen:
   - Neues im Film (Commit eingeblendet)? Nein, nicht genannt; Commit ist der alte.
   - Berührt jeder Biss sichtbar Körper oder Schild? Nein, Angriff 1 und 2 enden eine Handbreit davor, Angriff 3 nicht zu sehen.
   - Blut nur bei Treffer am Körper? Aus dem Beleg nicht zu sagen (nicht genannt).
   - Jeder Angriff einzeln, keiner verdeckt? Nein, Angriff 3 verdeckt.
   - `sollbild_784` grün? Nein, keine Ausgabe.
   - Nein unter Bisher erneut geprüft: „Film t300.11 Fail“ (Chef 18.11., 22:12) trifft weiter zu, der Biss erreicht den Helden nicht.
5. Am Geänderten: Biss ins Leere mit Treffer bricht das Eintauchen (schon oben).
6. Steckt fest: Chef „Fail“ zu t300.11 unter Bisher → „nein“ mit „steckt fest“.
7. Außerdem: der Auftrag ist ein Entwurf („eintragen erst nach 1589.4“) und sagt „Ruht bis 1589.4 (1714): vorher kein Lauf“. Ob 1589.4 erledigt ist, prüfe ich mit `python3 tools/vorgang.py 1589` (der Fall sagt es nicht). Sonst ist ein Lauf vor der Freigabe ein Sachverhalt → „Hinweis“.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 760 "nein, steckt fest. (1) Film Angriff 1 und 2: die Zähne enden eine Handbreit vor dem Körper, der Biss trifft nicht sichtbar; Biss an Körper oder Schild bringen. (2) Angriff 3 von hinten gefilmt, Biss nicht zu sehen; seitlich filmen, keiner verdeckt. (3) Gemeldeter Commit be2c0d8 ist derselbe wie unter Bisher (be2c0d8f0, aus Build 300 zurückgenommen), im Film kein Commit eingeblendet; neuen Commit auf gepushtem Zweig zeigen. (4) Blut: im Beleg nicht zu beurteilen, je Angriff zeigen. (5) sollbild_784 mit STRENG=1: Ausgabe fehlt. (6) Beleg: alt gegen neu fehlt; Rückmeldung ohne Zahl der Fälle, Kontaktliste und Filmpfad. Steckt fest, weil Chef 18.11., 22:12 „Fail“ zu t300.11 weiter zutrifft: es fehlte die Handwerksregel, den Widerspruch Messung gegen Bild erst nachzustellen und am gezeichneten Netz in der Endpose zu messen (1711), bevor ein Film läuft."
python3 tools/vorgang.py rueckmeldung 760 "Hinweis: Auftrag 760 ruht bis 1589.4 (1714, vorher kein Lauf) und ist als Entwurf markiert; der Filmlauf be2c0d8 lief, ohne dass eine Freigabe nach 1589.4 im Auftrag steht."
```
Erwartet: erste an Sokrates und Rückläufer an den Macher (Jerry); zweite an den Disponenten. Die zweite nur, wenn `vorgang.py 1589` zeigt, dass 1589.4 offen ist.

Lücken:
- Mein Text sagt nicht, was ich mit einem Auftrag tue, der laut eigenem Kopf noch Entwurf ist und ruht. Ich prüfe die Arbeit trotzdem und melde den Lauf als Hinweis.
- Ziel „berühren die Zähne sichtbar den Helden; … nie am Schild“ gegen Prüffrage 2 „Körper oder Schild“: ob ein Biss ins Schild das Ziel erfüllt, sagt der Auftrag nicht eindeutig. Mein Text gibt „Hinweis: Prüffrage fehlt“ nur für einen Mangel ohne Prüffrage, nicht für eine Prüffrage, die weiter ist als das Ziel. Hier egal, weil nichts berührt wird.
- Das Profil Kampf, das der Auftrag nennt, lädt mein Text nicht; Maße für „sichtbar trifft“ kenne ich nicht.

## P8

(a) Prüfung (Prüfart „Prüfung mit Ausgabe“; selbst nachgesehen in `kopie/`):
1. Neues drin: `git log -1 3e1df00` → `3e1df00eb 19.11. 07:15 Vollzug 1724: Build 300 auf main ohne 760, Geprüft an: 3db05d4e5 …`; `git show --stat 3e1df00` → nur `docs/LISTE-VORGAENGE.md`. Der gemeldete „Geprüft an“ ist der Notiz-Commit der Vollzugszeile, nicht der geprüfte Stand, und liegt zeitlich vor dem Revert (`dbdff8bc2`, 07:31) und dem Merge (`3db05d4e5`, 08:14). Er zeigt also einen anderen Stand → „Beleg fehlt“. Ende nach Profil; die Sachprüfung habe ich trotzdem selbst gemacht, damit der Satz sagt, was fehlt:
2. Sachverhalt am Repo:
   - Merge auf `main`: `git show --stat 3db05d4e5` → Eltern `06737b6b1` und `dbdff8bc2`, „Build 300 auf main ohne 760 (1724 …)“; `git merge-base --is-ancestor 3db05d4e5 main` → ja. Dass es der Merge von PR 221 ist, steht nicht im Titel; ohne `gh` nicht belegbar.
   - Revert: `git show --stat dbdff8bc2` → „Revert von a607a1d3d, 18be49d71, 13f6a3f70, be2c0d8f0“, nimmt `sprung.gd`, `sprung_760.gd`, Einträge in `godot.yml` und `sollbild_784.gd` heraus; nur die vier Commits, nicht der Merge (Systemfrage erfüllt).
   - 760-Dateien: `git ls-tree -r --name-only 3db05d4e5 | grep -E "sprung(_760)?\.gd$"` → nichts; `git show 3db05d4e5:.github/workflows/godot.yml | grep -c sprung_760` → 0.
   - Prüffrage 2 wörtlich: `git diff 06737b6b1 3db05d4e5 --stat` enthält `godot/kampf/kampfort.gd` und `.github/workflows/godot.yml`, beide auch in den 760-Commits (`git show --stat 13f6a3f70`, `a607a1d3d`); `git diff … -- kampfort.gd godot.yml | grep -i "sprung\|760"` → nichts. Dateien also da, aber ohne 760-Inhalt (andere Build-300-Commits).
   - Jeder andere Commit auf `main`: `git log --oneline main..origin/claude/build-300 | wc -l` → 0; 41 Commits im Merge, davon 18 ohne Merge und ohne die 760-Commits und den Revert.
   - Lauf grün: in der Kopie nicht prüfbar (laut Fall angenommen grün), Link fehlt in der Rückmeldung.
3. Feld 7 fehlt: Revert-Commit, Merge-Commit auf `main`, Link des grünen Laufs, Zahl der geprüften Commits, Liste der 760-Commits (Umsetzen 1). Testausgabe (Prüfart „mit Ausgabe“) fehlt.
4. Zusatz: `python3 tools/vorgang.py 1724` → Archiv: „erledigt, Geprüft an: 3db05d4e5“. Der Vorgang ist schon erledigt; die Rückmeldung nennt einen anderen Commit als das Archiv.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1724 "Beleg fehlt: Geprüft an 3e1df00 ist der Notiz-Commit der Vollzugszeile (nur docs/LISTE-VORGAENGE.md, 19.11., 07:15, vor Revert dbdff8bc2 07:31 und Merge 3db05d4e5 08:14), nicht der geprüfte Stand; das Archiv nennt 3db05d4e5. Nachreichen nach Feld 7: Merge-Commit auf main (PR 221), Revert-Commit, Link des grünen Laufs, Liste der vier 760-Commits und Zahl der geprüften Commits, dazu die Ausgabe der Prüfung. Am Repo selbst gesehen: Merge 3db05d4e5 auf main, Revert nur der vier 760-Commits, keine sprung*.gd und kein sprung_760 in godot.yml, main..origin/claude/build-300 leer."
python3 tools/vorgang.py rueckmeldung 1724 "Hinweis: Prüffrage fehlt: Prüffrage 2 fragt nach keiner Datei aus den vier 760-Commits; kampfort.gd und godot.yml sind auch von anderen Build-300-Commits geändert und erscheinen im Diff ohne 760-Inhalt; richtig wäre: kein Inhalt aus den 760-Commits im Diff."
```
Erwartet: erste an den Macher (wer „fertig“ meldete; sonst Disponent), zweite an den Arbeitsplaner („Hinweis Prüffrage fehlt“, 1873).

Lücken:
- Mein Text kennt keine Prüfung eines „Vollzug“ (Folgeauftrag eines Entscheids, schon erledigt im Archiv). Ob ich eine Vollzugsmeldung zu einem erledigten Vorgang überhaupt abnehme, sagt er nicht.
- „Beleg fehlt und Ende“: ich habe die Sachprüfung trotzdem gemacht, weil Prüfart „mit Ausgabe“ das Repo selbst zum Beleg macht. Der Text sagt nicht, was bei „Prüfung mit Ausgabe“ als Beleg gilt, die Ausgabe der Fachkraft oder das, was ich selbst ausführe.
- Lauf grün und PR 221: ohne `gh` und Netz nicht prüfbar; mein Text sagt nicht, wie ich einen Lauf belege.
- Prüffrage wörtlich falsch, Sachverhalt aber richtig: der Text kennt „nein, Auftrag“ nur ohne Mangel. Hier gibt es einen Belegmangel, darum „Hinweis: Prüffrage fehlt“ statt „nein, Auftrag“. Ob das so gemeint ist, sagt er nicht.

## P9

(a) Prüfung (zweite Rückmeldung zu A7; unter Rückmeldungen mein „nein, steckt fest“ aus P1):
1. Erst sehen: beschriftet, Spielkamera in Handygröße, Stelle markiert; neu: Flanke am Körper, keine Beule; Garrick und Bram je ein Feld; Messung im Anhang 67 → 31.
2. Neues drin: `bfd783a` ≠ Bisher `547033f9f` und ≠ P1 `3c1f0aa`. `git show --stat bfd783a` → `bfd783a3c 21.11. 20:26 uid des Bildskripts 1535`, nur `godot/tests/spielbild_1535.gd.uid`. Die Gewichte stecken in `4fd7055c8 18.11. 23:59 1535: Gewichte eng anliegender Kleidung … Dehnregel auch am Oberarm` (`git log 547033f9f..bfd783a | grep 1535`), das ist Vorfahr von `bfd783a` auf `origin/claude/tom-1535-gruss`. Als Stand trägt `bfd783a` das Neue; im Bild sichtbar anders als alt → ja.
3. Beleg: Prüfart erfüllt (Spielkamera, Handygröße, markiert, beschriftet, Garrick und Bewohner im Kittel; Bram ist laut `1896bc91c` „Bram im Kittel“). Zu prüfen, ob das Feld alt jetzt Stand 299 trägt (P1-Mangel 5): der Fall sagt nur „beschriftet“. Feld 7 fehlt: roter Commit und behobener Commit (genannt ist nur ein uid-Commit), Zweig gepusht, Zahl der Fälle, Quelle mit Datum; Testausgabe fehlt.
4. Ziel und Prüffragen, dazu jedes Nein aus P1 erneut:
   - Neues nachweislich (neues Modell im Bild)? Ja, das Feld neu unterscheidet sich sichtbar.
   - Unterschied alt gegen neu ohne Erklärung zu sehen? Ja, Beule alt, keine Beule neu.
   - Flanke neu innerhalb der Körperbreite, ohne Faden? Ja, Flanke liegt am Körper.
   - Prüfung über alle Figuren null Fehlfälle? Nicht zu beantworten, keine Zahl der Fälle und keine Ausgabe → Belegmangel.
   - P1 (3) Ursache als roter Test am Netz mit Commit: nicht belegt (kein roter Commit genannt).
   - P1 (5) Feld alt mit 299: nur „beschriftet“; muss 299 zeigen, nicht `7ffa715`.
5. Am Geänderten: Signatur und Leben: Bild in Spielkamera; nichts Fremdes gemeldet. Bram: ist er im Katalog? Der Auftrag nennt keine Katalogquelle → kein Hinweis nötig, er ist der Bewohner im Kittel aus dem Auftrag.
6. Kein „nein“ → kein „steckt fest“. Nach meinem P1 steht 1535 auf „wartet auf Sokrates“; ob Sokrates gelöst hat, sehe ich mit `python3 tools/vorgang.py 1535` (Feld „wartet auf“), die Prüfung ändert das nicht.

(b) Rückmeldung:
```
python3 tools/vorgang.py rueckmeldung 1535 "Beleg fehlt: Bild Garrick und Bram stimmt (Flanke neu am Körper, Unterschied zu alt sichtbar), aber Prüffrage 4 ist nicht belegt: Prüfung über alle Figuren mit Kaufkleid in allen Ruhebewegungen mit gehobenem Arm mit Zahl der Fälle und null Fehlfällen als Ausgabe beilegen. Gemeldeter Commit bfd783a enthält nur spielbild_1535.gd.uid; roten Commit (Ursache am Netz) und behobenen Commit (laut git 4fd7055c8) nennen, Zweig gepusht, Quelle mit Datum aus der Systemfrage. Feld alt: zeigen, dass es Stand 299 trägt (P1 nannte 7ffa715, Commit zu 431)."
```
Erwartet: Rückläufer „Beleg fehlt“ an Tom (letzter „fertig“), WECKER → `send_message`. Erstes „Beleg fehlt“ zu diesem Auftrag, zählt nicht als Runde.

Lücken:
- Mein Text sagt nicht, ob ich eine neue „fertig“-Meldung prüfe, solange der Vorgang nach meinem „steckt fest“ auf Sokrates wartet. Ich prüfe, weil die Rückmeldung mit Commit an mich geht (`rueckmeldung.py`: „fertig“ mit Commit → Prüfer).
- Bild zeigt das Ziel erreicht, nur Prüffrage 4 und Feld 7 fehlen: „Beleg fehlt“ statt „ja“ folgt aus „fehlt … eine Angabe aus Feld 7 oder die Testausgabe“. Der Text sagt nicht, ob ich ein sichtbar erreichtes Ziel trotzdem als „ja“ weitergeben darf, um den Chef früher zu erreichen.
- Gemeldeter Commit ist nur eine `.uid`-Datei, der Bau liegt in einem Vorfahren: mein Text sagt nicht, ob der gemeldete Commit der Bau-Commit sein muss oder die Spitze des Zweigs reicht.
