# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


**Gelesen bis:** `origin/main` 20.10., 11:05

**206 (19.10., 12:1x):** M (Wunsch des Chefs), gebaut: „Vorgang“ statt „Zeile“ in Startauftrag und Hindernistext (`lauf.py`), Weiter-Haken, Besetzung (Spalte), `CLAUDE.md`; Tabellenzeile und interne Kommentare bleiben „Zeile“. Wirkt ab nächstem Lauf von Ford.

**202 (19.10., 12:2x):** gebaut: `startbar.py` nennt am Ende „Übernahme für Tom/Jerry: <Nr> …“, wenn das Team nichts Startbares hat (oberste freie Zeile des anderen, ohne Test/Gerät/Build bevorzugt, nichts bei mehr als 4 Wartenden auf Test). `lauf.py` startet noch nicht danach; Ford sieht den Hinweis, 202 Rest: lauf.py anbinden nur, wenn Ford es von Hand tun muss.

**M?-Abgleich (19.10., 11:1x):** 198, 199, 200 (Fehler des Chefs, Direktive 179) und 149 (Probewoche läuft, Chef „Ja“ zu 149.1, Frist 24.10.) auf M.

**Übergabe (20.10., 08:5x, „Perikles – Tagesrückblick 20.10.“):** Rückblick Tag 2 getan, „M?“ entschieden (234 M, 232 M, 233 K, 211.14 M), 235 an Sokrates, Chefsache 234 angelegt, Notizkopie zurückgesetzt. Nachfolger: keiner

**Abgleich (18.10., 22:4x, Chef: „Überprüfe und gleiche ab“):** Zeile 90 fehlte (Schritt 11 verweist darauf), neu; 165 Tag 2 erst 20.10. (19.10. Rückblick Sokrates); 167 erledigt (.1, .4, .5, .8, .9, .2, .10 umgesetzt, .7 nein), 167.6 zu Sokrates (Wiedervorlage 26.10.); 99 ruht (Niederlassung, 159).

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| 238 | M | **von Sokrates (Chef 20.10., 11:02):** Frage des Chefs zu t42.2 kam bei keiner Sitzung an (Ford archivierte Jerry 10:58 sofort nach der Neustart-Meldung, der Chef antwortete im alten Gespräch) | gebaut 20.10., 11:3x: Neustart archiviert nicht mehr; `lauf.py` archiviert erst nach 60 Minuten Ruhe (`ARCHIV_MIN`, Test mit Kurzzeilen), Regel in `LISTE-BETRIEB.md`, `ROLLE-BETRIEB.md`; ob Nachrichten an archivierte Sitzungen verloren gehen, nicht getestet (Folgen vermieden) | `main` |
| 236 | M | **von Ford (Eingang, Diogenes D36.5):** `notiz.sh` bleibt in neuer Sitzung im Merge stehen (Abbild bringt alten lokalen `main` mit) | gebaut: Abbruch mit Meldung in `notiz.sh`, `bash -n` ok 20.10.; Rest: Abbild erneuern (Ursache alter lokaler main) bei Ford/Chef | `main` |
| 234 | M | **von Team Jerry (Chef 20.10., 07:58):** Freigabe eines Builds gilt einmal, egal in welcher Sitzung; kein zweites Wort des Chefs für den Merge | wartet auf Chef: Chefsache 234 (settings.json und notiz.sh darf ich nicht selbst ändern; Notiz-Regel „Freigabe gilt einmal“ folgt, sobald Notizen schreibbar) |
| 247.1 | M | **von Sokrates (Chef 20.10., 13:27):** Tagesbericht umsetzen: Ford startet Perikles 7:30 (Sa, So 9:30), Morgenmeldung nur eine Zeile, `LISTE-BETRIEB.md` Schritt 10, `lauf.py --morgen`; Regeln schon in `ROLLE-PROJEKT.md`, Muster `ARBEIT-TAGESBERICHT.md` 20.10. | offen; ab 21.10. 7:30 |
| 90 | K | Tagesrückblick (ersetzt durch Tagesbericht 247 ab 21.10.) (Probe 18.–22.10.), Ford startet ihn (`LISTE-BETRIEB.md` Schritt 11) | Tag 2 getan 20.10. (Zu 90); nächster Rückblick 21.10., Bilanz 23.10.; Termin 21.10. |
| 165 | M | Ablaufstichprobe, im Tagesrückblick 90 | ab 21.10. Tag 3 (Tag 1 18.10., Tag 2 20.10. getan), Bilanz 23.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann ja.“) | ab 20.10. Auswertung an Sokrates (Grenze umgestellt 18.10., 22:4x; Messtag 19.10.; Ford meldet Tageskosten 17.–19.10. am 20.10.) |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | ab 21.10. Entscheid (Messung 20.–21.10.) |
| 99h.6 | K | Messung Leitung 20.–21.10. mit den Neustarts der Teams (99h, 99h.6) | ab 22.10. Auswertung |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz) | ruht bis 23.10. |
| D36.2 | K | **von Diogenes (Lauf 36):** `ROLLE-ENTWICKLUNG.md` 228-Absatz „Gerätetest vor `main` bleibt“ ohne Ausnahme 201a; „Zeile“ statt „Vorgang“ in `ROLLE-ENTWICKLUNG.md` Z. 23, 27, 31 und `ROLLE-KREATIV.md` Z. 15 (D36.3). Einzelheiten `PRUEFBERICHT.md` | offen |
| D37.1 | K | **von Diogenes (Lauf 37, nachgetragen von Sokrates 20.10.):** Kür-Start Jerry 17.10., 22:08 unterblieben; bestätigen, welche Regelfassung damals galt (vor 166.1), damit 149 ihn zählt oder nicht; `PRUEFBERICHT.md` | offen: bis 24.10. (Zählung 149) |
| D38.1 | K | **von Diogenes (Lauf 38, 149.1):** Nacht 18.→19.10., 23:41–10:06: Jerry ohne Sitzung, Kür 72u.1 laut `startbar.py` startbar, Ford stimmte nach Wochenziel („nicht diese Woche“) dagegen. Zeilen, die das Wochenziel ausnimmt, auf „nach dem Meilenstein“ setzen, damit Werkzeug und Wochenziel übereinstimmen | offen |
| 246.1 | K | **von Sokrates (Chef 20.10., 12:59):** übrige Artefakte als `.md` ins Repo, im Inhaltsverzeichnis verlinken; Geschäftsmodell, Markt, Preise bleiben Artefakt (Vorgangsarchiv 246) | nach dem Meilenstein |

