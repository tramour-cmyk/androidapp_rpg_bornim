# Wochenzählung

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

Dazu: jeden Entscheid der Woche im `docs/VORGANGSARCHIV.md` prüfen, ob er noch in Kern, Profil oder Werkzeug steht und greift (fehlt oder greift nicht → Befund); jeden Vorgang im Bereich B auf „gebaut“, der noch nicht mit `greift` geschlossen ist, prüfen, ob er greift (greift nicht → Befund); Stichprobe der Vorlagen an den Chef (Fassungsblatt, Fehlerrunden, Wortlaut, Vorgabe; 373); höchstens einen Vorschlag für „Bekannte Fehler“ („nie X, stattdessen Y“) aus Wiederholungen.

Ergebnis: neue Spalte in der Tabelle oben in `docs/PRUEFBERICHT.md`, eine Zeile per Telegram (lautlos); jeden Befund mit Beleg ans Büro. Wird dieselbe Zahl zwei Wochen hintereinander schlechter, schreibst du die Zeile „zwei Wochen schlechter: <Zahl>“ ans Büro; das Büro gibt sie an Sokrates.

## Herkunft

Angelegt von `tools/ladesumme.py --anlegen` (1928) aus `docs/entwurf/1727-muster/routine-wochenzaehlung.md|## Text`; dort ändern und neu anlegen.
