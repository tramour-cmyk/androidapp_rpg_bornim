# Betrieb (Ford)

Fords Vorrat (`ROLLE-BETRIEB.md`). Oben Zähler, Stellung und Kennungen; darunter Eingang; unten Protokoll. Aufgeräumt 23.11., 08:46 (1688): was seit dem Umschalten 22.11., 16:17 nicht mehr gilt, steht in Git (`git log -p docs/ARBEIT-BETRIEB.md`, Stand vorher 2c67215a4). Befristetes nur als „Zu <Nr>, bis erledigt, streicht: <Rolle>“.

**Nie archivieren:** (keine; Sokrates …777MV8Hv8ps2Js5voW freigegeben, Chef 18.11., 08:45)

Jede Startnachricht für Figur, Bild oder Film: „`LISTE-HANDWERK-FIGUR-PRUEFBILD.md` vor dem Lauf lesen und das Bild danach dagegen prüfen“ (1625, Sokrates 07:20).

**Nächste freie Vorgangsnummer: 2068** (zuletzt 2067 Werkzeug 28.11. 07:05:05 8b27) (wer einen Vorgang anlegt, zählt hier hoch, trägt ihn in `LISTE-VORGAENGE.md` mit Bereich und Klasse ein, pusht und nennt dann die Nummer)

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
- **Zu Chefwort 21:51, ab Sa 28.11., 20:00 (nach Ende der Laufsperre), bis Chefwort, streicht: Disponent.** Chef 27.11., 21:51 an Sokrates: „Test erfolgt morgen. Reihenfolge A.“ (docs/VORGANGSARCHIV.md oben, eb6f951de2): ab dann läuft nur Kampf, einer nach dem anderen: t301 → 1589.2/1589.4 auf main → 2064/2065 → 1589 → 1627 → 709 → 709.1 → 760 → 1708. lauf.py mit `--ohne` für Figur, Klang, Story, Technik, Welt, Kataloge, Oberfläche, Regeln; Grund „Chef 27.11., 21:51 nur Kampf“. **Geändert Chef 22:08 (5cf1cad976, Sokrates 22:09):** Werkzeug nicht als Rolle ausschließen; ab Sa 20:00 laufen Kampf und 2066 (Eilt; Arbeitsplaner schreibt 2066-Ü1/Ü2 erst ab Sa 20:00); die anderen startbaren Werkzeug-Zeilen einzeln per Nummer mit `--ohne NR:"Chef 27.11., 21:51 nur Kampf"`. Arbeitsplaner, Prüfer, Tester bleiben für Kampf; Werkzeug nur bei einem Fehler, der das Spiel blockiert (Sokrates 21:52).
- **Wache (aktuell)** `session_01Hmoj77JCMhf2hwMABWtXB4` (Handstart Chef 24.11., 07:01, Kopiertext C; Vorgängerin Clara `session_01Hmoj78CoScvkasiYmBbPTG` an der Token-Sperre 318 Tsd., archivieren: Disponent); Uhr „Wache“ `trig_01Wmm3Nxhn7nPjqG8Q1VgxZs` (:33), alte Uhr gelöscht.

## Eingang

Anregungen ohne Bereich und Startwünsche (eine Zeile, Datum, Absender). Ford teilt im nächsten Lauf zu oder legt sie dem Chef vor.

## Protokoll
Eine Zeile je Lauf mit Tat, neueste oben, höchstens 20 Zeilen; ältere streichen (Verlauf in Git, 117). Marken von `lauf.py` (Startsperre, Marke, Warnung) bleiben bis zur Aufräumung durch das Werkzeug. Startsperren bleiben mindestens bis zum Archivieren der Sitzung (`rufname.py` ordnet Rufnamen darüber der Rolle zu, 1957).

