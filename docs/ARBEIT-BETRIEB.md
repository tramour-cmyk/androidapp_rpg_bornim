# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll. Aufgeräumt 23.11., 08:46 (1688): was seit dem Umschalten 22.11., 16:17 nicht mehr gilt, steht in Git (`git log -p docs/ARBEIT-BETRIEB.md`, Stand vorher 2c67215a4). Befristetes nur als „Zu <Nr>, bis erledigt, streicht: <Rolle>“.

**Nie archivieren:** (keine; Sokrates …777MV8Hv8ps2Js5voW freigegeben, Chef 18.11., 08:45)

Jede Startnachricht für Figur, Bild oder Film: „`LISTE-HANDWERK-FIGUR-PRUEFBILD.md` vor dem Lauf lesen und das Bild danach dagegen prüfen“ (1625, Sokrates 07:20).

**Nächste freie Vorgangsnummer: 2042** (zuletzt 2041 Werkzeug 25.11. 20:48:39 ca0c) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

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

- 20:38 25.11.: Otto: Protokoll auf 14 KB gekürzt (Zeilen vor 19:00 und alte Startsperren raus, stehen in Git; war 34,6 KB). Vera: 1694 Auftrag steht (Ü41), wartet auf Figur-Platz; 2039 Eilt wartet auf Werkzeug-Platz. Sokrates alt …79nRJF archiviert (11,43 $ auf 1988).
- 20:31 25.11.: Otto (Disponent, …79qsAJ) übernimmt von Detlef. Erster Takt lauf.py --besetzung (25 Seiten): nichts gestartet (Laufsperre 3: Edda, Greta, Ines arbeiten; Planer/Tagesbericht-Vorschläge ruhen laut Übergabe). Vera …79KM7e von lauf.py fälschlich als „Figur“ zum Archivieren vorgeschlagen (Titel ohne Rolle): bleibt, Planerin. Uhr: create_trigger vom Auto-Modus verweigert, alte Uhr trig_01Jog7nqdG9EM9EeKddJnPfQ (auf Detlef) bleibt an; Detlef bleibt bis zur Umhängung. Testbuild-Erinnerung neu als send_later trig_01MzbqijpDaS2FnXSUosLB4T (Fr 27.11., 17:30) in diese Sitzung.
- 20:29 25.11.: ÜBERGABE Disponent Detlef → Nachfolger (Detlef bei 477 Tsd.): Prüfer Ralf …78FAZt gestartet (offene Prüfzeilen 2032-Ü2, 2034-Ü11, 2035-Ü18/23/27/30 überholt prüfen). Arbeiten (Laufsperre 3, bis Sa 28.11., 20:00, nur Spiel und Eilt): Greta …779v32 (2031-Ü3 Kutte/Haut), Ines …77NKuN (2032-Ü3 Rowena), Edda …78JK5Z (2034 Probe nach A2). Arbeitsplaner Vera …79KM7e (128 Tsd., keine Zeile offen). Wartend in Folge: 2024-Ü6 (Krogg Prankenhieb, neue Figur-Fachkraft), Nachfolger 1589.4 mit Variante a (Auftrag vorhanden; Entscheid Alter Ego 20:21, Archiv 93e3b5ce7, Zweig claude/moritz-1589.2), 1708-Ü10 (Auftrag steht, Zweig claude/berit-1708-blut), 2039 (Auftrag steht, Start erst nach Eilt des Chefs), 2035 weitere Teile (a)-(d),(f). Nicht starten: 1694 (beim Chef), Planer 887, Tagesbericht 448, Kampf Arne, Zora (Vorschläge ruhen seit 16:58). Uhr trig_01Jog7nqdG9EM9EeKddJnPfQ (Stundentakt :03) und Testbuild-Erinnerung trig_011EUfQde4D24gb9vxy8xuud (Fr 27.11., 17:30) auf neue Sitzung umhängen (update_trigger kann persistent_session_id nicht ändern: neue Uhr per create_trigger anlegen, alte abschalten, Auto-Modus hat update_trigger verweigert). Zeile Disponent aktuell in ARBEIT-BETRIEB.md selbst schreiben. Archivieren: ging nach Chefwort 19:27; wartend zu archivieren: Anna ✓, Uwe …77CqtJ bereits weg; Vera, Ralf bei Fertigstellung; Detlef …78E4LW nach Meldung des Nachfolgers (Kosten bei Archivierung auf 1997). Zählfehler lauf.py (Lehre R53): zählt Disponent und nicht gestartete Startsperren mit: Handstart nur mit Ja Sokrates und Notstart-Satz (R53). Kosten Detlef bisher noch nicht gebucht.
- 20:19 25.11.: Handstart Figur Ines …77NKuN (2032-Ü3 Rückläufer Rowena, Notstart R53); Helga …77dYge archiviert (3,69 $ auf 2029). Arbeiten: Greta 2031-Ü3, Ines 2032-Ü3, Tilda 2035 (fertig, gemischt 5b2ced4df, noch zu archivieren, 11,05 $ + eigene). Wartend: 2024-Ü6 (Krogg Prankenhieb, Figur neu), Nachfolger 1589.4 (Maja …75uanU idle 568 Tsd. mit offener Variantenfrage a/b2/c, noch nicht archiviert), 2034 ruht beim Chef (Probe A2), 2039 wartet auf Eilt, 1708-Ü10 Auftrag steht (wartet Laufsperre). Planerin Vera …79KM7e läuft (128 Tsd.). Übergabe an Nachfolger: Zeilen 28/30 in ARBEIT-BETRIEB.md selbst schreiben (Zeile 30 ist gestrichen, nur noch Zeile Disponent aktuell), alte Uhr trig_01Jog7nqdG9EM9EeKddJnPfQ (Stundentakt :03) an Sitzung hängen.
- 19:55 25.11.: Archiviert: Anna (Prüferin …75cYry, 5,66 $ auf 1997), Ulla (Planerin …7639xa, 4,10 $ auf 2039), Finja (…75yn4R, 7,66 $ auf 2032, Zweig claude/figur-2032-guertel gepusht dbf076dae), Eddas Nachfolger (…76crkB, 4,80 $ auf 2034, Zweig claude/figur-2034-abzug 48fec4243). Es arbeiten 3: Greta 2031, Helga 2029, Tilda 2035. Wartend: 2032-Ü3 (Figur neu, zuerst), 2034 nach Rita-Ja (Figur neu), 2024-Ü6, 1708-Ü10 (Auftrag steht). Prüferin Rita …78tXNR. Kein Arbeitsplaner läuft (Vorrat leer).
- 19:53 25.11.: wartet: Laufsperre (Alter Ego 19:53): offene „starten“-Zeilen 1520-Ü9, 2005-Ü3, 1785-Ü1, 1973-Ü1 und 2024-Ü6 (Rückläufer Krogg Prankenhieb, Selma archiviert, Figur-Nachfolger sobald Platz frei; 4 Fachkräfte arbeiten: Greta 2031, Helga 2029, Eddas Nachfolger 2034, Tilda 2035). 1694 liegt beim Chef, nicht starten. Prüfer Rita …78tXNR prüft 2032-Ü2 und 2035; Prüfer zählen nicht zu den drei.
- 19:46 25.11.: Kurz vier arbeitende Fachkräfte (Sabine 2035, Greta 2031, Helga 2029, Eddas Nachfolger 2034 wartet mit Probe-Lauf auf freien Platz): Sokrates 19:44 gab 2029 und 2034 zugleich frei, Sokrates trägt den Fehler; sobald Sabine fertig ist, gebe ich Eddas Nachfolger "Platz frei". Greta …77tXdj? siehe session_01Hmoj779v32dPawDXUscfQp, Helga session_01Hmoj77dYgeRnKtSuzVv8p1 (Handstart R53).
- 19:31 25.11.: Detlef: ARBEIT-BETRIEB Zeilen 28 (Disponent aktuell) und 30 (Ford aktuell) auf Detlef …78E4LWrmHhvJmYYDVD umgeschrieben, uebergabe.disponent() liefert ihn. Erinnerung Testbuild B neu als send_later trig_011EUfQde4D24gb9vxy8xuud (Fr 27.11., 17:30) in diese Sitzung; alte trig_01UMBs6pPDviZ7zQjUeKikeT abschalten vom Auto-Modus verweigert (zeigt auf archivierten Uwe …75wHERa, feuert ins Leere). Übergabe an Nachfolger ab 300 Tsd.: Zeilen 28 und 30 selbst schreiben; Uwe …77CqtJ, Anna-Prüferin …75cYry, Ulla …7639xa (Planer 2039), Sabine …76YyLN (2035), Edda-Nachfolger …76crkB (2034), Finja …75yn4R (2032) laufen.
- 19:30 25.11.: Auf Chefwort 19:27 archiviert (ging jetzt durch): Edda …77GxC2 (6,69 $ auf 2034), alter Alter Ego …78S1BS7 (8,33 $ auf 2013), Carsten …75bSt8 (2,72 $ auf 2036). Lehre R54 (Verweigerung) hinfällig bei ausdrücklichem Chefauftrag.
- 19:30 25.11.: Start Arbeitsplaner Ulla (session_01Hmoj7639xaDueU5bSvXq6q) für 2039 (Sokrates 19:29), Zeile 2039-Ü1; Handstart nach lauf.py --start --sperre. Wecker des Werkzeugs ging an die Prüferin …75cYry (falscher Empfänger).
- 19:25 25.11.: Neustart Alter Ego (268 Tsd.) auf Bitte Sokrates 19:24: Nachfolger session_01Hmoj78ddRUPdf89SqpS789 (Vorgang 2013, Notstart ohne Startblock); alter …78S1BS7 wird archiviert, sobald der neue sich meldet (Auto-Modus verweigert Archivieren, dann legt Sokrates es dem Chef vor).
- 19:06 25.11.: Handstart Figur 2034 (Edda-Nachfolger, session_01Hmoj76crkBHd9ELteDQFD4) mit Ja Sokrates 19:05, Grund R53 (Zählfehler Laufsperre); alte Edda (…77GxC2) bleibt untätig stehen bis Chef archiviert (archive_session im Auto-Modus verweigert).
- 19:04 25.11.: Detlef: Start Werkzeug Sabine 2035 Teil rote lauf-Tests (session_01Hmoj76YyLNmo9KWFhoyAGr, Deckel 50 $ statt 10 $ im Auftrag nach Chef 16:38). Edda 2034 (…77GxC2) archivieren vom Auto-Modus verweigert, Nachfolger wartet auf Chef-Freigabe; Kosten Edda 6,69 $ auf 2034 gebucht. Carsten (…75bSt8) bleibt als Arbeitsplaner (167 Tsd. Token, 1,84 $ noch ungebucht).
- 19:51 25.11.: Sabine …76YyLN archiviert (4,82 $ auf 2035). Nachfolger Tilda …77BeDb (Werkzeug, 2035 Marke Disponent Fassung 2, Notstart ohne Startblock, Platz von Sabine). Rita …78tXNR neuer Prüfer (2032, 2035). Greta …779v32 (2031), Helga …77dYge (2029), Eddas Nachfolger …76crkB (2034 Probe-Lauf).
- 20:03 25.11.: Startsperre 20:03 Start Arbeitsplaner, Tagesbericht, Prüfer (lauf.py, Arbeitsplaner 887 Zora, Tagesbericht 448, Prüfer 2035 Arne)
- 20:14 25.11.: Rita (Prüferin …78tXNR, 3,79 $ auf 2035) archiviert. 2035: Fassung 2 Marke Disponent Ja der Prüferin (7ed0e2614), Tilda mischt. Offene Prüfer-Zeilen 2032-Ü2, 2034-Ü11 überholt (2032-Ü3 Nein, 2034 neue Probe nach A2), 2035-Ü18/Ü23/Ü27 durch Rita beantwortet. Neuer Prüfer erst bei der nächsten Prüfzeile.
- 20:17 25.11.: Startsperre 20:17 Start Arbeitsplaner, Kampf, Werkzeug, Arbeitsplaner, Tagesbericht, Prüfer (lauf.py, Arbeitsplaner 887 Zora, Kampf 1589.4 Arne, Werkzeug 2035 Benno, Arbeitsplaner 2029 Conrad, Tagesbericht 448, Prüfer 2035 Dirk)
- 20:21 25.11.: Tilda …77BeDb archiviert (6,49 $ auf 2035; Fassung 2 Marke Disponent auf main 5b2ced4df; 2035 hat weitere Teile, nicht fertig gesetzt). Maja …75uanU archiviert (32,99 $ auf 1589.4; Variantenfrage a/b2/c in docs/vorgang/1589.4.md gesichert, Wahl liegt bei Alter Ego). Handstart Figur Edda …78JK5Z (2034 Probe nach A2, Notstart R53). Arbeiten: Greta 2031-Ü3, Ines 2032-Ü3, Edda 2034. Wartend: 2024-Ü6, Nachfolger 1589.4 (nach Variantenwahl), 1708-Ü10 (Auftrag steht), 2039 (Eilt Chef).
- 20:30 25.11.: Startsperre 20:30 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Arne, Arbeitsplaner 2029 Benno, Tagesbericht 448)
- 20:30 25.11.: Startsperre 20:30 Start Tagesbericht (lauf.py, 448)
- 20:33 25.11.: Startsperre 20:33 Start Sokrates (selbst, Nr 1988, Otto). Startsperre 20:33 Start Alter Ego (selbst, Nr 2013, Otto).
- 20:43 25.11.: Startsperre 20:43 Start Arbeitsplaner (selbst, 2035-Ü32, Otto).
- 20:52 25.11.: Startsperre 20:52 Start Werkzeug (selbst, 2035-Ü33, dann 2041; Handstart mit Ja Sokrates 20:51, R53, Otto).
- 21:02 25.11.: Startsperre 21:02 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 887 Benno, Arbeitsplaner 2029 Conrad, Tagesbericht 448)
- 21:02 25.11.: Marke Tagesbericht 25.11. (lauf.py)
- 21:02 25.11.: Marke Nachhalten 25.11. (lauf.py)
- 21:02 25.11.: Marke Tagesbericht fehlt 25.11. (lauf.py)
- 21:02 25.11.: Marke Abgleich ganz 25.11. (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj75zjMe2vQTTLnP9jaN (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78GVgrp48SUhwspQ4U (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj79qsAJkf1SGKyjZA9Q (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78FAZt4S1xdWaMpnzt (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78JK5ZK3PgG9J51MzU (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj77NKuNKtY23SQr71xQ (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78ddRUPdf89SqpS789 (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78E4LWrmHhvJmYYDVD (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj78Wv7RZiy8Cg7y8keo (lauf.py)
- 21:02 25.11.: Marke Ohne-Rolle session_01Hmoj76EdmopCkFv7PLLpSS (lauf.py)
- 21:02 25.11.: Marke Start-fehlt Arbeitsplaner 25.11.-20:43 (lauf.py)
- 21:02 25.11.: Marke Start-fehlt Kampf 25.11.-20:17 (lauf.py)
- 21:02 25.11.: Marke Start-fehlt Prüfer 25.11.-20:17 (lauf.py)
- 21:02 25.11.: Marke Start-fehlt Tagesbericht 25.11.-20:30 (lauf.py)
- 21:02 25.11.: Marke Start-fehlt Werkzeug 25.11.-20:52 (lauf.py)
- 21:04 25.11.: Otto: Takt 21:02 (eine Seite, Besetzung gepusht). Prüfzeilen 1535-Ü1, 1674-Ü1, 1398-Ü1, 1710-Ü1 an Ralf; 2035-Teil Disponent erkennen gebaut (Mira, aa45cb42e), Ralf prüft Ü35/Ü36; Mira danach 2041. Uhr weiter offen (create_trigger).
- 21:06 25.11.: Disponent-Uhr: trig_01RDJvETEx6wog5bGvsETLSD (3 * * * *, auf Otto …79qsAJ, von Alter Ego umgehängt, Sokrates 21:05); alte trig_01Jog7nq… aus. Testbuild-Erinnerung trig_01MzbqijpDaS2FnXSUosLB4T (Fr 27.11., 17:30) auf Otto. Detlef …78E4LW archiviert (12,83 $ auf 1997).
- 21:05 25.11.: Startsperre 21:05 Start Prüfer (lauf.py, Prüfer 1992 Anna)
- 21:09 25.11.: Startsperre 21:09 Start Werkzeug (selbst, Nachfolger Mira 2041-Ü3, Handstart mit Ja Sokrates 20:51, R53, Otto).
- 21:14 25.11.: Otto: Prüfer Gerd …75U9LA ersetzt Ralf (archiviert, 4,46 $ auf 2035); 1992 erledigt (c431b9c1d), 2035-Teil Disponent erkennen auf main (b076bd0b3), Nora …793gz7 baut 2041 a–c (Mira archiviert, Kosten offen). 1398/1710 ja an Sokrates, 1535/1674 Beleg fehlt.
- 21:15 25.11.: Chef 21:11: Disponent heißt künftig „Disponent – Büro“ (Archiv 6594535ac); Otto behält Titel „Otto – Disponent – Betrieb“, bis 2041 d auf main ist, dann set_session_title.
