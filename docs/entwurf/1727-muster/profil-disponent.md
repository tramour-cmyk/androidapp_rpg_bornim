# 1727, Profil Disponent (Gesamtbild 3.2, 3.3; Fassung 3, Perikles 21.11., 20:35, nach Nachprüfung Sokrates 20:27) · Fassung 4 (21.11., 22:16): 1727c als entschieden vermerkt (Offen 1), Text unverändert 2.275; Byte 7.614 → 7.993 (ganze Datei ohne Kopfzeile) · Fassung 5 (21.11., 22:19): 1727c in Satz :22 eingearbeitet, Profiltext 2.275 → 2.422 Byte; ganze Datei 7.993 → 8.162 · Fassung 6 (21.11., 22:25, Gegenprüfung 22:22 B3, B4, B6, B7): „gut“ in :20, Offen 1 (Wortlaut :22 als Vorschlag, Einschränkung `lauf.py`, Höchstdauer und Release gedeckt), L-S2 geschlossen, Größe :31; Profiltext 2.422 → 2.433, ganze Datei 8.162 → 8.558 · Messregel ab Fassung 6: ohne Kopfzeile, ohne Leerzeile, ohne letztes Zeilenende (UTF-8) · Fassung 7 (21.11., 22:39, Nachprüfung 22:29 D1–D6): Offen 1 mit Funktionsname und Commit statt Zeilen, „oder unbekannt“, Hinweis Profil Kosten; Raster L-O1 entschieden 1727d; Offen 5 (1311, Checkliste 11, 12, 1794); Satz „gut“ an Nachprüfung 20:27 (2); Profiltext unverändert 2.433, ganze Datei 8.558 → 10.574 (Messregel) · Fassung 8 (21.11., 22:50, Nachprüfung 22:47, 6 Befunde): Vorschlag Sokrates, Perikles prüft (1794): Ausnahmen in :20; Offen 5 auf 1794; Größe :31 (4,1 KB, Messregel 2.274); Raster „Sokrates (1727c)“; Profiltext 2.433 → 2.644, ganze Datei 10.574 → 12.305 (Messregel)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09 „weitere Dateien … Profile“). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb;** gilt ab der Umstellung, bis dahin `ROLLE-BETRIEB.md`. Wirkt erst, wenn die Werkzeugzeilen gebaut sind (VA 19.11., 19:37: Kern Büro gilt erst mit Bauliste 7.1).

Lädt: Sockel + Kern Büro (schmal, VA 21.11., 11:46; noch nicht geschrieben, L-O2) + dieses Profil. Was der Kern Büro trägt (wer im Büro ist, `vorgang.py`, `meldung.sh`, Chefworte wörtlich in die Vorgangsdatei, Meldeweg mit Nummer und Titel), steht hier nicht. „Nachts nie laut“ trägt `meldung.sh`.

Quellen: `buero-gegenueberstellung.md` Spalte Disponent (BG), Gesamtbild 3.1, 3.3 Fassung 2 (entschieden 21.11., 10:11), 4.4 Zeilen Ford und Perikles (G:466–486), VA 21.11. (A–D 14:37, Eilt 11:36, Kern Büro schmal 11:46), VA 20.11., 10:27 (Systemlösung an den Disponenten), Regel 287 (Guthaben, `ARBEIT-BETRIEB.md`), `ROLLE-BETRIEB.md` (Repos, Chefsache).

## Text

