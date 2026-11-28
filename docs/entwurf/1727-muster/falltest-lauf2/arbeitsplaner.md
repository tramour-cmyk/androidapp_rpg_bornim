# Antworten Arbeitsplaner (Büro), Fälle A1–A16

Gespielt am 21.11., ab 23:28, nur mit Sockel, Kern Büro, Kern Arbeitsplaner und den genannten Profilen. Repo `/home/user/bornim-main` nur gelesen (`git status` danach leer).
Kurzname: `AU=/tmp/claude-0/-home-user-androidapp-rpg-bornim/631c2e46-b361-57ad-a0c4-9f58072209a7/scratchpad/antworten/auftraege`.
Alle Schreibbefehle unten sind **nur aufgeschrieben, nicht ausgeführt**. Eingetragen würde ein Auftrag mit `python3 tools/vorgang.py auftrag <Nr> --datei $AU/<Fall>.auftrag.md` (ohne `--pruefen`).

Für jeden Fall gilt zusätzlich (Werkzeug, nicht Ladetext): vorher `python3 tools/vorgang.py offen Arbeitsplaner`, die Zeile an mich `python3 tools/vorgang.py annehmen <Kennung>`, nach der Rückmeldung `python3 tools/vorgang.py erledigt <Kennung>`.

## Prüfausgaben (alle Aufträge)

```
A1:  vorgang.py auftrag 1694 --datei $AU/A1.auftrag.md --pruefen  → vorgang.py auftrag 1694: gültig (2037 Byte)
A3:  vorgang.py auftrag 1694 --datei $AU/A3.auftrag.md --pruefen  → vorgang.py auftrag 1694: gültig (1660 Byte)
A6:  vorgang.py auftrag 1694 --datei $AU/A6.auftrag.md --pruefen  → vorgang.py auftrag 1694: gültig (1696 Byte)
A7:  vorgang.py auftrag 1535 --datei $AU/A7.auftrag.md --pruefen  → vorgang.py auftrag 1535: gültig (1949 Byte)
A8:  vorgang.py auftrag 1650 --datei $AU/A8.auftrag.md --pruefen  → vorgang.py auftrag 1650: gültig (1968 Byte)
A9:  vorgang.py auftrag 1653 --datei $AU/A9.auftrag.md --pruefen  → vorgang.py auftrag 1653: gültig (1947 Byte)
A10: vorgang.py auftrag 1613 --datei $AU/A10.auftrag.md --pruefen → vorgang.py auftrag 1613: gültig (1995 Byte)
A11: vorgang.py auftrag 1655 --datei $AU/A11.auftrag.md --pruefen → vorgang.py auftrag 1655: gültig (2002 Byte)
A12: vorgang.py auftrag 1694 --datei $AU/A12.auftrag.md --pruefen → vorgang.py auftrag 1694: gültig (1960 Byte)
A13: vorgang.py auftrag 1621 --datei $AU/A13.auftrag.md --pruefen → vorgang.py auftrag 1621: gültig (1848 Byte)
A14: vorgang.py auftrag 431  --datei $AU/A14.auftrag.md --pruefen → vorgang.py auftrag 431: gültig (1991 Byte)
A15: vorgang.py auftrag 1619 --datei $AU/A15.auftrag.md --pruefen → vorgang.py auftrag 1619: gültig (1862 Byte)
A16: vorgang.py auftrag 760  --datei $AU/A16.auftrag.md --pruefen → vorgang.py auftrag 760: gültig (1917 Byte)
```
1694 als Ersatznummer bei A3 (Build 299/1417 archiviert), A6 (1724 archiviert), A12 (1569 archiviert). A1 hielt zuerst an („2109 Byte, höchstens 2048“), gekürzt.

---

## A1 · 1694 Griff als Systemlösung (Chefwort 18.11., 17:01)

