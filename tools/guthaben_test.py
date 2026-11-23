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
def sitz(r, lauf=True, ruhig=5, titel=""): return {"id": "session_%s%d%s" % (r, ruhig, abs(hash(titel)) % 1000 if titel else ""), "title": titel, "_info": (r, lauf, ruhig, [])}

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
    soll("2001 (c), seit 2002 (B): Eilt, zwei laufen (N) → START", b.erlaubt("Werkzeug", "M", dict(WE, nr="1960")) is None, b.erlaubt("Werkzeug", "M", WE)); b.zaehle("Werkzeug", WE)
    soll("2001 (c), seit 2002 (B): Eilt, drei laufen (N+1) → nein", b.erlaubt("Werkzeug", "M", dict(WE, nr="1959")) and "höchstens 2" in b.erlaubt("Werkzeug", "M", dict(WE, nr="1959")), b.erlaubt("Werkzeug", "M", WE))
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

# (d2) 2001-Ü10 (Prüfer 15:54): Prüfer und Tester mit Rufnamen im Titel zählen nicht, auch wenn lauf.py die Rolle aus dem Vorgang liest
def f_d2():
    global b
    pa = "Paula – 1988: Prüfung 1988-Ü8, 1986-Ü9, 1971-Ü6 (23.11., 11:04)"  # echter Titel, kosten.rolle → Figur (Rufname doppelt)
    ha = "Hanna – 1675: Prüfung (23.11., 12:04)"  # echter Titel, Rolle aus dem Vorgang 1675 → Figur
    je = {"Figur": [sitz("Figur", titel=pa), sitz("Figur", titel=ha)], "Tester": [sitz("Tester", titel="Tom – 287: Test Build 287 (23.11., 12:00)")],
          "Werkzeug": [sitz("Werkzeug", titel="Fenja – 2001: Handstart (23.11., 15:33)")], "Kampf": [sitz("Kampf", titel="Conrad – 1068: Handstart (23.11., 14:44)")]}
    n = guthaben.laufende_fachkraefte(je)
    soll("2001 (d2): Prüfer Paula, Hanna (Titel „: Prüfung“) und Tester zählen nicht, Fenja und Conrad → 2", n == 2, n)
    soll("2001 (d2): Rolle aus dem Titel: Prüfung → Prüfer, Test → Tester, Handstart bleibt", guthaben.ober_rolle("Figur", ha) == "Prüfer" and guthaben.ober_rolle("Figur", pa) == "Prüfer"
         and guthaben.ober_rolle("Kampf", "Tom – 287: Test Build 287 (23.11., 12:00)") == "Tester" and guthaben.ober_rolle("Werkzeug", "Fenja – 2001: Handstart (23.11., 15:33)") == "Werkzeug",
         [guthaben.ober_rolle("Figur", t) for t in (ha, pa)])
    nm = guthaben.laufende_namen(je)
    soll("2001 (d2): Namen je Zählung: Conrad (Kampf), Fenja (Werkzeug)", nm == ["Conrad (Kampf)", "Fenja (Werkzeug)"], nm)
    b = guthaben.Bremse(J, betrieb(50), archiv=ober("zwei"), protokoll=[], laufend=n); b.namen = nm
    soll("2001 (d2): LAUFSPERRE-Zeile nennt die Laufenden", any("2 laufen (Conrad (Kampf), Fenja (Werkzeug))" in z for z in b.zeilen()), b.zeilen())
    soll("2001 (d2): Tester frei unter der Obergrenze", b.erlaubt("Tester", "M", WZ) is None, b.erlaubt("Tester", "M", WZ))
fall("d2", f_d2)

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

