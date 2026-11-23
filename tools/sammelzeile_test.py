#!/usr/bin/env python3
"""1971 (Chef 22.11., 18:27/18:28; Eilt 23.11., 09:11): stündliche lautlose Telegram-Sammelzeile, nur Vorgänge, die im Fenster in
docs/LISTE-VORGAENGE.md auf „erledigt“ gingen, je Zeile „✓ <Nr> <Titel kurz>: erledigt“; nichts bei Übergaben, Starts, Planern."""
import os, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sammelzeile

fehler = 0
def pruefe(ok, was):
    global fehler
    if not ok:
        fehler += 1
        print("FEHLER", was)

KOPF = ("| Nr | Titel | Teil | Block | Kl | Abschnitt | wartet auf | Zweig | Stand | Sitzung | Runde | Kosten |\n"
        "|---|---|---|---|---|---|---|---|---|---|---|---|\n")
def zeile(nr, titel, stand): return "| %s | %s | 7 | B Werkzeuge | Eilt | – | – | – | *%s* | *–* | *0* | *–* |\n" % (nr, titel, stand)
d = tempfile.mkdtemp()
def git(*a, t=None):
    env = dict(os.environ, GIT_AUTHOR_DATE=t or "", GIT_COMMITTER_DATE=t or "")
    return subprocess.run(["git", "-C", d] + list(a), capture_output=True, text=True, env=env, check=True).stdout
git("init", "-q"); git("config", "user.email", "t@t"); git("config", "user.name", "t")
os.makedirs(os.path.join(d, "docs"))
def stand(zs, t):
    open(os.path.join(d, "docs", "LISTE-VORGAENGE.md"), "w", encoding="utf-8").write("# Liste\n\n" + KOPF + "".join(zs))
    git("add", "-A"); git("commit", "-qm", "x", t=t)
A = zeile("2001", "Alpha: lange Beschreibung (Chef 22.11.)", "startbar")
stand([A, zeile("2002", "Beta", "in Arbeit"), zeile("2003", "Gamma", "startbar")], "2026-11-23T07:30:00+01:00")
stand([zeile("2001", "Alpha: lange Beschreibung (Chef 22.11.)", "erledigt"), zeile("2002", "Beta", "in Arbeit"), zeile("2003", "Gamma", "startbar")], "2026-11-23T08:10:00+01:00")
stand([zeile("2002", "Beta", "erledigt"), zeile("2003", "Gamma", "startbar")], "2026-11-23T08:40:00+01:00")  # 2001 ins Archiv
stand([zeile("2002", "Beta", "erledigt"), zeile("2003", "Gamma", "erledigt")], "2026-11-23T09:05:00+01:00")  # nach dem Fenster

z = sammelzeile.erledigt(d, "2026-11-23T08:00:00+01:00", "2026-11-23T09:00:00+01:00")
pruefe([x[0] for x in z] == ["2001", "2002"], "1971: im Fenster erledigt: 2001, 2002 (nicht 2003 danach, nicht ins Archiv geschoben): %s" % z)
t = sammelzeile.text(z, "09:00")
pruefe("✓ 2001 Alpha: erledigt" in t and "✓ 2002 Beta: erledigt" in t, "1971: Wortlaut „✓ <Nr> <Titel kurz>: erledigt“: %r" % t)
pruefe("Beschreibung" not in t, "1971: Titel gekürzt (bis zum ersten Doppelpunkt oder Klammer)")
pruefe(sammelzeile.text([], "09:00") == "", "1971: ohne Erledigtes keine Meldung")
pruefe(sammelzeile.erledigt(d, "2026-11-23T07:00:00+01:00", "2026-11-23T08:00:00+01:00") == [], "1971: Anlage einer Zeile ist kein Erledigt")
lang = sammelzeile.kurz("X" * 100)
pruefe(len(lang) <= 60, "1971: Titel höchstens 60 Zeichen: %d" % len(lang))
# 1971-Ü5 (nein Nils 09:34): Vorsatz „Von <Rolle> (…): “ überspringen, die Sache kürzen
for tt, soll in (("Von Welt (Emil 22.11., 17:43, zu 1566; Sokrates 18:07): tools/godot/bau_am_rechner.py holt das R10-Wasserkit nicht",
                  "tools/godot/bau_am_rechner.py holt das R10-Wasserkit nicht"),
                 ("Von Chef (22.11., 18:39): Kennzahlen Kosten, Sitzungen; Bestand kostenbericht.py", "Kennzahlen Kosten, Sitzungen"),
                 ("Von Sokrates: Archiv-Schutz (status X)", "Archiv-Schutz"),
                 ("Vonnegut lesen: Kapitel", "Vonnegut lesen")):
    pruefe(sammelzeile.kurz(tt) == soll, "1971-Ü5: %r → %r, soll %r" % (tt[:30], sammelzeile.kurz(tt), soll))
print("sammelzeile_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