1. **Tue:** Nachstellauftrag, kein Bau: `$AU/A1.auftrag.md`. Grund: unter „Bisher“ drei Versuche (`c64616f7a`, `1659ed4cb`, `7c7ce0f02`), zuletzt Messung „passt“ (350°, −0,1 cm) gegen Bild „Stiel über dem Fingerrücken“ (19.11., 07:45), Ursache offen → Kern Feld 3 „Ursache unbekannt: Nachstellauftrag … kein Bau“. Beide Nein des Chefs (17:38, 21:37) wörtlich unter „Bisher“, als Prüffragen.
   Rückmeldung (aufgeschrieben): `python3 tools/vorgang.py rueckmeldung 1694 "Auftrag steht: 1694 Griff für alle gehaltenen Dinge – Nachstellauftrag Bild gegen Messung (Tiefe oder Pose), kein Bau; Auftrag in docs/vorgang/1694.md" --sitzung Arbeitsplaner`
2. **Nicht:** kein Bauauftrag (Ursache unbekannt); Chefwort nicht neu eintragen, es steht schon wörtlich im Archiv („Griff als Systemlösung“, 18.11., 17:01); Stieldicke der Staffelwaffen nicht anordnen (Aussehen, Spike 19.11., 11:17 selbst: „Chefsache mit Bild“).
3. **Quellen:** `vorgang.py 1694` (Liste, „Zu 1694“ 17:01 bis 19.11., 11:17, Archiv), `docs/ARBEIT-*.md` Volltext der Zeilen 07:45 und 11:17, `git log`/`git branch --contains 7c7ce0f02` (`claude/spike-1694-griff`), keine Commits zu 1694 seit 19.11.; `vorgang.py auftrag 1694` (Lehren: keine).
4. **Nächster Schritt:** Disponent startet die Fachkraft (1694 „ruht, bis Sa 21.11.“ ist abgelaufen; Archiv: „nächster Lauf ab Sa 21.11., 20:00 als Auftrag mit Systemfrage, nach Nachstellen am Einzelbild“). Nach „fertig“ mit Ursache schreibe ich den Bauauftrag.
5. **Lücke:** Wer nach „Auftrag steht“ startet, sagt der Kern nicht; das Werkzeug leitet „Auftrag steht“ nicht weiter (`rueckmeldung.py` kennt nur „steckt fest“, „Frage“, „wirkt nein“, „nein, Auftrag“, „fertig“, „ja“, „Hinweis“). Kern: Auftrag „oben in die Vorgangsdatei“; `auftrag.py eintragen` hängt „## Auftrag (Zeit)“ **unten** an. Kern Feld 4 „höchstens fünf Punkte und der Pfad des Profils“: das Werkzeug zählt jede Spiegelstrich-Zeile, Profilpfad deshalb in die Kopfzeile von „Beachte“ gelegt. Größe 2 KB nennt nur `auftrag.py`, nicht die Vorlage, auf die der Kern verweist („Felder und Größe: `vorgang.py auftrag <Nr>`“). Die Vorlage nennt „Lehren des Bereichs“; der Kern kennt das Lehrenbuch nicht.

## A2 · 1694 „1694 ist nix zu erkennen...“ (18.11., 21:37)

1. **Tue:** Kein eigener Auftrag: Nein des Chefs zum Bild, gehört wörtlich unter „Bisher“ von 1694 und wird Prüffrage – steht so in `$AU/A1.auftrag.md` (Feld 3 und Feld 6 „beschriftet, farbig, Nahsicht und Spielkamera Handygröße“, wie Archiv 21:37). Keine eigene Rückmeldung; die von A1 deckt es.
2. **Nicht:** nicht umformulieren, nicht als neue Aufgabe anlegen; kein Bildlauf (der Auftrag A1 lässt erst nachstellen).
3. **Quellen:** Archiv „1694, Bild nicht beurteilbar“ (18.11., 21:37) und „Lauf frei“ 21:58/23:41 über `vorgang.py 1694`.
4. **Nächster Schritt:** mit A1.
5. **Lücke:** Kern sagt nicht, was mit einem Chefwort geschieht, das älter ist als der letzte Auftrag/Stand (hier drei Tage, schon im Archiv verarbeitet).

