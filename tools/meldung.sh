#!/usr/bin/env bash
# Meldung an den Nutzer über Telegram (81r): Telegram ist das Protokoll, jeder meldet selbst.
#   tools/meldung.sh <Name> "<Nummer> <Stand>"          lautlos (Arbeitsstand, auch nachts)
#   tools/meldung.sh --laut <Name> "<Nummer> <Stand>"   mit Ton und ⚠ (der Nutzer ist dran; nicht 22–7 Uhr)
#   tools/meldung.sh --bild <datei> <Name> "<Text>"     Standbild mit der Zeile als Unterschrift (Telegram verkleinert)
#   tools/meldung.sh --datei <datei> <Name> "<Text>"    Bild in voller Auflösung als Datei (Pixelprüfung)
#   tools/meldung.sh --film <datei.mp4> <Name> "<Text>" Film (MP4, bis 50 MB) mit der Zeile als Unterschrift; Bewegung nur als Film vorlegen (381, Chef 27.10., 17:19)
# Kostet in der Sitzung nichts: das Bild wird nur hochgeladen, nicht gelesen. Optionen kombinierbar, an jeder Stelle.
# Kopf: Name verlinkt automatisch auf die eigene Sitzung. Pflicht für alle (Nutzer 15.10.): jede Nummer mit Datei auf „Chefsache“ als Sprungmarke.
# Sprungmarke: „[72o.1](cs:72o1): …“ macht die Nummer zum Link auf docs/chefsache/*/72o1-….md auf GitHub (108, 117; alte Formen dz:72o1 und dz:e/72o1.html gehen weiter), [Wort](URL) im Text ebenso.
# Form: Kopf „Name TT.MM. HH:MM“, darunter je Thema eine Zeile „81s: …“ (Ford: je Agent „Tom: …“), getrennt mit \n; nur Nummern und Stichworte, nie Spieltexte.
# Schlüssel nur aus der Umgebungsvariable TELEGRAM_BOT_TOKEN, nie ins Repo oder in den Chat.
# Veraltete Kopie im Arbeitszweig (Nutzer 15.10.: Meldungen ohne Links): an die Notizkopie auf main weitergeben
haupt=/home/user/bornim-main/tools/meldung.sh
if [ -z "$MELDUNG_WEITER" ] && [ -f "$haupt" ] && [ "$(realpath "$0")" != "$(realpath "$haupt")" ]; then
  git -C /home/user/bornim-main pull -q --no-rebase origin main >/dev/null 2>&1
  MELDUNG_WEITER=1 exec "$haupt" "$@"
fi
laut=0; probe=0
bild=""; art=""
# Optionen an jeder Stelle (244: „--bild“ hinter dem Text wurde still übergangen, nur der Text ging raus)
rest=()
while [ $# -gt 0 ]; do
  case "$1" in
    --probe) probe=1 ;;  # nur zeigen, was gesendet würde (HTML), nichts senden
    --laut) laut=1 ;;
    --bild) art=photo; bild="$2"; shift ;;
    --datei) art=document; bild="$2"; shift ;;
    --film) art=video; bild="$2"; shift ;;
    --*) echo "meldung: unbekannte Option $1, nichts gesendet" >&2; exit 2 ;;
    *) rest+=("$1") ;;
  esac
  shift
done
if [ -n "$art" ] && [ ! -f "$bild" ]; then echo "meldung: Bild $bild fehlt" >&2; exit 2; fi
if [ "$art" = video ]; then  # 381: Telegram nimmt über die Bot-Schnittstelle höchstens 50 MB
  case "${bild,,}" in *.mp4) ;; *) echo "meldung: Film als MP4 (H.264), nichts gesendet (381)" >&2; exit 2 ;; esac
  [ "$(stat -c %s "$bild")" -le 52428800 ] || { echo "meldung: Film über 50 MB, nichts gesendet (kürzer oder kleiner rechnen; 381)" >&2; exit 2; }
