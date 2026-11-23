# 1804: Guthabenstufe (287) und Laufsperre aus Chefwort für lauf.py. Ohne Git, ohne Netz. Aufruf: python3 tools/guthaben_test.py
import datetime, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.argv = sys.argv[:1]
import guthaben
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
B = guthaben.BERLIN
J = datetime.datetime(2026, 11, 22, 12, 0, tzinfo=B)  # So
def betrieb(w, t="22.11., 09:00"): return "x\n**Guthaben:** **Chef %s (an Sokrates, Chat):** „%s Prozent“ (…); davor **Chef 19.11., 13:00:** „93 Prozent“\n" % (t, w)

# Zurücksetzen
soll("letzter Reset So → Sa 21.11., 19:59", guthaben.letzter_reset(J) == datetime.datetime(2026, 11, 21, 19, 59, tzinfo=B))
soll("Sa 19:58 → Vorwoche", guthaben.letzter_reset(datetime.datetime(2026, 11, 21, 19, 58, tzinfo=B)) == datetime.datetime(2026, 11, 14, 19, 59, tzinfo=B))
# Stufen
for w, s in ((79, "frei"), (80, "nur Muss"), (94, "nur Muss"), (95, "nur Rückläufer"), (100, "Stillstand")):
    soll("%d %% → %s" % (w, s), guthaben.stufe(betrieb(w), J)[0] == s, guthaben.stufe(betrieb(w), J))
soll("Wert vor dem Zurücksetzen → unbekannt", guthaben.stufe(betrieb(93, "21.11., 13:00"), J)[0] == "unbekannt")
soll("heutige Zeile von ARBEIT-BETRIEB (19.11.) → unbekannt", guthaben.stufe("**Guthaben:** **Chef 19.11., 13:00 (an Sokrates, Chat):** „93 Prozent“", J)[0] == "unbekannt")
soll("ohne Zeile → unbekannt", guthaben.stufe("nichts", J)[0] == "unbekannt")
soll("„87 %“ geht auch", guthaben.stufe("**Guthaben:** **Chef 22.11., 08:00:** „87 %“", J)[:2] == ("nur Muss", 87))

M = {"titel": "Von Sokrates (x): y", "stand": "startbar"}
R1 = {"titel": "Von Chef (18.11., 07:37): Großaxt · zurück t299", "stand": "startbar"}
R2 = {"titel": "x", "stand": "startbar, Rückläufer 👎 16:50: Faust"}
R3 = {"titel": "Von Chef (18.11., 14:34, Fund, Build 298/299): Streitkolben", "stand": "startbar"}
soll("Rückläufer: Marke zurück t, Stand, Fund des Chefs", all(guthaben.ruecklaeufer(d) for d in (R1, R2, R3)) and not guthaben.ruecklaeufer(M))

b = guthaben.Bremse(J, betrieb(85), archiv="")
soll("85 %: Kür angehalten", b.erlaubt("Tom", "K", M) and "nur Muss" in b.erlaubt("Tom", "K", M), b.erlaubt("Tom", "K", M))
soll("85 %: Muss frei", b.erlaubt("Tom", "M", M) is None and b.nur_muss())
b = guthaben.Bremse(J, betrieb(96), archiv="")
soll("96 %: Muss angehalten, Rückläufer frei", b.erlaubt("Tom", "M", M) and b.erlaubt("Jerry", "M", R2) is None)
b = guthaben.Bremse(J, betrieb(100), archiv="")
soll("100 %: alles steht, auch Rückläufer und Sokrates", b.erlaubt("Tom", "M", R1) and b.erlaubt("Sokrates", "M", M))
b = guthaben.Bremse(J, betrieb(50), archiv="")
soll("50 %: frei, keine Laufsperre", b.erlaubt("Tom", "K", M) is None and not b.nur_muss() and b.zeilen() == ["GUTHABEN 50 % (Chef 22.11., 09:00): Stufe frei (287)"], b.zeilen())

