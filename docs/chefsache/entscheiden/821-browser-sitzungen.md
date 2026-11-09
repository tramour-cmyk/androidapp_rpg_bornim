# 821 · Deine Browser-Sitzungen Tom und Jerry auf das große Modell stellen und Fords doppelte Sitzungen archivieren?
Sokrates · 09.11., 22:45 · B Abläufe · aus deinem Wort 22:44 („Kannst du das mal checken?“)
Kurz: Browser-Sitzungen haben beide Repos, laufen aber auf dem kleinen Modell; Tom und Jerry sind doppelt besetzt

Geprüft an: https://claude.ai/code/session_01Hmoj79SzkTzkNvs2XD48fD (Tom), https://claude.ai/code/session_01Hmoj76oi6MckqboXAF3HM5 (Jerry), https://claude.ai/code/session_01Hmoj78xzFvBQ6it6HDfWph (Ford); `get_session` 22:45

**Frage:** Deine drei Sitzungen aus dem Browser haben beide Repos (Spiel und Kaufmodelle), laufen aber auf dem kleinen Modell; die Startzuordnung (`LISTE-BETRIEB.md`) will für Tom und Jerry das große. Zugleich hat Ford eigene Sitzungen gestartet, so dass Tom, Jerry und Ford je doppelt laufen. Welche bleiben?

**Votum:** „821 A“: in deinen Browser-Sitzungen Tom und Jerry das Modell laut Startzuordnung umstellen und mit ihnen weiterarbeiten; Ford archiviert nach Übergabe „Tom – 819“, „Jerry – 562“ (22:37) und „Ford“ (22:32).

**Berührt:** 391, 818 (Sitzungen nachts länger offen), 819 Sammelbuild 273 (Tom), 562 (Jerry), Startzuordnung `LISTE-BETRIEB.md`, „keine Klone“ (`CLAUDE.md`)

**Begründung:** Chef 21.10.: „jeden Mitarbeiter gibt es genau einmal, keine Klone“. Nur Browser-Starts binden das Kaufrepo ein (Probe 22:42 über `create_session`: ohne Repo).

**Sachverhalt:**
- Browser-Sitzungen Tom, Jerry, Ford: Quellen `androidapp_rpg_bornim` und `bornim-kaufmodelle`, Modell das kleine (für Ford richtig).
- Ford-Starts: „Tom – 819: Sammelbuild 273“ (22:42), „Jerry – 562“ (22:37), beide nur mit dem Spiel-Repo; „Ford“ (22:32) wartet auf „820 erlaubt“.
- Browser-Jerry prüft dasselbe wie Jerry 562 (Gang aus Build 272 vor dem Bau von 562).

**Auswertung:**
- **A (Empfehlung):** Browser-Sitzungen bleiben, Modell umgestellt; Ford-Doppel weg. Kosten: zwei Handgriffe von dir.
- **B:** Fords Sitzungen bleiben (richtiges Modell, aber ohne Kaufrepo), Browser-Sitzungen archivieren.
- **Stärkstes Gegenargument gegen A:** Tom 819 steckt vielleicht mitten im Sammelbuild; Weg: Tom 819 bleibt bis zum Ende des Builds, deine Tom-Sitzung pausiert so lange.

**Folgerungen:** Ford archiviert nach deinem Wort; künftig startest du Tom und Jerry, wenn sie das Kaufrepo brauchen, im Browser (oder 818 bleibt).

Antwort: …
