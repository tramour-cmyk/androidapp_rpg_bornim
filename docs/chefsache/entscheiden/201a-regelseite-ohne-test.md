# 201a · Regelseite MARS ins Design ohne Gerätetest auf main?
Sokrates · 19.10., 14:34 · E Kampf · M

Frage (Chef 14:32): „Kann die Designanpassung des Infokastens zu Maß nicht einfach gepusht werden? Muss ich das wirklich ansehen?“

Empfehlung: ja. Jerry stellt die Regelseite (weißer Kasten, schwarze Schrift) auf die vorhandenen schwarz-goldenen Bausteine um, prüft selbst am Vorschau-Standbild und bringt Build 33 (PR #122) ohne weiteren Gerätetest auf `main`. Nur Farben und Rahmen, keine Spiellogik; Build 33 sonst vollständig getestet (33.1–33.5).

Stärkstes Gegenargument: „Kein Code auf `main` ohne Test des Chefs“; jede Ausnahme weicht die Regel auf. Hier klein, weil nur das Aussehen einer geprüften Seite.

Berührt: 201 (Jerry), 199, 200, 172c (gleicher PR).

Antwort: „ja“ oder „nein“.