## A3 · Build 299: 299.1, 299.2 „Handy“

1. **Tue:** Ausarbeitung `$AU/A3.auftrag.md`: beide Punkte als **Bild** statt Handy (Kern Feld 6: „Handy nur mit Satz ‚warum nicht Bild‘“; hier geht es um Aussehen eines festen Schirms, Bild in Handygröße reicht). Beleg in Git: Commit `51e24e668` „t299.1, t299.2 als Bild (Chef 15:48, Sokrates): Hauptmenü Handygröße, alt 297 gegen neu 299“. 299.2 „Fläche vor dem Schild“ aus der Quelle 1417 (Chef 16.11., 12:37: „Schild des Helden links wie abgeschnitten; Durchdringung beheben“) als Ausschnitt der Schildvorderseite gelesen.
   Rückmeldung: `python3 tools/vorgang.py rueckmeldung 1417 "Auftrag steht: 1417 Schild im Hauptmenü – Prüfpunkte 299.1, 299.2 als Bild (alt 297 gegen neu 299, 360 dp), nicht Handy" --sitzung Arbeitsplaner`
2. **Nicht:** keinen Handypunkt stehen lassen; keine Prüfliste selbst schreiben (Build-Macher); nichts in `docs/chefsache/` gelesen.
3. **Quellen:** `vorgang.py 1417 1675`, `git log --all -- '*t299*'` (nur Commit-Nachrichten), `git show -s 51e24e668 1da789511`.
4. **Nächster Schritt:** Build-Macher (Spike) übernimmt die Zeilen in die Prüfliste.
5. **Lücke:** „Fläche vor dem Schild“ ist mehrdeutig; meine Lesart steht auf 1417, ist aber Lesart → wäre streng genommen „Frage“. Kern regelt Build-Prüflisten nicht eigens (nur Aufträge an Fachkräfte). Build 299 ist laut Git längst getestet (t299 archiviert), 1417 erledigt; ob `rueckmeldung` auf eine archivierte Nummer geht, sagt der Text nicht.

## A4 · 👎 ohne Wort zu „1535 Garrick alt gegen neu“

1. **Tue:** Daumen wörtlich mit Zeit in die Vorgangsdatei (Kern Büro), dann „Frage“, denn was falsch ist, kann ich nicht belegen:
   `python3 tools/vorgang.py chefwort 1535 "👎 (ohne Wort) zur Meldung „1535 Garrick alt gegen neu“" --zeit "<TT.MM., HH:MM der Reaktion>"`
   `python3 tools/vorgang.py rueckmeldung 1535 "Frage: 1535 Kleidung bei gehobenem Arm (Garrick) – 👎 des Chefs ohne Wort zum Bild alt gegen neu; was ist falsch (kein Unterschied sichtbar, Stelle, anderes)? Ohne Wort kein Auftrag." --sitzung Arbeitsplaner` → Werkzeug legt Zeile an Sokrates an.
2. **Nicht:** keinen Auftrag aus Vermutung; nicht selbst beim Chef nachfragen (an den Chef nur über `meldung.sh`, und das ist Sokrates’ Weg).
3. **Quellen:** `vorgang.py 1535` (Archiv: genau dieser Fall 18.11., 17:12 „ohne Wort; nachgefragt 20:06“, Wort kam 21:47).
4. **Nächster Schritt:** Sobald das Wort in der Vorgangsdatei steht (Haken legt mir eine Zeile an), Auftrag wie A7.
5. **Lücke:** Kern: „Jedes frühere Nein … steht wörtlich unter ‚Bisher‘“ – ein Nein ohne Wort hat keinen Wortlaut; ob `chefwort` ein Emoji als „Wortlaut“ nimmt, sagt keiner. `vorgang.py build` wertet 👎 nur auf „tN.k:“-Meldungen aus, nicht auf Bildmeldungen außerhalb eines Builds.

