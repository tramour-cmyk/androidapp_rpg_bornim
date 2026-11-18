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
PUSH = re.compile(r"\bgit\b(?:\s+-C\s+(\S+)|\s+-c\s+\S+)*\s+push\b([^;&|]*)")
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


def ziel_bash(befehl, cwd):
    """claude/build-<n>, wenn der Befehl dorthin pusht (Refspec oder aktueller Zweig ohne Refspec), sonst None."""
    for m in PUSH.finditer(befehl):
        args = m.group(2)
        b = re.search(r"claude/build-\d+", args)
        if b:
            return b.group(0)
        teile = [t for t in args.split() if not t.startswith("-")]
        if len(teile) <= 1:   # git push [remote]: der aktuelle Zweig
            try:
                z = subprocess.run(["git", "-C", m.group(1) or cwd or ".", "rev-parse", "--abbrev-ref", "HEAD"],
                                   capture_output=True, text=True, timeout=5).stdout.strip()
            except Exception:
                z = ""
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
    ok(rolle("## Kern\n\nDu bist **Spike**, Technik bei BornWire") == "Spike", "Rolle Spike")
    ok(rolle("Jerry – 1697: Rechtecke … Start") == "Jerry", "Rolle Jerry")
    ok(rolle("Bitte mach das") is None, "Chef ohne Rolle")
    print("BUILDZWEIG1716 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
