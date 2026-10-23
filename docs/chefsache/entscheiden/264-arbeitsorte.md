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

## Nachtrag 23.10., 17:42 (Chef 17:40: „Brauchen wir unbedingt das GitHub, das im Netz steht, wo irgendein Pfiffikus … mir den ganzen Code klauen [kann], solange ich nicht auf privat stelle? Ginge das?“)

- **Ganz zu Hause entwickeln geht:** Claude Code in einer VM auf Proxmox (Linux, JDK, Android-SDK), gestartet mit `claude remote-control` im Projektordner, erscheint in der Claude-App; Code in einem Git auf dem NAS. Aber Fords Betrieb (Sitzungen starten, Weckrufe, mehrere Rollen gleichzeitig) läuft in Cloud-Sitzungen, und die erreichen dein Heimnetz nicht. Das wäre der Umbau über Wochen aus dem Befund.
- **Warum das Repo öffentlich ist (109, 16.10.):** Privat hätten die Builds etwa 70–100 $ im Monat gekostet (3.300 Build-Minuten je Woche gegen 2.000 freie im Monat; APK-Ablage 6 GB gegen 500 MB).
- **Neuer Weg, der beides löst:** Repo **privat** stellen und die Builds auf einem **eigenen GitHub-Runner in einer Proxmox-VM** laufen lassen. Minuten auf dem eigenen Runner kosten bei GitHub nichts. Die APKs bleiben auf der VM oder dem NAS statt in GitHub, mit kurzer Aufbewahrung dort. Cloud-Sitzungen, Ford, Pull Requests und Freigaben bleiben, wie sie sind.
- *Stärkstes Gegenargument:* Ist die VM aus, wartet jeder Build. Der Runner führt Code aus dem Repo aus, darum gehört er in eine abgeschottete VM ohne Zugriff aufs übrige Heimnetz. Einrichten kannst nur du (etwa 1–2 Stunden, auf Wunsch mit einer lokalen Claude-Sitzung).
- *Empfehlung neu:* vor dem Marktstart (338 f): Runner auf Proxmox, dann Repo privat (109). Dazu die Spiegelkopie auf dem NAS (2b). Alles andere wie oben.

Berührt: 252 (Webseite), 253 (BornWire), 263 (Geschäftszimmer), 109 (Repo öffentlich), 338.
