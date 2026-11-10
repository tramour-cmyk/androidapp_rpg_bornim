# 264.1 · Auf dem eigenen Runner apt-get ohne Passwort freigeben
Perikles · 10.11., 17:55 · B Werkzeuge

Der Probelauf von godot.yml auf proxmox-bornim (Lauf 324) brach nach 36 Sekunden ab, weil der Benutzer runner für sudo ein Passwort braucht. Checkout, Java und Gradle liefen schon. godot.yml installiert an vielen Stellen Pakete mit `sudo apt-get` (Blender, Xvfb, ffmpeg, Vulkan).

Einmal auf der Maschine des Runners als Administrator ausführen:

```
echo 'runner ALL=(root) NOPASSWD: /usr/bin/apt-get' | sudo tee /etc/sudoers.d/runner
```

Das gibt nur apt-get frei, keine vollen Root-Rechte. Gegenargument: wer apt-get darf, kann Pakete als root installieren; das ist tragbar, weil das Repo privat ist und nur wir pushen. Danach „264.1 erledigt“; ich starte den Lauf neu und vergleiche die Bauzeit je Schritt mit den GitHub-Läufen.
