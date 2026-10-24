# Paket für Sokrates: Regeltreue erhöhen, Kosten senken

Stand 24.10. Zusammengestellt aus den Dateien, die der Chef hochgeladen hat (`CLAUDE.md`, `ROLLE-ENTWICKLUNG.md`, `LISTE-BAUEN-TESTEN.md`, die drei `DESIGN-…`, `ARBEIT-TEAM-TOM.md`, `ARBEIT-BETRIEB.md`, `CHANGELOG.md`, `tools/notiz.sh`, `tools/weiter-haken.py`, `tools/meldung.sh`, `.claude/settings.json`). **Nichts davon ist in echten Sitzungen erprobt.** Token sind geschätzt (etwa 3,3 Zeichen je Token); die genaue Zahl zeigt `/context`.

## 1. Befund in fünf Sätzen

1. Sitzungen ignorieren Regeln wie „kurz“, rechnen die Uhrzeit selbst hoch (und entschuldigen sich danach) und melden Dinge, die der Chef weder beeinflussen noch entscheiden kann. Der Output-Style „Knapp“ wirkt kaum.
2. Meine Vermutung: Regeln, die weit vorn im Kontext stehen, verlieren nach vielen Tausend Token an Wirkung; eine Erinnerung direkt vor der Antwort wirkt stärker. Belegt ist das nicht.
3. Die Uhrzeit hing bisher nur an einer Textregel. `notiz.sh` gab sie nicht aus, nur Commit-Zeiten. `meldung.sh` setzt sie in Telegram schon selbst und ist deshalb nicht betroffen.
4. Der Start einer Sitzung lädt bei Tom etwa 108,7 KB (≈ 33k Token), bei Jerry etwa 93,8 KB. Den größten Teil machen `CHANGELOG.md` (27 KB, der ganze Abschnitt „Unveröffentlicht“), `DESIGN-STIL.md` (23 KB) und `ARBEIT-BETRIEB.md` (15 KB, nur eine Zeile nötig) aus.
5. Es gibt keine Messung der Regeltreue; alles beruht auf Eindrücken. Darum gehört der Zähler (Punkt 3.4) mit in das Paket.

**Korrektur an früheren Angaben:** Ich hatte `ARBEIT-TEAM-TOM.md` mit 16,6 KB über der Grenze von 15 KB gesehen und `DESIGN-STIL.md` mit 26 KB gemessen. Das war ein Fehler meiner Umwandlung (Tabellen waren mit Leerzeichen aufgefüllt). Richtig sind etwa 11 KB und 23 KB. Eine Vorratszeile ist mit etwa 475 Zeichen knapp über der Grenze von 400.

## 2. Was geändert wird (Stufe 1, jetzt)

| Nr | Was | Wirkung | Risiko |
|---|---|---|---|
| 3.1 | `tools/notiz.sh`: Berliner Zeit und Kernregel-Zeile als letzte Zeilen jeder Ausgabe | Zeit mechanisch; Erinnerung direkt vor der Antwort | gering; wirkt nur, wenn die Sitzung das Skript vor der Antwort aufruft |
| 3.2 | `tools/hook-prompt.sh` (neuer Hook `UserPromptSubmit`) | Zeit bei jedem Prompt, Kernregeln bei jedem 10. | gering |
| 3.3 | Eintrag in `.claude/settings.json` | schaltet 3.2 und 3.4 ein | gering |
| 3.4 | `tools/hook-zaehler.py` (neuer Hook `Stop`, nur Messung) | schreibt je Zugende eine Zeile nach `.claude/regeltreue.tsv`; kostet keine Token | gering; Annahme zum Aufbau des Verlaufs siehe 6 |
| 3.5 | `CLAUDE.md`: Haltung „Sparsam“ neu, neuer Abschnitt „Bekannte Fehler“, Telegram-Länge | Chat-Filter, Zeit-Regel, Platz für gelernte Fehler | gering; nichts wird ausgelagert |
| 3.6 | `ROLLE-ENTWICKLUNG.md`: Abschnitt „Start“ mit gezielten Ladebefehlen | Start deutlich kleiner | mittel: ändert Startregeln |

