# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


**Gelesen bis:** `origin/main` 22.10., 14:14

**Übergabe (22.10., 14:1x, „Perikles – 308 Vorrat aufräumen“):** 308 erledigt (Vorrat 15 → 6 KB), 307 gebaut (`notiz.sh` liest Kennungen aus `ROLLE-BETRIEB.md`), 300 in `CLAUDE.md` „Melden“, Guthaben beantwortet. Nachfolger: Perikles – 165 Bilanz (23.10.).

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| 261.5 | M | **von Chef (21.10., 06:15):** Archivregel; Zu 261.5 | frühestens 24.10.: beobachten mit Zählung 149; 261.6 gebaut 22.10. |
| 276 | K | **von Sokrates (zu 274):** Fords Anleitung auf eine Seite, etwa 3 KB; Urteilsaufgaben in `lauf.py` oder zu Perikles | frühestens 26.10.: Ford 2 nach `LISTE-FORD2.md` (gebaut); Rest nach Zählung 149 (24.10.) mit Zahlen vorlegen (Zu 276) |
| 270 | M | Modellwechsel, Regelwerk kürzen (Vorgangsarchiv) | frühestens 26.10.: gebaut 21.10.; nach der Wochenzählung Empfehlung behalten oder zurück |
| 236 | M | **von Ford (D36.5):** `notiz.sh` bleibt in neuer Sitzung im Merge stehen (Abbild bringt alten lokalen `main` mit) | gebaut: Abbruch mit Meldung; Rest: Abbild erneuern bei Ford/Chef; 21.10., 17:13 wieder (Sicherung `backup-lokal-main`, Reset) | `main` |
| 165 | M | Ablaufstichprobe, im Tagesbericht 247 | frühestens 23.10. (Bilanz mit dem Chef; Tag 1–3 getan, Zu 165) |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz, Zu 163.1) | ruht bis 23.10. |
| 99 | K | Zwei Niederlassungen (Zentrale Max, Niederlassung Pro) | ruht: Niederlassung ruht (`CLAUDE.md`) |
| 246.1 | K | **von Sokrates:** übrige Artefakte als `.md` ins Repo (Vorgangsarchiv 246) | ruht: 9 Dateien übernommen; Rest bei Sokrates (Originale löschen, Kartenmappe, Beschlüsse) | – |
| 298 | M | **von Jerry (Chef 22.10., 11:00):** Version der Prüfliste automatisch | gebaut 22.10. (`zug-index.py`, auch bei Laufbeginn); beim nächsten Build ansehen, dann streichen | `main` |

## Einzelheiten

- **Von Sokrates (22.10., 17:50, Chef 17:44: „… check doch bitte die anderen Vorräte auch, ob da genauso viele Leichen rumliegen.“):** 298 streichen (t77 trägt 0.1.983); 246.1 Rest übernimmt Sokrates, hier zu; `ARBEIT-BETRIEB.md` 21,8 KB, Übergabe zu lang; Vorschlag: Werkzeug meldet „wartet auf tNN“ ohne Datei in `chefsache/ansehen/` (bei Tom 267, Jerry 211.14, 257 gefunden).

Ältere Wortlaute und Befunde (234, 185, 261, 261 Kosten, Fehlerfall 251, 261.5 Neustart, 246.1, 298, 165 Tag 1–2 ausführlich): Git, Stand `b92df164` dieser Datei.

- **Zu Guthaben** (BERATUNG „Zu 45“, Chef 22.10., 14:06; Frage Sokrates: was an Abläufen sparen?). **Perikles 14:1x:** keine neue Sparregel; 287 („nicht sparen, nichts nachkaufen“) und die 80-%-Regel (`lauf.py --nur-muss`, ab ~16:00) reichen. Größter Hebel bleibt die Stabsarbeit (24 % der Kosten, Zu 163.1): ab 80 % Sokrates nur auf Zuruf des Chefs, Perikles und Diogenes nur Muss mit Termin; Fords Stundenlauf bleibt (8 %, Sicherheit). Stärkstes Gegenargument: ohne Bremse für die Leitung ist das Guthaben Fr ~13:30 leer, also 31 Stunden Stillstand bis Sa 20:59; dafür steht 287. Bilanz mit Zahlen in 163.1 (23.10.).

