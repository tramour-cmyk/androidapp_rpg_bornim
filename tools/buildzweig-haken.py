#!/usr/bin/env python3
"""1716 (Chef 18.11., 22:29, nach zwei Neustarts von Lauf 575 durch fremde Pushes auf claude/build-300: „wie kann hier einfach
irgendjemand was neu einmischen und dann fängt alles wieder von vorne an? Du bist hier verantwortlich für den Build und nicht
irgendwelche Dödel von der Seite.“): der Buildzweig gehört Spike. PreToolUse-Haken für Bash und die GitHub-Schreibwerkzeuge: ein
Push auf claude/build-<n> aus einer Sitzung, deren erste Nachricht eine andere Rolle nennt, hält an (Exit 2); Nachträge kommen in
den nächsten Build, ein roter Test des Builds geht über Spike (send_message). 1765 (Build-Kette 2, Chef 19.11., 22:05): Muster
claude/build-<Name> (auch build-496a), unbekannte Rolle hält an; pushen darf Spike, nach der Umstellung der Build-Macher (beide
gelten bis dahin, 1727 rückwärtsverträglich). Nur gegen Versehen: die Sicherung ist der Vergleich im Build-Werkzeug
(buildwerkzeug.py spitze). Jeder Fehler im Haken lässt durch.
Prüfen von Hand: buildzweig-haken.py --test
"""
import json, os, re, subprocess, sys

ROLLEN = ("Build-Macher", "Spike", "Tom", "Jerry", "Tuffy", "Ford", "Perikles", "Homer", "Sokrates", "Diogenes")
BUILD_NAME = r"claude/build-[^\s:;&|]+"
ERLAUBT = ("Spike", "Build-Macher")
# 1768 (D328.1): vor git dürfen Shell-Schlüsselwörter und Vorsätze stehen (do, then, else, if, while, until, !, {, time, nohup,
# exec, command, env, timeout [-k N] DAUER, VAR=wert), etwa „for i in 1 2; do git push …“ oder „timeout 60 git push …“
VORSATZ = (r"(?:(?:do|then|else|elif|if|while|until|!|\{|time(?:\s+-p)?|nohup|exec|command|builtin|env(?:\s+-\S+)*"
           r"|timeout(?:\s+--?[\w-]+(?:=\S+)?|\s+-[ks]\s+\S+)*\s+\d[\w.]*|\w+=\S*)\s+)*")
PUSH = re.compile(r"(?:^|[;&|(`\n])\s*" + VORSATZ + r"git\b(?:\s+-C\s+(\S+)|\s+-c\s+\S+)*\s+push\b([^;&|`)\n]*)")
MCP_SCHREIBEN = ("push_files", "create_or_update_file", "delete_file")


def erste_nachricht(pfad):
    try:
        with open(pfad, encoding="utf-8", errors="replace") as f:
            for zeile in f:
                if '"user"' not in zeile:
                    continue
                try:
                    d = json.loads(zeile)
                except ValueError:
                    continue
                if d.get("type") != "user" or d.get("isSidechain") or d.get("isMeta"):
                    continue
                c = (d.get("message") or {}).get("content")
                if isinstance(c, list):
                    c = "\n".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
                if isinstance(c, str) and c.strip():
                    return c
    except OSError:
        pass
    return ""


def rolle(text):
    """Erste Rolle in der ersten Nachricht („Du bist **Spike**“, „Tom“, Startzeile von Ford); None, wenn keine."""
    m = re.search(r"Du bist \**(%s)\b" % "|".join(ROLLEN), text) or re.search(r"\b(%s)\b" % "|".join(ROLLEN), text[:600])
    return m.group(1) if m else None


def ohne_text(befehl):
    """1718 (D327.1): Heredoc-Körper und Zeichenketten ('…', "…") entfernen; ein „git push“ darin ist kein Push."""
    befehl = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?\n\s*\1\b", " ", befehl, flags=re.S)
    return re.sub(r"'[^']*'|\"(?:[^\"\\]|\\.)*\"", " ", befehl)


