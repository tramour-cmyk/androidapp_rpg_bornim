# Antworten Prüfer (Abnahme), Fälle P1–P9

Geladen: `sockel.md`, `kern-abnahme.md`, `profil-pruefer.md`; `querprofil-signatur-und-leben.md` nur bei P1, P2, P4, P5, P9 (Auftrag nennt es); `profil-fremde-inhalte-A.md` nirgends (kein Auftrag hier nennt es). Fachprofile, die die Aufträge auch nennen (`profil-figur-und-pruefbild.md`, `profil-kampf.md`, `profil-regeln.md`, `profil-technik-A.md`), habe ich nicht geladen: Mein Text erlaubt nur die beiden Querprofile.

Für alle Fälle gilt:
- Melden immer mit `cd /home/user/bornim-main && python3 tools/vorgang.py rueckmeldung <Nr> "<Meldung>"` (Kern: „Du meldest mit `tools/vorgang.py rueckmeldung`“). Das Werkzeug schreibt selbst, committet und pusht nach `main` (`uebergabe.atomar`, `git push origin …:refs/heads/main`). Ich committe also nichts von Hand.
- Danach schicke ich die ausgegebene Zeile `WECKER <Sitzung> | sieh in <Nr> (<Kennung>)` als `send_message` an diese Sitzung (im Test nur aufgeschrieben).
- Vorher schaue ich jedes Mal den Beleg an, erst danach den Text des Machers („Erst sehen, dann lesen“).
- Im Repo gibt es `docs/vorgang/` nur als `1789.md`. Zu den Vorgängen dieser Fälle gibt es also keine Vorgangsdatei, und das Werkzeug kennt keinen Macher. Für ein „nein“ oder „Beleg fehlt“ nennt es dann nach `rueckmeldung.weitergabe` den **Disponenten** als Empfänger statt der Fachkraft. Im Ernstbetrieb stünde dort das „fertig“ der Fachkraft.

---

## P1: 1535, erste Rückmeldung (Flanke Garrick, `3c1f0aa`)

**1. Was ich tue**
1. Beleg ansehen: Er zeigt zwei Felder, beschriftet „alt `7ffa715`“ und „neu `3c1f0aa`“, in der Spielkamera. In **beiden** Feldern sitzt dieselbe Beule über Körperbreite unter dem gehobenen Arm.
2. Schritt 1, „Neues drin“: **Nein.**
   - Das neue Feld unterscheidet sich nicht vom alten. Die Messung 67 → 57 widerspricht dem Bild, und dann gilt das Bild (Kern).
   - `git log -1 3c1f0aa` ergibt „unknown revision“. Der Commit liegt also auf keinem gepushten Zweig.
   - „alt `7ffa715`“ ist laut Git „431 Tuch letzter Lauf“ (15.11.). Das ist nicht der Stand vor den Rumpfgewichten (`547033f9f`). Genau diesen Fehler nennt „Bisher“ schon.
   - Damit gilt „nein“, und ich prüfe nichts weiter.
3. Vorheriges Nein prüfen: In der Vorgangsliste steht zu 1535 „zurück t299 (Garrick-Faden)“, im Auftrag „Fund des Chefs Test 299: ‚299.3 ✗‘“. Den ✗ des Chefs zu einem gelieferten Stand werte ich als „nein“ des Chefs zu dieser Arbeit. Darum schreibe ich „steckt fest“ dazu.
4. Befehl:
```
python3 tools/vorgang.py rueckmeldung 1535 "nein, steckt fest: Neues nicht drin. ansehen/1535-garrick-alt-neu.webp zeigt in alt und neu dieselbe Beule über Körperbreite unter Garricks gehobenem Arm; die Messung 67 → 57 widerspricht dem Bild, das Bild gilt. Commit 3c1f0aa liegt auf keinem gepushten Zweig (git: unknown revision): pushen. Feld alt ist mit 7ffa715 beschriftet, das ist '431 Tuch' vom 15.11., nicht der Stand vor 547033f9f: alt richtig beschriften. Vor dem Bild nachweisen, dass das Modell aus dem Commit geladen ist. Fehlende Handwerksregel: vor jedem Bild belegen, dass das neue Modell geladen ist, und Messung gegen das Bild in der Endpose abgleichen, bevor gemeldet wird."
```
   Das erste Wort ist **„nein“**. Das Werkzeug erkennt „nein … steckt fest“, die Übergabezeile geht an **Sokrates** („steckt fest: Rückmeldung … lesen (1763 C)“). Danach schicke ich die WECKER-Zeile.

**2. Was ich nicht tue**
- Ziel, Prüffragen und Querprofil prüfe ich nicht: „Nein: ‚nein‘, nichts weiter prüfen.“
- Ich bessere nichts nach: „Du änderst nichts.“
- Ich lege keinen Vorgang an: „Vorgänge legt das Büro an, nicht du.“

