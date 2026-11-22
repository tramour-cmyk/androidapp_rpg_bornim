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

## Bewertung gegen Soll (Sokrates, 21.11., 23:23)

Maß: bestanden = alle Kernpunkte des Solls und das „NICHT“ getroffen; teilweise = NICHT getroffen, ein Kernpunkt fehlt oder ist aus der Zusammenfassung nicht belegt; nicht = NICHT verfehlt oder Kernpunkt falsch; ungültig = Fall falsch aufgesetzt. Grundlage: Zusammenfassung oben (Wortlaut der Helfer nicht gesichert, Lehre: in Lauf 2 Antworten je Fall als Datei sichern).

| Fall | Urteil | Ursache | Maßnahme |
|---|---|---|---|
| L1 | nicht | Kern Leitung verlangt Prüfung nur „vor der Vorlage“, nicht nach jedem Einarbeiten; Größe nicht verlangt | Satz für Kern Leitung (abgenommen): Gespräch 10:00 |
| L2 | teilweise | NICHT getroffen; Archiv mit Datum nicht genannt (nur „Frage“ nach Quelle) | Lauf 2 mit Prüffrage wiederholen |
| L3 | bestanden | – | Lauffreigabe nur in `probelauf.py`: Werkzeug genügt |
| L4 | teilweise | Archiv und Nummer richtig; Zeile an Tom „genau ein Lauf“ nicht belegt; „Eingang des Büros“ ohne Befehl (L-O1) | L-O1 im Gespräch 10:00 |
| D1 | bestanden | – | – |
| D2 | ungültig | „steckt fest“ geht nach 3.3/1727c an Sokrates; Soll erwartet, dass der Disponent fachlich antwortet | Fall als Kette Disponent → Leitung (Leitung verbietet Reset, verlangt Sicherung) |
| D3 | nicht | Profil sagt nicht, wer nach `main` bringt; Werkzeug gibt „fertig“ mit Commit immer an den Prüfer, auch bei Werkzeug | Profil Disponent: wer zusammenführt; Werkzeugvorgang Spike (Weg „Werkzeug fertig“) |
| D4 | nicht | Chefwort übersteuert die Werkzeugstufe im Text nicht | Profil Disponent Guthaben: Chefwort geht vor |
| D5 | bestanden | „Betrieb steht“ ohne Maß | Kern Büro: Maß nennen |
| A1 | bestanden | Feld 7 nennt Wörter, die das Werkzeug nicht kennt (1797) | Kern Arbeitsplaner Feld 7 an Werkzeug |
| A2 | teilweise | Beleg-Bedingungen stehen im Kern; „erst nachstellen“ nicht belegt | Lauf 2 |
| A3 | bestanden | Zählung „unter vier keine APK“ nicht belegt; Besitzer Build-Prüfliste offen | Lauf 2 |
| A4 | bestanden | 👎 = falsch nur in `reaktionen.py` | Kern Büro: 👎/👍 |
| A5 | bestanden | Lesart in Klammern nicht belegt | Lauf 2 |
| A (alle) | nicht | Feld 6 heißt im Kern „Prüfart“, `auftrag.py` verlangt „Prüfart und Prüfe vor dem Senden“: jeder Auftrag nach Kern wird abgelehnt; Profilpfade unbekannt (keine Ablage der Profile festgelegt) | Kern Arbeitsplaner Feld 6 wie Werkzeug; Ablage der Profile in die Bauliste |
| W1–W5 | ungültig | ohne Auftrag gespielt; die Werkstatt kennt nur Sockel und Auftrag | Lauf 2 mit Aufträgen, die ein blinder Arbeitsplaner schreibt (prüft A zugleich) |
| W1 | (Lücke) | „nur eigene Dateien“ steht nirgends; Sockel 7 „alles pushen“ mehrdeutig | Sockel 7 (abgenommen): Gespräch; Werkzeugsperre 1776 |
| W5 | (Lücke) | `add_repo` für Fachkraft in keinem Text | Profil Figur und Prüfbild oder Sockel: Gespräch |
| P1 | ungültig | Eingang ohne Commit; Disponent nimmt „fertig“ ohne Commit nicht an, Prüfer sähe ihn nie | Eingang mit Commit, Lauf 2 |
| P2 | teilweise | Schweben erkannt, aber „nein, Auftrag“ statt „nein“ (Mangel ist bei der Arbeit behebbar) | Profil Prüfer 3: „nein, Auftrag“ nur, wenn die Arbeit den Mangel nicht beheben kann; Lauf 2 |
| P3 | nicht | Testbitte-Gegenlesen kennt kein Text; Handy-Absatz prüft den Weg zur Stelle nicht am Code | Profil Prüfer Handy: Lage und Weg am Code, Stelle nennen |
| P4 | ungültig | ohne Auftrag; Helfer prüfte Ruhen statt Herkunft des Belegs | Lauf 2 mit Auftrag |
| P5 | nicht | Tusche als „Hinweis“ statt „Beleg fehlt“ | Profil Prüfer 2: Beleg ohne Spielansicht mit Signatur = „Beleg fehlt“ |
| P6 | bestanden | Fachkraft erfährt das „steckt fest“ nicht | Werkzeug (Spike) |
| P7 | ungültig | ohne Auftrag (wie P4) | Lauf 2 |
| T1 | bestanden | „Befunde:“ hat kein Ziel im Werkzeug (1795) | – |
| T2 | teilweise | ohne Maß für Bildrate unsicher, ob „Fehler“ | Profil Tester 4: Maß aus der Abnahmeliste, sonst als Fehler mit Messwert |
| R1 | teilweise | Wiederholer gewählt, aber nur als Vorschlag ans Büro; Systemfrage geht nach 1727 (20.11., 10:27) über Wächter → Disponent → Arbeitsplaner | Soll an neue Ordnung: Vorschlag mit Fundzahlen genügt |
| R2, R3 | nicht | Liegengebliebenes („gebaut“ ohne Build über Frist, getestet nicht auf `main`) fängt kein Text: Rundblick schlägt nur vor, Wochenzählung zählt nur, Wache sieht nur Sitzungen | Routine Wache Nr. 7: Vorgang über der Frist seines Stands (14.2) → Wecker an den Disponenten; Fälle zur Wache |

