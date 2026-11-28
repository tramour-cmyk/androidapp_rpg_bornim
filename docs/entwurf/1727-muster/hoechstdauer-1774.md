# 1774, Werte für Höchstdauer je Auftrag und Laufbremse (Fassung 3, Sokrates 21.11., 21:13; Nachprüfung 21:10 eingearbeitet: nur Werte für das Gebaute; Nachprüfung offen)

Anlass: Vorgang 1774 (Spike, aus 1766): Werte für Höchstdauer je Auftrag und Laufbremse; Wert fehlt (L-O17). Entschieden: Laufbremse und Höchstdauer je Auftrag „(14.2.5)“; Dollar-Freigabe ab 40 $ fällt (Archiv 20.11., 08:19; Chef 08:17: Kosten „eher ein virtueller Punkt“, G:481). Laufbremse in der Form: Archiv 19.11., 13:02. Über die Grenze je Auftrag entscheidet Sokrates, im Zweifel billigt der Chef (Archiv 20.11., 08:16). Fristen sind Annahmen bis zur Probewoche (G:367).

**Gebaut (Spike 1766, `19bf8c8d4`):** `lauf.py`:181–184 `HOECHSTDAUER_MIN = {"Mittel": None, "Hoch": None}`, Minuten je Leistungsstufe, reine Wanduhr ab Sitzungsstart oder jüngstem „## Auftrag (TT.MM., HH:MM)“ der Vorgangsdatei (`auftrag_seit` :567); geprüft nur bei laufender Sitzung (working/blocked, :594, :825); ausgenommen Ford, Sokrates, Sonstige (:592); Folge Zeile `HÖCHSTDAUER` an Ford: `interrupt_session`, Rückmeldung „Hinweis“ (erstes Mal), „steckt fest“ (zweites Mal je Vorgang → an Sokrates, 1763 C) (:583–607, Test `laufbremse_test.py`); scharf erst mit `tools/1727-SCHARF`.

**Art:** Vorentscheid Sokrates nur für die zwei Werte im Gebauten (`ROLLE-BERATUNG.md` „Entscheidet selbst“, Einzelheiten von Abläufen); kein neues Maß, kein neues Feld, keine neue Folge, kein Umbau.

## Messung (Helfer 20:57; 7 Tage, 128 archivierte Arbeitssitzungen Tom, Jerry, Spike)

- Wanduhr je Sitzung (created_at → updated_at): Median 88 min, P90 223, Max 605. Lange Sitzungen sind fast nur Warten (zu 286: 605 min, davon 11 min API-Zeit; zu 295: 393/14; zu 297: 400/43). Je Auftrag (über Neustarts) nicht gemessen; Wartezeiten nicht nach Chef, Prüfer, Ford getrennt.

## Vorschlag

1. **Laufbremse:** kein neuer Wert; gilt wie entschieden (19.11., 13:02) und gebaut (`probelauf.py`:318–335, :1299–1303): ein Bild- oder Filmlauf je Runde ohne Freigabe, jeder weitere nur nach Freigabe des Prüfers, nach dem zweiten Nein an Sokrates.
2. **`HOECHSTDAUER_MIN = {"Mittel": 360, "Hoch": 300}`**: über P90 (223 min) mit Puffer; Hoch enger, weil je Stunde teurer (G:441). Annahme bis zur Probewoche, dann gegen die Wochenzählung (Zahl 5 „Bremsen“).
3. **Folge wie gebaut:** erstes Mal „Hinweis“ mit Anhalten, zweites Mal „steckt fest“ an Sokrates; erst ein zweites „steckt fest“ an den Chef mit Chefsache (B, Archiv 21.11., 14:37 und 20:59). Was nach dem Anhalten mit der Übergabezeile geschieht (archivieren, „offen“, Neustart, 14.2.5), ist nicht Teil dieses Vorentscheids: gehört zu 1739 (Weitergabe „Hinweis“, `rueckmeldung.py`:12).
4. **Keine Höchstkosten in Dollar** (Archiv 08:19); die Zeile „Höchstkosten“ in 14.2.5 (G:375) und G:481 gleiche ich an das Archiv an (Sokrates, Text).
5. **„Sitzung hängt“ bleibt Meldung** (`lauf.py`:935–942), kein Halt.

6. **Folgeauftrag an Spike (Vorgang, Absender Sokrates 1774), vor `tools/1727-SCHARF`:** (a) Konstante setzen, `laufbremse_test.py`:26 und Kommentar `lauf.py`:181–183, :28 nachziehen; (b) Sitzung mit offenem Weckruf, aber `idle` nicht prüfen (`lauf.py`:825–826 zählt sie als laufend: Fehlalarm beim Warten auf Build); (c) nach „Hinweis“ dieselbe Sitzung nicht für immer auslassen (:603–604: Weckruf oder `WEITER` lässt sie sonst ohne Grenze weiterlaufen), sondern Uhr ab dem Hinweis neu; (d) neue Rollennamen nach der Umstellung (Prüfer, Büro, Arbeitsplaner, Tester) in `kosten.ROLLEN` (`kosten.py`:14), sonst als „Sonstige“ nie geprüft; „Ford 2“ ausnehmen.

