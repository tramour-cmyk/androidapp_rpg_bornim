#!/usr/bin/env python3
"""Auftrag und Schließen über vorgang.py (1739, Bauliste 1727 Gesamtbild 7.1, Vorlage 4.2).

  vorgang.py auftrag NR                  Vorlage mit den sieben Feldern ausgeben (zum Ausfüllen)
  vorgang.py auftrag NR --datei PFAD     Auftrag prüfen (sieben Felder, Pflichtfeld „Zurück“ mit Inhalt, höchstens 2 KB)
                                         und als Abschnitt „## Auftrag (TT.MM., HH:MM)“ in docs/vorgang/NR.md eintragen (gepusht wie
                                         die Übergabezeilen); „-“ liest von der Standardeingabe; --pruefen: nur prüfen, nichts schreiben
  vorgang.py schliessen NR "Grund"       Vorgang schließen mit Grund (mindestens drei Wörter): Stand „erledigt“ wie `fertig`
                                         (Rest-Sperre 1143 gilt), Grund als Zeile „Geschlossen“ in docs/vorgang/NR.md

Felder (Gesamtbild 4.2): 1 Ziel · 2 Systemfrage · 3 Bisher · 4 Beachte (höchstens fünf Punkte) · 5 Umsetzen · 6 Prüfart und
Prüfe vor dem Senden · 7 Zurück. Feld 8 „Leistungsstufe“ erst nach 1742 (Gesamtbild 4.2 Fassung 2).
Größe: Bauliste 7.1 „etwa 2 KB“ (Vorlage 4.2 nannte 1,5 KB); über 2048 Byte hält an.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

FELDER = ["Ziel", "Systemfrage", "Bisher", "Beachte", "Umsetzen", "Prüfart und Prüfe vor dem Senden", "Zurück"]
HINWEIS = ["was der Spieler sieht, hört oder erlebt", "keine Einzellösung; wie lösen es andere? Pflicht bei Bezügen",
           "was schon versucht wurde, mit Ursache", "höchstens fünf Punkte", "was zu tun ist",
           "drei bis fünf Ja-Nein-Fragen", "an wen, in welcher Form, mit Beleg; Zweig gepusht, Commit genannt"]
GRENZE = 2048

# 1789 (Sokrates, routine-rundblick.md:13, „Zu 1766“: alle drei Routinen): Routinen sind vom Feld „Zurück“ ausgenommen; ihr Auftrag ist
# der feste Text (Teil A), das Zurück steht darin (Übergabezeilen ans Büro, dann „fertig“). Erkannt am Titel des Wochentermins.
ROUTINE = re.compile(r"\(Routine, Auftrag (\S+?\.md)(?: (Teil [A-Z]))?\)")

def routine(titel):
    """1789: (Pfad, Teil oder None), wenn der Titel eine Routine nennt, sonst None."""
    m = ROUTINE.search(titel or "")
    return (m.group(1), m.group(2)) if m else None

def routine_text(titel, wurzel):
    """1789: fester Auftrag der Routine: erster ```markdown-Block unter „## <Teil>“ (ohne Teil: erster Block der Datei); None, wenn er fehlt."""
    r = routine(titel)
    if not r: return None
    p = os.path.join(wurzel, r[0])
    if not os.path.isfile(p): return None
    text = open(p, encoding="utf-8").read()
    if r[1]:
        m = re.search(r"(?m)^## %s\b.*$" % re.escape(r[1]), text)
        if not m: return None
        text = text[m.end():]
    m = re.search(r"(?ms)^```markdown\n(.*?)^```", text)
    return m.group(1).strip() if m else None

def vorlage(nr, titel=""):
    kopf = "Auftrag %s%s\n\n" % (nr, (": " + titel) if titel else "")
    return kopf + "\n".join("%d. **%s:** <%s>" % (i, f, h) for i, (f, h) in enumerate(zip(FELDER, HINWEIS), 1)) + "\n"

def _feld(text, i, name):
    """Inhalt von Feld i bis zum nächsten nummerierten Feld; None, wenn es fehlt."""
    weiter = "|".join(re.escape(x) for x in FELDER)
    m = re.search(r"(?m)^[ \t]*%d\.[ \t]*\**%s\**[ \t]*:?\**[ \t]*:?(.*?)(?=^[ \t]*\d\.[ \t]*\**(?:%s)\b|\Z)" % (i, re.escape(name), weiter), text, re.S)
    return None if not m else m.group(1).strip()

def pruefen(text):
    """Liste der Fehler (leer = gut)."""
    f = []
    n = len(text.encode("utf-8"))
    if n > GRENZE: f.append("%d Byte, höchstens %d (Bauliste 7.1 „etwa 2 KB“)" % (n, GRENZE))
    for i, name in enumerate(FELDER, 1):
        inhalt = _feld(text, i, name)
        if inhalt is None: f.append("Feld %d „%s“ fehlt" % (i, name)); continue
        if re.fullmatch(r"<[^>]*>|[-–—]?|…", inhalt): f.append("Feld %d „%s“ leer" % (i, name))
    zur = _feld(text, 7, "Zurück")
    if zur and not re.fullmatch(r"<[^>]*>|[-–—]?|…", zur) and len(zur.split()) < 3:
        f.append("Feld 7 „Zurück“ zu knapp: an wen, in welcher Form, mit Beleg")
    bea = _feld(text, 4, "Beachte") or ""
    punkte = [z for z in bea.splitlines() if re.match(r"\s*(?:[-*•]|\d+[.)])\s", z)]
    if len(punkte) > 5: f.append("Feld 4 „Beachte“ hat %d Punkte, höchstens fünf" % len(punkte))
    return f

def eintragen(nr, text, treffer=None):
    """treffer: Zeile „Lehren-Treffer (Zeit): …“ (1739 Lehrenbuch), steht im selben Commit unter dem Auftrag."""
    zeit = ue.fmt(ue.jetzt())
    def aendern(alt):
        kopf = "" if alt else "# Vorgang %s\n\n" % nr
        return alt + kopf + ("\n" if alt and not alt.endswith("\n\n") else "") + "## Auftrag (%s)\n\n%s\n%s" % (
            zeit, text.strip(), ("\n" + treffer + "\n") if treffer else ""), zeit
    return ue.atomar(nr, aendern, "%s: Auftrag (%s, vorgang.py auftrag)" % (nr, zeit))

def schliessen(nr, grund):
    zeit = ue.fmt(ue.jetzt())
    def aendern(alt):
        kopf = "" if alt else "# Vorgang %s\n\n" % nr
        return alt + kopf + ("\n" if alt and not alt.endswith("\n\n") else "") + "Geschlossen (%s): %s\n" % (zeit, grund.strip()), zeit
    return ue.atomar(nr, aendern, "%s: geschlossen (%s): %s" % (nr, zeit, grund.strip()[:120]))

def _titel(nr):
    import startbar
    z = [d for d in startbar.zeilen_liste() if d["nr"] == nr]
    return z[0]["titel"] if z else None

def haupt(a, fertig=None):
    b, rest = a[0], list(a[1:])
    if b == "auftrag":
        nur = "--pruefen" in rest
        if nur: rest.remove("--pruefen")
        datei = None
        if "--datei" in rest:
            i = rest.index("--datei")
            if i + 1 >= len(rest): sys.exit("vorgang.py auftrag: --datei braucht einen Pfad oder „-“")
            datei = rest[i + 1]; del rest[i:i + 2]
        if len(rest) != 1: sys.exit(__doc__)
        nr = rest[0]
        titel = _titel(nr)
        if titel is None: sys.exit("vorgang.py auftrag: %s steht nicht in der Vorgangsliste" % nr)
        import lehren
        liste, treffer = lehren.treffer_zeile(nr, titel)
        if datei is None:
            print(vorlage(nr, titel), end="")
            print("\nLehren des Bereichs (Lehrenbuch, 1739; passende in „Beachte“ und „Umsetzen“, höchstens fünf, weitere als Nummer):")
            print("\n".join("- " + lehren.zeigen(x) for x in liste) if liste else "- keine")
            return
        text = sys.stdin.read() if datei == "-" else open(datei, encoding="utf-8").read()
        f = pruefen(text)
        if f:
            print("vorgang.py auftrag %s hält an:\n- " % nr + "\n- ".join(f)); sys.exit(1)
        if nur: print("vorgang.py auftrag %s: gültig (%d Byte)" % (nr, len(text.encode("utf-8")))); return
        try: zeit = eintragen(nr, text, treffer)
        except ue.Fehler as e: sys.exit("vorgang.py auftrag: %s; nichts geschrieben" % e)
        print("vorgang.py: Auftrag %s eingetragen (%s, %s, gepusht)" % (nr, ue._pfad(nr), zeit)); return
    if b == "schliessen":
        if len(rest) != 2: sys.exit(__doc__)
        nr, grund = rest
        if len(grund.split()) < 3: sys.exit("vorgang.py schliessen: Grund mit mindestens drei Wörtern (warum geschlossen, was gilt)")
        if _titel(nr) is None: sys.exit("vorgang.py schliessen: %s steht nicht in der Vorgangsliste" % nr)
        fertig(nr)  # hält bei Rest ohne Folgevorgang an (1143), bevor der Grund geschrieben wird
        try: schliessen(nr, grund)
        except ue.Fehler as e: sys.exit("vorgang.py schliessen: Liste auf erledigt, Grund nicht geschrieben (%s); nachholen" % e)
        import lehren  # 1739 Lehrenbuch, „Roh sammeln“ beim Schließen
        try: print("LEHRENBUCH %s angehängt (Schließen)" % lehren.roh(nr, "geschlossen", grund))
        except ue.Fehler as e: print("LEHRENBUCH nicht geschrieben (%s); von Hand: vorgang.py lehre roh %s geschlossen …" % (e, nr))
        print("vorgang.py: Grund in %s (gepusht); Liste committen und pushen" % ue._pfad(nr)); return
    sys.exit(__doc__)

if __name__ == "__main__":
    haupt(sys.argv[1:])
