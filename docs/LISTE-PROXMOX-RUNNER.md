# Build-Rechner auf Proxmox einrichten

Schritt für Schritt (Chef 23.10., 17:54: „so detailliert, dass das meine Oma mit 90 Jahren könnte“). Hintergrund und Abwägung: `LISTE-ARBEITSORTE.md`, Weg B; Entscheidung in Chefsache 264. Stand 23.10., Sokrates.

**Was am Ende da ist:** eine eigene kleine Maschine (VM) auf deinem Proxmox. Sie wartet still auf Aufträge von GitHub, baut die APK und schickt sie zurück. Sie sieht das Internet, aber nicht dein Heimnetz (Home Assistant, NAS usw.).

**Was du brauchst:** Proxmox im Browser (Anmeldung wie immer), dein GitHub-Konto im Browser, etwa 1 Stunde, davon die meiste Zeit Warten.

**Reverse Proxy:** Für diesen Build-Rechner **nicht nötig, bitte nichts eintragen.** Der Rechner ruft selbst bei GitHub an und holt sich die Aufträge; von außen muss niemand zu ihm hinein. Eine Regel im Reverse Proxy der Synology würde nur eine unnötige Tür öffnen. (Ein Reverse Proxy wäre erst für Weg C2 nötig, ein eigenes Git zu Hause, und den empfehlen wir nicht.)

**Reihenfolge:** erst diesen Rechner einrichten (Schritte 1–6, das Skript holt er sich, solange das Repo noch öffentlich ist), dann alte APKs aufräumen, dann privat stellen, und erst dann bekommt der Rechner Aufträge (Schritt 7). Ein eigener Rechner an einem öffentlichen Repo wäre gefährlich: Fremde könnten über einen Pull Request Code darauf ausführen.

---

## Schritt 1: Ubuntu herunterladen (5 Minuten)

1. Markiere diese Adresse und kopiere sie (Strg+C):
   `https://releases.ubuntu.com/24.04/ubuntu-24.04.5-live-server-amd64.iso`
   (Nicht die Seite ubuntu.com/download nehmen: deren grüner Knopf führt zu einer Dankeseite und zu einer neueren Ausgabe.)
2. Wechsle zum Proxmox-Tab.
3. Links in der Baumansicht: Klick auf den Pfeil vor deinem Server-Namen, damit er aufklappt. Darunter stehen Speicher, meist **„local (…)“**. Klick auf **local**.
5. In der Mitte erscheinen Reiter. Klick auf **„ISO Images“**.
6. Oben auf den Knopf **„Download from URL“**.
7. Ins Feld **URL**: mit Strg+V die Adresse einfügen. Dann rechts daneben **„Query URL“** klicken. Der Dateiname füllt sich von selbst.
8. Unten **„Download“** klicken. Ein Fenster zeigt den Fortschritt. Warten, bis dort **„TASK OK“** steht, dann das Fenster schließen.

## Schritt 2: Die VM anlegen (5 Minuten)

1. Oben rechts in Proxmox der blaue Knopf **„Create VM“**.
2. Reiter **General:** bei **Name** eintippen: `bornim-build`. Rest lassen. **Next**.
3. Reiter **OS:** bei **ISO image** das Ubuntu aus Schritt 1 auswählen. **Next**.
4. Reiter **System:** nichts ändern. **Next**.
5. Reiter **Disks:** bei **Disk size (GiB)** `60` eintragen. **Next**.
6. Reiter **CPU:** bei **Cores** `4` eintragen. Bei **Type** `host` auswählen. **Next**.
7. Reiter **Memory:** bei **Memory (MiB)** `8192` eintragen. **Next**.
8. Reiter **Network:** nichts ändern. **Next**.
9. Reiter **Confirm:** unten das Häkchen **„Start after created“** setzen. **Finish**.

Links im Baum erscheint jetzt `bornim-build` (mit einer Nummer davor, z. B. 105).

## Schritt 3: Ubuntu installieren (20 Minuten, meist Warten)

1. Links auf **bornim-build** klicken, in der Mitte **„Console“**. Ein schwarzes Fenster erscheint.
2. Bedient wird nur mit der Tastatur: **Pfeiltasten** zum Wählen, **Enter** zum Bestätigen, **Leertaste** für Häkchen, **Tab** zum nächsten Feld.
3. Die Fragen der Reihe nach:
   - **Sprache:** `English` (ist voreingestellt), Enter. (Englisch macht spätere Fehlermeldungen leichter zu finden.)
   - **Installer update available:** „Continue without updating“, Enter.
   - **Keyboard:** Layout `German`, Variant `German`, dann „Done“, Enter.
   - **Type of installation:** `Ubuntu Server` (voreingestellt), „Done“.
   - **Network:** steht eine Adresse wie `192.168.…` da, einfach „Done“.
   - **Proxy:** leer lassen, „Done“.
   - **Mirror:** warten, bis „This mirror location passed tests“ erscheint, dann „Done“.
   - **Storage:** „Use an entire disk“ (voreingestellt) bleibt. Darunter steht **„[X] Set up this disk as an LVM group“**: mit den Pfeiltasten hingehen und mit der **Leertaste das X entfernen** (sonst nutzt Ubuntu nur die halbe Platte). „Done“; nächste Seite „Done“; dann „Continue“ bei der Warnung.
   - **Profile:** Your name: `Build`. Server name: `bornim-build`. Username: `oma` (oder ein Name deiner Wahl). Password zweimal: **ein Passwort, das du dir aufschreibst**. „Done“.
   - **Ubuntu Pro:** „Skip for now“, „Continue“.
   - **SSH:** nichts ankreuzen, „Done“.
   - **Featured snaps:** nichts ankreuzen, „Done“.
