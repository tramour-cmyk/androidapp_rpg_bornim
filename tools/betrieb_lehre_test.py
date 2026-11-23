#!/usr/bin/env python3
# 1999 Lehrenbuch für Betrieb und Leitung: (a) Herzschlag WECKEN/NEUSTART, (b) abgelehntes create_trigger, (c) create_session,
# (d) gescheiterter Start/Neustart (lauf.py), (e) meldung.sh --laut der Wache → je eine rohe Zeile (Fall Betrieb, B Steuerung,
# dieselbe Ursache je Tag einmal); (f) neue Vorlage in chefsache/entscheiden|billigen ohne „Abgleich“ und (g) neuer Archiveintrag,
# der einen älteren ohne „ersetzt durch“ trifft: Commit-Prüfung hält an. Echtes Git mit nacktem origin, ohne Netz.
# Aufruf: python3 tools/betrieb_lehre_test.py
import json, os, subprocess, sys, tempfile, time
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=A, check=True): return subprocess.run(["git"] + list(a), cwd=cwd, check=check, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o, cwd=d)
g("clone", "-q", o, A, cwd=d); g("config", "user.email", "t@t"); g("config", "user.name", "t"); g("checkout", "-q", "-b", "main")
os.makedirs(os.path.join(A, "docs", "chefsache")); os.makedirs(os.path.join(A, "tools"))
for f in os.listdir(HIER):
    if f.endswith((".py", ".sh", ".txt")): os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
def schreibe(p, t):
    os.makedirs(os.path.dirname(os.path.join(A, p)), exist_ok=True); open(os.path.join(A, p), "w").write(t)
schreibe("docs/LISTE-VORGAENGE.md", "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
         "| 9001 | Probe | Tom | M | startbar | – | – | – | E Figuren | – |\n")
schreibe("docs/ARBEIT-BETRIEB.md", "**Nächste freie Vorgangsnummer: 9100**\n\n- **Wache (aktuell)** `session_WACHE1` „Wache“\n")
schreibe("docs/ARBEIT-BESETZUNG.md", "# Besetzung\n\n**Stand:** 23.11., 10:12 (lauf.py)\n")
ALT_1098 = ("- **1098 A, vorher D prüfen** (13.11., 09:18, Chef an Sokrates: „1098 A, vorher D prüfen“): Ford probiert beim nächsten Selbstneustart "
            "einmal D; sonst A (Ford-Starter). → **Empfehlung Sokrates**")
schreibe("docs/VORGANGSARCHIV.md", "# Vorgangsarchiv\n\n" + ALT_1098 + "\n")
g("add", "-A"); g("commit", "-q", "-m", "start"); g("push", "-q", "origin", "main")
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="23.11., 14:00", BORNIM_SITZUNG="session_T1", MELDUNG_WEITER="1",
           GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
for k in ("BORNIM_OHNE_PUSH", "TELEGRAM_BOT_TOKEN", "CLAUDE_CODE_REMOTE_SESSION_ID"): ENV.pop(k, None)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige[-600:]))
def buch():
    g("fetch", "-q", "origin")
    return g("show", "origin/main:docs/LISTE-LEHREN.md", check=False)
def betrieb(wort):
    return [z for z in buch().splitlines() if z.startswith("| R") and "| Betrieb |" in z and "| B Steuerung |" in z and wort in z]
def lauf(*a, env=None, eingabe=None):
    p = subprocess.run(list(a), env=env or ENV, capture_output=True, text=True, cwd=A, input=eingabe)
    return p.returncode, p.stdout + p.stderr
def warte(wort, n=1, frist=40):
    for _ in range(frist * 2):
        if len(betrieb(wort)) >= n: break
        time.sleep(0.5)
    return betrieb(wort)

