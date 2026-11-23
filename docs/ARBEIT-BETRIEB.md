# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll. Aufgeräumt 23.11., 08:46 (1688): was seit dem Umschalten 22.11., 16:17 nicht mehr gilt, steht in Git (`git log -p docs/ARBEIT-BETRIEB.md`, Stand vorher 2c67215a4). Befristetes nur als „Zu <Nr>, bis erledigt, streicht: <Rolle>“.

**Nie archivieren:** (keine; Sokrates …777MV8Hv8ps2Js5voW freigegeben, Chef 18.11., 08:45)

Jede Startnachricht für Figur, Bild oder Film: „`LISTE-HANDWERK-FIGUR-PRUEFBILD.md` vor dem Lauf lesen und das Bild danach dagegen prüfen“ (1625, Sokrates 07:20).

**Nächste freie Vorgangsnummer: 2009** (zuletzt 2008 Werkzeug 23.11. 21:04:58 bd18) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g; Schalter für `lauf.py`, gilt für den Disponenten)

**Herzschlag (1764, seit 21.11.; 1997):** lauf.py pusht selbst: jeder vollständige Lauf, ohne Schalter, schreibt am Ende Tabelle und Zeitmarke von `ARBEIT-BESETZUNG.md` und pusht sie; nur bei „HERZSCHLAG NICHT GEPUSHT“ selbst committen und pushen.

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Chef abwesend:** bis Fr 27.11., streicht: Disponent. **Chef 22.11., 17:00 (an Sokrates, Chat):** „ab morgen bis einschließlich Freitag, sehr viel unterwegs und werde ganz wenig Zeit haben“ (23.–27.11.): was am Chef hängt, sammelt sich in der Chefsache; **Chef 17:04:** „auf Telegram einen Daumen hoch oder runter bei einer Sache zu machen [ist 100-mal leichter], als mich jetzt hier in die Codesitzungen einzuloggen“: aussagekräftige Einzelpunkte (Bild mit Frage, Freigabe mit einem Satz) per Telegram zum 👍/👎, keine langen Texte.