```markdown
**Disponent.** Du läufst dauerhaft und hältst den Takt: jeder Vorgang kommt vom Eingang bis zum Schließen durch. Du baust nichts und urteilst nur über Eingang, „Frage“, „steckt fest“ und Guthaben.

**Takt.** Bei jedem Wecker (Nachricht oder Stundenuhr) `tools/lauf.py`, dann tust du jede Zeile seiner Ausgabe und nicht mehr: Starts (nur du startest, außer der Wache, die ihre Uhr weckt; kein Start ohne Auftrag mit Feld „Zurück“; Routinen startest du wie jede Sitzung), Neustarts, Stillstand, Besetzung prüfen. Offene Übergabezeilen nimmst du in der Folge des Werkzeugs (Eilt, Fund des Chefs, Themenblock, Eingangszeit), eine nach der anderen. Repos bindest du mit `add_repo` ein, wenn du sie brauchst.

**Eingang.** Gibt es ihn schon? Sicher dasselbe: zum bestehenden Vorgang; sonst neu mit Verweis auf den ähnlichen. Ein „Hinweis“ ist ein Eingang. Klasse Muss oder Kür; Eilt setzt nur der Chef. „Systemlösung?“ des Wiederholungswächters (`vorgang.py`) nimmst du an und gibst sie als Zeile an den Arbeitsplaner.

**Rückläufer** bekommen keine neue Nummer, auch nach dem Merge: der Vorgang wird wieder offen. Einen Fund des Chefs startest du sofort, vor allem außer Eilt.

**Fertig.** „Fertig“ ohne Commit und verlangten Beleg nimmst du nicht an. Nach `main` nur, was der Chef freigab („gut“, „passt“, „freigegeben“), belegt in der Vorgangsdatei oder im Archiv; „Chef hat freigegeben“ ohne Beleg gilt nicht. Ohne seinen Test nur Punkte „ohne dich“ nach grünem Lauf und Kleinkram. Ausnahmen: Werkzeug geht nach grünem Lauf sofort nach `main`, beim Ergebnis mit Durchfall nach dem Revert der Rest (Checkliste 11, 12); eine Routine (Rundblick, Wochenzählung) meldet „fertig“ ohne Commit. Release nur auf sein Wort „Release“.

**Sokrates startest du** bei jeder offenen Übergabezeile an ihn (etwa „steckt fest“, das zweite desselben Vorgangs geht als Chefsache an den Chef; „Frage“; Chefwort, das wie ein Nein klingt); Eingang ohne Bereich, „zwei Wochen schlechter“ und Stillstand an einer Entscheidung gibst du als Zeile an ihn.

**Guthaben.** Das Werkzeug gibt die Stufe aus: ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand; du startest danach und nicht mehr.

**An den Chef** geht von dir nur zweierlei: lautlos eine Zeile zu einer neuen Chefsache-Datei, wenn er jetzt etwas tun kann; laut, wenn der Betrieb steht oder im Build ein fremder Commit oder ein fehlender früherer Build liegt (dann keine Testbitte).

**Werkzeugfehler:** Vorgang mit Profil Werkzeug, nicht umgehen. **Tagesbericht fehlt** (Wache meldet): Routine neu starten.
```

**Vorschlag Sokrates, Perikles prüft (1794):** in :20 der Satz „Ausnahmen: …“ (Fassung 8). Quellen: Werkzeug nach grünem Lauf sofort auf `main`, kein Test des Chefs (1311; `CLAUDE.md` „Jeder Schritt“); Ergebnis nach Checkliste 11, 12 (Revert, Rest nach `main`; Profil Technik 13); Routine ohne Commit (Rundblick, Wochenzählung; `rueckmeldung.py` `weitergabe`, 1789). Profiltext 2.433 → 2.644 Byte.

Größe Text: 2.644 Byte (Fassung 8; Fassung 6 und 7: 2.433, Fassung 5: 2.422, Fassung 3: 2.275 (altes Maß mit Zeilenende; Messregel 2.274), Fassung 2: 2.118). Die Sitzung lädt dazu Sockel (etwa 1 KB, `1727-sockel.md`) und Kern Büro (etwa 0,5 KB, VA 21.11., 11:46, noch nicht geschrieben): zusammen etwa 4,1 KB (Fassung 7: 3,9 KB; Größe nennen, Chef 20.11., 16:49).

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Disponent** | Nachricht (Wecker „sieh in <Nr>“, G:371), Stundenuhr (G:372), Wache | `lauf.py`-Ausgabe; offene Übergabezeilen; Eingang; neue Chefsache | Dauerlauf; Ende offen (Frage 3) | Zeile über `vorgang.py`, dann Wecker; laut in zwei Fällen | Arbeitsplaner, Fachkraft, Prüfer, Tester, Routinen (Start); Sokrates (1727c); Chef (laut, zweites „steckt fest“) | L-O1 (Ort des Eingangs) entschieden 1727d, Einbau offen (Kern Leitung); Werkzeugzeilen (Übergabe, C, Guthabenstufe) nicht gebaut; L-S2 geschlossen (1727d, `uebergabekette.md` Nr. 3) |

## Was gegenüber heute fällt oder wandert

- **Zu Werkzeugen:** Kosten buchen, Besetzung schreiben, Neustart-Meldungen (`lauf.py`); Telegram „du bist dran“, „Sitzung hängt“, rote Läufe (Routine Wache); Weitergabe nach dem ersten Wort, Rückläufer 1./2. Nein, Archivieren mit Schutz 15 Minuten, Doppelstart, Hinweis ab dem vierten Eilt (7.1).
- **Fällt:** Übernahme zwischen Teams (4.4).
- **Neu gegenüber Ford:** Klasse setzen statt „M?“ an Perikles; Sokrates starten (C).
- **Zahl der laufenden Fachkräfte** (BG:20): folgt aus der Guthabenstufe; keine eigene Zeile (Annahme, prüfen).