## Einzelheiten

- **243 (20.10., 12:3x, entschieden, keine Regel):** Die Weiterleitung hat gewirkt (Freigabe 12:02, PR #130 zusammengeführt 12:12); verzögert war nur der Nachfolger, der erst Jerrys Vorrat ablief, und Sokrates prüfte zu früh. Gegenargument: Freigaben des Chefs dürfen nicht warten. Dagegen: eine Regel „Worte des Chefs vor jeder Zeile“ besteht schon (CLAUDE.md, Haltung 3 und Zusammenarbeit 1/5), ein Einzelfall von 10 Minuten rechtfertigt keine zweite (90a). Lehre für Prüfer: Wirkung einer Weiterleitung erst nach etwa 15 Minuten prüfen.

- **Zu 234** (Chef 20.10., 07:58, an Jerry, Wortlaut): „Bild 40 und 41 sind freigegeben und ich finde es bescheuert, dass ich das immer zweimal sagen muss, obwohl ich es schon freigegeben hatte. Mann!“ (Bild = Build.) Freigaben vorher: Build 40 06:57, Build 41 07:34, beide an Sokrates.

- **Zu 192/191 (19.10., gebaut):** 192.2 Schritte 5, 9, 10 (`--morgen`), 11 in `lauf.py`; Schritte 6 und 8 sind Urteil, bleiben Text. 192.3: Wortlaut des Chefs im Vorrat, Weckruf nach Push, Standzeile nicht als Haken gebaut (nicht sicher erkennbar, Leitlinie 192: Haken, der öfter falsch meldet, wird abgeschaltet; D31.4). 191 komplett (Kosten als Differenz, Termin vorbei). Diogenes prüft in 192.5b.
- **Zu 192** (D31.1): Haken-Grenzen: Größe nur anhalten, wenn der Commit die Datei vergrößert und sie über 15000 liegt; Uhrzeit nur in neuen Zeilen, 5 Minuten Toleranz; D- und Unternummern kennen; Ausweg für zurückgezogene Chefsache.
- **Zu 165** (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10.
- **Zu 90/165, für die Bilanz 23.10.** (von Sokrates 20.10., 09:06; Anlass Chef 08:54: „Wer kümmert sich eigentlich um die Berichtsergebnisse von Diogenes in seinen letzten Tests?“): D37.1 stand im Prüfbericht, aber in keinem Vorrat. Vorschlag: im Tagesrückblick Prüfbericht gegen die Vorräte abgleichen (jeder Befund hat eine Zeile beim Besitzer); in der Bilanz mit dem Chef vorlegen.
- **165 Tag 1 (18.10., 17:1x):** Testdateien t25 (Tom) und t26 (Jerry) verglichen. Abweichung: t26 ohne Satz „Ein Weg …, über Build n installieren“ und Reihenfolge nicht als Weg (26.5 Schänke nach Höhle); Wurzel: Weg-Regel stand nur in `LISTE-BAUEN-TESTEN.md`, nicht im Muster „So geht's“. Behoben in `tools/zug-index.py` (Muster, README neu). Übergaben Tom/Jerry und Meldungen: kein Unterschied gefunden. Aufwand etwa 10 Minuten. Befund 1 von 1 je Tag zählt für die Bilanz.
- **165 Tag 2 (20.10., 00:1x):** Testdateien t39 (Tom) und t40 (Jerry): gleiches Muster, kein Unterschied. Übergaben Tom (318 Zeichen) und Jerry (964, mit Stand, Branchnamen, Zitat): Abweichung gegen `CLAUDE.md` „was getan ist und der Nachfolger, kein Stand“. Wurzel: kein Maß, kein Haken; behoben in `tools/regelcheck.py` (Übergabe über 700 Zeichen wird gemeldet, Jerrys Vorrat steht jetzt drin; kürzen macht Jerry). Chefsache-Dateien `entscheiden/` leer, Meldungen (Telegram) nicht lesbar. Aufwand etwa 10 Minuten. Befund 2 von 2 Tagen.

- **Zu 246.1** (Sokrates 20.10., 13:1x; Chef 13:09: „Da dürften ja irgendwann nicht mehr so viele Artefakte da sein, hoffe ich.“): 27 Artefakte auf Max. Zum Löschen (umgesetzt oder Kopie im Repo), nur mit Wort des Chefs: Dein Zug, 108, Diogenes Prüfbericht (alt), Entwürfe 98 (Firma und Rollen, Dateienentwurf, Firmenbild), CLAUDE.md kürzen, Ford 81, 77e, 76/77, Kampfsystem neu denken, Heldenbau, Storyplan, Texte Kapitel 2. Erst umziehen, dann löschen: Beschlüsse bis 16.10., Rollenkonzept 98, Morgenbericht 19.10., Prüfbogen, Kartenmappe, Graumoor-Karte, Roter Faden, MARS Aufstellung, Spielanleitung 72.10a, Zwischenbildschirm 24, Chronik-Texte Kapitel 1. Bleiben: Geschäftsmodell, Marktvergleich.

## Tagesrückblicke

Je Rückblick ein Absatz, neueste oben, angehängt statt überschrieben (90, Chef 20.10.); nach 7 Tagen streichen (Verlauf in Git). Rückblick 18.10. (Tag 1) nur im Git-Verlauf.

- **Tagesrückblick 90, 20.10. (Tag 2):** (1) Muss des Wochenziels (13e, 38, 39, 26) ruhen oder warten auf den Chef; die Woche geht fast ganz in 211 (MARS-Kampfbild, Muss laut Chef 19.10., 23:13). (2) Muss-Anteil nicht belastbar: von 741 $ in `vorgangskosten.py` haben 344 $ (46 %) keine Klasse; Klassen nachtragen (Diogenes bei der Wochenzählung). (3) Ford 32,5 / 34,5 / 21,0 $ (17.–19.10.), Woche 297 $, Spiel 56 % (Stufe 50 % erreicht); Ford-Uhr aus bei reinem Warten spart (seit 02:05), Auswertung 185 an Sokrates nach Messung 99h.6. Stichprobe 165 Tag 3 am 21.10. Entscheid M?: 234 M, 232 M, 233 K, 211.14 M (Leistungsmessung A56) mit Rest K. Notizkopie war im ungelösten Merge (D36.5): zurückgesetzt, Sicherung Zweig `backup-lokal-main`; Dauerlösung in `tools/notiz.sh` (Abbruch bei Fehlschlag) darf ich nicht selbst ändern, siehe Chefsache 234.
