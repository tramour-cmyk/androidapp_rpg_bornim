# Arbeitsorte: GitHub, Proxmox, NAS, ALL-INKL

Zum Nachlesen (Chef 23.10., 17:45). Entscheidung offen in Chefsache 264; Hintergrund 109 (Repo öffentlich). Stand 23.10., 17:46, Sokrates (fremd geprüft).

## Die drei Teile unserer Werkstatt

| Teil | Was er tut | Heute |
|---|---|---|
| **Ablage** | hält den Code, die Notizen, die Pull Requests (Freigaben) | GitHub, Repo **öffentlich** |
| **Arbeiter** | die Claude-Sitzungen (Tom, Jerry, Ford …): lesen den Code, schreiben, testen | Cloud-Sitzungen bei Anthropic; sie holen und liefern den Code über GitHub |
| **Werkbank** | baut aus dem Code die APK und signiert sie | GitHub Actions (Server von GitHub) |

Ford startet Sitzungen, Weckrufe und Nachrichten zwischen Sitzungen laufen über die Cloud von Anthropic. Telegram-Meldungen, `lauf.py` und die Haken laufen in den Sitzungen.

## Warum das Repo öffentlich ist (109, 16.10.)

Privat zahlt man bei GitHub für die Werkbank: Wir brauchen etwa 3.300 Build-Minuten pro Woche, frei sind 2.000 im Monat; dazu 6 GB APKs gegen 500 MB freien Speicher. Geschätzt 70–100 $ im Monat. Öffentlich ist beides frei, aber jeder kann den Code lesen und kopieren.

## Die Wege

**A. Wie heute.** Alles bei GitHub, öffentlich. Kostet nichts, Code ist offen.

**B. Repo privat, Werkbank zu Hause (Empfehlung).**
- Ablage bleibt GitHub, aber **privat**: niemand außer uns sieht den Code.
- Arbeiter bleiben die Cloud-Sitzungen, Ford und alle Abläufe bleiben unverändert.
- Nur die **Werkbank** zieht um: ein „eigener GitHub-Runner“ in einer VM auf Proxmox. GitHub schickt jeden Build-Auftrag an diese VM; sie baut die APK. Builds auf dem eigenen Runner kosten bei GitHub nichts. Die APKs liegen auf der VM oder dem NAS, mit kurzer Aufbewahrung.
- Das ist kein GitHub-Klon, nur der Bau-Rechner.
- Was dafür zu tun ist:
  - **Du:** VM anlegen, JDK und Android-SDK installieren (die GitHub-Server bringen beides mit, die VM nicht), Runner bei GitHub anmelden. Etwa 2–4 Stunden; eine Claude-Sitzung auf dem Rechner kann helfen.
  - **Team Tom:** die Bauanleitungen (`.github/workflows/android.yml`, `vorschau.yml` u. a.) von `runs-on: ubuntu-24.04` auf den eigenen Runner umstellen und die APK-Ablage umbauen (heute `upload-artifact` ohne Aufbewahrungsfrist; der Speicher zählt auch beim eigenen Runner). Das ist Code, also mit deinem Test.
  - Vorher die Aufbewahrung der APKs kürzen (109).
- Proxmox läuft ohnehin rund um die Uhr (Chef 17:43).

**C. Alles zu Hause.**
- Ablage: ein eigenes Git (z. B. Gitea) auf NAS oder Proxmox.
- Arbeiter: Claude Code in einer VM auf Proxmox, gestartet mit `claude remote-control` im Projektordner; die Sitzung erscheint in deiner Claude-App.
- Werkbank: dieselbe VM.
- Dann braucht es weder GitHub noch Cloud-Sitzungen.
- Aber: Fords Betrieb (Sitzungen selbst starten, Weckrufe, mehrere Rollen gleichzeitig, Nachrichten zwischen Sitzungen) ist auf Cloud-Sitzungen gebaut. Zu Hause müsste jede Rolle als eigener Prozess auf der VM laufen und von Hand oder per Skript gestartet werden; Werkzeuge, Haken, Signatur und Freigaben müssten neu gebaut werden. Schätzung: Wochen, gegen die oberste Direktive (338).
- Kosten an Claude-Guthaben: gleich, die Sitzung zu Hause zieht dasselbe Abo.

