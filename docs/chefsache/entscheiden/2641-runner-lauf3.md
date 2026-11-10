# 264.1 · Eigener Runner: Ursache am Rechner prüfen und dann dritter Lauf?
Perikles · 10.11., 18:32 · B Werkzeuge · aus Lauf 325 nach deinem „264.1 erledigt“ (17:59)
Kurz: Lauf 325 brach beim Laden der freien Quaternius-Pakete von itch.io ab; bis dahin war der Runner langsamer als GitHub, fast nur durch Einmal-Kosten.

Geprüft an: Lauf 325, https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42860370977

**Frage:** Der zweite Lauf auf proxmox-bornim kam bis zum Schritt „CC0-Pakete (Quaternius)“ und brach dort nach einer Sekunde ab: itch.io gab dem Runner keine verwertbare Antwort. Von unserer Cloud aus liefert dieselbe Anfrage um 18:31 die Download-Adresse; am Skript liegt es also nicht, sondern an der Leitung oder Adresse des Runners. Auf GitHub fällt das nicht auf, weil die Pakete dort aus dem Zwischenspeicher kommen; der gilt für den eigenen Runner nicht. Sollst du die Ursache einmal mit einem Befehl auf der Maschine des Runners prüfen, bevor ein dritter Lauf startet?

**Votum:** „264.1 A“: auf der Maschine des Runners ausführen und mir die Ausgabe schicken (zwei Zeilen):

```
curl -sS -o /dev/null -w "%{http_code} %{remote_ip}\n" https://quaternius.itch.io/universal-base-characters
curl -sS -X POST https://quaternius.itch.io/universal-base-characters/download_url | head -c 200; echo
```

**Berührt:** nur 264.1 (Zweig `claude/perikles-264-runner`); kein Push auf main, kein Team.

**Begründung:** Regel „nie einen Fehler zweimal mit Vermutung bauen“; ein dritter Lauf kostet etwa eine Stunde, der Befehl 30 Sekunden.

**Sachverhalt:**
- Runner: Ubuntu 24.04, 4 Kerne, 15 GB Speicher, 102 GB frei.
- Zeiten Runner (Lauf 325) gegen GitHub (Lauf 322, Build 274, gesamt 63 Min.):
  - Runner vorbereiten 1:38 (nur beim ersten Mal; Android-SDK lag schon unter /opt/android-sdk)
  - Karten aus core 3:34 gegen 1:18 (Gradle ohne Zwischenspeicher, beim nächsten Mal warm)
  - Gekaufte Modelle 5:22 gegen 1:33 (Download über deine Leitung, jedes Mal)
  - Python einrichten 2:16 gegen 0:01, Blender 2:43 gegen 0:25 (nur beim ersten Mal)
- Die teuren Schritte, an denen sich der Gewinn entscheidet, kamen noch nicht dran: Held je Klasse 11:43, Leute 8:43, Kampfort 13:51, Skripte prüfen 16:46 auf GitHub.

**Auswertung:**
- **A (Empfehlung):** Befehl auf der Maschine, dann behebe ich die Ursache gezielt und Lauf 3 misst die teuren Schritte. Kosten: 30 Sekunden für dich, ein Lauf.
- **B:** Lauf 3 sofort, mit Ausgabe der itch-Antwort im Schritt; sieht die Ursache auch, braucht aber wahrscheinlich einen vierten Lauf für die Behebung.
- **C:** Probe beenden; bisher war der Runner nirgends schneller.
- **Stärkstes Gegenargument gegen A:** Schon jetzt ist der Download der gekauften Modelle 3,5-mal langsamer; liegt es an der Leitung, frisst sie einen Teil des Gewinns. Antwort: die gekauften Modelle kann der Runner dauerhaft auf der Platte behalten, dann fällt der Download weg; das zeigt Lauf 3.

**Folgerungen:** nach A und deiner Ausgabe: Behebung im Zweig, Lauf 3, Zeiten je Schritt per Telegram (Perikles).

Antwort: …
