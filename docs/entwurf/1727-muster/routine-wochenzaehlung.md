# 1727, Routine Wochenzählung (Gesamtbild 6d; Fassung 3, Perikles 21.11., 20:35, nach Gegenprüfung 20:18 und Nachprüfung Sokrates 20:27)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O7 und legt L-T5 als Frage vor. Fassung 1: Gesamtbild 6d (Sokrates 20.11., 09:40, Chef 09:33 „Ja“ zum Schreiben). **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung zählt Diogenes nach `LISTE-PRUEFUNG.md` „Wochenzählung“.

Lädt: Sockel + dieser Auftrag, ohne Gruppe und Kern.

Quellen: Gesamtbild 6d, 4.4 Zeilen Perikles und Diogenes; VA 20.11., 09:45 (drei Kostenteile, Qualitätskosten), 10:27 (Systemrunde fällt, Wochenzählung trägt mit), 19.11., 17:44 (Wochenziel fällt); `LISTE-PRUEFUNG.md` „Wochenzählung“ (heutige Zahlen und Quellen); `ein-ausgang.md` L-T5, L-O7.

## Text (Änderungen gegen Fassung 1 unter dem Text)

```markdown
Ziel: die Kennzahlen der Woche zählen, damit die Leitung sieht, ob die Firma besser wird (gemeinsames Maß: was der Chef als Erster findet). Du zählst, du bewertest nicht.

Zähle für die Woche Mo 0 Uhr bis So 24 Uhr, je Zahl mit Quelle; fehlt eine, schreib „fehlt“ und warum:
1. Erstfunde des Chefs: je Build und je Woche, je Profil der Werkstatt, das die Arbeit machte.
2. Wiederholungen: Läufe bis „abgenommen“ je Auftrag; Anteil der Aufträge mit mehr als einem Lauf, je Profil.
3. Rückgaben: Anteil „nein“ des Prüfers je Profil; über 20 % als Hinweis „Auftrag oder Profil nachbessern“.
4. Liegezeit: Median der Zeit je Übergabe (Ziel etwa 5 Minuten); Fälle über 6 h, obwohl gesehen.
5. Bremsen: Aufträge über Laufbremse oder Höchstdauer.
6. Guthaben: Verbrauch der Woche in drei Teilen nach Bereich: Spiel (E, G), Qualität (Q), Verwaltung (B, M); dazu Prüfen (Abnahme) gegen Nacharbeit (Läufe nach „nein“ und nach Erstfunden des Chefs).
7. Fortschritt: Abnahmeliste „ganze Punkte x von n“ mit Teilhaken; Stand je Themenblock.
8. Testrunden des Chefs; Funde des Testers vor der Testbitte gegen Erstfunde des Chefs danach.
9. Leitung: Entscheide von Sokrates, davon vom Chef zurückgedreht.
10. Rundblick: Vorschläge, angenommen, umgesetzt (seit Beginn).

Dazu: jeden Vorgang im Bereich B auf „gebaut“, der noch nicht mit `greift` geschlossen ist, prüfen, ob er greift (greift nicht → Befund); Stichprobe der Vorlagen an den Chef (Fassungsblatt, Fehlerrunden, Wortlaut, Vorgabe; 373); höchstens einen Vorschlag für „Bekannte Fehler“ („nie X, stattdessen Y“) aus Wiederholungen.

Ergebnis: neue Spalte in der Tabelle oben in `docs/PRUEFBERICHT.md`, eine Zeile per Telegram (lautlos); jeden Befund mit Beleg ans Büro. Wird dieselbe Zahl zwei Wochen hintereinander schlechter, schreibst du die Zeile „zwei Wochen schlechter: <Zahl>“ ans Büro; das Büro gibt sie an Sokrates.
```

