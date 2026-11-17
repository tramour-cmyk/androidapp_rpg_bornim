#!/usr/bin/env python3
"""1548 (Chef 17.11., 11:15: „wie da unsere Zeiten waren, greifen unsere vorgerenderten Modelle noch … in die Managementfassung …
durchgeführte Runs und durchschnittliche Zeit, Max und Min“): abgeschlossene Läufe des APK-Baus (godot.yml, grün oder rot, ohne
abgebrochene) mit Dauer und ob die vorgerenderten Kaufmodelle (Kauf-Cache 854) griffen. Gegriffen = kein Modellbau-Schritt lief
länger als SCHWELLE Minuten (Held je Klasse, Leute, Kampfort, Modelle bauen); sonst baute der Lauf Modelle neu.

Aufruf: python3 tools/laufzeiten.py [--tage N]   Tabelle je Lauf und Zusammenfassung 24 h / N Tage (Standard 7)
Im Tagesbericht: kurz(stunden) liefert die Zeile (tagesbericht.py, Zeile „Builds“)."""
import datetime, json, sys, urllib.request

BASIS = "https://api.github.com/repos/tramour-cmyk/androidapp_rpg_bornim/actions/"
MODELLBAU = ("Held je Klasse", "Leute bauen", "Kampfort bauen", "Modelle bauen")
SCHWELLE = 3.0  # Minuten; ein Treffer überspringt den Schritt oder braucht Sekunden, ein Neubau 9–37 min (Läufe 530, 543, 544)

def holen(u):
    r = urllib.request.Request(BASIS + u, headers={"Accept": "application/vnd.github+json"})
    return json.load(urllib.request.urlopen(r, timeout=20))

def zeit(s): return datetime.datetime.fromisoformat(s.replace("Z", "+00:00"))

def minuten(a, b):
    try: return (zeit(b) - zeit(a)).total_seconds() / 60
    except Exception: return 0.0

def neubau(lauf_id):
    """Modellbau-Schritte über SCHWELLE Minuten (Name, Minuten); leer = vorgerenderte Modelle griffen."""
    aus = []
    for j in holen("runs/%d/jobs?per_page=100" % lauf_id).get("jobs", []):
        for s in j.get("steps", []):
            if s.get("started_at") and s.get("completed_at") and s["name"].startswith(MODELLBAU):
                m = minuten(s["started_at"], s["completed_at"])
                if m > SCHWELLE: aus.append((s["name"].split(" (")[0], m))
    return aus

def laeufe(tage=7):
    seit = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=tage)).strftime("%Y-%m-%dT%H:%M:%SZ")
    ls = []
    for seite in range(1, 11):
        teil = holen("workflows/godot.yml/runs?status=completed&per_page=100&page=%d&created=%%3E%%3D%s" % (seite, seit)).get("workflow_runs") or []
        ls += teil
        if len(teil) < 100: break
    aus = []
    for l in ls:
        if l.get("conclusion") not in ("success", "failure"): continue
        aus.append(dict(nr=l["run_number"], id=l["id"], beginn=l["run_started_at"], zweig=l.get("head_branch") or "", ergebnis=l["conclusion"],
                        min=minuten(l["run_started_at"], l["updated_at"]), neu=neubau(l["id"])))
    return aus

def zusammen(ls):
    if not ls: return "keine Läufe"
    m = [l["min"] for l in ls]; treffer = [l for l in ls if not l["neu"]]; neu = [l for l in ls if l["neu"]]
    s = "**%d**, Ø **%d min** (min %d, max %d), vorgerendert **%d von %d**" % (
        len(ls), round(sum(m) / len(m)), round(min(m)), round(max(m)), len(treffer), len(ls))
    if treffer and neu:
        s += " (Ø %d min, mit Neubau %d min)" % (round(sum(l["min"] for l in treffer) / len(treffer)), round(sum(l["min"] for l in neu) / len(neu)))
    return s

def kurz(stunden=24):
    """Zeile für den Tagesbericht; Netz weg: Hinweis statt Zahl."""
    try: ls = laeufe(max(1, (stunden + 23) // 24))
    except Exception: return "Laufzeiten unbekannt (Netz)"
    grenze = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=stunden)
    return "APK-Läufe %d h: %s" % (stunden, zusammen([l for l in ls if zeit(l["beginn"]) >= grenze]))

if __name__ == "__main__":
    tage = int(sys.argv[sys.argv.index("--tage") + 1]) if "--tage" in sys.argv else 7
    ls = laeufe(tage)
    jetzt = datetime.datetime.now(datetime.timezone.utc)
    for l in sorted(ls, key=lambda l: l["beginn"]):
        b = zeit(l["beginn"]).astimezone(datetime.timezone(datetime.timedelta(hours=1)))
        print("%4d %s %-7s %5.1f min  %-36s %s" % (l["nr"], b.strftime("%d.%m. %H:%M"), l["ergebnis"], l["min"], l["zweig"][:36],
                                                  "Neubau: " + ", ".join("%s %.0f" % x for x in l["neu"]) if l["neu"] else "vorgerendert"))
    print("24 h:", zusammen([l for l in ls if zeit(l["beginn"]) >= jetzt - datetime.timedelta(hours=24)]))
    print("%d Tage:" % tage, zusammen(ls))