fi
# 457 (Chef 01.11., 11:49: „unsere Signatur muss sich wiederfinden“): Bild oder Film einer Probe nie „ohne Toon/Tusche“
if [ -n "$art" ] && ! printf '%s' "${rest[*]}" | grep -q 'Chef erlaubt ohne Signatur' && fehlt=$(python3 -c 'import sys; sys.path.insert(0, sys.argv[1]); import importlib; m = importlib.import_module("commit-pruefung"); r = m.ohne_signatur(sys.argv[2]); print(r or ""); sys.exit(0 if r else 1)' "$(dirname "$(realpath "$0")")" "${rest[*]}" 2>/dev/null); then
  echo "meldung: Probe „$fehlt“, nichts gesendet; mit Toon-Licht und Tusche wie im Spiel neu zeichnen (457, D57.1; Ausnahme „Chef erlaubt ohne Signatur“)" >&2; exit 2
fi
[ -n "$art" ] && bild="$(realpath "$bild")"  # relativer Pfad: git -C "$repo" fand die Datei sonst nicht (Jerry 25.10.)
if [ ${#rest[@]} -gt 2 ]; then echo "meldung: zu viele Angaben (Text in Anführungszeichen?), nichts gesendet" >&2; exit 2; fi
name="${rest[0]}"; text="${rest[1]}"
if [ -z "$name" ] || [ -z "$text" ]; then echo "Aufruf: tools/meldung.sh [--laut] <Name> \"<Text>\"" >&2; exit 2; fi
# 484 (Chef 02.11., 19:27: „Keine Abkürzungen mehr in Telegram-Meldungen.“): Kürzel und Abkürzungen halten die Meldung an;
# erlaubt sind Vorgangsnummern und Kennungen (A1, D63.1, t146), Code in `…`, Links und die Namen MARS, SRD, APK, PNG, MP4, MB, GB
if kurz=$(printf '%s' "$text" | python3 -c '
import re, sys
t = sys.stdin.read()
t = re.sub(r"`[^`]*`|\]\([^)]*\)|https?://\S+|„[^“]*“|[\w.-]+\.(?:md|py|sh|gd|json|yml|tsv|png|mp4|tscn)\b", " ", t)  # D67.1: Zitat in „…“ ist Wortlaut; D69.1: Dateinamen
frei = {"MARS", "SRD", "APK", "PNG", "MP4", "MB", "GB", "KB", "CC0", "TCS", "OK", "JPG", "GIF"}
funde = [w for w in re.findall(r"(?<![\w./-])[A-ZÄÖÜ]{2,6}(?!\w)", t) if w not in frei]  # D67.1: auch „HP-Balken“
# D67.1: Buchstabe mit Zahl nur als Kennung (A1–G9 Grundstand, O/W Projektplan, D Befund, t Build), sonst Kürzel wie „K1“
funde += re.findall(r"(?<![\w./-])(?![A-GOWD]\d)[A-Z]\d{1,2}(?![\w.])", t)
funde += re.findall(r"(?<![\w.])(?:NW|E)\s\d+\b", t)
funde += re.findall(r"(?<!\w)(?:z\.\s?B\.|bzw\.|usw\.|ggf\.|ca\.|u\.\s?a\.|d\.\s?h\.|evtl\.|inkl\.|vgl\.|Nr\.|o\.\s?ä\.|s\.\s?o\.|s\.\s?u\.|u\.\s?U\.|m\.\s?E\.)", t)
print(", ".join(dict.fromkeys(funde))); sys.exit(0 if funde else 1)'); then
  echo "meldung: Abkürzung im Text ($kurz), nichts gesendet; ausschreiben (484, Chef 02.11., 19:27)" >&2; exit 2
fi
if [ $probe = 0 ] && [ -z "$TELEGRAM_BOT_TOKEN" ]; then echo "meldung: TELEGRAM_BOT_TOKEN fehlt in dieser Umgebung, Meldung nicht gesendet" >&2; exit 1; fi
zeit=$(TZ=Europe/Berlin date "+%d.%m. %H:%M"); stunde=$(TZ=Europe/Berlin date +%H)
if [ $laut = 1 ]; then
  text="⚠ $text"
  case $stunde in 22|23|0[0-6]) laut=0 ;; esac  # nachts nur lautlos
fi
still=true; [ $laut = 1 ] && still=false
# Ablage (363, Chef 25.10.): jedes Bild auch in voller Größe im Zweig „bilder“ (nicht auf main: Sitzungen holen ihn nicht),
# Pfad JJJJ-MM/TT-HHMM-<Vorgang>-<Name>.<endung>; ohne Vorgangsnummer am Textanfang wird nichts gesendet. Link kommt unter den Text.
if [ -n "$art" ]; then
  nr=$(printf '%s' "${text#⚠ }" | sed -nE '1s/^[[:space:]]*\[?([A-Za-z]?[0-9]+[a-z]?(\.[0-9]+[a-z]?)*)[]:( ].*/\1/p')
  if [ -z "$nr" ]; then echo "meldung: Bild ohne Vorgangsnummer am Textanfang („348.7: …“), nichts gesendet (363)" >&2; exit 2; fi
  # 374 (373 Punkt 2, 228): Bilder an den Chef nur mit Datei docs/chefsache/ansehen/<Nummer ohne Punkt>-….md
  ansehen="$(dirname "$(realpath "$0")")/../docs/chefsache/ansehen"
  k=$(printf '%s' "$nr" | tr -d . | tr 'A-Z' 'a-z')
  if ! ls "$ansehen" 2>/dev/null | tr 'A-Z' 'a-z' | grep -q "^$k-.*\.md$"; then
    echo "meldung: zu $nr liegt keine Datei docs/chefsache/ansehen/$k-….md, nichts gesendet (374); erst die Datei anlegen und pushen" >&2; exit 2
  fi
  if [ $probe = 0 ] && [ "$art" = video ] && [ "$(stat -c %s "$bild")" -gt 20971520 ]; then
    echo "meldung: Film über 20 MB, nicht im Zweig bilder abgelegt (Repo klein halten; 381), nur Telegram" >&2
  elif [ $probe = 0 ]; then
    repo="$(dirname "$(realpath "$0")")/.."
    basis="$(TZ=Europe/Berlin date +%Y-%m)/$(TZ=Europe/Berlin date +%d-%H%M)-$nr-$(printf '%s' "$name" | tr -c 'A-Za-z0-9' '_' | sed 's/_*$//')"
    endung="${bild##*.}"; pfad="$basis.$endung"
    blob=$(git -C "$repo" hash-object -w "$bild")
    abgelegt=""
    for versuch in 1 2 3; do
      eltern=""; git -C "$repo" fetch -q origin bilder 2>/dev/null && eltern=$(git -C "$repo" rev-parse FETCH_HEAD)
      # 696: mehrere Bilder in derselben Minute überschrieben sich; belegter Pfad bekommt einen Zähler (-2, -3 …)
      pfad="$basis.$endung"; z=1
      while [ -n "$eltern" ] && git -C "$repo" cat-file -e "$eltern:$pfad" 2>/dev/null; do z=$((z + 1)); pfad="$basis-$z.$endung"; done
      idx=$(mktemp); rm -f "$idx"
      [ -n "$eltern" ] && GIT_INDEX_FILE=$idx git -C "$repo" read-tree "$eltern"
      GIT_INDEX_FILE=$idx git -C "$repo" update-index --add --cacheinfo "100644,$blob,$pfad"
      baum=$(GIT_INDEX_FILE=$idx git -C "$repo" write-tree); rm -f "$idx"
      neu=$(git -C "$repo" commit-tree "$baum" ${eltern:+-p "$eltern"} -m "Bild $nr ($name)")
      git -C "$repo" push -q origin "$neu:refs/heads/bilder" 2>/dev/null && { abgelegt=1; break; }
      sleep $((versuch * 2))
    done
    # 483 (Chef 02.11., 19:21): jsDelivr liefert aus dem Zweig bilder nichts mehr (über 50 MB); je Film ein eigener Zweig
    # film/… mit nur dieser Datei (Commit ohne Eltern), Link über jsDelivr darauf; Marken (Tags) lässt der Proxy der Sitzungen
    # nicht zu (403, 02.11.), Zweige ja (Probe film/probe-483: 200, video/mp4); geht das nicht: Link auf GitHub
    film_url="https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/$pfad"
    if [ -n "$abgelegt" ] && [ "$art" = video ]; then
      marke="film/$(TZ=Europe/Berlin date +%Y%m%d-%H%M%S)-$(printf '%s' "$nr" | tr -c 'A-Za-z0-9.' '_')"
      idx=$(mktemp); rm -f "$idx"
      GIT_INDEX_FILE=$idx git -C "$repo" update-index --add --cacheinfo "100644,$blob,$pfad"
      fbaum=$(GIT_INDEX_FILE=$idx git -C "$repo" write-tree); rm -f "$idx"
      fneu=$(git -C "$repo" commit-tree "$fbaum" -m "Film $nr ($name)")
      for versuch in 1 2 3; do
        git -C "$repo" push -q origin "$fneu:refs/heads/$marke" 2>/dev/null && {
          film_url="https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@$marke/$pfad"; break; }
        sleep $((versuch * 2))
      done
      case "$film_url" in *jsdelivr*) ;; *) echo "meldung: Marke $marke nicht gepusht, Link auf GitHub (483)" >&2 ;; esac
    fi
    if [ -n "$abgelegt" ] && [ "$art" = video ]; then text="$text\n[Film im Repo]($film_url)"  # 381.1: spielt im Browser ab
    elif [ -n "$abgelegt" ]; then text="$text\n[Bild im Repo](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/$pfad)"
    else echo "meldung: Ablage im Zweig bilder fehlgeschlagen, Bild nur auf Telegram" >&2; fi
    # 450 (Chef 01.11., 10:55): Link selbst in die Datei ansehen/<k>-….md des Vorgangs auf main, unter Zeile 1, neuester oben; ohne Arbeitskopie
    # (temporärer Index wie beim Zweig bilder), darum keine Störung offener Änderungen. Mehrere Dateien zum Vorgang: die zuletzt geänderte.
    if [ -n "$abgelegt" ]; then
      wort=Bild; u="https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/$pfad"
      [ "$art" = video ] && { wort=Film; u="$film_url"; }
      zeile_l="[$wort von $(TZ=Europe/Berlin date '+%d.%m., %H:%M')]($u) (eingetragen von meldung.sh, $name)"
      eingetragen=""
      for versuch in 1 2 3; do
        git -C "$repo" fetch -q origin main 2>/dev/null || { sleep $versuch; continue; }
        basis=$(git -C "$repo" rev-parse FETCH_HEAD); blatt=""; jung=0
        for f in $(git -C "$repo" ls-tree --name-only "$basis" docs/chefsache/ansehen/); do
          b=$(basename "$f" | tr 'A-Z' 'a-z'); case "$b" in "$k"-*.md) ;; *) continue ;; esac
          t=$(git -C "$repo" log -1 --format=%ct "$basis" -- "$f"); [ "${t:-0}" -ge $jung ] && { jung=${t:-0}; blatt=$f; }
        done
        [ -n "$blatt" ] || { echo "meldung: Datei zu Vorgang $nr in ansehen/ auf main nicht gefunden, Link nicht eingetragen (450)" >&2; break; }
        inhalt=$(git -C "$repo" show "$basis:$blatt"; echo .)
        case "$inhalt" in *"$u"*) eingetragen=1; break ;; esac
        neu_b=$(printf '%s' "${inhalt%.}" | ZEILE="$zeile_l" python3 -c '
import os, sys
t = sys.stdin.read()
k, _, r = t.partition("\n")
sys.stdout.write(k + "\n\n" + os.environ["ZEILE"] + "\n\n" + r.lstrip("\n"))' | git -C "$repo" hash-object -w --stdin)
        idx=$(mktemp); rm -f "$idx"
        GIT_INDEX_FILE=$idx git -C "$repo" read-tree "$basis"
        GIT_INDEX_FILE=$idx git -C "$repo" update-index --cacheinfo "100644,$neu_b,$blatt"
        baum=$(GIT_INDEX_FILE=$idx git -C "$repo" write-tree); rm -f "$idx"
        neu=$(git -C "$repo" commit-tree "$baum" -p "$basis" -m "meldung.sh: $wort $nr in $(basename "$blatt") ($name, 450)")
        git -C "$repo" push -q origin "$neu:refs/heads/main" 2>/dev/null && { eingetragen=1; break; }
        sleep $((versuch * 2))
      done
      [ -n "$eingetragen" ] || echo "meldung: Link nicht in die Datei des Vorgangs eingetragen; von Hand nachtragen (450)" >&2
    fi
  fi
fi
# Aussehen (Nutzer 15.10.): Kopf fett in eigener Zeile; Zeilen, die mit „Name:“ oder „Nummer:“ beginnen, bis zum Doppelpunkt fett; **x** fett.
# Kopf verlinkt auf die Sitzung des Absenders (Nutzer 15.10., 16:0x), wenn die Umgebung sie kennt
sitzung=""; case "$CLAUDE_CODE_REMOTE_SESSION_ID" in cse_*) sitzung="https://claude.ai/code/session_${CLAUDE_CODE_REMOTE_SESSION_ID#cse_}" ;; esac
zug="$(dirname "$(realpath "$0")")/../docs/chefsache"
besetzung="$(dirname "$(realpath "$0")")/../docs/ARBEIT-BESETZUNG.md"
zeile=$(NAME="$name" ZEIT="$zeit" SITZUNG="$sitzung" TEXT="$text" ZUG="$zug" BESETZUNG="$besetzung" python3 -c '
import os, re, html
t = html.escape(os.environ["TEXT"].replace("\\n", "\n"), quote=False)
t = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", t)
t = re.sub(r"`([^`\n]+)`", r"<code>\1</code>", t)  # 369.1: Satz zum Kopieren (Antippen kopiert)
import glob
gh = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/"
def dz(u):  # Chefsache im Repo (108, 117): cs:72o1 -> docs/chefsache/<ordner>/72o1-….md, sonst der Ordner
    k = u[3:].removeprefix("e/").removesuffix(".html").removesuffix(".md").replace(".", "").lower()
    for f in sorted(glob.glob(os.path.join(os.environ["ZUG"], "*", "*.md"))):
        if os.path.basename(f).split("-")[0].removesuffix(".md").replace(".", "").lower() == k:
            return gh + "blob/main/docs/chefsache/" + os.path.basename(os.path.dirname(f)) + "/" + os.path.basename(f)
    return gh + "tree/main/docs/chefsache"
url = lambda u: dz(u) if u.startswith(("cs:", "dz:")) else u  # cs: Chefsache (117), dz: alte Form
# Sprungmarke (Nutzer 15.10.): Zeile „[72o.1](cs:72o1): …“ macht die fette Nummer selbst zum Link
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)\[([^\]]{1,30})\]\(([^)\s]+)\):", lambda m: m.group(1) + "<a href=\"" + url(m.group(3)) + "\"><b>" + m.group(2) + ":</b></a>", t)
t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", lambda m: "<a href=\"" + url(m.group(2)) + "\">" + m.group(1) + "</a>", t)
# Nackte Adresse (105, Chef 16.10.: „Hyperlink nicht unterlegt, sondern extra“): „Titel“: URL -> Titel als Link, sonst das Wort „Link“
t = re.sub(r"„([^“<]+)“:?\s*(https?://[^\s<]+)", lambda m: "<a href=\"" + m.group(2) + "\">„" + m.group(1) + "“</a>", t)
t = re.sub(r"(?<![\"=>])(https?://[^\s<]+?)([.,;)]?(?:\s|$))", lambda m: "<a href=\"" + m.group(1) + "\">Link</a>" + m.group(2), t)
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)([\wÄÖÜäöüß][\wÄÖÜäöüß .,/–-]{0,30}):", r"\1<b>\2:</b>", t)
# Selbsttätig (105, Nutzer 16.10.: Links fehlen, Fettdruck uneinheitlich): auch ohne [..](cs:..) wird jede Nummer mit Datei
# auf Chefsache (72s.1, 99g, D10, 0.1.757 -> t757) fetter Link, „PR #71“ Link auf den PR, „Tom:“ am Zeilenanfang Link auf die laufende Sitzung (Besetzung).
keys = {}
for f in glob.glob(os.path.join(os.environ["ZUG"], "*", "*.md")):
    k = os.path.basename(f).split("-")[0].removesuffix(".md").lower()
    if re.search(r"\d", k): keys[k] = gh + "blob/main/docs/chefsache/" + os.path.basename(os.path.dirname(f)) + "/" + os.path.basename(f)
