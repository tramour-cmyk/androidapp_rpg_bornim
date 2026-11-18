#!/usr/bin/env python3
"""1716 (Chef 18.11., 22:29, nach zwei Neustarts von Lauf 575 durch fremde Pushes auf claude/build-300: „wie kann hier einfach
irgendjemand was neu einmischen und dann fängt alles wieder von vorne an? Du bist hier verantwortlich für den Build und nicht
irgendwelche Dödel von der Seite.“): der Buildzweig gehört Spike. PreToolUse-Haken für Bash und die GitHub-Schreibwerkzeuge: ein
Push auf claude/build-<n> aus einer Sitzung, deren erste Nachricht eine andere Rolle nennt, hält an (Exit 2); Nachträge kommen in
den nächsten Build, ein roter Test des Builds geht über Spike (send_message). Unbekannte Rolle (Chef, fremde Sitzung): durchlassen.
Jeder Fehler im Haken lässt durch.
Prüfen von Hand: buildzweig-haken.py --test
"""
import json, os, re, subprocess, sys

ROLLEN = ("Spike", "Tom", "Jerry", "Tuffy", "Ford", "Perikles", "Homer", "Sokrates", "Diogenes")
BUILD = re.compile(r"(?:^|[:/\s])claude/build-\d+(?:$|\s)")
PUSH = re.compile(r"(?:^|[;&|(\n])\s*(?:\w+=\S*\s+)*git\b(?:\s+-C\s+(\S+)|\s+-c\s+\S+)*\s+push\b([^;&|\n]*)")
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
            if re.fullmatch(r"claude/build-\d+", z):
                return z
    return None


def ziel(e):
    name = e.get("tool_name", "")
    t = e.get("tool_input") or {}
    if name == "Bash":
        return ziel_bash(t.get("command", ""), e.get("cwd"))
    if name.startswith("mcp__github__") and name.split("__")[-1] in MCP_SCHREIBEN:
        b = str(t.get("branch", ""))
        return b if re.fullmatch(r"claude/build-\d+", b) else None
    return None


def main():
    try:
        e = json.load(sys.stdin)
        z = ziel(e)
        if not z:
            return 0
        r = rolle(erste_nachricht(e.get("transcript_path", "")))
        if r is None or r == "Spike":
            return 0
        print("1716 (Chef 18.11., 22:29: „Du bist hier verantwortlich für den Build und nicht irgendwelche Dödel von der Seite.“): "
              "%s gehört Spike, %s pusht dort nicht; jeder Push startet den laufenden Bau neu. Nachtrag in den nächsten Build "
              "(Zweig gebaut lassen, Spike mischt ihn); roter Test dieses Builds: send_message an Spike." % (z, r), file=sys.stderr)
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
    print("BUILDZWEIG1716 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