**3. Quellen**
- Auftrag `A7.auftrag.md`
- `git log -1 3c1f0aa` (unbekannt), `git log -1 7ffa715` („431 Tuch …“, `origin/claude/tom-431-umhang`), `git log -1 547033f9f`
- Zeile 1535 in `docs/LISTE-VORGAENGE.md`

**4. Nächster Schritt:** sobald die Fachkraft erneut „fertig“ mit Commit meldet und das Werkzeug mir das zuweist (siehe P9). Ob vorher Sokrates eingreift, entscheidet er.

**5. Lücke und Widerspruch**
- Schritt 1 sagt „nichts weiter prüfen“, die Meldung soll aber „alle Mängel auf einmal“ nennen. Mängel aus Schritt 3 (Nachstellauftrag, also kein Bau; Ursache in einem Satz; Zahl der Fälle) melde ich darum nicht. Die nächste Runde wird sie bringen.
- Ob ein „✗“ des Chefs als „nein“ zählt, sagt der Text nicht. Ich habe es so gewertet.
- **Text gegen Werkzeug:** Mein Profil verlangt „steckt fest“, wenn vorher ein „nein“ des **Chefs** unter „Bisher“ oder in der Vorgangsdatei steht. Das Werkzeug zählt nur die „Rückmeldungen“ der Vorgangsdatei (`zaehlen()` liest nur `abschnitt(text, "Rückmeldungen")`) und kennt den ✗ des Chefs nicht. Zu Sokrates kommt die Meldung nur, weil „steckt fest“ wörtlich darin steht.
- Bei „nein … steckt fest“ geht die einzige Übergabezeile an Sokrates, **nicht** an den Macher (der Zweig `w & {"steckt fest", …}` greift vor `weitergabe`). Ob der Macher trotzdem nachbessern soll, sagt der Text nicht.

---

## P2: 1621, Waffen kürzer (`9e2d1b4`)

**1. Was ich tue**
1. Beleg ansehen: beschriftet, Spielkamera, die Waffen sind kürzer. Bei allen vier Figuren berührt keine Hand den Griff, die Waffen schweben etwa eine Fingerbreite vor der Hand.
2. Schritt 1: Ja. Das Bild ist beschriftet, das Neue (kürzer) ist sichtbar. Aber `git log -1 9e2d1b4` ergibt „unknown revision“.
3. Schritt 2: kein „Beleg fehlt“. Bild ist die richtige Art, Spielkamera, beschriftet.
4. Schritt 3, Prüffragen:
   - „Neue Länge gemessen?“ **Nein.** Gemeldet ist „um 20 % kürzer“. Entschieden sind feste Maße (Großaxt 110, Kriegshammer 100, Zweihänder 115 cm; „Längen sind entschieden: nicht neu wählen“). Länge je Waffe im Bild ist nicht genannt.
   - „Wirkt jede Waffe kürzer, gleiche Kamera und Pose?“ Ja, kürzer. Der Auftrag verlangt aber „Held mit jeder der drei Waffen“, das Bild zeigt vier Figuren.
   - „Beide Fäuste schließen um den Griff?“ **Nein.** Bei allen vier Figuren schwebt die Waffe eine Fingerbreite vor der Hand.
   - „`waffen_522` grün, Zahl genannt?“ **Nein**, keine Ausgabe, keine Zahl.
   - Ohne Prüffrage: Laut Auftrag gilt „Erst nach 1694 (Griff) bauen; vorher kein Lauf“. 1694 steht in der Vorgangsliste auf „ruht, bis Sa 21.11.“. Der Lauf ging also gegen den Auftrag.
5. Vorheriges Nein: Unter „Bisher“ steht Chef 16:50 „Da wird der Griff des Schwertes nicht umfasst“, in der Liste „Rückläufer 👎 16:50“. Das ist ein Nein des Chefs, also „steckt fest“.
6. Schritt 4, Querprofil: Waffe farbig, Tusche, kein fremder Stil. Aus dem Fall nichts weiter zu sehen. Das Schweben bricht das Eintauchen, das ist schon als Mangel erfasst.
7. Befehl:
```
python3 tools/vorgang.py rueckmeldung 1621 "nein, steckt fest: (1) Bild alt gegen neu: bei allen vier Figuren schwebt die Waffe eine Fingerbreite vor der Hand, keine Faust schließt um den Griff (1621 16:50): Griff erst auf Stand mit 1694. (2) Gemeldet ist 'um 20 % kürzer'; entschieden sind Großaxt 110, Kriegshammer 100, Zweihänder 115 cm: diese Längen bauen, im Bild am Netz messen und je Waffe mit Länge beschriften; Held mit jeder der drei Waffen. (3) Ausgabe von waffen_522 und Zahl der Waffen fehlen: nachreichen. (4) Ohne Prüffrage: Lauf vor 1694 (ruht bis Sa 21.11.) gegen 'Erst nach 1694 bauen; vorher kein Lauf'. (5) Commit 9e2d1b4 auf keinem gepushten Zweig: pushen. Fehlende Handwerksregel: vor dem Lauf prüfen, worauf der Auftrag wartet, und den Handausschnitt am gezeichneten Netz der Endpose prüfen, bevor gemeldet wird."
```
   Erstes Wort **„nein“**, die Übergabezeile geht an **Sokrates**, danach die WECKER-Zeile.