# 2002 (Chef 23.11., 15:48): (A) fertige Fachkraft ohne Rückläufer belegt keinen Platz; (B) Eilt bis N+1
def vg(*bl): return "# x\n\n## Rückmeldungen\n\nWörtlich.\n\n" + "".join("- **23.11., %s**, %s (`%s`):\n> %s\n\n" % b for b in bl) + "## Übergaben\n"
ZORA = "session_01Hmoj76qSnDZrRVq4uHy98n"
def f_2002_ursache():
    # Ursache Zora 14:58–15:34: fertig 14:57 mit Frage („Freigabe dafür?“) → status_bucket BLOCKED, updated_at 14:57; lauf.py „Laufend“ = working/blocked und unter 60 Min.
    z = {"id": ZORA, "title": "Zora – 1999: Handstart (23.11., 14:38)", "status_bucket": "SESSION_STATUS_BUCKET_BLOCKED", "session_status": "SESSION_STATUS_IDLE",
         "updated_at": "2026-11-23T13:57:26Z"}
    soll("2002 Ursache: Zora (fertig, blocked, 14:57) zählt um 15:30 als laufend, um 15:58 nicht mehr", guthaben.ist_laufend(z, datetime.datetime(2026, 11, 23, 15, 30, tzinfo=B))
         and not guthaben.ist_laufend(z, datetime.datetime(2026, 11, 23, 15, 58, tzinfo=B)))
fall("2002 Ursache", f_2002_ursache)

def f_2002_a():
    global b
    je = {"Werkzeug": [sitz("Werkzeug", titel="Zora – 1999: Handstart (23.11., 14:38)")], "Kampf": [sitz("Kampf", titel="Conrad – 1068: Handstart (23.11., 14:44)")],
          "Figur": [sitz("Figur", titel="Isa – 1694: Handstart (23.11., 15:51)")]}
    zid = je["Werkzeug"][0]["id"]
    fe = guthaben.fertige_sitzungen([vg(("14:57", "Werkzeug", zid, "fertig (Zora, Werkzeug, 23.11., 14:57). Commits …"))])
    soll("2002 (a): letzte Rückmeldung „fertig“ → fertig", set(fe) == {zid}, fe)
    n = guthaben.laufende_fachkraefte(je, fertig=fe)
    soll("2002 (a): drei laufen, Zora fertig → 2 gezählt", n == 2, n)
    soll("2002 (a): Namen ohne Zora", guthaben.laufende_namen(je, fertig=fe) == ["Conrad (Kampf)", "Isa (Figur)"], guthaben.laufende_namen(je, fertig=fe))
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=n)
    soll("2002 (a): N 3, eine davon fertig → START", b.erlaubt("Welt", "M", KA) is None, b.erlaubt("Welt", "M", KA))
    soll("2002 (a): nur „fertig“ zählt: letzte Rückmeldung „Frage“ → nicht fertig", set(guthaben.fertige_sitzungen([vg(("14:57", "W", zid, "fertig x"), ("15:10", "W", zid, "Frage: y"))])) == set())
    soll("2002 (a): jüngste über alle Dateien", set(guthaben.fertige_sitzungen([vg(("15:20", "W", zid, "fertig x")), vg(("15:10", "W", zid, "Frage: y"))])) == {zid})
fall("2002 a", f_2002_a)

def f_2002_b():
    global b
    zid = "session_Zora"
    fe = guthaben.fertige_sitzungen([vg(("14:57", "Werkzeug", zid, "fertig x"), ("15:41", "Prüfer", "session_P", "nein, Auftrag …"))])
    soll("2002 (b): Rückläufer (nein des Prüfers danach) → nicht fertig, zählt wieder", set(fe) == set(), fe)
    je = {"Werkzeug": [dict(sitz("Werkzeug"), id=zid)], "Kampf": [sitz("Kampf")], "Figur": [sitz("Figur")]}
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=guthaben.laufende_fachkraefte(je, fertig=fe))
    soll("2002 (b): mit Rückläufer drei gezählt → kein START", b.laufend == 3 and b.erlaubt("Welt", "M", KA), (b.laufend, b.erlaubt("Welt", "M", KA)))
fall("2002 b", f_2002_b)

