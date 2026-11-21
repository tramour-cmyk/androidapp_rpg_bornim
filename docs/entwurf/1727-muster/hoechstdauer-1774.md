# 1774, Werte für Höchstdauer je Auftrag und Laufbremse (Entwurf Sokrates 21.11., 21:00, ungeprüft)

Anlass: Vorgang 1774 (Spike, aus 1766): „Werte für Höchstdauer je Auftrag (auch bei working) und Laufbremse (Läufe je Auftrag) festlegen; Wert fehlt laut L-O17“. Entschieden: Laufbremse und Höchstdauer je Auftrag (Archiv 20.11., 08:19, 14.2.5); Laufbremse in der Form (Archiv 19.11., 13:02: je Runde ein Bild- oder Filmlauf, den nächsten gibt der Prüfer frei, nach dem zweiten Nein Sokrates); Höchstdauer „auch bei working“ (`prozesspruefung-21-11.md`:29 Nr. 4, Vorschlag L-O17). Über die Grenze entscheidet Sokrates, im Zweifel billigt der Chef (Archiv 20.11., 08:16). Art: Vorentscheid Sokrates (Einzelheiten eines Ablaufs, `ROLLE-BERATUNG.md` „Entscheidet selbst“).

## Messung (Helfer 20:57, 7 Tage, 352 Sitzungen, 128 archivierte Arbeitssitzungen Tom, Jerry, Spike; Kosten für 40)

- Dauer created_at → updated_at (Minuten): Median 88, P75 149, P90 223, Max 605. Je Vorgang über Neustarts: Median 133, P90 382.
- **Dauer ist fast nur Warten:** Tom 286 605 min, davon API-Zeit 11 min; Spike 295 393/14; Jerry 297 400/43. Einzelne Arbeitsgänge enden nach Minuten. Wartende Sitzungen kosten 1–3 $/h, arbeitende 6–25 $/h.
- Von 11 Ausreißern über P90 warteten etwa 6 zu Recht (Test des Chefs, Freigabe, nachts), 3 arbeiteten wirklich lange (Jerry 297, Jerry Build 294, Tom 1420). Keine Schleife in 7 Tagen.
- Stufe Hoch (9 von 40): nicht länger, Median 45 % teurer.
- Vorhandene Grenzen: `lauf.py` „Sitzung hängt“ bei working 60 min ohne neues `updated_at` (nur Meldung); 40 $ je Vorgang (1538, fällt mit der Umstellung, Archiv 20.11., 08:19); Neustart-Haken 300 Tsd.; Herzschlag 120 min.

## Vorschlag

1. **Laufbremse:** kein neuer Wert; gilt wie entschieden (19.11., 13:02): ein Bild- oder Filmlauf je Runde ohne Freigabe; jeder weitere nur nach Freigabe des Prüfers; nach dem zweiten Nein an Sokrates. Für Buildläufe gilt die Build-Kette (einmal nachbessern, zweites Rot abgebrochen; `build-kette.md`).
2. **Höchstdauer je Auftrag = Arbeitszeit, nicht Wanduhr:** gezählt wird nur Zeit, in der die Sitzung des Auftrags `working` ist (Start oder WEITER bis Zugende); `idle`, `need_input`, Warten auf Test oder Wecker zählen nicht. `lauf.py` summiert je Lauf (Stundentakt und Weckrufe) die Abstände, in denen der Status `working` war.
   - **Mittel: 120 min Arbeitszeit, Hoch: 150 min.** Begründung: Die längsten echten Arbeiter (Jerry 297 mit 43 min API-Zeit, plus Werkzeugzeit für Builds und Filme, ein APK-Lauf 9–37 min) liegen darunter; die Grenze ist Notbremse (Fristen 14.2 „nur Notbremse“, Chef 19.11., 22:18), keine Taktvorgabe. Hoch +25 %, weil je Arbeitsgang länger gedacht wird.
   - Folge bei Überschreitung: Werkzeug hält an (keine weitere Nachricht an die Sitzung), Zeile an Sokrates („Höchstdauer überschritten“, Profil Kosten :17), der entscheidet: weiter mit neuer Grenze oder Übernahme durch eine neue Sitzung aus der Vorgangsdatei.
3. **Harte Stufe gegen Schleifen:** `working` ohne neues `updated_at` 60 min am Stück → aus der heutigen Meldung „Sitzung hängt“ wird Halt mit Zeile an Sokrates (gleiche Folge wie 2).
4. Konstanten oben in `lauf.py` (`HOECHST_MIN = {"Mittel": 120, "Hoch": 150}`, `HAENGT_MIN = 60`), scharf mit `tools/1727-SCHARF`; nach zwei Wochen gegen die Wochenzählung (Zahl 5 „Bremsen“) prüfen.

**Stärkstes Gegenargument:** Arbeitszeit aus Stundenstichproben ist ungenau (eine Sitzung, die zwischen zwei Läufen arbeitet und wieder ruht, wird falsch gezählt), und der Schaden (Schleife) kam in 7 Tagen nicht vor; jeder unnötige Halt kostet einen Neustart (3–5 $ Startlesen) und Zusammenhang. **Entkräftung:** die Grenze liegt weit über jeder beobachteten Arbeitszeit, sie trifft also praktisch nur echte Hänger; gezählt wird grob in Lauf-Abständen, ein Fehler um eine Stunde ändert bei 120 min das Ergebnis nur bei Grenzfällen, und die Folge ist kein Abbruch, sondern eine Zeile an Sokrates.