**2. Was ich nicht tue**
- Ob die Waffen „gut aussehen“, beurteile ich nicht: „Geschmack … urteilt der Chef.“
- Die Griffhöhe in `halt.json` gehört zu 1694, nicht hierher. Ich schlage keine Lösung vor: „Du änderst nichts.“

**3. Quellen:** `A13.auftrag.md`; Zeilen 1621 und 1694 in `docs/LISTE-VORGAENGE.md`; `git log -1 9e2d1b4`.

**4. Nächster Schritt:** nach neuem „fertig“ mit Commit. Laut Auftrag ist das frühestens nach 1694.

**5. Lücke und Widerspruch**
- Ob der Griff ein Mangel ist, den diese Arbeit beheben kann (sonst „nein, Auftrag“), sagt der Text nicht eindeutig. Der Griff hängt an 1694. Ich melde „nein“, weil Länge, Messung und der Lauf vor 1694 Mängel dieser Arbeit sind.
- Ob ein Chefwort ohne das Wort „nein“ (16:50, 👎) als „nein“ zählt, sagt der Text nicht.
- Werkzeug: siehe P1 (Chefworte zählen nicht, nur das wörtliche „steckt fest“ steuert).

---

## P3: Testbitte Build 299, Handypunkte 299.3 und 299.4 (Gegenlesen)

**1. Was ich tue** (Profil, Abschnitt **Handy**: Die Schritte 1, 2 und 4 entfallen. Ich prüfe den Satz „warum nicht Bild“, ob die Testausgabe grün ist und den Weg im Code, je Punkt mit Codestelle.)

**299.3 „Lage Schlagbaum: bei Jorin … zusehen, während sie stehen“**
- Satz „warum nicht Bild“: steht nicht in der Testbitte. Der Punkt gehört zu 1535 (Liste: „zurück t299 (Garrick-Faden)“), also zu einer Beule an stehenden Figuren. Das ist ein fester Anblick, und laut Auftrag A7 reicht dafür ein Bild am Rechner. Der Satz trägt also nicht → „Beleg fehlt“.
- Testausgabe: nicht beigelegt.
- Weg im Code:
  - Eine Station „Schlagbaum“ gibt es nicht (`godot/skripte/testmodus.gd` Z. 182–184, `STATIONEN`: Garrick … Tempel). Eine Lage heißt nur dann so, wenn die Prüfliste sie im Abschnitt „## Lagen“ festlegt (`tools/pruefliste.py` Z. 13). Die Prüfliste liegt mir nicht vor.
  - Jorin steht in `godot/daten/karten.json` Z. 606–613: Dorf, 15/3, `runde` [[15,3],[17,3],[20,3],[18,3]]. Er geht also Streife.
  - `godot/skripte/leute.gd` Z. 6 und Z. 887–897: An jedem Punkt bleibt er 2,5–5 s oder 10–16 s stehen. „Steht der Held daneben, bleibt sie stehen.“
  - Für „zusehen, während sie stehen“ muss die Lage also `ort=village:x:y` neben einen Streifenpunkt legen (`spiel.gd` Z. 1567–1570, `teleport`). Ob sie das tut, kann ich ohne die Lagenzeile nicht belegen. Wer mit „sie“ gemeint ist, ist offen, denn Jorin ist einer.
- Befehl:
```
python3 tools/vorgang.py rueckmeldung 1535 "Beleg fehlt: Testbitte 299.3 (Handy) ohne Satz 'warum nicht Bild'; die Beule an stehenden Figuren ist ein fester Anblick, Bild am Rechner reicht. Bleibt es Handy: Lagenzeile (## Lagen) mitgeben, die den Helden neben Jorins Streifenpunkt stellt (karten.json Z. 606–613 runde 15/3–20/3; leute.gd Z. 887–897: steht nur 2,5–16 s, bleibt stehen, wenn der Held daneben steht), sagen, wer 'sie' ist, und grüne Testausgabe (lage_1156) beilegen."
```

