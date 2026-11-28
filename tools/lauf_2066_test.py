#!/usr/bin/env python3
"""2066 (Chef 27.11., 22:03 „Ja, nicht Jahr.“; 22:08 „Systemkritisch passt … wenn ich halt sage, das ist jetzt zu erledigen“): ein
Schlüssel für jede Folge: Stufe (1 Krit, 2 Jetzt, 3 Eilt, 4 Muss, 5 Kür) vor Themenblock (Zeilenfolge chefsache/themenbloecke.md);
„Fund des Chefs“ ist keine eigene Stufe mehr. Fälle:
(A) startbar.rang: Folge nach Stufe, gleiche Stufe nach Block; Kl. Krit/Jetzt lesen und schreiben; pruefen kennt beide, unbekannte
    Klasse laut (UnbekannteKlasse, Formfehler).
(B) vorgang.py ordnen (muss_vorn) und startbar.plan (--rolle): Krit, Jetzt, Eilt, Muss, Kür.
(C) uebergabe.buero_rang und lauf.auftrag_offen: Stufe vor Block, Fund ohne eigene Stufe.
(D) lauf.py an einer Liste nur aus Testzeilen (Kopie von tools/ und docs/, 28.11., 21:00, ohne Netz, ohne Push), Deckel 4 Fachkräfte:
    START in der Folge Krit (Story, Block 13), Jetzt (Technik, 6), Eilt (Kampf, 2), Muss (Regeln, 10); Muss Welt (5) nicht mehr
    (gleiche Stufe nach Block, Deckel voll); zweites Muss Regeln startet nicht (eine Fachkraft je Block); Kür ruht; Kl. „Xyz“ →
    WARNUNG-LAUT, kein START.
Aufruf: python3 tools/lauf_2066_test.py"""
import glob, os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
sys.path.insert(0, H); sys.argv = sys.argv[:1]

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

AUFTRAG = open(os.path.join(W, "docs", "vorgang", "2006.md"), encoding="utf-8").read().split("## Auftrag (23.11., 22:09)\n", 1)[1].split("\n## ", 1)[0]
def datei(nr):
    return "# %s · Test 2066\n\n## Auftrag (23.11., 22:09)\n%s\n" % (nr, AUFTRAG)

# (Nr, Block, Bereich, Kl.); Blockfolge laut themenbloecke.md: 10 Regeln, 2 Kampf, 3 Figur, 4, 5 Welt, 11, 12 Oberfläche, 13 Story, 6 Technik, 7, 8
ZEILEN = [("9301", 3, "E Figuren", "K"), ("9302", 10, "G Balance", "M"), ("9303", 5, "E Welt", "M"), ("9304", 2, "E Kampf", "Eilt"),
          ("9305", 6, "E Technik", "Jetzt"), ("9306", 13, "G Story", "Krit"), ("9307", 10, "G Balance", "M"), ("9308", 12, "E Oberfläche", "Xyz")]
SEP = "|---|---|---|---|---|---|---|---|---|---|---|---|\n"
def zeile(n, bl, ber, kl, s="startbar"):
    return "| %s | Test 2066 %s | %d | %s | %s | – | – | – | *%s* | *–* | *0* | *–* |\n" % (n, n, bl, ber, kl, s)

