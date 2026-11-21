#!/usr/bin/env python3
"""Lehrenbuch `docs/LISTE-LEHREN.md` (1739; 1727, Archiv „Lehrenbuch“ 21.11., 14:19; Form und Rollen `1727-muster/fehlerbuch.md`,
Tabelle „Wer sucht, gibt vor, trägt ein“). Nie geladen, nur durchsucht; geschrieben nur über dieses Werkzeug.

  vorgang.py lehre suche WORT …            freie Suche (Fachkraft, nur bei einer Frage, die der Auftrag nicht beantwortet)
  vorgang.py lehre bereich NR              Lehren des Bereichs von NR, Rangfolge nach Stichworten im Titel (wie bei `auftrag`)
  vorgang.py lehre roh NR "Anlass" "Ursache und Satz"
                                           rohe Zeile anhängen (sonst das Werkzeug selbst: Rückmeldung „ja“ mit „Ursache:“,
                                           zweites „nein“, Schließen)
  vorgang.py lehre zuordnen R<n> L<n>      rohe Zeile an eine Lehre hängen; Wirkung: stand L<n> unter den Treffern des Falls
                                           → „wirkt nein“, sonst bei gleichem Bereich „nicht gefunden“; beides als Zeile an Sokrates
  vorgang.py lehre zuordnen R<n> --neu "Stichworte" "Lehre"     als neue Lehre fassen („erst …, dann …“ / „nie X, stattdessen Y“)
  vorgang.py lehre zuordnen R<n> --keine "Grund"                „keine Lehre: Einzelfall, weil …“

`vorgang.py auftrag NR` gibt die Lehren des Bereichs unter der Vorlage aus; beim Eintragen des Auftrags schreibt das Werkzeug
die Treffernummern als Zeile „Lehren-Treffer (Zeit): L1, L4, R2“ in docs/vorgang/NR.md (Pflichtsuche, Tabelle Zeile 1 und 2).
Schreiben wie beim Zähler: Push nur auf den gelesenen Stand von origin/main, sonst neu lesen (uebergabe.atomar).
Muster (erst nachsehen, wie andere es lösen): Postmortem-Datenbank mit Stichwortsuche und Wirkungskontrolle (Google SRE,
„Postmortem Culture“: Aktionspunkte je Vorfall, Wiederholer zeigen, ob die Maßnahme griff).
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

PFAD = "docs/LISTE-LEHREN.md"
KOPF_L = "| L | Bereich | Stichworte | Fälle | Ursache | Lehre | bewährt / wirkt nein |\n|---|---|---|---|---|---|---|\n"
KOPF_R = "| R | Bereich | Fall | Anlass | Ursache und Satz | seit | Zustand |\n|---|---|---|---|---|---|---|\n"
LEER = ("# Lehrenbuch (1727, Archiv „Lehrenbuch“ 21.11., 14:19)\n\n"
        "Nie geladen, nur durchsucht (`vorgang.py lehre suche <Wort>`); schreiben nur mit `vorgang.py lehre …` (`tools/lehren.py`). "
        "Form und wer sucht, vorgibt, einträgt: `docs/entwurf/1727-muster/fehlerbuch.md`.\n\n"
        "## Lehren\n\n" + KOPF_L + "\n## Roh\n\n" + KOPF_R)
ZL = re.compile(r"^\| (?P<id>L\d+) \| (?P<bereich>[^|]*?) \| (?P<stich>[^|]*?) \| (?P<faelle>[^|]*?) \| (?P<ursache>[^|]*?) \| (?P<lehre>[^|]*?) \| (?P<wirkung>[^|]*?) \|$", re.M)
ZR = re.compile(r"^\| (?P<id>R\d+) \| (?P<bereich>[^|]*?) \| (?P<fall>[^|]*?) \| (?P<anlass>[^|]*?) \| (?P<text>[^|]*?) \| (?P<seit>[^|]*?) \| (?P<zustand>[^|]*?) \|$", re.M)
TREFFER = re.compile(r"(?m)^Lehren-Treffer \([^)]*\): (.*)$")
SOKRATES = "Sokrates"


def lehren(text): return [m.groupdict() for m in ZL.finditer(text)]
def rohe(text): return [m.groupdict() for m in ZR.finditer(text)]


def lesen():
    p = os.path.join(ue.WURZEL, PFAD)
    return open(p, encoding="utf-8").read() if os.path.exists(p) else LEER


def _zeile(nr):
    try:
        import startbar
        for d in startbar.zeilen_liste():
            if d["nr"] == nr: return d
        for d in startbar.tafel_zeilen(open(os.path.join(ue.WURZEL, "docs", "LISTE-VORGAENGE-ARCHIV.md"), encoding="utf-8").read()):
            if d.get("nr") == nr: return d
    except Exception:
        pass
    return None


def bereich_von(nr):
    d = _zeile(nr)
    return (d or {}).get("bereich", "").strip() or "?"


def _worte(s): return {w for w in re.findall(r"[a-zäöüß]{4,}", (s or "").lower())}


def rangfolge(bereich, titel, text=None):
    """Alle Lehren und offenen rohen Zeilen des Bereichs (gleicher Teilbereich), Rangfolge nach Stichworten im Titel (Pflichtsuche)."""
    text = lesen() if text is None else text
    tw = _worte(titel)
    def treffer(stich): return len(_worte(stich) & tw) + sum(1 for w in _worte(stich) for t in tw if w != t and (w in t or t in w))
    l = [x for x in lehren(text) if x["bereich"] == bereich]
    r = [x for x in rohe(text) if x["bereich"] == bereich and x["zustand"] == "offen"]
    l.sort(key=lambda x: (-treffer(x["stich"]), int(x["id"][1:])))
    r.sort(key=lambda x: (-treffer(x["text"] + " " + x["anlass"]), int(x["id"][1:])))
    return l + r


def zeigen(x):
    if x["id"].startswith("L"):
        return "%s [%s] %s: %s (Fälle %s; Ursache %s; %s)" % (x["id"], x["bereich"], x["stich"], x["lehre"], x["faelle"], x["ursache"], x["wirkung"])
    return "%s [%s] roh, Fall %s, %s: %s (seit %s)" % (x["id"], x["bereich"], x["fall"], x["anlass"], x["text"], x["seit"])


def suche(worte, text=None):
    text = lesen() if text is None else text
    ws = [w.lower() for w in worte]
    alle = lehren(text) + rohe(text)
    return [x for x in alle if all(w in " ".join(x.values()).lower() for w in ws)]


def _neue_id(text, art):
    zs = [int(x["id"][1:]) for x in (lehren(text) if art == "L" else rohe(text))]
    return "%s%d" % (art, max(zs, default=0) + 1)


def _einfuegen(text, abschnitt, zeile):
    """Zeile ans Ende der Tabelle unter „## ABSCHNITT“."""
    kopf = "\n## %s\n" % abschnitt
    a = text.index(kopf) + len(kopf)
    n = text.find("\n## ", a)
    n = len(text) if n < 0 else n
    return text[:n].rstrip("\n") + "\n" + zeile + "\n" + ("\n" + text[n:].lstrip("\n") if n < len(text) else "")