**299.4 „Lage `vorraete`, Umhang ablegen und anlegen“**
- Satz „warum nicht Bild“: fehlt. Anlegen und Ablegen ist Bedienung, Handy wäre also begründbar, aber der Satz muss dastehen.
- Weg im Code:
  - `vorraete` ist ein Lagenschlüssel (`testmodus.gd` Z. 714) und keine Lage. `spiel.gd` Z. 1545 ruft `Testmodus.vorraete` auf (`testmodus.gd` Z. 331–339). Die Funktion füllt nur die „dinge“ aus `texte.json` (Arten BANDAGE, BOMB, FOOD, INGREDIENT, KEY, POTION, TONIC, ohne Umhang), zwei Fackeln und ein Rauchbündel.
  - Kein Lagenschlüssel legt einen Umhang an oder in die Tasche: `ruestung` nimmt nur Brustrüstungen (`testmodus.gd` Z. 305–306, Z. 770). Der Umhang ist `cloak`, Platz CLOAK, Art ARMOR (`daten/held.json` Z. 558–563).
  - Der Weg stellt also nicht her, was der Punkt verlangt → „nein“.
- Befehl (Nummer siehe Lücke; ich nehme die Vorgangsnummer des Punkts, die in der Testbitte fehlt):
```
python3 tools/vorgang.py rueckmeldung <Nr zu 299.4> "nein: Testbitte 299.4, Lage 'vorraete' bringt keinen Umhang: testmodus.gd Z. 331–339 füllt nur Verbrauchsdinge, Fackeln, Rauchbündel; kein Lagenschlüssel legt CLOAK an (ruestung nur Brust, Z. 305–306, 770). Lage so ändern, dass der Held einen Umhang (held.json Z. 558 'cloak') trägt oder in der Tasche hat; Satz 'warum nicht Bild' und grüne Testausgabe dazu."
```
Danach jeweils die WECKER-Zeile. „Beleg fehlt“ und das erste „nein“ gehen an den Macher, ohne Vorgangsdatei an den Disponenten.

**2. Was ich nicht tue**
- Am Gerät bediene ich nichts. Bedienen oder Ablauf „prüft der Chef selbst im Build“.
- Ich korrigiere die Testbitte nicht selbst: „Du änderst nichts.“

**3. Quellen**
- `godot/skripte/testmodus.gd` Z. 182–184, 305–306, 331–339, 714, 770
- `godot/skripte/spiel.gd` Z. 1538–1574 (Z. 1545)
- `godot/skripte/leute.gd` Z. 6, 887–897
- `godot/daten/karten.json` Z. 606–613
- `godot/daten/held.json` Z. 558–563
- `godot/daten/texte.json` („dinge“: Arten gezählt)
- `tools/pruefliste.py` Z. 13
- Die Prüfliste t299 liegt nur unter `docs/chefsache/` und `docs/entwurf/`. Beides ist für mich gesperrt, ich habe sie nicht geöffnet.

**4. Nächster Schritt:** nach der berichtigten Testbitte. Vor dem Versand an den Chef geht sie wieder durch mich.

**5. Lücke**
- Der Text sagt nicht, unter welcher Nummer ich eine Testbitte melde (Build 299 ist kein Vorgang; 299.4 nennt keinen Vorgang).
- Er sagt nicht, welche Meldung gilt, wenn zwei Punkte verschieden ausgehen. Ich melde je Punkt.
- Er sagt nicht, was ich tue, wenn die Lagenzeile nicht beiliegt.
- Das Profil verlangt „Testausgabe grün“, die Testbitte bringt keine mit.

---

## P4: 431, Film Umhang (`7ffa71528`)

**1. Was ich tue**
1. Film ansehen: Der Umhang flattert. Im Laufkopf steht „Stand `5b0e2c1`“.
2. Schritt 1: **Nein.**
   - Der Beleg zeigt nicht den gemeldeten Stand `7ffa71528`, sondern `5b0e2c1` (älter; in Git nicht auffindbar).
   - Dazu ist `7ffa71528` laut Git selbst „431 Tuch letzter Lauf …“ vom 15.11., also der Stand vor dem Film-✗ unter „Bisher“, nichts Neues.
   - Auf dem Zweig `claude/tom-431-umhang` ist der Bau `656c6a243` (Bisher). Ein Commit auf gepushtem Zweig mit neuem Stand fehlt.
3. Vorheriges Nein: „Bisher: Film 15.11. ✗“, also „steckt fest“ (gewertet wie P1).
4. Befehl:
```
python3 tools/vorgang.py rueckmeldung 431 "nein, steckt fest: Neues nicht drin. Gemeldet ist Stand 7ffa71528, der Film zeigt im Laufkopf 'Stand 5b0e2c1' (älter); 7ffa71528 selbst ist '431 Tuch letzter Lauf' vom 15.11., der Stand vor dem Film-✗. Neuen Commit auf gepushtem Zweig nennen und den Film mit diesem Commit im Laufkopf neu aufnehmen. Fehlende Handwerksregel: vor dem Film nachweisen, dass der gemeldete Commit geladen ist (Laufkopf gleich Meldung)."
```
   Erstes Wort **„nein“**, an **Sokrates**, danach die WECKER-Zeile.