# Laufsperre
A = "- **1900, Laufsperre** (22.11., 10:30, Chef an Sokrates: „weniger laufen“) → **Laufsperre: höchstens zwei Starts, spätestens 18:00** (Umfang Sokrates)\n"
P = ["- 10:40 22.11.: Startsperre 10:40 Start Tom, Sokrates (lauf.py, Tom 1535)",
     "- 10:20 22.11.: Startsperre 10:20 Start Jerry (lauf.py, Jerry 1765)",  # vor der Sperre
     "- 11:00 22.11.: Startsperre 11:00 Start Jerry (lauf.py, Jerry 1621)"]  # Rückläufer
zl = {"1535": M, "1621": R2, "1765": M}
rueck = lambda n: guthaben.ruecklaeufer(zl.get(n))
s = guthaben.laufsperre(J, A)
soll("Laufsperre gelesen: Deckel 2, ab 10:30, bis 18:00", s and s["deckel"] == 2 and s["ab"].hour == 10 and s["bis"].hour == 18, s)
soll("nach dem Ende nicht mehr", guthaben.laufsperre(J.replace(hour=18, minute=1), A) is None)
soll("vor dem Chefwort nicht", guthaben.laufsperre(J.replace(hour=10, minute=0), A) is None)
soll("ohne Chef in der Klammer keine", guthaben.laufsperre(J, A.replace("Chef an", "Ford an")) is None)
soll("gezählt: Tom ja, Sokrates frei, vor Beginn nicht, Rückläufer frei → 1", guthaben.gezaehlt(s, J, P, rueck) == 1, guthaben.gezaehlt(s, J, P, rueck))
b = guthaben.Bremse(J, betrieb(50), archiv=A, protokoll=P, rueck=rueck)
soll("noch 1 von 2", b.rest == 1 and "noch 1 von 2 Starts bis 22.11., 18:00" in b.zeilen()[1], b.zeilen())
soll("erster Start erlaubt", b.erlaubt("Tom", "M", M) is None); b.zaehle("Tom", M)
soll("zweiter angehalten", b.erlaubt("Spike", "M", M) and "Laufsperre 1900" in b.erlaubt("Spike", "M", M), b.erlaubt("Spike", "M", M))
soll("Sokrates und Rückläufer bleiben frei", b.erlaubt("Sokrates", "K", M) is None and b.erlaubt("Jerry", "M", R1) is None)
A0 = "- **1901, Laufsperre** (22.11., 11:30, Chef an Sokrates) → **Laufsperre: höchstens keine Starts**\n"
b = guthaben.Bremse(J, betrieb(50), archiv=A0, protokoll=[], rueck=rueck)
soll("„keine“ = 0, ohne Ende 24 h mit Warnung", b.rest == 0 and b.erlaubt("Tom", "M", M) and "Ende fehlt" in b.zeilen()[1], b.zeilen())
soll("Deckel aus nachtstarts (Rolle-Starts an) ist keine Laufsperre", guthaben.laufsperre(J, "- **1784 A** (22.11., 10:00, Chef) → **höchstens zwei weitere Spike-Starts an 1694**") is None)

