#!/usr/bin/env python3
"""Listen je Bereich mit Auslöser an Handlungen (822, 745 A2, Chef 09.11., 17:46).

Je Bereich eine vorhandene Liste (keine neue daneben) und ein Abschnitt daraus. Berührt eine Sitzung den Bereich
(Pfade in `git commit`/`git push` oder im Push über den GitHub-Server, oder ein Befehl), gibt `probelauf.py` den
Abschnitt einmal je Sitzung und Bereich als Zusatztext mit. Was prüfbar ist, wird Sperre in den Haken, nicht Text hier.
Fehlt der Abschnitt in der Liste, steht im Zusatztext nur der Verweis (Besitzer füllt ihn, Vorgang in der Liste).

Von Hand: `python3 tools/bereichslisten.py` zeigt alle Bereiche mit Länge des Abschnitts.
"""
import os
import re
import subprocess

DOCS = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs")
MAX = 6000  # Zeichen je Bereich im Zusatztext (Build und Test ganz)

# Bereich: (Liste, Abschnitt oder None = alle nummerierten Punkte, Pfade, Befehle)
BEREICHE = {
    "Build und Test": ("LISTE-CHECK-BUILD-TEST.md", None,
                       r"^docs/chefsache/ansehen/t\d+-", r"\bclaude/build-\d+|vorgang\.py\s+build\b"),
    "Vorlage an den Chef": ("chefsache/MUSTER.md", "Checkliste Vorlage an den Chef",  # 903 B (2): zweite Liste als Probe, 905 zählt
                            r"^docs/chefsache/((entscheiden|billigen|tun)/|ansehen/(?!t\d+-))", None),
    "Aussehen und Modelle": ("DESIGN-STIL.md", "Signatur (302)",
                             r"^godot/(shader|bilder|tiere)/|\.(glb|gdshader)$|^tools/blender", r"\bblender\b"),
    "Kampf": ("LISTE-MARS.md", "Checkliste",
              r"^godot/(kampf|regeln)/", None),
    "Spieltexte": ("STORY-REGELN.md", "Regeln",
                   r"^docs/STORY-|^godot/regeln/mars_texte\.gd$|^godot/skripte/(geschichte|chronik|hauptmenue|auftraege)\.gd$", None),
    "Kauf und Lizenz": ("LISTE-QUELLEN.md", "Prüfschema (für jede Quelle, jedes Paket)",
                        r"^docs/LISTE-(BESTAND|QUELLEN)\.md$", r"bornim-kaufmodelle|kauf_laden"),
}


def abschnitt(liste, titel):
    """Text des Abschnitts `## <titel>` oder alle nummerierten Punkte (titel None); None, wenn er fehlt."""
    try:
        text = open(os.path.join(DOCS, liste), encoding="utf-8").read()
    except OSError:
        return None
    if titel is None:
        z = [re.sub(r"\*\*", "", l) for l in text.splitlines() if re.match(r"(## |\d+\. )", l)]
        return "\n".join(l[3:] if l.startswith("## ") else "  " + l for l in z) or None
    m = re.search(r"^## " + re.escape(titel) + r"[ \t]*\n(.*?)(?=^## |\Z)", text, flags=re.S | re.M)
    return re.sub(r"\*\*", "", m.group(1)).strip() if m else None


def treffer(pfade=(), befehl=""):
    """Bereiche, die diese Pfade oder dieser Befehl berühren."""
    return [name for name, (_, _, pm, bm) in BEREICHE.items()
            if any(re.search(pm, p) for p in pfade) or (bm and re.search(bm, befehl or ""))]


def zusatz(pfade=(), befehl="", sitzung="x"):
    """Zusatztext für die in dieser Sitzung noch nicht gezeigten Bereiche; merkt sie sich in /tmp."""
    sitzung = re.sub(r"[^\w-]", "", sitzung)[:40] or "x"
    teile = []
    for name in treffer(pfade, befehl):
        marke = "/tmp/bornim-bereich-%s-%s" % (sitzung, re.sub(r"\W", "", name))
        if os.path.exists(marke):
            continue
        open(marke, "w").close()
        liste, titel = BEREICHE[name][:2]
        inhalt = abschnitt(liste, titel)
        kopf = "Liste %s (822, einmal je Sitzung): `docs/%s`%s" % (name, liste, " „%s“" % titel if titel else "")
        if not inhalt:
            teile.append(kopf + "; Abschnitt fehlt noch, Regeln in der Datei nachlesen.")
            continue
        if len(inhalt) > MAX:
            inhalt = inhalt[:MAX].rsplit("\n", 1)[0] + "\n  … (weiter in der Datei)"
        teile.append(kopf + ":\n" + inhalt)
    return "\n\n".join(teile)


def pfade_git(befehl, wo):
    """Pfade, die `git commit` (bereitgestellt) oder `git push` (noch nicht auf origin) mitnimmt."""
    def g(*a):
        r = subprocess.run(["git", "-C", wo] + list(a), capture_output=True, text=True, timeout=8)
        return r.stdout.split() if r.returncode == 0 else []
    if re.search(r"\bgit\s+(-C\s+\S+\s+)?commit\b", befehl):
        return g("diff", "--cached", "--name-only") + (g("diff", "--name-only") if re.search(r"\s-a\b|\s-\w*a\w*m\b", befehl) else [])
    if re.search(r"\bgit\s+(-C\s+\S+\s+)?push\b", befehl):
        return g("diff", "--name-only", "@{u}..HEAD") or g("diff", "--name-only", "origin/main...HEAD")
    return []


if __name__ == "__main__":
    for name, (liste, titel, _, _) in BEREICHE.items():
        a = abschnitt(liste, titel)
        print("%-22s %-28s %s" % (name, liste, "%d Zeichen" % len(a) if a else "Abschnitt fehlt"))
