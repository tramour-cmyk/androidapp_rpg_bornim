# 1727, Prozessprüfung: läuft der Ablauf, gibt es Schleifen ohne Ausgang? (21.11., 14:30)

Auftrag Chef 21.11., 14:28: „prüft mal bitte du und ein Gegenprüfer nochmal den gesamten Prozess, ob der läuft oder nicht. Mit unseren letzten Feststellungen und Fassungen jeweils. Ob der Workflow überhaupt hinhauen kann oder ob wir wieder irgendwelche Schleifen drin haben, die sich nicht mehr auflösen.“

Grundlage: 3.3 Fassung 2, Büro-Gegenüberstellung Fassung 3, Kern Abnahme 6.2, Kern Arbeitsplaner 4.1 Fassung 2, Lehrenbuch Fassung 7 mit Tabelle Fassung 3, Archiv bis 14:19.

## Eigene Prüfung Sokrates (unabhängig vom Gegenprüfer, vor dessen Bericht)

1. **Schleife ohne Ausgang „steckt fest“.** Profil Prüfer: „Meldest du ‚nein‘ und steht unter ‚Bisher‘ schon ein ‚nein‘ … dazu ‚steckt fest‘“ (Gesamtbild 6.2, Meldung). Nach meinem Nachstellauftrag steht das alte Nein weiter unter „Bisher“; jedes weitere Nein meldet wieder „steckt fest“ an Sokrates. Kein Text sagt, wann es zum Chef geht oder ruht.
2. **Schleife ohne Obergrenze „nein, Auftrag“.** Zählt „nicht als Runde“ (6.2); Prüfer und Arbeitsplaner können beliebig oft hin und her. Die Laufbremse fehlt (Gesamtbild 7: „nicht gebaut“; Ersatz nur Freigabe ab 40 $).
3. **Hänger Sokrates außerhalb des Gesprächs.** „Leitung im Gespräch“ (3.3 Nr. 3); an Sokrates gehen „steckt fest“, „Frage“, „wirkt nein“, „nicht gefunden“, rohe Zeilen älter als eine Woche. Heute startet `lauf.py` Sokrates nur für Chefsache-Dateien ohne Stellungnahme (`LISTE-BETRIEB.md` 41). Ist der Chef nicht da, bleibt das liegen.
4. **Hänger Quittung.** „solange er `working` ist, wird gewartet“ (3.3 F2 Nr. 3): hängt eine Sitzung im Zustand `working`, wartet die Übergabe ohne Ende; die Fristen 14.2 als Notbremse sind nicht gebaut.
5. **Lücke nach „gut“.** Merge, Build, Testbitte trägt „Profil Technik“, das nicht geschrieben ist (Gegenüberstellung, Zeile Fertig; Reihenfolge Schritt 2 zuerst). Ohne es endet Fall „neuer Auftrag“ beim „gut“ des Chefs.
6. **Widerspruch Tester-Befund mit Nummer.** Profil Tester: „das Büro legt je Befund ohne Nummer einen Vorgang an“; mit Nummer offen. Gegenüberstellung: an den Arbeitsplaner als Rückläufer.

## Gegenprüfer (frisch, 14:31, Stand `c26a4ab47`, zehn Fälle durchgespielt)

Urteil: **läuft mit Änderungen, für den Betrieb, nicht schon heute Abend.** Schleifen und Hänger nach Schwere:
1. „nein, Auftrag“ ohne Zähler und Ausgang (= meine 2).
2. „steckt fest“ ohne Grenze (= meine 1).
3. Sokrates als Empfänger ohne Starter; `lauf.py` startet Sokrates heute „nie“ aus dem Vorrat (Z. 56), nur für Stellungnahmen (Z. 1077) (= meine 3).
4. **Chefwort in fremder Sitzung ohne Träger:** nur in 3.3 Nr. 7; Kern Büro schmal schiebt es „ins Werkzeug“, weder Sockel noch Bauliste noch Haken tragen es (neu).
5. Warten auf `working` ohne Ende; Übernahmeregel mit „ersetzt 1–7“ weggefallen; Frist ohne Wert; „Nachfolger:“ liest `lauf.py` aus den Vorräten, die wegfallen (= meine 4, erweitert).
6. Build, Merge, `main` ohne Text, Profil Technik fehlt (= meine 5).
7. Werkzeuge der Bauliste fast alle nicht gebaut; `vorgang.py` kennt keine Übergabe; **1760 läuft nicht** (startbar ab 20:00), `reihenfolge.md` behauptet „läuft schon“ (neu).
8. **Termin:** Archiv 11:17 „heute ab 20:00 umstellen“ gegen Reihenfolge „Umstellung erst, wenn Falltest bestanden und jedes Werkzeug grün“; geht nur, wenn 20:00 Beginn der Arbeit heißt (neu).
9. Kleineres: Kern Arbeitsplaner meldet noch „an die Sitzung, die dich gestartet hat“; Nachstellen nach erstem Nein doppelt geregelt (Fachkraft selbst / Nachstellauftrag); Fund und „Systemlösung?“ erzeugen zwei Aufträge zu einem Vorgang; Eingang ohne Ort; Fachkraft nach „steckt fest“ gebunden oder frei: unklar; Tester-Befunde halten Testbitte auf: unklar; Guthaben „knapp“ ohne Schwelle (meine 6 dort als F9).

Änderungen des Gegenprüfers: (1) Obergrenze je Vorgang über alle Arten, etwa zweites „nein, Auftrag“ oder dritter abgelehnter Auftrag → „ruht, beim Chef“ mit Chefsache-Datei; (2) „steckt fest“ einmal je Vorgang an Sokrates, danach an den Chef; (3) Disponent startet Sokrates bei „steckt fest“, „Frage“, „wirkt nein“, wenn keine Sitzung läuft (Zeile in `lauf.py`); (4) Frist mit Wert und Höchstdauer auch bei `working`, Übernahme aus der Vorgangsdatei zurück in 3.3, „Nachfolger:“ über `vorgang.py`; (5) Chefwort in fremder Sitzung: Haken, der Chefnachrichten an `vorgang.py` gibt, in die Bauliste; (6) Profil Technik und Profil Disponent vor dem Falltest; (7) Kern Arbeitsplaner nach 3.3 Nr. 8, Fund und „Systemlösung?“ zu einem Auftrag; (8) 20:00 = Beginn der Arbeit, Betrieb erst umschalten, wenn 1760 und Bauliste grün.

## Abgleich, mein Wort

Beide fanden unabhängig dieselben vier schweren Punkte (Schleifen 1 und 2, Sokrates ohne Starter, Hänger `working`, Profil Technik). Der Gegenprüfer fand zusätzlich: Chefwort in fremder Sitzung, 1760 läuft nicht, Termin, Kleineres: **stimmt** (selbst nachgesehen: 1760 startbar ab 20:00, Prüfer-Meldung 6.2, `lauf.py` Z. 56; Rest nach Beleg des Prüfers); `reihenfolge.md` berichtigt. Seine acht Änderungen: **stimmt**; 1, 2, 3, 5 legen etwas fest und gehen als Frage an den Chef, 4, 6, 7 sind Schreibarbeit in Schritt 2, 8 Klarstellung. Gegen (5) als Satz im Sockel spricht der volle Sockel (1.110 von 1.200 Byte): Haken.