# 1930 (Chef 22.11., 11:48): Chefwort „alles“ sperrt auch die Rückläufer; Wache und Sokrates bleiben frei.
# 1934 (D371.1): erkannt an der Marke „, auch Rückläufer“ in der fetten Laufsperre, die Sokrates nur bei „alles“ setzt
AA = A.replace("„weniger laufen“", "„weniger laufen, alles“").replace("spätestens 18:00**", "spätestens 18:00, auch Rückläufer**")
s = guthaben.laufsperre(J, AA)
soll("1930: Marke „auch Rückläufer“ erkannt", s and s["alles"] and not guthaben.laufsperre(J, A)["alles"], s)
soll("1930: „alles“ nur im Text nach dem Pfeil zählt nicht", not guthaben.laufsperre(J, A.replace("(Umfang Sokrates)", "(alles Weitere Sokrates)"))["alles"])
soll("1934: „Ja, alles klar, lass weniger laufen.“ ohne Marke sperrt Rückläufer nicht", not guthaben.laufsperre(J, A.replace("„weniger laufen“", "„Ja, alles klar, lass weniger laufen.“"))["alles"])
soll("1934: „alles“ im Zitat ohne Marke sperrt Rückläufer nicht", not guthaben.laufsperre(J, A.replace("„weniger laufen“", "„weniger laufen, alles“"))["alles"])
soll("1934: Marke außerhalb der fetten Laufsperre zählt nicht", not guthaben.laufsperre(J, A.replace("(Umfang Sokrates)", "(Umfang Sokrates, auch Rückläufer)"))["alles"])
soll("1934: Marke ohne „spätestens“ erkannt", guthaben.laufsperre(J, A.replace(", spätestens 18:00**", ", auch Rückläufer**"))["alles"])
soll("1930: gezählt mit „alles“: Tom und Rückläufer Jerry → 2", guthaben.gezaehlt(s, J, P, rueck) == 2, guthaben.gezaehlt(s, J, P, rueck))
b = guthaben.Bremse(J, betrieb(50), archiv=AA, protokoll=P, rueck=rueck)
soll("1930: Deckel verbraucht, Rückläufer angehalten", b.rest == 0 and b.erlaubt("Jerry", "M", R1) and "auch Rückläufer" in b.erlaubt("Jerry", "M", R1), (b.rest, b.erlaubt("Jerry", "M", R1)))
soll("1930: Sokrates und Wache bleiben frei", b.erlaubt("Sokrates", "K", M) is None and b.erlaubt("Wache", "M", M) is None)
soll("1930: Zeile nennt die Sperre der Rückläufer", "frei: Wache, Sokrates (Chef „alles“" in b.zeilen()[1], b.zeilen())
b = guthaben.Bremse(J, betrieb(50), archiv=AA.replace("zwei", "drei"), protokoll=P, rueck=rueck)
b.zaehle("Jerry", R1)
soll("1930: Rückläufer zählt mit „alles“ mit", b.rest == 0, b.rest)

# 2001 (Chef 23.11., 14:37; Archiv 287): Laufsperre als Obergrenze gleichzeitig laufender Fachkräfte; N aus der Zeile (Chef 14:43: drei)
def ober(n="drei", rest=", nur Spiel, nachts 23–07 keine, spätestens 28.11., 20:00"):
    return "- **287 Laufsperre** (22.11., 10:30, Chef an Sokrates: „lasst den einen dritten aufmachen“) → **Laufsperre: höchstens %s Fachkräfte zugleich%s** (Sokrates)\n" % (n, rest)
O = ober()
KA = {"nr": "1068", "bereich": "E Kampf", "eilt": False, "titel": "x", "stand": "startbar"}
WZ = {"nr": "1961", "bereich": "B Werkzeuge", "eilt": False, "titel": "x", "stand": "startbar"}
WE = dict(WZ, eilt=True)
def sitz(r, lauf=True, ruhig=5): return {"id": "session_%s%d" % (r, ruhig), "_info": (r, lauf, ruhig, [])}

def fall(name, f):
    try: f()
    except Exception as ex: soll("2001 (%s): Ausnahme" % name, False, repr(ex))

def f_form():
    s = guthaben.obergrenze(J, O)
    soll("2001: Form gelesen (N 3, nur Spiel, nachts 23–07, bis 28.11., 20:00)", s and s["n"] == 3 and s["bereiche"] == guthaben.SPIEL and s["nacht"] == (23, 7)
         and s["bis"] == datetime.datetime(2026, 11, 28, 20, 0, tzinfo=B), s)
    soll("2001 Kopf: Form im Kopf von guthaben.py beschrieben", "Laufsperre: höchstens <Zahl> Fachkräfte zugleich[, nur <Bereiche>][, nachts HH–HH keine][, spätestens TT.MM., HH:MM]" in guthaben.__doc__)
fall("Form", f_form)

