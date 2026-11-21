# 1727d · Fünf Lücken im schon Abgenommenen so schließen?
Sokrates · 21.11., 21:19 · 7 Firma · aus 1727, Raster Ein- und Ausgang (`ein-ausgang.md` L-O1, L-S2, L-U10, L-U15, L-T6)
Kurz: Fünf Stellen in abgenommenen Texten (3.3, Profil Technik, Chefrunde, Eingang) führen ins Leere; je ein Satz schließt sie.
Beim Chef, weil: Rollen und Accounts (Profile, Übergabe zwischen Rollen); ändert Abgenommenes (Archiv 20.11., 16:49 „Abgenommenes nur nach Gespräch“; 3.3 Archiv 21.11., 10:11; Profil Technik 21.11., 15:15)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/ein-ausgang.md`:53, :58, :67, :70, :74; `1727-gesamtbild.md` 2.2, 3.3 (:370–373)

**Frage:** Das Raster hat fünf tote Enden in Abgenommenem gefunden. Je eine Antwort, A heißt Vorschlag:
1. **L-S2 Wiederwecken (3.3):** Frist abgelaufen, Empfänger `idle` → Zeile offen, aber ohne Zahl. Vorschlag: ein Neustart, beim zweiten Mal „steckt fest“ (wie die Höchstdauer, gebaut, noch ohne Wert, `lauf.py`:631–634); gilt ebenso für „abgebrochen“ (L-U8, `ein-ausgang.md`:65).
2. **L-O1 Eingang ohne Ort:** „über den Eingang des Büros“, aber `ARBEIT-BETRIEB.md` fällt. Vorschlag (wie `ein-ausgang.md`:74): Sokrates legt es mit `vorgang.py neu` an und weckt den Disponenten.
3. **L-U15 „gut“ aus fremder Sitzung:** geht laut 3.3 an den Arbeitsplaner, Profil Technik erwartet den Disponenten. Vorschlag: einheitlich an den Disponenten, der den Build-Macher startet.
4. **L-T6 Profil Technik „ans Team zurück“:** Teams fallen weg. Vorschlag: zurück an die Fachkraft des Vorgangs über eine Übergabezeile; Fund mit Mangel beim Bereich statt beim Besitzer.
5. **L-U10 Profil Chefrunde (2.2) nach altem Stand:** Vorschlag: „Rückbau beim Besitzer“ → „beim Bereich über den Disponenten“.

**Votum:** „1727d A“: alle fünf wie vorgeschlagen (Einzelnes mit „1727d 3 B“ abwählbar).

**Berührt:** 3.3, Profil Technik F12, Profil Chefrunde, Kern Büro (1727, Sokrates); Größe zusammen etwa +250 Byte Ladetext, je Text wird sie beim Einarbeiten genannt.

**Begründung:** ohne diese Sätze bleiben Zeilen liegen (Chef 20.11., 22:17 „dürfen nicht durchrutschen“).

**Sachverhalt:**
- Alle fünf vom Raster belegt (`ein-ausgang.md` an den genannten Zeilen); 1 entspricht dem alten Ablauf AB:12, den 3.3 F2 nicht übernahm.

**Auswertung:**
- **A (Empfehlung):** fünf Sätze, kein neues Werkzeug außer `vorgang.py`-Zeilen, die 1739 ohnehin baut.
- **B:** einzeln im Gespräch.
- **Stärkstes Gegenargument gegen A:** mehrere Änderungen an Abgenommenem in einem Wort; der Chef wollte Kerne nicht aufblähen. Entkräftung: jede Änderung ist ein Satz, Größe wird genannt, einzeln abwählbar.

**Folgerungen:** A: Sokrates arbeitet die Sätze ein (Tabelle 0, Größe vorher/nachher); Werkzeugteil in 1739 (Spike).

Antwort: …
