# 654 · Mitdenken vor dem Bauen · Sokrates · 08.11., 14:4x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-VORGAENGE-ARCHIV.md

**Anlass (Chef 14:39, zu 653):** „Wieso muss jetzt ich da drauf kommen … Dafür seid ihr doch da … so viel Zeit verschwendet und so viel Geld … Wenn ihr vorher mal auch sagen würdet, ja, hey, das können wir anders lösen. Das kann man berechnen … Warum kommt ihr nicht mit sowas um die Ecke? … Ihr seid doch dafür da, um mitzudenken. Nicht nur stumpf was umzusetzen.“

**Befund:** Heute dreimal dasselbe Muster: Gegenstandskatalog (644), Figurenkatalog (649), Halt je Modell (653) kamen von dir, nicht von uns. Allein „Schild“ steht in 17 Vorgängen mit zusammen etwa 530 $ (grob, Kostenspalte). **Ursache:** jede Rolle arbeitet Vorgang für Vorgang am gemeldeten Fehler; belohnt wird das Schließen der Zeile, nicht die Frage, ob dieselbe Art Fehler wiederkommt. Keine Rolle hat den Auftrag, vor dem Bauen nach der grundsätzlichen Lösung zu fragen; ich prüfe nur, was man mir vorlegt; das „stärkste Gegenargument“ prüfen wir gegen Empfehlungen, nie gegen den Lösungsweg selbst.

**Frage:** Drei Schritte, damit wir mitdenken, bevor du es tust?
1. **Systemfrage vor jedem Bau** (alle bauenden Rollen): vor dem ersten Commit eines Vorgangs eine Zeile „Kommt das wieder? (anderes Volk, andere Waffe, andere Figur, anderer Schirm)“. Ja → zuerst die einmalige Lösung vorschlagen (Datei in der Chefsache), erst dann bauen. Ersetzt die Regel „Vergleich mit der alten Fassung nur für berührte Schirme“ nicht, sondern die bisherige stille Annahme „Fehler an der Stelle beheben“ (Regelbilanz: dafür streiche ich in `ROLLE-ENTWICKLUNG.md` die Einzelfall-Prüfliste, die die Systemfrage ersetzt).
2. **Wiederholungswächter im Werkzeug:** `vorgang.py neu` meldet, wenn ein neuer Vorgang ein Stichwort mit zwei oder mehr früheren teilt (Schild, Schrift, Kasten, Kamera …), und legt automatisch eine Zeile „Systemlösung?“ für mich an.
3. **Wöchentliche Systemrunde** (ich, montags, mit den Kosten aus 651): die zehn teuersten Vorgänge der Woche; je Vorgang: hätte man das einmal grundsätzlich lösen können? Was davon kommt wieder? Ergebnis als Vorschläge an dich, höchstens drei.

**Votum Sokrates: ja.**

## Auswertung
- **Stärkstes Gegenargument:** mehr Vorab-Denken kostet Zeit und Token bei jedem Vorgang, und nicht jede Kleinigkeit braucht eine Grundsatzlösung; Gefahr, dass alles zur Chefsache wird. **Antwort:** die Systemfrage ist eine Zeile; nur bei „ja, kommt wieder“ folgt ein Vorschlag. 653 allein hätte mehrere Messläufe an 499 erspart.
- Mein eigener Anteil: beim Gegenstandskatalog (644) habe ich Spalten je Stück vorgeschlagen, ohne an Griffpunkt und Halterung zu denken, obwohl 499 seit Tagen lief. Ich reagiere auf Vorlagen statt die laufenden Vorgänge nach Mustern abzusuchen; Schritt 3 macht genau das zu meiner Pflicht.

## Folgerungen
„654 ja“: Schritt 1 in `ROLLE-ENTWICKLUNG.md` und die Prüfliste (Perikles), Schritt 2 im Werkzeug (Perikles), Schritt 3 in `ROLLE-BERATUNG.md` (ich), erste Runde Montag 09.11. mit den Zahlen aus 651.