**2. Was ich nicht tue:** Das Flattern bewerte ich nicht: „Nein: ‚nein‘, nichts weiter prüfen.“ Wie der Schwung wirkt, ist ohnehin Spielgefühl, und das urteilt der Chef.

**3. Quellen:** `A14.auftrag.md`; `git log -1 7ffa71528`, `git log -1 5b0e2c1` (unbekannt).

**4. Nächster Schritt:** nach neuem „fertig“ mit Commit.

**5. Lücke**
- „Stand“ statt „Commit“ in der Rückmeldung: Das Werkzeug erkennt den Hash trotzdem (`COMMIT`-Muster) und gibt an mich weiter. Der Text sagt nicht, ob ein alter Commit als „gemeldeter Commit“ gilt.
- Die Wertung „✗ = nein“ wie in P1.
- Der Auftrag sagt „ruht … bis nach dem Meilenstein“, liegt mir aber als Auftrag vor. Ob ich einen Lauf trotz Ruhe prüfe, sagt der Text nicht. Ich prüfe, was kommt.

---

## P5: 1619, Gang über die Wiese (`a77c3e0`, Vermerk „nur Gang zählt“)

**1. Was ich tue**
1. Film ansehen: Die Füße gleiten nicht mehr. Ohne Tusche, freie Kamera von oben, nicht die Spielkamera. Eine Commit-Einblendung nennt der Fall nicht.
2. Schritt 1: Den Commit sehe ich im Film nicht. Das ist zugleich eine fehlende Beschriftung aus Schritt 2. Ich melde nach Schritt 2, weil die Spielansicht ausdrücklich dort steht: „zeigt ein Bild oder Film nicht die Spielansicht (Spielkamera mit Tusche), auch bei Vermerken wie ‚nur X zählt‘ … ‚Beleg fehlt‘“.
3. Befehl:
```
python3 tools/vorgang.py rueckmeldung 1619 "Beleg fehlt: Der Film muss in der Spielkamera mit Tusche den Helden auf der Wiese von der Seite zeigen, alt gegen neu, Commit a77c3e0 eingeblendet, Testmenü 'Schnell' aus, bis 15 s, der Moment dreimal, dazu die Ausgabe von gang_1632 über alle Figuren, Waffen und Gangarten mit Zahl; freie Kamera von oben ohne Tusche lässt keinen Schluss zu, auch mit Vermerk 'nur Gang zählt'."
```
   Erstes Wort **„Beleg fehlt“**, an den Macher (ohne Vorgangsdatei an den Disponenten), danach die WECKER-Zeile. Das zählt nicht als Runde.

**2. Was ich nicht tue:** Die Arbeit lehne ich nicht ab: „Die Arbeit lehnst du damit nicht ab.“ Das Gehtempo 2,13 m/s urteile ich nicht neu, das ist entschieden.

**3. Quellen:** `A15.auftrag.md`; Zeile 1619 in der Vorgangsliste (gebaut an `b11447e6c`, t301); `git log -1 a77c3e0` (unbekannt, nicht auf gepushtem Zweig, im Satz nicht gemeldet, siehe Lücke).

**4. Nächster Schritt:** nach neuem Film.

**5. Lücke**
- Step 1 und Step 2 überschneiden sich bei fehlender Commit-Einblendung („nein“ oder „Beleg fehlt“?). Der Text regelt den Vorrang nicht.
- „Beleg fehlt mit einem Satz“ gegen „alle Mängel auf einmal“: Ob ich die fehlende `gang_1632`-Zahl oder den unauffindbaren Commit gesondert melde, bleibt offen. Ich habe sie in den einen Satz genommen.

---

## P6: 1657, Griff am Stab (`c0ffee1`)

**1. Was ich tue**
1. Beleg ansehen: Die Hand greift weiter durch den Stab.
2. Auftrag: Es liegt keiner vor, und `docs/vorgang/1657.md` gibt es im Repo nicht. Ich prüfe gegen den Titel in der Liste und gegen das Chefwort.
3. Schritt 1: Ob der Commit beschriftet ist, sagt der Fall nicht (`c0ffee1` ist in Git unbekannt).
4. Schritt 3: Das Ziel (Hand um den Stab, nicht hindurch; Chefwort 20.11., 18:02) ist nicht erreicht → „nein“.
5. In der Vorgangsdatei steht unter „Chefworte“ schon ein „Nein“ des Chefs → „steckt fest“.
6. Befehl:
```
python3 tools/vorgang.py rueckmeldung 1657 "nein, steckt fest: Bild zu Commit c0ffee1: die Hand greift weiter durch den Stab, wie Chefwort 20.11., 18:02 ('Nein, die Hand greift immer noch durch den Stab'); Hand muss um den Stab schließen, am gezeichneten Netz in der Endpose. Commit c0ffee1 auf keinem gepushten Zweig: pushen. Fehlende Handwerksregel: den Fund des Chefs vor dem Senden selbst im Bild an derselben Stelle nachsehen, nicht nur messen."
python3 tools/vorgang.py rueckmeldung 1657 "Hinweis: 1657 wartet laut Vorgangsliste auf 1694 (Griff für alle, ruht bis Sa 21.11.); Griff am Stab vor 1694 angepasst."
```
   Die erste Meldung geht an **Sokrates**, der Hinweis an den **Disponenten**. Danach jeweils die WECKER-Zeile.

