# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-ENTWICKLUNG.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**Vorrang (von Sokrates, Chef 11.11., 07:16; Pause aufgehoben):** „wenn sie nichts mehr für den Umzug zu tun haben, ob sie dann Pause haben. Ja, macht ja keinen Sinn.“ und „lass das Spike und Taffy das machen. Fehler ausmerzen“. (1) Umzug 870.x zuerst; (2) wartet der Umzug, Fehler aus den Tests des Chefs (Muss, wiederholte zuerst); kein Neues (Chef 10.11., 14:08: „nicht wieder irgendeinen Füllefanz neu anfangen“). Spike nimmt Fehler aus den Tests, solange Tom am Umzug ist. Umzugsdateien (`LISTE-UMZUG-BRS.md` 4) ändert nur der Umzugszweig (Grundsatz 5).

**Übergabe (21.11., 20:42, `session_01Hmoj78DiFwajwS4D9pgu7E`):** Auf Chefwort 20:06 (über Ford) nur 1535 fertig. Getan: Bild alt (299) gegen neu, Garrick und Bram im Kittel, Ruhe_Trinken, Spielkamera, an den Chef 20:38 (`ansehen/1535-flanke.md`); Bildskript `godot/tests/spielbild_1535.gd` (`claude/tom-1535-gruss` `bfd783a3c`, Pose fest, Blick zur Kamera). Erster Lauf durch Skriptfehler verbraucht, zweiter frei vom Chef 20:31. Nachfolger: Tom – 1535: Urteil zum Bild, dann Sammelbuild 1535/1650/1205/1205b (erst wenn Ford Tom wieder ruft).
- **Zugriff, von Chef (16.11., 15:06, im Chat an Tom):** „Du darfst auf alle Repos zugreifen, die du zum Arbeiten brauchst.“ (Kaufrepo per `add_repo`, ohne Rückfrage)

## Einzelheiten

- **Von Spike (1307, 16.11., 14:33):** Sperrklinke Typen auf `main` (`f8a06554f`): in `godot/regeln/` und `godot/kampf/` je Datei nicht mehr Stellen ohne Typ als in `godot/tests/typen_1268.json`, neue Dateien 0, sonst ist der Prüfschritt rot. Grenzen aus `main` und den offenen Zweigen (auch `tom-1341-bild`, `tom-1383-ziege`), heute grün. Prüfen: `python3 tools/godot/typen.py`.

- **Rest aus 1186/1359 (archiviert; Wortlaut in Git vor 16.11., 10:26):** offen je ein Satz an Sokrates: 477, 348.13, 569, 455.1, 455.2, 513, 292.4, 30, 145, 614, 678, 861/862 doppelt, 1122/1079 schließen nach 283 auf `main`, 1108, 1140, 964/967 (Code auf `main` ohne Test?).
- **Rechnerweg (Tom):** Godot-Tests: Daten per gradle export wie `godot.yml` 57–78, `--import`, dann `user://test.cfg` löschen; Testbefehle mit wörtlichem `res://tests/<datei>.gd`. Gebietskarten ohne Kaufpakete: `python3 -m venv ~/bl && ~/bl/bin/pip install bpy==5.2.3 numpy pillow`, `PAKETE="medieval-village-megakit stylized-nature-megakit" bash tools/blender348/v3/cc0_laden.sh ~/cc0`, dann `OUT=… KARTEN=$PWD/godot/daten/karten.json`, `tex.py`, `KARTE=<karte> bl/bin/python -I tools/blender348/v3/dorf.py` (3 min je Karte).

**Ältere Einzelheiten** (621.2; `grep "Zu [^*]*<Nr>"` in): `git show d579b9d49:docs/ARBEIT-TEAM-TOM.md` (1119, 1120, 1118, 1108 mit Texten Homer, 1092 Sokrates und Diogenes, 1086, 764, 1081, 1044 Tom 09:53, 492/1104/1040.1, 282 Lauf-Start, 756 Wortlaute); `git show 94621abe7:docs/ARBEIT-TEAM-TOM.md` (1092 Messung 08:48, 492 03:29 und 22:15, 758, 756 Spike 14:18, 282 04:26, ältere zu 867, 1044, 1090, 842, 1022); `git show 0f5f13313:docs/ARBEIT-TEAM-TOM.md` (dort unten das ganze Verzeichnis älterer Stände).
