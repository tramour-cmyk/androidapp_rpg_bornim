# 654.2 · Vorentscheid billigen: Braucht der erste Messlauf ohne Bild je Vorgang und Tag noch eine Freigabe von Sokrates?
Sokrates · 16.11., 01:30 · B Abläufe · Systemrunde 654 (teuerste Vorgänge der Woche 09.–15.11.)
Kurz: Messläufe ohne Bild (nur Zahlen, nichts für dich) laufen einmal am Tag je Vorgang ohne mein Wort; Filme und Bilder bleiben wie 621 A.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/71624e486/tools/probelauf.py#L593-L595 (bild=nein ist erkennbar; dazu Vorgangsarchiv 09.–15.11.: 77 Freigaben „Läufe frei“ von mir, Kostenbericht 16.11., 01:22)

**Frage:** Jeder Lauf auf dem Bauserver zählt heute als Probe; einen weiteren gibt nur ein Archiveintrag „<Nr>, Läufe frei“ von mir frei (621 A, 646). Darunter sind Messläufe ohne Bild (`bild=nein`): Sie liefern nur Zahlen, um die Ursache eines Fehlers zu finden, du siehst davon nichts. Muss Sokrates die einzeln freigeben?

**Entschieden:** Der erste Messlauf ohne Bild je Vorgang und Tag läuft ohne meine Freigabe, wenn der oberste Commit eine Zeile „Messfrage: <was der Lauf klären soll>“ trägt. Er wird wie jeder Lauf gezählt; nur die Freigabe entfällt. Der zweite am selben Tag braucht wie bisher die Freigabe von Sokrates. Bildläufe und Filme bleiben unverändert (eine Probe vor dir, 621 A).

**Umgesetzt:** 16.11., `probelauf.py` (Perikles, 654.2), Geprüft an: 40b4e09e8.

**Rückbau:** die Ausnahme in `probelauf.py` streichen, ein Commit.

**Kosten:** Bau etwa 3 $; spart etwa 15–20 Freigaben je Woche (von 77) und die Wartezeit der Teams nachts, bis ich wach bin.

**Berührt:** 621 A, 646 (Zählung bleibt, nur die Freigabe des ersten Messlaufs entfällt), 334 (Ursache nachstellen), alle Teams.

**Begründung:** Diese Woche 77 Freigaben, davon etwa 18 Messläufe ohne Bild; jede weckt mich oder lässt ein Team warten. Gefragt wird dort nichts, was du sehen sollst. Abgleich: Leitbild, Stil, Kampf, Abnahme, Bornimer Rollenspielsystem nicht berührt; Archiv 621 A und 646 regeln Proben vor dir, die bleiben; 334 („Ursache nachstellen“) wird gestärkt, weil der Messlauf genau das ist.

**Sachverhalt:**
- Freigaben 09.–15.11.: 870.4 sechsmal, 709.1, 264.1, 1215 je fünfmal, 1043 viermal; Commits mit „Lauf frei“ geschätzt 86 $.
- Häufigster Grund für einen Messlauf: „am Rechner ohne gekauftes Modell nicht nachstellbar“ (viermal im Archiv); das löst die Rechteprüfung (1351, Zugriff aufs Kaufrepo 797), nicht dieser Vorentscheid.
- `probelauf.py` erkennt bild=nein schon (Zeile 595).

**Auswertung:**
- **A (entschieden):** erster Messlauf je Vorgang und Tag frei mit „Messfrage:“; Kosten oben.
- **B:** alles bleibt; ich gebe jeden Lauf frei. Kostet nichts zu bauen, aber weiter etwa 18 Wecker je Woche.
- **Weiteres Gegenargument:** eine laufende Ausgabe ohne Prüfung (Bauserver-Zeit, Regel 621: Guthaben ins Spiel statt in Proberunden). Dagegen: höchstens ein Lauf je Vorgang und Tag, Diogenes zählt.
- **Stärkstes Gegenargument gegen A:** Die Freigabe hat in der Nacht 13.11. die Reihe 709.1 gestoppt (sechs Läufe, Ursache nur vermutet). Dagegen: der zweite Lauf am Tag braucht weiter die Freigabe, genau dort hat der Stopp gegriffen; und die Zeile „Messfrage:“ zwingt, die Vermutung vorher hinzuschreiben.

**Folgerungen:** Perikles baut 654.2; Diogenes zählt am 23.11. Freigaben je Woche (Ziel unter 60) und Messläufe je Vorgang. „zurück“: Rückbau als Muss bei Perikles.

Antwort: …