**2. Was ich nicht tue:** Am Stab baue ich nichts und warte auch nicht selbst auf 1694: „Du änderst nichts.“ Den Fund zu 1694 behebe ich nicht: „Fund außerhalb des Auftrags: zurückmelden, nicht beheben.“

**3. Quellen:** Zeilen 1657 und 1694 in `docs/LISTE-VORGAENGE.md`; `docs/vorgang/` (nur `1789.md` vorhanden); `git log -1 c0ffee1`.

**4. Nächster Schritt:** nach neuem „fertig“. Sokrates kann den Vorgang vorher anhalten.

**5. Lücke und Widerspruch**
- Ohne Auftrag (Ziel, Prüffragen) kann ich die Schritte 2 und 3 nur am Chefwort messen. Was ich ohne Auftrag tue, sagt der Text nicht.
- **Werkzeug:** Das Chef-„Nein“ unter „Chefworte“ zählt `zaehlen()` nicht. Ohne mein wörtliches „steckt fest“ ginge das Nein als erster Rückläufer an den Macher.

---

## P7: 760, drei Wolfsangriffe (`be2c0d8`)

**1. Was ich tue**
1. Film ansehen: Angriff 1 und 2 von der Seite, die Zähne enden eine Handbreit vor dem Körper. Angriff 3 von hinten, der Biss ist nicht zu sehen.
2. Schritt 1: **Nein.** `be2c0d8` ist `be2c0d8f0` vom 18.11. (`SPRUNG_TIEF`), genau der Stand unter „Bisher“: t300.11 Fail, aus Build 300 zurückgenommen (`dbdff8bc2`). Es gibt keinen neuen Commit, also nichts Neues. Der Film zeigt denselben Fehler wie t300.11.
3. Vorheriges Nein: „Film t300.11 Fail“ des Chefs → „steckt fest“.
4. Ohne Prüffrage gesehen: Der Auftrag ist ein „Entwurf; eintragen erst nach 1589.4“ und „Ruht bis 1589.4 (1714): vorher kein Lauf“. Liste: 760 „ruht, nach Arena (1714)“, wartet auf 1589.4. Das melde ich als eigenen Hinweis.
5. Befehle:
```
python3 tools/vorgang.py rueckmeldung 760 "nein, steckt fest: Neues nicht drin. Commit be2c0d8 ist be2c0d8f0 (18.11., SPRUNG_TIEF), der Stand aus 'Bisher', in t300.11 Fail und aus Build 300 zurückgenommen (dbdff8bc2); der Film zeigt denselben Fehler (Biss 1 und 2 enden eine Handbreit vor dem Körper). Neuen Stand auf gepushtem Zweig bauen und nennen. Fehlende Handwerksregel: Widerspruch Messung gegen Bild (1711) erst am gezeichneten Netz in der Endpose nachstellen, bevor ein Film läuft."
python3 tools/vorgang.py rueckmeldung 760 "Hinweis: Lauf zu 760 vor 1589.4; Auftrag ist Entwurf ('eintragen erst nach 1589.4', 'Ruht bis 1589.4: vorher kein Lauf'), Vorgangsliste 760 'ruht, nach Arena (1714)'."
```
   „nein“ geht an **Sokrates**, „Hinweis“ an den **Disponenten**. Danach die WECKER-Zeilen.

**2. Was ich nicht tue:** Prüffragen (Biss trifft, Blut, Angriff 3 verdeckt) und das Querprofil prüfe ich nicht weiter: „nichts weiter prüfen“. Klang und Wirkung des Blutes sind Spielgefühl. `profil-kampf.md` lade ich nicht, mein Text erlaubt nur die Querprofile, und A16 nennt keines davon.

**3. Quellen:** `A16.auftrag.md`; `git log -1 be2c0d8` (be2c0d8f0, 18.11., auf `main` nur zusammen mit dem Revert `dbdff8bc2`); Zeile 760 in der Vorgangsliste.

**4. Nächster Schritt:** frühestens nach 1589.4 und einem neuen „fertig“.

**5. Lücke**
- Ob ich einen Auftrag prüfe, der laut eigenem Kopf noch Entwurf ist und ruht, sagt der Text nicht. Die Wahl zwischen „nein, Auftrag“ und „Hinweis“ ist offen. Ich habe „Hinweis“ gewählt, weil der Auftrag selbst nicht am Ziel vorbeifragt.
- Angriff 3 von hinten wäre zugleich „Beleg fehlt“ (Kamera seitlich je Angriff verlangt). Nach Schritt 1 entfällt das, die nächste Runde wird es bringen.

