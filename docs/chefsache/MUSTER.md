# Muster einer Vorlage (364, 799)

Für `entscheiden/` und `billigen/`. Chef 09.11., 20:45 zu 758: „Ich verstehe die Frage, ich sehe ein Votum, ich sehe, was betroffen ist, ich sehe eine Begründung, ich sehe einen Sachverhalt, ich sehe eine Auswertung dazu. Also perfekt. So soll es sein.“

`tools/probelauf.py` hält einen Commit oder Push an, der eine Datei ohne diese Teile nach `main` bringt; die Übersicht meldet Altbestand unter „Lücken“. Prüfen von Hand: `python3 tools/vorlage_pruefen.py <Datei>`. Entwurf außerhalb der beiden Ordner schreiben, dann vollständig anlegen.

## Zum Kopieren

```markdown
# <Nr.> · <die Frage an den Chef, als Frage>?
<Absender> · <TT.MM.>, <HH:MM> · <Bereich, z. B. E Welt> · <Anlass, z. B. aus deinem Wort 14:29>
Kurz: <ein Satz für die Übersicht>

Geprüft an: <Link, Commit oder Lauf>
Beim Chef, weil: <Code auf main, Geld, Lizenz, Story, Aussehen, neue Richtung im Spielgefühl, Release, Rollen und Accounts> (nur `entscheiden/`, 1129 A 1; sonst entscheidet das Team, Perikles oder Sokrates per Vorentscheid)

**Frage:** <ausführlich, so dass der Chef sie ohne Vorwissen versteht>

**Votum:** „<Nr.> A“: <was der Chef sagen oder tun soll>

**Berührt:** <Vorgänge und Rollen, die sich mitändern>

**Begründung:** <warum, kurz; Chefwort im Wortlaut, wenn es eines gibt>

**Sachverhalt:**
- <belegt, mit Quelle: alte Fassung, Godot, Bestand>

**Auswertung:**
- **A (Empfehlung):** <Weg, Kosten>
- **B:** <Weg, Kosten>
- **Stärkstes Gegenargument gegen A:** <…>

**Folgerungen:** <was nach der Antwort geschieht, wer>

Antwort: …
```

Bei `billigen/` (Vorentscheid, 194.1) statt **Votum** die Marke **Entschieden:**, dazu **Umgesetzt:** (Commit), **Rückbau:** und **Kosten:**; Zeile 1 fragt „Vorentscheid … billigen?“.

## Checkliste Vorlage an den Chef

Probe 903 B (Chef 11.11., 07:46) über etwa zehn Vorlagen; Diogenes zählt, wie viele wegen der Form zurückkommen (905). Gesammelt, nicht neu: je Punkt die Quelle, dort gilt der Wortlaut. `probelauf.py` zeigt die Liste einmal je Sitzung, sobald ein Commit oder Push eine Datei in `entscheiden/`, `billigen/`, `tun/` oder `ansehen/` (außer Prüflisten `t<n>-…`, dafür `LISTE-CHECK-BUILD-TEST.md`) anlegt oder löscht.

1. **Nur Chefsache:** was der Chef entscheiden, tun oder ansehen soll; was du nach deiner Rollendatei selbst entscheidest, entscheidest du (`CLAUDE.md` Zusammenarbeit 3, 8; Lehre 715).
2. **Nummer zuerst:** `vorgang.py neu`, pushen, dann nennen; Dateiname die Nummer ohne Punkt (`CLAUDE.md` „Nummern“, „So geht's“).
3. **Probe wie der spätere Bau** (Bekannte Fehler, 302.3); Bild mit Signatur, sonst in derselben Zeile der Vergleich „mit Tusche“ (457, Commit-Prüfung hält an). Eigenbau mit Zeile „Bestand geprüft: <Datei, Teil> genommen“ oder „… fehlt im Bestand“ (434).
4. **Aufbau** nach „Zum Kopieren“ oben, ohne Vorwissen verständlich; Sachverhalt mit Quelle; in der Auswertung das stärkste Gegenargument (Haltung 1); das Votum sagt, was der Chef sagen oder tun soll (364, 799).
5. **Bilder** in `bilder/`: JPG oder WebP, höchstens 800 px, 60 KB, 3 je Punkt; Größeres und Hörproben nur über Telegram `--datei`, vermerkt „Großbild: Telegram TT.MM. HH:MM“; Filme im Zweig `bilder` (`chefsache/README.md` „So geht's“, 381.1).
6. **`ansehen/` ohne Build** nur mit Bild, Film oder Frage; was der Chef tun soll, steht in `tun/` (890, Commit-Prüfung hält an).
7. **Überarbeiten:** Datei löschen, neu anlegen, wenn fertig; nie „folgt“ (275).
8. **Telegram:** Standbild als PNG `--bild`, Bewegung nur als Film `--film`; vorher selbst ansehen (beim Film ein Standbild daraus), dann sofort an den Chef, ohne Helfer und Probebild; Text vorher fremd prüfen; `--laut` nur, wenn der Chef dran ist (`CLAUDE.md` Zusammenarbeit 9; 655, 783 W1, 338.2).
9. **Text an den Chef:** keine Abkürzung (auch nicht „NW“, „BRS“, „K1“), Dateien mit Namen, Vorgänge mit Wort dazu, Chefsache als Sprungmarke; Helferbefund als Text nachsenden (485 (3), Bekannte Fehler).
10. **Nach der Antwort:** Wortlaut mit Zeit ins Vorgangsarchiv, kurz, nie umformuliert (t78); im selben Commit die Datei löschen, auch die eines anderen, und jeden Folgeauftrag beim Betroffenen eintragen (383.3, 783 W8; Commit-Prüfung hält an). Bleibt ein Teil offen, legt der Besitzer neu an; Vorlage mit „Was du tust“ gelöscht → Datei in `tun/` (890).

## Beispiel

758 (Tom, 09.11., 20:41), vom Chef als Muster genannt: `git show 65f56ef8a:docs/chefsache/entscheiden/758-sitzen.md`.