def roh(nr, anlass, satz):
    """Rohe Zeile anhängen (nichts geht verloren). Rückgabe R-Kennung; dieselbe offene Zeile (Fall, Anlass, Satz) nur einmal."""
    bereich, zeit = bereich_von(nr), ue.fmt(ue.jetzt())
    def f(alt):
        t = alt or LEER
        for x in rohe(t):
            if (x["fall"], x["anlass"], x["text"]) == (nr, ue._rein(anlass), ue._rein(satz)): return alt, x["id"]
        k = _neue_id(t, "R")
        return _einfuegen(t, "Roh", "| %s | %s | %s | %s | %s | %s | offen |" % (k, bereich, nr, ue._rein(anlass), ue._rein(satz), zeit)), k
    return ue.atomar(nr, f, "Lehrenbuch: roh %s (%s, 1739)" % (nr, ue._rein(anlass)[:60]), pfad=PFAD)


def treffer_von(nr):
    """Treffernummern aller Aufträge des Falls (Zeilen „Lehren-Treffer“ in docs/vorgang/NR.md)."""
    p = os.path.join(ue.WURZEL, ue._pfad(nr))
    if not os.path.exists(p): return set()
    return {k.strip() for m in TREFFER.finditer(open(p, encoding="utf-8").read()) for k in m.group(1).split(",") if k.strip()}


