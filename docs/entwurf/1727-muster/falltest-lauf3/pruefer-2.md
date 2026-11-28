# Antworten Prüfer Kette (Falltest Lauf 3, 22.11., 07:20)

Ladetext: `lt3/sockel.md`, `lt3/kern-abnahme.md`, `lt3/profil-pruefer.md`; dazu der Auftrag `A7.auftrag.md` und das darin unter „Beachte“ genannte Querprofil Signatur und Leben (der Kern verweist darauf: „beide lädt der Auftrag zu“). Werkzeug gelesen: `tools/rueckmeldung.py` (ganz), `tools/vorgang.py` Zeilen 41–43, 812–813. Kein Schreibbefehl ausgeführt; die Befehle unten täte ich.

## P1 (eigene Sitzung)

Eingang: „fertig 1535: Flanke Garrick, Messung 67 → 57, Commit `3c1f0aa`, Bild alt gegen neu“. Laut Werkzeug kam sie zu mir, weil „fertig“ mit Commit (`rueckmeldung.py` Z. 98: `if COMMIT.search(text): return PRUEFER, …`).

Erst sehen (Beleg), dann lesen (Rückmeldung).

1. **Neues drin:** Beleg zeigt den gemeldeten Commit: ja, Feld beschriftet „neu `3c1f0aa`“. Neues darin: nur als Beschriftung; im Bild ist nichts Neues zu sehen (Feld neu gleich Feld alt). Ich prüfe 2–4 weiter.
2. **Beleg:** Art Bild reicht, richtig. Mängel gegen Feld 6:
   - Feld alt ist „alt `7ffa715`“ beschriftet; verlangt ist Build 299.
   - Figur nicht beschriftet; die Rückmeldung nennt nur Garrick; ob Bram je ein Feld hat, sagt das Bild nicht.
   - Handygröße nicht angegeben, Flanke nicht markiert.
   - Zug von der Jacke zum Arm (15:33): die Beschreibung zeigt nur die Beule; dazu lässt das Bild keinen Schluss zu.
   - Spielkamera: ja. Spiel-Shader und Tusche: nicht beschrieben, im Test kein Schluss.
3. **Ziel und Prüffragen:** Ziel nicht erreicht: in beiden Feldern dieselbe Beule über Körperbreite.
   - Neues nachweislich im Bild? Nein. Feld neu gleich Feld alt.
   - Flanke in jedem neuen Feld am Körper, keine Beule (15:59)? Nein. Die Beule ist im Feld neu da.
   - Unterschied alt gegen neu ohne Erklärung sichtbar? Nein. Es ist keiner zu sehen.
   - Kein Zug Jacke zum Arm (15:33)? Kein Schluss möglich, siehe 2.
   - Prüfung über alle grün, Zahl genannt? Nein. Die Rückmeldung hat keine Zahl (Feld 7 verlangt „Zahl der geprüften Fälle“).
   - Messung 67 → 57: zählt nicht. „Widersprechen sich Messung und Bild, gilt das Bild“ (Kern); A7 Feld 4 sagt: „67 → 57 war unsichtbar“. Das ist dieselbe Zahl wie vorher.
   - Neins unter „Bisher“ erneut geprüft: „299.3 ✗“ weiter nein; 15:59 Beule weiter nein; 15:33 kein Schluss.
   - Ohne Prüffrage, nein: Ursache nicht belegt (Feld 5); Quelle zur Systemfrage (wie andere Spiele es lösen, mit Link) fehlt (Feld 2); Prüfung „am Stand von Build 299 rot“ nicht gemeldet (Feld 5); Weg in `kauf_kleid.py` für alle Figuren nicht gezeigt (Feld 2). Der Macher hat trotz Nein gesendet, Feld 6 sagt: „Ein Nein: nicht senden.“
4. **Nur am Geänderten:** Fremder Stil, Text und Katalog: nichts Neues, kein Mangel. Das Kaufkleid ist eine fremde Datei, das Querprofil Fremde Inhalte lädt A7 aber nicht zu. Nicht prüfbar, Hinweis.

„steckt fest“: nein. Unter „Rückmeldungen“ steht noch kein Nein. „299.3 ✗“ des Chefs ist das Nein, aus dem der Auftrag entstand, und zählt nicht.

**Rückmeldung 1:**