**Abgleich (`ROLLE-BERATUNG.md`:36):** betrifft nur Abläufe; Leitbild, Stil, Kampf, Abnahme, BRS nicht berührt. **Nächste Schritte:** nach Nachprüfung Archiv „Vorentscheid“, Datei `chefsache/billigen/1774-hoechstdauer.md` mit Umsetzung (Rückbau: Werte auf None). Punkt 4 ist Folgeänderung Text, nicht Teil des Vorentscheids. Gemessen sind nur Tom, Jerry, Spike; die Werte gelten auch für Perikles, Diogenes, Homer, Tuffy. „Hoch“ ist heute nur der Start mit „Aufwand hoch“ (festgefahrene Aufgaben, `lauf.py`:576–581, 136–148); Feld Leistungsstufe hängt an 1742.

**Nicht hier:** Frist für eine stille oder `idle` Sitzung mit angenommener Übergabezeile (3.3 F2 Nr. 3, L-S2; Wächter 14.2.5 „still abgebrochen“): die Höchstdauer sieht nur laufende Sitzungen.

**Stärkstes Gegenargument:** so gebaut wirkt die Grenze schlecht: Fehlalarm bei Sitzungen, die mit Weckruf warten, und nach dem ersten Hinweis läuft dieselbe Sitzung ohne Grenze weiter; den Neustart aus der Vorgangsdatei gibt es erst mit 1739. **Entkräftung:** die Werte wirken erst mit `tools/1727-SCHARF`; vorher baut Spike (b) und (c) (Punkt 6); bis 1739 nur Hinweis und Zählung (Wochenzählung Zahl 5). Reine Wanduhr zählt Warten mit; ein neuer Auftrag („## Auftrag“) oder eine neue Sitzung setzt die Uhr zurück; die Probewoche zeigt, ob 360 zu eng ist.

## Gegenprüfung 21:00 (frischer Helfer, Fassung 1, Votum „nein in dieser Form, Punkt 1 kann gelten“), mein Wort

1 Halt bewirkt nichts, Übergabe wartet weiter: **stimmt**, Folge nach 14.2.5 mit Unterbrechen, Archivieren, Zeile offen, Neustart · 2 Zeile an Sokrates tot, neuer Startgrund nicht vorentscheidbar: **stimmt**, zweites Mal „steckt fest“, dann C · 3 harte Hänger-Stufe hält lange echte Züge an: **stimmt**, bleibt Meldung · 4 Arbeitszeit mit `lauf.py` nicht messbar: **stimmt**, Maß Kosten (2) und Wanduhr ohne Chefwarten (3) · 5 Körnung, neue Grenze ohne Ort: **stimmt**, Feld in der Vorgangsdatei · 6 Hoch länger statt enger: **stimmt**, ein Kostenwert, damit enger · 7 Zitat „Chef 19.11., 22:18 Notbremse“ ohne Beleg: **stimmt**, gestrichen, Verweis 14.2:367 · 8 „still abgebrochen“ ohne Wächter: **stimmt**, Wanduhr 8 h (3); Frist 3.3 Nr. 3 offen benannt · 9 „auch bei working“ unter Entschieden: **stimmt**, nicht mehr dort · 10 Befugnis: **stimmt**, Vorentscheid nur Werte · 11 Dauer-Sitzungen, Höchstkosten: **stimmt**, ausgenommen, Höchstkosten jetzt Maß · 12 Kosten als vorhandenes Maß: **stimmt**, übernommen.

## Nachprüfung 21:10 (frischer Helfer, Fassung 2, Votum „nicht vorlegbar“), mein Wort, eingearbeitet in Fassung 3

1 Maß passt nicht zum Gebauten, Umbau ohne Folgeauftrag: **stimmt**, nur `HOECHSTDAUER_MIN` · 2 Chefwarten nicht messbar: **stimmt**, gestrichen · 3 „still abgebrochen“ greift nicht: **stimmt**, unter „Nicht hier“ · 4 Kosten je Auftrag gibt es nicht, „Kosten auf“ falsch: **stimmt**, Kostenmaß gestrichen · 5 Folge weicht ab: **stimmt**, Folge wie gebaut, Rest bei 1739; Zuordnung B/20:59 berichtigt · 6 Dollargrenze gegen 08:17/08:19: **stimmt**, keine Höchstkosten (4) · 7 Befugnis zu eng angegeben: **stimmt**, durch 1–6 jetzt nur Werte · 8 Zahlen tragen den Wert nicht: **stimmt**, Annahme bis Probewoche, 297 nicht mehr als Beleg · 9 Zeilen: **stimmt**, berichtigt · 10 Ausnahmen: **stimmt**, wie gebaut · 11 Punkte 1 und 5: **stimmt**.