- **Zu M? (Perikles 22.10., 08:1x, bis Wochenziel 26.10.):** M: 267, 293, 294 (Rückläufer und Sprungtest = Pflicht „läuft rund“), 295 (Kampf glätten, Chef erwartet beide Systeme), 284 (entschieden). K: 289 (Chef: zurückgestellt), 296 (Übersicht, kein Spiel; Funde werden eigene Muss-Zeilen), 276 (Zahlen erst 24.10.). Gegenargument zu 295: 212 „neue Kampfregeln nur in MARS“; gilt für Regeln, nicht für Bewegungen.

- **Zu 163.1:** Wortlaut Chef 21.10., 15:28 und Kostenbefund in `ARBEIT-BERATUNG.md` „Zu 163.1“. **Messung 20.–21.10.** (546 $): Spiel 60 % (Tom 112, Jerry 197, Homer 20 $); Leitung 40 %: Sokrates 131 $ (24 %, 22 Sitzungen), Perikles 44, Ford ~47 (23 $/Tag), Diogenes 11. Neustarts der Teams ~35 $ (11 % der Teamkosten, je Start 0,5–0,75 $). Vorschlag Regelbilanz: 99h.6 bleibt; größter Hebel ist die Stabsarbeit, nicht Ford.
- **Zu 276** (Chef 21.10., 08:07: „… Pro und Contra, was bringt uns das? Wird es die Fehler von Ford vermeiden? Geht uns dann wieder was verloren?“). Perikles: Fords Fehler kamen aus Lücken zwischen Quellen, Urteilsschritten und Werkzeug-/Rechtefehlern, nicht vom Lesen; Kürzen spart 5–7 Tsd. Token je Start; Risiko wie D41.1. Empfehlung „noch nicht“; Chef 08:12: „Ja, Ford 2 aus der Startlektüre nehmen. Und dann den Rest halt zurückstellen, wie ihr gesagt habt.“ Sokrates: am 24.10. Fords Abweichungen je Schritt zählen; ein Schritt mit Fehlern wird Ausgabezeile in `lauf.py`.
- **Zu 261.5** (Chef 21.10., 06:15; Vorgangsarchiv 261.5, 261.6): Archivregel in `LISTE-BETRIEB.md` (je Bereich eine Sitzung; ältere archiviert Ford, sobald die neuere läuft, offene Frage vorher übertragen; neue Arbeit in alter Sitzung unter 100 Tsd. Token und 60 Minuten Ruhe). Prüfung in `lauf.py`: ARCHIVIERE zweimal oder zwei Sitzungen je Bereich zwei Läufe hintereinander → WARNUNG-LAUT. Offen: beobachten bis 24.10. (mit 149); Modell Ford nach 3 Tagen.
- **Zu 165** (Chef Ja 18.10.): Schritt im Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10. Tag 1 (18.10.): Weg-Regel fehlte im Testmuster, behoben in `zug-index.py`. Tag 2 (20.10.): Übergabe Jerry mit Stand, Maß 700 Zeichen in `regelcheck.py`. Tag 3 (21.10.) getan. Je Tag ein Befund, Aufwand ~10 Minuten. Dazu (Sokrates 20.10., Chef 08:54 „Wer kümmert sich eigentlich um die Berichtsergebnisse von Diogenes …?“): Prüfbericht gegen die Vorräte abgleichen, in der Bilanz vorlegen.
- **Zum Wochenziel ab 26.10.** (Chef 20.10., 14:42, an Sokrates): „Ich habe jetzt 52 Jahre darauf gewartet, ein Spiel zu entwickeln. … ein paar Tage hin oder her, glaube ich, werden den Markt nicht völlig verändern.“ Sokrates: Termine nicht gegen Güte ausspielen; knapp sind Guthaben und Zeit des Chefs.
