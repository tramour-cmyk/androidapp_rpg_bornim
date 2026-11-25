#!/usr/bin/env python3
"""2041 d Nachträge (2041-Ü8): Disponent fest „Disponent – Büro“ ohne Rufnamen (Chef 25.11., 21:11), Wache „Wache – Betrieb“,
Wochenzählung „Wochenzählung – KW <nn> – <Nr>“ ohne Rufnamen (Chef 21:14); alte Form „<Name> – Disponent – “ bleibt erkannt;
kosten.rolle gibt Prüfer, Tester, Arbeitsplaner am Titel (2035-Ü38); Mira in rufname.ALLE; „Ford“ → „Disponent“ in den Texten
von neustart-haken.py und lauf.uebergabe_zeilen; art_weg_test und bildvergleich --test in werkzeuge.yml.
Ohne Netz und ohne Schreiben in docs/. Aufruf: python3 tools/titel_2041b_test.py"""
import os, re, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.argv = [sys.argv[0]]
import rufname as rn, kosten, guthaben, lauf, uebergabe as ue

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def ruf(f, *a, **k):
    try: return f(*a, **k)
    except Exception as e: return "Fehler %r" % e

ZEILEN = [{"nr": "2035", "besitzer": "Werkzeug", "titel": "Disponent erkennen"}, {"nr": "2041", "besitzer": "Werkzeug", "titel": "Abläufe"}]
rn._ZEILEN["liste"] = ZEILEN
guthaben.ZEILEN = ZEILEN

NEU = "Disponent – Büro (25.11., 21:30)"
ALT = "Otto – Disponent – Betrieb (25.11., 20:29)"
# Disponent erkennen, neu und alt; nie Wache, Starter, Fachkraft
for t in (NEU, "Disponent – Büro", ALT):
    soll("DISPONENT_TITEL trifft: %s" % t, bool(ue.DISPONENT_TITEL.match(t)))
    soll("kosten.rolle Disponent: %s" % t, kosten.rolle(t) == "Disponent", kosten.rolle(t))
for t in ("Wache – Disponent (25.11., 10:00)", "Wache – Betrieb (25.11., 21:30)", "Disponent-Starter (23.11.)", "Nora – in Arbeit – 2041 – Disponent – Büro",
          "Disponent – Bürokram", "Olga – 2041: Nachträge zu d (25.11., 21:28)"):
    soll("DISPONENT_TITEL trifft nicht: %s" % t, not ue.DISPONENT_TITEL.match(t))
soll("kosten.rolle Wache – Betrieb", kosten.rolle("Wache – Betrieb (25.11., 21:30)") == "Wache", kosten.rolle("Wache – Betrieb (25.11., 21:30)"))

# uebergabe.disponent() liest die Besetzung in beiden Formen, die jüngste Zeile gilt
d = tempfile.mkdtemp(); os.makedirs(os.path.join(d, "docs"))
def besetzung(*zeilen):
    open(os.path.join(d, "docs", "ARBEIT-BESETZUNG.md"), "w", encoding="utf-8").write(
        "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n" + "".join(
            "| Disponent | [%s](https://claude.ai/code/%s) | Betrieb | – | 25.11., 20:27 |\n" % z for z in zeilen))
w = ue.WURZEL; ue.WURZEL = d
try:
    besetzung((ALT, "session_alt"))
    soll("disponent() alte Form", ue.disponent() == ["session_alt"], ue.disponent())
    besetzung((ALT, "session_alt"), (NEU, "session_neu"))
    soll("disponent() neue Form, jüngste Zeile", ue.disponent() == ["session_neu"], ue.disponent())
    besetzung(("Wache – Betrieb (25.11., 21:30)", "session_wache"))
    soll("disponent() nie die Wache", ue.disponent() == [], ue.disponent())
finally:
    ue.WURZEL = w

# Start: Disponent und Wache ohne Rufnamen, fester Titel; Fachkraft weiter mit Rufnamen
s = lauf.ist_scharf; lauf.ist_scharf = lambda: True
try:
    for rolle, kopf in (("Disponent", "Disponent – Büro ("), ("Wache", "Wache – Betrieb (")):
        zs = ruf(lauf.start_zeilen, rolle, "Betrieb", "Übernimm.", [])
        st = [z for z in zs if isinstance(z, str) and z.startswith("START ")] if isinstance(zs, list) else []
        f = st[0].split(" | ", 6) if st else ["", "", "", "", "", "", ""]
        soll("start_zeilen %s: Titel %s…" % (rolle, kopf), f[5].startswith(kopf) and lauf.nummer_aus_titel(f[5]) == "", f[5] or zs)
        soll("start_zeilen %s: kein Rufname" % rolle, "Dein Rufname" not in f[6] and rn.aus_titel(f[5]) is None, f[6][:80])
        soll("start_zeilen %s: kosten.rolle" % rolle, kosten.rolle(f[5]) == rolle, kosten.rolle(f[5]))
    z = "START %s | a | b | c | d | %s – 2041: x (25.11., 21:30) | Auftrag"
    aus = lauf.mit_rufnamen([z % ("Disponent", "Disponent"), z % ("Wache", "Wache"), z % ("Werkzeug", "Werkzeug")], [])
    soll("mit_rufnamen: Disponent ohne Rufname", aus[0] == z % ("Disponent", "Disponent"), aus[0])
    soll("mit_rufnamen: Wache ohne Rufname", aus[1] == z % ("Wache", "Wache"), aus[1])
    soll("mit_rufnamen: Fachkraft mit Rufname", rn.aus_titel(aus[2].split(" | ")[5]) is not None, aus[2])