```
python3 tools/vorgang.py rueckmeldung 1535 "nein 1535 (Commit 3c1f0aa): Im Feld neu unter dem gehobenen Arm ist dieselbe Beule über Körperbreite wie im Feld alt; Flanke an den Körper bringen (15:59). Die Messung 67 → 57 zählt nicht, das Bild zeigt sie nicht (A7 Feld 4). Unterschied alt gegen neu nicht sichtbar; das Neue muss ohne Erklärung zu sehen sein. In der Rückmeldung fehlen Zahl und Ergebnis der Prüfung über alle Fälle und ob sie am Stand von Build 299 rot ist; nennen. Ohne Prüffrage: Ursache nicht belegt, Quelle zur Systemfrage mit Link fehlt, Weg in kauf_kleid.py für alle Figuren nicht gezeigt; nachliefern. Beleg: Feld alt muss Build 299 zeigen, nicht 7ffa715; Felder mit Figur beschriften, Garrick und Bram je ein Feld; Flanke markieren; Handygröße nennen; der Zug von der Jacke zum Arm (15:33) muss zu beurteilen sein."
```

Weg im Werkzeug: `worte()` ergibt {„nein“} (Z. 51; „steckt fest“ steht nicht im Text, Z. 57). `zaehlen` ergibt danach nein = 1, also keine Obergrenze (Z. 136) und keine Laufbremse (Z. 145, erst bei 2). Dann `weitergabe` (Z. 150), Zweig Z. 90–93: `macher(vorher)` ist der, der zuletzt „fertig“ meldete, also die Fachkraft. Zeile „Rückläufer (nein des Prüfers, …): „<erste 160 Zeichen>“; nachbessern, dann `vorgang.py rueckmeldung` „fertig“ mit Commit (1739)“. Ist der Macher „unbekannt“, geht sie an den Disponenten (Z. 94). Ausgabe `EINGETRAGEN 1535, OFFEN 1535-Ü<n> an <Fachkraft>`, dazu `WECKER <Sitzung> | sieh in 1535 (1535-Ü<n>)` (Z. 214). Die WECKER-Zeile schicke ich per `send_message` an diese Sitzung. Außerdem laufen der Lehrenbuch-Eintrag (Z. 199–203) und der Nein-Wächter (Z. 212).

**Rückmeldung 2:**

```
python3 tools/vorgang.py rueckmeldung 1535 "Hinweis: Prüffrage fehlt in A7 (1535, Feld 6): Ist die Ursache belegt? Ist die Prüfung am Stand von Build 299 rot? Ist die Quelle zur Systemfrage mit Link genannt? Außerdem: A7 bearbeitet ein Kaufkleid, lädt aber das Querprofil Fremde Inhalte nicht zu (Feld 4); die Lizenz der Bearbeitung ist darum nicht prüfbar."
```

Weg im Werkzeug: `worte()` ergibt {„Hinweis“} (Z. 56), Zweig Z. 101: an den Disponenten, „wie einen Eingang behandeln“. Bis zur Umschaltung ist das Ford (Z. 213). Die WECKER-Zeile geht an Fords Sitzung.

## P9 (eigene Sitzung)

Eingang: „fertig 1535: Gewichte am Oberarm, Commit `bfd783a`, Bild alt gegen neu“ (Z. 98, an den Prüfer). Unter „Rückmeldungen“ steht mein Nein aus P1.

1. **Neues drin:** „beschriftet“ heißt hier: wie Feld 6 verlangt, mit Figur und Commit. Ich sehe nach, dass die Beschriftung `bfd783a` zeigt und Feld alt Build 299 (in P1 bemängelt). Steht dort etwas anderes, kommt der Satz „Beleg fehlt“ dazu. Neues darin: ja, die Flanke ist im Feld neu verändert.
2. **Beleg:** Bild, beschriftet, Spielkamera in Handygröße, Stelle markiert, Garrick und Bram je ein Feld: erfüllt. Offen bleibt: Den Zug von der Jacke zum Arm (15:33) nennt die Beschreibung nicht; dazu kein Schluss, Satz „Beleg fehlt“. Messung 67 → 31: passt zum Bild und gilt.
3. **Ziel und Prüffragen:** Ziel im Bild erreicht (Flanke am Körper, keine Beule), soweit es zu sehen ist.
   - Neues nachweislich im Bild? Ja. Im Feld neu liegt die Flanke anders als in P1.
   - Flanke in jedem neuen Feld am Körper, keine Beule? Ja, laut Beleg.
   - Unterschied ohne Erklärung sichtbar? Ja. Alt Beule, neu am Körper.
   - Kein Zug Jacke zum Arm (15:33)? Kein Schluss, siehe 2.
   - Prüfung über alle grün, Zahl genannt? Nein. Die Rückmeldung hat weiter keine Zahl.
   - Mein Nein aus P1 erneut geprüft: Beule behoben, ja. Beschriftung, Markierung und Handygröße: ja. Zahl und rot an Build 299: weiter nein. Ursache „Gewichte am Oberarm“ ist jetzt genannt, aber nicht belegt: nein. Quelle mit Link: weiter nein. Weg in `kauf_kleid.py` für alle Figuren: nicht gezeigt, nein.