# Nur Nummern mit Datei auf Chefsache werden Link (Chef 16.10., 12:0x: Verlinkung auf eine Vorratsdatei „macht keinen Sinn“):
# fett mit Link heißt „du bist dran“, schlichte Nummer heißt „nur Stand“.
sitz = {}
try:
    for z in open(os.environ["BESETZUNG"], encoding="utf-8"):
        m = re.match(r"\|\s*([^|]+?)\s*\|\s*\[[^\]]*\]\((https://claude\.ai/code/session_\w+)\)", z)
        if m:
            sitz[m.group(1)] = m.group(2)
            if m.group(1).startswith("Team "): sitz[m.group(1)[5:]] = m.group(2)
except OSError: pass
def nummer(m):
    tok = m.group(0); k = tok.replace(".", "").lower()
    v = re.fullmatch(r"0\.1\.(\d+)", tok)
    if v: k = "t" + v.group(1)
    if k not in keys or len(tok) < 2 and "/chefsache/" not in keys[k]: return tok  # einstellige Zahlen („Stufe 3“) nur mit Datei auf Chefsache
    return "<a href=\"" + keys[k] + "\"><b>" + tok + "</b></a>"
def frei(seg):
    seg = re.sub(r"\bPR #(\d+)", lambda m: "<a href=\"" + gh + "pull/" + m.group(1) + "\">" + m.group(0) + "</a>", seg)
    teile = re.split(r"(<a [^>]*>.*?</a>|<[^>]+>)", seg)
    return "".join(x if x.startswith("<") else re.sub(r"(?<![\w.#/:])(?:0\.1\.\d+|[A-Za-z]?\d+[a-z]?(?:\.\d+)?[a-z]?)(?![\w.:]\w|\w)", nummer, x) for x in teile)