finally:
    lauf.ist_scharf = s
for rolle in ("Disponent", "Wache", "Wochenzählung"):
    soll("titel_zeile %s: kein TITEL" % rolle, rn.titel_zeile("session_x", "2041", "in Arbeit", rolle=rolle) is None)

# Wochenzählung „Wochenzählung – KW <nn> – <Nr> (…)“
t = ruf(getattr(lauf, "routine_titel", lambda *a: "fehlt"), "Wochenzählung", "2050", "Wochenzählung (Routine, …), Wochentermin 30.11.: x")
soll("routine_titel Wochenzählung – KW 48 – 2050", isinstance(t, str) and t.startswith("Wochenzählung – KW 48 – 2050 ("), t)
soll("Wochenzählung: Nummer 2050, Rolle", isinstance(t, str) and lauf.nummer_aus_titel(t) == "2050" and kosten.rolle(t) == "Wochenzählung",
     (lauf.nummer_aus_titel(str(t)), kosten.rolle(str(t))))
t = ruf(getattr(lauf, "routine_titel", lambda *a: "fehlt"), "Rundblick", "2051", "Rundblick (Routine, …)")
soll("routine_titel Rundblick unverändert", isinstance(t, str) and t.startswith("Rundblick – 2051: Routine ("), t)

# kosten.rolle: Prüfer, Tester, Arbeitsplaner am Titel, nicht der Bereich des Vorgangs (2035-Ü38)
for t, r in (("Ralf – 2035: Prüfung Disponent erkennen (25.11., 21:00)", "Prüfer"), ("Ralf – beim Prüfer – 2035 – Prüfung Disponent", "Prüfer"),
             ("Timo – 2035: Test Disponent erkennen (25.11., 21:00)", "Tester"), ("Vera – Auftrag 2036 (25.11., 18:07)", "Arbeitsplaner"),
             ("Vera – Auftrag 2036: Rufnamen (25.11., 18:07)", "Arbeitsplaner"),
             ("Nora – 2041: Abläufe (25.11., 21:09)", "Werkzeug"), ("Nora – beim Prüfer – 2041 – Abläufe", "Werkzeug")):
    soll("kosten.rolle %s: %s" % (r, t), kosten.rolle(t) == r, kosten.rolle(t))
soll("guthaben.ober_rolle Prüfer weiter", guthaben.ober_rolle(kosten.rolle("Ralf – 2035: Prüfung x"), "Ralf – 2035: Prüfung x") == "Prüfer")

soll("rufname.ALLE: Mira", "Mira" in rn.ALLE)

# Texte an Sitzungen: Disponent statt Ford
q = open(os.path.join(HIER, "neustart-haken.py"), encoding="utf-8").read()
soll("neustart-haken.py: keine „Nachricht an Ford“", "Nachricht an Ford" not in q and q.count("Nachricht an den Disponenten") >= 4,
     [l.strip()[:60] for l in q.splitlines() if "an Ford" in l])
doc = lauf.uebergabe_zeilen.__doc__ or ""
soll("lauf.uebergabe_zeilen: Text ohne „NACHRICHT an Ford“", "an Ford" not in doc, re.findall(r".{20}an Ford.{0,20}", doc))

y = open(os.path.join(HIER, "..", ".github", "workflows", "werkzeuge.yml"), encoding="utf-8").read()
soll("werkzeuge.yml: art_weg_test", re.search(r"^\s*python3 tools/art_weg_test\.py", y, re.M) is not None)
soll("werkzeuge.yml: bildvergleich --test", re.search(r"^\s*python3 tools/bildvergleich\.py --test", y, re.M) is not None)
soll("werkzeuge.yml: titel_2041b_test", "tools/titel_2041b_test.py" in y)

print("titel_2041b_test: %d Fehler" % fehl)
sys.exit(1 if fehl else 0)
