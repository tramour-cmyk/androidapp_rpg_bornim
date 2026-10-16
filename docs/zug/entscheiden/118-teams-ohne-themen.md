# 118 · Teams ohne Themen: eine Liste für beide?

Sokrates Projekt · 16.10., 13:35 · Anlass Chef 16.10., 13:3x: „wie wäre es, wenn die … nicht mehr thematisch arbeiten, sondern arbeiten einfach die Liste ab und ergänzen sich im Sinne von, okay, ich brauche das andere, dann mach doch du das, ich mach das. Also keine thematische Trennung mehr. Was spricht dafür, was spricht dagegen?“

Kurz: Bereiche bleiben, aber wer nichts Startbares hat, nimmt die oberste freie Zeile des anderen Teams (Empfehlung B)

**Frage:** Lösen wir die Bereiche von Team Tom und Team Jerry auf (A), lockern wir sie (B) oder bleibt es (C)?

**Stand heute (13:35):** Tom: 10 offen, praktisch alles wartet auf Chef oder andere, Übergabe „Nachfolger: keiner jetzt“. Jerry: 28 offen, 11 warten auf Chef, 12 PRs (#70, #72–#82) warten auf deinen Test, Pause bis 13:20 (Stundenkontingent Pro leer). Die Last ist ungleich: Max hat Luft, Pro nicht.

**Dafür (Auflösung):**
- Keiner läuft leer, während der andere überläuft (heute genau der Fall).
- Vorrang gilt über beide: das Wichtigste wird zuerst gebaut, nicht das Wichtigste je Bereich.
- Fällt Pro aus, arbeitet Max einfach weiter; die Sonderfälle „Guthaben leer / stiller Ausfall / Rückkehr“ in `FIRMA.md` würden fast überflüssig.

**Dagegen:**
- **Der Engpass ist dein Test, nicht das Bauen.** 12 Builds warten schon. Mehr parallel bauen verlängert die Schlange und erhöht Rückläufer, weil Builds älter werden und öfter neu gebaut werden müssen (Nummern nur aufsteigend).
- **Kontext kostet:** wer Klang oder Kampf nicht kennt, liest sich erst ein; der erste Wurf in fremdem Gebiet fällt eher durch (Maß der Teams: Test passt beim ersten Mal).
- **Zwei Accounts sehen sich nicht**, nur über `main`. Bei einer gemeinsamen Liste greifen zwei Sitzungen dieselbe Zeile; nötig wäre ein Belegen per Push vor dem Start.
- **Zuständigkeit verwischt:** wer bestätigt Diogenes-Befunde, wer hält die Zeile nach, wer hat den Überblick über Klang oder Dorf.
- Umbau an vielen Orten (Regel 6, `ROLLE-TEAM.md`, `FIRMA.md`, Vorräte, Besetzung) mitten im Sparmodus.

**Empfehlung B (Bereiche lockern, nicht auflösen):** Jedes Team behält seinen Vorrat als Heimat. Neu: Hat ein Team nichts Startbares (alles wartet auf Chef oder andere), nimmt es die oberste freie Zeile des anderen Teams; vorher in dessen Vorrat „übernommen von Tom, Zweig …“ eintragen und pushen (belegt die Zeile über `main`, auch über Accounts). `WorldScreen.kt` weiter nur nach Absprache; nie Tom und Jerry in einem Build bleibt.
- **Regelbilanz (90a):** ersetzt in `CLAUDE.md` Regel 6 „Keiner arbeitet an Zeilen oder Code eines anderen“ durch die Übernahme-Regel; `FIRMA.md` „Guthaben auf Pro leer / Stiller Ausfall“: Ford holt nicht mehr Team Jerry nach Max, Tom übernimmt Jerrys Zeilen (eine Regel weniger).
- Wirkung heute: Tom könnte z. B. Jerrys 59e (Händler, Vorrat je Laden) oder 18 (Gegnerstimmen) nehmen, solange Pro ruht.
- Bilanz am 23.10.: Übernahmen zählen, Rückläufer bei Übernahmen gesondert.

**Stärkstes Gegenargument gegen B:** Es löst den eigentlichen Engpass nicht; mehr Builds landen in deiner Schlange. Darum gilt mit B: übernommene Zeilen bevorzugt solche ohne Test am Gerät (Kerntests, Hörproben, Messungen), und Builds nur, wenn die Testreihe des anderen Teams nicht länger als 4 offene Builds ist.

**A** (volle Auflösung) erst, wenn B am 23.10. zeigt, dass Übernahmen ohne Rückläufer gelingen. **C** (bleibt) ist vertretbar, wenn du die Schlange erst abbauen willst.

**Prüfung Diogenes:** Ablaufentwurf, Zeile 118 in `ARBEIT-PRUEFUNG.md`; im Sparmodus (99d) startet Ford ihn nur auf deinen Zuruf („Diogenes 118“). Umsetzung von B nach deinem Ja, nicht vor Sa 21:00, außer du sagst „sofort“.