Nicht in Stufe 1: das Auslagern von Verfahren aus der `CLAUDE.md` (Entwurf mit `LISTE-REGELN.md` liegt separat vor). Es spart nur etwa ein Fünftel und könnte Regeln untergehen lassen; erst nach Test.

## 3. Änderungen im Wortlaut

### 3.1 `tools/notiz.sh`

```diff
--- tools/notiz.sh (alt)
+++ tools/notiz.sh (neu)
@@ -5,6 +5,8 @@
 #   tools/notiz.sh --kurz   nur eine Zeile (für den Starthaken)
 # Bearbeiten danach unter ../bornim-main, committen und sofort pushen (siehe CLAUDE.md).
 cd "$(dirname "$0")/.." || exit 1
+# Zeit und Kernregeln als letzte Zeilen jeder Ausgabe: stehen damit direkt vor der nächsten Antwort.
+kern="Kernregeln: Chat nur, was der Chef entscheiden, tun oder prüfen kann, sonst schweigen; keine Entschuldigung, kein Zwischenstand; Ergebnis zuerst (Telegram darf länger sein); prüfen statt zustimmen; nicht raten."
 repo=$(pwd)
 wt="$(cd "$repo/.." && pwd)/bornim-main"
 mark="$(git rev-parse --git-common-dir)/notiz-zuletzt"
@@ -62,6 +64,8 @@
     if [ -z "$alt" ]; then was="erster Aufruf, tools/notiz.sh zeigt die letzten Änderungen"
     else was="$(git rev-list --count "$alt..$neu" -- CLAUDE.md CHANGELOG.md docs 2>/dev/null) neue Änderungen seit dem letzten Mal (tools/notiz.sh zeigt sie)"; fi
     echo "Bornim: Diese Sitzung ist $name. Notizen auf main: $was."
+    echo "Jetzt (Berlin): $(TZ=Europe/Berlin date '+%d.%m., %H:%M')"
+    echo "$kern"
     exit 0
 fi
 echo "Diese Sitzung ist: $name"
@@ -88,4 +92,6 @@
     printf '#!/bin/sh\n# commit-pruefung (192.1)\nif [ -f tools/commit-pruefung.py ]; then python3 tools/commit-pruefung.py || exit 1; fi\nexit 0\n' > "$hk" && chmod +x "$hk"
 fi
 echo "$neu" > "$mark"
-echo "Arbeitskopie für Notizen: $wt"
\ No newline at end of file
+echo "Arbeitskopie für Notizen: $wt"
+echo "Jetzt (Berlin): $(TZ=Europe/Berlin date '+%d.%m., %H:%M')"
+echo "$kern"
```

### 3.2 `tools/hook-prompt.sh` (neu, `chmod +x`)

```bash
#!/usr/bin/env bash
# UserPromptSubmit-Hook: Berliner Zeit bei jedem Prompt, Kernregeln bei jedem 10. Prompt.
# Ablegen als tools/hook-prompt.sh, ausführbar machen: chmod +x tools/hook-prompt.sh

INTERVALL=10   # alle wie viele Prompts die Kernregeln wiederholt werden

eingabe=$(cat)
sid=$(printf '%s' "$eingabe" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p')
sid=${sid:-unbekannt}
datei="/tmp/bornim-hook-${sid}"

n=$(cat "$datei" 2>/dev/null || echo 0)
n=$((n + 1))
echo "$n" > "$datei"

echo "Systemzeit (Berlin): $(TZ=Europe/Berlin date '+%d.%m., %H:%M') – nur diese Zeit nutzen, nie schätzen."

if (( n % INTERVALL == 1 )); then
  echo "Kernregeln: Chat nur, was der Chef entscheiden, tun oder prüfen kann, sonst schweigen; keine Entschuldigung, kein Zwischenstand; Ergebnis zuerst (Telegram darf länger sein); prüfen statt zustimmen; nicht raten."
fi

exit 0
```