t = "".join(x if x.startswith("<a ") else frei(x) for x in re.split(r"(<a [^>]*>.*?</a>)", t, flags=re.S))
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)<b>([^<:]+):</b>", lambda m: m.group(1) + ("<a href=\"" + sitz[m.group(2)] + "\"><b>" + m.group(2) + ":</b></a>" if m.group(2) in sitz else "<b>" + m.group(2) + ":</b>"), t)
n = "<b>" + html.escape(os.environ["NAME"]) + "</b>"
if os.environ["SITZUNG"]: n = "<a href=\"" + os.environ["SITZUNG"] + "\">" + n + "</a>"
print(n + " <b>" + os.environ["ZEIT"] + "</b>\n" + t)')
[ $probe = 1 ] && { [ -n "$art" ] && echo "($art: $bild)"; echo "$zeile"; printf '%b' "${text#⚠ }" | sed -nE 's/^[[:space:]]*(⚠[[:space:]]*)?\[?([A-Za-z]?[0-9]+[a-z]?(\.[0-9]+[a-z]?)*)[]:( ].*/\2/p' | sort -u | paste -sd, - | sed 's/^/(Protokoll 383: /;s/$/)/'; exit 0; }
if [ -n "$art" ]; then
  methode=sendPhoto; [ $art = document ] && methode=sendDocument; [ $art = video ] && methode=sendVideo
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/$methode" \
    -F "chat_id=8965432899" -F "disable_notification=$still" -F "$art=@$bild" --form-string "caption=$zeile" -F "parse_mode=HTML" \
    $([ $art = video ] && echo "-F supports_streaming=true") 2>&1)