# (a) alte Marke → herzschlag.py --wache → eine Zeile; zweiter Lauf keine; NEUSTART eigene Ursache; ok schreibt nichts
HS = os.path.join(A, "tools", "herzschlag.py")
rc, out = lauf(sys.executable, HS, "--wache", "--jetzt", "23.11.2026 14:00")
z = betrieb("Herzschlag-ALARM")
soll("(a) WECKEN → eine rohe Zeile", rc == 2 and "WACHE WECKEN" in out and len(z) == 1, out + buch())
print("     ", z[0][:160] if z else "-")
rc, out = lauf(sys.executable, HS, "--wache", "--jetzt", "23.11.2026 14:33")
soll("(a) zweiter Lauf: keine weitere Zeile", len(betrieb("Herzschlag-ALARM")) == 1, out + buch())
rc, out = lauf(sys.executable, HS, "--wache", "--jetzt", "23.11.2026 15:10", "--geweckt", "23.11.2026 14:00")
soll("(a) NEUSTART → eigene Zeile", rc == 3 and len(betrieb("Herzschlag-NEUSTART")) == 1, out + buch())
schreibe("docs/ARBEIT-BESETZUNG.md", "**Stand:** 23.11., 13:59 (lauf.py)\n")
vorher = buch()
rc, out = lauf(sys.executable, HS, "--wache", "--jetzt", "23.11.2026 14:10")
soll("(a) WACHE ok schreibt nichts", rc == 0 and buch() == vorher, out)

# (b, c) abgelehntes create_trigger / create_session über neustart-haken.py (PermissionDenied, PostToolUseFailure, PostToolUse)
NH = os.path.join(A, "tools", "neustart-haken.py")
def haken(art, e): return lauf(sys.executable, NH, art, eingabe=json.dumps(e))
haken("abgelehnt", {"hook_event_name": "PermissionDenied", "tool_name": "mcp__claude-code-remote__create_trigger",
                    "tool_input": {"name": "Disponent"}, "reason": "[Create Unsafe Agents] depth 2", "session_id": "s1"})
z = warte("create_trigger abgelehnt (PermissionDenied)")
soll("(b) create_trigger abgelehnt (PermissionDenied) → eine Zeile", len(z) == 1, buch())
print("     ", z[0][:160] if z else "-")
haken("nach", {"hook_event_name": "PostToolUse", "tool_name": "mcp__claude-code-remote__create_trigger", "tool_response": "Error: request refused by policy"})
z = warte("create_trigger abgelehnt (PostToolUse)")
soll("(b) create_trigger mit Fehlertext in PostToolUse → eine Zeile", len(z) == 1, buch())
haken("nach", {"hook_event_name": "PostToolUse", "tool_name": "mcp__claude-code-remote__create_trigger", "tool_response": {"trigger": {"id": "trig_1"}}})
haken("abgelehnt", {"hook_event_name": "PermissionDenied", "tool_name": "mcp__claude-code-remote__create_trigger", "reason": "zweites Mal"})
time.sleep(4)
soll("(b) Erfolg schreibt nichts, gleiche Ursache am Tag nur einmal", len(betrieb("create_trigger abgelehnt")) == 2, buch())
haken("abgelehnt", {"hook_event_name": "PostToolUseFailure", "tool_name": "mcp__claude-code-remote__create_session",
                    "error": "create_session refused: session depth limit", "is_interrupt": False})
z = warte("create_session abgelehnt (PostToolUseFailure)")
soll("(c) create_session abgelehnt (PostToolUseFailure) → eine Zeile", len(z) == 1, buch())
print("     ", z[0][:160] if z else "-")
haken("abgelehnt", {"hook_event_name": "PermissionDenied", "tool_name": "Bash", "reason": "x"})
time.sleep(3)
soll("(c) anderes Werkzeug schreibt nichts", "| Bash" not in buch() and "Bash abgelehnt" not in buch(), buch())

