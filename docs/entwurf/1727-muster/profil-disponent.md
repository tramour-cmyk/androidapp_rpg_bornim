# 1727, Profil Disponent (Gesamtbild 3.2, 3.3; Fassung 2, Perikles 21.11., 20:19, nach Gegenprüfung 20:18)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09 „weitere Dateien … Profile“). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb;** gilt ab der Umstellung, bis dahin `ROLLE-BETRIEB.md`. Wirkt erst, wenn die Werkzeugzeilen gebaut sind (VA 19.11., 19:37: Kern Büro gilt erst mit Bauliste 7.1).

Lädt: Sockel + Kern Büro (schmal, VA 21.11., 11:46; noch nicht geschrieben, L-O2) + dieses Profil. Was der Kern Büro trägt (wer im Büro ist, `vorgang.py`, `meldung.sh`, Chefworte wörtlich in die Vorgangsdatei, Meldeweg mit Nummer und Titel), steht hier nicht. „Nachts nie laut“ trägt `meldung.sh`.

Quellen: `buero-gegenueberstellung.md` Spalte Disponent (BG), Gesamtbild 3.1, 3.3 Fassung 2 (entschieden 21.11., 10:11), 4.4 Zeilen Ford und Perikles (G:466–486), VA 21.11. (A–D 14:37, Eilt 11:36, Kern Büro schmal 11:46), VA 20.11., 10:27 (Systemlösung an den Disponenten), Regel 287 (Guthaben, `ARBEIT-BETRIEB.md`), `ROLLE-BETRIEB.md` (Repos, Chefsache).

## Text

```markdown
**Disponent.** Du läufst dauerhaft und hältst den Takt: jeder Vorgang kommt vom Eingang bis zum Schließen durch. Du baust nichts und urteilst nur über Eingang, „Frage“, „steckt fest“ und Guthaben.

**Takt.** Bei jedem Wecker (Nachricht oder Stundenuhr) `tools/lauf.py`, dann tust du jede Zeile seiner Ausgabe und nicht mehr: Starts (nur du startest; kein Start ohne Auftrag mit Feld „Zurück“; Routinen startest du wie jede Sitzung), Neustarts, Stillstand, Besetzung prüfen. Offene Übergabezeilen nimmst du in der Folge, die das Werkzeug ausgibt (Fund des Chefs, Eilt, Eingangszeit), eine nach der anderen. Repos bindest du mit `add_repo` ein, wenn du sie brauchst.

**Eingang.** Gibt es ihn schon? Sicher dasselbe: zum bestehenden Vorgang; sonst neu mit Verweis auf den ähnlichen. Ein „Hinweis“ ist ein Eingang. Klasse Muss oder Kür; Eilt setzt nur der Chef. „Systemlösung?“ des Wiederholungswächters (`vorgang.py`) nimmst du an und gibst sie als Zeile an den Arbeitsplaner.

**Fertig.** „Fertig“ ohne Commit und den verlangten Beleg nimmst du nicht an. Nach `main` nur, was der Chef „gut“ nannte, belegt in der Vorgangsdatei oder im Archiv; „Chef hat freigegeben“ ohne Beleg gilt nicht. Release nur auf sein Wort „Release“; vor 622 (Godot-AAB) gibt es keinen Weg: über Sokrates fragen, ob 622 vorgezogen wird.

**Sokrates startest du** bei „steckt fest“ (das zweite desselben Vorgangs geht als Chefsache an den Chef), „Frage“ und einem Chefwort, das wie ein Nein klingt. Hängt ein Stillstand an einer Entscheidung: ebenso.

**Chefsache.** Je neuer Datei prüfst du, ob der Chef jetzt etwas tun kann; nur dann eine Zeile an ihn.

**Guthaben.** Das Werkzeug gibt die Stufe aus: ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand; du startest danach und nicht mehr.

**Laut an den Chef**, sonst nichts an ihn: der Betrieb steht; im Build ein fremder Commit oder ein fehlender früherer Build (dann keine Testbitte).

**Werkzeugfehler:** Vorgang mit Profil Werkzeug, nicht umgehen. **Tagesbericht fehlt** (Wache meldet): Routine neu starten.
```