## A5 · 1727 Spracherkennung „Profiltechnik-Jahr zu 535 Jahren“

1. **Tue:** „Frage“, wortgetreu, ohne Deutung:
   `python3 tools/vorgang.py rueckmeldung 1727 "Frage: 1727 Neustrukturierung – Chefwort 21.11., 15:15 aus der Spracherkennung „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ ist nicht eindeutig: Ja zu Profil Technik und zu 235 (Vorlage)? 535 und 1535 sind auch Vorgänge. Bitte Wortlaut bestätigen lassen." --sitzung Arbeitsplaner`
2. **Nicht:** nicht als „Profil Technik ja, 235 ja“ auslegen (Kern Feld 1: „Keine eigene Auslegung“; Kern Büro „nie umformuliert“); kein Auftrag. Das Chefwort steht schon in der Vorgangsdatei (Haken), nicht noch einmal eintragen.
3. **Quellen:** `vorgang.py 1727` (Sokrates, B Abläufe), `vorgang.py 235` (erledigt, Auto-Modus-Sperren), `vorgang.py 535` (Archiv, Kampf), `LISTE-CHECK-BUILD-TEST.md` 13 nennt „(235)“ als Merge-Regel.
4. **Nächster Schritt:** Sokrates klärt; bei Ja schreibe ich nichts, falls 1727 Sokrates’ eigener Ablaufvorgang ohne Fachkraftauftrag bleibt.
5. **Lücke:** Kern sagt nicht, ob der Arbeitsplaner für einen Ablaufvorgang des Sokrates (Bereich B) überhaupt einen Auftrag schreibt; der Haken schickt jedes Chefwort an mich (`chefwort.py`: „offene Übergabezeile an den Arbeitsplaner“).

## A6 · 1724 Build 300 ohne 760 (Kette K1.2)

1. **Tue:** Auftrag für den Build-Macher `$AU/A6.auftrag.md` (Profil Technik: „Nach `main` führst du zusammen, wenn dein Auftrag es nennt“; nur die vier 760-Commits zurücknehmen, nicht den Merge). Rückmeldung:
   `python3 tools/vorgang.py rueckmeldung 1724 "Auftrag steht: 1724 Build 300 auf main ohne 760 – vier 760-Commits per Revert, Rest per Merge nach grünem Lauf; Hinweis: laut Git schon geschehen (dbdff8bc2, 3db05d4e5 auf main)" --sitzung Arbeitsplaner`
2. **Nicht:** nicht selbst zurücknehmen oder mischen (baut nichts); 760-Zweig nicht anfassen; „lass es klar ziehen“ nicht weiter auslegen als „ohne 760 zusammenführen“.
3. **Quellen:** `vorgang.py 1724` (Archiv: erledigt, „Geprüft an: 3db05d4e5“), `git log origin/claude/build-300` (Merge `508bbbbad`, vier 760-Commits, Revert `dbdff8bc2`), `git merge-base --is-ancestor` (build-300 in `main`), `LISTE-CHECK-BUILD-TEST.md` 10–13.
4. **Nächster Schritt:** Spike; im echten Stand nichts mehr zu tun → Disponent sollte schließen statt starten.
5. **Lücke:** Git zeigt den Vorgang erledigt; der Kern kennt als erstes Wort nur „Auftrag steht“ oder „Frage“, kein „schon erledigt“. Profil Technik: „was ‚mit Einschränkungen‘ heißt: Checkliste 13“ – Checkliste 13 sagt das nicht, die Rücknahme einzelner Punkte steht in 12.

## A7 · 1535 Kleidung bei gehobenem Arm (Kette K2.2)