**Zählung Lauf 1:** 31 Fälle: bestanden 9 (L3, D1, D5, A1, A3, A4, A5, P6, T1), teilweise 6 (L2, L4, A2, P2, T2, R1), nicht 7 (L1, D3, D4, P3, P5, R2, R3), ungültig 9 (D2, W1–W5, P1, P4, P7); dazu der Werkzeugfehler Feld 6, der jeden Auftrag trifft. Ketten K1–K3 noch nicht gespielt.

**Pflichtpunkte des Chefs** (Vorrat „ab Sa 20:00“): Wiederholer 1694 (K3), 1535 (K2, P1), 760 (L3, P7), t299 (A3, P3) in Lauf 2 als Ketten mit Liegezeit je Übergabe; Rückläufer nicht durchrutschen (R2/R3 → Wache 7; nach Nachprüfung 1 → `lauf.py` LIEGT, 1799).

## Lauf 2 (21.11., 23:28–23:47), Bewertung Sokrates

Verfahren wie Lauf 1, aber: Ladetexte nach Einarbeitung und Vorschläge; gelesen haben (Ordner um 23:39 überschrieben, Nachprüfung 2 Nr. 1, aus Zitaten und Dateizeiten) Leitung, Disponent, Tester vorher: Disponent F11, Tester F4, V1 Fassung 1; Prüfer und Fachkraft nachher: Prüfer F5, V2 Fassung 2; Arbeitsplaner unklar; und Feld 6 im Kern Arbeitsplaner wie Werkzeug; Fälle nur „Eingang“, neue Fälle für die Ketten (Leitung L5–L10, Disponent D6–D11, Arbeitsplaner A6–A16 schreibt die Aufträge, Werkstatt W6–W8 und Prüfer P8–P9 mit diesen Aufträgen). Antworten im Wortlaut, Fälle und Aufträge: `falltest-lauf2/`. Liegezeit: am Tisch nicht messbar; geprüft wird, ob jede Übergabe sofort eine Zeile und einen Wecker erzeugt.

