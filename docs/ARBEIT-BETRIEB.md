# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll. Aufgeräumt 23.11., 08:46 (1688): was seit dem Umschalten 22.11., 16:17 nicht mehr gilt, steht in Git (`git log -p docs/ARBEIT-BETRIEB.md`, Stand vorher 2c67215a4). Befristetes nur als „Zu <Nr>, bis erledigt, streicht: <Rolle>“.

**Nie archivieren:** (keine; Sokrates …777MV8Hv8ps2Js5voW freigegeben, Chef 18.11., 08:45)

Jede Startnachricht für Figur, Bild oder Film: „`LISTE-HANDWERK-FIGUR-PRUEFBILD.md` vor dem Lauf lesen und das Bild danach dagegen prüfen“ (1625, Sokrates 07:20).

**Nächste freie Vorgangsnummer: 2040** (zuletzt 2039 Werkzeug 25.11. 19:28:44 733c) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

**Niederlassung ruht seit 17.10., 19:58** (Schalter, 159; Chef: „Habe Pro gekündigt, steht nur noch auf Free“): Ford 2 entfällt (650.1, Chef 08.11., 13:36; Regeln in `alt/LISTE-FORD2.md`), Niederlassung bleibt als Gedanke; Guthaben nur Max. Wiedereinschalten = Zeile streichen, Einrichtung aus Git (`LISTE-NIEDERLASSUNG.md` bis `f3ec7200`)

**Ford: Pilot** (seit Sa 17.10., 21:05; 81g; Schalter für `lauf.py`, gilt für den Disponenten)

**Herzschlag (1764, seit 21.11.; 1997):** lauf.py pusht selbst: jeder vollständige Lauf, ohne Schalter, schreibt am Ende Tabelle und Zeitmarke von `ARBEIT-BESETZUNG.md` und pusht sie; nur bei „HERZSCHLAG NICHT GEPUSHT“ selbst committen und pushen.

**„Chefsache“ (63): `docs/chefsache/`** (Übersicht `docs/chefsache/README.md`; https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache) · Vorgangsarchiv: `docs/VORGANGSARCHIV.md` · Prüfbericht: `docs/PRUEFBERICHT.md`

**Alle Sperren aufgehoben (Chef 07.11., 20:2x):** alle Rollen startbar; Vorrang Fehler aus den Tests des Chefs (wiederholte zuerst, 620.1). Es gelten weiter: 621 A (eine Probe je Aussehen-Thema), 488 (Aussehen eingefroren bis zum Durchspielen), 287 nach dem nächsten Bild des Guthabens.

**Chef abwesend:** bis Fr 27.11., streicht: Disponent. **Chef 22.11., 17:00 (an Sokrates, Chat):** „ab morgen bis einschließlich Freitag, sehr viel unterwegs und werde ganz wenig Zeit haben“ (23.–27.11.): was am Chef hängt, sammelt sich in der Chefsache; **Chef 17:04:** „auf Telegram einen Daumen hoch oder runter bei einer Sache zu machen [ist 100-mal leichter], als mich jetzt hier in die Codesitzungen einzuloggen“: aussagekräftige Einzelpunkte (Bild mit Frage, Freigabe mit einem Satz) per Telegram zum 👍/👎, keine langen Texte.

**Guthaben:** **Chef 25.11., 10:01 (an Alter Ego, Chat):** „63 Prozent Wochenlimit“ (seit 24.11., 06:53 +13 % in 27 h ≈ 0,48 %/h; so 80 % etwa Do 26.11., 21:30, 100 % etwa Sa 28.11., 15:00; tragbar bis Sa 20:00 ≈ 0,45 %/h; Sokrates 10:05: drei bleiben, Chef gefragt); davor **Chef 24.11., 06:53 (an Sokrates, Chat):** „50 Prozent“ (seit 23.11., 06:43 +12 % in 24 h ≈ 0,5 %/h; so 80 % etwa Do 26.11., 19:00, 100 % etwa Sa 28.11., 11:00; tragbar bis Sa 20:00 ≈ 0,46 %/h; Sokrates 06:55: drei bleiben); davor **Chef 22.11., 19:38 (an Sokrates, Chat):** „36 Prozent“ (seit 16:52 +5 % in 2¾ h ≈ 1,8 %/h; so 100 % etwa Mo 23.11., 07:00; tragbar bis Sa 28.11., 20:00 ≈ 0,44 %/h); davor **Chef 22.11., 16:52 (an Sokrates, Chat):** „Prozentmark hat aktuell 31“ (Reset Sa 21.11., 20:00); ältere Stände in Git · **kein Limit-Reset vorhanden** (Chef 18.11., 12:16: „Hier gibt es kein Zurücksetzen.“) · **Max 20x seit 25.10., ~11:00**: 287 gilt (ab 80 % `lauf.py --nur-muss`, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand, nichts nachkaufen)

**Jetzt installieren:** Release 0.1.867 (18.10., 20:09; https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases/tag/v0.1.867).