def wirkung(lid, l_bereich, fall, fall_bereich, treffer):
    """„wirkt nein“: die Lehre stand im Auftrag des Falls; „nicht gefunden“: stand nicht drin, obwohl gleicher Bereich; sonst None."""
    if lid in treffer: return "wirkt nein"
    if l_bereich == fall_bereich: return "nicht gefunden"
    return None


def zuordnen(rid, lid=None, neu=None, keine=None):
    """Rückgabe (Text für die Ausgabe, Wirkung oder None, Fall)."""
    zeit = ue.fmt(ue.jetzt())
    erg = {}
    def f(alt):
        t = alt or LEER
        r = [x for x in rohe(t) if x["id"] == rid]
        if not r: raise ue.Fehler("%s steht nicht im Lehrenbuch" % rid)
        r = r[0]
        if r["zustand"] != "offen": raise ue.Fehler("%s ist schon zugeordnet (%s)" % (rid, r["zustand"]))
        erg["fall"] = r["fall"]
        if keine:
            zustand = "keine Lehre: " + ue._rein(keine)
        elif neu:
            stich, satz = neu
            k = _neue_id(t, "L")
            t = _einfuegen(t, "Lehren", "| %s | %s | %s | %s | %s | %s | – |" % (k, r["bereich"], ue._rein(stich), r["fall"], r["text"], ue._rein(satz)))
            zustand, erg["l"] = "→ " + k, k
        else:
            l = [x for x in lehren(t) if x["id"] == lid]
            if not l: raise ue.Fehler("%s steht nicht im Lehrenbuch" % lid)
            l = l[0]
            w = wirkung(lid, l["bereich"], r["fall"], r["bereich"], treffer_von(r["fall"]))
            erg["w"], erg["l"] = w, lid
            faelle = l["faelle"] if r["fall"] in [s.strip() for s in l["faelle"].split(",")] else (l["faelle"] + ", " + r["fall"]).strip(", ")
            wk = ("%s %s (%s)" % (w, zeit, r["fall"])) if w == "wirkt nein" else l["wirkung"]
            alt_z = "| %s | %s | %s | %s | %s | %s | %s |" % tuple(l[k] for k in ("id", "bereich", "stich", "faelle", "ursache", "lehre", "wirkung"))
            neu_z = "| %s | %s | %s | %s | %s | %s | %s |" % (l["id"], l["bereich"], l["stich"], faelle, l["ursache"], l["lehre"], wk)
            t = t.replace(alt_z, neu_z, 1)
            zustand = "→ " + lid
        alt_r = "| %s | %s | %s | %s | %s | %s | offen |" % tuple(r[k] for k in ("id", "bereich", "fall", "anlass", "text", "seit"))
        t = t.replace(alt_r, alt_r[:-len("| offen |")] + "| %s |" % zustand, 1)
        return t, None
    ue.atomar(rid, f, "Lehrenbuch: %s zugeordnet (1739)" % rid, pfad=PFAD)
    w, fall = erg.get("w"), erg.get("fall")
    if w:  # Meldung an Sokrates (Tabelle „Wirkung“, „Pflegen“)
        try: ue.uebergabe(fall, SOKRATES, "Lehrenbuch: %s %s beim Zuordnen von %s (Fall %s); pflegen (Bereich, Stichworte, Werkzeug statt Text)" % (erg["l"], w, rid, fall))
        except ue.Fehler as e: print("ZEILE an Sokrates nicht geschrieben (%s); von Hand: vorgang.py uebergabe %s Sokrates …" % (e, fall))
    return erg.get("l") or "keine Lehre", w, fall


