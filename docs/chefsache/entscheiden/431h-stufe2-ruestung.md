# 431h (Rüstung sichtbar) · Stufe 2: soll man jede angelegte Rüstung am Helden sehen, auch fremde Stücke und Plattenrüstung (etwa 40 bis 70 $)?
Tom · 17.11., 00:51 · E Figuren · Folge aus deinem 👍 zu Stufe 1 (16.11., 18:47: „danach Stufe 2 als Vorlage“)
Kurz: Stufe 2 zeigt jede angelegte Rüstung mit ihrem eigenen Teil, auch Stücke anderer Herkünfte und die Ritterteile; Aufwand und Risiko hier.
Beim Chef, weil: Aussehen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/69285b8a3 (`claude/tom-431-ausruestung`; `tools/gegenstaende/gegenstaende.json` Feld `netz`, `godot/skripte/heldfigur.gd` `kleide` 381–408, `tools/blender348/v3/held_klassen.py` `schrank`); Größe der Heldenmodelle am Rechner gemessen (Stand `main`, 17.11.): je Tracht und Geschlecht 7,8 bis 8,1 MB, zehn Stück
Beim Chef, weil: Aussehen (wie der Held in jeder Rüstung aussieht)

**Frage:** Seit Stufe 1 trägt der Held, was in seinen Plätzen steht, aber nur in den Teilen seiner eigenen Tracht: legt der Wachsoldat Lederstiefel an, sieht man weiter seine Stiefel; legt jemand eine Brustplatte an, sieht man sein Kettenhemd oder Wams. Stufe 2: jedes Stück zeigt sein eigenes Teil, auch aus einer anderen Tracht (Lederrüstung am Wachsoldaten) und die Ritterteile, die heute keine Tracht hat (Brustplatte, Plattenpanzer, Topfhelm, Panzerhandschuhe, Beinschienen, Stirnreif). Willst du das jetzt bauen lassen?

**Votum:** „431h Stufe 2 A“: bauen wie unten (Deckel 70 $), Messung am Rechner, dann Film an dich; besteht die Messung nicht, kein Film, es ruht.

**Berührt:** 431 (Tom), 455.2 (Netzliste je sichtbarem Platz, ruht; mit Stufe 2 für Kapitel 1 erledigt), 1341 (Ausrüstungsseite, Drehteller), 476 (Symbole aus den Modellen), 1297 (Schildgröße je Volk), Ladezeit und Speicher am Handy (1270, Spike)

**Begründung:** Du, 15.11., 17:13: „dass ich ausgerüstet habe … aber man sieht ja nichts am Helden“. Stufe 1 hat die Plätze ehrlich gemacht; deinen Fund behebt erst Stufe 2.

**Sachverhalt:**
- Zuordnung Stück → Teil steht schon in der Gegenstandsliste (Feld `netz`), aus der Vorlage 431h: Stirnreif → Krone (Adel) · Topfhelm → Ritterhelm · Brustplatte, Schienenpanzer → Ritter-Körper · Halbplatte → dazu runde Schulterstücke · Plattenpanzer → dazu Schulterstücke und Halsberge · Kettenhemd, Schuppen-, Kettenpanzer → unser Kettenhemd · Lederrüstung, Nietenleder → Waldläufer-Wams · Panzerhandschuhe, Kroggs Pranken → Ritter-Arme · Armschienen → Kloster-Arme · Kettenbeinlinge → Waldläuferhose mit Stiefel · Beinschienen → Ritter-Beine und -Füße.
- Heute baut der Bau je Tracht ein Modell mit den Teilen dieser Tracht; `kleide` blendet nur Teile der eigenen Tracht ein. Fremde Stücke brauchen Teile aus den anderen Trachten im selben Modell, die Ritterteile gibt es noch in keinem.
- Fehlt im Bestand: Lederkappe und Helm (Netz „Kappe“), Mantel; Umhänge ruhen bis nach dem Meilenstein (431, Umhang).
- Größe: ein Heldenmodell 7,8 bis 8,1 MB; alle Teile in jedes Modell würde es geschätzt um die Hälfte bis das Doppelte größer machen (nicht gemessen; wird in der Messung gemessen, Ladezeit Dorf und Kampfort dazu).

**Auswertung:**
- **A (Empfehlung):** ein Kleiderschrank je Volkskörper und Geschlecht: alle Teile aus den fünf Trachten und die etwa zehn Ritterteile in einem Modell, `kleide` wählt je Platz das Teil nach dem Feld `netz` des angelegten Stücks (2 bis 3 Sitzungen, etwa 40 bis 70 $). Messung am Rechner: je Körper leichte, mittlere, schwere Rüstung und gemischt (Brustplatte mit Bauernärmeln, Kettenhemd mit Beinschienen), Nähte an Hals, Handgelenk, Knie, kein Durchstoßen in Stehen, Gehen, Hieb; Modellgröße und Ladezeit nicht schlechter als 20 %. Film: Drehteller je Volk in drei Rüstungen, alt gegen neu.
- **B:** nur die Ritterteile dazu, fremde Stücke weiter im Teil der eigenen Tracht (1 bis 2 Sitzungen, etwa 30 bis 40 $): Brustplatte und Plattenpanzer sieht man, Lederstiefel am Wachsoldaten nicht.
- **C:** bis nach dem Meilenstein ruhen, 0 $.
- **Stärkstes Gegenargument gegen A:** gemischte Sätze bergen das Nahtrisiko, an dem der Umhang auf denselben Körpern nach etwa 220 $ ruht, und sichtbare Rüstung steht nicht in der Abnahmeliste für Kapitel 1. Darum Deckel 70 $ und „Messung nicht bestanden, kein Film, ruht“.

**Offene Fragen (beantwortest du mit, sonst gilt der Vorschlag):**
1. Lederkappe und Helm: bis zu einem eigenen Teil als Kapuze zeigen (wie Stufe 1).
2. Mantel: als Umhang zeigen, sobald der Umhang nicht mehr ruht; bis dahin unsichtbar.

**Folgerungen:** Bei A oder B: Tom baut auf `claude/tom-431-ausruestung` (nach Build 295, damit Stufe 1 vorher getestet ist), Messung, Film an dich, dann Sammelbuild mit Prüfzeile (Rüstung an- und ausziehen am Handy). Bei C: 431h ruht bis nach dem Meilenstein, Tom nimmt den nächsten Vorgang.

Antwort: …
