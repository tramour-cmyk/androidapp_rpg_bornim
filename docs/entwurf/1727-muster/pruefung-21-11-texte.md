# 1727, Gegenprüfungen der neuen Texte am 21.11. abends (offen zum Einarbeiten)

Sammelt Befunde frischer Prüfer, die noch nicht eingearbeitet sind; je Datei nach dem Einarbeiten den Abschnitt in die Datei selbst („mein Wort“) und hier streichen.

Stand 22:15: Nachprüfung 21:03 wird in `werkzeuge.md` F6 eingearbeitet (Helfer, dann Nachprüfung). 1774: F4, Befunde 21:10 und 21:15 eingearbeitet, Umbau an Spike (1779). Nachprüfung 21:15 der drei Texte F4a eingearbeitet (Fassung 5, „mein Wort“ in den drei Dateien); Nachprüfung der Fassung 5 offen.

## Nachprüfung 21:03: werkzeuge.md Fassung 5 (frischer Helfer, an `986d3d340`; Vorrunde 1–20 stimmt, außer 10 teils überholt; Zählung A 44, B 17, C 25, D 37 stimmt)

Mein Wort (Sokrates 21:05): alle **stimmt**, Einarbeiten in Fassung 6 offen.
1 B Herzschlag/Wache, A `lauf.py` Zeitmarke: 1764 gebaut (`c526199e2`); Zeitmarke ist „**Stand:**“ in `ARBEIT-BESETZUNG.md` (`lauf.py`:1398–1408); `herzschlag.yml` liegt vor, beim Chef nur Secret `TELEGRAM_BOT_TOKEN`; G:475 ist durch Archiv 20:50 „Wache bleibt“ ersetzt; gegen `routine-wache.md`:47 schreibt `lauf.py` stündlich neu.
2 Totes Ende: Wache selbst (Schicht 2) und ihre Zeitmarke nicht gebaut, `herzschlag.py`:37 prüft nur `lauf.py` → „Vorgang fehlt“ oder Rest von 1764.
3 A `startbar.py` Reihenfolge „Fund, Eilt“ gegen Archiv 20:54 „Eilt zuerst“.
4 Neu nicht eingeordnet: `herzschlag.py` (Rollenname „Ford“ :37 → A), `herzschlag.yml`, `werkzeuge.yml`; Abhängigkeit `lauf.py`:1400 → `herzschlag.marke`; Raster neu (255 Dateien, 10 Workflows).
5 A `godot.yml` und „Lauf auf `main`“: seit 1775 Werkzeugtests in `werkzeuge.yml`:25–29, nur 5 von 33 `*_test.py`, Auslöser nur oberste Ebene `tools/`.
6 `herzschlag.yml`:64 immer laut, an `meldung.sh` vorbei (gegen „nachts nie laut“, `meldung.sh`:121, G:921) → Vorgang an Spike.
7 Form: 1772 jetzt `1db38639d`; `nein_waechter` :114.
8 Spur Spike: 1764 gebaut, 1766 gebaut (`19bf8c8d4`, Werte über 1774).
9 Anschluss Rundblick: „wartet auf“ in `WOCHENTERMINE` und Start ohne „Zurück“ (`auftrag.py`:40–43) in A `startbar.py`, `auftrag.py` mit 1766; Rundblick zitiert `werkzeuge.md`:140, jetzt :148.
10 Liste der Notizschreiber (`profil-werkzeug.md` Teil B) fehlt unter „In A/B, fehlt in 7.1“.
11 Form: `commit-pruefung.py` `BESITZER` :24. 12 Form: `notiz.sh` → `startwarnung.py` :88.

## Gegenprüfung 20:41: werkzeuge.md Fassung 4 (frischer Helfer; grep-Raster selbst gelaufen, 250 Dateien, 120 mit Treffern, stimmt mit Anhang)

Mein Wort (Sokrates 20:43): alle 20 **stimmt**; 1 und 13 sofort an Spike (1739, Nachricht 20:43), Rest in Fassung 5.