| Fall | Urteil | Befund | Maßnahme |
|---|---|---|---|
| L1 (V1) | bestanden | neue Runde nach Einarbeiten, Größe vorher/nachher | V1 ins Gespräch |
| L2 | bestanden | Archiv 20.11., 11:45/12:06 als Quelle, Argument neu gefasst | – |
| L3 | bestanden | „nein“ mit 1714, 1605, t300.11; Zeile zurück, Hinweis ans Büro | – |
| L4 | bestanden | Archiv unter 1535, Chefwort über `chefwort` an den Arbeitsplaner | L-O1 „Eingang des Büros“ im Gespräch |
| L5 (D2) | bestanden | kein Reset, Sicherung über `notiz.sh` (1701), Hinweis an Spike | – |
| L6 (K1.1) | bestanden | Antwort „Build 300 freigegeben“ in Worten des Chefs | – |
| L7, L8 (K2.1, K2.8) | bestanden | Funde wörtlich, keine Freigabe für `main` | – |
| L9 (K3.3) | bestanden | Richtung mit Deckel, kein dritter Versuch | – |
| L10 (K3.6) | teilweise | Chefsache richtig, aber ohne Nachprüfung (Text deckt Chefsache nicht) | V1 Fassung 2: „oder in die Chefsache geht“ |
| D1–D5 | bestanden | D2 nur weitergeleitet (richtig nach 1727c); D3 erst mit Stundenuhr bemerkt | D3: `lauf.py` LIEGT (1799) |
| D6, D7 | bestanden | Werkzeugfehler in D7 belegt statt blind verteilt | – |
| D8, D9 | bestanden | D9: drei verschiedene Folgen in Werkzeugen | 1796 |
| D10, D11 (K3.2, K3.5) | bestanden gegen Werkzeug | `lauf.py` gibt nach „steckt fest“ weiter START der Fachkraft; Disponent hält mit `--ohne` an | Werkzeug 1800; Profil Disponent F12 |
| A1–A4 | bestanden | Aufträge mit Bisher, Systemfrage, Prüffragen; A4 „Frage“ | – |
| A5 | teilweise | „Frage“ ohne Lesart [235] | nach Gespräch nicht nötig (NICHT getroffen) |
| A6–A16 | bestanden | 11 Aufträge geprüft gültig, davon A12, A16 als Entwurf; A12 (Aussehen ohne Chefwort), A16 (760 ruht) richtig als Entwurf mit „Frage“ | Werkzeug 1798 (Auftrag oben, archivierte Nummer, Größe in der Vorlage) |
| W1–W7 | bestanden | nur eigene Dateien, erst beheben, Logursache, Modell vor dem Lauf belegt, `add_repo` selbst, Chefwort in der Vorgangsdatei | W4: Weg Kaufmodell → Bauserver nur im Profil Technik |
| W8 (K3.1, K3.4) | nicht | „Frage“ statt „steckt fest“, weil Feld 7 das Wort nicht anbietet: Obergrenze B greift nie | V3 ins Gespräch |
| P1, P2, P5, P6 | bestanden | Urteil am Bild, Schweben trotz Längenfrage, „Beleg fehlt“ trotz Vermerk, „steckt fest“ nach Chef-Nein | – |
| P3 | bestanden | je Punkt mit Codestelle; 299.4 „nein“, weil `vorraete` keinen Umhang gibt (wie Tom 18.11.) | – |
| P4 | teilweise | Herkunft geprüft, aber „nein“ statt „Beleg fehlt“ (Profil Schritt 1) | Profil Prüfer F6 |
| P7 | teilweise | Schritt 1 „nichts weiter prüfen“ verdeckte Angriff 3 „nicht beurteilbar“ | Profil Prüfer F6 |
| P8, P9 | gültig, Fall schief | P9 „Beleg fehlt“, weil der Nachstellauftrag A7 Prüfausgabe verlangt | – |
| T1, T2 | bestanden | Testhilfen aus; Bildrate als gezählter Fehler mit Messwert | Werkzeug 1795 („Befunde:“) |
| R1 | bestanden | Wiederholer gewählt, drei Vorschläge | Routine braucht Titelmarke (1789) für `fertig` ohne Commit |
| R2, R3 (Wache 7) | bestanden | Wache meldet „Liegt“ | nach Nachprüfung 1 in `lauf.py` (1799), Wache F5 ohne Fall 7 |