else
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=8965432899" --data-urlencode "disable_notification=$still" \
    --data-urlencode "text=$zeile" --data-urlencode "parse_mode=HTML" \
    --data-urlencode "link_preview_options={\"is_disabled\":true}" 2>&1)  # keine Vorschaukarten (Nutzer 15.10.)
fi
case "$antwort" in *'"ok":true'*) echo "meldung: gesendet" ;; *) echo "meldung: Fehler: ${antwort:0:200}" >&2; exit 1 ;; esac
# 658: Telegram-Kennung der Nachricht als fünfte Spalte, damit tools/reaktionen.py eine Reaktion des Chefs dem Vorgang zuordnet
mid=$(printf '%s' "$antwort" | python3 -c 'import json,sys
try: print(json.load(sys.stdin)["result"]["message_id"])
except Exception: pass' 2>/dev/null)
# 383 (Chef 27.10., 17:53): je Meldung eine Protokollzeile im Zweig „meldungen“ (Zeit, Vorgänge am Zeilenanfang, Name, Art),
# damit der Wartewächter in lauf.py sieht, ob zu einem „jetzt“ des Chefs etwas vorgelegt wurde. Fehler hier ändern nichts am Senden.
nrn=$(printf '%b' "${text#⚠ }" | sed -nE 's/^[[:space:]]*(⚠[[:space:]]*)?\[?([A-Za-z]?[0-9]+[a-z]?(\.[0-9]+[a-z]?)*)[]:( ].*/\2/p' | sort -u | paste -sd, -)
if [ -n "$nrn" ]; then
  wie=text; [ $laut = 1 ] && wie=laut; [ -n "$art" ] && wie=$art
  repo="$(dirname "$(realpath "$0")")/.."
  zeile_p="$(TZ=Europe/Berlin date "+%Y-%m-%d %H:%M")\t$nrn\t$name\t$wie\t$mid"
  for versuch in 1 2 3; do
    eltern=""; git -C "$repo" fetch -q origin meldungen 2>/dev/null && eltern=$(git -C "$repo" rev-parse FETCH_HEAD)
    alt=""; [ -n "$eltern" ] && alt=$(git -C "$repo" show "$eltern:meldungen.tsv" 2>/dev/null)
    blob=$( { [ -n "$alt" ] && printf '%s\n' "$alt" | tail -n 2000; printf '%b\n' "$zeile_p"; } | git -C "$repo" hash-object -w --stdin)
    idx=$(mktemp); rm -f "$idx"
    GIT_INDEX_FILE=$idx git -C "$repo" update-index --add --cacheinfo "100644,$blob,meldungen.tsv"
    baum=$(GIT_INDEX_FILE=$idx git -C "$repo" write-tree); rm -f "$idx"
    neu=$(git -C "$repo" commit-tree "$baum" ${eltern:+-p "$eltern"} -m "Meldung $nrn ($name)")
    git -C "$repo" push -q origin "$neu:refs/heads/meldungen" 2>/dev/null && break
    sleep $versuch
  done
fi
