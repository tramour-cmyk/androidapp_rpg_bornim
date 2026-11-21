# 1727, Reihenfolge bis zur Umstellung (Entwurf Sokrates 21.11., 10:15)

Anlass: Vorschlag 20.11., 21:41 „Aufräumen → Arbeitsdateien → Profil Technik → Bauliste → Feste Regeln → Falltest“, ohne Wort des Chefs. Maßstab Chef 20.11., 16:50: „Der Falltest kann erst kommen, wenn wir doch die ganzen Rollendateien umgemünzt haben auf Sockel, Kern, Profildateien, respektive dann Arbeitsdateien zum Testen.“ Befunde: `pruefung-20-11-abend.md` (Abend) und `pruefung-20-11.md`.

## Änderung gegen 21:41

„Aufräumen“ als eigener Schritt fällt: das Gesamtbild (150 KB, etwa 81 % Verlauf, Befund 1) aufzuräumen und danach die Arbeitsdateien herauszuziehen, ist doppelte Arbeit. Stattdessen wird das Gesamtbild eingefroren (Verlauf, nur noch Verweise), aufgeräumt wird beim Herausziehen.

## Reihenfolge

1. **Umgemünzt fertig schreiben** (16:50 Schritt 1), im Gesamtbild als letzte Fassungen:
   a. Abgleich `1727-abgleich-rollen.md` je Punkt durchsehen: übernehmen (wohin) oder „fällt“ (16:50, ohne Zwangsziel).
   b. Fehlende Texte: Profil Technik zuerst (Befund 4: Build, Merge, Release ohne Träger), dann Werkzeug, Fremde Inhalte, Spieltext einbauen, Büro-Profile, Routinen Tagesbericht und Wache, Chefrunde.
   c. Feste Regeln mit Ort (Befund 5, Tabelle 0c „bleibt, wo“), Lücken nach Wegfall von Leitbild, Rollen, `CLAUDE.md` (Befund 8), Meldewege je erstes Wort (Befund 10).
   d. Was zu 3.3 folgt (Fassung 2 Nr. 8): Kern Büro, Kern Arbeitsplaner, Kern Abnahme anpassen.
   Je Text Größe vorher/nachher und Ladesumme (16:49); Abgenommenes nur nach Gespräch.
2. **Arbeitsdateien** (16:50 Schritt 2, Befund 1): je Sockel, Kern, Profil eine Datei nur mit gültigem Text; dabei berichtigen: eine Feldliste nur im Werkzeug (Befund 6), keine Doppeltexte (Befund 7), „Fachkraft“ statt „Macher“ (Befund 9), Kleineres (Befund 14). Gesamtbild danach Verlauf; Übersicht der Größen per Skript.
3. **Falltest** (16:50 Schritt 3) auf den Arbeitsdateien: Fälle in `1727-falltest.md` und Übergabe-Vorrat „Zu 1727, ab Sa 21.11., 20:00“; Übergaben zählen wie Prüfung 20.11. (Befund 2), Bremsen auf zwei (Befund 13), Verweisprüfung per grep (Befund 8).
4. **Werkzeuge** (Befund 3, Bauliste 7.1): Spike baut ab Schritt 2 nebenher (1760 läuft schon); die Bauliste wird in Schritt 1 vollständig. Umstellung erst, wenn Falltest bestanden und jedes Werkzeug grün läuft.

## Was offen beim Chef bleibt (eigene Wörter, nicht Teil dieser Reihenfolge)

Kern Arbeitsplaner Fassung 2; Liste „Offen beim Chef“ in `pruefung-20-11-abend.md`.

## Stärkstes Gegenargument

Schritt 1 schreibt weiter ins 150-KB-Gesamtbild, die unzuverlässige Quelle (Befund 1); jeder neue Text muss in Schritt 2 noch einmal angefasst werden. Gegenweg: neue Texte aus Schritt 1 gleich als Arbeitsdatei schreiben, nur die alten in Schritt 2 herausziehen.
