# 1727 · Falltest Lauf 1 (21.11., 23:14), Antworten der Rollen

Verfahren: je Gruppe ein frischer Helfer, kennt nur die Ladetexte (Stand e8e18657e, ausgezogen nach Messregel: Sockel 1.109, Kern Leitung 2.837, Kern Büro 680, Profil Disponent 3.040, Kern Arbeitsplaner 2.649, Kern Abnahme 1.567, Profil Prüfer 2.030, Profil Tester 2.473, Rundblick Teil A 1.168, Werkstatt-Profile wie `herausgezogen.md`) und die Werkzeughilfe; Sollwerte (`falltest-faelle-22-11.md`) nicht gesehen. Bewertung gegen Soll folgt (Abschnitt „Bewertung“). Hier nur die Lücken, die die Rollen selbst nennen, und Abweichungen auf den ersten Blick.

## Rundblick (R1–R3)

- R1: wählt Funde des Chefs zuerst, Vorschlag mit Quelle, Maß, Kosten; `vorgang.py uebergabe <Nr> Disponent "Vorschlag: …"`, dann `rueckmeldung <Nr> "fertig"`; baut nichts. **Lücken:** welche `<Nr>` (eigener Routine-Vorgang oder Vorgang der Schwäche); erledigte Vorgänge als Schwäche?; Wochenzählung ohne laufende Woche; „teuerste“ für Chef-Fund nicht in Geld messbar.
- R2 (Stau „gebaut“ ohne Build): Fund außerhalb des Auftrags zurückmelden, nicht beheben. **Lücke:** Rundblick kennt keinen Meldeweg für Funde außer „Vorschlag:“ und „fertig“ (Erstes Wort, Befehl offen); Liste ohne Feld „seit“.
- R3 (getestete Builds nicht auf `main`, Lauf rot): wie R2; **Lücke:** wer getestete Builds nach `main` bringt, sagt kein geladener Text; kein Meldeweg für roten Lauf.

## Fachkraft (W1–W5; ohne Auftrag gespielt, Feld „Zurück“ fehlte also)

- Alle: Meldeweg nur aus dem Werkzeug erschlossen (`vorgang.py rueckmeldung NR "<Wort> …"`); **Lücke:** Sockel/Profile nennen weder Befehl noch Liste der ersten Wörter (gedacht: Feld „Zurück“ des Auftrags – im nächsten Lauf mit Muster-Auftrag spielen).
- W1 (17 fremde Dateien bereitgestellt): nimmt Fremdes aus der Bereitstellung, Kerntests, Commit nur eigener, „Hinweis“ für den Fund. **Lücken:** kein Text „Commit nur eigene Dateien“; Sockel 7 „alles pushen“ mehrdeutig; angefangener Merge nicht geregelt.
- W2 (Prüfbild mit Fehler): behebt, alt gegen neu, Bildregeln, „fertig“. **Lücke:** Probelauf-Grenze 1 (`probelauf.py`) in keinem Text; Bildweg zum Chef offen.
- W3 (Filmlauf abgebrochen): kein zweiter Lauf auf Vermutung, „steckt fest“ oder „Frage“. **Lücken:** Grenze 1 Lauf nicht im Text; welches Wort.
- W4 (Bild ohne neues Modell): kein Lauf vor dem Bau, sonst „Frage“. **Lücke:** wer Modelle baut (blender348, Kaufdateien), zählt Modellbau als Probelauf?
- W5 (Kaufdateien): `add_repo bornim-kaufmodelle` selbst, bei Verweigerung „Frage“ mit Wortlaut; kein anderer Weg. **Lücken:** wer `add_repo` aufruft und Weg Kaufdatei → Build stehen nicht im Profil.

## Leitung (L1–L4)

- L1: legt nach einer Prüfrunde vor; **Lücke:** Nachprüfung nach dem Einarbeiten nicht ausdrücklich verlangt (Kern Leitung: Pflicht nur „vor der Vorlage“) – gegen Chef 21.11., 21:37.
- L2: übernimmt „Kapitel 1/Oberste Direktive“ nicht, Maßstab oberstes Ziel, „Frage:“ nach Quelle – gut.
- L3 (760 Filmlauf): findet im Archiv „ruht“ und t300.11, „Nein:“ – gut. **Lücken:** Lauffreigabe durch Sokrates steht nur in `probelauf.py`; Rückweg zur Werkstatt.
- L4 („1535, ein Lauf frei“): Archiv oben mit „Lauf frei“ im Kopf, `vorgang.py chefwort` – gut. **Lücke:** „Eingang des Büros“ ohne Befehl (L-O1, Einbau offen).

## Disponent (D1–D5)