4. **Nur am Geänderten:** Kein neuer Text, keine neue Figur, kein fremder Stil beschrieben. Fremde Inhalte: wie in P1 nicht zugeladen, mein Hinweis steht schon.

„steckt fest“: ja. Ich melde nein, und unter „Rückmeldungen“ steht mein Nein aus P1 zu diesem Auftrag, später datiert als der Auftrag. Fehlende Handwerksregel: Die Fachkraft sendet „fertig“, ohne jede Prüffrage und jedes Feld „Zurück“ abgehakt zu haben (Zahl der Prüfung über alle, Quelle mit Link).

**Rückmeldung:**

```
python3 tools/vorgang.py rueckmeldung 1535 "nein 1535 (Commit bfd783a), steckt fest: Das Bild ist gut, die Flanke liegt im Feld neu am Körper, keine Beule, Messung 67 → 31 passt. In der Rückmeldung fehlen weiter Zahl und Ergebnis der Prüfung über alle Fälle und ob sie am Stand von Build 299 rot war (A7 Feld 5, 7; Prüffrage 5); nennen. Offen aus meinem Nein zu 3c1f0aa, ohne Prüffrage: Ursache „Gewichte am Oberarm“ ist genannt, aber nicht belegt; Quelle zur Systemfrage mit Link fehlt; Weg in kauf_kleid.py für alle Figuren nicht gezeigt; nachliefern. Beleg: Der Zug von der Jacke zum Arm (15:33) ist im Bild nicht zu beurteilen; zeigen. Fehlende Handwerksregel: „fertig“ erst senden, wenn jede Prüffrage und jedes Feld „Zurück“ erfüllt ist (A7 Feld 6: „Ein Nein: nicht senden“)."
```

Weg im Werkzeug: `worte()` ergibt {„nein“, „steckt fest“} (Z. 51 und 57). `zaehlen` ergibt danach nein = 2 und steckt fest = 1, also keine Obergrenze (A ab 3 Nein, B ab 2 „steckt fest“; Z. 136–137). Der erste Zweig, der greift, ist Z. 143–144: an **Sokrates**, Zeile „steckt fest: Rückmeldung <Zeit> von Prüfer lesen (1763 C)“. Die Laufbremse (Z. 145) wird nicht mehr erreicht, und `weitergabe` (Z. 150) auch nicht. Die Fachkraft bekommt also **keine** Rückläufer-Zeile. Ausgabe `EINGETRAGEN 1535, OFFEN 1535-Ü<n> an Sokrates`, dann WECKER an Sokrates' Sitzung (Z. 214). Läuft keine, kommt „KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)“ (Z. 215–216). Lehrenbuch und Nein-Wächter laufen wie in P1.

## Fund außerhalb der Fälle (Sockel 5, nur gemeldet)

`git show` im Repo: `7ffa715` ist „431 Tuch letzter Lauf …“ vom 15.11. und keine Gewichtsänderung am Rumpf zu 1535. `bfd783a` ist „uid des Bildskripts 1535“ (nur `godot/tests/spielbild_1535.gd.uid`), keine Gewichte am Oberarm. `3c1f0aa` gibt es nicht. Im echten Lauf hieße das: A7 „Bisher“ nennt einen falschen Commit, und in P9 ist das Neue nicht im gemeldeten Commit (Schritt 1 „nein“). Im Falltest sind die Hashes wohl ausgedacht. Ich habe nach der Fallbeschreibung geurteilt.

## Lücken