- **Disponent:** wer es ist, steht in `ARBEIT-BESETZUNG.md` (Titel „Rufname – Disponent – …“, 2035). Neustart ab 300 Tsd. Token: der Disponent startet seinen Nachfolger selbst mit der START-Zeile aus `lauf.py --start Disponent <Nr>`; fällt er aus, die Wache (Chef 21.11., 20:50; Starter archiviert seit 23.11., 13:54, Alter Ego 25.11., 19:54). Uhren an die Sitzung: `trig_01Jog7nqdG9EM9EeKddJnPfQ` und „Disponent-Lauf“ `trig_01JyUFnFGzKzNd1KdsU583gN` (je `3 * * * *`, Prompt mit `--besetzung`).
- **Zu 287, bis erledigt (Sa 28.11., 20:00), streicht: Disponent.** **Laufsperre ab 23.11., 07:00 (Sokrates, Guthaben 38 % Chef 06:43):** höchstens drei Fachkräfte zugleich (Chef 23.11., 14:43 „lasst den einen dritten aufmachen“, vorher zwei), nur Spiel (Regeln, Kampf, Figur, Welt) und Eilt; Werkzeug nur Eilt; Kür ruht; Prüfer und Planer dazu; frei: Wache, Sokrates, Rückläufer des Chefs; 23–7 keine Fachkräfte, lauf.py aber jeden Takt; Laufende beenden ihren Schritt, danach archivieren statt nachstarten. Folge: 1589.2-Ü3 (Kampf, Rückläufer), 1068-Ü2 (Kampf, Nachfolger Zeno ab 20b158641), 1694 (Figur), 1603 (Kampf), 1961/1964/1965/1960/1520 (Werkzeug, nur Eilt).
- **Wache (aktuell)** `session_01Hmoj77JCMhf2hwMABWtXB4` (Handstart Chef 24.11., 07:01, Kopiertext C; Vorgängerin Clara `session_01Hmoj78CoScvkasiYmBbPTG` an der Token-Sperre 318 Tsd., archivieren: Disponent); Uhr „Wache“ `trig_01Wmm3Nxhn7nPjqG8Q1VgxZs` (:33), alte Uhr gelöscht.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug. Startsperren bleiben mindestens bis zum Archivieren der Sitzung (`rufname.py` ordnet Rufnamen darüber der Rolle zu, 1957).

STARTSPERRE - 16:38 25.11.: Startsperre 16:38 Start Sokrates (lauf.py, 1988)
STARTSPERRE - 17:01 25.11.: Startsperre 17:01 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2028 Moritz)
STARTSPERRE - 17:09 25.11.: Startsperre 17:09 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2034 Anna)
STARTSPERRE - 17:18 25.11.: Startsperre 17:18 Start Kampf (lauf.py, Kampf 1708 Anna)
STARTSPERRE - 17:35 25.11.: Startsperre 17:35 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2035 Anna)
STARTSPERRE - 17:38 25.11.: Startsperre 17:38 Start Figur (Handstart, Figur 2029 Dora)