---

## P8: 1724, Vollzug Build 300 ohne 760 (`3e1df00`)

**1. Was ich tue**
1. Beleg ansehen: Die Rückmeldung bringt keine Ausgabe, nur „Geprüft an: `3e1df00`“. Prüfart laut Auftrag: „Prüfung mit Ausgabe“. Verlangt sind Merge-Commit auf `main`, Lauf-Link, Zahl der zugeordneten Commits und Ausgabe des Diffs.
2. Selbst gesehen (lesend):
   - `git log -1 3e1df00`: „Vollzug 1724 … Geprüft an: 3db05d4e5“. Das ist der Notiz-Commit, nicht der Merge.
   - `git log -1 --format='%h %p %s' 3db05d4e5`: Eltern `06737b6b1` `dbdff8bc2`, also ein Merge.
   - `git show --stat dbdff8bc2`: „Revert von a607a1d3d, 18be49d71, 13f6a3f70, be2c0d8f0“, ein gemeinsamer Revert.
   - Würde ich noch ausführen: `git log --oneline main..origin/claude/build-300` (leer erwartet) und `gh run list --workflow godot.yml --commit 3db05d4e5 --limit 1` für den grünen Lauf (laut Fall angenommen grün).
3. Schritt 2: **Beleg fehlt.** „Geprüft an“ nennt den Notiz-Commit statt des Merges, und Lauf-Link, Zahl und Diff-Ausgabe fehlen (Maße aus „Zurück“).
4. Befehl:
```
python3 tools/vorgang.py rueckmeldung 1724 "Beleg fehlt: Die Rückmeldung muss den Merge-Commit auf main (3db05d4e5, nicht den Notiz-Commit 3e1df00), den Link zum grünen Lauf godot.yml, die Zahl der zugeordneten Commits aus main..claude/build-300 und die Ausgabe des Diffs zeigen, dass je 760-Commit (a607a1d3d, 18be49d71, 13f6a3f70, be2c0d8f0) ein Revert auf main steht."
```
   An den Macher (ohne Vorgangsdatei an den Disponenten), danach die WECKER-Zeile.

**2. Was ich nicht tue:** Ich führe nichts zusammen und nehme nichts zurück: „Du änderst nichts.“ Ein „ja“ melde ich nicht auf eigene Sicht hin, solange der verlangte Beleg fehlt. „Die Arbeit lehnst du damit nicht ab.“

**3. Quellen:** `A6.auftrag.md`; `git log` und `git show` zu `3e1df00`, `3db05d4e5`, `dbdff8bc2`, `be2c0d8f0`.

**4. Nächster Schritt:** nach der ergänzten Rückmeldung. Stimmt sie mit dem überein, was ich gesehen habe, melde ich „ja“, und das geht an den Disponenten.

**5. Lücke und Widerspruch**
- „Erst sehen“: Darf ich den fehlenden Beleg durch eigene Repo-Prüfung ersetzen? Der Text sagt es nicht. Mein Repo-Blick spricht in der Sache für „ja“.
- Prüffrage „zu jedem der vier ein Revert“: Ein gemeinsamer Revert-Commit für alle vier, gilt das? Der Text schweigt.
- „fertig: Vollzug …“: Das Werkzeug erkennt „fertig“ und findet einen Hash, also ging es richtig an mich. Den Vollzug prüft laut Vollzugsregel „der Empfehler am Stichtag“. Das ist eine zweite Prüfstelle, die mein Text nicht kennt.

---

## P9: 1535, zweite Rückmeldung (Gewichte am Oberarm, `bfd783a`)

**1. Was ich tue**
1. Beleg ansehen: beschriftet, Spielkamera, Stelle markiert. Im neuen Feld liegt die Flanke am Körper, keine Beule.
2. Schritt 1: Ja.
   - `bfd783a3c` liegt auf `origin/claude/tom-1535-gruss`, enthält aber nur `godot/tests/spielbild_1535.gd.uid` („uid des Bildskripts 1535“).
   - Die gemeldeten „Gewichte am Oberarm“ stehen im Vorgänger `4fd7055c8`. Der Stand `bfd783a` enthält sie, das Neue ist im Bild sichtbar.
3. Schritt 2: **Beleg fehlt.**
   - Prüfart „Bild am Rechner plus Prüfungsausgabe“: Die Prüfungsausgabe fehlt.
   - Der Auftrag verlangt Garrick (Gruß) **und** Kittel (Hand zum Mund). Laut Fall ist nur Garrick zu sehen.
   - Zahl der Fälle und der Satz zur Ursache fehlen („Zurück“).