### 3.3 `.claude/settings.json`: Einträge ergänzen, Bestehendes bleibt

Unter `hooks` → `UserPromptSubmit` als weiteren Eintrag (neben `neustart-haken.py`):

```json
{ "hooks": [ { "type": "command", "command": "$CLAUDE_PROJECT_DIR/tools/hook-prompt.sh" } ] }
```

Unter `hooks` → `Stop` als weiteren Eintrag (neben `weiter-haken.py` und `zug-haken.py`):

```json
{ "hooks": [ { "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/tools/hook-zaehler.py\"" } ] }
```

In `.gitignore`: `.claude/regeltreue.tsv`

### 3.4 `tools/hook-zaehler.py` (neu, nur Messung)

Gibt nichts aus, blockiert nie, Exit-Code immer 0. Bei einem Zugende nach einem Stop-Haken (`stop_hook_active`) zählt es nicht doppelt.

```python
#!/usr/bin/env python3
"""Stop-Hook, nur Messung: schreibt je Zugende eine Zeile nach .claude/regeltreue.tsv.
Gibt nichts aus (kostet keine Token), blockiert nie, endet immer mit Exit-Code 0.
Ablegen als tools/hook-zaehler.py. Die Datei .claude/regeltreue.tsv in .gitignore eintragen."""
import json, os, re, sys
from datetime import datetime
from zoneinfo import ZoneInfo

PROJEKT = os.environ.get("CLAUDE_PROJECT_DIR", ".")
LOG = os.path.join(PROJEKT, ".claude", "regeltreue.tsv")
KOPF = "zeit\tsitzung\tprompt_nr\tkontext_token\twoerter\tentschuldigung\tstempel\tstempel_abweichung_min"
ENTSCHULD = re.compile(r"entschuldig|verzeih|tut mir (so )?leid|\bleid\b|\bsorry\b|mein fehler", re.I)
STEMPEL = re.compile(r"\[(\d\d)\.(\d\d)\., (\d\d):(\d\d)\]")


def schreibe(zeile):
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    neu = not os.path.exists(LOG)
    with open(LOG, "a", encoding="utf-8") as f:
        if neu:
            f.write(KOPF + "\n")
        f.write(zeile + "\n")


def letzte_antwort(pfad):
    text, usage = "", {}
    with open(pfad, encoding="utf-8") as f:
        zeilen = f.readlines()
    for roh in reversed(zeilen):
        try:
            e = json.loads(roh)
        except ValueError:
            continue
        if e.get("type") != "assistant":
            continue
        msg = e.get("message", {})
        teile = [b.get("text", "") for b in msg.get("content", []) if isinstance(b, dict) and b.get("type") == "text"]
        if not usage and msg.get("usage"):
            usage = msg["usage"]
        if teile:
            text = "\n".join(teile)
            if msg.get("usage"):
                usage = msg["usage"]
            break
    return text, usage


def main():
    daten = json.load(sys.stdin)
    if daten.get("stop_hook_active"):
        return
    text, usage = letzte_antwort(daten["transcript_path"])
    sid = str(daten.get("session_id", "?"))
    jetzt = datetime.now(ZoneInfo("Europe/Berlin"))
    ohne_code = re.sub(r"```.*?```", " ", text, flags=re.S)
    woerter = len(ohne_code.split())
    entschuldigung = 1 if ENTSCHULD.search(text) else 0
    ctx = sum(int(usage.get(k, 0) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
    stempel, abw = 0, ""
    m = STEMPEL.search(text[:120])
    if m:
        stempel = 1
        try:
            tm, mo, h, mi = (int(x) for x in m.groups())
            gemeldet = jetzt.replace(month=mo, day=tm, hour=h, minute=mi, second=0, microsecond=0)
            abw = str(int(abs((jetzt - gemeldet).total_seconds()) // 60))
        except ValueError:
            abw = "ungueltig"
    try:
        prompt_nr = open("/tmp/bornim-hook-" + sid, encoding="utf-8").read().strip()
    except OSError:
        prompt_nr = ""
    schreibe("\t".join([jetzt.strftime("%Y-%m-%d %H:%M"), sid[:8], prompt_nr, str(ctx), str(woerter),
                        str(entschuldigung), str(stempel), abw]))


try:
    main()
except Exception as fehler:  # Messung darf nie stören
    try:
        schreibe("FEHLER\t" + repr(fehler)[:200])
    except Exception:
        pass
sys.exit(0)
```