# (a) Laufende aus der Sitzungsliste (lauf.py „Laufend“), nie ARBEIT-BESETZUNG.md; N aus der Zeile
def f_a():
    global b
    je = {"Kampf": [sitz("Kampf")], "Figur": [sitz("Figur")], "Welt": [sitz("Welt", False, 70)], "Prüfer": [sitz("Prüfer")], "Arbeitsplaner": [sitz("Arbeitsplaner")], "Sokrates": [sitz("Sokrates")]}
    soll("2001 (a): Laufende aus der Sitzungsliste: Kampf, Figur; ruhende Welt, Prüfer, Planer, Sokrates nicht → 2", guthaben.laufende_fachkraefte(je) == 2, guthaben.laufende_fachkraefte(je))
    soll("2001 (a): archivierte zählt nicht", guthaben.laufende_fachkraefte(je, {"session_Kampf5"}) == 1)
    b = guthaben.Bremse(J, betrieb(50), archiv=ober("zwei"), protokoll=[], laufend=guthaben.laufende_fachkraefte(je))
    soll("2001 (a): zwei laufen, N 2 → kein dritter START", b.erlaubt("Welt", "M", KA) and "höchstens 2 Fachkräfte" in b.erlaubt("Welt", "M", KA), b.erlaubt("Welt", "M", KA))
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=2)
    soll("2001 (a): N 3 aus der Zeile, zwei laufen → dritter START", b.erlaubt("Welt", "M", KA) is None); b.zaehle("Welt", KA)
    soll("2001 (a): danach drei → kein vierter", b.erlaubt("Regeln", "M", KA) and b.laufend == 3, (b.erlaubt("Regeln", "M", KA), b.laufend))
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[])
    soll("2001 (a): Laufende unbekannt → kein START (bricht ab statt falsch)", b.erlaubt("Welt", "M", KA) and "unbekannt" in b.erlaubt("Welt", "M", KA), b.erlaubt("Welt", "M", KA))
fall("a", f_a)

# (b) nur Spiel: Werkzeug ohne Eilt nein
def f_b():
    global b
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=0)
    soll("2001 (b): Werkzeug ohne Eilt → nein", b.erlaubt("Werkzeug", "M", WZ) and "nur Spiel" in b.erlaubt("Werkzeug", "M", WZ), b.erlaubt("Werkzeug", "M", WZ))
    soll("2001 (b): Spiel = G Regeln, E Kampf, E Figuren, E Welt; E Klang nein", all(b.erlaubt("x", "M", dict(KA, bereich=x)) is None for x in ("G Regeln", "E Kampf", "E Figuren", "E Welt")) and b.erlaubt("Klang", "M", dict(KA, bereich="E Klang")))
    soll("2001 (b): Nachfolger ohne Zeile → nein (Bereich unbekannt)", b.erlaubt("Kampf", "M", None))
fall("b", f_b)

# (c) Eilt nur unter N (287 Filter, 1997)
def f_c():
    global b
    b = guthaben.Bremse(J, betrieb(50), archiv=ober("zwei"), protokoll=[], laufend=1)
    soll("2001 (c): Eilt, eine läuft → START", b.erlaubt("Werkzeug", "M", WE) is None); b.zaehle("Werkzeug", WE)
    soll("2001 (c): Eilt, zwei laufen → nein", b.erlaubt("Werkzeug", "M", dict(WE, nr="1960")) and "höchstens 2" in b.erlaubt("Werkzeug", "M", dict(WE, nr="1960")), b.erlaubt("Werkzeug", "M", WE))
    soll("2001 (c): Eilt der alten Liste („jetzt“) zählt als Eilt", guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=0).erlaubt("Werkzeug", "M", {"bereich": "B Werkzeuge", "titel": "x · „jetzt“ 23.11.", "stand": ""}) is None)
fall("c", f_c)