- Werkzeugabgleich: Guthabenstufe 80/95/100 % gibt `lauf.py` nicht aus (nur `--nur-muss`); Folge in `uebergabe.py offen` anders (1796); `vorgang.py neu` ohne Feld „Profil“; vor `tools/1727-SCHARF` heißen Disponent/Prüfer im Werkzeug Ford/Diogenes.
- D1 (Nachtstopp gegen 1784 A): umgeht nicht, Protokollzeile, Vorgang Werkzeug, Zeile an Sokrates – gut (wie Ford 22:28).
- D2 („steckt fest“): Zeile an Sokrates, START – gut; **Lücke:** woher die Vorgangsnummer.
- D3 (Werkzeug „fertig“): **Widerspruch** Profil „erst `main`, dann Prüfer“ gegen Werkzeug (fertig mit Commit immer an Prüfer); wer den Zweig nach `main` bringt, sagt kein Text.
- D4 (Chefwort „nicht zu viel laufen“): trägt wörtlich ein, Zeile an Sokrates; startet die Kür trotzdem nach Werkzeug – **Fehler gegen Soll wahrscheinlich**: Chefwort übersteuert die Stufe nicht im Text.
- D5 (zwei „Frage“ an Sokrates, nachts): START Sokrates, beide in einer Sitzung – gut; **Lücke:** ab wann „Betrieb steht“.

## Arbeitsplaner (A1–A5)

- **Fehler am Werkzeug nachgestellt:** Kern nennt Feld 6 „Prüfart“, `auftrag.py` verlangt „Prüfart und Prüfe vor dem Senden“ – Auftrag nach Kern wird abgelehnt. Feld 4 „Pfad des Profils“: Profilpfade kennt der Arbeitsplaner nicht. Annehmen der offenen Zeile vor der Arbeit nicht geregelt.
- A1 (Systemlösung Griff): Chefwort wörtlich, Auftrag mit Systemfrage, Nachstellauftrag bei unbekannter Ursache – gut; Feld 7 nennt „Auftrag steht“/„abgebrochen“ (Werkzeug erkennt sie nicht, 1797).
- A2 („nix zu erkennen“): Nein des Chefs unter „Bisher“, Prüfart Bild, sonst „Frage“ – gut.
- A3 (Prüfpunkte „Handy“ fürs Standbild): stellt auf Bild um, Ja-Nein-Fragen – gut; **Lücke:** wem die Build-Prüfliste gehört.
- A4 (👎 ohne Wort): „Frage“ statt Auftrag – gut; **Lücke:** 👎 = falsch steht nur in `reaktionen.py`.
- A5 (verstümmelte Spracherkennung): nicht umdeuten, „Frage“ – gut.

## Nächste Schritte (Übergabe 23:17)

Ausziehen: Ladetexte nach Messregel (Codeblock bzw. bis erstes „##“; Sockel = erster Codeblock im Gesamtbild, Kern Leitung = letzter Codeblock in 2.1) in den Scratchpad; je Gruppe ein frischer Helfer nur mit Ladetexten + Werkzeughilfe, Fälle nur Spalte „Eingang“. Dann Bewertung gegen Soll hier; Fachkraft mit Muster-Auftrag (Feld „Zurück“) wiederholen; Ketten K1–K3 spielen. Bekannte Fehler aus Lauf 1: Feld 6 gegen `auftrag.py`; Kern Leitung ohne Nachprüfung nach Einarbeiten (Gespräch 10:00); Disponent D3, D4.

## Prüfer und Tester (P1–P7, T1–T2; kam 23:17 noch an)

- Werkzeug heute: Vorgangsdateien fehlen (nur `1789.md`) → Macher unbekannt → Rückläufer gehen an den Disponenten; Rolle ohne Sitzung bekommt keinen WECKER, ohne Hinweis; `--sitzung` fehlt im Profil (Absender „unbekannt“); Chef-Neins stehen in Archiv/Vorrat, nicht in Vorgangsdateien → zählen nicht.
- P1 (fertig ohne Commit): „nein“ + „Hinweis“ – gut; **Lücke:** Wort für „kein Commit“ (nein/Beleg fehlt).
- P2 (Prüffrage „kürzer?“): „nein, Auftrag“ bei Frage am Ziel vorbei – gut; **Lücke:** Glanz an Neuem Mangel oder Hinweis.
- P3 (Testbitte gegenlesen): **Lücke:** Prüfer kennt kein „Testbitte gegenlesen“, keine Nummer für Buildpunkte.
- P4/P7 (ruhende Vorgänge 431, 760): prüft, meldet Ruhen als „Hinweis“ – gut; **Lücke:** fehlt Auftrag → kein Wort (Sockel 3 „Frage“ gegen Kern „statt Frage …“).
- P5 (Vermerk „nur Gang zählt“, Tusche fehlt): prüft Geändertes, Tusche als Hinweis – gut.
- P6 (Chef-Nein, dann Prüfer-Nein): „nein, steckt fest“ → genau eine Zeile an Sokrates – **besteht**; **Lücke:** Macher erfährt nichts; woher die Handwerksregel.
- T1 (Schalter „Schnell“): Testhilfen aus, Zustand im Beleg – **besteht**; „Befunde:“ geht nirgends hin (1795).
- T2 (Bildrate nebenbei): **Lücke:** kein Maß für Bildrate beim Tester; Nebenfund Befund oder Hinweis.

## Noch ausstehend

Prüfer und Tester (P1–P7, T1–T2): mit denselben Ladetexten neu spielen lassen (Auszug: `python3` nach Messregel aus den Dateien, Fälle nur Spalte „Eingang“), dann alles gegen Soll bewerten.
