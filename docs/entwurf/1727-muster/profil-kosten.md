# 1727, Profil Kosten (Gesamtbild 3.2; Entwurf Perikles 21.11., 20:15, ungeprüft)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb.** Vorschlag Sokrates „Release, Kosten und Guthaben“ war nicht entschieden (G:351); dieser Text legt ihn vor.

Lädt: der Disponent dazu, nur bei Anlass (Profil Disponent „Guthaben“). Keine eigene Sitzung.

Quellen: VA 20.11., 08:19 (Dollar-Freigabe weg, Laufbremse und Höchstdauer je Auftrag 14.2.5, Wochenguthaben im Tagesbericht), 08:16 (über die Auftragsgrenze entscheidet Sokrates, im Zweifel billigt der Chef; Wochengrenze setzt der Chef), 08:17 (Chef: Kosten „eher ein virtueller Punkt“, Abo; was zählt, sind Wiederholungen), 09:45 (drei Teile Spiel, Qualität, Verwaltung), 10:38 (bei knappem Guthaben pausieren die Teams zuerst), 21.11., 20:06 (Teams nur fertigmachen); Gesamtbild 4.4 Zeilen Perikles „Kosten“.

## Text

```markdown
**Kosten.** Geladen, wenn das Werkzeug knappes Guthaben, die Wochengrenze oder eine Bremse (Laufbremse, Höchstdauer je Auftrag) meldet. Was zählt, sind Wiederholungen, nicht Dollar.

**Bremse an einem Auftrag:** die Fachkraft hält an; Zeile mit Laufzahl und Dauer an Sokrates. Weiter erst mit seinem Wort.

**Guthaben knapp:** startest du nichts Neues in der Werkstatt; laufende Aufträge beenden ihren Lauf. Weiter laufen nur Leitung, Abnahme dessen, was fertig ist, und Eilt. Eine Zeile an den Chef (lautlos) mit Stand in Prozent und dem Zeitpunkt, zu dem das Guthaben bei diesem Verbrauch leer ist.

**Wochengrenze erreicht:** wie knapp, bis der Chef sie hebt oder die Woche neu beginnt.

Das Profil endet, sobald das Werkzeug keinen Anlass mehr meldet.
```

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Kosten** | `lauf.py` meldet Guthaben unter Schwelle, Wochengrenze oder Bremse | Ausgabe des Werkzeugs; Laufzahl und Dauer des Auftrags | Starts angehalten oder Auftrag gestoppt; endet, wenn kein Anlass mehr | Bremse: Zeile an Sokrates; Guthaben: eine Zeile Telegram, lautlos | Sokrates (Bremse), Chef (Guthaben, Wochengrenze) | offen: Schwelle, Laufbremse, Höchstdauer nicht gebaut (G:911, L-O12); Guthabenzahl ohne Quelle |

## Offen, Fragen

1. **Kein Auslöser ohne Zahl:** das Guthaben kennt heute nur der Chef (Bild der App, `ARBEIT-BETRIEB.md` „Guthaben:“ von Hand). Ohne Quelle meldet `lauf.py` nichts. Vorschlag: der Chef nennt die Zahl im Chat, Haken D trägt sie ein, `lauf.py` liest sie; oder Schwelle nach Zeit seit dem Rücksetzen (Sa 19:59).
2. **Schwelle und Wochengrenze:** setzt der Chef (08:16). Heute gibt es keine Zahl; Vorschlag zum Fragen: knapp ab 85 % vor Mittwoch, 95 % sonst (aus dem Verlauf 18./19.11.: 1 %/h bei voller Arbeit).
3. **„Teams pausieren zuerst“ (10:38)** heißt künftig „Werkstatt“; Abnahme dessen, was fertig ist, läuft weiter, damit nichts Gebautes liegt (Annahme, prüfen).
4. **Kostenteile** (Spiel, Qualität, Verwaltung) zählt die Routine Wochenzählung, nicht dieses Profil.

## Votum

**Profil Kosten statt Zeilen im Profil Disponent**, weil es selten greift (zuletzt Guthaben 19.11., Sperre bis 21.11., 20:00) und der Disponent es sonst bei jedem Wecker mitliest. **Stärkstes Gegenargument:** ein eigenes Profil für vier Zeilen ist eine Stufe mehr; lädt der Disponent es nicht, weil das Werkzeug den Anlass nicht meldet, greift nichts. **Dagegen:** derselbe Auslöser fehlt auch bei Zeilen im Profil; ohne Werkzeugzeile (Frage 1) wirkt beides nicht. Zusammenlegen mit Release lehne ich ab: andere Auslöser, andere Empfänger.
