# 2034 Teil 0: Übergabe Edda (25.11., 18:29)

Nachfolger: Edda – 2034 Teil 0: Abzug (Figur)

Stand: Signatur-Probe und Liste fertig (Zweig `claude/figur-2034-abzug`, 8337e31fe; Rückmeldungen 18:29 in `docs/vorgang/2034.md`). Offen: der eine Beleglauf Abzug (243 Bilder), erst nach Freigabe des Prüfers (Laufanforderung 18:29).

Weiter (Befehle, Pakete neu laden wie in der Liste beschrieben, `p/M<n>` je Paket ausgepackt):
1. `bl/bin/python -I tools/blender348/v3/abzug_mh.py <p> <glb>` (bpy 5.2.3 im venv ~/bl), dann `python3 tools/godot/abzug_2034_liste.py <p> <glb>/liste.json docs/entwurf/2034-abzug.md <commit> <messung.json>` (setzt `lizenz`, `zeichnen`).
2. Nur Stücke mit „ja“: `NUR=` aus liste.json (zeichnen true), `PROBE=2034 LISTE=… GLB=… AUS=<roh> xvfb-run -a ~/godot/godot --path godot --rendering-method mobile -s res://tests/abzug_2034.gd > lauf.log`.
3. `tools/godot/abzug_2034.sh <roh> <liste.json> lauf.log docs/entwurf/2034-abzug <commit> abzug "" <NUR>`; jedes zehnte Bild ansehen; Häute (49) als `<Nr>_haut.png` noch ohne Randtext: im Skript ergänzen.
4. Rückmeldung „fertig“ mit Commit über `vorgang.py rueckmeldung 2034` in ../bornim-main.

## Nachtrag 18:46: Prüfer-Nein 18:42 (2034-Ü6, von Edda angenommen, an Nachfolger)

Erst lesen: `docs/vorgang/2034.md` Rückmeldung 18:42 und Hinweis 2034-Ü7. Kern:
1. Robe M36-05 und Stiefel M57-09: mit und ohne Tusche im Bild gleich; dunkles Stück (Helligkeit 0,09–0,16) auf blauschwarzem Grund, Tusche unsichtbar, die Messung (Umriss 54–55 %) widerspricht dem Bild. Tusche an dunklen Stücken sichtbar machen (Licht- oder Randkante gegen den Grund, nicht linear aufhellen), neues Probebild Robe und Stiefel; sonst „Frage“ mit Probebild. Messung in `abzug_2034_signatur.py` so ändern, dass sie die Sichtbarkeit misst (Kontrast Linie gegen Grund und Stück), nicht nur „dunkler als ohne“.
2. Stiefel füllen nur etwa 40 % der Höhe (Paar weit auseinander): Rahmung in `abzug_2034.gd` anpassen (z. B. einen Stiefel zeigen oder Paar enger); Pixelblöcke im Leder prüfen.
Laufbremse: Lauf 1 für 2034 ist verbraucht, nächster Bildlauf erst nach Prüfer-Ja zur neuen Laufanforderung.

## Nachtrag 19:17 (Edda, Nachbesserung 2034-Ü6, ohne Bildlauf)

1. Tusche an dunklen Stücken: `abzug_2034.gd` stellt hinter das Stück eine unbeleuchtete Wand mit kaltem Lichthof (Mitte 0,25/0,28/0,36, nach außen weich bis Grund); Stück und Shader unverändert, nichts aufgehellt.
2. Messung `abzug_2034_signatur.py`: neu „sichtbar“ = Umrisspunkte, an denen die Linie gegen Grund und Stück je mindestens 0,05 dunkler ist. Gegenprobe an den alten Probebildern (Maske aus dem Bild ohne Tusche genähert): sichtbar 0–2 % bei allen sechs, Linie gegen Grund −0,01–0,00; bestätigt das Prüfer-Nein.
3. Pixelblöcke: flache Normalen aus `abzug_mh.py`, Beleg `probe/M57-09_bloecke.webp`; behoben mit `me.shade_smooth()`, alle 194 Netze.
4. Höhe: Paare (Stiefel, Handschuhe) zusammengeschoben; M57-09 rechnerisch 42 % → 86 %. Je Stück `fuellt.tsv`, `UNTER80` gemeldet. Flache, breite Stücke (Hutkrempe, Handschuhe in T-Pose) können bei 2048×1024 mit vorn und Seite unter 80 % bleiben; dann Frage.
5. Häute: Bild mit Randtext und Vermerk im Skript ergänzt (9. Argument GLB-Ordner).
Offen: Probe-Lauf (Robe M36-05, Stiefel M57-09, dazu M29-04) nach Prüfer-Ja; bpy-venv ~/bl fehlt in diesem Behälter (neu anlegen).

## Nachtrag 19:52 (Edda): Probe-Lauf 2 (Sokrates 19:44) an 860900ac4