def treffer_zeile(nr, titel=None):
    """Für `auftrag`: (Liste der Treffer, Zeile „Lehren-Treffer (Zeit): …“ oder None, wenn das Buch für den Bereich leer ist)."""
    d = _zeile(nr) or {}
    t = rangfolge(d.get("bereich", "").strip(), titel if titel is not None else d.get("titel", ""))
    if not t: return [], None
    return t, "Lehren-Treffer (%s): %s" % (ue.fmt(ue.jetzt()), ", ".join(x["id"] for x in t))


def roh_aus_rueckmeldung(nr, text, wer, datei_text, zahl_nein):
    """Tabelle „Roh sammeln“: „ja“ mit Feld „Ursache:“ in der Vorgangsdatei, zweites „nein“. Fehler bleiben still (Rückmeldung zählt)."""
    try:
        import rueckmeldung as rm
        w = rm.worte(text)
        if "ja" in w:
            m = re.findall(r"(?mi)^\W*Ursache:\**\s*(.+)$", datei_text)  # das letzte Feld „Ursache:“ gilt
            if m: return roh(nr, "ja mit Ursache (%s)" % wer, m[-1])
        if "nein" in w and zahl_nein == 2:
            return roh(nr, "zweites Nein (%s)" % wer, text)
    except ue.Fehler as e:
        print("LEHRENBUCH nicht geschrieben (%s); von Hand: vorgang.py lehre roh %s …" % (e, nr))
    return None


def haupt(a):
    a = list(a[1:]) if a[:1] == ["lehre"] else list(a)
    if not a: sys.exit(__doc__)
    b, rest = a[0], a[1:]
    try:
        if b == "suche" and rest:
            for x in suche(rest): print(zeigen(x))
            return
        if b == "bereich" and len(rest) == 1:
            d = _zeile(rest[0])
            if not d: sys.exit("vorgang.py lehre bereich: %s steht nicht in der Vorgangsliste" % rest[0])
            for x in rangfolge(d.get("bereich", "").strip(), d.get("titel", "")): print(zeigen(x))
            return
        if b == "roh" and len(rest) == 3:
            print("LEHRENBUCH %s angehängt (%s, gepusht)" % (roh(*rest), PFAD)); return
        if b == "zuordnen" and len(rest) >= 2:
            rid = rest[0]
            if rest[1] == "--neu" and len(rest) == 4: l, w, _ = zuordnen(rid, neu=(rest[2], rest[3]))
            elif rest[1] == "--keine" and len(rest) == 3:
                if len(rest[2].split()) < 3: sys.exit("vorgang.py lehre zuordnen --keine: Grund mit mindestens drei Wörtern („Einzelfall, weil …“)")
                l, w, _ = zuordnen(rid, keine=rest[2])
            elif len(rest) == 2 and re.fullmatch(r"L\d+", rest[1]): l, w, _ = zuordnen(rid, lid=rest[1])
            else: sys.exit(__doc__)
            print("LEHRENBUCH %s → %s%s (gepusht)" % (rid, l, ("; %s, Zeile an Sokrates" % w) if w else "")); return
    except ue.Fehler as e:
        sys.exit("vorgang.py lehre: %s; nichts geschrieben" % e)
    sys.exit(__doc__)


if __name__ == "__main__":
    haupt(sys.argv[1:])