def f_2002_cdf():
    global b
    b = guthaben.Bremse(J, betrieb(50), archiv=O, protokoll=[], laufend=3)
    soll("2002 (c): N laufen, Eilt → START", b.erlaubt("Werkzeug", "M", WE) is None, b.erlaubt("Werkzeug", "M", WE))
    soll("2002 (c): N laufen, Spiel ohne Eilt → nein", b.erlaubt("Kampf", "M", KA), b.erlaubt("Kampf", "M", KA)); b.zaehle("Werkzeug", WE)
    soll("2002 (d): N+1 laufen, Eilt → nein", b.laufend == 4 and b.erlaubt("Werkzeug", "M", dict(WE, nr="1960")), (b.laufend, b.erlaubt("Werkzeug", "M", WE)))
    b = guthaben.Bremse(J.replace(hour=23, minute=30), betrieb(50), archiv=O, protokoll=[], laufend=0)
    soll("2002 (f): nachts Eilt → nein", b.erlaubt("Werkzeug", "M", WE) and "nachts" in b.erlaubt("Werkzeug", "M", WE), b.erlaubt("Werkzeug", "M", WE))
fall("2002 c d f", f_2002_cdf)

def f_2002_b2():
    # 2002-Ü4 (Prüfer 16:18, Sokrates 16:21 (1)): jedes Prüfwort außer „ja“ nach dem „fertig“ ist Rückläufer
    zid = "session_Zora"
    for w in ("Beleg fehlt: Ausgabe zu (d)", "nein … steckt fest", "steckt fest: x", "nein, Auftrag unklar"):
        fe = guthaben.fertige_sitzungen([vg(("14:57", "Werkzeug", zid, "fertig x"), ("15:41", "Figur", "session_P", w))])
        soll("2002 (b2): „%s“ nach fertig → Rückläufer, nicht fertig" % w, zid not in fe, fe)
    fe = guthaben.fertige_sitzungen([vg(("14:57", "Werkzeug", zid, "fertig x"), ("15:41", "Prüfer", "session_P", "ja (Hanna): alles belegt"))])
    soll("2002 (b2): „ja“ nach fertig → bleibt fertig", zid in fe, fe)
    fe = guthaben.fertige_sitzungen([vg(("15:41", "Prüfer", "session_P", "Beleg fehlt: y"), ("15:50", "Werkzeug", zid, "fertig z"))])
    soll("2002 (b2): „Beleg fehlt“ vor dem fertig zählt nicht", zid in fe, fe)
fall("2002 b2", f_2002_b2)

def f_2002_taetig():
    # 2002-Ü4 (Sokrates 16:21 (2)): arbeitet eine fertige Sitzung danach wieder (working, updated_at nach dem „fertig“), zählt sie
    zid = "session_Zora"
    fe = guthaben.fertige_sitzungen([vg(("14:57", "Werkzeug", zid, "fertig x"))])
    def je(bucket, upd): return {"Werkzeug": [dict(sitz("Werkzeug"), id=zid, status_bucket=bucket, updated_at=upd)], "Kampf": [sitz("Kampf")], "Figur": [sitz("Figur")]}
    n = guthaben.laufende_fachkraefte(je("SESSION_STATUS_BUCKET_WORKING", "2026-11-23T14:10:00Z"), fertig=fe)
    soll("2002 Tätigkeit: fertig 14:57, danach working (15:10) → zählt, 3", n == 3, n)
    n = guthaben.laufende_fachkraefte(je("SESSION_STATUS_BUCKET_BLOCKED", "2026-11-23T14:10:00Z"), fertig=fe)
    soll("2002 Tätigkeit: fertig 14:57, danach blocked (Frage) → zählt nicht, 2", n == 2, n)
    n = guthaben.laufende_fachkraefte(je("WORKING", "2026-11-23T13:50:00Z"), fertig=fe)
    soll("2002 Tätigkeit: working, updated_at 14:50 vor dem fertig → zählt nicht, 2", n == 2, n)
    soll("2002 Tätigkeit: Namen mit Zora", "session_Zora (Werkzeug)" in guthaben.laufende_namen(je("WORKING", "2026-11-23T14:10:00Z"), fertig=fe),
         guthaben.laufende_namen(je("WORKING", "2026-11-23T14:10:00Z"), fertig=fe))
fall("2002 Tätigkeit", f_2002_taetig)

print("%d Fehler" % fehl); sys.exit(1 if fehl else 0)