**Zählung Lauf 2:** 59 Wertungen (L 10, D 11, A 16, W 8, P 9, T 2, R 3): bestanden 52, teilweise 4 (L10, A5, P4, P7), nicht 1 (W8), Fall schief 2 (P8, P9), dazu D10/D11 bestanden nur gegen das Werkzeug. Überholt durch die Berichtigung unten.

**Berichtigung nach Nachprüfung 2 (23:58, `falltest-lauf2/nachpruefung-2.md`), mein Wort: stimmt.** Meine Bewertung war zu milde. Neu gezählt: bestanden 43, teilweise 10 (D3, D4, D5, A1, A3, A7, L10 u. a.), nicht 3 (W8, P7, D9 gegen Werkzeug), Soll überholt 1 (D2), Fall schief 2; „ungültig 0“ zu günstig (W8 ohne Auftragsdatei, D6/D7 ohne vorab festes Soll). Die Ladetexte unter `scratchpad/lt/` wurden um 23:39 während des Laufs überschrieben: Fachkraft und Prüfer lasen V2 Fassung 2 bzw. Prüfer F5, nicht die oben genannten Stände. Kernbefund: „nein, steckt fest“ beim ersten Prüfer-Nein, sobald unter „Bisher“ ein altes Chef-Nein steht (P1, P2, P4, P7), widerspricht K2.5; Soll P6 gegen K2.5 widersprüchlich. Abarbeitung der 13 Befunde: Nachfolger (Übergabe Vorrat Sokrates).

**Urteil am Kettenende (Nachprüfung 2 Nr. 3):** K1 (1694) endet in P8 mit „Beleg fehlt“, nicht beim Chef: teilweise. K2 (1535) bricht an A7 (Nachstellauftrag ohne Bau) und K2.5 (Prüfer-Nein wird „steckt fest“): nicht. K3 (Wiederholer) bricht an W8 („Frage“ statt „steckt fest“): nicht. Dazu L10: Soll K3.6 verlangt „Kosten bisher“, kein Text trägt sie (Kern Leitung nennt keine Kosten); Träger offen, ins Gespräch. P8: darf der Prüfer einen fehlenden Beleg durch eigene Prüfung im Repo ersetzen, und doppelt sich das mit der Vollzugsprüfung des Empfehlers? Ins Gespräch. D1: legt neuen Werkzeugvorgang an, obwohl 1792 denselben Haken trägt (eigene Regel „Gibt es ihn schon?“ verletzt).

**Eingearbeitet nach Nachprüfung 2 (22.11., 07:09), mein Wort je Befund:**