1. **Tue:** Nachstellauftrag `$AU/A7.auftrag.md` (Versuch ohne sichtbaren Unterschied, Ursache unbekannt). Funde des Chefs wörtlich unter „Ziel“/„Bisher“, Prüffragen daraus.
   `python3 tools/vorgang.py rueckmeldung 1535 "Auftrag steht: 1535 Kleidung bei gehobenem Arm – Nachstellauftrag über alle Kaufkleider mit gehobenem Arm, kein Bau; Hinweis: Commit 7ffa715 der Vorgangsdatei ist in Git 431 Tuch, Rumpfgewichte stehen in 547033f9f" --sitzung Arbeitsplaner`
2. **Nicht:** kein Bau, keine eigene Vermutung (Schultergewicht) als Lösung vorgeben.
3. **Quellen:** `vorgang.py 1535`, `git show -s 7ffa715` („431 Tuch letzter Lauf…“, 15.11.), `git log origin/claude/tom-1535-gruss` (`547033f9f` 18.11., 16:25 Flanke an den Rumpf).
4. **Nächster Schritt:** Fachkraft Figuren; nach „fertig“ mit Ursache Bauauftrag. Im echten Stand ist die Flanke gebilligt (Archiv 21.11., 21:40, `bfd783a3c`).
5. **Lücke:** Widerspruch Vorgangsdatei gegen Git (Commit) – Kern sagt nicht, ob dann „Frage“ oder Auftrag mit Hinweis; ich habe beides belegt in „Bisher“ geschrieben.

## A8 · 1650 Sohle schwebt (für W1)

1. **Tue:** `$AU/A8.auftrag.md`. Rückmeldung: `python3 tools/vorgang.py rueckmeldung 1650 "Auftrag steht: 1650 Stiefel – Sohle schwebt in der Ruhepose; Prüfung über alle stehenden Figuren, ein Weg, Bild alt gegen neu" --sitzung Arbeitsplaner`
2. **Nicht:** die genannten Pfade nicht übernehmen: `tools/bau/held_klassen.py` und `godot/scenes/held.tscn` gibt es nicht (`ls`), richtig `tools/blender348/v3/held_klassen.py`, Held in `godot/skripte/held.gd`/`heldfigur.gd`; keine Schwelle erfunden (am Bild belegen); Bild `ansehen/1650-stiefel.webp` nicht geöffnet (Chefsache, im Test gesperrt).
3. **Quellen:** `vorgang.py 1650` (echte 1650: Hose durch Stiefelschaft, gebilligt 17:12, `6ab87322b`), `find -name held_klassen.py`, `godot/tests/schweben_531.gd` (ähnliche Messung).
4. **Nächster Schritt:** Fachkraft Figuren über Disponent; kein Lauf frei → Bild am Rechner.
5. **Lücke:** Neuer Fund ohne Vorversuch: Kern verlangt Nachstellauftrag nur bei „Ursache unbekannt“ unter „Bisher“ – ob das auch für einen frischen Fund gilt, sagt er nicht; ich habe „erst nachstellen, dann beheben“ in einen Auftrag gelegt (Profil Technik/Figur). Wer den Beleglauf freigibt, sagt der Kern nicht. Die Lage widerspricht der echten Vorgangszeile 1650.

## A9 · 1653 Thessa Kragen (für W2)

1. **Tue:** `$AU/A9.auftrag.md`; Chef-Nein 18.11., 21:48 („keine Bilder … mehr freie Fläche“) wörtlich als Prüffrage. `python3 tools/vorgang.py rueckmeldung 1653 "Auftrag steht: 1653 Thessa – Kragen durch den Umhang; Durchstich über alle Umhangträger, Bild nur alt gegen neu, Figur mittig" --sitzung Arbeitsplaner`
2. **Nicht:** gebilligte Spangen (`711c18da6`, 👍 22:37) nicht zurückbauen lassen; 1570 (Umhang als System, Tom) nicht mitbauen.
3. **Quellen:** `vorgang.py 1653`, `git log origin/claude/jerry-1653-kleid`, `godot/tests/durchstich_1631.*`, `vorgang.py 1570`.
4. **Nächster Schritt:** Fachkraft über Disponent; Bild am Rechner (kein Lauf genannt).
5. **Lücke:** Lage („Kragen sticht durch den Umhang“) weicht von der Liste ab („Kleid sticht durch den Kragen“). Profil: „Sichtbarer eigener Fehler ist keine Frage an den Chef“ – Kern sagt nicht, ob dann überhaupt ein Bild an den Chef geht; Lage verlangt es.

