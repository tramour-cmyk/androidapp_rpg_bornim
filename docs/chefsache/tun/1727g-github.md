# 1727g · Bitte auf GitHub eine Regel gegen Force-Push auf Buildzweige anlegen

Sokrates · 21.11., 21:19 · 7 Firma · aus 1727, Werkzeugübersicht (`werkzeuge.md` B, G:923 „GitHub-Regel gegen Force-Push stellt der Chef ein“)

Kurz: Nur du hast die Rechte. Regel (Branch protection / Ruleset) auf `claude/build-*`: Force-Push und Löschen verbieten.

Selbst erledigen kann ich es nicht: Unsere GitHub-Werkzeuge können keine Regeln anlegen, und dafür braucht es Admin-Rechte am Repo.

Weg (im Browser, am besten am Rechner; am Handy die Desktop-Ansicht):
1. `https://github.com/tramour-cmyk/androidapp_rpg_bornim/settings/rules` öffnen (oder: Repo → oben „Settings“ → links unter „Code, planning, and automation“ → „Rules“ → „Rulesets“; Beschriftung kann leicht abweichen).
2. Knopf „New ruleset“ → „New branch ruleset“.
3. „Ruleset name“: `Buildzweige`.
4. „Enforcement status“: **Active** wählen (steht sonst auf „Disabled“, dann wirkt nichts).
5. „Bypass list“: leer lassen (dann kannst auch du dort nicht force-pushen oder löschen; gewollt).
6. „Target branches“ → „Add a target“ → „Include by pattern“ → `claude/build-*` eintippen → bestätigen.
7. Unter „Branch protections“ nur diese zwei angehakt lassen: „Restrict deletions“ und „Block force pushes“ (sind schon vorgewählt). **Nicht** anhaken: „Restrict creations“, „Restrict updates“, „Require a pull request before merging“ und alle anderen; sonst kann Spike keine Buildzweige mehr anlegen oder pushen.
8. Ganz unten „Create“.
9. Mir sagen: „1727g erledigt“.

Prüfen danach: in der Liste „Rulesets“ steht „Buildzweige“ mit „Active“ und „1 target“.

**Noch nicht:** das Secret `TELEGRAM_BOT_TOKEN` für den Herzschlag (Spike, Zu 1764). `herzschlag.yml`:64 meldet immer laut, an `meldung.sh` vorbei, auch nachts; erst muss Spike das beheben, dann bitte ich dich darum.
