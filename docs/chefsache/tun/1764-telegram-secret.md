# 1764 · Bitte auf GitHub das Secret TELEGRAM_BOT_TOKEN für den Herzschlag anlegen

Sokrates · 21.11., 22:41 · 7 Firma · aus 1727, Werkzeuge (Herzschlag 1764, Spike; Vorbedingung „nachts nie laut“ gebaut, `herzschlag.yml`:63, 1780)

Kurz: Nur du hast die Rechte. Ohne das Secret meldet der Herzschlag einen Ausfall von Ford bzw. Disponent nur als roten Lauf auf GitHub, nicht auf Telegram.

Weg: GitHub → `tramour-cmyk/androidapp_rpg_bornim` → Settings → Secrets and variables → Actions → New repository secret; Name `TELEGRAM_BOT_TOKEN`; Wert: derselbe Bot-Schlüssel, den `meldung.sh` in unseren Sitzungen als `TELEGRAM_BOT_TOKEN` liest (Einstellung der Umgebung „WireStorm“); Add secret. Sag „1764 Secret erledigt“.

Geprüft an: `.github/workflows/herzschlag.yml`:59–69 (liest `secrets.TELEGRAM_BOT_TOKEN`, sonst Warnung; nachts 22–06 lautlos), kein anderer Workflow nutzt das Secret.