## A10 · 1613 Glanz nachts (für W3)

1. **Tue:** `$AU/A10.auftrag.md` (Profil Technik + Querprofil, Signatur „Nur Gold, Feuer, Magie glänzen“). Film begründet (Glanz wandert mit Bewegung). `python3 tools/vorgang.py rueckmeldung 1613 "Auftrag steht: 1613 Glanz – Metall nachts nur im Licht sichtbarer Quellen, alle Metallteile, ein Filmlauf" --sitzung Arbeitsplaner`
2. **Nicht:** Farbe des Metalls nicht ändern lassen (Aussehen); Fassung A (Schein ab episch, Chef 18.11., 13:09) nicht anrühren.
3. **Quellen:** `vorgang.py 1613`, `git log origin/claude/spike-1613-glanz`, `grep "wie Plastik" docs/` (kein Treffer zu 1613 – Zitat nur aus der Lage), Vorhandensein `LISTE-EFFEKTE.md`, `LISTE-BESTAND.md`, `LISTE-TECHNIK-PRAXIS.md`.
4. **Nächster Schritt:** Spike über Disponent; ein Film frei (Sokrates).
5. **Lücke:** Echte 1613 ist Kür „Waffen episch mit Effekt“, die Lage ist ein anderes Thema („je Thema ein Vorgang“ – Kern schweigt, ob ich dann einen neuen Vorgang verlange). Welches Profil bei Licht/Shader im Dorf (Technik oder Welt), lässt der Kern offen.

## A11 · 1655 Morwen Kapuze (für W4)

1. **Tue:** `$AU/A11.auftrag.md` mit Profil Fremde Inhalte (Kaufdateien) und `add_repo`. `python3 tools/vorgang.py rueckmeldung 1655 "Auftrag steht: 1655 Morwen – Kapuze im Modellbau neu, alle Kapuzenträger, ein Bildlauf alt gegen neu" --sitzung Arbeitsplaner`
2. **Nicht:** keine neue Kapuzenform vorgeben (Aussehen, als „Frage“ der Fachkraft); keine Kaufdatei ins öffentliche Repo.
3. **Quellen:** `vorgang.py 1655` (`10d4710c0`, Lauf 20:58 nur alt), `git log origin/claude/tom-1655-kapuze`, `.github/workflows/godot.yml` (`tools/blender348/**` ist Spielcode-Pfad → kein Profil Werkzeug).
4. **Nächster Schritt:** Fachkraft Figuren; ein Bildlauf frei.
5. **Lücke:** „neu bauen“ an einem Kaufteil – ob das schon „Bearbeitung“ mit Lizenzprüfung des Originals ist, sagt der Kern nicht (Profil Fremde Inhalte schon).

## A12 · 1569 Umhang Wachsoldat aus dem Kaufmodell (für W5)

1. **Tue:** Auftrag als **Entwurf** `$AU/A12.auftrag.md`, nicht eintragen; „Frage“, weil das Ziel neues Aussehen ohne Chefwort ist (Kern: „Nicht deins: … Aussehen“, „Fehlt ein Chefwort zu seiner Frage: ‚Frage‘ statt Auftrag“; Profil Kataloge „Neues Aussehen nur nach Chefwort“).
   `python3 tools/vorgang.py rueckmeldung 1569 "Frage: 1569 Umhang Wachsoldat – Kaufumhang statt Tuch ist neues Aussehen ohne Chefwort; außerdem gehört es zu 1570 (ein Weg für alle Umhänge). Chefwort und Zuordnung?" --sitzung Arbeitsplaner`
2. **Nicht:** nicht eintragen, nicht kaufen, kein Lauf.
3. **Quellen:** `vorgang.py 1569` (Archiv: erledigt, t299, betraf den Helden), `vorgang.py 1570 1735 1736`, Archiv `grep umhang … kauf|tuch` (kein Chefwort), Archiv 1651 (Wache-Umhang gebilligt ohne Bau).
4. **Nächster Schritt:** nach Chefwort über Sokrates: Entwurf prüfen (`--pruefen`), eintragen, „Auftrag steht“.
5. **Lücke:** Fallanleitung verlangt einen Auftrag, Kern verbietet ihn ohne Chefwort – gelöst als Entwurf plus „Frage“. Kein Wort, ob ein Auftrag zu einem archivierten Vorgang eingetragen werden darf (`auftrag` hält bei Nummern außerhalb der Liste an: „steht nicht in der Vorgangsliste“).

## A13 · 1621 Waffenlänge (für P2)

1. **Tue:** `$AU/A13.auftrag.md`: Maß aus dem Chefentscheid A (18.11., 07:37: 110/100/115 cm), keine Varianten nötig. `python3 tools/vorgang.py rueckmeldung 1621 "Auftrag steht: 1621 Waffenlänge – Längen A entschieden, Bild alt gegen neu nach 1694 (Griff)" --sitzung Arbeitsplaner`
2. **Nicht:** keine neue Längenwahl (Chef hat gewählt); kein Lauf vor 1694 (Feld „wartet auf 1694“); Griffhöhe gehört zu 1694.
3. **Quellen:** `vorgang.py 1621`, Archiv Z. 155–170, `git log origin/claude/spike-1621-laengen` (`df5f29746`), `godot/tests/waffen_522.gd`, `godot/regeln/halt.json`.
4. **Nächster Schritt:** nach 1694 „fertig“ startet der Disponent 1621.
5. **Lücke:** Zitat „Die Waffen sind viel zu lang“ (17.11.) steht nicht im Archiv. Ohne den Entscheid A wäre es „Geschmack ohne Maß“ → Varianten; Kern sagt nicht, ob ein späterer Entscheid das ersetzt (ich habe ja angenommen).

## A14 · 431 Umhang starr (für P4)

1. **Tue:** `$AU/A14.auftrag.md` mit Systemfrage auf 1735 (Federknochen, `SpringBoneSimulator3D`, Projekt Godot 4.7) und 1570. `python3 tools/vorgang.py rueckmeldung 431 "Auftrag steht: 431 Umhang beim Gehen – Federknochen für losen Stoff, alle Träger, ein Filmlauf; Hinweis: deckt sich mit 1735 (Spike) und 1570 (Tom), Umhang in 431 ruht laut Archiv bis nach dem Meilenstein" --sitzung Arbeitsplaner`
2. **Nicht:** keinen zweiten Weg neben 1735 vorgeben; nicht den ruhenden Zweig `claude/tom-431-umhang` fortsetzen lassen.
3. **Quellen:** `vorgang.py 431 1570 1735 1736`, `godot/project.godot` (4.7), `grep SpringBone godot` (noch nicht benutzt).
4. **Nächster Schritt:** Disponent; ein Film frei.
5. **Lücke:** Archiv 16.11.: „Umhang ruht bis nach dem Meilenstein“ gegen Lage „Filmlauf frei“; Kern hat keine Regel für Überschneidung mit einem anderen Vorgang (Sockel 5: Fund zurückmelden – gemacht als Hinweis).

## A15 · 1619 Füße gleiten (für P5)