4. Jetzt installiert er. Warten, bis unten **„Reboot Now“** erscheint. Darauf Enter.
5. Kommt „Please remove the installation medium, then press ENTER“: einfach **Enter** drücken.
6. Er startet neu. Am Ende steht `bornim-build login:`. Tippe deinen Username, Enter, dann das Passwort, Enter. (Beim Passwort erscheinen keine Sternchen; das ist normal.)

## Schritt 4: Den Schlüssel bei GitHub holen (3 Minuten)

1. In einem neuen Browser-Tab: **github.com/tramour-cmyk/androidapp_rpg_bornim** öffnen und anmelden.
2. Oben im Repo der Reiter **„Settings“** (Zahnrad).
3. Links im Menü **„Actions“** aufklappen, dann **„Runners“**.
4. Oben rechts der grüne Knopf **„New self-hosted runner“**.
5. Bei **Runner image** `Linux` wählen, bei **Architecture** `x64`.
6. Weiter unten unter **„Configure“** steht eine Zeile, die mit `./config.sh --url …` beginnt. Darin steht hinter **`--token`** ein langer Schlüssel aus Großbuchstaben und Zahlen. **Den brauchst du gleich.** Er gilt 1 Stunde; ist er abgelaufen, diese Seite einfach neu laden.
7. Den Tab offen lassen.

## Schritt 5: Das Einrichtungsskript laufen lassen (20 Minuten, meist Warten)

Zurück im Proxmox-Tab, in der schwarzen Console von `bornim-build`. Tippe genau diese Zeile ab (eine Zeile, ohne Zeilenumbruch), dann Enter:

```
curl -fsSL -o e.sh https://raw.githubusercontent.com/tramour-cmyk/androidapp_rpg_bornim/main/tools/runner/einrichten.sh
```

Dann diese Zeile, Enter:

```
sudo bash e.sh
```

1. Er fragt nach dem Passwort (dein Ubuntu-Passwort aus Schritt 3), Enter.
2. Er fragt nach dem **Schlüssel von GitHub**: aus dem GitHub-Tab abtippen (Groß- und Kleinbuchstaben beachten), Enter.
3. Jetzt arbeitet er allein: Programme, Android-Werkzeuge, Runner, Firewall. Es läuft viel Text durch. Warten.
4. Am Ende steht **„FERTIG.“**

**Wenn eine rote Fehlermeldung kommt und kein „FERTIG.“:** ein Foto vom Bildschirm an Telegram oder in den Chat. Nichts weiter versuchen.

## Schritt 6: Nachsehen, ob es geklappt hat (1 Minute)

1. Im GitHub-Tab die Seite **Settings → Actions → Runners** neu laden.
2. Dort steht jetzt **`proxmox-bornim`** mit einem **grünen Punkt** und „Idle“.
3. Fertig mit deinem Teil. Die VM läuft ab jetzt still mit; nach einem Neustart des Proxmox startet sie und der Runner von selbst (in Proxmox bei der VM unter **Options → „Start at boot“** auf **Yes** stellen: Doppelklick auf die Zeile, Häkchen, OK).

## Schritt 7: Danach, nicht von dir

1. **Team Tom:** räumt die alten APKs bei GitHub auf (heute etwa 6 GB; privat sind nur 500 MB frei, sonst scheitern die Uploads) und setzt in den Bauanleitungen eine kurze Aufbewahrung (`retention-days`).
2. **Du:** Repo privat stellen. GitHub-Tab: **Settings** → ganz unten **„Danger Zone“** → **„Change repository visibility“** → **„Make private“** → bestätigen.
3. **Team Tom:** stellt die Bauanleitungen (`.github/workflows/android.yml`, `vorschau.yml` u. a.) von `runs-on: ubuntu-24.04` auf `runs-on: [self-hosted, bornim]` um (`bornim` ist das Etikett des Rechners). Das ist ein Build mit deinem Test. Zwischen 2 und 3 laufen die Builds noch bei GitHub und kosten Minuten; darum 3 gleich danach.

## Gut zu wissen

- **Sicherheit:** Der Runner läuft als eigener Benutzer ohne Verwaltungsrechte. Die Firewall in der VM lässt nur Internet und die Namensauflösung zu, nichts im Heimnetz (10.x, 172.16–31.x, 192.168.x). Der Signaturschlüssel kommt nur während eines Builds in einen Arbeitsordner, den der Runner nach jedem Auftrag leert.
- **Strom und Platz:** Die VM braucht im Leerlauf kaum Rechenleistung; während eines Builds etwa 5–10 Minuten lang alle 4 Kerne.
- **Updates:** Ubuntu installiert Sicherheitsupdates von selbst. Den Runner hält GitHub selbst aktuell.
- **Wegwerfen:** Wird die VM nicht mehr gebraucht: in Proxmox herunterfahren, dann **More → Remove**; bei GitHub unter Runners `proxmox-bornim` entfernen.
