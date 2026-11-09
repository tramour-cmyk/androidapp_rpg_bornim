# Muster einer Vorlage (364, 799)

Für `entscheiden/` und `billigen/`. Chef 09.11., 20:45 zu 758: „Ich verstehe die Frage, ich sehe ein Votum, ich sehe, was betroffen ist, ich sehe eine Begründung, ich sehe einen Sachverhalt, ich sehe eine Auswertung dazu. Also perfekt. So soll es sein.“

`tools/probelauf.py` hält einen Commit oder Push an, der eine Datei ohne diese Teile nach `main` bringt; die Übersicht meldet Altbestand unter „Lücken“. Prüfen von Hand: `python3 tools/vorlage_pruefen.py <Datei>`. Entwurf außerhalb der beiden Ordner schreiben, dann vollständig anlegen.

## Zum Kopieren

```markdown
# <Nr.> · <die Frage an den Chef, als Frage>?
<Absender> · <TT.MM.>, <HH:MM> · <Bereich, z. B. E Welt> · <Anlass, z. B. aus deinem Wort 14:29>
Kurz: <ein Satz für die Übersicht>

Geprüft an: <Link, Commit oder Lauf>

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

## Beispiel

758 (Tom, 09.11., 20:41), vom Chef als Muster genannt: `git show 65f56ef8a:docs/chefsache/entscheiden/758-sitzen.md`.