### 3.5 `CLAUDE.md`: drei Stellen

**a) Haltung, Punkt „Sparsam“ ersetzen** (Nummerierung bleibt, damit „Haltung 3“ weiter stimmt):

> **Sparsam:** im Chat nur, was der Chef entscheiden, tun oder prüfen kann; sonst schweigen. Keine Entschuldigung, kein Zwischenstand, keine Einleitung, ohne Füllwörter, Ergebnis zuerst; nur Sokrates begründet ausführlich. Was funktioniert oder der Chef nicht beeinflussen kann, muss er nicht erfahren. Telegram darf ausführlicher sein.

**b) Neuer Abschnitt direkt nach „Haltung“:**

> ## Bekannte Fehler (höchstens 10 Zeilen: „nie X, stattdessen Y“; neue Zeile ersetzt eine alte; Diogenes trägt sie montags bei der Zählung ein)
> - Nie die Uhrzeit schätzen oder weiterrechnen; stattdessen die Zeile „Systemzeit (Berlin)“ bzw. „Jetzt (Berlin)“ aus Hook oder `tools/notiz.sh` nehmen.
> - Nie Entschuldigung oder Bericht über Dinge, die der Chef nicht beeinflussen kann (z. B. was eine APK gerade tut); stattdessen schweigen oder eine Zeile, die er entscheiden oder prüfen kann.

**c) Telegram:** In „Melden“ steht „je Thema eine Zeile“. Der Chef hat gesagt, Telegram darf länger sein. Vorschlag: „so ausführlich wie nötig, aber nur, was der Chef entscheiden, tun oder prüfen kann“. Meines Wissens begrenzt Telegram Textnachrichten auf 4096 und Bildunterschriften auf 1024 Zeichen; bei `--bild` ist die Grenze enger, ein langer Text gehört dann in eine zweite Meldung. Sokrates entscheidet, ob die Regel so geändert wird.

### 3.6 `ROLLE-ENTWICKLUNG.md`: Abschnitt „Start“ ersetzen

Die Befehle sind an den hochgeladenen Dateien getestet (CHANGELOG 27,1 → 1,9 KB, `DESIGN-STIL.md` 23 → 2,2 KB, Ford-Zeile statt 14,9 KB).