**Guthaben:** **Chef 22.11., 19:38 (an Sokrates, Chat):** „36 Prozent“ (seit 16:52 +5 % in 2¾ h ≈ 1,8 %/h; so 100 % etwa Mo 23.11., 07:00; tragbar bis Sa 28.11., 20:00 ≈ 0,44 %/h); davor **Chef 22.11., 16:52 (an Sokrates, Chat):** „Prozentmark hat aktuell 31“ (Reset Sa 21.11., 20:00); ältere Stände in Git · **kein Limit-Reset vorhanden** (Chef 18.11., 12:16: „Hier gibt es kein Zurücksetzen.“) · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Starter (aktuell)** `session_01Hmoj79aK2ZM5TMgz3YQoPo` „Disponent-Starter (23.11., 10:13)“, Umgebung WireStorm Mittel, Modell sonnet, ohne Repo (Chef 23.11., 10:09); legt nur auf „Disponent-Neustart“ eine Sitzung an; niemand archiviert ihn.
- **Disponent (aktuell)** Uwe `session_01Hmoj75wHERahcfNJhym3bB` „Disponent – Betrieb (23.11., 13:53)“, Modell sonnet (Neustart bei 303 Tsd. Token über den Starter 13:53; Vorgänger Fritz archiviert). Neustart ab 300 Tsd. Token nur über den Starter mit der START-Zeile aus `lauf.py --start Disponent <Nr>`. **Eigene Uhr** „Disponent-Lauf“ `trig_01JyUFnFGzKzNd1KdsU583gN` (`3 * * * *`, an diese Sitzung, Prompt mit `--besetzung`; Chef 14:04, Fritz archiviert 14:04).
- **Zu 287, bis erledigt (Sa 28.11., 20:00), streicht: Disponent.** **Laufsperre ab 23.11., 07:00 (Sokrates, Guthaben 38 % Chef 06:43):** höchstens drei Fachkräfte zugleich (Chef 23.11., 14:43 „lasst den einen dritten aufmachen“, vorher zwei), nur Spiel (Regeln, Kampf, Figur, Welt) und Eilt; Werkzeug nur Eilt; Kür ruht; Prüfer und Planer dazu; frei: Wache, Sokrates, Rückläufer des Chefs; 23–7 keine Fachkräfte, lauf.py aber jeden Takt; Laufende beenden ihren Schritt, danach archivieren statt nachstarten. Folge: 1589.2-Ü3 (Kampf, Rückläufer), 1068-Ü2 (Kampf, Nachfolger Zeno ab 20b158641), 1694 (Figur), 1603 (Kampf), 1961/1964/1965/1960/1520 (Werkzeug, nur Eilt).
- **Zu 1961, bis erledigt, streicht: Disponent.** Marke für `neustart-haken.py` (sucht „Ford (aktuell)“): **Ford (aktuell)** `session_01Hmoj75wHERahcfNJhym3bB`.
- **Wache (aktuell)** `session_01Hmoj78CoScvkasiYmBbPTG` „Wache – Disponent (23.11., 13:35)“, Modell sonnet (Neustart bei 201 Tsd. Token, Disponent Fritz 13:35, Vorgängerin `session_01Hmoj77Y2Jo6nDTdSSdi9P6` archiviert); Uhr „Wache“ `trig_01QuKEpvSi5e9AXBWWDgTvqd` (:33). Stand 21:34 (Clara): WACHE ok (lauf.py 21:06), Disponent idle seit 21:09, kein roter Lauf seit 12:30; laut an Chef 21:34: 1603 Arne (seit 21:14); Frage an Chef zu Wache-Neustart bei 231 Tsd. Token offen; vorher 20:34 laut (1653, 1589.2); vorher 13:34 ohne Befund. Meldungen: keine.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug. Startsperren bleiben mindestens bis zum Archivieren der Sitzung (`rufname.py` ordnet Rufnamen darüber der Rolle zu, 1957).