d = tempfile.mkdtemp(prefix="lauf-2066-")
try:
    A = os.path.join(d, "A"); os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    shutil.copytree(os.path.join(H, "umstellung1727"), os.path.join(A, "tools", "umstellung1727"))
    b = os.path.join(A, "docs", "ARBEIT-BETRIEB.md")
    t = open(b, encoding="utf-8").read()
    open(b, "w", encoding="utf-8").write("".join(l for l in t.splitlines(True) if "Startsperre " not in l))
    li = os.path.join(A, "docs", "LISTE-VORGAENGE.md")
    kopf, rest = open(li, encoding="utf-8").read().split(SEP, 1)
    rest = re.sub(r"\A(\|[^\n]*\n)+", "", rest)  # alle echten Zeilen raus: nur Testzeilen
    open(li, "w", encoding="utf-8").write(kopf + SEP + "".join(zeile(*z) for z in ZEILEN) + rest)
    open(li + ".technik", "w", encoding="utf-8").write(kopf + SEP + "".join(zeile(n, 6, "E Technik", kl) for n, _, _, kl in ZEILEN[:7]) + rest)  # (B) ein Besitzer
    for n, *_ in ZEILEN:
        open(os.path.join(A, "docs", "vorgang", "%s.md" % n), "w", encoding="utf-8").write(datei(n))
    ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_OHNE_PUSH="1", BORNIM_LAUF_VOLL="1",
               BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"), BORNIM_SITZUNG="session_test2066")
    for k in ("BORNIM_WURZEL", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    subprocess.run(["git", "init", "-q", "-b", "main"], cwd=A, env=ENV, capture_output=True)
    for c in (["add", "-A"], ["commit", "-q", "-m", "Test 2066"]):
        subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)

    # (A)–(C) im Prozess an der Kopie
    einheit = r'''
import os, sys, json
sys.path.insert(0, "tools"); import startbar
aus = {}
z = {d["nr"]: d for d in startbar.zeilen_liste()}
try:
    aus["rang"] = sorted([n for n in z if n != "9308"], key=lambda n: (startbar.rang(z[n]), n))
except Exception as e: aus["rang"] = repr(e)
aus["kl"] = {n: (z[n]["kl"], bool(z[n].get("eilt"))) for n in ("9304", "9305", "9306")}
aus["text"] = {n: startbar.zeile_text(z[n]).split(" | ")[4] for n in ("9304", "9305", "9306", "9302")}
aus["pruefen"] = {n: startbar.pruefen_zeile(z[n]) for n in ("9305", "9306", "9308")}
try: startbar.rang(z["9308"]); aus["laut"] = "kein Fehler"
except Exception as e: aus["laut"] = type(e).__name__ + ": " + str(e)
import vorgang
t, aus["zahl"] = vorgang.muss_vorn(open("docs/LISTE-VORGAENGE.md.technik", encoding="utf-8").read())
aus["ordnen"] = [d["nr"] for d in startbar.vorgangsliste(t) if d["nr"].startswith("93") and d["besitzer"] == "Technik"]
open("docs/LISTE-VORGAENGE.md.ordnen", "w", encoding="utf-8").write(t)
import uebergabe
r = uebergabe.buero_rang(os.path.abspath("docs"))
aus["buero"] = sorted(["9301", "9302", "9303", "9304", "9305", "9306"], key=lambda n: r(n, "", "28.11., 10:00"))
import lauf
st = {}
for n in ["9301", "9302", "9303", "9304", "9305", "9306"]:
    d_ = z[n]; st.setdefault(d_["besitzer"], ([], [], None, []))[0 if d_["kl"] == "M" else 1].append((n, d_["kl"], d_["titel"], d_))
lauf.auftrag_fehlt = lambda nr, *a, **k: "ohne Auftrag (Test)"
aus["auftrag"] = [o[2] for o in lauf.auftrag_offen(st)]
print("JSON " + json.dumps(aus, ensure_ascii=False))
'''
    r = subprocess.run([sys.executable, "-c", einheit], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    j = next((l[5:] for l in r.stdout.splitlines() if l.startswith("JSON ")), None)
    soll("A–C: Einheit läuft", j is not None, r.stdout[-800:] + r.stderr[-1500:])
    import json
    e = json.loads(j) if j else {}
    FOLGE = ["9306", "9305", "9304", "9302", "9307", "9303", "9301"]  # Krit, Jetzt, Eilt, Muss Block 10 (zwei), Muss Block 5, Kür
    soll("A: startbar.rang Krit, Jetzt, Eilt, Muss (Block 10 vor 5), Kür", e.get("rang") == FOLGE, e.get("rang"))
    soll("A: Kl. Krit/Jetzt/Eilt gelesen als Muss mit Vorrang", e.get("kl") == {"9304": ["M", True], "9305": ["M", True], "9306": ["M", True]}, e.get("kl"))
    soll("A: zeile_text schreibt Krit, Jetzt, Eilt, M zurück", e.get("text") == {"9304": "Eilt", "9305": "Jetzt", "9306": "Krit", "9302": "M"}, e.get("text"))
    p = e.get("pruefen", {})
    soll("A: pruefen kennt Krit und Jetzt", p.get("9305") == [] and p.get("9306") == [], p)
    soll("A: pruefen meldet Kl. „Xyz“", any("Xyz" in x for x in p.get("9308", [])), p)
    soll("A: rang bei Kl. „Xyz“ laut (UnbekannteKlasse)", str(e.get("laut", "")).startswith("UnbekannteKlasse") and "Xyz" in e.get("laut", ""), e.get("laut"))
    soll("B: ordnen zählt verschobene Zeilen (K M M Eilt Jetzt Krit M: 4 verschoben, 3 Muss bleiben; 2066-Ü9 c)", e.get("zahl") == 4, e.get("zahl"))
    soll("B: vorgang.py ordnen je Besitzer Krit, Jetzt, Eilt, Muss, Kür", e.get("ordnen") == ["9306", "9305", "9304", "9302", "9303", "9307", "9301"], e.get("ordnen"))
    soll("C: uebergabe.buero_rang Stufe vor Block", e.get("buero") == ["9306", "9305", "9304", "9302", "9303", "9301"], e.get("buero"))
    soll("C: lauf.auftrag_offen Stufe vor Block", e.get("auftrag") == ["9306", "9305", "9304", "9302", "9303", "9301"], e.get("auftrag"))

    # (B) vorgang.py --rolle an der geordneten Kopie: Technik-Zeilen Krit, Jetzt, Eilt, Muss, Kür
    shutil.copy(li + ".ordnen", li); os.remove(li + ".ordnen")
    q = subprocess.run([sys.executable, "tools/vorgang.py", "--rolle", "Technik", "--alle"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
    pos = [q.stdout.find(n + " |") for n in ("9306", "9305", "9304", "9302", "9301")]
    soll("B: vorgang.py --rolle Technik: Krit, Jetzt, Eilt, Muss, Kür", -1 not in pos and pos == sorted(pos), q.stdout[-1500:] + q.stderr[-500:])

    # (A) vorgang.py klasse/setze: Jetzt nur mit „jetzt“ unter „## Chefworte“, kl=M nimmt Krit weg
    q = subprocess.run([sys.executable, "tools/vorgang.py", "klasse", "9302", "Jetzt", "--sitzung", "Sokrates"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
    soll("A: klasse Jetzt ohne Chefwort „jetzt“ bricht ab (auch Sokrates)", q.returncode != 0 and "Chefworte“ in docs/vorgang/9302.md" in q.stdout + q.stderr, q.stdout[-500:] + q.stderr[-500:])
    v = os.path.join(A, "docs", "vorgang", "9302.md")
    # 2066-Ü9 (Sokrates 28.11., 22:05; Prüfer 22:04): Chefwort 22:08 an 2066 genügt nicht, Setzer muss Sokrates sein (--sitzung Sokrates)
    v66 = open(os.path.join(W, "docs", "vorgang", "2066.md"), encoding="utf-8").read()
    open(v, "a", encoding="utf-8").write("\n## Chefworte\n\n" + "- **27.11., 22:08**" + v66.split("- **27.11., 22:08**", 1)[1].split("\n## ", 1)[0] + "\n")
    for wer in ([], ["--sitzung", "Prüfer"]):
        for bef in (["klasse", "9302", "Jetzt"], ["setze", "9302", "kl=Jetzt"]):
            q = subprocess.run([sys.executable, "tools/vorgang.py"] + bef + wer, cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
            soll("A: %s %s mit Chefwort 22:08 bricht ab" % (" ".join(bef), " ".join(wer) or "ohne --sitzung"),
                 q.returncode != 0 and "Sokrates" in q.stdout + q.stderr and "| 9302 | Test 2066 9302 | 6 | E Technik | M |" in open(li, encoding="utf-8").read(), q.stdout[-500:] + q.stderr[-500:])
    q = subprocess.run([sys.executable, "tools/vorgang.py", "klasse", "9302", "Jetzt", "--sitzung", "Sokrates"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
    soll("A: klasse Jetzt mit Chefwort und --sitzung Sokrates schreibt Kl. Jetzt", q.returncode == 0 and "| 9302 | Test 2066 9302 | 6 | E Technik | Jetzt |" in open(li, encoding="utf-8").read(), q.stdout[-500:] + q.stderr[-500:])
    q = subprocess.run([sys.executable, "tools/vorgang.py", "setze", "9306", "kl=M"], cwd=A, env=ENV, capture_output=True, text=True, timeout=300)
    soll("A: setze kl=M nimmt Krit weg", q.returncode == 0 and "| 9306 | Test 2066 9306 | 6 | E Technik | M |" in open(li, encoding="utf-8").read(), q.stdout[-500:] + q.stderr[-500:])

    # (D) lauf.py mit Deckel 4 Fachkräfte
    open(li, "w", encoding="utf-8").write(kopf + SEP + "".join(zeile(*z) for z in ZEILEN) + rest)
    for c in (["add", "-A"], ["commit", "-q", "-m", "Test 2066 D"]):
        subprocess.run(["git"] + c, cwd=A, env=ENV, capture_output=True)
    seite = os.path.join(d, "seite.txt")
    open(seite, "w", encoding="utf-8").write("# has_more: nein\n")
    prog = ("import datetime, sys; sys.path.insert(0, 'tools'); sys.argv = ['lauf.py', '--ohne-pull', %r]\n"
            "import lauf\nlauf.JETZT = datetime.datetime(2026, 11, 28, 21, 0, tzinfo=lauf.BERLIN)\n"
            "lauf.protokoll_pushen = lambda f, n: (print('GEPUSHT-TEST ' + n), True)[1]\nlauf.herzschlag_pushen = lambda leb: None\n"
            "import guthaben\nZ = [0]\n"
            "guthaben.Bremse.erlaubt = lambda self, r, kl, z: None if not guthaben.fachkraft(r) or Z[0] < 4 else 'Testdeckel 4 Fachkräfte'\n"
            "guthaben.Bremse.zaehle = lambda self, r, z: Z.__setitem__(0, Z[0] + (1 if guthaben.fachkraft(r) else 0))\n"
            "lauf.main()\n") % seite
    r = subprocess.run([sys.executable, "-c", prog], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    zl = r.stdout.splitlines()
    soll("D: Lauf ohne Absturz", r.returncode == 0, r.stderr[-1500:])
    starts = [(l[6:].split(" |")[0], next((n for n, *_ in ZEILEN if " – %s" % n in l), "?")) for l in zl if l.startswith("START ")]
    fach = [s for s in starts if s[0] not in ("Arbeitsplaner", "Prüfer", "Tester", "Tagesbericht", "Wochenzählung", "Sokrates")]
    zeig = [l[:160] for l in zl if l.startswith(("START", "NICHTS", "NUR MUSS", "WARNUNG-LAUT"))]
    soll("D: START-Folge Krit Story, Jetzt Technik, Eilt Kampf, Muss Regeln", fach == [("Story", "9306"), ("Technik", "9305"), ("Kampf", "9304"), ("Regeln", "9302")], zeig)
    soll("D: Muss Welt 9303 nach Muss Regeln, Deckel voll: kein START", not any(n == "9303" for _, n in starts), zeig)
    soll("D: zweites Muss im Block Regeln (9307) startet nicht", not any(n == "9307" for _, n in starts), zeig)
    soll("D: je Block höchstens eine Fachkraft", len({r_ for r_, _ in fach}) == len(fach), fach)
    soll("D: Kür 9301 startet nicht", not any(n == "9301" for _, n in starts), zeig)
    soll("D: Kl. „Xyz“ 9308 laut, kein START", any(l.startswith("WARNUNG-LAUT") and "9308" in l and "Xyz" in l for l in zl) and not any(n == "9308" for _, n in starts), zeig)
finally:
    shutil.rmtree(d, ignore_errors=True)

print("lauf_2066_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
