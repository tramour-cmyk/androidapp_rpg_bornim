# 1727g · Bitte auf GitHub eine Regel gegen Force-Push auf Buildzweige anlegen

Sokrates · 21.11., 21:19 · 7 Firma · aus 1727, Werkzeugübersicht (`werkzeuge.md` B, G:923 „GitHub-Regel gegen Force-Push stellt der Chef ein“)

Kurz: Nur du hast die Rechte. Regel (Branch protection / Ruleset) auf `claude/build-*`: Force-Push und Löschen verbieten.

Weg: GitHub → `tramour-cmyk/androidapp_rpg_bornim` → Settings → Rules → Rulesets → New ruleset → New branch ruleset; Name „Buildzweige“; Enforcement status **Active** (sonst wirkt die Regel nicht); Target branches → Add target → Include by pattern `claude/build-*`; „Restrict deletions“ und „Block force pushes“ an; Create. Sag „1727g erledigt“.

**Noch nicht:** das Secret `TELEGRAM_BOT_TOKEN` für den Herzschlag (Spike, Zu 1764). `herzschlag.yml`:64 meldet immer laut, an `meldung.sh` vorbei, auch nachts; erst muss Spike das beheben, dann bitte ich dich darum.
