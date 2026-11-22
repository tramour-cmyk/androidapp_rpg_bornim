#!/usr/bin/env python3
"""1804 (1727 Nachprüfung 2 Nr. 6, 12; Profil Disponent „Guthaben“): Guthabenstufe und Laufsperre aus Chefwort für lauf.py.

Guthabenstufe (287): ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand. Den Prozentwert kennt nur der Chef;
er nennt ihn Sokrates, Sokrates trägt ihn ein (Archiv 1727e). Ort: die Zeile „**Guthaben:**“ in docs/ARBEIT-BETRIEB.md, neuester
Wert vorn: „**Guthaben:** **Chef TT.MM., HH:MM (…):** „NN Prozent“ …“. Ein Wert vor dem letzten Zurücksetzen (Sa 19:59, RESET)
gilt nicht mehr: Stufe „unbekannt“, gestartet wird wie unter 80 %.

Laufsperre (Chefwort „weniger laufen“): Zeile im Vorgangsarchiv im Format der Ausnahme mit Deckel (nachtstarts.py, 1792):
„- **<Nr>, …** (TT.MM., HH:MM, Chef …) → **Laufsperre: höchstens <Zahl> Starts[, spätestens HH:MM]**“ (Zahl als Ziffer oder Wort,
„keine“ = 0). Umfang und Ende setzt Sokrates (Profil Disponent F15). Ab der Entscheidzeit zählen die Startsperren des Protokolls;
frei sind Wache, Sokrates (auch Rundblick) und Rückläufer des Chefs. Ohne „spätestens“ gilt sie STANDARD_STUNDEN und lauf.py warnt.
Ohne „Chef“ in der Klammer keine Laufsperre. 1930 (1727j Frage 8, Chef 22.11., 11:48): sagt der Chef „alles“, sperrt sie auch die
Rückläufer des Chefs; frei bleiben dann nur Wache und Sokrates (FREI_ROLLEN). 1934 (D371.1): das Werkzeug liest das nicht aus dem
Zitat („alles klar“ stand in 51 von 1184 Archivzitaten), sondern aus der Marke „, auch Rückläufer“ in der fetten Laufsperre nach dem
Pfeil, die Sokrates nur bei diesem Chefwort setzt: „→ **Laufsperre: höchstens zwei Starts, spätestens 18:00, auch Rückläufer**“.

Vorbild (erst nachsehen, wie andere es lösen): Budget-Aktionen in Cloud-Konten (Schwellen 80/100 % lösen gestufte Aktionen aus, bis
zum Sperren neuer Starts) und Ausgabegrenzen von CI-Diensten (bei 100 % keine neuen Läufe); beide werten einen Messwert nur in
seinem Abrechnungszeitraum.

  guthaben.py            Stufe und Laufsperre jetzt (Prüfen von Hand)
"""
import datetime, os, re, sys, zoneinfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nachtstarts

BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
RESET = (5, 19, 59)  # Sa 19:59 Berliner Zeit (ARBEIT-BETRIEB.md „Guthaben“: „Reset Sa 19:59“)
STUFEN = ((100, "Stillstand"), (95, "nur Rückläufer"), (80, "nur Muss"))
FREI_ROLLEN = {"Sokrates", "Rundblick", "Ideenlauf", "Wache", "Ford"}  # 1907: Ideenlauf ist Sokrates
STANDARD_STUNDEN = 24
ZAHLWORT = dict(nachtstarts.ZAHLWORT, keine=0, null=0, keinen=0)


def letzter_reset(jetzt):
    t = jetzt.replace(hour=RESET[1], minute=RESET[2], second=0, microsecond=0) - datetime.timedelta(days=(jetzt.weekday() - RESET[0]) % 7)
    return t if t <= jetzt else t - datetime.timedelta(days=7)