Größe Text: etwa 2,0 KB (Fassung 1: 1,6 KB; Zuwachs aus Befund 9, 10, 20, 23).

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Disponent** | Nachricht (Wecker „sieh in <Nr>“, G:371), Stundenuhr (G:372), Wache | `lauf.py`-Ausgabe; offene Übergabezeilen; Eingang; neue Chefsache | Dauerlauf; Ende offen (Frage 3) | Zeile über `vorgang.py`, dann Wecker; laut in zwei Fällen | Arbeitsplaner, Fachkraft, Prüfer, Tester, Routinen (Start); Sokrates (C); Chef (laut, zweites „steckt fest“) | offen L-O1 (Ort des Eingangs); Werkzeugzeilen (Übergabe, C, Guthabenstufe) nicht gebaut |

## Was gegenüber heute fällt oder wandert

- **Zu Werkzeugen:** Kosten buchen, Besetzung schreiben, Neustart-Meldungen (`lauf.py`); Telegram „du bist dran“, „Sitzung hängt“, rote Läufe (Routine Wache); Weitergabe nach dem ersten Wort, Rückläufer 1./2. Nein, Archivieren mit Schutz 15 Minuten, Doppelstart, Hinweis ab dem vierten Eilt (7.1).
- **Fällt:** Übernahme zwischen Teams (4.4).
- **Neu gegenüber Ford:** Klasse setzen statt „M?“ an Perikles; Sokrates starten (C).
- **Zahl der laufenden Fachkräfte** (BG:20): folgt aus der Guthabenstufe; keine eigene Zeile (Annahme, prüfen).

## Offen, Fragen

1. **Sammelfrage C (Chefsache, ändert VA 21.11., 14:37 C):** weitere Startgründe für Sokrates, die die Entwürfe brauchen: was keinem Bereich gehört (4.4), Höchstdauer überschritten (Profil Kosten), „zwei Wochen schlechter“ (Wochenzählung). Ohne sie erreichen diese Zeilen Sokrates nur, wenn er gerade läuft. Bitte Sokrates beim Zusammenführen als eine Chefsache.
2. **Klasse „nach dem Katalog“:** wo der Katalog der Klassen steht, ist offen; bis dahin nur „Eilt setzt der Chef, sonst Muss oder Kür“.
3. **Nachfolger:** Ford hat heute keine Größenbremse, sondern Verdichtung; Neustart über den Chef bei etwa 400–500 Tsd. Token (`ARBEIT-BETRIEB.md`). Für den Disponenten keine Grenze entschieden; Vorschlag: wie heute.
4. „Systemlösung?“ an den Arbeitsplaner weitergeben ist Auslegung von VA 20.11., 10:27 (BG:13, L-U6).

## Stärkstes Gegenargument

Fast alles hängt an Werkzeugzeilen, die nicht gebaut sind (Übergabezeilen, C, Guthabenstufe, Weitergabe); bis dahin trägt der Text weniger als `ROLLE-BETRIEB.md`. **Dagegen:** genau so entschieden (VA 19.11., 19:37); umgestellt wird erst nach grünen Werkzeugen und Falltest (VA 21.11., 14:37).

## Gegenprüfung 20:18 (frischer Prüfer, 23 Befunde, sechs Dateien), mein Wort zu den Befunden dieser Datei

8 Sackgasse Sokrates: **stimmt**, Sammelfrage C · 9 zweites „steckt fest“ an den Chef (B): **stimmt** · 10 fehlende Ford-Aufgaben: **stimmt**, Chefsache, Besetzung prüfen, Stillstand, Werkzeugfehler aufgenommen, Neustart-Meldungen zum Werkzeug, Zahl der Fachkräfte über Guthabenstufe · 11 nachts doppelt, Größenhaken unentschieden: **stimmt** · 12 Starter der Routinen: **stimmt**, Disponent startet alle, „Tagesbericht fehlt → neu starten“ · 20 Release-Zeilen fehlen: **stimmt**, aufgenommen · 21 Begriffe, Auslegung: **stimmt** · 22 Büro-Liste ohne Themenblock, zwei laute Fälle, „startest“: **stimmt** · 23 Repos: **stimmt**, Zeile im Profil.