def _zweig(wo):
    try:
        return subprocess.run(["git", "-C", wo, "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True, timeout=5).stdout.strip()
    except Exception:
        return ""


def ziel_bash(befehl, cwd):
    """claude/build-<n>, wenn der Befehl dorthin pusht (Refspec, HEAD/@ als Refspec oder aktueller Zweig ohne Refspec), sonst None.
    1718 (D327.1): HEAD und @ werden aufgelöst; nur ein git-Befehl am Anfang eines Befehlsteils zählt, nicht Text in echo, -m, Python."""
    roh = ohne_text(befehl)
    for m in PUSH.finditer(roh):
        vorn = roh[:m.start()]
        cds = re.findall(r"(?:^|[;&|(\n])\s*cd\s+([^\s;&|]+)", vorn)
        wo = m.group(1) or (os.path.join(cwd or ".", os.path.expanduser(cds[-1])) if cds else (cwd or "."))
        teile = [t for t in m.group(2).split() if not t.startswith("-")]
        ziele = [t.lstrip("+").split(":")[-1] for t in teile[1:]] if len(teile) >= 2 else ["HEAD"]
        for z in ziele:
            if z in ("HEAD", "@"):
                z = _zweig(wo)
            z = z.replace("refs/heads/", "")
            if re.fullmatch(BUILD_NAME, z):
                return z
    return None


def ziel(e):
    name = e.get("tool_name", "")
    t = e.get("tool_input") or {}
    if name == "Bash":
        return ziel_bash(t.get("command", ""), e.get("cwd"))
    if name.startswith("mcp__github__") and name.split("__")[-1] in MCP_SCHREIBEN:
        b = str(t.get("branch", ""))
        return b if re.fullmatch(BUILD_NAME, b) else None
    return None


def main():
    try:
        e = json.load(sys.stdin)
        z = ziel(e)
        if not z:
            return 0
        r = rolle(erste_nachricht(e.get("transcript_path", "")))
        if r in ERLAUBT:
            return 0
        print("1716 (Chef 18.11., 22:29: „Du bist hier verantwortlich für den Build und nicht irgendwelche Dödel von der Seite.“): "
              "%s gehört Spike (nach der Umstellung dem Build-Macher), %s pusht dort nicht; jeder Push startet den laufenden Bau neu. Nachtrag in den nächsten Build "
              "(Zweig gebaut lassen, Spike mischt ihn); roter Test dieses Builds: send_message an Spike." % (z, r or "eine Sitzung ohne Rolle"), file=sys.stderr)
        return 2
    except Exception:
        return 0


def test():
    f = 0
    def ok(b, was):
        nonlocal f
        if not b:
            f += 1; print("FEHLER", was)
    ok(ziel_bash("git push -q origin claude/build-300", ".") == "claude/build-300", "Refspec")
    ok(ziel_bash("cd x && git push origin HEAD:claude/build-301 2>&1", ".") == "claude/build-301", "HEAD:Refspec")
    ok(ziel_bash("git -C /tmp push -u origin claude/jerry-760-biss", ".") is None, "Teamzweig")
    ok(ziel_bash("git status && echo push", ".") is None, "kein Push")
    w = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True).stdout.strip()
    ok(ziel_bash("echo 'git push origin claude/build-300'", ".") is None, "Text in echo (1718)")
    ok(ziel_bash('git commit -q -m "git push origin claude/build-300" && git push origin claude/jerry-x', ".") is None, "Text in -m (1718)")
    ok(ziel_bash("python3 - <<'EOF'\nprint('git push origin claude/build-300')\nEOF", ".") is None, "Heredoc (1718)")
    ok(ziel_bash("git push -u origin HEAD", ".") == (w if re.fullmatch(r"claude/build-\d+", w) else None), "HEAD aufgelöst (1718)")
    ok(ziel_bash("git push origin HEAD:refs/heads/claude/build-302", ".") == "claude/build-302", "refs/heads (1718)")
    ok(rolle("## Kern\n\nDu bist **Spike**, Technik bei BornWire") == "Spike", "Rolle Spike")
    ok(rolle("Jerry – 1697: Rechtecke … Start") == "Jerry", "Rolle Jerry")
    ok(rolle("Bitte mach das") is None, "Chef ohne Rolle")
    ok(ziel_bash("git push origin claude/build-496a", ".") == "claude/build-496a", "Buchstabe im Namen (1765)")
    ok(ziel_bash("git push origin HEAD:claude/build-497 && echo x", ".") == "claude/build-497", "Name ohne Anhang (1765)")
    ok(rolle("Du bist **Build-Macher**") == "Build-Macher", "Rolle Build-Macher (1765)")
    for b in ("for i in 1 2 3 4; do git push -u origin claude/build-399 && break; sleep 2; done",
              "if true; then git push origin claude/build-399; fi", "if ok; then :; else git push origin claude/build-399; fi",
              "until git push origin claude/build-399; do sleep 1; done", "while ! git push origin claude/build-399; do sleep 1; done",
              "! git push origin claude/build-399", "{ git push origin claude/build-399; }", "timeout 60 git push origin claude/build-399",
              "timeout -k 5 60s git push origin claude/build-399", "time git push origin claude/build-399",
              "nohup git push origin claude/build-399 &", "env GIT_TRACE=1 git push origin claude/build-399",
              "x=$(git push origin claude/build-399)", "x=`git push origin claude/build-399`",
              "if git push origin claude/build-399; then echo ok; fi"):
        ok(ziel_bash(b, ".") == "claude/build-399", "Schlüsselwort (1768): " + b)
    for b in ("echo do git push origin claude/build-399", "echo then git push origin claude/build-399",
              "grep -n 'timeout 60 git push origin claude/build-399' x", "echo '! git push origin claude/build-399'",
              "printf '%s\\n' \"do git push origin claude/build-399\"", "git log --grep=push claude/build-399",
              "for i in 1 2; do git push -u origin claude/jerry-1768; done", "timeout 60 git push origin HEAD:claude/tom-1"):
        ok(ziel_bash(b, ".") is None, "Text ohne Fehlalarm (1768): " + b)
    print("BUILDZWEIG1716 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
