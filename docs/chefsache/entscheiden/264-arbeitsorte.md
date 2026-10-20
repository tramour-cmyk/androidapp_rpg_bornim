# 264 · Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL?
Sokrates · 20.10., 21:05 · B Betrieb · K (Chef 20.10., 21:02, Wortlaut: „Ich habe hier ein Synology-NAS, einen Proxmox-Server und Cloudspeicher bei Allinkl … Wie kann ich dich auf andere Orte berechtigen? Welcher Speicherort macht für dich am meisten Sinn (neben GitHub? Oder eine eigene Entwicklungsumgebung auf Proxmox oder dem Synology? Oder auf Allinkl? Geht das? Dann würden wir gar nichts mehr direkt auf Github machen, sondern unsere Entwicklung woanders erledigen.“)

## Befund

- **An GitHub hängt alles:** Cloud-Sitzungen klonen von dort, Builds und Signatur laufen in GitHub Actions (Schlüssel nur als GitHub-Secret), Ford startet Sitzungen auf das Repo, Freigaben laufen über Pull Requests. Weg von GitHub heißt: Builds, Signatur, Sitzungsstart, Werkzeuge (`lauf.py`, Haken) neu bauen. Wochen Arbeit gegen die oberste Direktive (179).
- **Berechtigen geht so:** Cloud-Sitzungen erreichen einen Dienst, wenn in den Einstellungen der Umgebung (Wolkenmenü oben, „Bearbeiten“) die Adresse unter „Erlaubte Domains“ steht und der Zugang als Netzwerk-Geheimnis hinterlegt ist; nie Passwörter in den Chat. Geräte im Heimnetz (NAS, Proxmox) erreicht nur eine Sitzung, die dort läuft (Desktop-App oder `claude remote-control` in einer VM).
- **Kosten:** Eine Sitzung auf Proxmox zieht dasselbe Max-Guthaben wie in der Cloud; gespart wird nichts, nur Grenzen des Containers (Speicher, Netz) fallen weg.

## Vorschlag

1. **GitHub bleibt Mitte** für Code, Builds, Notizen.
2. **NAS:** (a) Belegablage für das Geschäftszimmer (263), nur von dir oder einer lokalen Sitzung; (b) **nächtliche Spiegelkopie des Repos** (Aufgabenplaner der Synology, `git clone --mirror`, dann `git remote update`): Schutz, falls das GitHub-Konto gesperrt wird. NAS nie ins Internet öffnen.
3. **ALL-INKL:** Webhosting für die Webseite (252), sobald sie dran ist; Hochladen per SFTP aus einer Cloud-Sitzung (Domain freigeben, Zugang als Geheimnis). Als Entwicklungsort ungeeignet (Webhosting, keine Rechenmaschine).
4. **Proxmox: noch nicht.** Erst, wenn der Container uns sichtbar bremst (Speicher voll, Build am Rechner nötig, Gerätetest im Emulator); dann eine abgeschottete VM ohne Zugriff aufs übrige Heimnetz.

## Stärkstes Gegenargument

Alles bei einem Anbieter ist ein Klumpenrisiko; eine eigene Umgebung wäre unabhängig. Antwort: Die Spiegelkopie auf dem NAS deckt den Ernstfall für ein paar Minuten Einrichtung; der Umzug selbst kostet Wochen und bringt dem Spiel nichts.

## Empfehlung

**1 bis 4 wie oben.** Zuerst nur 2b (Spiegelkopie), Rest bei Anlass.

Berührt: 252 (Webseite), 253 (WireStorm), 263 (Geschäftszimmer).