# (d) frei, eigene Menge: Planer, Prüfer, Wache, Sokrates, Tagesbericht; alte FREI_ROLLEN unverändert
def f_d():
    global b
    b = guthaben.Bremse(J, betrieb(50), archiv=ober("zwei"), protokoll=[], laufend=2)
    soll("2001 (d): Prüfer, Planer, Wache, Sokrates, Tagesbericht bei zwei → START", all(b.erlaubt(r, "M", WZ) is None for r in ("Prüfer", "Arbeitsplaner", "Wache", "Sokrates", "Tagesbericht")),
         [(r, b.erlaubt(r, "M", WZ)) for r in ("Prüfer", "Arbeitsplaner", "Wache", "Sokrates", "Tagesbericht")])
    b.zaehle("Prüfer", WZ); b.zaehle("Arbeitsplaner", WZ)
    soll("2001 (d): freie zählen nicht mit", b.laufend == 2, b.laufend)
    soll("2001 (d): FREI_ROLLEN der alten Form unverändert", guthaben.FREI_ROLLEN == {"Sokrates", "Rundblick", "Ideenlauf", "Wache", "Ford"})
fall("d", f_d)

# (e) nach Ende frei
def f_e():
    global b
    soll("2001 (e): nach „spätestens“ frei", guthaben.Bremse(datetime.datetime(2026, 11, 28, 20, 1, tzinfo=B), betrieb(50), archiv=O, protokoll=[], laufend=9).erlaubt("Werkzeug", "M", WZ) is None)
    soll("2001 (e): vor dem Chefwort frei", guthaben.obergrenze(J.replace(hour=10), O) is None)
    b = guthaben.Bremse(J, betrieb(50), archiv=ober("zwei", ""), protokoll=[], laufend=0)
    soll("2001 (e): ohne Ende 24 h mit Warnung", b.ober["bis"] == b.ober["ab"] + datetime.timedelta(hours=24) and any("Ende fehlt" in z for z in b.zeilen()), b.zeilen())
    soll("2001: ohne Chef in der Klammer keine", guthaben.obergrenze(J, O.replace("Chef an", "Uwe an")) is None)
    soll("2001: Zeile LAUFSPERRE nennt N, Laufende, Bereiche, frei", any(z.startswith("LAUFSPERRE 287") and "2 laufen" in z and "höchstens 3 Fachkräfte" in z and "Prüfer" in z
         for z in guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=2).zeilen()), guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=2).zeilen())
fall("e", f_e)

# (f) alte Form unverändert, neben der neuen
def f_f():
    global b
    soll("2001 (f): neue Form ist keine alte Startzahl", guthaben.laufsperre(J, O) is None)
    b = guthaben.Bremse(J, betrieb(50), archiv=A + O, protokoll=P, rueck=rueck, laufend=0)
    soll("2001 (f): alte Form zählt weiter Starts (noch 1 von 2), neue daneben", b.rest == 1 and b.sperre and b.ober, (b.rest, b.sperre, b.ober))
    b.zaehle("Kampf", KA)
    soll("2001 (f): alte Form hält den zweiten Start an", b.erlaubt("Welt", "M", KA) and "alle 2 Starts verbraucht" in b.erlaubt("Welt", "M", KA), b.erlaubt("Welt", "M", KA))
fall("f", f_f)

# (h) nachts keine Fachkraft
def f_h():
    global b
    b = guthaben.Bremse(J.replace(hour=23, minute=30), betrieb(50), archiv=O, protokoll=[], laufend=0)
    soll("2001 (h): 23:30 → keine Fachkraft, auch Eilt", b.erlaubt("Kampf", "M", KA) and "nachts" in b.erlaubt("Kampf", "M", KA) and b.erlaubt("Werkzeug", "M", WE), b.erlaubt("Kampf", "M", KA))
    soll("2001 (h): 23:30 → Prüfer frei", b.erlaubt("Prüfer", "M", WZ) is None)
    soll("2001 (h): 06:59 nein, 07:00 ja", guthaben.Bremse(J.replace(hour=6, minute=59) + datetime.timedelta(days=1), betrieb(50), archiv=O, protokoll=[], laufend=0).erlaubt("Kampf", "M", KA)
         and guthaben.Bremse(J.replace(hour=7, minute=0) + datetime.timedelta(days=1), betrieb(50), archiv=O, protokoll=[], laufend=0).erlaubt("Kampf", "M", KA) is None)
fall("h", f_h)

print("%d Fehler" % fehl); sys.exit(1 if fehl else 0)
