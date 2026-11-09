# 719 · Wochentermine selbsttätig in die Vorgangsliste · Sokrates · 09.11., 08:53
B Abläufe

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/PRUEFBERICHT.md

**Anlass:** Diogenes, Wochenzählung 09.11. (Lauf 92): Ideenspeicher Homer drei Sonntage in Folge ausgefallen, Rollenspiegel Fr 06.11. und Tagesbericht 06.11. ausgefallen. Ursache: Wochentermine stehen nur in den Rollendateien; Ford startet nur Zeilen der Vorgangsliste. Nachgeholt als 715, 716 (Chef 08:49).

**Frage:** Sollen Wochentermine sich selbst als Vorgang anlegen?

- **A (Empfehlung):** `startbar.py` legt jeden Wochentermin an seinem Tag als Muss beim Besitzer an (Ideenspeicher So Homer, Rollenspiegel Fr Perikles, Wochenzählung Mo Diogenes, Wochenziel Mo Perikles); Ford startet ihn wie jeden Vorgang; Diogenes zählt Ausfälle wie bisher. Gegenargument: kostet jede Woche Guthaben, auch wenn es knapp ist; jeder Termin ist aber kurz (eine Sitzung).
- **B:** Termine streichen, die drei Wochen in Folge ausfielen (Ideenspeicher), Rest wie heute. Gegenargument: Ideen bleiben liegen, „sehen heißt sagen“ läuft ins Leere.

Antwort: „719 A“ oder „719 B“.