> ## Start
>
> 1. Diese Datei; dein Vorrat: Übergabe und „Zeilen“ ganz (`sed -n '1,/^## Einzelheiten/p' docs/ARBEIT-TEAM-<NAME>.md`); aus „Einzelheiten“ nur die Einträge „Von …“ und die zu Vorgängen, an die du gehst (`grep -E '^- \*\*(Von |Zu <Nr>)' docs/ARBEIT-TEAM-<NAME>.md`).
> 2. `DESIGN-LEITBILD.md` ganz (gilt bei Widerspruch); `DESIGN-STIL.md` nur „Auf einen Blick“ (`sed -n '/^## Auf einen Blick/,/^## Signatur/p' docs/DESIGN-STIL.md`), die Einzelabschnitte (Signatur, Karte und Räume, Oberfläche, Zwischensequenzen, Klang …) erst, wenn die Aufgabe sie berührt; `DESIGN-ABNAHME.md` ganz.
> 3. `CHANGELOG.md`: nur die drei neuesten Einträge unter „Unveröffentlicht“ (`awk '/^## v/{exit} /^- \*\*/{n++} n<=3' CHANGELOG.md`).
> 4. `LISTE-BAUEN-TESTEN.md` „Handwerk“ ganz, **vor dem ersten Build**; dann `tools/check-env.sh`.
> 5. Nur Tom: **Ford muss laufen** (außer Stellung „aus“): die Zeile „Ford lebt in einer Sitzung“ aus `docs/ARBEIT-BETRIEB.md` holen (`grep "Ford lebt in einer Sitzung" docs/ARBEIT-BETRIEB.md`, nicht die ganze Datei), `get_session` dieser Sitzung, älter als 70 Minuten → `send_message` „Ford-Lauf“.
>
> Nicht beim Start: übrige `LISTE-…` (`LISTE-FIGUREN.md` vor jeder Figur und jedem Zwischenbild), Rollendateien anderer.

## 4. Token-Bilanz (geschätzt)

Start einer Sitzung, in KB:

| Datei | jetzt | nach Stufe 1 | Ersparnis |
|---|---:|---:|---:|
| `CLAUDE.md` | 12,8 | 13,4 | -0,6 |
| `ROLLE-ENTWICKLUNG.md` | 5,4 | 5,9 | -0,5 |
| `Vorrat ARBEIT-TEAM-<NAME>.md` | 10,9 | 4,9 | 6,0 |
| `DESIGN-LEITBILD.md` | 3,8 | 3,8 | 0,0 |
| `DESIGN-STIL.md` | 23,1 | 2,2 | 20,9 |
| `DESIGN-ABNAHME.md` | 4,7 | 4,7 | 0,0 |
| `CHANGELOG.md` | 27,1 | 1,9 | 25,2 |
| `LISTE-BAUEN-TESTEN.md „Handwerk“` | 5,9 | 5,9 | 0,0 |
| `ARBEIT-BETRIEB.md (nur Tom)` | 14,9 | 0,2 | 14,7 |
| **Summe Tom** | **108,7** | **42,9** | **65,8** |
| **Summe Jerry** | **93,8** | **42,7** | **51,1** |

Das sind bei Tom etwa 33k → 13k Token (Ersparnis ≈ 20k), bei Jerry etwa 28k → 13k. Die `CLAUDE.md` wird in Stufe 1 etwas größer, weil Text hinzukommt.

Laufende Zusatzkosten: Hook etwa 28 Token je Prompt, `notiz.sh` etwa 72 Token je Aufruf, zusammen etwa 101 Token je Austausch, wenn `notiz.sh` bei jeder Antwort läuft. Gleichstand bei etwa **197 Austauschen**; kürzere Sitzungen sparen, längere zahlen drauf. Der Zähler kostet nichts. Nicht eingerechnet sind Systemprompt, Werkzeug- und MCP-Beschreibungen, Chat und alles, was die Sitzung später liest.

Weiter sparen lässt sich bei Bedarf (nicht Teil von Stufe 1): ältere Einträge unter „Unveröffentlicht“ in `CHANGELOG.md` auf eine Zeile verdichten (der Abschnitt wächst bis zum nächsten Release), das Protokoll in `ARBEIT-BETRIEB.md` (9,8 KB) rotieren, die eine überlange Vorratszeile kürzen.

## 5. Validieren

**Vorab, am selben Tag (je 5 Minuten):**
1. Eine Nachricht schicken und die Sitzung fragen, welche „Systemzeit (Berlin)“ sie sieht. Das prüft, ob die Hook-Ausgabe im Kontext ankommt.
2. Nach einem Zugende `.claude/regeltreue.tsv` ansehen: Kopfzeile und eine Datenzeile müssen da sein; steht dort „FEHLER“, stimmt meine Annahme über den Aufbau des Verlaufs nicht (siehe 6).
3. `/context` direkt nach dem Start einer Tom-Sitzung, einmal mit alten und einmal mit neuen Startregeln. Das ist die genaue Zahl für die Tabelle in 4.