1. **Tue:** `$AU/A15.auftrag.md` mit Prüfung `gang_1632` als Systemfrage. `python3 tools/vorgang.py rueckmeldung 1619 "Auftrag steht: 1619 Gang über die Wiese – Fußgleiten über alle Gangarten mit gang_1632, ein Filmlauf" --sitzung Arbeitsplaner`
2. **Nicht:** Gehtempo 2,13 m/s nicht ändern (Chef 13:04); Build 301 nicht anfassen.
3. **Quellen:** `vorgang.py 1619 1632`, `git log origin/claude/spike-1619-gang-main` (`b11447e6c`, `bad5be71b`).
4. **Nächster Schritt:** Disponent; ein Film frei. Achtung: 1619 steht „gebaut“ in t301 – besser nach dem Test von 301.
5. **Lücke:** Kern sagt nicht, was mit einem Auftrag geschieht, dessen Vorgang gerade im Testbuild liegt.

## A16 · 760 Wolfsbiss (für P7)

1. **Tue:** Auftrag als **Entwurf** `$AU/A16.auftrag.md`, nicht eintragen; „Frage“:
   `python3 tools/vorgang.py rueckmeldung 760 "Frage: 760 Wolfsbiss – ruht bis 1589.4 (1714, Chef 18.11., 22:17); Profil Kampf: bis dahin kein Auftrag, kein Lauf. Entwurf liegt bereit; gilt die Ruhe weiter?" --sitzung Arbeitsplaner`
2. **Nicht:** keinen Auftrag, keinen Film (Profil Kampf „Arena“: „kein Auftrag, kein Lauf“); nicht nur am Wolf (Profil: „nie nur am Wolf“).
3. **Quellen:** `vorgang.py 760 1714 1708 1589`, `git log origin/claude/build-300` (760 zurückgenommen), Profil Kampf.
4. **Nächster Schritt:** nach 1589.4 Entwurf prüfen und eintragen.
5. **Lücke:** Lage „drei Wolfsangriffe im Film“ gegen Profil „Bauen und prüfen an allen Modellen …, nie nur am Wolf“ – ich habe Wolfsfilm plus Prüfung über alle Arten geschrieben. Kein erstes Wort für „ruht, kein Auftrag“; „Frage“ ist die einzige passende.

---

## Querschnitt Lücken (Text gegen Werkzeug)

- **Weiterleitung „Auftrag steht“:** Kern: „‚Frage‘ geht an Sokrates (das Werkzeug leitet weiter)“ – stimmt; für „Auftrag steht“ legt `rueckmeldung.py` keine Zeile an (nicht in `SIGNAL`), also startet niemand automatisch.
- **„oben in die Vorgangsdatei“** (Kern) gegen `auftrag.py`: Abschnitt wird ans Ende angehängt.
- **Beachte-Zählung:** Kern „höchstens fünf Punkte und der Pfad des Profils“; Werkzeug zählt jede Zeile mit `-`, `*`, `•`, `1.`; ein Profilpfad als Spiegelstrich würde den sechsten Punkt sperren.
- **Größe:** Kern verweist auf `vorgang.py auftrag <Nr>` für „Felder und Größe“; die Vorlage zeigt keine Größe, erst die Prüfung („höchstens 2048“).
- **Ersatznummer:** `auftrag` verweigert Nummern außerhalb der Liste; archivierte Vorgänge (1417, 1569, 1724) bekommen so keinen Auftrag.
- **Übergabezeilen:** `annehmen`/`erledigt` für die Zeile an den Arbeitsplaner nennt der Kern nicht.
- **Ablage der Aufträge:** Fallkopf „neben deine Antwortdatei“, Auftrag „in `antworten/auftraege/`“ – ich habe den Unterordner genommen.
- **Wer gibt Läufe frei:** Kern Feld 5 „genau ein Beleglauf“, sagt nicht, wer ihn freigibt (im Archiv Sokrates nach 621 A).