# (d) gescheiterter Start/Neustart: lauf.py --sperre gibt „Start <Rolle> nicht angekommen“ an lehren.aus_lauf
zeile = "WARNUNG-LAUT Start Disponent nicht angekommen: Startsperre 23.11., 13:40, keine Sitzung Disponent seither; Disponent: START ausführen oder mit --ohne NR:Grund ausschließen (837)"
code = "import sys; sys.path.insert(0, %r); import lehren; lehren.aus_lauf([%r, 'NICHTS: x']); lehren.aus_lauf([%r])" % (os.path.join(A, "tools"), zeile, zeile)
rc, out = lauf(sys.executable, "-c", code)
soll("(d) Start nicht angekommen → eine Zeile, zweimal gleich nur einmal", len(betrieb("Start Disponent nicht angekommen")) == 1, out + buch())
quelle = open(os.path.join(HIER, "lauf.py"), encoding="utf-8").read()
soll("(d) lauf.py ruft lehren.aus_lauf bei --sperre", "if sperre:  # 1999 (d)" in quelle and "lehren.aus_lauf(ausgabe)" in quelle)

# (e) meldung.sh --laut: nur die Wache schreibt; Uhrzeit ändert die Ursache nicht
MS = os.path.join(A, "tools", "meldung.sh")
rc, out = lauf("bash", MS, "--laut", "Clara", "1997 Herzschlag-Alarm 14:05: Disponent hängt", env=dict(ENV, CLAUDE_CODE_REMOTE_SESSION_ID="session_ANDERE"))
soll("(e) laut, nicht die Wache: nichts", not betrieb("Wache meldet laut"), out + buch())
rc, out = lauf("bash", MS, "--laut", "Clara", "1997 Herzschlag-Alarm 14:05: Disponent hängt", env=dict(ENV, CLAUDE_CODE_REMOTE_SESSION_ID="session_WACHE1"))
z = betrieb("Wache meldet laut")
soll("(e) laut von der Wache → eine Zeile", len(z) == 1, out + buch())
print("     ", z[0][:160] if z else "-")
lauf("bash", MS, "--laut", "Clara", "1997 Herzschlag-Alarm 14:35: Disponent hängt", env=dict(ENV, CLAUDE_CODE_REMOTE_SESSION_ID="session_WACHE1"))
lauf("bash", MS, "Clara", "1997 lautlos", env=dict(ENV, CLAUDE_CODE_REMOTE_SESSION_ID="session_WACHE1"))
soll("(e) andere Uhrzeit gleiche Ursache, lautlos: keine weitere", len(betrieb("Wache meldet laut")) == 1, buch())

# (f), (g): Commit-Prüfung
g("pull", "-q", "origin", "main")
CP = os.path.join(A, "tools", "commit-pruefung.py")
def pruefen(): return lauf(sys.executable, CP)
def zurueck():
    g("reset", "-q", "--hard", "HEAD"); g("clean", "-qfd", "docs")
VOTUM = ("# 9001 · Disponent-Starter auf Ebene 1?\n\n**Frage:** Starter für den Disponenten?\n\n**Votum:** (Votum Sokrates 23.11., 10:07) Chef startet einmal "
         "einen Disponenten auf Ebene 0; der legt einen Starter auf Ebene 1 an (wie Ford-Starter 1098 A), alle späteren Disponenten-Neustarts nur über ihn.\n\n"
         "**Beim Chef, weil:** Rollen und Accounts\n\n**Berührt:** Betrieb\n\n**Begründung:** Ebene 8\n\n**Sachverhalt:** Neustart\n\n"
         "**Auswertung:** Gegenargument: Tiefe\n\n**Folgerungen:** Starter\n\nGeprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74e9d42f0\n\n**Antwort:** \n")
