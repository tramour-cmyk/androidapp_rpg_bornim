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

print("%d Fehler" % fehl); sys.exit(1 if fehl else 0)