Lauf: abzug_mh.py (bpy 5.2.3, venv ~/bl neu) NUR=M29-04,M36-05,M57-09, dann `SIGNATUR=1 … abzug_2034.gd` (xvfb, OpenGL 3 nach Vulkan-Fehlschlag wie zuvor), Bilder `probe/M29-04|M36-05|M57-09.webp`, alt gegen neu `probe/M36-05_alt_neu.webp`, `probe/M57-09_alt_neu.webp`, Messung `probe/messung-860900ac4.json`, MARKE `probe/marke-860900ac4.txt`. Nach dem Lauf nur das Zusammensetzen geändert (Schrift: Ansichtszeile kleiner, Rand passt sich dem Messsatz an; Lizenz der Paketseite aus der Liste). Wartet auf Prüfer; Abzug erst nach Ja.

## Nachtrag 20:42 (Edda): Probe-Lauf 3 nach DESIGN-STIL A2 (2034-Ü14) an d0ed0dc33

Lauf `SIGNATUR=1 NUR=M36-05,M57-09,M29-04` an d0ed0dc33 (Lauf 3 von 3, kein weiterer ohne Freigabe). Sonne und Tusche aus `kampf/signatur.gd` (`sonne_wie_kampf`: −45, 55; `tusche_licht` Gruppe: px 0,8, dick 1,5, umriss_dick 1,3), Lampe auf der Sonnenseite. Bilder `probe/<Nr>.webp` (vorn mit | ohne), `probe/<Nr>_abzug.webp` (vorn | Seite wie im Abzug), `probe/<Nr>_licht_schatten.webp` (Ausschnitt 3-fach), Messung `probe/messung-d0ed0dc33.json`, Lauf `probe/marke-d0ed0dc33.txt`. Rahmen aller 194 Netze ohne Bildlauf: `2034-abzug/rahmen.tsv` (`abzug_2034_rahmen.py`, stimmt bei den drei Stücken mit dem Lauf überein).
Befund: Toon-Stufen 1 statt 3 (weißes Stück 0,98): Kampfort-Sonne ohne Tonwerte des Kampforts. Behebung ohne Lauf im Folgecommit (`Sig.einrichten` statt Einzelteilen), wartet auf Laufanforderung beim Prüfer.

## Nachtrag 21:38 (Edda): Lauf 4 frei, Neustart

Sokrates 21:39 (Archiv 96b91cc84): Lauf 4 für 2034 frei; Antwort wörtlich in `docs/vorgang/2034.md` (zuerst lesen, auch zu den 19 breiten Stücken). Frage war 2034-Ü18 (20:43).
Nachfolger: Edda – 2034 Teil 0: Probe-Lauf 4 (Figur)
Weiter: Pakete neu laden und `abzug_mh.py` wie Nachtrag 20:42 (Skript `lade.sh`-Weg: Paketseite → `files.makehumancommunity.org`-Zip, `p/M<n>`), `abzug_2034_liste.py` für `zeichnen`, dann genau ein Lauf `SIGNATUR=1 NUR=M36-05,M57-09,M29-04` an 1806d5665 (oder Behebung nach Sokrates), danach `abzug_2034_signatur.py`, `abzug_2034_seiten.py`, `abzug_2034.sh … probe`; prüfen: Toon-Stufen wieder 3, Tusche Schatten breiter als Licht; alt (d0ed0dc33) gegen neu; dann Prüfer, dann Probe an den Chef.

## Nachtrag 22:10 (Edda): Probe-Lauf 4 an 1806d5665

Lauf `PROBE=2034 SIGNATUR=1 NUR=M36-05,M57-09,M29-04` 22:06–22:07 (Freigabe Archiv „2034, Lauf frei“ 22:05), OpenGL 3 nach Vulkan-Fehlschlag, Tonemap 2 (Filmic) aus `Sig.einrichten`. Bilder `probe/<Nr>.webp`, `<Nr>_abzug.webp`, `<Nr>_licht_schatten.webp`, alt (Probe 3) gegen neu `<Nr>_alt_neu4.webp`, Messung `probe/messung-1806d5665.json`, Lauf `probe/marke-1806d5665.txt`.
Befund: Tusche gelingt (Linie Schattenseite 1,69 / 1,82 / 1,80 px gegen Lichtseite 1,00 / 1,11 / 1,00 px bei Robe, Stiefel, Helm). Toon-Stufen nicht behoben: weißes Prüfstück jetzt überall 1,00 (vorher 0,98), Stufenmessung leer (NaN); Helm im Bild heller und flacher als in Probe 3; an Stiefel und Robe Licht-Schatten-Grenze sichtbar. Ursache offen (Filmic/Kontrast aus `Sig.einrichten` übersteuert Weiß, Belichtung der Bühne fehlt?). Kein weiterer Lauf ohne Freigabe.