p = "docs/chefsache/entscheiden/9001-disponent-starter.md"
schreibe(p, VOTUM); g("add", p)
rc, out = pruefen()
soll("(f) Vorlage 10:07 nachgestellt ohne Abgleich: abgelehnt", rc == 1 and "Abgleich“ fehlt" in out, out)
print("     ", next((l for l in out.splitlines() if "Abgleich" in l), "-")[:200])
buchtext = open(os.path.join(A, "docs", "LISTE-LEHREN.md")).read() if os.path.exists(os.path.join(A, "docs", "LISTE-LEHREN.md")) else ""
schreibe("docs/LISTE-LEHREN.md", buchtext.rstrip("\n") + "\n| R99 | B Werkzeuge | 1574 | Leitung 10:07 | Starter 1098 A ersetzt durch 1574 | 23.11., 14:20 | offen |\n"); g("add", "docs/LISTE-LEHREN.md")
schreibe(p, VOTUM.replace("**Antwort:**", "## Abgleich\n\n`vorgang.py lehre suche starter`\n\n- keine\n\nArchiv starter: keine\n\n**Antwort:**")); g("add", p)
rc, out = pruefen()
soll("(f) Abgleich verschweigt Treffer R im Lehrenbuch und Archivkopf: abgelehnt", rc == 1 and "nennt Treffer im Lehrenbuch nicht" in out, out)
schreibe(p, VOTUM.replace("**Antwort:**", "## Abgleich\n\n`vorgang.py lehre suche starter`\n\n- R2 (Herzschlag-NEUSTART, Starter), R99 [B Werkzeuge] roh, Fall 1574\n\nArchiv starter: keine\n\n**Antwort:**")); g("add", p)
rc, out = pruefen()
soll("(f) Archivtreffer fehlt: abgelehnt", rc == 1 and "nennt Archivtreffer nicht" in out, out)
schreibe(p, VOTUM.replace("**Antwort:**", "## Abgleich\n\n`vorgang.py lehre suche starter`\n\n- R2 (Herzschlag-NEUSTART, Starter), R99 [B Werkzeuge] roh, Fall 1574\n\nArchiv starter: 1098 A, vorher D prüfen (13.11.)\n\n**Antwort:**")); g("add", p)
rc, out = pruefen()
soll("(f) mit vollständigem Abgleich: geht durch", rc == 0, out)
zurueck()

NEU_1007 = ("- **Disponent-Starter** (23.11., 10:09, Chef an Sokrates auf Votum 10:07: „Ja, schick mir die Startnachricht.“) → **Chef startet einmal "
            "einen Disponenten auf Ebene 0; der legt einen Starter auf Ebene 1 an (wie Ford-Starter 1098 A), alle späteren Disponenten-Neustarts nur über ihn (Nutzer; Votum Sokrates)**")
schreibe("docs/VORGANGSARCHIV.md", "# Vorgangsarchiv\n\n" + NEU_1007 + "\n" + ALT_1098 + "\n"); g("add", "docs/VORGANGSARCHIV.md")
rc, out = pruefen()
soll("(g) Archiveintrag 10:09 zu 1098 A ohne „ersetzt durch“ dort: abgelehnt", rc == 1 and "ohne „ersetzt durch“" in out, out)
print("     ", next((l for l in out.splitlines() if "ersetzt durch" in l), "-")[:200])
schreibe("docs/VORGANGSARCHIV.md", "# Vorgangsarchiv\n\n" + NEU_1007 + "\n" + ALT_1098 + " → ersetzt durch Disponent-Starter, 23.11.\n"); g("add", "docs/VORGANGSARCHIV.md")
rc, out = pruefen()
soll("(g) mit „ersetzt durch“ am alten Eintrag: geht durch", rc == 0, out)
schreibe("docs/VORGANGSARCHIV.md", "# Vorgangsarchiv\n\n" + NEU_1007.replace("(Nutzer;", "(ersetzt nichts; Nutzer;") + "\n" + ALT_1098 + "\n"); g("add", "docs/VORGANGSARCHIV.md")
rc, out = pruefen()
soll("(g) mit „ersetzt nichts“ im neuen: geht durch", rc == 0, out)
schreibe("docs/VORGANGSARCHIV.md", "# Vorgangsarchiv\n\n- **9050 Faust** (23.11., 12:00, Chef: „ja“) → **Faust zu (Nutzer)**\n" + ALT_1098 + "\n"); g("add", "docs/VORGANGSARCHIV.md")
rc, out = pruefen()
soll("(g) Eintrag ohne gemeinsame Nummer: geht durch", rc == 0, out)
zurueck()

print("betrieb_lehre_test: " + ("grün" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