def wert(betrieb, jetzt):
    """(Prozent, Zeit) des neuesten Werts in der Zeile „**Guthaben:**“, oder None (keine Zeile, kein Wert, vor dem Zurücksetzen)."""
    z = next((l for l in betrieb.splitlines() if l.startswith("**Guthaben:**")), "")
    m = re.search(r"Chef (\d\d)\.(\d\d)\., (\d\d):(\d\d)\b[^„]*?„(\d{1,3})(?:,\d+)? ?(?:Prozent|%)", z)
    if not m: return None
    try:
        t = datetime.datetime(jetzt.year, int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4)), tzinfo=jetzt.tzinfo)
    except ValueError:
        return None
    if t > jetzt + datetime.timedelta(days=1): t = t.replace(year=t.year - 1)  # Jahreswechsel
    if t < letzter_reset(jetzt): return None
    return int(m.group(5)), t


def stufe(betrieb, jetzt):
    """(Stufe, Prozent, Zeit): Stufe „frei“, „nur Muss“, „nur Rückläufer“, „Stillstand“ oder „unbekannt“."""
    w = wert(betrieb, jetzt)
    if not w: return "unbekannt", None, None
    for g, name in STUFEN:
        if w[0] >= g: return name, w[0], w[1]
    return "frei", w[0], w[1]


def laufsperren(archiv, jahr):
    aus = []
    for l in archiv.splitlines():
        if "Laufsperre" not in l: continue
        k = re.search(r"\((\d\d)\.(\d\d)\., (\d\d):(\d\d), Chef\b", l)
        m = re.search(r"Laufsperre:? höchstens (\w+) (?:weitere )?Starts?(?:, spätestens (\d\d):(\d\d))?", l)
        if not k or not m: continue
        z = m.group(1).lower()
        deckel = int(z) if z.isdigit() else ZAHLWORT.get(z)
        if deckel is None: continue
        try:
            ab = datetime.datetime(jahr, int(k.group(2)), int(k.group(1)), int(k.group(3)), int(k.group(4)), tzinfo=BERLIN)
        except ValueError:
            continue
        if m.group(2):
            bis = ab.replace(hour=int(m.group(2)), minute=int(m.group(3)))
            if bis <= ab: bis += datetime.timedelta(days=1)
        else:
            bis = ab + datetime.timedelta(hours=STANDARD_STUNDEN)
        q = re.match(r"- \*\*([^,*]+)", l)
        aus.append(dict(deckel=deckel, ab=ab, bis=bis, ende=bool(m.group(2)), quelle=q.group(1) if q else "?", alles=alles(l)))
    return aus


def alles(zeile):
    """1930/1934: Marke „auch Rückläufer“ in der fetten Laufsperre nach dem Pfeil (setzt Sokrates nur beim Chefwort „alles“);
    ein „alles“ im Zitat allein („alles klar“) sperrt nichts."""
    nach = zeile.split("→", 1)[1] if "→" in zeile else ""
    m = re.search(r"\*\*Laufsperre:?[^*]*\*\*", nach)
    return bool(m and re.search(r",\s*auch Rückläufer\b", m.group(0)))


def laufsperre(jetzt, archiv=None):
    """Geltende Laufsperre (die jüngste) oder None."""
    g = [a for a in laufsperren(nachtstarts.archiv() if archiv is None else archiv, jetzt.year) if a["ab"] <= jetzt <= a["bis"]]
    return max(g, key=lambda a: a["ab"]) if g else None


def gezaehlt(sperre, jetzt, protokoll=None, rueck=lambda nr: False):
    """Starts seit Beginn der Laufsperre, ohne freie Rollen und ohne Rückläufer des Chefs (Zuordnung „<Rolle> <Nr>“ in der Klammer)."""
    p = protokoll if protokoll is not None else nachtstarts.zeilen(sperre["ab"])
    n = 0; gesehen = set()
    for l in p:
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)(.*)", l)
        if not m: continue
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        try:
            t = jetzt.replace(day=int(k.group(1)), month=int(k.group(2))) if k else jetzt
            t = t.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        except ValueError:
            continue
        if t < sperre["ab"] or t > jetzt + datetime.timedelta(minutes=5) or (t, m.group(3)) in gesehen: continue
        gesehen.add((t, m.group(3)))
        nr_je = dict(re.findall(r"\b(\w+) (\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)\b", m.group(4)))
        for r in m.group(3).split(", "):
            if r in FREI_ROLLEN or (not sperre.get("alles") and r in nr_je and rueck(nr_je[r])): continue
            n += 1
    return n