4. Gesehen: A7 ist ein „Nachstellauftrag, kein Bau“. Die Rückmeldung bringt einen Bau. Die Prüffragen 1–2 (Beule zeigen, Prüfung rot, Schalter) passen auf einen Bau nicht mehr. Das melde ich als Hinweis.
5. Befehle:
```
python3 tools/vorgang.py rueckmeldung 1535 "Beleg fehlt: Zum Bild alt gegen neu (Garrick, Flanke anliegend) muss die Prüfungsausgabe kommen: Messung über alle Figuren mit Kaufkleid je Ruhebewegung mit gehobenem Arm mit Zahl, achsel_1515 an der Stelle, dazu das Feld Kittel (Hand zum Mund) alt gegen neu und die Ursache in einem Satz (welche Ecken folgten welchem Knochen); als Bau-Commit 4fd7055c8 nennen, bfd783a ist nur die uid des Bildskripts."
python3 tools/vorgang.py rueckmeldung 1535 "Hinweis: Auftrag 1535 ist Nachstellauftrag (kein Bau), die Rückmeldung bringt den Bau 4fd7055c8 (Gewichte in T-Haltung, Oberarm, Flankenregel 16:25 weg); Prüffragen 1–2 (Beule zeigen, Prüfung rot, Schalter) fragen danach am Ziel vorbei."
```
   „Beleg fehlt“ geht an den Macher, der Hinweis an den Disponenten, danach die WECKER-Zeilen. Zählung in der Kette: Das „nein“ aus P1 bleibt die einzige Runde, „Beleg fehlt“ zählt nicht. Keine Obergrenze ist erreicht.

**2. Was ich nicht tue**
- Kein „ja“, solange Prüfungsausgabe und Kittel fehlen.
- Keine Wertung, ob die neue Flanke „schöner“ ist (Chef).
- Nach Schritt 4 kein „nein“ für die Signatur. Aus dem Fall ist nichts zu sehen, das gegen das Querprofil spricht (Tusche in Spielkamera vorhanden).

**3. Quellen:** `A7.auftrag.md`; `git show --stat bfd783a3c`; `git log --oneline origin/claude/tom-1535-gruss` (`4fd7055c8`, `1896bc91c`, `bfd783a3c`); Zeile 1535 der Vorgangsliste.

**4. Nächster Schritt:** nach der ergänzten Rückmeldung, dann die Schritte 3 und 4 ganz.

**5. Lücke und Widerspruch**
- Ob nach „Beleg fehlt“ noch Schritt 3 folgt, sagt das Profil nicht („Die Arbeit lehnst du damit nicht ab“, aber kein „weiter“ oder „Halt“).
- Für Prüffragen eines Nachstellauftrags, die ein Bau überholt, nennt der Text „nein, Auftrag“ nur, „ohne dass du einen Mangel siehst“. Hier sehe ich einen Belegmangel, darum habe ich „Hinweis“ statt „nein, Auftrag“ gewählt.
- Auffällig im Repo: Die Vorgangsliste trägt zu 1535 schon „gebaut, Geprüft an: bfd783a3c (Bild 👍 21:40)“. Der Chef hätte das Bild also vor einem „ja“ der Abnahme gesehen. Mein Text sagt nicht, was ich dann tue.

---

## Übergreifend: Text gegen Werkzeug

1. **Chef-Nein:** Das Profil zählt ein „nein“ des Chefs unter „Bisher“ oder in der Vorgangsdatei mit. `rueckmeldung.py` zählt nur den Abschnitt „Rückmeldungen“ (`zaehlen()`). Die Laufbremse (`LAUFBREMSE_NEIN = 2`) greift also erst beim zweiten Prüfer-Nein, nicht nach einem Chef-Nein. Richtig weitergegeben wird nur, weil ich „steckt fest“ wörtlich schreibe.
2. **Macher bei „steckt fest“:** Bei „nein … steckt fest“ geht die Übergabezeile an Sokrates, nicht an den Macher. Profil und Kern sagen nicht, wer dann nachbessert.
3. **Empfänger ohne „fertig“:** Fehlt in der Vorgangsdatei ein „fertig“ (die Fachkraft hat nicht über das Werkzeug gemeldet), gehen „nein“ und „Beleg fehlt“ an den Disponenten statt an den Macher (`macher()` → `None`).
4. **Sitzung:** Das Werkzeug nimmt meine Rolle aus der Besetzung, sonst „unbekannt“. `--sitzung Prüfer` erwähnt mein Text nicht. Die Empfänger heißen bis zur Umschaltung Diogenes und Ford (`alt = {"Prüfer": "Diogenes", "Disponent": "Ford", …}`), das kennt mein Text nicht.
5. **Testbitte:** Für das Gegenlesen einer Testbitte (P3) gibt das Werkzeug keine Nummer vor. Der Text auch nicht.