1 toter Ende: offene Übergabezeilen an andere als Sokrates startet niemand (`chefwort.py`:28, `rueckmeldung.py`:10, :26 → „Arbeitsplaner“; `uebergabe.py`:157–166 findet keine Sitzung; `lauf.py` nur `sokrates_zeilen` :505–530); `offen --sitzungen` ruft kein Lauf → A `lauf.py` ausdrücklich: Zeilen je Empfänger, starten/wecken, `offen --sitzungen` je Lauf.
2 `t` (Marke nur Zeitstempel, `t`:16–17; `commit-pruefung.py` :201–209 reicht nicht für G:922) und `freigabe-haken.py` (ruft `meldung.sh`, G:921) gehören nach A; beide schon geändert (44eb13bf4, 5b15f73a0); Raster um Abhängigkeiten (wer ruft wen, Marken).
3 C ohne Abhängige: `vorratspruefung.py` von `tagesbericht.py`:298–335 und `startwarnung.py`:137; `pflegehinweis.py` von `notiz.sh`:90; `probelauf.py` in `commit-pruefung.py`:464 importiert und einziger Aufrufer von `bereichslisten.py` (:1292–1298) → Aufrufer nennen, `bereichslisten.py` nach C „Ersatz offen“.
4 „Rückwärtsverträglich bis zum Umschalten (BER Zu 1739; SPIKE:6)“: Belege falsch (Satz in SPIKE:8, begründet mit „Tom und Jerry bauen weiter“, ersetzt 21.11., 20:06) → neu begründen: bis zum Umschalt-Commit, weil laufende Restarbeit und alte Sitzungen.
5 Leistungsstufe in A `lauf.py`, `startsperre-haken.py`: Chef 20.11., 15:52 erst nach Prüfung 1742 → „Vorschlag, wartet auf 1742“.
6 GitHub-Regel Buildzweige steht in G:923 („stellt der Chef ein“) → aus „fehlt in 7.1“ streichen, B „7.1, beim Chef“.
7 Haken D „Liste noch ‚startbar‘“ falsch (1762 gebaut, 34de71832); `chefwort.py` braucht Rufnamen-Umbau wie `rueckmeldung.py`, `uebergabe.py` → A-Zeile.
8 veraltete Fundstellen `lauf.py` (vor 1763, +26): Archivschutz :782→:809, :887; `abgleich` :1007–1011→:1034–1053; Wochentermine :680→:707; 1531 :677→:704 (Fkt. :172); laufende Sitzung :718→:745; Nie archivieren :781→:808; Rollenspiegel :945, :959, :1120–1138→:972, :986, :1017, :1151–1171; „Kosten auf“ 197→:491–504; `mit_kern` :121→:122.
9 Form: `vorgang.py` „Systemlösung?“ :477→:488–489, `waechter` :504; `abgleich.py` :25, :29→:26–27; `vorlage_pruefen.py`:8→:9; „BER:11“ (Umstellung Vorgangsliste, Stop-Haken) → BER:12.
10 B Herzschlag/Wache gegen `routine-wache.md` F3 (dauerhafte Sitzung, vom Disponenten gestartet, :11) und G:475; „3 rote Läufe“ doppelt (A `lauf.py` und Wache, Frage 2: G:919 streichen); Zeitmarke offen (Frage 5: Commit der Besetzung, 1387) gegen A „Zeitmarke je Lauf (1764)“; fehlen Workflow-Datei und Telegram-Secret (beim Chef) → B angleichen.
11 Lücke B: Liegezeit (G:493, :889, :899; `routine-wochenzaehlung.md`:44) → B-Zeile „Kennzahlen Wochenzählung (Liegezeit aus Übergabezeilen)“, Vorgang fehlt.
12 A `tagesbericht.py` unvollständig gegen `routine-tagesbericht.md`: „Wo stehen wir“ statt „Rest geschätzt“ (:87, :345), Halt Vorratsprüfung fällt (:325–335), Alter letzter Release, Fragen ohne Antwort; „Text fehlt (EA L-O8)“ überholt.
13 toter Ende: Umschalt-Commit (Schritt 8) ohne `tools/1727-SCHARF`; ohne sie bleiben Haken D (`chefwort.py`:17, :144) und Telegram-Regel in `meldung.sh` (5b15f73a0) aus.
14 `godot.yml`:387 betrifft `kauftier.py` (Teamzweig `claude/jerry-348-kampf`, :385–388), nicht `waffen.py`; `godot-kampf.yml`:195 holt `claude/tom-376-1-figuren` → beide nennen.
15 `art_weg_test.py` in D gezählt (testet `commit-pruefung.py`, :10, :15) → streichen, D = 40.
16 Reihenfolge gegen Archiv 20:20: Jerry baut 1765 parallel → zwei Spuren (Spike 1739, 1764, 1766; Jerry 1765), Abhängigkeit „Gegengelesen“ an Rufnamen nennen.
17 A `notiz.sh`: liest Account aus Team-Kennungen, Rolle aus erster Nachricht (`notiz.sh`:17–21), nicht aus `ROLLE-BETRIEB.md`.
18 A `spike-probe-4552.yml`: 455.2 läuft auf `claude/jerry-455-2-groesse`, Workflow nur `claude/spike-455-2-**` (:9) → Begründung „nur Handstart“.
19 A `startbar.py`: `urteil_faellig` (:272, je Rolle) fehlt; `spiegel_auswertung_faellig` (:302) nur über :305 in C → beide nennen.
20 überholt: `tools/buildwerkzeug.py` (44eb13bf4, 1765) fehlt in A–D; Telegram-Regel in `meldung.sh`; Änderungen `commit-pruefung.py`, `buildzweig-haken.py`, `godot.yml`, `t`, `freigabe-haken.py` → Fassung 5 mit neuem Raster, „gebaut“ führen.

Ungeprüft (Prüfer): `ein-ausgang.md` außer L-O6, L-O16, L-S1, L-U14 nur Stichproben; BG, Katalog, Fehlerbuch, Abendprüfung nur genannte Zeilen; `kerne-falltest.md`, `gesamtbetrachtung.md`, Profile Disponent, Kosten, Release, Werkzeug, Fremde Inhalte nicht voll gegen A/B; alte Archiveinträge (222, 222.1, 235, 797, 513 B) nur Existenz; Force-Push nicht probiert; keine Werkzeuge ausgeführt; `tools/blender348` nur Raster; `godot.yml` außer :8, :16–41, :71, :355–388; `kernregeln.txt` (D) nicht bewertet.