**Geändert gegen Fassung 1:** (a) „bewerten tut Sokrates“ aus dem Text: die Routine braucht es nicht zu wissen, der Weg steht im letzten Satz. (b) Quellenangaben in Nr. 1 (Vorgänge „Von Chef … Fund“, Testrückmeldungen) gestrichen: die Vorgangsdatei markiert Funde des Chefs (7.1), dann gibt es eine Quelle; bis dahin „fehlt“. (c) „greift“ nur für noch nicht mit `greift` Geschlossenes (Gegenprüfung 20:18, Befund 16); Stichprobe 373 aufgenommen (4.4, G:490; Befund 15). (d) Telegram lautlos (nichts für den Chef zu tun). (e) „zwei Wochen schlechter“ geht ans Büro statt „die Vorlage schreibt Sokrates“: wer Sokrates weckt, stand nicht (L-T5). (f) Gestrichen aus Fassung 1 (Liste Sokrates 20:27): „Regeln wie bisher, 1463“, „nicht nach Sitzung“, „Qualitätskosten:“, „das legt den Vorgang an“; Nr. 6 trägt die Qualitätskosten, der letzte Satz den Weg ans Büro.

Größe Text: 1.939 Byte.

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Wochenzählung** | montags 8 Uhr: `lauf.py` gibt die Startzeile aus, der Disponent startet (wie heute `startbar.py` den Wochentermin für Diogenes anlegt, 719 A) | Vorgangsliste, Vorgangsdateien, `kostenbericht.py`, Abnahmeliste, Archiv, GitHub | Spalte in `PRUEFBERICHT.md` gepusht; Sitzung endet | eine Zeile Telegram, lautlos | Büro (Befunde, „zwei Wochen schlechter“) → Sokrates | L-T5 geschlossen, wenn Frage 1 entschieden; offen: Quellen für 2–5 entstehen erst mit Vorgangsdatei und Auftragsfeldern (7.1) |

## Offen, Fragen

1. **Chefsache (ändert C, VA 21.11., 14:37):** „zwei Wochen schlechter“ als vierter Grund, aus dem der Disponent Sokrates startet. Sonst liest Sokrates die Spalte erst im nächsten Gespräch mit dem Chef (Vorschlag Sokrates, L-T5). Mein Votum: vierter Grund, weil sonst niemand bewertet, solange der Chef nicht fragt. Gegenargument: mehr Starts der teuersten Sitzung; dagegen höchstens einer je Woche.
2. **Starter (L-O7):** `lauf.py` statt eigener GitHub-Zeitplan, weil der Disponent alle Starts hält (Startsperre, 3.3 F2 Nr. 5) und `lauf.py` Montag 8 Uhr heute schon kennt (`startbar.py`, 719 A).
3. **Wer trägt „Bekannte Fehler“ ein?** 4.4: Sokrates (statt Perikles). Kommt mit Frage 1 zu ihm.
4. **Zahl 4 Liegezeit** misst laut 4.4 das Werkzeug (G:490); die Routine übernimmt die Zahl. Quellen heute auch Vorgangsliste, `meldungen.tsv`, Werkzeugwarnungen (`LISTE-PRUEFUNG.md`:22–26).
5. **Befund ans Büro** heißt: `tools/vorgang.py neu` mit Bereich und Beleg, Absender „Wochenzählung“, dann Wecker an den Disponenten (L-O1 bis zum Ort des Eingangs).

## Nachprüfung Sokrates 20:27, mein Wort

Kopf „ungeprüft“ weg: **stimmt** · „fett markiert“ weg: **stimmt** · Streichungen nennen: **stimmt**, (f) · Größe: **stimmt**.

## Gegenprüfung 20:18, mein Wort

15 Stichprobe 373 fehlte: **stimmt**, aufgenommen · 16 (c) verliert Fälle: **stimmt**, berichtigt · 17 „zwei Wochen schlechter“ ins Leere, Liegezeit: **stimmt**, hängt an Sammelfrage C (Profil Disponent Frage 1), Liegezeit Werkzeug · 14 Weg ans Büro: **stimmt**, Frage 5.

## Stärkstes Gegenargument

Zehn Zahlen, von denen vier (2–5) bis zum Bau der Auftragsfelder „fehlt“ zeigen; die Routine kostet jede Woche eine Sitzung für eine halbleere Spalte. **Dagegen:** 1, 6, 7, 8, 9 gibt es heute schon (Diogenes zählt sie); die leeren zeigen, was 7.1 noch bauen muss. Maß: nach vier Wochen Anteil „fehlt“ unter 20 %, sonst Zahlen streichen statt weiterzählen.