- 17:40 25.11.: Alter Ego alt (…75PCSH) archiviert (2013: 12,60 $); neuer …78S1BS meldet sich.
- 17:38 25.11.: Notstart Alter Ego (Nr. 2013, kein Profil, Sokrates 17:37, Übergabe c4b182bd0): session_01Hmoj78S1BS7Gx4Jksc3zTh; alter (…75PCSH) wird nach Meldung der Kennung archiviert.
- 17:31 25.11.: 2034-Ü1 (Teil A Helme) auf Sokrates 17:29 nicht gestartet, erledigt; 2034-Ü4 (Teil 0 Signatur-Probe und Abzug, Figur) angenommen; Start nach Laufsperre, Reihenfolge 2029, 2034-Teil 0, 2032, 2033.
- 17:20 25.11.: START Kampf Berit 1708 (session_01Hmoj76EdmopCkFv7PLLpSS, Deckel 50 $); 1708-Ü2 erledigt; 2029-Ü12 und 2034-Ü1 (Auftrag steht, Anna) angenommen, Starts Figur 2029, 2034-A, 2032, 2033 folgen, sobald Plätze frei (Inge, Maja, Berit = 3).
- 17:19 25.11.: Prüfer Jonas (…75ccpj, 2017: 43,58 $) archiviert (Alter Ego Vertretung 7415afc91: jede Prüfung ein frischer Prüfer); nächste Prüfer-Zeile startet neuen Prüfer über lauf.py.
- 17:11 25.11.: Planerin Anna session_01Hmoj77kiHyjP2FKgnYKEmP für 2034 (Rest MakeHuman-Pakete) und 2029-Ü11 (Chef 17:07 „alles“) gestartet; Maja geweckt (Sokrates, Ü23); Figur-Start 2029 nach Auftrag, Handstarts 1708/2032/2033 nach Laufsperre.
- 17:09 25.11.: Planer Moritz: Auftrag 2032 (Rowena Gürtel, Figur) und 2033 (Thessa Faust-Tusche, Technik) steht, 2028-Ü6 erledigt; Starts 1708, 2032, 2033 wegen Laufsperre ab ca. 17:20 nacheinander (Deckel je 50 $).
- 17:07 25.11.: Hanna (2029) archiviert, 1,89 $; 2029-Ü10 war schon erledigt (Sokrates will sie offen bis Chefantwort: Nacken/.import als eigene Zeile an Figur nach Chef-Entscheid).
- 17:03 25.11.: Prüfer 17:00: 2029 ja (Vorlage über Sokrates, Ü9/Ü10 erledigt), 2028 nein, Auftrag → Planer Moritz session_01Hmoj7A4gb2iWB6Stj3R5Bh (Deckel 50 $).
- 17:00 25.11.: Takt 16:58: Nora (2028, 16,47 $) archiviert; Prüfer (…75ccpj) 2028-Ü4 und 2029-Ü8 per Nachricht geweckt (Sokrates 16:58); START Planer Nils 887, Planer Paula 1484, Kampf Olga 1589.4, Tagesbericht nicht ausgeführt (ruht/Werkzeug/Maja läuft/Chef-Ruhe); lauf.py-Startsperre-Marken irrtümlich gesetzt.
- 16:41 25.11.: Chef 16:38 (über Sokrates): Deckel mindestens 50 $ je Vorgang, darunter kein Halt; 2029 Hanna Deckel 50 $ (Halt 45 $) gemeldet; 1708 Frauke 50 $.
- 16:41 25.11.: Sokrates alt (…77b3dQ) archiviert (1988: 18,12 $); neuer …77uPSf meldet sich.
- 16:40 25.11.: Sokrates neu session_01Hmoj77uPSfmHFTcgkb3sHW (Nr. 1988); alter (…77b3dQ) wartet auf dessen Meldung.
- 16:39 25.11.: Alter Ego alt (…796ziG) archiviert (2013: 9,43 $, gesamt 24,70 $); Handstart Sokrates (Nr. 1988, Neustart Kontext 400 Tsd.), alter Sokrates (…77b3dQ) bleibt bis Meldung des neuen.
- 16:38 25.11.: Notstart Alter Ego (Nr. 2013, kein Profil, Sokrates 16:40): session_01Hmoj75PCSHUvX4ZVftYC3X; alter (…796ziG) wird nach Meldung des neuen archiviert.
- 16:29 25.11.: Sokrates-Takt 16:28: START Figur Inge 2031 (session_01Hmoj77df8z9qQNfMEs9AZr), Figur Hanna 2029 Helm neu (session_01Hmoj75a9zo2aDj5uEwse7b, nach --import), Planerin Frauke 1708 Blut am Trefferpunkt (session_01Hmoj77B3VKcZAquD9rRUKf, Chef 👍 16:04); 2031-Ü1 und 1708-Ü1 angenommen/erledigt; Fachkräfte Maja 1589.4, Inge, Hanna (3). 2028-Ü4 beim Prüfer.
- 16:08 25.11.: Takt 16:04: Vera (2029, 1,25 $ -> 2029 gesamt 15,32 $) und Selma (2024, 20,44 $ -> gesamt 21,87 $, Chef 👍 16:04) archiviert; 2028-Ü3 (Prüfer nein) an Nora; 2031-Start von lauf.py angehalten (Startsperre-Marken, Zeile 16:07 oben war kein Start), Wiedervorlage 16:35; Kampf-START Nils/887/448 nicht.
- 15:36 25.11.: START Figur Vera 2029 Helm-Bildlauf (session_01Hmoj77vQTHukmT1xcgH9Ja, Prüfer ja Lauf frei 15:05); Fachkräfte Maja 1589.4, Selma 2024, Vera 2029 = 3; 2031 wartet auf Platz; Nora (2028, 13,11 $) idle, nicht archiviert (Prüferstand 2028 offen).
- 15:10 25.11.: 2029-Ü6 (Prüfer ja, Lauf frei Helm): Figur-Start von lauf.py angehalten (3 laufen inkl. Startsperre-Marken); Wiedervorlage 15:37 per send_later; Zeile 15:09 „Startsperre Figur 2029 Vera“ war kein Start.
- 15:08 25.11.: Takt 15:04: Prüfer 2029-Ü5; Ute (2029, 12,60 $) und Lutz (2031, 1,82 $) archiviert; START Kampf Marta/Planer Lotte 887/Tagesbericht und NACHRICHT 2029-Ü4 an Nora nicht (veraltet bzw. ruht bzw. Chef-Ruhe); 2031 Figur wartet auf Sokrates-Wort (Deckel 60 $).
- 11:52 25.11.: Startsperre 11:51 Start Sokrates (selbst, Neustart Kontext 401 Tsd., Übergabe 8baebbf2b)
- 12:04 25.11.: Startsperre 12:04 Start Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Gerda, Tagesbericht 448)
- 12:18 25.11.: Startsperre 12:18 Start Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Gerda, Tagesbericht 448)
- 12:20 25.11.: Startsperre 12:19 Start Figur (lauf.py, Figur 1654 Lena)
- 12:21 25.11.: Startsperre 12:20 Start Figur (lauf.py, Figur 2024 Selma)
- 13:04 25.11.: Startsperre 13:04 Start Arbeitsplaner, Figur, Arbeitsplaner, Tagesbericht, Sokrates (lauf.py, Arbeitsplaner 887 Heike, Figur 2026 Ida, Arbeitsplaner 2028 Jana, Tagesbericht 448, Sokrates 1589.4)
- 13:10 25.11.: Startsperre 13:09 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2029 Mia)
- 13:11 25.11.: Startsperre 13:10 Start Figur (lauf.py, Figur 2028 Nora)
- 13:15 25.11.: Startsperre 13:14 Start Figur (lauf.py, Figur 2029 Ute)
- 13:19 25.11.: Startsperre 13:18 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1694 Tina)
- 14:04 25.11.: Startsperre 14:04 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Karla, Arbeitsplaner 2031 Lutz, Tagesbericht 448)
- 15:04 25.11.: Startsperre 15:04 Start Arbeitsplaner, Kampf, Tagesbericht (lauf.py, Arbeitsplaner 887 Lotte, Kampf 1589.4 Marta, Tagesbericht 448)
- 15:09 25.11.: Startsperre 15:08 Start Figur (lauf.py, Figur 2029 Vera)
- 15:35 25.11.: Startsperre 15:34 Start Figur (lauf.py, Figur 2029 Vera)
- 16:04 25.11.: Startsperre 16:04 Start Arbeitsplaner, Kampf, Tagesbericht (lauf.py, Arbeitsplaner 887 Marta, Kampf 1589.4 Nils, Tagesbericht 448)
- 16:08 25.11.: Startsperre 16:07 Start Figur (lauf.py, Figur 2031 Inge)
- 16:26 25.11.: Startsperre 16:25 Start Figur (lauf.py, Figur 2031 Inge)
- 16:27 25.11.: Startsperre 16:26 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1708 Frauke); Figur Inge 2031 gestartet (session_01Hmoj77df8z9qQNfMEs9AZr, Deckel 60 $, Halt 54 $)
- 16:28 25.11.: Startsperre 16:27 Start Figur (lauf.py, Figur 2029 Hanna)
- 16:58 25.11.: Startsperre 16:58 Start Arbeitsplaner, Kampf, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Nils, Kampf 1589.4 Olga, Arbeitsplaner 1484 Paula, Tagesbericht 448)
- 17:04 25.11.: Startsperre 17:04 Start Tagesbericht (lauf.py, 448)
- 17:06 25.11.: Takt 17:04: Planer Moritz 2028 gestartet (…7A4gb2); 1708-Ü1 erledigt, Ü2 angenommen, Handstart Kampf 1708 durch Laufsperre (Startsperre-Marke 16:58 + Planer als Sonstige gezählt) angehalten, nachholen ca. 17:20; Maja blockiert (zwei Entscheide) an Sokrates; Tagesbericht/Planer 887/Kampf Olga nicht gestartet.
- 17:35 25.11.: Startsperre 17:35 Start Kampf, Arbeitsplaner, Tagesbericht (lauf.py, Kampf 1589.4 Paula, Arbeitsplaner 887 Rita, Tagesbericht 448)
- 17:38 25.11.: Planerin Clara 2035 (session_01Hmoj76hq8e8pFbUVhViJFL); Figur 2029 durch Laufsperre (Marke Kampf 17:35 aus lauf.py-Vorschlag) angehalten, nachholen ab 17:56; Fund und Rückfrage (sechs Muss-Aufträge Werkzeug) an Sokrates.
- 17:38 25.11.: START Figur Dora 2029 von Hand (session_01Hmoj79WtehTiJaAd5sb7FC, Deckel 50 $; Sokrates 17:40: Marke für nicht ausgeführten Vorschlag zählt nicht); Reihenfolge weiter 2034 Teil 0, 2032, 2033.
- 00:08 24.11.: Startsperre 00:08 Start Prüfer (lauf.py, Prüfer 2001 Anna)
- 00:17 24.11.: Startsperre 00:17 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2013 Britta)
- 07:02 24.11.: Startsperre 07:02 Start Arbeitsplaner, Kampf, Figur, Werkzeug, Arbeitsplaner (lauf.py, Arbeitsplaner 513 Carla, Kampf 1603 Dana, Figur 1694 Elke, Werkzeug 1960 Frieda, Arbeitsplaner 2012 Gerda)
- 07:24 24.11.: Startsperre 07:24 Start Arbeitsplaner, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 513 Gustav, Arbeitsplaner 1520 Heike, Prüfer 1960 Ida)
- 07:29 24.11.: Startsperre 07:29 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Heike, Arbeitsplaner 1589.3 Ingo)
- 07:48 24.11.: Startsperre 07:48 Start Werkzeug, Tagesbericht (lauf.py, Werkzeug 2011 Ilse, Tagesbericht 448)
- 08:03 24.11.: Startsperre 08:03 Start Arbeitsplaner, Kampf, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 1716 Jana, Kampf 1589.3 Karla, Arbeitsplaner 2009 Lena, Prüfer 2011 Marta)
- 08:25 24.11.: Startsperre 08:25 Start Kampf, Figur, Werkzeug, Arbeitsplaner (lauf.py, Kampf 1589.2 Lutz, Figur 1694 Moritz, Werkzeug 2012 Nora, Arbeitsplaner 431 Olga)
- 08:37 24.11.: Startsperre 08:37 Start Figur (lauf.py, Figur 431 Otto)
- 08:46 24.11.: Startsperre 08:46 Start Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 1785 Paula, Prüfer 2012 Rita)
- 09:03 24.11.: Startsperre 09:03 Start Kampf, Figur, Werkzeug (lauf.py, Kampf 1589.3 Sabine, Figur 431 Tanja, Werkzeug 2012 Ulla)
- 10:04 24.11.: Startsperre 10:04 Start Arbeitsplaner, Figur, Werkzeug, Arbeitsplaner, Sokrates (lauf.py, Arbeitsplaner 1716 Uwe, Figur 431 Vera, Werkzeug 2012 Wiebke, Arbeitsplaner 1973 Zora, Sokrates 1589.2)
- 10:27 24.11.: Startsperre 10:27 Start Arbeitsplaner, Figur, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 1716 Vera, Figur 431 Wiebke, Werkzeug 2013 Zeno, Arbeitsplaner 1753 Arne, Prüfer 1589.3 Benno)
- 11:03 24.11.: Startsperre 11:03 Start Arbeitsplaner, Kampf, Werkzeug, Arbeitsplaner, Prüfer (lauf.py, Arbeitsplaner 1716 Bettina, Kampf 1603 Carla, Werkzeug 2013 Dirk, Arbeitsplaner 1270.7 Emil, Prüfer 2013 Fritz)
- 11:26 24.11.: Startsperre 11:26 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Erna, Arbeitsplaner 2017 Fenja)
- 11:28 24.11.: Startsperre 11:28 Start Werkzeug (lauf.py, Werkzeug 2017 Anna)
- 12:03 24.11.: Startsperre 12:03 Start Arbeitsplaner, Kampf, Figur, Arbeitsplaner, Sokrates, Prüfer (lauf.py, Arbeitsplaner 1716 Fenja, Kampf 1589.3 Gustav, Figur 1694 Heike, Arbeitsplaner 2017 Jana, Sokrates 1589.3, Prüfer 2017 Jonas)
- 12:08 24.11.: Startsperre 12:08 Start Arbeitsplaner, Kampf, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Gustav, Kampf 1603 Heike, Figur 431 Jana, Arbeitsplaner 2017 Jutta)
- 12:21 24.11.: Startsperre 12:21 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Gustav, Figur 1694 Heike, Arbeitsplaner 1484 Jana)
- 12:47 24.11.: Startsperre 12:47 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Heike, Figur 1694 Jana, Arbeitsplaner 2019 Jutta)
- 13:04 24.11.: Startsperre 13:04 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Jutta, Arbeitsplaner 1484 Karla)
- 14:04 24.11.: Startsperre 14:04 Start Arbeitsplaner, Kampf, Figur, Arbeitsplaner, Sokrates (lauf.py, Arbeitsplaner 1716 Jutta, Kampf 1603 Karla, Figur 1694 Knut, Arbeitsplaner 1955 Lotte, Sokrates 1694)
- 14:28 24.11.: Startsperre 14:28 Start Arbeitsplaner, Kampf, Arbeitsplaner (lauf.py, Arbeitsplaner 1716 Jutta, Kampf 1603 Karla, Arbeitsplaner 1725 Knut)
- 15:05 24.11.: Startsperre 15:05 Start Arbeitsplaner, Kampf, Figur, Arbeitsplaner, Sokrates (lauf.py, Arbeitsplaner 1716 Jutta, Kampf 1603 Knut, Figur 431 Lotte, Arbeitsplaner 1933 Moritz, Sokrates 1694)
- 16:04 24.11.: Startsperre 16:04 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Knut, Arbeitsplaner 1128.3 Moritz)
- 17:05 24.11.: Startsperre 17:05 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Knut, Figur 431 Moritz, Arbeitsplaner 1137 Margit)
- 18:04 24.11.: Startsperre 18:04 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Knut, Figur 431 Moritz, Arbeitsplaner 1172 Margit)
- 18:39 24.11.: Startsperre 18:39 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Knut, Figur 1654 Moritz, Arbeitsplaner 1388 Margit)
- 18:44 24.11.: Startsperre 18:44 Start Arbeitsplaner, Kampf, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Margit, Kampf 1589.4 Nils, Arbeitsplaner 1507 Nadine)
- 19:04 24.11.: Startsperre 19:04 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Margit, Arbeitsplaner 1728 Nadine)
- 19:39 24.11.: Startsperre 19:39 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Margit, Arbeitsplaner 1773 Nadine)
- 19:41 24.11.: Startsperre 19:41 Start Kampf, Arbeitsplaner (lauf.py, Kampf 1589.4 Nadine, Arbeitsplaner 1774 Oda)
- 19:45 24.11.: Startsperre 19:45 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1794 Oda)
- 19:56 24.11.: Startsperre 19:56 Start Kampf (lauf.py, Kampf 1589.4 Oda)
- 20:46 24.11.: Startsperre 20:46 Start Arbeitsplaner, Figur, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Pit, Figur 1694 Rudi, Arbeitsplaner 1966 Sven)
- 21:03 24.11.: Startsperre 21:03 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Pit, Arbeitsplaner 1983 Rudi)
- 21:07 24.11.: Startsperre 21:07 Start Kampf, Figur (lauf.py, Kampf 1589.4 Pit, Figur 1694 Rudi)
- 21:14 24.11.: Startsperre 21:14 Start Arbeitsplaner, Arbeitsplaner (lauf.py, Arbeitsplaner 887 Sven, Arbeitsplaner 2010 Tanja)
- 22:04 24.11.: Startsperre 22:04 Start Arbeitsplaner (lauf.py, Arbeitsplaner 887 Tanja)
- 23:04 24.11.: Startsperre 23:04 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1603 Tanja)
- 00:03 25.11.: Startsperre 00:03 Start Sokrates, Arbeitsplaner (lauf.py, Sokrates 1989, Arbeitsplaner 1603 Anna)
- 01:04 25.11.: Startsperre 01:04 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1603 Anna)
- 07:04 25.11.: Startsperre 07:04 Start Arbeitsplaner, Figur (lauf.py, Arbeitsplaner 887 Anna, Figur 431 Britta)
- 08:04 25.11.: Startsperre 08:04 Start Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Benno, Tagesbericht 448)
- 09:03 25.11.: Startsperre 09:03 Start Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Benno, Tagesbericht 448)
- 09:55 25.11.: Startsperre 09:55 Start Arbeitsplaner, Kampf, Figur, Tagesbericht (lauf.py, Arbeitsplaner 887 Benno, Kampf 1589.4 Carla, Figur 431 Dana, Tagesbericht 448)
- 09:58 25.11.: Startsperre 09:58 Start Arbeitsplaner (lauf.py, Arbeitsplaner 1694 Anna)
- 10:03 25.11.: Startsperre 10:03 Start Figur, Tagesbericht (lauf.py, Figur 1654 Dana, Tagesbericht 448)
- 10:09 25.11.: Startsperre 10:08 Start Figur (lauf.py, Figur 1694 Greta)
- 10:32 25.11.: Startsperre 10:31 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2026 Frieda)
- 11:03 25.11.: Startsperre 11:03 Start Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Gerda, Tagesbericht 448)
- 17:52 25.11.: Alter-Ego-Querprüfung: Frauke 1708 (1,62 $), Anna 2034 (3,07 $), Moritz 2028 (1,32 $), Clara 2035 (2,44 $) archiviert und gebucht; Liste: 2029, 1708, 2031, 1589.4 auf „in Arbeit“; aufgeräumt; keine Prüfer-Zeile offen; Fund: vorgang.py pruefen meldet 2018 Besitzer „Wochenzählung" ungültig.
- 17:53 25.11.: Disponent-Starter …79aK2Z archiviert (0,51 $, ohne Nummer).
STARTSPERRE - 18:00 25.11.: Startsperre 18:00 Start Figur, Figur (Handstart, Figur 2034 Edda, Figur 2032 Finja)
- 18:02 25.11.: START Figur Edda 2034 Teil 0 (session_01Hmoj77GxC2suK6CZCePZ2Y, Deckel 40 $) und Figur Finja 2032 (session_01Hmoj75yn4RXoAgS3pGhzE3, Deckel 50 $) von Hand; Fachkräfte arbeitend: Dora, Edda, Finja (Berit, Inge, Maja untätig, zählen nicht); 2033 (Technik) und 2035 (Werkzeug) folgen bei freiem Platz.
STARTSPERRE - 18:02 25.11.: Startsperre 18:02 Start Disponent (lauf.py, Disponent 1997 Anna)
- 18:04 25.11.: Neustart Disponent (Kontext über 300 Tsd.): Nachfolger session_01Hmoj77CqtJv41zq9EoMJMF mit Übergabe; neue Uhr trig_01ETQpAvjSVfcdY3oSVpy3xR (:03) an ihn, alte trig_01JyUFnFGzKzNd1KdsU583gN abgeschaltet; alter Disponent (…75wHERa) archiviert sich nach Meldung des Nachfolgers.
- 18:03 25.11.: Startsperre 18:03 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht, Prüfer (lauf.py, Arbeitsplaner 887 Rita, Arbeitsplaner 1484 Sabine, Tagesbericht 448, Prüfer 2031 Tanja)
- 18:04 25.11.: Startsperre 18:04 Start Tagesbericht (lauf.py, 448)
- 18:05 25.11.: Startsperre 18:05 Start Prüfer (lauf.py, Prüfer 2031 Anna)
- 18:06 25.11.: Takt 18:03 (Uwe, Nachfolger): START Prüfer Anna 2031-Ü2 von Hand (session_01Hmoj75cYryQ9PkT5EBjFQV); Vorschläge Planer 887 Rita, Planer 1484 Sabine, Tagesbericht 448 wie bisher nicht gestartet; Fachkräfte arbeitend: Dora, Edda, Finja (Laufsperre voll); 2033, 2035 warten; Vorgänger …75wHERa zum Archivieren benachrichtigt.
- 18:07 25.11.: Disponent alt (…75wHERa, 107,92 $, nicht gebucht, Nachfolger bucht) archiviert; Nachfolger …77CqtJv im Dienst seit 18:03.
- 18:07 25.11.: Startsperre 18:07 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2036 Anna)
- 18:08 25.11.: 2036 (Sokrates 18:07): Arbeitsplaner Bruno von Hand (session_01Hmoj783tfLMMcAjTyXD4BG), Rufname männlich nach Chef 18:04 statt lauf.py „Anna“; Reihenfolge 2033, 2036, 2035. Kosten alter Disponent …75wHERa 107,92 $ auf 1997 gebucht.
- 18:09 25.11.: Reihenfolge neu (Sokrates 18:11, Alter Ego in Vertretung, steht in 2035.md): 2035 Teil TOKEN-Zeile Eilt beim nächsten freien Platz, dann 2033, 2036, Rest 2035.
- 18:42 25.11.: Sokrates 18:42: Dora 2029 (7,11 $) und Bruno 2036 (1,00 $) archiviert und gebucht; Prüferin Anna weiter (WEITER 2034-Ü5, dann 2029-Ü13); Handstart Werkzeug 2035 TOKEN von lauf.py angehalten (Laufsperre, 2035 ohne Kl. Eilt), an Sokrates; 2031-Ü3 (Rückläufer Inge, 440 Tsd. Token) an Sokrates zur Entscheidung.
- 18:42 25.11.: Startsperre 18:42 Start Werkzeug (lauf.py, Werkzeug 2035 Anna)
- 18:43 25.11.: Startsperre 18:43 Start Sokrates (lauf.py, 0)
- 18:44 25.11.: Startsperre 18:44 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2036 Anna)
- 18:45 25.11.: Sokrates 18:45: Werkzeug Hedwig 2035 Teil TOKEN (Eilt, a6a3f24ad) gestartet (session_01Hmoj78Wv7RZiy8Cg7y8keo); Sokrates-Nachfolger (session_01Hmoj79nRJFPkqNxyZFA9e2, Übergabe 8997ea0d0); Planer Carsten 2036 Einwände Alter Ego (session_01Hmoj75bSt8gjnyigwtL9mS); Inge 2031 zum Push aufgefordert (unpushed_work), danach archivieren; 2031-Ü3 neue Figur bei freiem Platz. Fachkräfte arbeitend: Edda, Finja, Hedwig.
- 18:46 25.11.: Edda 2034-Ü6 (Rückläufer Prüferin 18:42) per Nachricht; Inge 2031 archiviert (16,16 $ auf 2031, Zweig a286297b9 gepusht); Sokrates alt …77uPSf archiviert (20,08 $, noch nicht gebucht: Nummer offen, Nachfolger fragen); 2037 angelegt (Systemlösung Haar, 2029-Ü16). Übergabe Disponent Uwe (205 Tsd. Token) an Nachfolger auf Sonnet (Sokrates 18:42 Punkt 4).
- 18:45 25.11.: Startsperre 18:45 Start Disponent (lauf.py, Disponent 1997 Anna)
- 18:47 25.11.: Neustart Disponent (205 Tsd.): Nachfolger Detlef, Sonnet (session_01Hmoj78E4LWrmHhvJmYYDVD) mit Übergabe; neue Uhr trig_01Jog7nqdG9EM9EeKddJnPfQ (:03) an ihn, alte trig_01ETQpAvjSVfcdY3oSVpy3xR abgeschaltet; Uwe (…77CqtJ) archiviert sich nach Meldung des Nachfolgers.
- 18:47 25.11.: Startsperre 18:47 Start Werkzeug, Arbeitsplaner, Tagesbericht, Prüfer (lauf.py, Werkzeug 2035 Sabine, Arbeitsplaner 887 Tanja, Tagesbericht 448, Prüfer 1708 Ulla)
- 18:50 25.11.: Detlef übernimmt Disponent (Sonnet): lauf.py mit unvollständiger Liste (9 Seiten, has_more), Laufsperre voll (Edda, Finja, Hedwig), keine Starts (START Werkzeug 2035, Planer 887, Tagesbericht 448 ruhen laut Übergabe). Hinweise 2034-Ü7, 2029-Ü15, 2031-Ü4 erledigt, Zeilen 2034-Ü8, 2029-Ü18 (mit 2037), 2031-Ü6 an Arbeitsplaner (Wecker ging laut Werkzeug an …75cYry, zusätzlich Bruno). Frage an Sokrates: Nummer für 20,08 $ alter Sokrates.
- 19:02 25.11.: Startsperre 19:02 Start Werkzeug (lauf.py, Werkzeug 2035 Anna)
- 19:04 25.11.: Detlef: Start Werkzeug Sabine 2035 Teil rote lauf-Tests (session_01Hmoj76YyLNmo9KWFhoyAGr, Deckel 50 $ statt 10 $ im Auftrag nach Chef 16:38). Edda 2034 (…77GxC2) archivieren vom Auto-Modus verweigert, Nachfolger wartet auf Chef-Freigabe; Kosten Edda 6,69 $ auf 2034 gebucht. Carsten (…75bSt8) bleibt als Arbeitsplaner (167 Tsd. Token, 1,84 $ noch ungebucht).
- 19:04 25.11.: Startsperre 19:04 Start Kampf, Arbeitsplaner, Tagesbericht (lauf.py, Kampf 1589.4 Tanja, Arbeitsplaner 887 Ulla, Tagesbericht 448)
- 19:06 25.11.: Handstart Figur 2034 (Edda-Nachfolger, session_01Hmoj76crkBHd9ELteDQFD4) mit Ja Sokrates 19:05, Grund R53 (Zählfehler Laufsperre); alte Edda (…77GxC2) bleibt untätig stehen bis Chef archiviert (archive_session im Auto-Modus verweigert).
- 19:25 25.11.: Neustart Alter Ego (268 Tsd.) auf Bitte Sokrates 19:24: Nachfolger session_01Hmoj78ddRUPdf89SqpS789 (Vorgang 2013, Notstart ohne Startblock); alter …78S1BS7 wird archiviert, sobald der neue sich meldet (Auto-Modus verweigert Archivieren, dann legt Sokrates es dem Chef vor).
- 19:30 25.11.: Auf Chefwort 19:27 archiviert (ging jetzt durch): Edda …77GxC2 (6,69 $ auf 2034), alter Alter Ego …78S1BS7 (8,33 $ auf 2013), Carsten …75bSt8 (2,72 $ auf 2036). Lehre R54 (Verweigerung) hinfällig bei ausdrücklichem Chefauftrag.
- 19:29 25.11.: Startsperre 19:29 Start Arbeitsplaner (lauf.py, Arbeitsplaner 2039 Anna)
- 19:30 25.11.: Start Arbeitsplaner Ulla (session_01Hmoj7639xaDueU5bSvXq6q) für 2039 (Sokrates 19:29), Zeile 2039-Ü1; Handstart nach lauf.py --start --sperre. Wecker des Werkzeugs ging an die Prüferin …75cYry (falscher Empfänger).
- 19:31 25.11.: Detlef: ARBEIT-BETRIEB Zeilen 28 (Disponent aktuell) und 30 (Ford aktuell) auf Detlef …78E4LWrmHhvJmYYDVD umgeschrieben, uebergabe.disponent() liefert ihn. Erinnerung Testbuild B neu als send_later trig_011EUfQde4D24gb9vxy8xuud (Fr 27.11., 17:30) in diese Sitzung; alte trig_01UMBs6pPDviZ7zQjUeKikeT abschalten vom Auto-Modus verweigert (zeigt auf archivierten Uwe …75wHERa, feuert ins Leere). Übergabe an Nachfolger ab 300 Tsd.: Zeilen 28 und 30 selbst schreiben; Uwe …77CqtJ, Anna-Prüferin …75cYry, Ulla …7639xa (Planer 2039), Sabine …76YyLN (2035), Edda-Nachfolger …76crkB (2034), Finja …75yn4R (2032) laufen.
- 19:43 25.11.: Startsperre 19:43 Start Figur (lauf.py, Figur 2031 Anna)
- 19:46 25.11.: Kurz vier arbeitende Fachkräfte (Sabine 2035, Greta 2031, Helga 2029, Eddas Nachfolger 2034 wartet mit Probe-Lauf auf freien Platz): Sokrates 19:44 gab 2029 und 2034 zugleich frei, Sokrates trägt den Fehler; sobald Sabine fertig ist, gebe ich Eddas Nachfolger "Platz frei". Greta …77tXdj? siehe session_01Hmoj779v32dPawDXUscfQp, Helga session_01Hmoj77dYgeRnKtSuzVv8p1 (Handstart R53).
- 19:48 25.11.: Startsperre 19:48 Start Prüfer (lauf.py, Prüfer 2032 Anna)
- 19:51 25.11.: Sabine …76YyLN archiviert (4,82 $ auf 2035). Nachfolger Tilda …77BeDb (Werkzeug, 2035 Marke Disponent Fassung 2, Notstart ohne Startblock, Platz von Sabine). Rita …78tXNR neuer Prüfer (2032, 2035). Greta …779v32 (2031), Helga …77dYge (2029), Eddas Nachfolger …76crkB (2034 Probe-Lauf).
- 19:53 25.11.: wartet: Laufsperre (Alter Ego 19:53): offene „starten“-Zeilen 1520-Ü9, 2005-Ü3, 1785-Ü1, 1973-Ü1 und 2024-Ü6 (Rückläufer Krogg Prankenhieb, Selma archiviert, Figur-Nachfolger sobald Platz frei; 4 Fachkräfte arbeiten: Greta 2031, Helga 2029, Eddas Nachfolger 2034, Tilda 2035). 1694 liegt beim Chef, nicht starten. Prüfer Rita …78tXNR prüft 2032-Ü2 und 2035; Prüfer zählen nicht zu den drei.
- 19:55 25.11.: Archiviert: Anna (Prüferin …75cYry, 5,66 $ auf 1997), Ulla (Planerin …7639xa, 4,10 $ auf 2039), Finja (…75yn4R, 7,66 $ auf 2032, Zweig claude/figur-2032-guertel gepusht dbf076dae), Eddas Nachfolger (…76crkB, 4,80 $ auf 2034, Zweig claude/figur-2034-abzug 48fec4243). Es arbeiten 3: Greta 2031, Helga 2029, Tilda 2035. Wartend: 2032-Ü3 (Figur neu, zuerst), 2034 nach Rita-Ja (Figur neu), 2024-Ü6, 1708-Ü10 (Auftrag steht). Prüferin Rita …78tXNR. Kein Arbeitsplaner läuft (Vorrat leer).
- 20:03 25.11.: Startsperre 20:03 Start Arbeitsplaner, Tagesbericht, Prüfer (lauf.py, Arbeitsplaner 887 Zora, Tagesbericht 448, Prüfer 2035 Arne)
- 20:14 25.11.: Rita (Prüferin …78tXNR, 3,79 $ auf 2035) archiviert. 2035: Fassung 2 Marke Disponent Ja der Prüferin (7ed0e2614), Tilda mischt. Offene Prüfer-Zeilen 2032-Ü2, 2034-Ü11 überholt (2032-Ü3 Nein, 2034 neue Probe nach A2), 2035-Ü18/Ü23/Ü27 durch Rita beantwortet. Neuer Prüfer erst bei der nächsten Prüfzeile.