- 22:31 22.11.: Startsperre 22:31 Start Disponent (lauf.py, Disponent 1961 -; Selbstübergabe sonnet)
- 22:34 22.11.: Startsperre 22:34 Start Arbeitsplaner, Kampf, Regeln, Werkzeug (lauf.py, Arbeitsplaner 1750 Nadine, Kampf 1589.2 Oda, Regeln 870 Ruth, Werkzeug 1963 Sven)
- 23:03 22.11.: Startsperre 23:03 Start Arbeitsplaner, Kampf, Figur, Welt, Werkzeug, Arbeitsplaner, Regeln (lauf.py, Arbeitsplaner 1963 Nadine, Kampf 1068 Oda, Figur 1675 Ruth, Welt 1566 Sven, Werkzeug 1964 Timo, Arbeitsplaner 1961 Thea, Regeln 870 Volker)
- 05:35 23.11.: Startsperre 05:35 Start Wache (Disponent von Hand, Wache-Neustart bei 203 Tsd. Token; Nachfolger Ella)
- 06:40 23.11.: Startsperre 06:40 Start Arbeitsplaner, Kampf, Figur, Welt, Werkzeug, Arbeitsplaner, Regeln (lauf.py, Arbeitsplaner 513 Anna, Kampf 1068 Britta, Figur 1675 Carla, Welt 1566 Dana, Werkzeug 1964 Elke, Arbeitsplaner 1716 Frieda, Regeln 870 Gerda)
- 07:03 23.11.: Startsperre 07:03 Start Arbeitsplaner, Kampf, Figur, Welt, Werkzeug, Arbeitsplaner, Sokrates, Prüfer, Regeln (lauf.py, Arbeitsplaner 513 Anna, Kampf 1068 Britta, Figur 1675 Carla, Welt 1566 Dana, Werkzeug 1964 Elke, Arbeitsplaner 1716 Frieda, Sokrates 1570, Prüfer 1566 Gerda, Regeln 870 Heike)
- 07:04 23.11.: Startsperre 07:04 Start Sokrates (lauf.py, 1570)
- 07:06 23.11.: Startsperre 07:06 Start Prüfer, Regeln, Werkzeug (Disponent von Hand nach Sokrates 06:45/06:50: Prüfer 1566 Gerda, Regeln 870 Heike, Werkzeug 1963 Elke; Silke 1566 archiviert, 8,67 $)
- 07:29 23.11.: Startsperre 07:29 Start Arbeitsplaner (Disponent von Hand nach Sokrates 07:30: Frieda für 1976-Ü1, 1978-Ü1, 1566-Ü22); Heike (870) und Elke (1963) archiviert, Kosten gebucht; Gerda bekommt 1963-Ü10, 870-Ü8 (Chef 07:27 A)
- 07:32 23.11.: Startsperre 07:32 Start Prüfer (Disponent von Hand nach Sokrates 07:33: Ida 1963-Ü10, Jana 870-Ü8, frische Prüfer für Nachprüfungen; Gerda nur Erstprüfungen)
- 07:34 23.11.: Startsperre 07:34 Start Werkzeug (Disponent von Hand nach Sokrates 07:30: Karin 1976, Lena 1978; Aufträge Frieda; 1963 fertig, Ida/Jana archiviert)
- 07:46 23.11.: Startsperre 07:46 Start Technik, Prüfer (Disponent von Hand nach Sokrates 07:47/07:50: Mara Build 301 nur mit 1566, Nora 1978-Ü3). Prüfer-Zählung (Chef 07:40 Regel A): Gerda 3 von 3 (1566, 870, 1963), archiviert; Nora 0 von 3. Gerda, Frieda, Lena archiviert, Kosten gebucht; 870 nach main gemischt (Chef 07:40 Votum A), regelwerte.py gelaufen; vorgang.py fertig 870 lehnt ab (870.12 wartet ohne wartet auf), an Sokrates
- 07:55 23.11.: Startsperre 07:55 Start Werkzeug (Disponent von Hand nach Sokrates 07:55: Olga 1963-Ü12 rote Werkzeugtests, dann 1978-Ü4); Karin (1976) archiviert, Kosten gebucht; Nora Prüfer 1978-Ü3 fertig, 1976-Ü3 angewiesen (Zählung 2 von 3)
- 08:03 23.11.: Startsperre 08:03 Start Arbeitsplaner, Kampf, Figur, Welt, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 513 Jonas, Kampf 1068 Karla, Figur 1675 Lutz, Welt 1566 Marta, Arbeitsplaner 1716 Nils, Tagesbericht 448)
- 08:04 23.11.: Startsperre 08:04 Start Tagesbericht (lauf.py, 448)
- 08:06 23.11.: Startsperre 08:06 Start Prüfer (Disponent von Hand: Petra B301-Ü6, zweites Gegenlesen; Prüfer-Zählung Petra 0 von 3; Nora 3 von 3 archiviert)
- 08:15 23.11.: Startsperre 08:15 Start Arbeitsplaner (Disponent von Hand nach Sokrates 08:13: Rosa für 1570-Ü7 Auftrag und weitere Zeilen); 1566 nach main gemischt (Chef 08:09), Godot-Lauf offen; Mara, Petra archiviert, Build 301 entfällt
- 08:20 23.11.: Startsperre 08:20 Start Prüfer (Disponent von Hand: Sabine 1963-Ü13, 1978-Ü6, 1976-Ü7, 0 von 3, frisch wegen früherer Prüfungen von Nora/Gerda); Olga archiviert (Token 193 Tsd., alle drei Werkzeug-Zeilen erledigt)
- 08:29 23.11.: Startsperre 08:29 Start Figur (Disponent von Hand nach Sokrates 08:13: Svea 1570 A, Zweig claude/dana-1570-umhang ab 9bc78331a); Rosa (Planer, 154 Tsd. Token) bekommt 1986-Ü1 (Eilt, Sokrates 08:33); 1570 Auftrag steht seit 08:20
- 08:30 23.11.: Startsperre 08:30 Start Werkzeug (Disponent von Hand nach Sokrates 08:33: Tilda 1986 Leitung umstellen, Eilt); Rosa archiviert, Kosten gebucht
- 08:42 23.11.: Startsperre 08:42 Start Prüfer (Disponent von Hand: Uta 1986-Ü3, 0 von 3)
- 08:43 23.11.: Startsperre 08:43 Start Werkzeug (Disponent von Hand nach Sokrates 08:53: Viola 1688-Ü1, ARBEIT-BETRIEB auf 30 KB); Tilda (1986 fertig, aa49e9404) archiviert, Kosten gebucht
- 08:50 23.11.: Startsperre 08:50 Start Arbeitsplaner, Kampf, Figur, Arbeitsplaner, Tagesbericht, Sokrates, Welt (lauf.py, Arbeitsplaner 513 Jonas, Kampf 1068 Karla, Figur 1570 Lutz, Arbeitsplaner 1716 Marta, Tagesbericht 448, Welt 1566 Nils)
- 08:51 23.11.: Startsperre 08:51 Start Sokrates (Disponent von Hand nach Sokrates 08:30/Chef 08:26 A: neuer Sokrates 'Rundblick und Bremse' mit Kern Leitung + Gedächtnis; Uta 1986 ja, 3,0 $ nicht gezählt); alter Sokrates (401 Tsd. Token, 23,03 $) archiviert, Kosten auf 1986; Uta archiviert (0 von 3 aber keine Zeilen mehr)
- 08:55 23.11.: Startsperre 08:55 Start Prüfer (Disponent von Hand: Wanda 1688-Ü2, Gegenprüfung ‚fehlt Geltendes?‘, 0 von 3)
- 09:01 23.11.: Startsperre 09:01 Start Prüfer (Disponent von Hand: Xenia 1688-Ü6, zweite Gegenprüfung, 0 von 3); Viola (1688-Ü4 45d94ae69) und Wanda (1 von 3, kein Vorgang zweimal) archiviert, Kosten gebucht
- 09:04 23.11.: Startsperre 09:04 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Tagesbericht, Welt (lauf.py, Arbeitsplaner 513 Nils, Kampf 1068 Otto, Figur 1570 Paula, Werkzeug 1964 Rita, Arbeitsplaner 1716 Sven, Tagesbericht 448, Welt 1566 Tanja)
- 09:05 23.11.: Startsperre 09:05 Start Werkzeug (Disponent von Hand nach Sokrates 09:04: Yvonne 1988 Aufwand und Leitungs-Neustart); die lauf.py-Starts von 09:04 (Planer 513/1716, Kampf 1068, Figur 1570 doppelt zu Svea, Welt 1566, Werkzeug 1964) nicht ausgeführt (zwei Fachkräfte: Svea, Yvonne)
- 09:29 23.11.: Startsperre 09:29 Start Prüfer (Disponent von Hand mit lauf.py --start, Startblock: Nils 1988-Ü2/Ü3, 1971-Ü2, 1989-Ü2, 0 von 3); Yvonne (1988, 1971, 1989 auf main, 204 Tsd. Token) archiviert, Kosten gebucht; 1988 Zusatz 09:26 (Punkte 4/5) noch offen, Zeile fehlt (Sokrates)
- 09:30 23.11.: Startsperre 09:30 Start Werkzeug (Disponent von Hand mit lauf.py --start, Startblock: Ottilie 1988-Ü5 Zusatz 09:26 Punkte 4/5)
- 09:34 23.11.: Startsperre 09:34 Start Kampf (Disponent von Hand mit lauf.py --start, Startblock, nach Sokrates 09:33: Pia 1589.2-Ü3 Rückläufer, danach 1068-Ü2); Svea (1570 ruht bis Sa 28.11., 239 Tsd. Token) archiviert, Kosten gebucht
- 09:38 23.11.: Startsperre 09:38 Start Prüfer (lauf.py, Prüfer 1988 Quirin)
- 09:50 23.11.: Startsperre 09:50 Start Disponent (lauf.py, Disponent 1961 Zita; Neustart bei 582 Tsd. Token von Hand, Vorgänger session_01Hmoj7825XQzzhzppzqkXKU)
- 09:54 23.11.: Startsperre 09:54 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Tagesbericht, Prüfer, Welt (lauf.py, Arbeitsplaner 513 Anna, Kampf 1068 Britta, Figur 1675 Carla, Werkzeug 1964 Dana, Arbeitsplaner 1971 Elke, Tagesbericht 448, Prüfer 1589.2 Frieda, Welt 1566 Gerda)
- 10:03 23.11.: Startsperre 10:03 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Tagesbericht, Welt (lauf.py, Arbeitsplaner 513 Anna, Kampf 1068 Britta, Figur 1675 Carla, Werkzeug 1964 Dana, Arbeitsplaner 1971 Elke, Tagesbericht 448, Welt 1566 Frieda)
- 10:05 23.11.: Startsperre 10:05 Start Werkzeug (lauf.py, Werkzeug 1992 Emil)
- 10:12 23.11.: Startsperre 10:12 Start Arbeitsplaner, Figur, Arbeitsplaner, Tagesbericht, Welt (lauf.py, Arbeitsplaner 513 Carla, Figur 1675 Dana, Arbeitsplaner 1961 Elke, Tagesbericht 448, Welt 1566 Frieda)
- 10:45 23.11.: Startsperre 10:45 Start Figur, Werkzeug, Arbeitsplaner, Tagesbericht, Sokrates, Prüfer (lauf.py, Figur 1675 Tanja, Werkzeug 1964 Ulla, Arbeitsplaner 513 Vera, Tagesbericht 448, Sokrates 1989, Prüfer 1971 Wiebke)
- 11:28 23.11.: Startsperre 11:28 Start Kampf, Sokrates (Handstart ohne lauf.py, nachgetragen 13:59: Tamara 1068, Sokrates Leitung)
- 12:04 23.11.: Startsperre 12:04 Start Prüfer (Handstart ohne lauf.py, nachgetragen 13:59: Hanna 1675)
- 13:06 23.11.: Startsperre 13:06 Start Figur (Handstart ohne lauf.py, nachgetragen 13:59: Ulrike 1694)
- 13:52 23.11.: Startsperre 13:52 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Arne, Kampf 1068 Benno, Figur 1675 Carla, Werkzeug 1964 Dana, Arbeitsplaner 1961 Erna, Prüfer 1675 Fritz)
- 14:01 23.11.: Startsperre 14:01 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1997 Anna)
- 14:05 23.11.: Startsperre 14:05 Start Werkzeug (lauf.py, Werkzeug 1997 Bettina)
- 14:06 23.11.: Tamara (1068, 4,78 $) und Anna (1997-Planer, 1,24 $) archiviert, Kosten gebucht; Bettina (Werkzeug 1997 Eilt) läuft seit 14:05
- 14:24 23.11.: Startsperre 14:24 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1999 Werner)
- 14:38 23.11.: Startsperre 14:38 Start Werkzeug (lauf.py, Werkzeug 1999 Zora)
- 14:43 23.11.: Startsperre 14:43 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2001 Alma)
- 14:44 23.11.: Startsperre 14:44 Start Kampf (lauf.py, Kampf 1068 Conrad; dritter Platz nach Chef 14:43)
- 15:05 23.11.: Startsperre 15:05 Start Arbeitsplaner, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Gustav, Arbeitsplaner 1961 Hugo, Prüfer 1997 Ingo)
- 15:07 23.11.: Takt 15:05: START Arbeitsplaner 513 Gustav, Arbeitsplaner 1961 Hugo, Prüfer 1997 Ingo nicht ausgeführt (Laufsperre bis 28.11.: kein Spiel, nicht Eilt; 1997 von Hanna schon geprüft, ja 14:49); NACHRICHT-Zeilen an Disponent/Rita/Zora (Werkzeug-Zeilen, Figur 1675-Ü4) wegen Laufsperre ohne Wirkung; LIEGT-Leichenprüfung (Grund: Laufsperre) nicht einzeln bedient, an Sokrates gemeldet
- 15:08 23.11.: LIEGT 100 Zeilen, Grund Laufsperre (Chef 14:43; Sokrates 15:09: bis Sa 28.11., 20:00 nicht einzeln, ausgenommen Eilt, Spiel, Chefworte)
- 15:22 23.11.: Startsperre 15:22 Start Sokrates (lauf.py, Leitung; Neustart bei 435 Tsd. Token, Vorgänger session_01Hmoj76v3qfGY8UGYcLqL1A, Titel „Sokrates – Leitung (23.11., 15:22)“)
- 15:33 23.11.: Startsperre 15:33 Start Werkzeug (lauf.py, Werkzeug 2001 Fenja; Eilt, Sokrates 15:33)
- 15:39 23.11.: alter Sokrates (session_01Hmoj76v3qfGY8UGYcLqL1A, 452 Tsd. Token, 28,43 $) archiviert, Kosten auf 1988; Nachfolger session_01Hmoj78wagZZvirW9ecr5Pc
- 15:43 23.11.: Startsperre 15:43 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1999 Greta; auch 1694, Chefworte 15:42)
- 15:51 23.11.: Startsperre 15:51 Start Figur, Werkzeug (lauf.py, Figur 1694 Isolde, Werkzeug 1999 Jutta; Rufname Hanna von lauf.py war doppelt)
- 15:55 23.11.: Startsperre 15:55 Start Werkzeug (lauf.py, Werkzeug 2001 Ida; Nachfolger Fenja, Eilt)
- 16:05 23.11.: Startsperre 16:05 Start Arbeitsplaner, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Karla, Arbeitsplaner 1961 Lutz, Prüfer 1997 Marta)
- 16:07 23.11.: Takt 16:05: START Arbeitsplaner 513 Karla, Arbeitsplaner 1961 Lutz, Prüfer 1997 Marta nicht ausgeführt (513/1961 weder Spiel noch Eilt, Laufsperre; Prüfer-Start war Folge einer nicht geschlossenen Zeile 1997-Ü3, geschlossen); LIEGT 103 Zeilen, Grund Laufsperre (Chef 14:43); Laufsperre 3 von 3 laufen (Conrad, Ida, Isolde), Jutta 1999 und Conrad 1068 fertig, Prüfung Hanna
- 16:19 23.11.: Startsperre 16:19 Start Werkzeug (lauf.py, Werkzeug 2002 Anna; Nachfolger Ida, Eilt)
- 16:57 23.11.: Startsperre 16:57 Start Werkzeug (lauf.py, Werkzeug 2001 Beate; letzter enger Lauf, Eilt)
- 17:04 23.11.: Startsperre 17:04 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Lutz, Kampf 1589.2 Marta, Figur 1675 Otto, Werkzeug 1964 Oda, Arbeitsplaner 1971 Pit, Prüfer 1999 Rudi)
- 17:06 23.11.: Takt 17:04: START Figur 1675 Otto, Prüfer 1999 Rudi, Arbeitsplaner nicht ausgeführt (Figur 1675 wartet bis 17:25, weil Startsperren 17:04 20 Minuten als laufend zählen; Prüfer-Start war Rest alter Prüferzeilen, geschlossen; Planer 513/1961 mit --ohne ausgeschlossen); Hanna (12,64 $ auf 1675) und Conrad (4,27 $ auf 1068) archiviert; LIEGT 124 Zeilen, Grund Laufsperre (Chef 14:43)
- 17:26 23.11.: Startsperre 17:26 Start Figur (lauf.py, Figur 1675 Carla; Rückläufer 1675-Ü4)
- 17:56 23.11.: Startsperre 17:56 Start Arbeitsplaner, Kampf, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Marta, Kampf 1589.2 Otto, Werkzeug 1965 Oda, Arbeitsplaner 1716 Pit, Prüfer 1675 Rudi)
- 17:59 23.11.: Takt außer der Reihe 17:56 (Alter Ego 17:57): ausgeführt START Kampf 1589.2 Otto, START Prüfer 1675 Rudi (Carla fertig 17:43); nicht ausgeführt (Laufsperre, weder Spiel noch Eilt): Planer 513 Marta, Planer 1716 Pit, Werkzeug 1965 Oda. Zu Takt 17:04: START Kampf 1589.2 Marta, Werkzeug 1964 Oda, Planer 513 Lutz, Planer 1971 Pit waren in der Ausgabe, wurden von mir NICHT gesehen (Filter beim Lesen verdeckte die Zeilen) und nicht ausgeführt; Kampf 1589.2 hätte starten dürfen (Spiel) und startet jetzt als Otto. Carla (4,05 $ auf 1675) und Beate (1,01 $ auf 2001) archiviert; LIEGT Grund Laufsperre
- 18:04 23.11.: Startsperre 18:04 Start Arbeitsplaner, Figur, Arbeitsplaner, Werkzeug (lauf.py, Arbeitsplaner 513 Oda, Figur 1675 Pit, Arbeitsplaner 887 Ruth, Werkzeug 1971 Sven)
- 18:05 23.11.: Takt 18:04: ausgeführt START Werkzeug 1971 Sven (Eilt, 1971-Ü9 Rückläufer); nicht ausgeführt (Laufsperre: weder Spiel noch Eilt bzw. schon erledigt): Planer 513 Oda, Planer 887 Ruth, Figur 1675 Pit (1675-Ü4 stand offen, Carla war fertig, Zeile geschlossen); Figur 1676 startet ab 18:25 (Startsperre Figur 18:04); LIEGT 126 Zeilen, Grund Laufsperre (Chef 14:43)
- 18:10 23.11.: Isolde (1694, 8,11 $) archiviert (wartet auf den Chef, Chefsache entscheiden/1694-grossaxt-stiel.md, Alter Ego 18:09: hält keinen Spielplatz); 1694 startet nach dem Urteil des Chefs neu; Platz geht an Figur 1676/431
- 18:26 23.11.: Startsperre 18:26 Start Figur (lauf.py, Figur 1676 Hedwig; Alter Ego 17:59 Ja)
- 18:57 23.11.: Startsperre 18:57 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Pit, Kampf 1589.2 Ruth, Figur 1653 Silke, Werkzeug 1964 Tanja, Arbeitsplaner 1961 Ulla, Prüfer 1971 Vera)
- 19:01 23.11.: Takt 18:57 (Alter Ego 18:58: kein Handfilter, alle lauf.py-Zeilen ausführen): ausgeführt START Planer 513 Pit (mit allen offenen Planerzeilen, zuerst 1676-Ü1, 1589.2-Ü8), Planer 1961 Ulla, Figur 1653 Silke, Werkzeug 1964 Tanja, Prüfer 1971 Vera; nicht ausgeführt START Kampf 1589.2 Ruth (1589.2-Ü8 Planer-Zeile offen, Otto 17:57 endete ohne Arbeit: Auftrag vor Start); archiviert Otto (0,38 $ auf 1589.2), Sven (0,81 $ auf 1971), Hedwig (0,81 $ auf 1676, wartet auf Auftrag 1676-Ü1); LIEGT 126 Zeilen, Grund Laufsperre
- 19:03 23.11.: Startsperre 19:03 Start Kampf, Arbeitsplaner (lauf.py, Kampf 1589.2 Volker, Arbeitsplaner 1961 Wiebke)
- 19:05 23.11.: Startsperre 19:03 Kampf 1589.2 Volker (ausgeführt), Planer 1961 Wiebke nicht ausgeführt (Werkzeug ohne Eilt, Sokrates 19:03 Ausnahme)
- 20:04 23.11.: Startsperre 20:04 Start Arbeitsplaner, Werkzeug, Arbeitsplaner, Sokrates, Prüfer (lauf.py, Arbeitsplaner 513 Wiebke, Werkzeug 1961 Zeno, Arbeitsplaner 1716 Arne, Sokrates 1694, Prüfer 1964 Benno)
- 20:07 23.11.: Takt 20:04: ausgeführt START Prüfer 1964/1653 Benno; Chef 👍 19:55 zu 1675 umgesetzt (Archiv, Chefsache-Datei gelöscht, 1675-Ü7 an Figur: nach main); Tanja (1964, 3,55 $) archiviert; nicht ausgeführt: Planer 513 (ruht, Fund 2005), Planer 1716 (Prüfer-Vorgang schon gebaut), Werkzeug 1961 (Muss ohne Eilt), START Sokrates + ARCHIVIERE Sokrates (365 Tsd. Token, ohne Übergabe: Neustart angefordert); LIEGT 125 Zeilen, Grund Laufsperre
- 20:07 23.11.: Startsperre 20:07 Start Sokrates (lauf.py, Leitung; Neustart bei 365 Tsd. Token, Vorgänger session_01Hmoj78wagZZvirW9ecr5Pc, Titel Sokrates – Leitung (23.11., 20:07))
- 21:01 23.11.: Startsperre 21:01 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner (lauf.py, Arbeitsplaner 513 Zeno, Kampf 1603 Arne, Figur 1675 Clara, Werkzeug 1961 Dana, Arbeitsplaner 1716 Dirk)
- 21:03 23.11.: Takt außer der Reihe 21:01 (Alter Ego 21:01): ausgeführt START Kampf 1603 Arne; Silke (Figur) per Nachricht auf 1675 → nach main gesetzt statt neuem Figur-Start (Clara); Volker (1589.2, 3,14 $) archiviert, Fragen an Sokrates übertragen; nicht ausgeführt: Planer 513 (ruht), Planer 1716 (gebaut), Werkzeug 1961 (Muss ohne Eilt); LIEGT 124 Zeilen, Grund Laufsperre
- 21:05 23.11.: Takt 21:03: keine START-Zeile (Startmarke 21:01 jünger als 20 Minuten); NACHRICHT Figur 1675-Ü7 an Silke schon gegeben; LIEGT 124 Zeilen, Grund Laufsperre (Chef 14:43)
- 21:06 23.11.: Startsperre 21:06 Start Arbeitsplaner, Werkzeug, Arbeitsplaner (lauf.py, Arbeitsplaner 513 Clara, Werkzeug 1961 Dana, Arbeitsplaner 2006 Dirk)
- 21:08 23.11.: Takt 21:06 (mit --ohne 513, 1716): START Arbeitsplaner Dirk 2006 ausgeführt (session_01Hmoj7794guYDJvxySgKGQE); START Werkzeug Dana 1961 von der Auto-Prüfung abgelehnt (nicht umgangen); START Arbeitsplaner Clara 513 nicht ausgeführt (513 ruht, Alter Ego/Sokrates, --ohne griff nicht); Kampf 1589.2 nicht startbar, Arne belegt Kampf (1603); LIEGT Laufsperre
- 22:03 23.11.: Startsperre 22:03 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner, Sokrates (lauf.py, Arbeitsplaner 513 Clara, Kampf 1603 Dana, Figur 1675 Doris, Werkzeug 1961 Erna, Arbeitsplaner 2006 Fritz, Sokrates 1589.2)
- 22:08 23.11.: Takt 22:03 (--ohne 513, 1716): START Fritz (Planer 2006), Dana (Kampf 1603), Doris (Figur 1675 + 1653-Ü6), Sokrates neu ausgeführt; START Erna (Werkzeug 1961) von Auto-Prüfung abgelehnt (zweiter Fall, Fund Sokrates); Clara (Planer 513) nicht gestartet (ruht, Fund 2005); archiviert Arne, Silke, Dirk, Kosten 1603 2,87, 1653 5,26, 2006 1,20; alter Sokrates (76c6) wartet auf Meldung des Nachfolgers; 1653 Chef 👍 22:02 → Archiv, Chefsache gelöscht, Übergabe Figur nach main
