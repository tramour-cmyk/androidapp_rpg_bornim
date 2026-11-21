# 1727, Profil Kosten (Gesamtbild 3.2; Fassung 3, Perikles 21.11., 20:35, nach Nachprüfung Sokrates 20:27)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb.** Vorschlag Sokrates „Release, Kosten und Guthaben“ war nicht entschieden (G:351).

## Votum: kein eigenes Profil

**Profil Kosten fällt; eine Zeile im Profil Disponent („Guthaben“) und Werkzeugzeilen tragen es.** Grund: es gibt schon eine Regel mit Schwellen (287: ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen; `ARBEIT-BETRIEB.md`:20), und die Bremsen handhabt das Werkzeug. Ein Profil, das nur bei einer Zahl lädt, die nur der Chef kennt, würde nie geladen. **Stärkstes Gegenargument:** im Disponenten liest jede Zeile bei jedem Wecker mit. **Dagegen:** es ist eine Zeile, ein Profil wären vier plus Ladeweg.

Quellen: VA 20.11., 08:19 (Dollar-Freigabe weg, Laufbremse und Höchstdauer je Auftrag 14.2.5, Wochenguthaben im Tagesbericht), 08:16 (über die Grenze je Auftrag entscheidet Sokrates, im Zweifel billigt der Chef; Wochengrenze setzt der Chef), 09:45 (drei Kostenteile); VA 19.11., 13:02 (Laufbremse: den nächsten Lauf gibt der Prüfer frei, beim zweiten Nein Sokrates); G:480 (Kosten: Wochenzählung zählt, Sokrates bewertet und schlägt vor), G:481 (Chef 08:17: Kosten „eher ein virtueller Punkt“), G:502 (`ARBEIT-BETRIEB.md` fällt, Guthaben → Tagesbericht); Regel 287.

## Was wo hingehört

| Fall | wer | Quelle |
|---|---|---|
| Guthabenstufe nach 287 | `lauf.py` gibt sie aus, der Disponent startet danach (Profil Disponent „Guthaben“) | 287 |
| Laufbremse (Läufe je Auftrag) | Werkzeug hält an; nächsten Lauf gibt der Prüfer frei; zweites Nein: „steckt fest“ an Sokrates | VA 19.11., 13:02 |
| Höchstdauer je Auftrag überschritten | Werkzeug hält an; Zeile an Sokrates, er entscheidet über die Grenze | VA 20.11., 08:16; Sammelfrage C |
| Wochengrenze | setzt der Chef; bis er eine nennt, keine | VA 20.11., 08:16 |
| Kostenteile Spiel, Qualität, Verwaltung | Routine Wochenzählung zählt | VA 20.11., 09:45 |
| Kosten bewerten, Sparvorschläge | Sokrates aus den Zahlen der Wochenzählung | G:480 |
| Wochenguthaben | Routine Tagesbericht (Werkzeugzahl) | VA 20.11., 08:19 |

## Offen, Fragen

1. **Quelle der Guthabenzahl:** nur der Chef (Bild der App). `ARBEIT-BETRIEB.md` fällt (G:502), die Zahl wandert in den Tagesbericht. Vorschlag: der Chef nennt sie im Chat, Haken D trägt sie ein, `lauf.py` liest sie. Haken D trägt heute nur Freigabe und Antwort auf eine Frage (VA 21.11., 14:37 D); die Guthabenzahl ist eine **Erweiterung von D, Chefsache** (über Sokrates). Ohne Zahl keine Stufe.
2. **Laufbremse, Höchstdauer:** nicht gebaut (G:911, L-O12).
3. Die Bedingung „bei knappem Guthaben pausieren die Teams zuerst“ (Prüfung 20.11., 10:40) ist mit 21.11., 20:06 überholt; 287 regelt die Folge.

## Nachprüfung Sokrates 20:27, mein Wort

Träger für Bewertung und Sparvorschläge (G:480): **stimmt**, Zeile ergänzt · Frage 1 ohne `ARBEIT-BETRIEB.md` (G:502): **stimmt** · Haken D schreiben ist Erweiterung von D: **stimmt**, als Chefsache gekennzeichnet.

## Gegenprüfung 20:18, mein Wort

5 Laufbremse an den Prüfer, nicht Sokrates; Anhalten im Werkzeug: **stimmt** · 6 Regel 287 übergangen, Schwelle erfunden: **stimmt**, Schwelle gestrichen, 287 gilt · 7 Quellen 08:17 und 10:38 falsch, Eilt-Ausnahme ungekennzeichnet: **stimmt**, berichtigt, Ausnahmen gestrichen · Gegenargument zum Votum (Profil würde nie geladen): **stimmt**, Votum geändert.