**Wirkung (eine Woche):** Wenn Zeit ist, erst 2 bis 3 Tage nur den Zähler (3.4) laufen lassen als Basis, dann Stufe 1 einschalten. Verglichen wird mit dem Zähler und mit dieser Zählliste je Sitzung (Sokrates oder Diogenes):
- Chat-Antworten ohne etwas zum Entscheiden, Tun oder Prüfen
- Entschuldigungen
- geschätzte oder falsche Uhrzeit
- „fertig“ gemeldet ohne Standbild oder Film und ohne fremde Prüfung
- wiederholter Fehler aus „Bekannte Fehler“
- Regel, die in einer Datei stand und nicht beachtet wurde (welche?)

Mindestens drei Sitzungen je Variante, weil Sitzungen stark schwanken.

**Auswertung nach Kontextgröße:**

```bash
awk -F'\t' 'NR>1 && $1!="FEHLER" {b=int($4/50000)*50; n[b]++; w[b]+=$5; e[b]+=$6} END{for(b in n) printf "%dk-%dk\t%d Zugenden\t%.0f Wörter im Schnitt\t%d Entschuldigungen\n", b, b+50, n[b], w[b]/n[b], e[b]}' .claude/regeltreue.tsv | sort -n
```

Falsche Zeitstempel (Abweichung über 3 Minuten):

```bash
awk -F'\t' 'NR>1 && $7==1 && $8>3' .claude/regeltreue.tsv | wc -l
```

## 6. Neustart-Schwelle

Jetzt nicht ändern. Der Zähler schreibt je Zugende die Kontextgröße (`kontext_token`) und die Prompt-Nummer mit. Steigen Wörter und Entschuldigungen ab einer bestimmten Größe (Auswertung in 5), setzt Sokrates die Schwelle knapp davor. Der Start ist mit Stufe 1 billiger, ein Neustart kostet dann weniger, das spricht eher für eine niedrigere Schwelle. Wo die Schwelle eingestellt ist (vermutlich `tools/neustart-haken.py`), weiß ich nicht.

## 7. Offene Annahmen und Grenzen

- Ich nehme an, dass die Ausgabe von `UserPromptSubmit`-Hooks im Kontext ankommt (Test 5.1) und dass der Verlauf als JSON-Zeilen mit `type: "assistant"`, `message.content[].text` und `message.usage` vorliegt. Der Zähler wurde nur mit einem selbst gebauten Verlauf getestet, nicht mit einem echten.
- Ob Sitzungen die Kernregel-Zeile befolgen, ist offen. Sie wirkt nur, wenn `notiz.sh` vor der Antwort aufgerufen wird; der Hook ist die Absicherung.
- Ich kenne `tools/commit-pruefung.py`, `tools/regelcheck.py`, `tools/neustart-haken.py`, `tools/zug-haken.py` nicht; dort liegen vermutlich schon mechanische Prüfungen. Bitte vor dem Bau neuer Prüfungen ansehen.
- Der Zähler kann später auf Blockieren umgestellt werden (zum Beispiel bei Entschuldigung oder falschem Zeitstempel). Das kostet je Treffer eine zusätzliche Runde und sollte erst nach den ersten Zahlen entschieden werden.

## 8. Entscheidungen für Sokrates

1. Reihenfolge und wer umsetzt (Technik und Skripte: das Team, dem der Chef es zuteilt).
2. Ob die Telegram-Regel (3.5 c) so geändert wird.
3. Ob zuerst eine Basis gemessen wird oder gleich Stufe 1 startet.
4. Ob nach den ersten Zahlen die Stufe 2 (Auslagern aus der `CLAUDE.md`) getestet wird.
