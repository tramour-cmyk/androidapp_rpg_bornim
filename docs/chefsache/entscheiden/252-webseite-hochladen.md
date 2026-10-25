# 252 · Webseite bornwire.de hochladen: was trägst du wo ein?
Sokrates · 25.10., 12:46 · M Markt · Frist 30.11.
Kurz: Webseite hochladen: Schritte im KAS, sechs Secrets in GitHub, zwei Antworten

**Frage:** Trägst du die Werte unten ein und gibst mir die zwei Antworten aus Schritt 3?

**Votum:** Schritte 1–3 in dieser Reihenfolge, dann „252 ja“. Erst danach lege ich die Action auf `main`; sie baut die Seiten, lädt sie per FTPS hoch, ich prüfe die Seite im Netz und melde. Vorher nicht hochladen: die Datenschutzerklärung nennt den AVV (1f) und braucht die Logfrist (3.1).

**Berührt:** 252, 142 (Datenschutz-Link im Store), 253 (Anschrift).

**Stand 25.10., 12:49 (Chef):** 1a–1e erledigt (Domains auf `/bornwire.de/` bzw. Weiterleitung, SSL aktiv, FTP-Zugang da), 1g eingerichtet, keine W-IdNr./USt-IdNr. (3.2 erledigt). Offen: 1f AVV, Schritt 2, 3.1 Logfrist.

## Schritt 1 · ALL-INKL, Verwaltung (kas.all-inkl.com)

| # | Wo | Was | Wert |
|---|---|---|---|
| 1a | Domains | prüfen, dass bornwire.de, bornwire.com, bornwiretcs.de, bornwiretcs.com bei ALL-INKL liegen oder dorthin zeigen | sonst bestellen, umziehen oder DNS umstellen |
| 1b | Domains | eigenen Ordner für bornwire.de anlegen, **nicht** die Wurzel „/“ (dort liegt mehr, z. B. Nextcloud) | z. B. `/bornwire.de/` |
| 1c | Domains | alle vier Domains **und** ihre www-Varianten auf diesen Ordner legen | Weiterleitung auf bornwire.de macht die Seite selbst |
| 1d | SSL | Let's-Encrypt-Zertifikat für alle acht Namen aus 1c einschalten | sonst warnt der Browser beim Sprung auf https |
| 1e | FTP | neuen FTP-Zugang anlegen, als Verzeichnis **genau den Ordner aus 1b** eintragen | Server, Benutzer, Passwort notieren (Schritt 2) |
| 1f | MembersArea `member.all-inkl.com` (nicht KAS) | Vertrag zur Auftragsverarbeitung (AVV) abschließen; liegt danach dort als PDF; Menüpunkt öffentlich nicht beschrieben, sonst Support fragen | Datenschutz sagt, er bestehe |
| 1g | E-Mail | Postfach oder Weiterleitung `kontakt@bornwire.de` | steht im Impressum |

Die genauen Menünamen im KAS habe ich nicht gesehen; findest du etwas nicht, schreib mir das Stichwort.

## Schritt 2 · GitHub, Secrets

Repo → Settings → Secrets and variables → Actions → **New repository secret**; je Zeile ein Secret, Name genau so.

| Name | Wert (Beispiel) | Pflicht |
|---|---|---|
| `BORNWIRE_INHABER` | `Vorname Nachname` | ja |
| `BORNWIRE_ANSCHRIFT` | `Musterstraße 1\|14469 Potsdam` (Zeilen mit „\|“ trennen) | ja |
| `BORNWIRE_TELEFON` | `+49 331 1234567` | nein, ohne Secret keine Telefonzeile |
| `FTP_SERVER` | `w0123456.kasserver.com` aus 1e; **nicht** bornwire.de oder ftp.bornwire.de, sonst scheitert die Verschlüsselung | ja |
| `FTP_USERNAME` | aus 1e | ja |
| `FTP_PASSWORD` | aus 1e | ja |

Anschrift: Wohnanschrift oder Büroservice entscheidest du (offen seit 20.10.); sie steht öffentlich im Impressum und bei Google Play.

## Schritt 3 · zwei Antworten an mich

1. **Logfrist:** nach wie vielen Tagen löscht oder kürzt ALL-INKL die Zugriffsprotokolle (Einstellung im KAS)? Die Zahl kommt in die Datenschutzerklärung. Die „sieben Tage“ in den Datenschutzinformationen von ALL-INKL gelten nur für deren eigene Seite (Ziffer 14), nicht für Kundenseiten.
2. **Wirtschafts-Identifikationsnummer:** hast du vom Finanzamt eine W-IdNr. (oder USt-IdNr.)? Wenn ja, gehört sie ins Impressum; schreib nur „ja“, ich baue dafür ein siebtes Secret ein.

<details><summary>Sachverhalt</summary>

- Seiten DE/EN, Impressum (§ 5 DDG), Datenschutz für App und Seite: `docs/firma/webseite/`, gebaut von `bauen.py`; Name, Anschrift, Telefon nur aus Secrets, nie in Git.
- Action `.github/workflows/webseite.yml` auf Zweig `claude/sokrates-252-webseite`; läuft auf `main` bei jeder Änderung der Seiten, sofort auch beim Einspielen, darum Secrets vorher; später auch von Hand (Actions → Webseite → Run workflow).
- `.htaccess` leitet alle Domains und http auf `https://bornwire.de` (301).
- Fehlen Inhaber oder Anschrift, bricht der Bau ab; fehlt der FTP-Zugang, scheitert das Hochladen. In beiden Fällen kommt nichts ins Netz.
- Helfer 12:4x: neun Befunde, alle eingearbeitet.

</details>

Antwort:
