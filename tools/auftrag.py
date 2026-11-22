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
Größe: Bauliste 7.1 „etwa 2 KB“ (Vorlage 4.2 nannte 1,5 KB); über 2048 Byte hält an. 1878 (Lauf 3 Arbeitsplaner L4): wörtliche
Zitate in Feld 3 „Bisher“ („…“ oder "…"; Kern: jedes frühere Nein wörtlich) zählen nicht mit, haben eine eigene Grenze von 2048 Byte.
1879 (Lauf 3 Arbeitsplaner L7, Prüfer-1 L8): Inhalt, nicht nur Form: kein Platzhalter <…> (außer in Pfaden wie docs/vorgang/<Nr>.md),
in Ziel, Umsetzen, Prüfart und Zurück keine Fehlwörter über den Auftrag selbst („Ziel fehlt“, „Herkunft unklar“, „erst mit der
Antwort“, TODO; 1917: „Im Hof fehlt die Fackel“ ist ein Spielfund und gilt), Ziel und Zurück ohne Frage,
Feld 6 mit drei bis fünf Prüffragen (Kern Arbeitsplaner, Vorlage 4.2).
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

FELDER = ["Ziel", "Systemfrage", "Bisher", "Beachte", "Umsetzen", "Prüfart und Prüfe vor dem Senden", "Zurück"]
HINWEIS = ["was der Spieler sieht, hört oder erlebt", "keine Einzellösung; wie lösen es andere? Pflicht bei Bezügen",
           "was schon versucht wurde, mit Ursache", "höchstens fünf Punkte", "was zu tun ist",
           "drei bis fünf Ja-Nein-Fragen", "an wen, in welcher Form, mit Beleg; Zweig gepusht, Commit genannt"]
GRENZE = 2048
GRENZE_ZITATE = 2048  # 1878: wörtliche Zitate unter „Bisher“, getrennt von GRENZE
ZITAT = re.compile(r'„[^“”„]*[“”]|"[^"\n]*"')

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
    kopf = ("Auftrag %s%s (höchstens %d Byte, etwa 2 KB; wörtliche Zitate unter „Bisher“ zählen nicht mit, eigene Grenze %d Byte; "
            "oben in docs/vorgang/%s.md)\n\n") % (nr, (": " + titel) if titel else "", GRENZE, GRENZE_ZITATE, nr)
    return kopf + "\n".join("%d. **%s:** <%s>" % (i, f, h) for i, (f, h) in enumerate(zip(FELDER, HINWEIS), 1)) + "\n"

def _name_re(name):
    """1798 (Kern Arbeitsplaner, Feld 6 „Prüfart“): Feld 6 heißt auch nur „Prüfart“."""
    return r"Prüfart(?: und Prüfe vor dem Senden)?" if name == FELDER[5] else re.escape(name)

def _feld(text, i, name):
    """Inhalt von Feld i bis zum nächsten nummerierten Feld; None, wenn es fehlt."""
    weiter = "|".join(_name_re(x) for x in FELDER)
    m = re.search(r"(?m)^[ \t]*%d\.[ \t]*\**%s\**[ \t]*:?\**[ \t]*:?(.*?)(?=^[ \t]*\d\.[ \t]*\**(?:%s)\b|\Z)" % (i, _name_re(name), weiter), text, re.S)
    return None if not m else m.group(1).strip()

# 1879: Platzhalter wie <Nr>, <Commit>, <was der Spieler sieht>; nicht in Pfaden (docs/vorgang/<Nr>.md) und nicht <-> o. Ä.
PLATZHALTER = re.compile(r"(?<![/\w])<[^<>\n/]*[A-Za-zÄÖÜäöüß][^<>\n/]*>(?![/.\w])")
# 1879, 1917 (D347.1), 1920 (D349.1): Wörter, die sagen, dass der AUFTRAG noch fehlt (A3 Feld 1: „Ziel und Herkunft fehlen, „Frage“
# an Sokrates; … erst mit der Antwort“). Geprüft wird je Satz und Satzteil: er sagt nur „fehlt/unklar/offen“ über einen Teil des
# Auftrags (Ziel, Herkunft, Quelle …) und sonst nichts als Füllwörter („Das Ziel ist unklar.“, „Es fehlt das Ziel“, „Ziel: noch offen.“,
# „ziel fehlt“), oder er ist nur „unklar“ vor einem Fragesatz („Unklar, was gebaut werden soll“). Ein Satz mit Ort oder Ding
# („Das Ziel fehlt auf der Gebietskarte“, „Im Hof fehlt die Fackel“, „Fehlt der Schatten noch?“) ist ein Spielfund.
_META = {"ziel", "ziele", "herkunft", "quelle", "quellen", "angabe", "angaben", "auftrag", "auftrags", "prüffrage", "prüffragen",
         "prüfart", "commit", "commits", "zweig", "empfänger", "nummer", "vorgangsnummer", "beleg", "belege", "systemfrage"}
_LEER = {"fehlt", "fehlen", "fehlend", "fehlende", "unklar", "ungeklärt", "offen", "unbekannt", "unbestimmt", "ausstehend", "aus"}
_FUELL = {"der", "die", "das", "den", "dem", "des", "es", "ist", "sind", "bleibt", "bleiben", "war", "noch", "und", "oder", "auch",
          "ganz", "völlig", "gänzlich", "komplett", "bisher", "leider", "derzeit", "aktuell", "hier", "ebenfalls", "weiterhin", "immer",
          "jedoch", "aber", "gar", "steht", "stehen", "sowie", "beide", "beides", "alle", "noch", "so", "vorerst", "erst", "mal"}
_FRAGEWORT = re.compile(r"^\s*(?:was|wer|wen|wem|wie|wo|wohin|woher|woran|worauf|wann|warum|wozu|ob|welche[rsnm]?)\b", re.I)
FEHLWORT_FEST = re.compile(r"\bTODO\b|\btbd\b|\?\?|\bspäter ergänzen\b|\bnoch zu klären\b|\berst (?:mit|nach) der Antwort\b"
                           r"|„Frage“ an (?:Sokrates|den Chef|Chef|Ford|Perikles|Homer|den Disponenten|den Arbeitsplaner)\b", re.I)

def _woerter(teil):
    t = re.sub(r"\bnicht\s+(?:klar|bekannt|festgelegt|geklärt|bestimmt|angegeben|genannt)\b", "unklar", teil.lower())
    return re.findall(r"[\wäöüß]+", t)

def _nur_leer(w):
    """Satzteil sagt nur „fehlt/unklar/offen“ (ohne Teil des Auftrags), z. B. „Es ist unklar“."""
    return bool(w) and any(x in _LEER for x in w) and all(x in _LEER or x in _FUELL for x in w)

def fehlwoerter(t):
    """1920: Stellen in t, die sagen, dass der Auftrag selbst fehlt (leer = keine)."""
    treffer = [m.group(0).strip() for m in FEHLWORT_FEST.finditer(t)]
    for satz in re.split(r"[.;!?\n]+", _ohne_zitate(t)):
        teile = [x for x in re.split(r",", satz)]
        for kand in [satz] + teile:
            w = _woerter(kand)
            if (w and any(x in _META for x in w) and any(x in _LEER for x in w)
                    and all(x in _META or x in _LEER or x in _FUELL for x in w)):
                treffer.append(kand.strip(" :–-")); break
        else:
            for i, teil in enumerate(teile):
                nachbarn = teile[i + 1:i + 2] + teile[max(i - 1, 0):i]
                if _nur_leer(_woerter(teil)) and any(_FRAGEWORT.match(x) for x in nachbarn):
                    treffer.append(satz.strip(" :–-")); break
    if _nur_leer(_woerter(_ohne_zitate(t))): treffer.append(t.strip())   # ganzes Feld nur „offen.“, „unklar“, „fehlt noch“
    return sorted(set(x for x in treffer if x))

FEHLWORT_FELDER = (1, 5, 6, 7)   # Ziel, Umsetzen, Prüfart, Zurück; in Bisher und Systemfrage ist „Ursache unbekannt“, „Quelle fehlt“ Auftrag
FRAGEN_MIN, FRAGEN_MAX = 3, 5

def _ohne_zitate(t):
    return ZITAT.sub("", t or "")

def prueffragen(text):
    """1879: Zahl der Prüffragen in Feld 6 (Fragezeichen außerhalb wörtlicher Zitate)."""
    return _ohne_zitate(_feld(text, 6, FELDER[5]) or "").count("?")

def inhalt_fehler(text):
    """1879: Fehler im Inhalt (Platzhalter, Fehl- und Fragewörter, Zahl der Prüffragen)."""
    f = []
    for i, name in enumerate(FELDER, 1):
        t = _feld(text, i, name)
        if not t or re.fullmatch(r"<[^>]*>|[-–—]?|…", t): continue   # fehlt oder leer: meldet pruefen schon
        p = sorted(set(m.group(0) for m in PLATZHALTER.finditer(_ohne_zitate(re.sub(r"`[^`]*/[^`]*`", "", t)))))
        if p: f.append("Feld %d „%s“ hat Platzhalter %s" % (i, name, ", ".join(p)))
        if i in FEHLWORT_FELDER:
            w = fehlwoerter(t)
            if w: f.append("Feld %d „%s“ sagt, dass etwas fehlt (%s): erst klären („Frage“), dann den Auftrag schreiben" % (i, name, ", ".join(w)))
        if i in (1, 7) and "?" in _ohne_zitate(t): f.append("Feld %d „%s“ ist eine Frage, keine Angabe" % (i, name))
    if _feld(text, 6, FELDER[5]):
        n = prueffragen(text)
        if not FRAGEN_MIN <= n <= FRAGEN_MAX:
            f.append("Feld 6 hat %d Prüffragen, verlangt %d bis %d Ja-Nein-Fragen (Kern Arbeitsplaner)" % (n, FRAGEN_MIN, FRAGEN_MAX))
    return f

def groesse(text):
    """1878: (Byte ohne die wörtlichen Zitate in Feld 3, Byte dieser Zitate)."""
    gesamt = len(text.encode("utf-8"))
    bis = _feld(text, 3, FELDER[2]) or ""
    z = sum(len(m.group(0).encode("utf-8")) for m in ZITAT.finditer(bis))
    return gesamt - z, z

def pruefen(text):
    """Liste der Fehler (leer = gut)."""
    f = []
    n, z = groesse(text)
    if n > GRENZE: f.append("%d Byte ohne Zitate unter „Bisher“, höchstens %d (Bauliste 7.1 „etwa 2 KB“)" % (n, GRENZE))
    if z > GRENZE_ZITATE: f.append("Zitate unter „Bisher“ %d Byte, höchstens %d (1878); ältere Neins als Verweis auf docs/vorgang/NR.md" % (z, GRENZE_ZITATE))
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
    return f + inhalt_fehler(text)

def eintragen(nr, text, treffer=None, wieder=False):
    """treffer: Zeile „Lehren-Treffer (Zeit): …“ (1739 Lehrenbuch), steht im selben Commit unter dem Auftrag.
    wieder (1798, 1899): Rückläufer zu archivierter Nummer; Zeile aus dem Archiv zurück in die Liste im selben Commit, gepusht
    (vorher nur lokal: auf origin/main blieb der Rückläufer im Archiv, scheiterte der Auftrag, blieb die Liste lokal geändert)."""
    zeit = ue.fmt(ue.jetzt())
    abschnitt = "## Auftrag (%s)\n\n%s\n%s\n" % (zeit, text.strip(), ("\n" + treffer + "\n") if treffer else "")
    pv = ue._pfad(nr)
    if not wieder:
        return ue.atomar(nr, lambda alt: (oben(alt, nr, abschnitt), zeit), "%s: Auftrag (%s, vorgang.py auftrag)" % (nr, zeit))
    import startbar, vorgang
    pl, pa = "docs/" + startbar.LISTE, "docs/" + vorgang.ARCHIV
    def aendern(alt):
        neu = {pv: oben(alt[pv], nr, abschnitt)}
        if any(d["nr"] == nr for d in startbar.vorgangsliste(alt[pl])): return neu, zeit  # schon wieder offen (anderer Schreiber)
        w = vorgang.wieder_texte(nr, alt[pl], alt[pa])
        if not w: raise ue.Fehler("%s auf origin/main weder in der Liste noch im Archiv" % nr)
        neu[pl], neu[pa] = w[0], w[1]
        print("vorgang.py: %s aus dem Archiv wieder offen (startbar, %s; gepusht)" % (nr, w[2]))
        return neu, zeit
    z = ue.atomar_dateien([pv, pl, pa], aendern, "%s: Auftrag (%s, vorgang.py auftrag), aus dem Archiv wieder offen (1798, 1899)" % (nr, zeit))
    startbar.neu_laden()
    return z

def oben(alt, nr, abschnitt):
    """1798 (Kern Arbeitsplaner: „oben in die Vorgangsdatei“): Abschnitt nach Kopfzeile und Vorspann, vor dem ersten „## “."""
    if not alt: return "# Vorgang %s\n\n%s" % (nr, abschnitt)
    m = re.search(r"(?m)^## ", alt)
    if not m: return alt + ("\n" if not alt.endswith("\n\n") else "") + abschnitt
    return alt[:m.start()] + abschnitt + "\n" + alt[m.start():]

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

def haupt(a, fertig=None, wieder=None):
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
        text = None
        if datei is not None:
            text = sys.stdin.read() if datei == "-" else open(datei, encoding="utf-8").read()
            f = pruefen(text)
            if f:
                print("vorgang.py auftrag %s hält an:\n- " % nr + "\n- ".join(f)); sys.exit(1)
            if nur: print("vorgang.py auftrag %s: gültig (%d Byte, davon Zitate unter „Bisher“ %d)" % ((nr, len(text.encode("utf-8"))) + groesse(text)[1:])); return
            zurueck = titel is None and wieder is not None
            if zurueck: titel = wieder(nr)  # 1798: Rückläufer zu archivierter Nummer, Vorgang wird wieder offen (Liste und Archiv in eintragen, 1899)
        if titel is None: sys.exit("vorgang.py auftrag: %s steht nicht in der Vorgangsliste und nicht im Archiv" % nr)
        import lehren
        liste, treffer = lehren.treffer_zeile(nr, titel)
        if datei is None:
            print(vorlage(nr, titel), end="")
            print("\nLehren des Bereichs (Lehrenbuch, 1739; passende in „Beachte“ und „Umsetzen“, höchstens fünf, weitere als Nummer):")
            print("\n".join("- " + lehren.zeigen(x) for x in liste) if liste else "- keine")
            return
        try: zeit = eintragen(nr, text, treffer, wieder=zurueck and titel is not None)
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
