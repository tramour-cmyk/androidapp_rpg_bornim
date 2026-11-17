#!/usr/bin/env bash
# Rollenspiegel (340.2): eigene Antwort ohne fremde. Die Datei docs/LISTE-ROLLENSPIEGEL.md nie selbst öffnen.
#   tools/rollenspiegel.sh <Rolle>                          Fragen und eigene Antwort der Vorwoche zeigen
#   tools/rollenspiegel.sh <Rolle> --antwort <datei|->      Antwort (Zeilen „0. …“ bis „11. …“, ohne 2) anhängen;
#                                                           Zeile „11. …“ (Vorschlag fürs Spiel) geht zusätzlich nach LISTE-IDEEN.md
#                          [--sitzung "<Titel>"]            Sitzungstitel für die Kopfzeile
# Rollen: Sokrates, Perikles, Homer, Ford, Diogenes, Tom, Jerry (auch „Team Tom“). Hängt unter „## Woche <Mittwoch>“ an (1461, ab 18.11.; vorher Freitag);
# eine neue Woche verdrängt alles vor der Vorwoche (älteres steht in Git). Danach selbst committen und pushen.
haupt=/home/user/bornim-main
[ -d "$haupt/docs" ] || haupt="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$haupt" pull -q --no-rebase origin main >/dev/null 2>&1
# Python über -c, damit stdin frei bleibt für „--antwort -“
code=$(cat <<'PY'
import sys, re, datetime, zoneinfo
datei, args = sys.argv[1], sys.argv[2:]
try: sys.stdout.reconfigure(errors="replace")
except Exception: pass
import signal; signal.signal(signal.SIGPIPE, signal.SIG_DFL)
NAMEN = {"sokrates": "Sokrates", "perikles": "Perikles", "homer": "Homer", "ford": "Ford", "diogenes": "Diogenes",
         "tom": "Team Tom", "team tom": "Team Tom", "jerry": "Team Jerry", "team jerry": "Team Jerry",
         "spike": "Team Tom", "tuffy": "Team Jerry"}  # 394
if not args or args[0].lower() not in NAMEN:
    sys.exit("Aufruf: tools/rollenspiegel.sh <Rolle> [--antwort <datei|->] [--sitzung \"<Titel>\"]; Rollen: Sokrates, Perikles, Homer, Ford, Diogenes, Tom, Jerry")
rolle, antwort, sitzung = NAMEN[args[0].lower()], None, ""
i = 1
while i < len(args):
    if args[i] == "--antwort" and i + 1 < len(args): antwort = args[i + 1]; i += 2
    elif args[i] == "--sitzung" and i + 1 < len(args): sitzung = args[i + 1]; i += 2
    else: sys.exit("Unbekannt: " + args[i])
text = open(datei, encoding="utf-8").read()
# Abschnitte: Kopf (bis „## Woche“), dann je Woche ein Block
teile = re.split(r"(?m)^(?=## Woche )", text)
kopf, wochen = teile[0], teile[1:]
def eigene(block):
    m = re.search(r"(?ms)^### " + re.escape(rolle) + r"\b.*?(?=^### |\Z)", block)
    return m.group(0).rstrip() if m else None
jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
# 1461 (340 A, Chef 16.11., 16:27: „alles nicht mehr freitags, sondern mittwochs. Und zwar nach dem Managementbericht von Pericles“):
# Termin mittwochs; vor dem 18.11. gilt noch der Freitag (Nachholen der Woche 13.11.).
UMSTELLUNG = datetime.date(2026, 11, 18)
TAG = 2 if jetzt.date() >= UMSTELLUNG - datetime.timedelta(days=2) else 4  # ab Mo 16.11. ist der nächste Termin Mi 18.11.
termin_d = (jetzt + datetime.timedelta(days=TAG - jetzt.weekday())).date()
termin = termin_d.strftime("%d.%m.")
kopfzeile = "## Woche " + termin
# 721, D93.1: eine Antwort vor dem Termintag ist immer das Nachholen des vergangenen Termins; steht dort schon eine,
# ist nichts fällig. Früher landete sie unter dem kommenden Termin und verdeckte dessen Ausfall.
naechster = ("Mi " if TAG == 2 else "Fr ") + termin
if jetzt.weekday() < TAG:
    vorige = termin_d - datetime.timedelta(days=7)
    if vorige < UMSTELLUNG:  # Woche vor der Umstellung: Freitag
        vorige = vorige + datetime.timedelta(days=2)
    kopfzeile = "## Woche " + vorige.strftime("%d.%m.")

if antwort is None:
    fragen = re.search(r"(?ms)^## Fragen\n.*?(?=^## )", kopf)
    print(re.sub(r"(?s)^# Rollenspiegel\n\n", "", kopf.split("## Fragen")[0]).strip().split("\n")[0])
    print()
    print(fragen.group(0).strip() if fragen else "(Fragen nicht gefunden)")
    print()
    alt = [(w.split("\n")[0], eigene(w)) for w in wochen if not w.startswith(kopfzeile)]
    alt = [a for a in alt if a[1]]
    if alt: print("Deine letzte Antwort (" + alt[-1][0][3:] + "):\n" + alt[-1][1])
    else: print("Keine eigene Antwort aus einer Vorwoche in der Datei (älteres in Git).")
    if any(w.startswith(kopfzeile) and eigene(w) for w in wochen):
        print("\nHinweis: Für die " + kopfzeile[3:] + " steht schon eine Antwort von " + rolle + ".")
    print("\nAntwort anhängen: tools/rollenspiegel.sh " + args[0] + " --antwort <datei> --sitzung \"<Titel>\"; danach committen und pushen.")
    sys.exit(0)

# 1461 (Chef 16.11., 16:27: „nach dem Managementbericht von Pericles“; 18.11., 00:03): mittwochs erst nach dem Tagesbericht
import os
tb = os.path.join(os.path.dirname(os.path.abspath(datei)), "ARBEIT-TAGESBERICHT.md")
if jetzt.weekday() == 2 and jetzt.date() >= UMSTELLUNG and os.path.exists(tb) and ("**Stand %s, " % jetzt.strftime("%d.%m.")) not in open(tb, encoding="utf-8").read():
    sys.exit("Mittwoch: Rollenspiegel erst nach dem Tagesbericht (1461); nichts geändert, lauf.py fordert ihn danach an.")

neu = (sys.stdin.read() if antwort == "-" else open(antwort, encoding="utf-8").read()).strip()
if not re.search(r"(?m)^0\. ", neu) or not re.search(r"(?m)^11\. ", neu):
    sys.exit("Antwort braucht die Zeilen „0. …“ bis „11. …“ ohne 2 (Fragen ohne Antwort: „nichts“ mit Begründung).")
neu = re.sub(r"(?m)^#+ .*\n?", "", neu).strip()
abschnitt = "### %s (%s%s)\n\n%s\n" % (rolle, jetzt.strftime("%d.%m., %H:%M"), ", Sitzung „%s“" % sitzung if sitzung else "", neu)
for n, w in enumerate(wochen):
    if w.startswith(kopfzeile):
        if eigene(w): sys.exit("Für die %s steht schon eine Antwort von %s; nichts geändert, der nächste Rollenspiegel ist am %s" % (kopfzeile[3:], rolle, naechster))
        wochen[n] = w.rstrip() + "\n\n" + abschnitt + ("\n" if n < len(wochen) - 1 else "")
        break
else:
    wochen = wochen[-1:] + [kopfzeile + "\n\n" + abschnitt]
    if wochen[0] != wochen[-1]: wochen[0] = wochen[0].rstrip() + "\n\n"
open(datei, "w", encoding="utf-8").write(kopf + "".join(wochen))
# 1461: Frage 11 (Vorschlag fürs Spiel) zusätzlich in den Ideenspeicher; Homer urteilt sonntags, Perikles holt montags
m11 = re.search(r"(?ms)^11\. (.*?)(?=^\d+\. |\Z)", neu)
if m11 and m11.group(1).strip():
    ideen = datei.replace("LISTE-ROLLENSPIEGEL.md", "LISTE-IDEEN.md")
    t = open(ideen, encoding="utf-8").read()
    zeile = "- **%s (Rollenspiegel %s):** %s" % (rolle, kopfzeile[9:], " ".join(m11.group(1).split()))
    k = "## Aus dem Rollenspiegel (Frage 11, 1461)"
    if k in t: t = t.replace(k + "\n\n", k + "\n\n" + zeile + "\n", 1)  # neueste oben
    elif "\n## Verworfen" in t: t = t.replace("\n## Verworfen", "\n" + k + "\n\n" + zeile + "\n\n## Verworfen", 1)
    else: t = t.rstrip() + "\n\n" + k + "\n\n" + zeile + "\n"
    open(ideen, "w", encoding="utf-8").write(t)
    print("Frage 11 in LISTE-IDEEN.md „%s“ eingetragen." % k[3:])
print("Angehängt unter %s: %s. Jetzt committen und pushen (Commit „340: Rollenspiegel %s“)." % (kopfzeile[3:], rolle, rolle))
PY
)
exec python3 -c "$code" "$haupt/docs/LISTE-ROLLENSPIEGEL.md" "$@"