1. **„steckt fest“ greift auch, wenn nur noch die Meldung fehlt, und dann bekommt der Macher keine Zeile.** Profil: „Meldest du „nein“ und steht … schon ein „nein“ eines Prüfers … dazu „steckt fest““. Werkzeug Z. 143 vor Z. 150: `elif w & {"steckt fest", "Frage", "wirkt nein"}: an, was = SOKRATES, …`. In P9 ist das Bild gut, es fehlen Zahl und Quelle. Trotzdem geht der Vorgang an Sokrates, zählt für Obergrenze B, und die Mängelsätze erreichen die Fachkraft nicht als Rückläufer. Es fehlt eine Unterscheidung „dasselbe Nein wieder“ gegen „neues, kleineres Nein“, oder dass auch der Macher eine Zeile bekommt.
2. **Die Laufbremse ist für den Prüfer nicht erreichbar.** Werkzeug Z. 11: „zweites „nein“ je Vorgang → an Sokrates „steckt fest (Laufbremse)““. Hält sich der Prüfer an sein Profil, enthält jedes zweite Nein schon „steckt fest“, und Z. 143 greift vor Z. 145. Das Ergebnis ist gleich (Sokrates), aber Z. 145–146 ist für Prüfer-Neins totes Werk.
3. **Der Hinweis „Prüffrage fehlt“ geht an die falsche Stelle.** Profil: „dazu die Rückmeldung „Hinweis: Prüffrage fehlt: …““. Werkzeug Z. 101: `if "Hinweis" in w: return DISPONENT, "Hinweis (%s): wie einen Eingang behandeln (1739)"`. Den Auftrag schreibt der Arbeitsplaner (Z. 147 „nein, Auftrag“ → `PLANER`), der Hinweis auf eine fehlende Prüffrage landet aber beim Disponenten.
4. **Fremde Inhalte hängt am Auftrag.** Kern: „bei fremder Datei oder Spieltext, was das Querprofil Fremde Inhalte verlangt (beide lädt der Auftrag zu)“. A7 Feld 4 nennt nur `querprofil-signatur-und-leben.md`, obwohl ein Kaufkleid bearbeitet wird. Der Prüfer kann die Lizenz nicht prüfen, und kein Schritt sagt, was dann zu melden ist; ich habe einen Hinweis gemeldet.
5. **Zur Testausgabe fehlt ein Schritt.** Profil: „Du bekommst … die Rückmeldung (Commit, Beleg, Testausgabe)“. Beide Rückmeldungen haben keine Testausgabe. Nur unter „Handy“ steht „die Testausgabe grün ist“. Für Bild-Belege sagt kein Schritt, ob fehlende Testausgabe „Beleg fehlt“ oder „nein“ ist. Ich habe es über Prüffrage 5 und Feld 7 als „nein“ gemeldet.
6. **Schritt 1 lässt ein gleiches Bild durch.** Profil: „Ist das Neue darin (bei Modellen Name oder Kennung)?“. Bei einer Gewichtsänderung ist die Commit-Beschriftung die einzige Kennung. In P1 besteht Schritt 1 so trotz unverändertem Bild; erst Prüffrage 1 fängt es. Es fehlt: „bei Änderung am Bestehenden: Unterschied zu sehen“.
7. **„nach seinem Datum“ ist mehrdeutig.** Profil: „ein „nein“ eines Prüfers oder des Chefs zu diesem Auftrag (nach seinem Datum; das Nein, aus dem er entstand, … zählen nicht)“. „seinem“ kann den Auftrag oder das Nein meinen. Ob die Chefworte 15:33 und 15:59 (vor A7, aber nicht „299.3 ✗“) als Neins zählen, ist nicht eindeutig. Ich habe sie als Ursprung des Auftrags nicht gezählt.
8. **Unbelegte Teilfragen in einem sonst guten Beleg.** Profil: „lässt er keinen Schluss zu, auch nur für einen Teil … „Beleg fehlt““. Zugleich gilt: „trifft „nein“ mit einem Belegmangel zusammen, erstes Wort „nein““. In P9 wäre ohne die fehlende Zahl das erste Wort „Beleg fehlt“, nur wegen des Zugs (15:33). Wie schwer ein einziger nicht beurteilbarer Teil wiegt, sagt der Ladetext nicht. Das ist folgerichtig, aber hart.