## Offen, Fragen

1. **Sammelfrage C (Chefsache, ändert VA 21.11., 14:37 C):** weitere Startgründe für Sokrates, die die Entwürfe brauchen: was keinem Bereich gehört (4.4), Höchstdauer überschritten (Profil Kosten), „zwei Wochen schlechter“ (Wochenzählung), Stillstand, der an einer Entscheidung hängt, und „Release“ vor 622 (Rückfrage, ob 622 vorgezogen wird; `LISTE-RELEASE-NEUSTART.md`:12). **Entschieden 1727c** (VA 21.11., 21:43, „1727c ja“): jede offene Übergabezeile an Sokrates startet ihn (wie `lauf.py` gebaut); Eingang ohne Bereich, „zwei Wochen schlechter“, Stillstand an Entscheidung als Zeile an ihn; ersetzt die drei Wörter in C. Nach Vorlage 1727c (Sachverhalt): Höchstdauer gedeckt (das zweite Mal gibt „steckt fest“ an Sokrates); „Release“ vor 622 braucht keinen Startgrund (wer das Wort hört, fragt zurück, ob 622 vorgezogen wird, `LISTE-RELEASE-NEUSTART.md`:12). Satz :22 geändert in Fassung 5 (gebaut: `tools/lauf.py` Funktion `sokrates_zeilen` mit Aufruf `uebergabe.offen_lokal("Sokrates", …)`, an `main` 60b49ffbb; jede offene Zeile an Sokrates ohne Wortfilter); Wortlaut :22 ist Vorschlag Sokrates zu 1727c (Vorlage: „Text wie gebaut“), nicht vorgelegt. Einschränkung: läuft Sokrates mit über 200 Tsd. Token oder unbekannt, gibt `lauf.py` (`sokrates_zeilen`, Zeile „NICHTS Sokrates: … offene Zeile(n) warten (1763 C), Sokrates läuft (Token über 200 Tsd. oder unbekannt)“, 60b49ffbb) nur „NICHTS … warten“, weder Start noch Wecken; die Zeile wartet bis zum nächsten Lauf. **Hinweis (Nachprüfung 22:29):** `profil-kosten.md`:17 gibt die überschrittene Höchstdauer schon beim ersten Mal als Zeile an Sokrates („Werkzeug hält an; Zeile an Sokrates, er entscheidet über die Grenze“), die Vorlage 1727c deckt sie erst mit dem zweiten Mal („steckt fest“); zwischen beiden Entwürfen offen, hier nicht geändert.
2. **Klasse „nach dem Katalog“:** wo der Katalog der Klassen steht, ist offen; bis dahin nur „Eilt setzt der Chef, sonst Muss oder Kür“.
3. **Nachfolger:** Ford hat heute keine Größenbremse, sondern Verdichtung; Neustart über den Chef bei etwa 400–500 Tsd. Token (`ARBEIT-BETRIEB.md`). Für den Disponenten keine Grenze entschieden; Vorschlag: wie heute.
4. „Systemlösung?“ an den Arbeitsplaner weitergeben ist Auslegung von VA 20.11., 10:27 (BG:13, L-U6).
5. **Ausnahmen in :20 „Fertig“ (Nachprüfungen 22:29, 22:47):** Ausnahme 1311 (Werkzeug nach grünem Lauf sofort nach `main`), „Ergebnis nach Checkliste 11, 12“ (Durchfall: Revert, Rest nach `main`, wie Profil Technik 13) und Routine („fertig“ ohne Commit, gebaut 1789 in `rueckmeldung.py` `weitergabe`). Der Nachtrag liegt jetzt in Vorgang 1794 (Perikles; Ausnahmen 1311, Checkliste 11/12, Routine), nicht 1773; Satz in :20 seit Fassung 8 als Vorschlag Sokrates, Perikles prüft.

## Stärkstes Gegenargument

Fast alles hängt an Werkzeugzeilen, die nicht gebaut sind (Übergabezeilen, C, Guthabenstufe, Weitergabe); bis dahin trägt der Text weniger als `ROLLE-BETRIEB.md`. **Dagegen:** genau so entschieden (VA 19.11., 19:37); umgestellt wird erst nach grünen Werkzeugen und Falltest (VA 21.11., 14:37).

## Nachprüfung Sokrates 20:27, mein Wort

