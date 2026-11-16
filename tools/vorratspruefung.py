#!/usr/bin/env python3
"""1425 (Chef 16.11., 13:44): „einmal den Arbeitsvorrat so richtig auf links drehen und alle Fehler ausmerzen … einmal täglich,
bevor du den Managementbericht machst.“ Perikles ruft es vor dem Tagesbericht (ROLLE-PROJEKT.md, Tagesbericht).

Eine Sicht auf alle klassischen Fehler der Vorgangsliste, je Fund Besitzer und was zu tun ist:
  A Form          Formfehler der Zeile (startbar.pruefen_liste)
  B Zirkel        Zeilen warten über „wartet auf“ im Kreis aufeinander
  C Chef falsch   wartet auf den Chef ohne Datei in der Chefsache; „zu testen“ mit schon getestetem Build
  D Rolle stumm   wartet auf eine Rolle, in deren Plan die Zeile nicht steht, oder auf Ford (löst nie)
  E Muss auf Kür  Muss wartet auf eine Zeile, die ruht, Idee, nach dem Meilenstein oder Kür ist
  F nicht gelöst  Feld „wartet auf“ ist erfüllt, Zeile noch gesperrt (Automatik A nicht gelaufen)
  G Leiche        hängt ohne Grund (startbar.haengt), Unternummern alle erledigt, ohne Bewegung seit 7 Tagen
  H Nummer fremd  wartet auf eine Nummer, die es nirgends gibt
  I Chefsache     Datei beim Chef, deren Vorgang erledigt ist oder fehlt (älter als 48 h)
  J Vorrat        „Zu <Nr>“ im Vorrat, deren Vorgänge alle erledigt sind
  K Urteil        Urteil des Chefs der letzten 48 h (Vorgangsarchiv) nennt eine Nummer ohne Zeile, oder die Zeile steht noch auf „Chef“
                  (ersetzt mit G die Leichenprüfung 1192 von Diogenes)
  L doppelt       zwei offene Zeilen mit fast gleichen Titelwörtern (nur Hinweis, Sinn prüft Perikles von Hand)
  M „jetzt“       Muss mit „jetzt“ im Titel, älter als 48 h und weder in Arbeit noch gebaut
  N Zweig         Zweig der Zeile fehlt auf GitHub, oder steckt schon ganz in main, Zeile aber offen und nicht gebaut
  O Unternummer   offene Unternummer, deren Oberzeile erledigt ist und die keiner Zeile mehr zugeordnet ist
  P Titel         Titel oder Stand sagt „entfällt“, „überholt“, „doppelt“, „erledigt“, Zeile aber offen
Nur lesen; Exit 0. `--kurz`: je Art die Zahl. `--streichen [--probe]`: J-Absätze ohne Künftiges aus den Vorräten nehmen
(Chef 16.11., 14:01).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar as S

ARTEN = {"A": "Form", "B": "Zirkel", "C": "Chef falsch", "D": "Rolle weiß nichts", "E": "Muss wartet auf Kür oder Ruhendes",
         "F": "erfüllt, nicht gelöst", "G": "Leiche", "H": "Nummer unbekannt", "I": "Chefsache ohne offenen Vorgang",
         "J": "Vorrat mit Erledigtem", "K": "Chefurteil nicht nachgezogen", "L": "wohl doppelt (von Hand prüfen)",
         "M": "„jetzt“ liegt", "N": "Zweig kaputt", "O": "Unternummer verwaist", "P": "Titel sagt fertig"}
VORRAETE = {"Tom": "ARBEIT-TEAM-TOM.md", "Jerry": "ARBEIT-TEAM-JERRY.md", "Spike": "ARBEIT-TEAM-SPIKE.md", "Homer": "ARBEIT-KREATIV.md",
            "Perikles": "ARBEIT-PROJEKT.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Sokrates": "ARBEIT-BERATUNG.md"}
RUHEND = ("ruht", "Idee", "nach Meilenstein", "aufgeteilt")



def funde():
    zs = [d for d in S.zeilen_liste() if d["wort"] != "erledigt"]
    nach = {d["nr"]: d for d in zs}
    aus = []  # (Art, Nr, Besitzer, Text)

    for nr, f in S.pruefen_liste():
        aus.append(("A", nr, nach.get(nr, {}).get("besitzer", "?"), f))

    # B Zirkel: Tiefensuche über offene Nummern im Feld
    kanten = {d["nr"]: [t for t in d["warte"] if S.art(t) == "nr" and t in nach] for d in zs}
    gesehen = set()
    for start in kanten:
        weg, stapel = [], [(start, iter(kanten[start]))]
        auf = {start}; weg = [start]
        while stapel:
            knoten, it = stapel[-1]
            nxt = next(it, None)
            if nxt is None:
                stapel.pop(); auf.discard(weg.pop()); continue
            if nxt in auf:
                kreis = weg[weg.index(nxt):]
                k = frozenset(kreis)
                if k not in gesehen:
                    gesehen.add(k)
                    aus.append(("B", kreis[0], ", ".join(sorted({nach[n]["besitzer"] for n in kreis})), " → ".join(kreis + [nxt])))
                continue
            if len(weg) < 12:
                auf.add(nxt); weg.append(nxt); stapel.append((nxt, iter(kanten.get(nxt, []))))

    # J: „Zu <Nr>“ im Vorrat, deren Vorgänge alle erledigt sind (Leiche im Vorrat, kürzt der Besitzer beim Übergeben)
    for rolle, datei in VORRAETE.items():
        try: text = S.lesen(datei)
        except Exception: continue
        for m in re.finditer(r"(?m)^- \*\*Zu ((?:D?\d[\w.]*(?:, | und )?)+)", text):
            nrn = [x for x in re.split(r", | und ", m.group(1).strip(" ,")) if re.match(r"D?\d", x)]
            absatz = text[m.start():text.find("\n- **", m.end()) if text.find("\n- **", m.end()) > 0 else len(text)]
            if re.search(r"nach Erledigt|noch zu (prüfen|zählen)", absatz) or any(
                    S.jahr_von(int(t), int(mo)) >= S.JETZT.date() for t, mo in re.findall(r"(?<![\d.])(\d\d?)\.(\d\d?)\.(?!\d)", absatz)
                    if 1 <= int(mo) <= 12 and 1 <= int(t) <= 31):
                continue  # Prüfauftrag nach dem Erledigt oder Termin heute und später: lebt noch
            if nrn and not any(x in nach for x in nrn) and all(S.stand_von(x)[0] for x in nrn):
                aus.append(("J", nrn[0], rolle, "%s: „Zu %s“, Vorgang erledigt (beim Übergeben streichen)" % (datei, ", ".join(nrn))))
    getestet = {d["nr"] for d in S.test_vorbei(zs)}
    arch = S.lesen("VORGANGSARCHIV.md")
    # I: Datei in der Chefsache, deren Vorgang erledigt ist oder fehlt (Leiche beim Chef)
    for ordner in S.CHEF_ORDNER:
        pfad = os.path.join(S.DOCS, "chefsache", ordner)
        if not os.path.isdir(pfad): continue
        for f in sorted(os.listdir(pfad)):
            m = re.match(r"(D?\d+[a-z]?)", f)
            if not f.endswith(".md") or not m or re.match(r"t\d+-", f): continue
            n = m.group(1)
            if n in nach or any(k.replace(".", "") == n or k.replace(".", "").startswith(n) and n[-1].isalpha() for k in nach): continue
            if re.sub(r"[a-z]$", "", n) in nach: continue
            alter = S._git("log", "-1", "--format=%ct", "--", os.path.join(pfad, f)).stdout.strip()
            if alter and (S.JETZT.timestamp() - int(alter)) < 48 * 3600: continue  # frisch: Antwort des Chefs steht noch aus
            aus.append(("I", n, "?", "chefsache/%s/%s: keine offene Zeile %s mehr (beantwortet heißt weg)" % (ordner, f, n)))
    for d in zs:
        nr, bes = d["nr"], d["besitzer"]
        if d["besitzer"] == "Ideen" or nr in S.SONDER: continue
        # C
        for t in d["warte"]:
            if S.art(t) == "chef" and S.erfuellt(t, nr):
                aus.append(("C", nr, bes, "wartet auf „%s“, aber keine Datei in der Chefsache" % t))
        if d["wort"] == "Chef" and not any(S.art(t) == "chef" for t in d["warte"]):
            aus.append(("C", nr, bes, "Stand „Chef“ ohne Chefsache-Datei im Feld"))
        if nr in getestet:
            aus.append(("C", nr, bes, "Build %s ist getestet, Zeile steht noch auf „%s“ (`vorgang.py build %s`)" % (d["build"], d["wort"], d["build"])))
        b = str(d.get("build") or "").strip()
        if d["wort"] == "zu testen" and b.isdigit() and not S.build_im_archiv(b, arch) and not any(
                f.startswith("t%s-" % b) for o in ("chefsache/ansehen", "entwurf") if os.path.isdir(os.path.join(S.DOCS, o))
                for f in os.listdir(os.path.join(S.DOCS, o))):
            aus.append(("C", nr, bes, "zu testen in Build %s, aber keine Prüfliste t%s in der Chefsache: der Chef wird nie gefragt" % (b, b)))
        # D
        for t in S.offen_warte(d):
            if S.art(t) != "rolle": continue
            try: sichtbar = any(x[0] == nr for x in S.plan(t))
            except Exception: sichtbar = True
            if not sichtbar:
                aus.append(("D", nr, bes, "wartet auf %s; im Plan von %s steht die Zeile nicht (Vorgang bei %s anlegen oder Feld leeren)" % (t, t, t)))
            elif t == "Ford":
                aus.append(("D", nr, bes, "wartet auf Ford; Ford baut nichts und löst das Feld nie (Ereignis als Datum oder Nummer eintragen)"))
        # E, H
        for t in S.offen_warte(d):
            if S.art(t) != "nr": continue
            z = nach.get(t)
            if z is None:
                n, st = S.stand_von(t)
                if n is None: aus.append(("H", nr, bes, "wartet auf %s, die es weder in Liste noch Archiv gibt" % t))
                continue
            if d["kl"] == "M" and d["wort"] not in RUHEND and z["wort"] in RUHEND:
                aus.append(("E", nr, bes, "Muss wartet auf %s (%s, %s, %s): Vorrang heben oder Feld lösen" % (t, z["besitzer"], z["kl"], z["wort"])))
        # F
        l = S.loesbar(d)
        if l and l[1]:
            aus.append(("F", nr, bes, "erfüllt: %s, steht noch auf „%s“" % (", ".join(l[2]), d["wort"])))
        # G
        try:
            if S.haengt(d): aus.append(("G", nr, bes, "hängt: %s" % (S.sperre(d) or "startbar ohne Start")))
        except Exception:
            pass
    # K: Chefurteile der letzten 48 h gegen die Zeilen
    try:
        for w, kopf, je in S.urteile(48):
            for n, ort, st in je:
                if ort == "ohne Zeile":
                    aus.append(("K", n, "?", "Urteil %s „%s“: keine Zeile %s (Folgeauftrag eingetragen?)" % (w.strftime("%d.%m., %H:%M"), kopf[:60], n)))
                elif ort.startswith("Liste") and S.wort_von(st) == "Chef":
                    aus.append(("K", n, ort[6:], "Urteil %s „%s“, Zeile steht noch auf „Chef“" % (w.strftime("%d.%m., %H:%M"), kopf[:60])))
    except Exception as e:
        aus.append(("K", "–", "–", "Urteilsprüfung übersprungen: %s" % e))
    # L: fast gleiche Titel (Kennwörter ab 5 Buchstaben, ohne Absender- und Füllwörter)
    weg = {"chef", "sokrates", "perikles", "diogenes", "jerry", "homer", "spike", "tuffy", "nicht", "statt", "werkzeug", "zeile",
           "zeilen", "vorgang", "build", "jetzt", "prüfen", "bitte", "wieder", "immer", "durch", "beim", "einen", "einer", "keine",
           "sollen", "alles", "neuen", "ohne", "zurück", "wiederholt"}
    def worte(d):
        t = re.sub(r"\([^)]*\)|·.*$", " ", d["titel"]).lower()
        return {x for x in re.findall(r"[a-zäöüß]{5,}", t) if x not in weg}
    offen = [d for d in zs if d["wort"] not in RUHEND and d["besitzer"] != "Ideen" and d["nr"] not in S.SONDER]
    ws = {d["nr"]: worte(d) for d in offen}
    for i, a in enumerate(offen):
        for b in offen[i + 1:]:
            x, y = ws[a["nr"]], ws[b["nr"]]
            if len(x) < 3 or len(y) < 3 or a["nr"].split(".")[0] == b["nr"].split(".")[0]: continue
            gemein = x & y
            if len(gemein) >= 3 and len(gemein) / min(len(x), len(y)) >= 0.6:
                aus.append(("L", a["nr"], a["besitzer"], "ähnlich %s (%s): %s" % (b["nr"], b["besitzer"], ", ".join(sorted(gemein)[:5]))))
    # M, N, O, P
    try:
        koepfe = {}
        for z in S._git("ls-remote", "--heads", "origin").stdout.splitlines():
            h, ref = z.split("\t"); koepfe[ref.replace("refs/heads/", "")] = h
    except Exception:
        koepfe = {}
    import datetime
    for d in zs:
        nr, bes = d["nr"], d["besitzer"]
        if bes == "Ideen" or nr in S.SONDER: continue
        m = re.search(r"„jetzt“ (\d\d?)\.(\d\d?)\.", d["titel"] + " " + d["stand"])
        if m and d["kl"] == "M" and d["wort"] in ("startbar", "offen", "wartet"):
            try:
                tag = S.jahr_von(int(m.group(1)), int(m.group(2)))
                if (S.JETZT.date() - tag).days >= 2:
                    aus.append(("M", nr, bes, "„jetzt“ seit %s, Stand „%s“%s" % (tag.strftime("%d.%m."), d["wort"], (", wartet auf " + ", ".join(d["warte"])) if d["warte"] else "")))
            except ValueError:
                pass
        zw = (d.get("zweig") or "").strip()
        if koepfe and zw.startswith("claude/") and d["wort"] in ("startbar", "offen", "in Arbeit", "wartet"):
            if zw not in koepfe:
                aus.append(("N", nr, bes, "Zweig %s gibt es auf GitHub nicht (mehr)" % zw))
            elif S._git("merge-base", "--is-ancestor", koepfe[zw], "origin/main").returncode == 0 and \
                    S._git("cat-file", "-e", koepfe[zw]).returncode == 0:
                aus.append(("N", nr, bes, "Zweig %s steckt ganz in main, Zeile steht auf „%s“" % (zw, d["wort"])))
        if "." in nr and d["wort"] not in RUHEND:
            ober = nr.rsplit(".", 1)[0]
            if ober not in nach and S.stand_von(ober)[0] == ober and not d["warte"] and d["kl"] == "K" and d["wort"] == "startbar":
                aus.append(("O", nr, bes, "Oberzeile %s erledigt, Unternummer als startbare Kür übrig (noch gebraucht?)" % ober))
        if re.search(r"\b(entfällt|überholt|doppelt zu|ist erledigt|schon erledigt|hinfällig)\b", d["titel"] + " " + d["zusatz"], re.I):
            aus.append(("P", nr, bes, "Text sagt „%s“, Zeile offen (%s)" % (re.search(r"\b(entfällt|überholt|doppelt zu|ist erledigt|schon erledigt|hinfällig)\b", d["titel"] + " " + d["zusatz"], re.I).group(1), d["wort"])))
    try:
        schon = {(a, n) for a, n, _, _ in aus}
        for bes, arten in S.leichen().items():
            for art_, nrn in arten.items():
                for n in nrn:
                    d = next((x for x in zs if x["nr"] == n), None)
                    if d and S.offen_warte(d): continue  # wartet noch auf etwas, das vorankommt
                    if ("G", n) not in schon: aus.append(("G", n, bes, art_))
    except Exception as e:
        aus.append(("G", "–", "–", "Leichenzählung übersprungen: %s" % e))
    return aus


LEBT = re.compile(r"\b(nächste[nr]?|künftig|weiterhin|bleibt|jeden|jede[rs]? (Woche|Tag|Montag)|montags|täglich|Stichtag|noch offen|offen mit|"
                  r"Rest|später|ab \d\d?\.\d\d?\.|gilt|dauerhaft)\b", re.I)


def streichen(f, probe=False):
    """1425 (Chef 16.11., 14:01: „warum können die da drin stehen, wenn sie doch erledigt sind? Da musst du die doch mal rausnehmen.“):
    J-Absätze streichen (Zeile „- **Zu …“ samt eingerückter Folgezeilen); Absätze mit Hinweis auf Künftiges (LEBT) bleiben und
    werden genannt. Text bleibt in Git. Gibt (gestrichen, behalten) zurück."""
    weg, bleibt = {}, []
    for a, nr, rolle, t in f:
        if a != "J": continue
        datei = t.split(":")[0]
        weg.setdefault(datei, set()).add(nr)
    zahl = 0
    for datei, nrn in weg.items():
        pfad = os.path.join(S.DOCS, datei)
        L = open(pfad, encoding="utf-8").read().split("\n")
        aus, i = [], 0
        while i < len(L):
            m = re.match(r"- \*\*Zu ((?:D?\d[\w.]*(?:, | und )?)+)", L[i])
            if m:
                ende = i + 1
                while ende < len(L) and L[ende].startswith("  "): ende += 1
                erste = re.split(r", | und ", m.group(1).strip(" ,"))[0]
                absatz = "\n".join(L[i:ende])
                if erste in nrn:
                    if LEBT.search(absatz): bleibt.append("%s: Zu %s" % (datei, erste))
                    else:
                        zahl += 1; i = ende; continue
            aus.append(L[i]); i += 1
        if not probe: open(pfad, "w", encoding="utf-8").write("\n".join(aus))
    return zahl, bleibt


def main():
    f = funde()
    if "--streichen" in sys.argv:
        n, b = streichen(f, probe="--probe" in sys.argv)
        print("gestrichen %d; behalten %d (Künftiges im Text, Besitzer entscheidet): %s" % (n, len(b), "; ".join(b)))
        return 0
    if "--kurz" in sys.argv:
        print("Vorratsprüfung (1425): %d Funde · " % len(f) + " · ".join("%s %s %d" % (k, v, sum(1 for x in f if x[0] == k)) for k, v in ARTEN.items()))
        return 0
    for k, v in ARTEN.items():
        teil = [x for x in f if x[0] == k]
        if not teil: continue
        print("\n%s %s (%d)" % (k, v, len(teil)))
        for _, nr, bes, t in sorted(teil, key=lambda x: (x[2], x[1])):
            print("  %-8s %-9s %s" % (nr, bes, t))
    print("\nZusammen %d Funde." % len(f))
    return 0


if __name__ == "__main__":
    sys.exit(main())