def ruecklaeufer(d):
    """Rückläufer des Chefs: Marke „zurück t<n>“ im Titel (827 A), „Rückläufer“ im Stand, „wiederholt“ (620.1 A) oder Fund des Chefs."""
    if not isinstance(d, dict): return False
    t = d.get("titel", ""); s = d.get("stand", "")
    return bool(re.search(r"zurück t\d", t) or "Rückläufer" in s or re.search(r"\bwiederholt\b", t, re.I)
                or re.search(r"Von Chef \([^)]*\bFund\b", t))


class Bremse:
    """Ein Lauf von lauf.py: erlaubt(rolle, nr, kl, zeile) → None oder Grund; zaehle() nach jedem START/WEITER."""

    def __init__(self, jetzt, betrieb, archiv=None, protokoll=None, rueck=lambda nr: False):
        self.stufe, self.prozent, self.zeit = stufe(betrieb, jetzt)
        self.sperre = laufsperre(jetzt, archiv)
        self.rest = None
        if self.sperre:
            self.rest = self.sperre["deckel"] - gezaehlt(self.sperre, jetzt, protokoll, rueck)

    def zeilen(self):
        aus = []
        if self.stufe == "unbekannt":
            aus.append("GUTHABEN unbekannt seit dem Zurücksetzen (Sa 19:59): Stufe wie unter 80 %; den Wert nennt der Chef Sokrates (1727e, 287)")
        else:
            aus.append("GUTHABEN %d %% (Chef %s): Stufe %s (287)" % (self.prozent, self.zeit.strftime("%d.%m., %H:%M"), self.stufe))
        if self.sperre:
            s = self.sperre
            aus.append("LAUFSPERRE %s (Chef %s): noch %d von %d Starts bis %s; frei: %s%s" % (
                s["quelle"], s["ab"].strftime("%d.%m., %H:%M"), max(self.rest, 0), s["deckel"], s["bis"].strftime("%d.%m., %H:%M"), self.frei_text(),
                "" if s["ende"] else "; WARNUNG Ende fehlt, gilt %d h, Sokrates setzt „spätestens HH:MM“" % STANDARD_STUNDEN))
        return aus

    def frei_text(self):
        return "Wache, Sokrates (Chef „alles“: auch Rückläufer gesperrt, 1930)" if self.sperre and self.sperre.get("alles") else "Wache, Sokrates, Rückläufer des Chefs"

    def rueck_frei(self, zeile):
        """Rückläufer des Chefs zählt nicht und läuft weiter, außer die Laufsperre trägt das Chefwort „alles“ (1930)."""
        return ruecklaeufer(zeile) and not (self.sperre and self.sperre.get("alles"))

    def nur_muss(self):
        return self.stufe in ("nur Muss", "nur Rückläufer", "Stillstand")

    def erlaubt(self, rolle, kl, zeile):
        """None = Start erlaubt, sonst Grund für „NICHTS <Rolle>: …“."""
        frei = rolle in FREI_ROLLEN
        rueck = ruecklaeufer(zeile)
        if self.stufe == "Stillstand":
            return "Guthaben %d %%, Stillstand (287)" % self.prozent
        if self.stufe == "nur Rückläufer" and not rueck:
            return "Guthaben %d %%, nur Rückläufer des Chefs (287)" % self.prozent
        if self.stufe == "nur Muss" and kl != "M" and not rueck:
            return "Guthaben %d %%, nur Muss (287)" % self.prozent
        if self.sperre and not frei and not self.rueck_frei(zeile) and self.rest <= 0:
            return "Laufsperre %s, alle %d Starts verbraucht, bis %s nur %s" % (
                self.sperre["quelle"], self.sperre["deckel"], self.sperre["bis"].strftime("%d.%m., %H:%M"), self.frei_text())
        return None

    def zaehle(self, rolle, zeile):
        if self.sperre and rolle not in FREI_ROLLEN and not self.rueck_frei(zeile): self.rest -= 1


if __name__ == "__main__":
    j = datetime.datetime.now(BERLIN)
    d = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "ARBEIT-BETRIEB.md")
    print("\n".join(Bremse(j, open(d, encoding="utf-8").read()).zeilen()))