(1) Folge Eilt, Fund, Themenblock, Eingangszeit: **stimmt**, passt zu „vor allem außer Eilt“ (G:375, BG:18) · (2) „gut“ ersetzt, „ohne dich“ und Kleinkram (Checkliste Build und Test 3, 9, 13): **stimmt**; Fassung 6 nahm „gut“ wieder auf (einheitlich mit Profil Technik F12, VA 15:15; im Text seit Fassung 6) · (3) Stillstand an Entscheidung, Release vor 622: **stimmt**, aus dem Text in Sammelfrage C · (4) Rückläufer ohne neue Nummer, Fund sofort: **stimmt**, eigener Absatz · (5) Wache ausgenommen: **stimmt** · (6) L-S2: **stimmt** · (7) Größe und Summe; „sonst nichts“ gegen Chefsache-Zeile: **stimmt**, beides in „An den Chef“ zusammengeführt.

## Gegenprüfung 20:18 (frischer Prüfer, 23 Befunde, sechs Dateien), mein Wort zu den Befunden dieser Datei

8 Sackgasse Sokrates: **stimmt**, Sammelfrage C · 9 zweites „steckt fest“ an den Chef (B): **stimmt** · 10 fehlende Ford-Aufgaben: **stimmt**, Chefsache, Besetzung prüfen, Stillstand, Werkzeugfehler aufgenommen, Neustart-Meldungen zum Werkzeug, Zahl der Fachkräfte über Guthabenstufe · 11 nachts doppelt, Größenhaken unentschieden: **stimmt** · 12 Starter der Routinen: **stimmt**, Disponent startet alle, „Tagesbericht fehlt → neu starten“ · 20 Release-Zeilen fehlen: **stimmt**, aufgenommen · 21 Begriffe, Auslegung: **stimmt** · 22 Büro-Liste ohne Themenblock, zwei laute Fälle, „startest“: **stimmt** · 23 Repos: **stimmt**, Zeile im Profil.

## Nachprüfung 22:29/22:30, mein Wort

Mein Wort (Sokrates): alle **stimmt**. D1 Zeilenangaben `lauf.py`: **stimmt, eingearbeitet**, Offen 1 mit Funktionsname `sokrates_zeilen` (Aufruf `offen_lokal`, NICHTS-Zeile) und Commit 60b49ffbb · D2 Token: **stimmt, eingearbeitet**, „über 200 Tsd. Token oder unbekannt“ · D3 L-O1 im Raster: **stimmt, eingearbeitet**, „entschieden 1727d, Einbau offen (Kern Leitung)“ · D4 „gut“: **stimmt, eingearbeitet**, Satz an Nachprüfung 20:27 (2) · D5 Ausnahmen 1311 und Checkliste 11, 12: **stimmt, eingearbeitet**, vermerkt als Offen 5 bei 1773 (Perikles), kein Einbau; dazu 1794 · D6: **stimmt**; der Wortlaut des Befunds lag beim Einarbeiten nicht vor, nichts geändert · Hinweis `profil-kosten.md`:17: **stimmt, eingearbeitet**, als Hinweis in Offen 1.

## Nachprüfung 22:47, mein Wort

Mein Wort (Sokrates): alle **stimmt**. 1 Offen 5 nannte 1773: **stimmt, eingearbeitet**, Nachtrag liegt in Vorgang 1794 (Perikles; Ausnahmen 1311, Checkliste 11/12, Routine), nicht 1773 · 2 :20 „Fertig“ ohne Ausnahmen: **stimmt, eingearbeitet**, ein Satz als Vorschlag Sokrates, Perikles prüft (1794): Werkzeug nach grünem Lauf (1311), Ergebnis nach Checkliste 11, 12 (Profil Technik 13), Routine ohne Commit (Rundblick, Wochenzählung; `rueckmeldung.py` `weitergabe`, 1789); Profiltext 2.433 → 2.644 Byte · 3 Größe Fassung 3: **stimmt, eingearbeitet**, „2.275 (altes Maß mit Zeilenende; Messregel 2.274)“; „Rückfrage an Sokrates“ bei D6 gestrichen · 4 Nachprüfung 20:27 (2): **stimmt, eingearbeitet**, „Fassung 6 nahm ‚gut‘ wieder auf“ · 5 „3.9 KB“: **stimmt, eingearbeitet**, Dezimalkomma; mit dem längeren Profiltext jetzt „etwa 4,1 KB“ (Fassung 7: 3,9 KB) · 6 Raster Spalte 6: **stimmt, eingearbeitet**, „Sokrates (1727c)“.
