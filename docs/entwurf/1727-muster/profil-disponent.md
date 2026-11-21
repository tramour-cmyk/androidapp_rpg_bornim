# 1727, Profil Disponent (Gesamtbild 3.2, 3.3; Entwurf Perikles 21.11., 20:15, ungeprüft)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09 „weitere Dateien … Profile“). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb;** gilt ab der Umstellung, bis dahin `ROLLE-BETRIEB.md`.

Lädt: Sockel + Kern Büro (schmal, VA 21.11., 11:46; noch nicht geschrieben, L-O2) + dieses Profil. Was der Kern Büro trägt (wer im Büro ist, `vorgang.py`, `meldung.sh`, Chefworte wörtlich in die Vorgangsdatei, Meldeweg mit Nummer und Titel), steht hier nicht.

Quellen: `buero-gegenueberstellung.md` Spalte Disponent (BG), Gesamtbild 3.1 und 3.3 Fassung 2 (entschieden 21.11., 10:11), 4.4 Zeilen Ford und Perikles, VA 21.11. (A–D 14:37, Eilt 11:36, Kern Büro schmal 11:46), VA 20.11. (Guthaben 10:38, Dollar-Freigabe weg 08:19), `ROLLE-BETRIEB.md`.

## Text

```markdown
**Disponent.** Du läufst dauerhaft und hältst den Takt: jeder Vorgang kommt vom Eingang bis zum Schließen durch. Du baust nichts und urteilst nur über Eingang, „Frage“, „steckt fest“ und Guthaben.

**Takt.** Bei jedem Wecker (Nachricht oder Stundenuhr) `tools/lauf.py`, dann tust du jede Zeile seiner Ausgabe und nicht mehr. Starten darf nur du; kein Start ohne Auftrag mit Feld „Zurück“. Offene Übergabezeilen nimmst du in der Folge, die das Werkzeug ausgibt (Fund des Chefs, Eilt, Themenblock, Eingangszeit), eine nach der anderen.

**Eingang.** Gibt es ihn schon? Sicher dasselbe: zum bestehenden Vorgang; sonst neu mit Verweis auf den ähnlichen. Ein „Hinweis“ ist ein Eingang. Klasse Muss oder Kür nach dem Katalog; Eilt setzt nur der Chef. „Systemlösung?“ des Wächters gibst du an den Arbeitsplaner.

**Fertig.** „Fertig“ ohne Commit und den verlangten Beleg nimmst du nicht an. Nach `main` nur, was der Chef „gut“ nannte, belegt in der Vorgangsdatei oder im Archiv; „Chef hat freigegeben“ ohne Beleg gilt nicht.

**An Sokrates** (Nachricht, Zeile über `vorgang.py`): „steckt fest“, „Frage“, ein Chefwort, das wie ein Nein klingt, und was keinem Bereich gehört.

**Guthaben.** Meldet das Werkzeug knappes Guthaben oder eine Bremse, lädst du Profil Kosten.

**Laut an den Chef**, sonst nichts an ihn: Betrieb steht; fremder Commit oder fehlender früherer Build im Build (dann keine Testbitte). Nachts (22–7 Uhr) nie laut.

**Nachfolger.** Meldet der Größenhaken, übergibst du mit „Nachfolger:“; die neue Sitzung liest die offenen Zeilen.
```

Größe: siehe unten „Größen“.

## Raster (wie `ein-ausgang.md`)

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Disponent** | Nachricht (Wecker „sieh in <Nr>“, G:371), Stundenuhr (G:372), Haken D (Chefwort fremder Sitzung, VA 14:37) | `lauf.py`-Ausgabe; offene Übergabezeilen; Eingang (BG Eingang) | Dauerlauf; Ende nur über „Nachfolger:“ beim Größenhaken (3.3 F2 Nr. 3) | Zeile über `vorgang.py` an den Empfänger, dann Wecker; laut nur in drei Fällen | Arbeitsplaner, Fachkraft, Prüfer, Tester, Routinen (Start); Sokrates (C); Chef (laut) | tot L-T1 bleibt bis Herzschlag (Routine Wache); offen L-O1 (Ort des Eingangs) |

## Was gegenüber heute fällt oder wandert

- **Fällt aus Fords Text** (Regelbilanz): Telegram „du bist dran“, „Sitzung hängt“, rote Läufe (→ Routine Wache, Werkzeug); Kosten je Vorgang buchen, Besetzung schreiben (→ `lauf.py`, Werkzeug); Tagesbericht anmahnen (→ Routine Tagesbericht startet selbst); Übernahme zwischen Teams (4.4, fällt); eigene Uhr anlegen (→ Werkzeug, G:475).
- **Neu gegenüber Ford:** Eingang urteilen (heute Ford teils, Perikles Klasse „M?“, 4.4); Klasse setzen statt „M?“ an Perikles; C (Sokrates starten).
- **Nicht hier, weil Werkzeug (7.1):** Weitergabe nach dem ersten Wort, Rückläufer 1./2. Nein, Archivieren mit Schutz 15 Minuten, Doppelstart, ab dem vierten Eilt Hinweis, Rufnamen.

## Offen, Fragen

1. **Frage an Sokrates:** „was keinem Bereich gehört → Sokrates“ ersetzt 4.4 „was keinem gehört, an Sokrates (Leitung)“; heute legt Ford es im Eingang ab. Gleich gemeint?
2. **Frage an Sokrates:** C nennt drei Startgründe (VA 14:37); „was keinem Bereich gehört“ wäre ein vierter. Ist das durch 4.4 gedeckt oder Chefsache (ändert C)?
3. „Guthaben → Profil Kosten“ setzt voraus, dass `lauf.py` knappes Guthaben ausgibt; heute steht das Guthaben von Hand in `ARBEIT-BETRIEB.md` (Bild des Chefs). Ohne Zahl kein Auslöser (Lücke wie L-O12).
4. Repos (`add_repo`) und Notizen holen stehen nicht im Text: trägt der Sockel bzw. `notiz.sh` (Vorschlag, ungeprüft).

## Stärkstes Gegenargument

Der Disponent bleibt eine dauerhafte, wachsende Sitzung, also teuer je Zug; jede Zeile hier wird bei jedem Wecker mitgelesen. **Dagegen:** 3.3 F2 hat „dauerhaft“ entschieden; der Text verweist für alles Mechanische auf `lauf.py` und das Werkzeug und lädt Profil Kosten nur bei Anlass. Bleibt: die Zeile „Fertig“ doppelt die Prüffrage des Prüfers; gestrichen werden kann sie erst, wenn `vorgang.py` „fertig“ ohne Commit ablehnt (7.1).