- 05:05 28.11.: ÜBERGABE Disponent …79GCrFff5PJ3KYGW5r (ca. 200 Tsd., Neustart-Haken) → Nachfolger: Disponent – Büro (28.11., 05:05), startet Alter Ego (Wurzel, Chefwort/Alter Ego 15:44 27.11.), nicht der Disponent selbst. Chefentscheid 17:18 gilt weiter: Laufsperre bis Sa 28.11., 20:00, keine Starts. Danach laut „Zu Chefwort 21:51“ (oben): nur Kampf plus 2066 (Eilt, Chef 22:08), Werkzeug-Zeilen einzeln per Nummer `--ohne`. Takt: list_sessions (mine, limit 100) in Datei, per Skript in Kurzform mit `# bis:`, `lauf.py --besetzung --ohne Figur/Werkzeug/Arbeitsplaner/Kampf/Sokrates/Tagesbericht … --token <eigene>=0`; ARCHIVIERE für Sokrates …75hFdXf2B1TFDpFwk5 NICHT ausführen (2063). Alter Ego neu: …78YZ5UUthecLR8vw2o (lauf.py meldet fälschlich „Start Alter nicht angekommen“, Zweiwort-Rolle, still lassen). WARNUNG-LAUT „wartet auf Freigabe“: einmal per meldung.sh --laut. Lauf-Uhr trig_01S5Hf1sAPJgHpZivpwLqap5 beim Nachfolger neu einhängen lassen (Alter Ego). Offen: nichts.
- 15:07 27.11.: ÜBERGABE Disponent …78cg8khw2wLQE5sUsG (ca. 200 Tsd., Neustart-Haken) → Nachfolger: Disponent – Büro (27.11., 15:07). Chefentscheid 17:18 gilt weiter (Laufsperre bis Sa 28.11., 20:00, keine Starts außer Ausnahmen des Chefs, die Sokrates meldet). Takt: lauf.py braucht Kurzform mit `# bis:` (Zeitmarke 11:14 gesetzt); list_sessions (mine, limit 100) Datei durch Skript in Kurzform wandeln. `--ohne Figur/Werkzeug/Arbeitsplaner/Kampf/Sokrates/Tagesbericht`; ARCHIVIERE für Sokrates NICHT ausführen (2063, Sokrates 13:17). Tagesbericht, Stillstände, Abgleich-Warnungen ruhen bis Sa 20:00 (Sokrates 11:16). Alter Ego …76togH, Sokrates …75hFdXf2B1TFDpFwk5. Lauf-Uhr trig_01W3gjtykvecdhBbiWnV3AEn feuert in diese Sitzung: Alter Ego bitten, sie auf den Nachfolger umzuhängen (Auto-Modus sperrt, Chefwort nötig). Offen: nichts.
- 10:21 27.11.: ÜBERGABE Disponent …77Prg659CQn3HAfQqX (ca. 205 Tsd.) → Nachfolger: Disponent – Büro (27.11., 10:20). Chefentscheid 17:18 gilt weiter (Laufsperre bis Sa 28.11., 20:00): KEINE Starts außer Ausnahmen des Chefs, die Sokrates meldet (2060 Eilt 09:32). Lauf-Uhr trig_01PC34cFcnDJLtwK93YbYyW4 hängt an …77Prg659 (Chef 09:12 „Ja, häng um“): Alter Ego bitten, sie auf dich umzuhängen. lauf.py: `# has_more`-Seiten nur erste Seite; „VOLLER LAUF“ verlangt alle Seiten (nicht geholt); --ohne Figur, Werkzeug (außer 2060), Arbeitsplaner, Kampf, Sokrates (lebt; ARCHIVIERE-Vorschlag ignorieren). Offen: Anna session_01Hmoj761PYCs4Tr4u8o9NVH (2060 fertig 5d719271e): erst archivieren und Kosten auf 2060 buchen, wenn Prüfer Carla session_01Hmoj75ZW3obNyn9PqgGxJT Ja sagt (bei Nein braucht Anna den Kontext); Sokrates führt 2060-Ü2/Ü3/Ü6 selbst. Kosten …77aaqc 4,25 $ gebucht. Notizen: nur benannte Dateien committen.
- 09:34 27.11.: Startsperre 09:34 Start Werkzeug (lauf.py, Werkzeug 2060 Anna)
- 10:19 27.11.: Startsperre 10:19 Start Prüfer (lauf.py, Prüfer 2060 Carla)
- 10:48 27.11.: Startsperre 10:48 Start Alter Ego (Alter Ego, Wurzel; Übergabe …77apEy)
- 11:09 27.11.: Startsperre 11:09 Start Werkzeug (lauf.py, Werkzeug 2062 Conrad)
- 11:11 27.11.: Startsperre 11:11 Start Tagesbericht (lauf.py, 448)
- 11:11 27.11.: Marke Tagesbericht 27.11. (lauf.py)
- 11:11 27.11.: Marke Nachhalten 27.11. (lauf.py)
- 11:11 27.11.: Marke Tagesbericht fehlt 27.11. (lauf.py)
- 11:11 27.11.: Marke Abgleich ganz 27.11. (lauf.py)
- 11:11 27.11.: Marke Archiv session_01Hmoj77Prg659CQn3HAfQqX (lauf.py)
- 11:11 27.11.: Marke Start-fehlt Alter 27.11.-10:48 (lauf.py)
- 11:33 27.11.: Startsperre 11:33 Start Prüfer (lauf.py, Prüfer 2062 Elke)
- 11:41 27.11.: Startsperre 11:41 Start Sokrates (Alter Ego …76togH)
- 12:03 27.11.: Marke Mehrfach Sokrates (lauf.py)
- 12:03 27.11.: Marke Archiv session_01Hmoj75hFdXf2B1TFDpFwk5 (lauf.py)
- 12:03 27.11.: Marke Archiv session_01Hmoj78LQ6fWBWLbV6uJK6n (lauf.py)
- 15:05 27.11.: Startsperre 15:05 Start Disponent (lauf.py)
- 15:06 27.11.: Startsperre 15:06 Start Arbeitsplaner, Figur, Arbeitsplaner, Sokrates (lauf.py, Arbeitsplaner 1189 Emil, Figur 2031 Frieda, Arbeitsplaner 1388 Gerda, Sokrates 1589.4)
- 18:26 27.11.: Startsperre 18:26 Start Alter Ego (Alter Ego …76togH)
