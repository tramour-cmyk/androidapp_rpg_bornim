# 464 · Godot in jeder Sitzung: Zeile im Setup-Skript der Umgebung
Perikles · 01.11., 20:51 · M Abläufe

Von 14 roten Läufen heute wären 5 vor dem Push am Rechner aufgefallen, zwei davon schon beim bloßen Lesen der Skripte (Parsefehler; in den Commits steht „Lokal: Godot nicht vorhanden“). Seit 20:50 hält der Push-Haken solche Fehler an, aber nur, wo Godot da ist. Jerrys Sitzung darf Godot nicht laden (die Rechteprüfung der Sitzung lehnte den Download ab, obwohl du ihn am 28.10. erlaubt hast, 399.2d). Damit fallen seine Fehler weiter erst auf GitHub auf, mit E-Mail an dich.

**Votum Perikles:** Godot einmal im Setup-Skript der Umgebung laden, dann hat jede neue Sitzung es, ohne Rechtefrage. Kostet etwa 10 s je Sitzungsstart. Stärkstes Gegenargument: jede Sitzung lädt 60 MB, auch Homer und Sokrates, die es nie brauchen; entkräftet, weil der Download nur einmal je Container läuft und nichts kostet.

Nur du kannst (Menü der Cloud-Umgebung in der Titelzeile einer Sitzung, dann Bearbeiten, Feld „Setup script“) diese Zeile anhängen:

```
mkdir -p ~/godot && cd ~/godot && [ -f godot ] || { curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip && unzip -q g.zip && mv Godot_v4.7.2-stable_linux.x86_64 godot && rm g.zip; }
```

Gilt für neue Sitzungen. Erledigt: „464 Setup drin“; dann lösche ich die Datei.