| Nr. | Wort | Maßnahme |
|---|---|---|
| 1 | stimmt | Satz Lauf 2 je Gruppe berichtigt; Lauf 3 mit festem Ordner je Lauf, während des Laufs unverändert |
| 2 | stimmt | D3, D4, D5 teilweise, D9 nicht gegen Werkzeug, D2 Soll überholt; Profil Disponent F14: Folge Eilt, Fund, Themenblock, Eingangszeit gilt auch gegen das Werkzeug |
| 3 | stimmt | A1, A3, A7 teilweise, P7 nicht; Kern: Prüfer zählt für „steckt fest“ nur ein Nein zu diesem Auftrag nach seinem Datum (Profil Prüfer F7), damit geht das erste Prüfer-Nein auf einen Rückläufer an die Fachkraft (K2.5) und P6 ist berichtigt (Soll P6 neu: „nein“ ohne „steckt fest“); A7: V4 Kern Arbeitsplaner Feld 3 ins Gespräch |
| 4 | stimmt | Zählung A6–A16 berichtigt; „ungültig 9 → 0“ gestrichen |
| 5 | stimmt | Profil Disponent :20 Wortlaut Nachprüfung 2 („Prüfer danach“, sonst Zeile an die Fachkraft) |
| 6 | stimmt | :24 „nur Wache, Sokrates und Rückläufer des Chefs; laufende Fachkräfte übergeben“; Werkzeug 1804 (Spike) |
| 7 | stimmt, Einwand zu „Chefwort“ | „offenes ‚steckt fest‘“, Werkzeugfehler als Eingang; „Chefwort“ bleibt (D10/D11), als Offen 6 im Profil |
| 8 | stimmt | LIEGT: „tu, was die Zeile nennt“; Empfänger je Stand als „Zu 1799“ |
| 9 | stimmt | Profil Prüfer: „Beleg fehlt“ und Ende; „nein“ mit Belegmangel = erstes Wort „nein“; drittes „Beleg fehlt“ ins Gespräch |
| 10 | stimmt | Nr. 8 Spiel-Shader, fehlende Tusche = Mangel nach 4; Nr. 9 „Hinweis: Prüffrage fehlt“ wieder eigene Rückmeldung; Nr. 14 V1 mit Ladesumme; Nr. 17 L-O1 entschieden (nur Werkzeugbefehl offen), D5 → 1760, A4 (👎 ohne Wort) und W5 (`add_repo`, 1781) ohne Textwechsel, P6/P1 durch Nr. 3 |
| 11 | stimmt, Einwand zum Deckel | V1 auf `chefsache/entscheiden/` und Ladesumme; Deckel als Frage mit Votum Nein (Chef 21:37); V3 mit stärkstem Gegenargument |
| 12 | stimmt | Wecker an Disponent: 1760 als Rückläufer; Guthabenstufe und Laufsperre: 1804; 1801 mit 1792; Ruhendes (760, 1657): trägt Profil Disponent („ruht“ hält den Start) und Arbeitsplaner (A16 Entwurf mit „Frage“); R2 Zahl in die Wochenzählung: offen bis Umstellung; W4: Arbeitsplaner nennt das Profil in Feld 4 |
| 13 | stimmt | Tester Ladezeit zurück; Wache 949; Kopfzeile Disponent gekürzt, Verlauf in Git |

Byte (Messregel): Disponent 3.642 → 3.761, Ladesumme 5.550; Prüfer 2.481 → 2.730, Ladesumme 5.406; Tester 2.606 → 2.626, Ladesumme 5.302; Wache 949, Ladesumme 2.058; mit V2 je +20.

**Werkzeugfehler aus Lauf 2** (an Spike, ruht bis 07:00): 1798 (Auftrag an Kern angleichen), 1799 (LIEGT), 1800 („steckt fest“ hält keinen Start an, Obergrenze B ungepusht), 1801 (Nachtstopp zählt Sokrates-Starts unter „1763 C“, zu prüfen); bekannt 1795, 1796, 1797. Weiter offen ohne Vorgang: Empfängernamen Disponent/Arbeitsplaner/Prüfer bis `tools/1727-SCHARF` nur in `lauf.py` (`ALT_EMPFAENGER`), nicht in `uebergabe.besetzung`; Gedächtnis `docs/leitung/gedaechtnis.md` fehlt (entsteht mit der Umstellung); Ablage der Profile.