**C2. Ablage zu Hause, Arbeiter in der Cloud** (Chef 17:47: „ich habe hier Reverse Proxy … wie kriegt Claude Zugang auf Services, die hier zu Hause laufen?“).
- Berichtigung: Cloud-Sitzungen erreichen jeden Dienst, der über deinen Reverse Proxy per HTTPS im Internet steht. Dazu trägst du in den Einstellungen der Umgebung (Wolkenmenü oben in der Sitzung, „Bearbeiten“, Netzwerkzugriff) den Namen unter „Erlaubte Domains“ ein, z. B. `git.<deine-domain>`. Den Zugang hinterlegst du als Netzwerk-Geheimnis, nie im Chat. Neue Sitzungen haben ihn dann. Anleitung: https://code.claude.com/docs/en/cloud-environments#network-access
- Damit ginge: ein eigenes Git (Gitea/Forgejo) auf Proxmox hinter dem Reverse Proxy; die Cloud-Sitzungen holen und liefern den Code dort mit einem Zugangsschlüssel; gebaut wird mit dem Runner von Gitea auf derselben VM.
- Was dabei verloren geht: Alles, was an GitHub hängt, müsste neu: Freigaben über Pull Requests, Weckrufe bei Builds und Kommentaren, Sitzungsstart mit fertig geholtem Repo, Ford-Werkzeuge. Ob der Sitzungsstart ein fremdes Git direkt annimmt, ist ungeprüft; sonst holt jede Sitzung den Code beim Start selbst. Dazu steht dann ein Dienst von dir offen im Internet, den du absichern und pflegen musst.
- Urteil: geht, schützt den Code aber nicht besser als B, kostet mehr Umbau und öffnet dein Heimnetz nach außen.

**Wichtig für alle Wege:** Der Code geht beim Arbeiten immer zu Claude (Anthropic), sonst könnte Claude ihn nicht lesen. Gegen Fremde schützt nur „privat“ oder „zu Hause“, nicht gegen den Dienst, mit dem wir arbeiten.

## Sicherheit bei B und C

- Die Runner-VM führt Code aus dem Repo aus. Sie gehört in ein eigenes Netz (eigene Bridge oder VLAN), nur mit Ausgang ins Internet, ohne Zugriff auf Home Assistant und das übrige Heimnetz.
- Größe: etwa 4 Kerne, 8 GB RAM, 40 GB Platte.
- Signaturschlüssel bleiben GitHub-Secrets; die VM bekommt sie nur während des Builds. Der Build entpackt den Schlüssel auf die Platte: Der Runner muss danach aufräumen oder bei jedem Build frisch starten.
- Mit privatem Repo laufen Workflows aus fremden Forks nicht ohne Freigabe; ein eigener Runner an einem öffentlichen Repo wäre gefährlich. Darum erst privat, dann der Runner aktiv.
- NAS und Proxmox nie direkt ins Internet öffnen; der Runner baut die Verbindung zu GitHub von innen auf.

## Dazu, unabhängig vom Weg

- **NAS:** nächtliche Spiegelkopie des Repos (`git clone --mirror`, Aufgabenplaner der Synology), Schutz, falls das GitHub-Konto gesperrt wird. Belegablage fürs Geschäftszimmer (263).
- **ALL-INKL:** Webseite und Impressum (252); als Entwicklungsort ungeeignet (Webhosting, kein Rechner). Die Nextcloud dort bleibt, wie sie ist.

## Empfehlung (Sokrates)

B vor dem Marktstart: Runner auf Proxmox einrichten, dann Repo privat stellen, dazu die Spiegelkopie auf dem NAS. C erst, wenn ein klarer Grund dazukommt, z. B. wenn wir GitHub oder die Cloud-Sitzungen nicht mehr nutzen können.

**Stärkstes Gegenargument gegen B:** Ein Rechner mehr, den du pflegst (Updates, Platz). Gegen die 70–100 $ im Monat und den offenen Code wiegt das wenig.
