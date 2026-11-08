# 655 · Warum das falsche Bild entsteht: der Maler sieht sein Bild nie · Sokrates · 08.11., 14:5x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/CLAUDE.md

**Anlass (Chef 14:46 zu 623.6; 14:51):** „Warum entsteht überhaupt ein weißes Bild mit ein paar schwarzen Krickeln drauf? … nicht, brauchen wir noch mehr Regeln“. Der frühere Vorschlag (Helfer-Vorprüfung) ist zurückgezogen.

**Wo der Fehler ist** (nachgesehen in Toms Vorrat, Zu 623.6, und in `CLAUDE.md`):
1. **Gebaut:** die Probe zeichnete alle Felder nacheinander in derselben Szene; das Wetterpaket stellte Nebel und Sonne um und wurde nicht zurückgesetzt. Ab dem Nebelfeld ist alles weiß, auch unsere eigene Fassung. Eine Ursache, Tom hat sie behoben (`35e4c163c`).
2. **Warum es keiner merkte:** Tom hat sein Bild nie angesehen. Das verlangt unsere Regel: „Standbilder … nie im eigenen Gespräch ansehen: das tut ein Helfer“ (300, Kontext sparen); 396 schickt es vor dem Helfer. Wer malt, malt also mit verbundenen Augen. Ein Mensch, der zwei Bilder malt, sieht beim Malen hin.
3. **Nebenbei:** der Bauserver hat keine Grafikkarte, gezeichnet wurde im Ersatzzeichner, nicht wie auf dem Handy.

**Frage:** Regel 300 streichen: wer ein Bild oder einen Film macht, sieht es selbst an, bevor er es schickt („zeigt es, was es zeigen soll?“), und schickt es dann sofort (396 bleibt: kein fremder Prüfer hält auf). Der Helfer nach dem Senden entfällt. Eine Regel weniger, keine neue.

**Votum Sokrates: ja.**

## Auswertung
- **Stärkstes Gegenargument:** 300 entstand, weil Bilder das Gespräch füllen und Guthaben kosten. **Antwort:** ein Standbild kostet einen Bruchteil eines Probelaufs; ein kaputtes Bild kostet einen Lauf, deine Zeit und dein Vertrauen. Bei Filmen sieht der Ersteller ein Standbild daraus an, nicht den ganzen Film.
- Gegenargument: der Ersteller sieht Eigenes zu gnädig. **Antwort:** über Schönheit urteilst weiter nur du; er soll nur sehen, ob das Bild das Gemeinte zeigt (Welt mit Boden und Farbe, kein weißes Feld). Das sieht jeder.
- Punkt 1 und 3 brauchen keine Regel: Ursache behoben; Handywert zeigt erst ein Build.

## Folgerungen
„655 ja“: Perikles streicht in `CLAUDE.md` „Melden“ den Halbsatz „nie im eigenen Gespräch ansehen: das tut ein Helfer … (300)“ und den Helferbefund danach, ebenso in `ROLLE-ENTWICKLUNG.md`; „Nie einen Helferbefund verschweigen“ (Bekannte Fehler) bleibt für Texte.
