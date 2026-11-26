#!/usr/bin/env python3
"""2041 Abläufe a–c (Chef 25.11., 20:48 „a bis d ja und jetzt“): (a) Stand „gebaut“ mit Commit legt sofort die Prüferzeile an,
(b) Rückläufer ohne lebende Fachkraft geht an die Rolle des Vorgangs, (c) Zeile „auf main, Vollzug mit Commit“ schließt sich, wenn der
Commit auf origin/main steht. Ohne Netz und ohne Schreiben (Schreiber ersetzt). Aufruf: python3 tools/ablaeufe_2041_test.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vorgang, rueckmeldung, uebergabe as ue

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

FEHLT = lambda *a, **k: ("fehlt", ["fehlt"])  # Funktion fehlt: Test rot statt Absturz
KOPF = "## Übergaben\n\n| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"

# (a) Fälle 1301, 1387, 1642, 1643: „gebaut“ mit Commit, Prüferzeile erst nach 24 h (liegt.py)
neu = []
ue_alt = ue.uebergabe
ue.uebergabe = lambda nr, an, was: neu.append((nr, an, was)) or "%s-Ü9" % nr
try:
    leer = "# 1642 · Test\n\n" + KOPF
    k = getattr(vorgang, "pruefer_bei_gebaut", FEHLT)("1642", "in Arbeit", "gebaut, Geprüft an: abc1234", text=leer)
    soll("(a) gebaut mit Commit → Zeile an Prüfer", k == "1642-Ü9" and neu and neu[0][1] == "Prüfer" and "abc1234" in neu[0][2], neu)
    neu.clear()
    offen = leer + "| 1642-Ü1 | Prüfer | prüfen: „fertig“ (1739) | 25.11., 20:00 | offen |\n"
    soll("(a) offene Prüferzeile da → keine zweite", getattr(vorgang, "pruefer_bei_gebaut", FEHLT)("1642", "in Arbeit", "gebaut, Geprüft an: abc1234", text=offen) is None and not neu, neu)
    soll("(a) Stand schon „gebaut“ → keine neue Zeile", getattr(vorgang, "pruefer_bei_gebaut", FEHLT)("1642", "gebaut, Geprüft an: abc1234", "gebaut, Geprüft an: abc1234", text=leer) is None and not neu, neu)
    soll("(a) „gebaut“ ohne Commit (Lauf-Link) → keine Zeile", getattr(vorgang, "pruefer_bei_gebaut", FEHLT)("1642", "in Arbeit", "gebaut, Geprüft an: Lauf 12", text=leer) is None and not neu, neu)
    soll("(a) anderer Stand → keine Zeile", getattr(vorgang, "pruefer_bei_gebaut", FEHLT)("1642", "startbar", "in Arbeit", text=leer) is None and not neu, neu)
finally:
    ue.uebergabe = ue_alt

# (b) Fälle 2024-Ü6 (an Selma), 2031-Ü3 (an Inge): Rückläufer an einen Rufnamen ohne lebende Sitzung
VORHER = ("# 2024 · Prankenhieb\n\n## Rückmeldungen\n\n- **25.11., 13:41**, Selma (`session_S`):\n> fertig: Zweig x, Kopf acb701fbd\n\n" + KOPF)
b_alt, l_alt = ue.besetzung, rueckmeldung._listen_besitzer
rueckmeldung._listen_besitzer = lambda nr: "Kampf" if nr == "2024" else None
try:
    ue.besetzung = lambda an: []
    an, was = rueckmeldung.weitergabe({"nein"}, "", "25.11., 13:42", "Prüfer", "nein: Prüffrage 5", VORHER)
    soll("(b) nein, Selma läuft nicht → an Rolle Kampf", an == "Kampf" and was.startswith("Rückläufer"), (an, was))
    ue.besetzung = lambda an: ["session_S"] if an == "Selma" else []
    an, was = rueckmeldung.weitergabe({"nein"}, "", "25.11., 13:42", "Prüfer", "nein: Prüffrage 5", VORHER)
    soll("(b) nein, Selma läuft → an Selma", an == "Selma", (an, was))
    ue.besetzung = lambda an: []
    an, was = rueckmeldung.weitergabe({"Beleg fehlt"}, "", "25.11., 13:42", "Prüfer", "Beleg fehlt: Bild", VORHER)
    soll("(b) Beleg fehlt, Selma läuft nicht → an Rolle Kampf", an == "Kampf", (an, was))
    rueckmeldung._listen_besitzer = lambda nr: None
    an, was = rueckmeldung.weitergabe({"nein"}, "", "25.11., 13:42", "Prüfer", "nein: Prüffrage 5", VORHER)
    soll("(b) ohne Besitzer in der Liste → bleibt bei Selma (kein Raten)", an == "Selma", (an, was))
finally:
    ue.besetzung, rueckmeldung._listen_besitzer = b_alt, l_alt

# (c) Fälle 2035-Ü15/24/28: „auf main, Vollzug mit Commit: <c> steht nicht auf origin/main …“
W = "auf main, Vollzug mit Commit: %s steht nicht auf origin/main (Prüfung beim Eintrag 25.11., 19:45, 1950); Werkzeug nach grünem Lauf sofort auf main (1311)"
T = ("# 2035 · Test\n\n" + KOPF
     + "| 2035-Ü15 | Werkzeug | %s | 25.11., 19:45 | offen |\n" % (W % "be35eb5ab")
     + "| 2035-Ü24 | Disponent | %s | 25.11., 20:00 | angenommen session_D bis 25.11., 20:30 |\n" % (W % "61c7856d3")
     + "| 2035-Ü28 | Disponent | %s | 25.11., 20:11 | offen |\n" % (W % "7ed0e2614")
     + "| 2035-Ü29 | Prüfer | prüfen: „fertig“ Commit be35eb5ab (1739) | 25.11., 20:12 | offen |\n")
AUF = {"be35eb5ab": True, "61c7856d3": True, "7ed0e2614": False}
t2, ks = getattr(ue, "main_zeilen_schliessen_text", FEHLT)(T, "2035", lambda c: AUF.get(c))
soll("(c) Ü15 und Ü24 (Commit auf main) geschlossen, Ü28 (nicht auf main) offen", ks == ["2035-Ü15", "2035-Ü24"], ks)
zu = {z["k"]: z["z"] for z in ue.zeilen(t2 if isinstance(t2, str) and t2 != "fehlt" else T)}
soll("(c) Zustand „erledigt … auf origin/main“", zu["2035-Ü15"].startswith("erledigt") and "origin/main" in zu["2035-Ü15"], zu["2035-Ü15"])
soll("(c) Ü28 bleibt offen, Prüferzeile Ü29 unberührt", zu["2035-Ü28"] == "offen" and zu["2035-Ü29"] == "offen", zu)
soll("(c) Commit unbekannt (None) → offen", getattr(ue, "main_zeilen_schliessen_text", FEHLT)(T, "2035", lambda c: None)[1] == [])

print("ablaeufe_2041_test: " + ("gut" if not fehl else "%d Fehler" % fehl))
sys.exit(1 if fehl else 0)
