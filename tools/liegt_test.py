# 1799: LIEGT je Vorgang über der Frist seines Stands (Grobablauf 14.2), Empfänger nach „Bewegt weiter“. Ohne Git, ohne Netz.
# Aufruf: python3 tools/liegt_test.py
import datetime, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.argv = sys.argv[:1]
import liegt, startbar
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
J = datetime.datetime(2026, 11, 22, 12, 0)
def z(nr, stand, h, kl="M", warte="–", build="–", bereich="E Welt", besitzer="Tom"):
    return "| %s | Titel %s | %s | %s | %s | %s | – | %s | %s | – |" % (nr, nr, besitzer, kl, stand, warte, build, bereich), h
ZS = [z("1", "startbar", 7), z("2", "startbar", 5), z("3", "startbar", 30, kl="K"), z("4", "gebaut, Geprüft an: abc1234", 25),
      z("5", "gebaut, Geprüft an: abc1234", 25, warte="Diogenes"), z("6", "gebaut, Geprüft an: def5678", 1, bereich="B Werkzeuge", besitzer="Spike"),
      z("7", "zu testen", 24 * 6, build="301"), z("8", "zu testen", 24 * 15, build="301"), z("9", "ruht", 50),
      z("10", "ruht", 50, warte="21.11."), z("11", "ruht", 50, warte="30.11."), z("12", "startbar, steckt fest", 49),
      z("13", "in Arbeit", 7), z("14", "wartet", 100, warte="1"), z("15", "erledigt", 900), z("16", "neu", 25),
      z("17", "gebaut, Geprüft an: 9f6e4c4", 30, warte="t301"), z("18", "ruht, bis Sa 21.11.", 50), z("19", "ruht", 50, warte="1331"),
      z("20", "ruht, Chef 04.11.", 50), z("21", "ruht, bis Kapitel 1 fertig (Chef 18.11.)", 50)]
kopf = "| Nr. | Vorgang | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
text = kopf + "\n".join(r for r, _ in ZS) + "\n"
zs = startbar.vorgangsliste(text)
zeiten = [None] * (max(d["i"] for d in zs) + 1)
for d, (_, h) in zip(zs, ZS): zeiten[d["i"]] = (J - datetime.timedelta(hours=h)).timestamp()
main = {"abc1234": True, "def5678": False, "9f6e4c4": True}
neu = liegt.zeilen(zs, zeiten, J, None, lambda c: main.get(c))
alt = liegt.zeilen(zs, zeiten, J, liegt.ALT, lambda c: main.get(c))
def zu(nr, aus=neu): return [l for l in aus if l.startswith("LIEGT %s |" % nr)]
soll("Muss startbar über 6 h → Disponent", zu("1") == ["LIEGT 1 | startbar | 7 h 00 min | an Disponent: Leichenprüfung: starten oder Grund nennen (14.2.4)"], zu("1"))
soll("unter der Frist: nichts", not zu("2"))
soll("Kür startbar: nichts (nach Vorrang)", not zu("3"))
soll("gebaut über 1 Tag → neuer Prüfer", zu("4") and "an Disponent: neuer Prüfer" in zu("4")[0] and "14.2.6" in zu("4")[0], zu("4"))
soll("gebaut, wartet auf Diogenes: nichts", not zu("5"))
soll("Werkzeug gebaut, Commit nicht auf main → Fachkraft", zu("6") == ["LIEGT 6 | gebaut, nicht auf main | 1 h 00 min | an Spike: Commit def5678 auf `main`, Vollzug mit Commit (1799)"], zu("6"))
soll("Chef testet über 5 Tage → Tagesbericht", zu("7") and "an Tagesbericht: Erinnerung" in zu("7")[0], zu("7"))
soll("Chef testet über 14 Tage → ruht mit Datum", zu("8") and "an Disponent: „ruht“ mit Datum" in zu("8")[0], zu("8"))
soll("ruht ohne Datum → Arbeitsplaner", zu("9") and "an Arbeitsplaner: ruht ohne Datum" in zu("9")[0], zu("9"))
soll("ruht, Datum erreicht → zurück auf Auftrag", zu("10") and "Datum 21.11. erreicht" in zu("10")[0], zu("10"))
soll("ruht, Datum später: nichts", not zu("11"))
soll("steckt fest über 48 h → Sokrates", zu("12") and "an Sokrates: Chefsache" in zu("12")[0], zu("12"))
soll("in Arbeit über 6 h → Disponent", zu("13") and "Sperre lösen" in zu("13")[0], zu("13"))
soll("wartet auf: nichts", not zu("14"))
soll("erledigt: nichts", not zu("15"))
soll("neu über 1 Tag → Arbeitsplaner", zu("16") and "an Arbeitsplaner" in zu("16")[0], zu("16"))
soll("gebaut, wartet auf t301 = Chef testet (unter 5 Tagen nichts)", not zu("17"))
soll("ruht bis Datum im Zusatz: zurück auf Auftrag", zu("18") and "Datum 21.11. erreicht" in zu("18")[0], zu("18"))
soll("ruht, wartet auf Vorgang: nichts", not zu("19"))
soll("1874 ruht, Datum eines Chefworts ist kein Termin", zu("20") and "ruht ohne Datum" in zu("20")[0], zu("20"))
soll("1874 ruht bis Kapitel 1 (Chef 18.11.): kein Termin", zu("21") and "ruht ohne Datum" in zu("21")[0], zu("21"))
soll("bis zur Umschaltung: Disponent = Ford, Tagesbericht = Perikles", zu("1", alt) and "an Ford:" in zu("1", alt)[0] and "an Perikles:" in zu("7", alt)[0], alt)
soll("Form LIEGT <Nr> | Stand | Alter | an <Rolle>", all(l.count(" | ") == 3 and " | an " in l for l in neu), neu)
soll("Alter in Tagen", liegt.alter_text(2 * 86400 + 3 * 3600) == "2 d 3 h")
import lauf
soll("lauf.py ruft liegt nur mit 1727-SCHARF", "if ist_scharf():  # 1799" in open(lauf.__file__, encoding="utf-8").read())
print("liegt_test: %s" % ("grün" if not fehl else "%d Fehler" % fehl))
sys.exit(fehl)
