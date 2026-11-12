# 1056 · Vorentscheid billigen: nächster Build halbiert nach Thema, erst Kampf, dann Dorf und Oberfläche?
Sokrates · 12.11., 16:54 · B Steuerung · aus deinem Wort 16:53 („können wir den nächsten Build dann nicht doch taktisch halbieren“)
Kurz: Nach Build 280 kommen zwei kleinere Builds statt eines großen: 281 mit dem Kampf (Wochenziel), 282 mit Dorf und Oberfläche gleich danach.

Geprüft an: [Lauf 43246197851 auf PR #199](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43246197851) (läuft seit 16:17), Vorgangsliste 12.11., 16:53 (Stand „gebaut“ je Team), `LISTE-CHECK-BUILD-TEST.md` Punkt 3 (317)

**Frage:** Bisher bündelt ein gemeinsamer Build alle fertigen Punkte beider Teams, ohne Obergrenze (317, Chef 07.11.). Nach Build 280 läge damit ein großer Build an. Du hast gefragt, ob man ihn halbieren kann.

**Entschieden:** Der nächste Build wird nach Thema geteilt:
- **Build 281 Kampf:** alle fertigen Punkte zum Kampf, also das Wochenziel „Kampf passt“; meist Jerry.
- **Build 282 Dorf und Oberfläche:** der Rest; meist Tom. Er baut auf 281 auf und kommt gleich danach, ohne auf deinen Test von 281 zu warten.
- Punkte ohne etwas zu sehen (Tests, Werkzeuge, Skripte) fahren in 281 mit und stehen nicht auf der Prüfliste.
- Gilt nur für diese beiden Builds; danach wieder ein gemeinsamer Build nach 317.

**Umgesetzt:** noch nicht. Jerry baut 281 mit 1055 (Perikles hat ihn 16:5x angelegt), sobald Build 280 auf `main` ist; Zu 1055 bei Jerry.

**Rückbau:** ein Build mit allem, wie bisher (317).

**Kosten:** ein zusätzlicher Baulauf von etwa einer Stunde; auf GitHub für uns ohne Kosten, da das Repo öffentlich ist.

**Berührt:** 1052 (Perikles, Wochenziel und Build 281), 1029 (Jerry, Build 280 auf `main`), beide Teams, Sperre 620.1 B

**Begründung:** Du testest zuerst, was das Wochenziel verlangt, und bekommst zwei kurze Prüflisten statt einer langen. Fällt im Kampf etwas durch, hält das Dorf nicht auf. Abgeglichen mit: 317 (Chef 07.11., ein Build für alle, ohne Obergrenze; hier für zwei Builds ausgesetzt, auf dein Wort 16:53), höchstens 6 Testbuilds am Tag (2 von 6), Nummern nur aufsteigend (282 baut auf 281), Sperre 620.1 B (löst sich je Team mit dem Test), Wochenziel 09.–15.11.

**Sachverhalt:**
- **Build 280 auf `main`:** hängt nur noch an einem roten Test (1029, schalter_1024). Jerry hat die Ursache nachgestellt und behoben; der Prüflauf läuft seit 16:17. Ein solcher Lauf dauert meist eine Stunde. Ist er grün, führt Jerry 280 sofort zusammen; nach heutigem Stand also etwa ab 17:20. Wird er wieder rot, später.
- **Was wartet:** Genau nachgezählt stehen 29 Punkte auf „gebaut“ (Tom 13, Jerry 16), nicht 45; die 45 des Werkzeugs zählen auch schon getestete Punkte aus Build 280 mit. Davon sind etwa 8 nur intern (Tests, Skripte, Sammelbuild selbst, schon in 280). Für dich zum Ansehen bleiben etwa 21: Kampf etwa 9, Dorf und Oberfläche etwa 12.
- Teilung nach Team statt nach Thema würde den Kampf zerreißen (Toms 1040.1 Drehen im Stehen gehört zu den Leuten, Jerrys 995 Grabhund zum Kampf); darum nach Thema.

**Auswertung:**
- **Nach Thema geteilt (entschieden):** Wochenziel zuerst, kurze Prüflisten, ein Lauf mehr.
- **Ein Build mit allem (verworfen):** ein Lauf weniger, aber eine Prüfliste mit über 20 Punkten, und der Kampf wartet auf das Dorf.
- **Nach Team geteilt (verworfen):** einfacher zu mischen, aber Kampf und Leute liegen in beiden Teams.
- **Stärkstes Gegenargument:** Zwei Builds kurz hintereinander heißt: 282 muss auf 281 aufbauen, und wer in 281 einen Rückläufer bekommt, baut ihn erst in 283. Das ist gewollt: Ein getesteter Build ist zu (324), der Rückläufer kommt in den nächsten.

**Folgerungen:** Perikles setzt es mit 1052 um und schreibt es den Teams in den Vorrat; die Prüflisten liest wie immer eine Sitzung außerhalb des Teams gegen. Du billigst mit „1056 gebilligt“ oder sagst „1056 zurück“, dann bleibt es bei einem Build.

Antwort: „1056 gebilligt“ oder „1056 zurück“
