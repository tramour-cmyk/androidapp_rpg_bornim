# 1727 · Grobablauf neu, frei gedacht (Entwurf Sokrates, 19.11.)

Auftrag Chef 19.11., 08:30: frei gedacht, wie die Firma arbeiten kann; Ziel winzige Prompts, was in jede Sitzung muss, ultrakompakt. Entwurf zum Besprechen, nichts davon gilt. Weisungen bisher sind kein Hindernis (Leitlinie 08:18). Quellen und Chefworte: `1625-prompts-kuerzen.md`. Durchnummeriert auf Wunsch des Chefs (09:33): Abschnitt 1, Punkt 1.1, Kasten im Diagramm 2.1.

## 1 Der Gedanke in drei Sätzen

- **1.1 Wissen wird geladen, wenn die Aufgabe es braucht, nicht vorab.** Jede Sitzung bekommt nur einen winzigen Sockel (etwa 0,5 KB) und ihren Auftrag (höchstens 1,5 KB). Handwerk liegt als Profil (Skill) bereit und lädt nur bei Bedarf.
- **1.2 Am Spiel arbeiten und die Firma verwalten sind getrennt.** Wer baut, kennt keine Vorgangsliste, keinen Vorrat und keine Melderegeln. Er bekommt einen Auftrag und meldet „fertig, hier der Beleg“. Alles Verwalten macht das Büro, und das meiste davon erledigt Code.
- **1.3 Regeln stehen nicht im Text, sondern in Werkzeugen oder im Auftrag.** Was ein Werkzeug prüfen oder verhindern kann, steht in keinem Prompt. Was nur für eine Aufgabe gilt, steht nur in deren Auftrag.

## 2 Flussdiagramm

```mermaid
flowchart TD
    C([2.1 Chef]) -->|Wort, Idee, Fund| S[2.2 Sokrates<br/>Gespräch mit dem Chef]
    S -->|Idee| I{2.3 taugt sie?}
    I -->|nein / später| IL[(2.4 Ideenliste)]
    I -->|ja| AB
    S -->|Entscheidung nötig| CS[(2.5 Chefsache)] --> C
    AB -->|braucht Entscheidung des Chefs| S
    S -->|Auftrag, Fund| AB{2.6 Büro: Abgleich<br/>gibt es das schon?}
    AB -->|derselbe Fehler, dasselbe Ziel| ALT[2.7 an den bestehenden Vorgang]
    AB -->|neu oder nur verwandt| V[2.8 Büro<br/>Vorgang anlegen, Bezüge, Vorrang]
    V --> A[2.9 Arbeitsvorbereitung<br/>Auftrag aus dem Baukasten, Prüfart]
    A -->|Auftrag + Profil| M[2.10 Macher<br/>frische Sitzung, nur dieser Auftrag]
    M -->|Fund außerhalb| AB
    M -->|fertig + Beleg| P{2.11 Prüfer<br/>Ziel erreicht? Prüfart des Auftrags}
    P -->|Fund außerhalb| AB
    P -->|nein, 1. Mal: erst Ursache nachstellen| M
    P -->|nein, 2. Mal: steckt fest| S
    P -->|ja| B[2.12 Büro<br/>eintragen, Warteschlange für den Build]
    B -->|wiederholt sich ein Fehler?| L[2.13 Lehre ins Profil<br/>nicht in einen Prompt]
    B -->|nächster Auftrag passt, Sitzung klein (3.9)| M
    B --> BA[2.14 Build-Auftrag an einen Macher<br/>Profil Build, Inhalt beim Start fest]
    BA --> T([2.15 Chef testet])
    T -->|gut| MAIN[(2.16 main)]
    T -->|Fund| S
```

## 3 Ergänzungen des Chefs, geprüft

Chef 09:14: „hast du wieder mein Feedback einfach eingebaut ohne dich damit auseinander zusetzen ob es sinnvoll ist“. Darum je Punkt: Wort, stärkstes Gegenargument, was sich ändert.

**3.1 Büro gleicht vor dem Anlegen ab** (09:00: „erstmal prüfen, ob es das alles schon gibt … Verweise auf andere Vorgangsnummern“). **Stimmt im Kern, zwei Einwände.**
- 3.1.1 *Sammelvorgänge:* „An einen bestehenden Vorgang hängen“ macht Vorgänge zu Sammelbecken; das verbietet heute schon die Regel „nie Fremdes unter eine Nummer“ (412). Darum anhängen nur bei **demselben Fehler oder demselben Ziel**; alles andere bekommt eine eigene Nummer und in der Spalte „Bezug“ die verwandten.
- 3.1.2 *Das Erkennen gibt es schon, das Handeln fehlt:* Unser Wiederholungswächter (654) legt längst Vorgänge „Systemlösung?“ an (1564 Wasser, 1635 Bogen, 1656 Kapuze). Sie liegen als Kür bei mir und sind nicht bearbeitet. Darum kommt die Systemfrage bei Bezügen **in den Auftrag der nächsten Behebung** (Pflichtfeld), statt als eigener Vorgang liegen zu bleiben.
- 3.1.3 *Ergänzt:* Der Abgleich ist Suche, also Code (Titel, Bereich, Dateien des Fundes); das Büro entscheidet nur zwischen den Treffern.

**3.2 Nicht alles ist ein Bild** (09:00). **Stimmt; Einwand: Nicht jede Prüfart kann eine KI verlässlich beurteilen.**
- 3.2.1 Belegt: 1694 meldete „grün“, das Bild zeigte den Fehler; 1650 Stiefel, 1653 Kragen gingen mit Bildern an den Chef, mit denen er nichts anfangen konnte. Bei Klang und Spielgefühl ist ein KI-Urteil noch schwächer.
- 3.2.2 Darum je Prüfart zwei Teile: **was der Prüfer selbst entscheidet** (messbar) und **was nur der Chef urteilt** (Aussehen, Klang, Spielgefühl). Dort prüft der Prüfer nur, ob der Chef damit urteilen kann, nicht ob es schön ist.

   | Nr. | Arbeit | Beleg | Prüfer entscheidet | Urteil |
   |---|---|---|---|---|
   | 3.2.3 | Aussehen, Figur, Welt | Bild in Spielkamera, Handygröße, alt gegen neu | Beleg taugt (Stelle mittig, markiert); **Sachverhalt** (liegt X in Y, sticht etwas durch) | Chef nur **Geschmack** (13.4.1) |
   | 3.2.4 | Bewegung | Film bis 15 s | zeigt den Moment, etwa dreimal; Sachverhalt (trifft er?) | Chef nur Geschmack |
   | 3.2.5 | Klang, Musik | Hörprobe im Spiel | spielt, Lautstärke im Rahmen, an der richtigen Stelle | Chef |
   | 3.2.6 | Regeln, Kampf, Balance | Rechnung bei 0, 24, 49, 74, 100, Kampfprotokoll | Zahlen stimmen mit dem Regelwerk | Prüfer; Spielgefühl Chef |
   | 3.2.7 | Spiellogik, Werkzeug | Test mit Befehl und Ausgabe | grün, Kerntests grün | Prüfer |
   | 3.2.8 | Spieltext | Abgleich mit `STORY-…` | wortgleich | Prüfer |
   | 3.2.9 | Spielgefühl, Ablauf | Durchspielprotokoll | läuft ohne Fehler durch | Chef |

**3.3 Rückläufer: wer legt an, wer fasst an** (09:00). **Stimmt, die Lücke war echt. Zwei Einwände gegen meinen ersten Wurf.**
- 3.3.1 *Drei Runden sind zu teuer:* Jede Runde ist eine Sitzung, und es gilt schon „nie einen Fehler zweimal mit Vermutung bauen“. Darum stellt derselbe Macher nach dem ersten Nein **erst die Ursache nach**, dann baut er; nach dem zweiten Nein geht es an Sokrates (steckt fest), keine dritte Runde.
- 3.3.2 *Kleinkram über das Büro kostet mehr als er nützt:* Ausnahme: **Tippfehler und Offensichtliches in den eigenen gesperrten Dateien** behebt der Macher und nennt es in „fertig“; alles andere meldet er.
- 3.3.3 Grundsatz: **Wer findet, meldet. Das Büro legt an. Die Arbeitsvorbereitung schreibt den Auftrag. Ein Macher baut.**

   | Nr. | Fall | Wer meldet | Wer legt an / entscheidet | Wer arbeitet ab |
   |---|---|---|---|---|
   | 3.3.4 | Ziel nicht erreicht, 1. Mal | Prüfer, mit Befund | bleibt im Vorgang | derselbe Macher: erst Ursache nachstellen, dann bauen |
   | 3.3.5 | Ziel nicht erreicht, 2. Mal | Prüfer | Sokrates: steckt fest | Sokrates klärt mit der Arbeitsvorbereitung: Auftrag, Profil oder Ursache falsch? Neuer Auftrag an einen frischen Macher, ggf. Chefsache |
   | 3.3.6 | Fund außerhalb des Auftrags | Macher oder Prüfer, eine Zeile „was, wo, Beleg“ | Büro: Abgleich (3.1) | wer laut Vorrang dran ist, mit eigenem Auftrag |
   | 3.3.7 | Tippfehler in eigenen Dateien | – | – | derselbe Macher, steht in „fertig“ |
   | 3.3.8 | Fund im Test des Chefs | Chef an Sokrates | Büro wie 3.3.6 | ebenso |
   | 3.3.9 | Ablauf oder Werkzeug hakt | wer es merkt | Büro (Regelwächter) | ein Macher mit Profil Werkzeug; Regel: Büro mit Sokrates |

**3.4 Werkzeug baut ein Macher mit Profil, nicht Spike** (09:14). **Stimmt**: Der Entwurf löst feste Fächer auf, die Nennung von Spike widersprach ihm; ebenso beim Build. Build und Werkzeug sind Profile wie Figur oder Klang. *Ergänzt:* Das Profil Werkzeug braucht drei feste Punkte, weil Werkzeuge jede Sitzung treffen: Kerntests vor dem Commit, kein Haken, der nur mahnt, Regelbilanz (ein neues Werkzeug ersetzt eine Textregel).

**3.5 Sind 4 KB für den Macher nicht zu groß?** (09:33: „Für Büro und Sokrates ggf. Ausnahme, aber generell?“). **Beim Sockel ja, beim Auftrag nein.**
- 3.5.1 *Sockel:* Von den acht Zeilen des ersten Wurfs kann ein Werkzeug fünf übernehmen oder ein Profil tragen (siehe 5). Es bleiben drei Zeilen, mit 3.7 vier, etwa 0,5 KB. Hier hattest du recht.
- 3.5.2 *Auftrag:* Er ist kein Ballast, sondern die Arbeit selbst: Ziel, Stand mit Ursache, Prüfpunkte. Kürzer heißt hier: der Macher sucht, was der Auftrag hätte sagen können, oder rät. Bei 1694 lag der Fehler genau im fehlenden Stand. Darum Grenze 1,5 KB als Zucht (höchstens fünf Punkte unter „Beachte“), aber kein Kürzen um jeden Preis.
- 3.5.3 *Stärkstes Gegenargument gegen mich:* Eine Grenze erzwingt Schärfe; ohne harte Zahl wachsen Aufträge wieder zu Abläufen. Entkräftet: Die Grenze steht im Baukasten, ein Werkzeug misst sie beim Start, und der Prüfer zählt, wie oft ein Auftrag als unklar zurückkommt (9.2).
- 3.5.4 *Zur Einordnung:* Claude Code lädt selbst schon einen Systemprompt und die Beschreibungen aller Werkzeuge, ein Vielfaches unserer Kilobytes, und während der Arbeit liest der Macher Code und Bilder. Was schadet, sind nicht die Bytes allein, sondern Unpassendes und Widersprüche (Quelle „Context Rot“ in 1625). Darum zählt: jede Zeile im Sockel wird in jeder Sitzung gebraucht, jede Zeile im Auftrag für genau diese Aufgabe.
- 3.5.5 *Büro und Sokrates:* Ja, Ausnahme: Sockel plus Kern von je höchstens 3 KB, weil sie Abläufe halten bzw. mit dem Chef sprechen. Auch dort lädt der Rest bei Anlass.
- 3.5.6 *Neu je Sitzung:* Macher etwa 2 KB (0,5 Sockel + höchstens 1,5 Auftrag), dazu ein Profil bei Bedarf; Prüfer ebenso; Büro, Sokrates, Arbeitsvorbereitung bis 3,5 KB. Heute: Macher etwa 75 KB.

**3.6 Homer wird Macher, Profil Story** (09:35: „Profil Story nicht mehr bei Homer, er wird Macher“). **Stimmt für das Schreiben; Einwand beim Zusammenhalt der Geschichte.**
- 3.6.1 *Dafür:* Was für Kapitel 1 an Text fehlt, sind greifbare Aufträge (Dialog einer Figur, Chroniktext, Menütext); die passen in den Baukasten (6). Entscheiden über Story tut ohnehin der Chef („nie selbst: Story“), ein Macher schlägt vor.
- 3.6.2 *Stärkstes Gegenargument:* Eine Geschichte über sieben Kapitel braucht einen Erzähler mit Überblick; frische Sitzungen je Text schreiben mit wechselnder Stimme und verlieren Fäden.
- 3.6.3 *Entkräftet:* Das Gedächtnis der Geschichte liegt schon heute in Dateien, nicht in Homers Kopf: `STORY-PLAN.md`, `STORY-PLAN-K1.md`, `STORY-K1-HANDLUNG.md`, `STORY-REGELN.md`. Das Profil Story lädt Ton, Figurenstimmen und den Storyplan; große Würfe (Kapitelentwurf) sind ein großer Auftrag an einen Macher; der Prüfer gleicht gegen Storyplan und Regeln ab, der Chef urteilt.
- 3.6.4 *Was Homer heute noch tut und wohin es geht:* Ideen urteilen (sonntags) → Sokrates (2.3); Stil und Aussehen → Chef; Leveldesign → Macher mit Profil Leveldesign; Vorentscheide Homer entfallen.
- 3.6.5 *Zwei Profile, nicht eines:* **Story** (schreiben: Ton, Stimmen, Plan) für den, der Texte verfasst; **Spieltext** (einbauen: wortgetreu aus `STORY-…`, nie erfinden, Begriffe) für jeden, der Texte ins Spiel setzt. Getrennt, damit wer nur einbaut, nicht den ganzen Ton laden muss.

**3.7 Sockel: „KISS – keep it short and simple. Nicht raten, sondern belegen.“** (09:46). **Beides stimmt; „belegen“ ist besser als mein Satz, KISS braucht eine Klammer.**
- 3.7.1 *Nicht raten, sondern belegen:* schärfer als mein „nicht raten; vorher nachsehen“, weil es den Nachweis verlangt, den auch die Quellen empfehlen („ask Claude for evidence“, 1625). *Ergänzt:* Was tun, wenn man nicht belegen kann? Anhalten und fragen. Ersetzt 5.2.
- 3.7.2 *KISS meint den Schreibstil* (Chef 09:52: „KISS bezieht sich primär auf den Schreibstil“). Damit entfällt mein Einwand, KISS verleite zur Einzellösung; meine Klammer „einfachste Lösung, die alle Fälle trägt“ ist gestrichen. Gegen Überbau bei Lösungen wirken schon die Systemfrage im Auftrag (6.2) und die Regelbilanz im Profil Werkzeug (3.4); das doppelt in den Sockel zu schreiben, wäre selbst gegen KISS.
- 3.7.3 *Was „kurz schreiben“ heißt,* steht nicht im Sockel, sondern zeigt sich am Baukasten (6) und an jeder Rückmeldung: Ergebnis zuerst, ein Gedanke je Satz, kein Füllwerk.

**3.8 „Nur Sokrates fabuliert, ansonsten KISS. Sokrates darf, aber muss nicht fabulieren“** (09:47). **Stimmt**; deckt sich mit der heutigen Regel „nur Sokrates begründet ausführlich“.
- 3.8.1 *Gegenargument:* Eine Ausnahme im Sockel kostet jede Sitzung eine Zeile für eine Rolle. *Darum:* Sockel nur KISS (5.3); die Erlaubnis steht allein im Kern Sokrates: „ausführlich nur, wo der Chef entscheiden soll und die Begründung trägt; sonst KISS“.

**3.9 Folgeauftrag an denselben Macher, wenn er noch klein ist** (Idee 09:56: „nicht immer gleich neue Sitzung, um Kosten zu sparen wenn möglich“). **Ja, unter drei Bedingungen.**
- 3.9.1 *Dafür:* Ein Start kostet: Claude Code lädt Systemprompt und Werkzeuge, der Macher liest Profil und Code erneut. Arbeitet er im selben Feld weiter, ist das schon da.
- 3.9.2 *Stärkstes Gegenargument:* Der alte Auftrag bleibt im Kontext, mit seinen Dateien, Ausgaben und Annahmen. Genau diese Ablenkung wollen wir loswerden (1.1). Und jeder weitere Schritt schickt den ganzen bisherigen Kontext mit; eine große Sitzung kostet je Schritt mehr als eine frische.
- 3.9.3 *Darum nur, wenn alles zutrifft:* (1) dasselbe Profil; (2) dasselbe Feld, also Bezug oder dieselben Verzeichnisse (3.1); (3) Kontext unter einer Grenze, zur Probe 150 Tsd. Token (Größe liefert `get_session`, das Büro entscheidet per Werkzeug). Sonst frische Sitzung.
- 3.9.4 *Nicht* nach einem Rückläufer im zweiten Mal (3.3.5): dann frisch, damit der Fehler nicht mitwandert.
- 3.9.5 *Bestand:* Die Messung „dieselbe Aufgabe frisch gegen groß“ liegt als Vorgang 383.2 bei mir (ruht bis 23.11.). Die Probewoche (12.2) misst damit, ab welcher Größe frisch billiger ist; die 150 Tsd. sind bis dahin eine Annahme.

**3.10 Wie sieht die Vorgangsliste künftig aus?** (Chef 10:06: „bleibt ja und wird nur um eine Bezugsspalte erweitert. Oder wie soll es zukünftig aussehen?“). **Votum: Die Liste bleibt als Verzeichnis, aber nicht nur mit „Bezug“ mehr. Drei Spalten ändern sich, eine Akte je Vorgang kommt dazu.**
- 3.10.1 *Heute* (19.11., 10:07): 248 offene Zeilen, 70 KB. Spalten: Nr. · Titel · Besitzer · Kl. · Stand · wartet auf · Zweig · Build · Bereich · Kosten. Titel tragen oft Chefzitate (bis 400 Zeichen); Einzelheiten stehen als „Zu NR“ verstreut in den Vorräten der Rollen.
- 3.10.2 *Neu:*

   | Nr. | Spalte | Änderung | Warum |
   |---|---|---|---|
   | 3.10.3 | Titel | kurz, nur was (höchstens etwa 100 Zeichen); Zitat und Herkunft in die Akte | die Liste liest das Büro oft, die Akte nur, wer den Vorgang bearbeitet |
   | 3.10.4 | Besitzer → **Sitzung** | wer gerade daran arbeitet; leer, wenn niemand | feste Fächer fallen weg (4.7); Verantwortung trägt das Büro bis zur Vergabe |
   | 3.10.5 | Bereich | **bleibt** (Chef 11:54: „Die Bereiche bleiben.“); das Profil steht nicht in der Liste, sondern im Auftrag (6), weil ein Vorgang mehrere Profile brauchen kann (760: Figur und Kampf); Vorschlag des Profils aus dem Bereich | Auswertung wie bisher (651), keine zweite Spalte für fast dasselbe |
   | 3.10.6 | Stand | feste Wörter mit Frist und Wächter, siehe 14.2; Endzustände erledigt, verworfen, doppelt, überholt (14.3) | jedes Wort entspricht einem Kasten in 2; das Werkzeug kann so zählen und starten |
   | 3.10.6a | neu: **Themenblock** | Nummer des Themenblocks aus der Chefsache-Übersicht (Block 1–9); die Reihenfolge der Blöcke legt nur der Chef fest (3.16) | Themen priorisieren, ganze Themen ruhen lassen |
   | 3.10.7 | neu: **Bezug** | verwandte Nummern (3.1) | Abgleich, Wiederholungen sehen |
   | 3.10.8 | neu: **Runde** | 0, 1, 2: wie oft der Prüfer nein sagte | 3.3.4, 3.3.5; zählt das Werkzeug (10.5) |
   | 3.10.9 | bleiben | Nr., Kl., wartet auf, Zweig, Build, Kosten | Kosten jetzt mit Schwelle (13.4.3) |

- 3.10.10 *Akte je Vorgang* (`docs/akte/<Nr>.md`): oben der Auftrag nach dem Baukasten (6), darunter Chefworte, Stand mit Ursache, Verlauf. Sie ersetzt die „Zu NR“-Absätze in den Vorräten. Erledigt → kurz ins Vorgangsarchiv, Akte in Git. Das ist „jeder Text an einem Ort“, nur endlich wirklich an einem.
- 3.10.11 *Stärkstes Gegenargument:* Der Umbau trifft die Werkzeuge, an denen alles hängt (`vorgang.py`, `lauf.py`, `startbar.py`, Haken), und kostet Guthaben; dazu 248 Zeilen umziehen. *Entkräftet:* in drei Schritten, jeder für sich rücknehmbar: (1) Bezug und Runde anfügen, nichts bricht; (2) Akten für neue Vorgänge, alte behalten „Zu NR“ bis zum Abschluss; (3) Besitzer → Sitzung erst, wenn der Pool startet (12.3); Bereich bleibt. Die Umstellung schreibt ein Werkzeug, nicht eine Sitzung von Hand.
- 3.10.12 *Zweites Gegenargument:* Viele kleine Akten sind unübersichtlich. *Entkräftet:* `vorgang.py <Nr>` sammelt schon heute alles zu einer Nummer aus Liste, Vorräten und Archiv; die Akte macht daraus eine Datei statt einer Suche.

**3.11 Bild Handwerksbetrieb** (Chef 10:14: „Das Büro vergibt einen Auftrag, der Handwerker fährt zum Kunden, schreibt auf, was er gemacht hat … gibt er wieder ab im Büro und dann werden die Kosten erhoben“). **Stimmt, als Leitbild für den ganzen Ablauf; an zwei Stellen besser als das Vorbild.**
- 3.11.1 Passt: Büro = Auftragsannahme und Disposition; Arbeitsvorbereitung = Auftragszettel; Macher = Geselle mit Werkzeugkiste (Profil); Fertigmeldung mit Beleg = Arbeitsbericht; Fund beim Kunden = Nachtrag übers Büro, nicht schwarz nebenbei (5.4).
- 3.11.4 Chef 11:35: Vorgänge sind die Aufträge, die Vorgangsliste ist das Auftragsbuch; „was ist, wenn der Macher auf dem Weg verunfallt und sich nie wieder meldet? Das muss irgendjemandem mal auffallen.“ Geregelt in 14.2.5 (Frist je Auftrag, Wächter im Code).
- 3.11.2 Besser 1: Die Stunden schreibt nicht der Geselle auf, sie misst das System (`cost_usd`); selbst aufgeschrieben wäre geraten.
- 3.11.3 Besser 2: Vor dem Kunden nimmt der Meister ab (Prüfer 2.11); der Kunde (Chef) sieht nur, was abgenommen ist, und urteilt über Geschmack.

**3.12 Werkzeuge und Haken zusammenlegen, mehr in Code statt in Prompts** (Chef 10:15). **Stimmt, mit einer Bedingung: Code darf nicht reden.**
- 3.12.1 *Bestand* (19.11., 10:15): `tools/` hat 102 Dateien, davon 83 Skripte mit zusammen etwa 900 KB, 27 davon Tests; 14 Haken-Einträge in `.claude/settings.json`.
- 3.12.2 *Stärkstes Gegenargument:* Code ist nicht automatisch schlank. Jeder Haken, der Warnungen in die Sitzung schreibt, ist wieder Prompt, nur unsichtbar für den Chef (die Startmeldungen heute früh: sieben Warnzeilen, die keiner der Sitzung zu tun gaben). Und eine falsche Regel in Python kann der Chef nicht lesen und nicht ändern.
- 3.12.3 *Darum drei Regeln für jedes Werkzeug:* (1) Es **handelt oder sperrt**, es mahnt nicht; Ausgabe nur, wenn die Sitzung etwas tun muss. (2) Je Werkzeug eine Zeile in einem Verzeichnis: was es tut, welche Textregel es ersetzt; ohne ersetzte Regel oder Nutzen fliegt es. (3) Jede Regel im Code hat einen Satz in Deutsch daneben, den der Chef lesen kann.
- 3.12.4 *Vorgehen:* Inventur als erster Auftrag an einen Macher mit Profil Werkzeug (12.1): je Werkzeug genutzt ja/nein (Aufrufe in Haken, `lauf.py`, Git), ersetzt welche Regel, redet es. Ergebnis: Liste behalten / zusammenlegen / streichen, an Sokrates, Entscheid beim Chef nur, wo eine Regel des Chefs dranhängt.

**3.13 Was im Hintergrund läuft und was es kostet** (Chef 10:17: „Ist Tools der Oberbegriff? … kosten die dann auch Token? … KISS“).
- 3.13.1 *Oberbegriff:* **Werkzeug** = ein Programm (Skript, meist in `tools/`). Ein **Haken** ist kein eigenes Ding, sondern ein Auslöser: Claude Code startet ein Werkzeug von selbst, wenn etwas passiert.
- 3.13.2 *Fünf Sorten:*

   | Nr. | Sorte | Beispiele bei uns | Kostet Token? | Verwässert? |
   |---|---|---|---|---|
   | 3.13.3 | **A Text, immer geladen** | `CLAUDE.md`, Schreibstil „Knapp“, Systemprompt und Werkzeugliste von Claude Code | ja, bei jeder Antwort (zwischengespeichert billiger) | ja, liest jede Sitzung immer |
   | 3.13.4 | **B Text, bei Bedarf** | Rollendatei, Vorrat, Profil, Auftrag | erst beim Lesen, dann bis Sitzungsende | nur, wenn es nicht zur Aufgabe passt |
   | 3.13.5 | **C Haken** | 14 Einträge: Start, jede Nachricht des Chefs, vor und nach jedem Werkzeugaufruf, Ende | das Prüfen nicht (läuft außerhalb des Modells); **was er zurückschreibt, ja** | ja, wenn er redet: „Uhr“ nach jedem Aufruf, „Kernregeln“ bei jeder Nachricht, sieben Warnzeilen beim Start |
   | 3.13.6 | **D Werkzeug, von der Sitzung aufgerufen** | `vorgang.py`, `meldung.sh`, `lauf.py` | Aufruf und Ausgabe ja, das Rechnen nicht | wenig, wenn die Ausgabe kurz ist |
   | 3.13.7 | **E Läufe auf GitHub** | 8 Abläufe: APK bauen, Tests, Webseite | nein, ganz autark; erst wer das Ergebnis liest, zahlt | nein |

- 3.13.8 *Wie sie sich beeinflussen:* Haken starten Werkzeuge; Werkzeuge schreiben Dateien, die andere lesen; reden mehrere Haken zugleich, summiert sich ihr Text; sagt ein Haken etwas anderes als `CLAUDE.md`, wählt das Modell beliebig (Quelle in 1625).
- 3.13.9 *Faustregel:* **Unsichtbar ist nur, was nichts zurückschreibt.** Darum: viel E, Haken nur zum Sperren oder stillen Handeln, A so klein wie möglich (5), D mit kurzer Ausgabe.

**3.14 Neu anfangen, frisch denken, ohne Bindungen** (Chef 10:29: „viel Potential zum mal neu anfangen, überdenken, konsolidieren und vor allem frisch denken ohne Bindungen aus best practise“). **Ja, als Nullbasis, nicht als Abriss.**
- 3.14.1 *Stärkstes Gegenargument:* Alles wegwerfen ist die bekannte Falle beim Neubau: Was heute still trägt, geht mit verloren (APK-Bau auf GitHub, Kerntests, Signatur, Sperren gegen echten Schaden), und während des Umbaus steht die Arbeit an Kapitel 1.
- 3.14.2 *Darum Nullbasis:* Jede Regel, jedes Werkzeug, jeder Haken startet bei null und muss sich neu begründen: Welchen Fehler verhindert es, belegt? Was die Begründung nicht schafft, fällt; was sie schafft, bleibt, auch wenn es alt ist. Frühere Weisungen werden genannt, binden aber nicht (Leitlinie 08:18).
- 3.14.3 *Grenze:* Das gilt für den Betrieb, nicht für das Spiel. Spielcode und Spielregeln (BRS) bleiben, wie sie sind.
- 3.14.4 *Umstieg:* Der neue Betrieb wird als Ganzes entworfen (dieses Dokument), eingeführt aber in Schritten (12), jeder rücknehmbar; das Spiel läuft dazwischen weiter.

**3.15 Priorität und Fristen** (entschieden 11:44: „Stufen so mit Werkzeug“) (Chef 11:37: „ob man nicht doch eine Art Priorität einführt … wenn ich halt 80 Muss habe, die auch nicht mehr gewissen Teams zugewiesen sind … dass die Fristen dann kürzer sind“). **Ja, aber drei Stufen statt einer Zahlenskala, und eine Reihenfolge für alle.**
- 3.15.1 *Bestand* (19.11., 11:38): 88 Muss, 153 Kür, 1 „M?“ offen. Heute gibt es Muss/Kür, „jetzt“ im Titel (Wächter 383) und die Reihenfolge **je Besitzer** als Vorrang. Wo eine Priorität früher verworfen wurde, habe ich im Archiv nicht gefunden.
- 3.15.2 *Der eigentliche Bruch:* Im Pool gibt es keine Besitzer mehr, also fällt „Reihenfolge je Besitzer“ weg. Es braucht **eine** Reihenfolge im ganzen Auftragsbuch.
- 3.15.3 *Vorschlag, drei Stufen mit eigenen Fristen* (Zahlen sind Annahmen bis zur Probewoche):

   | Nr. | Stufe | Wer setzt | Start | Beim Prüfer | Grenze |
   |---|---|---|---|---|---|
   | 3.15.4 | **Eilt** | nur der Chef (heute „jetzt“) | binnen 2 h | binnen 4 h | höchstens 3 gleichzeitig |
   | 3.15.5 | **Muss** | Büro nach Regeln, Chef kann ändern | nach Reihenfolge | binnen 1 Tag | – |
   | 3.15.6 | **Kür** | Büro | wenn kein Muss startbar | binnen 2 Tagen | „ruht“ nur mit Datum |

- 3.15.7 *Reihenfolge innerhalb Muss* rechnet das Büro-Werkzeug, nicht eine Sitzung: zuerst Funde des Chefs aus dem Test, dann Engpässe (worauf viele warten), dann Wiederholer (Bezüge, 3.1), dann nach Alter. Alter steigt von selbst, so verhungert nichts.
- 3.15.8 *Stärkstes Gegenargument:* Stufen blähen sich auf; schon heute sind 88 von 242 offenen Vorgängen Muss, Muss bedeutet also kaum noch etwas. *Entkräftet:* (1) Eilt ist hart begrenzt und nur Chefwort. (2) Einmal alle Muss gegen die Abnahmeliste von Kapitel 1 prüfen (Nullbasis wie bei den Werkzeugen): was Kapitel 1 nicht braucht, wird Kür. (3) Die Reihenfolge entscheidet ein Werkzeug nach festen Regeln, darum kein Feilschen um Stufen.

**3.16 Themenblöcke in die Vorgänge, Themen priorisieren** (Chef 11:51: „so dass ich nicht nur Vorgänge, sondern auch Themen priorisieren kann?“). **Ja.**
- 3.16.1 *Bestand:* Es gibt acht Themenblöcke mit fester Nummer (1440), etwa Block 2 „Kampf passt“, Block 3 „Kleiderschrank und Modelle“, Block 7 „Werkzeuge und Abläufe“. Sie stehen aber nicht im Vorgang, sondern `ueberblick.py` errät sie aus Bereich oder Nummer. Ganze Themen ruhen schon heute, aber von Hand je Vorgang („ruht, Block 2 (1605)“; 1714 Kampf ruht bis zur Arena).
- 3.16.1a *Begriff* (Chef 12:06: „ist dein Block mein Themenblock?“): ja, genau die Themenblöcke der Chefsache-Übersicht; „Block“ ist nur die Kurzform.
- 3.16.2 *Neu:* Spalte **Themenblock** (Nummer, dieselben Blöcke wie in der Chefsache-Übersicht) in jedem Vorgang, vom Büro beim Anlegen gesetzt (Vorschlag aus dem Bereich, das Büro bestätigt). Die Reihenfolge der Blöcke legt der Chef schon heute fest (Chefsache-Übersicht); neu wirkt sie direkt auf den Start, und ein Block kann als Ganzes ruhen (mit Datum oder Bedingung).
- 3.16.3 *Wirkung im Reihenfolge-Werkzeug (3.15.7):* Eilt vor allem; dann Muss nach der **Reihenfolge der Themenblöcke**, darin nach den Regeln (Funde des Chefs, Engpass, Wiederholer, Alter); dann Kür ebenso. Ruht ein Block, startet keiner seiner Vorgänge, ohne dass jemand jede Zeile anfasst.
- 3.16.4 *Stärkstes Gegenargument:* Block und Profil scheinen doppelt. *Entkräftet:* Der Block sagt **wofür** (Ziel, etwa „Kampf passt“), das Profil **womit** (Handwerk, etwa Figur). Der Biss des Wolfs (760) ist Block Kampf, Profil Figur und Kampf. Darum steht der Block in der Liste, das Profil im Auftrag.
- 3.16.5 *Zweites Gegenargument:* Ein Block ganz oben lässt andere verhungern. *Entkräftet:* Das Alter hebt jeden Vorgang mit der Zeit an (3.15.7); und was eilt, setzt der Chef mit „Eilt“ ohnehin vor alles.
- 3.16.6 *Auswertung* (Chef 11:52, 11:54: „Die Bereiche bleiben.“): Kosten, Läufe, Rückläufer und Alter je **Block** (was kostet ein Ziel, etwa „Kampf passt“) und je **Bereich** wie bisher (651). Beides im einen Kostenwerkzeug (Nullbasis 3.3.3), aus denselben Spalten.
- 3.16.7 *Wo die Reihenfolge steht* (Chef 12:10: „müssen wir dann auch wo festhalten. Ahh, meine Chefsache, oder?“): **Ja, in der Chefsache, als eine feste Datei** `docs/chefsache/themenbloecke.md`: Nummer, Name, Reihenfolge, ruht bis. Sie ist die Quelle; das Reihenfolge-Werkzeug und die Übersicht lesen sie. Ändern: dein Wort, eingetragen von Sokrates.
- 3.16.8 *Befund dabei:* Heute gibt es die Reihenfolge **zweimal und verschieden**: acht Themenblöcke fest im Code von `ueberblick.py` und sechs „Teilprojekte bis Kapitel 1 fertig“ in `PROJEKTPLAN.md` (1061), mit anderem Zuschnitt. Beide gehen in der einen Datei auf.
- 3.16.9 *Gegenargument:* In der Chefsache gilt „beantwortet heißt weg“; eine Dauerdatei passt nicht dazu. *Entkräftet:* Es gibt dort schon feste Dateien (`README.md`, `MUSTER.md`); die Themenblöcke sind dein Lenkrad, keine Frage, und gehören dahin, wo du nachsiehst.

**3.17 Sind die Themenblöcke griffig, und taugen sie als Ansatz für die Profile?** (Chef 12:16). Alle 245 offenen Vorgänge mit dem Werkzeug der Übersicht (`ueberblick.py`) zugeordnet, zwei Blöcke Zeile für Zeile gelesen.

- 3.17.1 *Ergebnis je Block:*

   | Nr. | Block heute | offen | Muss | Urteil |
   |---|---|---|---|---|
   | 3.17.2 | 1 Umzug BRS | 2 | 1 | fast fertig; geht in Kampf und Regeln auf |
   | 3.17.3 | 2 Kampf passt | 69 | 19 | griffig, aber groß |
   | 3.17.4 | 3 Kleiderschrank und Modelle | 31 | 21 | griffig |
   | 3.17.5 | 4 Alles an einer Stelle (Kataloge) | 10 | 3 | griffig, klein |
   | 3.17.6 | 5 Welt, Karten, Bild, Ton, Bedienung | 51 | 4 | **nicht griffig**: Sammelbecken aus Welt 21, Story 9, Stil 8, Oberfläche 6, Prüfung 4, Klang 2 |
   | 3.17.7 | 6 Godot besser nutzen | 19 | 11 | gemischt: auch Builds (1331, 496), Welt (416.6 Spuren, 1720 Vordergrund) |
   | 3.17.8 | 7 Werkzeuge und Abläufe der Firma | 53 | 30 | **30 Muss für unsere eigenen Abläufe**; viele davon legten Mahner selbst an (Startwarnung: 1686, 1687, 1688, 1690, 1723); einzelne Spielthemen falsch einsortiert (423.1 Spielerhandbuch im Spiel) |
   | 3.17.9 | 8 Marktstart | 10 | 0 | griffig |

- 3.17.10 *Ursache der Unschärfe:* Die Blöcke werden aus dem Bereich errechnet; ein falscher Bereich (etwa „E Technik“ oder „B Abläufe“ für ein Spielthema) landet im falschen Block. Mit der Spalte Themenblock (3.16) entscheidet das Büro beim Anlegen, nicht die Rechnung.
- 3.17.11 *Zweiter Befund:* Block 7 zeigt, warum die Nullbasis nötig ist: fast ein Drittel aller Muss betrifft die Firma, nicht das Spiel, und ein Teil davon erzeugten Mahner. Mit der Nullbasis fallen viele davon weg.
- 3.17.12 *Vorschlag Zuschnitt, je Block ein Fachprofil:*

   | Nr. | Block neu | Fachprofil |
   |---|---|---|
   | 3.17.13 | Kampf und Regeln (mit Umzug BRS) | Kampf |
   | 3.17.14 | Figuren und Kleidung | Figur |
   | 3.17.15 | Welt und Karten (Gelände, Licht, Wetter, Stil der Welt) | Welt |
   | 3.17.16 | Klang und Musik | Klang |
   | 3.17.17 | Bedienung und Oberfläche | Oberfläche |
   | 3.17.18 | Geschichte und Texte | Story |
   | 3.17.19 | Kataloge (alles an einer Stelle) | Daten |
   | 3.17.20 | Technik, Leistung, Build | Technik |
   | 3.17.21 | Firma: Werkzeuge und Abläufe | Werkzeug |
   | 3.17.22 | Marktstart | – (Sokrates mit dem Chef) |

- 3.17.23 *Dazu wenige Querschnittsprofile,* die jeder Block braucht: Prüfbild und Film, Build, Spieltext (einbauen), Fremde Inhalte. Der Auftrag nennt das Fachprofil seines Blocks und bei Bedarf eines davon oder ein zweites Fachprofil (760: Kampf und Figur).
- 3.17.24 *Stärkstes Gegenargument:* Zehn Blöcke sind mehr als acht, und jede Aufteilung macht neue Grenzfälle (Licht im Kampf: Welt oder Kampf?). *Entkräftet:* Grenzfälle entscheidet das Büro einmal beim Anlegen, nicht jede Sitzung neu; Klang und Musik nennt die Oberste Direktive eigens, darum ein eigener Block statt Rest in einem Sammelbecken; der Gewinn ist, dass Block, Profil und Auswertung zusammenpassen.
- 3.17.25 *Grenze:* Den Zuschnitt der Themenblöcke legst du fest (Chefsache-Übersicht); das hier ist mein Vorschlag.

## 4 Wer was tut

| Nr. | Wer | Tut | Liest beim Start |
|---|---|---|---|
| 4.1 | **Chef** | entscheidet, testet, gibt Ideen | – |
| 4.2 | **Sokrates** | Gespräch mit dem Chef; macht aus einem Chefwort einen Auftrag, einen Entscheid oder eine Idee; prüft und urteilt Ideen gegen Bestand und Leitbild (bisher Homer, 3.6.4); löst Festgefahrenes (3.3.5) | Sockel, Kern (bis 3 KB) |
| 4.3 | **Büro** (Ford, gestärkt) | Abgleich, Vorgänge, Vorrang (heute Perikles), Starten, Einsortieren, Melden, Kosten, Regelwächter; das Mechanische macht `lauf.py` | Sockel, Kern (bis 3 KB) |
| 4.4 | **Arbeitsvorbereitung** (heute Perikles; bei Chefthemen Sokrates) | schreibt je Vorgang einen Auftrag nach dem Baukasten (6) | Sockel, Baukasten, Akte des Vorgangs |
| 4.5 | **Macher** (Pool ohne feste Fächer; die Rolle steht im Auftrag und im Profil: Figur, Level, Kampf, Klang, Werkzeug, Build, Story, Spieltext; auch Homer, 3.6) | baut genau einen Auftrag in einem Zweig | Sockel, Auftrag; Profil bei Bedarf |
| 4.6 | **Prüfer** (Diogenes) | prüft nach der Prüfart des Auftrags (3.2), bevor der Chef es sieht; meldet Funde außerhalb ans Büro | Sockel, Auftrag, Ergebnis |

- 4.7 Feste Bereiche fallen weg (Chef 08:17): Verantwortung hängt am Vorgang, nicht an „Dorf“ oder „Höhle“. Damit zwei Macher sich nicht in die Quere kommen, sperrt das Büro je Auftrag ein Verzeichnis oder eine Szene.

## 5 Was in jede Sitzung muss (Sockel, etwa 0,5 KB, heute 15 KB)

Nur, was jede Sitzung braucht, nicht selbst sehen kann und kein Werkzeug erzwingen kann:

- 5.1 Deutsch, Berliner Zeit.
- 5.2 Nicht raten, sondern belegen (Quelle, Befehl mit Ausgabe, Bild). Geht das nicht oder ist der Auftrag unklar: anhalten und fragen. (3.7)
- 5.3 Kurz und einfach schreiben (KISS). (3.7)
- 5.4 Fund außerhalb des Auftrags: melden, nicht beheben (außer 3.3.7).

Wohin der Rest zieht:

| Nr. | Bisher im Text | Neu |
|---|---|---|
| 5.5 | Name und Zeit vor jeder Nachricht | Haken setzt ihn |
| 5.6 | Nie Schlüssel, Passwörter committen; App-Kennung; kein Force-Push | Sperrhaken (verhindert, mahnt nicht) |
| 5.7 | Kein Spielcode auf `main` ohne Test des Chefs | Schutz von `main` auf GitHub plus Sperrhaken |
| 5.8 | Spieltexte nie erfinden; Begriffe | Profil Spieltext |
| 5.9 | Fremde Inhalte nur mit offener Lizenz | Profil Fremde Inhalte (lädt beim Einbinden von Dateien) |
| 5.10 | „Fertig“ mit Beleg | Feld „Zurück“ in jedem Auftrag |
| 5.11 | Melden, Vorgänge, Chefsache, Rollen | Kern Büro bzw. Sokrates |

## 6 Der Auftrag (Baukasten, höchstens 1,5 KB)

Feste Gliederung, erprobt in `auftraege-19-11.md`:
- 6.1 **Ziel:** was der Spieler sieht, hört oder erlebt.
- 6.2 **Systemfrage:** keine Einzellösung; wie lösen es andere? Pflicht bei Bezügen (3.1.2).
- 6.3 **Stand:** was schon versucht wurde, mit Ursache.
- 6.4 **Beachte:** höchstens fünf Punkte.
- 6.5 **Umsetzen.**
- 6.6 **Prüfart und Prüfe vor dem Senden:** drei bis fünf Ja-Nein-Fragen (3.2).
- 6.7 **Zurück:** an wen, in welcher Form, mit Beleg.

## 7 Profile (Skills, laden nur bei Bedarf)

- 7.1 Je Arbeit ein Profil mit Handwerk, Prüfung, Abnahmebeleg: Figur und 3D-Modell · Prüfbild und Film · Leveldesign · Kampf und Regeln · Klang · Werkzeug · Build und APK · Story (schreiben) · Spieltext (einbauen) · Fremde Inhalte.
- 7.2 Das erste gibt es schon (`LISTE-HANDWERK-FIGUR-PRUEFBILD.md`).
- 7.3 Was beim Prüfer zweimal zurückkam, wird eine Zeile im Profil, nicht im Sockel. Der Prüfer schlägt sie vor, das Büro trägt sie ein; je Profil eine Größengrenze.

## 8 Was es kostet, was es spart

- 8.1 Start eines Machers: heute etwa 75 KB, neu etwa 2 KB plus Profil. Weniger Ablenkung, also weniger Fehler, die der Chef zuerst findet.
- 8.2 Jede Sitzung ist kurz und frisch; es gibt keinen Vorrat, den sie pflegen muss.
- 8.3 Eine Prüfung durch einen anderen fängt ab, was heute fünf- bis achtmal nachkontrolliert wird.
- 8.4 Gegenrechnung: Prüfer, Büro und Arbeitsvorbereitung kosten eigene Sitzungen. Gemessen wird darum das Guthaben je abgenommenem Auftrag, nicht die Startgröße.

## 9 Stärkstes Gegenargument

- 9.1 **Alles hängt an der Güte der Aufträge.** Ein frischer Macher weiß nur, was im Auftrag steht. Ist der Auftrag schlecht, misst der Prüfer an denselben schlechten Prüfpunkten, und derselbe blinde Fleck geht zweimal durch (1694: Prüfung „grün“, Bild falsch).
- 9.2 **Entkräftet durch:** (1) Der Prüfer prüft zuerst das Ziel, dann die Punkte des Auftrags, nach der Prüfart (3.2). (2) Wir messen den Auftragsschreiber: wie viele Aufträge kommen als unklar zurück, wie viele Läufe bis zur Abnahme. (3) Systemfrage und Stand mit Ursache sind Pflicht; ohne sie startet das Büro keinen Auftrag.
- 9.4 Größte Lücke nach Gegenlesen 2: **Liegenbleiben.** Ohne Frist, Wächter und einen Schließer kann ein Vorgang an fast jedem Kasten still stehen bleiben; geschlossen in 14.
- 9.3 Zweites Gegenargument: **Das Büro wird zum Nadelöhr.** Entkräftet: Was sich regeln lässt, macht `lauf.py`; die Sitzung Büro schreibt nur den Rest. Rückweg ist der heutige Stand in Git.

## 10 Weitere Einwände

- 10.1 **Haken:** heute 14 Einträge in `.claude/settings.json`, hinter denen viele Prüfungen stecken, viele mahnen nur. Neu: ein Haken nur, wenn er etwas verhindert. Ohne das bringt der kleine Sockel wenig, weil die Haken Text nachschieben.
- 10.2 **Der Prüfer kostet eine Sitzung je Auftrag.** Bei knappem Guthaben nur für Aussehen und Kampf; bei Werkzeugen prüft der Kerntest.
- 10.3 **Sokrates ist kein Auftragsarbeiter.** Für die Beratung bleibt ein Kern mit Gespräch. Homer wird Macher (3.6).
- 10.4 **Zusammenstöße im Repo:** Sperre je Verzeichnis oder Szene; die Vorgangsliste schreibt nur ein Werkzeug; bei einem Konflikt geht der Auftrag zurück, keiner löst ihn von Hand.
- 10.5 **Rückläufer zählen:** Wie oft ein Vorgang beim Prüfer scheiterte (3.3.4, 3.3.5), zählt ein Werkzeug, nicht eine Sitzung.

## 11 Gegenlesen (19.11., 08:32, frischer Helfer ohne meine Begründung)

Urteil: „Die Richtung … trägt. Der Entwurf löst aber das Verwaltungsproblem nur verschoben und lässt drei Praxisbrüche offen.“ Fünf Befunde, je mit meinem Wort:
- 11.1 Das stärkste Gegenargument ist der Auftragsschreiber, nicht das Büro. **Stimmt**, in 9.
- 11.2 Zusammenstöße: Sperre je Datei taugt nicht, die Vorgangsliste schreiben mehrere. **Stimmt**, in 10.4.
- 11.3 Wer Lehren ins Profil schreibt, fehlt. **Stimmt**, in 7.3.
- 11.4 Im Sockel fehlen der Abbruchweg und „melden, nicht beheben“; „wer wir sind“ kann raus. **Stimmt**, in 5.
- 11.5 Die Kosten je Auftrag können steigen. **Stimmt**, in 8.4. **Einwand:** Ein Prüfer nur bei Aussehen und Kampf stand schon im Entwurf.
- 11.6 Zusatz: Die Haken gehören in Schritt 1. **Stimmt**, in 12.1.

## 12 Einführung in Schritten (ab Sa 21.11., 20:00)

- 12.1 `CLAUDE.md` auf den Sockel kürzen; altes als `docs/alt/CLAUDE-voll.md`. Mahnhaken abschalten, Sperrhaken für 5.6 und 5.7 behalten. Dazu Inventur aller Werkzeuge und Haken (3.12.4).
- 12.2 Ein Macher, eine Woche, nur mit Auftrag, Prüfer davor. Zählung: Läufe bis Abnahme, Fehler, die der Chef zuerst findet, Guthaben je Auftrag.
- 12.3 Büro übernimmt Abgleich, Vorrang und Einsortieren; Perikles wird Arbeitsvorbereitung. Vorgangsliste: Bezug und Runde ab 12.1, Akten für neue Vorgänge ab 12.2, Sitzung statt Besitzer ab 12.3; Bereich bleibt (3.10.5).
- 12.3b Spalte Themenblock; die Reihenfolge der Blöcke des Chefs steuert den Start (3.16), im selben Werkzeug wie die Reihenfolge.
- 12.3a Stufen Eilt, Muss, Kür mit Werkzeug für die Reihenfolge (3.15.7) und Durchsicht aller Muss gegen die Abnahmeliste Kapitel 1 (3.15.8).
- 12.4 Dann die übrigen Macher; Rollendateien schrumpfen auf den Kern.

## 13 Durchgespielt an drei echten Fällen (Chef 10:05)

Quelle je Fall: `python3 tools/vorgang.py <Nr>` (Liste, Vorräte, Archiv), Stand 19.11., 10:05.

**13.1 Griff, 1694** (seit 18.11., 17:01; 14,80 $; drei Fehlschläge: 👎 17:38 „Stiel liegt nicht in der geschlossenen Hand“, 21:37 „nix zu erkennen“, 19.11. 07:4x vom Macher selbst nicht vorgelegt).
- 13.1.1 *Neu:* Chefwort → 2.2 → 2.6 Abgleich findet 1621 Zweihänder und 1657 Stab (derselbe Fehler) → ein Vorgang mit Systemfrage im Auftrag (6.2). So geschah es auch, aber erst auf Votum im Gespräch, nicht von selbst.
- 13.1.2 Fehlschlag 17:38 wäre beim Prüfer (2.11) hängen geblieben, nicht bei dir: „liegt der Stiel in der Faust?“ ist ein sichtbarer Sachverhalt. Das Bild 21:37 (unbeschriftet, schwarz, ohne Spielkamera) hätte der Prüfer als Beleg abgelehnt.
- 13.1.3 Zweites Nein → 3.3.5 „steckt fest“ → Ursache nachstellen statt neuem Lauf. Real kam die Ursache (Messung am Knochen statt am gezeichneten Netz) erst nach dem dritten Versuch.
- 13.1.4 **Lücke A:** In 3.2.3 steht „Aussehen: Urteil Chef“. Ob der Stiel in der Faust liegt, ist aber kein Geschmack, sondern ein Sachverhalt. Ohne Trennung schiebt der Prüfer alles Sichtbare an dich weiter.
- 13.1.5 **Lücke B:** Der Macher fand nebenbei, dass Holz und Leder schwarz wirken; ob heller, ist Aussehen, also deine Entscheidung. Im Diagramm führt vom Büro kein Weg zu dir.

**13.2 Wolfssprung, 760** (seit 09.11.; 37,07 $; 👎 15.11., Fund t298.7, t300.11 „Fail“; Messung „5 von 5 Bissen am Körper“ gegen dein Auge; musste aus Build 300 wieder heraus, 1724).
- 13.2.1 *Neu:* Ziel im Auftrag: „Der Spieler sieht, wie der Wolf springt und den Helden oder den Schild trifft; Blut dort, wo die Zähne treffen“. Prüfart Film (3.2.4); der Prüfer prüft am Film den Sachverhalt (trifft er?), nicht die Messung. Der Widerspruch Messung gegen Film wäre beim Prüfer aufgefallen.
- 13.2.2 Nach dem zweiten Nein (spätestens t298.7) → Sokrates, steckt fest; real liefen danach weitere Läufe und ein Build.
- 13.2.3 Build (2.14): Inhalt beim Start fest, nur aus „Prüfer ja“. 760 hatte kein Ja, wäre nicht in Build 300 gekommen; die Rücknahme 1724 entfällt.
- 13.2.4 **Lücke C:** 37 $ auf einem Vorgang, ohne dass jemand die Summe sah. Der Ablauf zählt Rückläufer, aber keine Kosten.

**13.3 Kleid sticht durch, 1653 und 1654** (Fund aus Toms Werkzeug, Durchstechprüfung; Bilder 18.11. 21:30 an dich als Frage „sichtbar?“; 21:48 „das sind ja keine Bilder … was soll ich denn damit anfangen?“; gebilligt erst 22:37).
- 13.3.1 *Neu:* Das Werkzeug meldet den Fund → 3.3.6 Büro, Abgleich, Vorgang → Auftrag „sichtbar? wenn ja beheben, Beleg alt gegen neu“. Der Macher entscheidet „sichtbar“ selbst an Bild und Messung; an dich geht keine Frage, sondern nur das Ergebnis.
- 13.3.2 Die beiden Bilder 21:30 hätte der Prüfer abgelehnt (Stelle nicht mittig, mehr freie Fläche als Figur). Die Lehre „Fehler mit eigenem Befund nicht als Frage vorlegen, beheben“ kommt nach 2.13 ins Profil Prüfbild, nicht in einen Prompt.
- 13.3.3 Funktioniert ohne Lücke.

**13.4 Was daraus folgt**
- 13.4.1 *Lücke A, Sachverhalt gegen Geschmack:* 3.2 bekommt die Trennung: **Sachverhalt** (liegt X in Y, trifft er, sticht etwas durch, ist die Stelle sichtbar) entscheidet der Prüfer; **Geschmack** (schön, passend, düster genug, Farbe) urteilt der Chef. Gegenargument: Der Prüfer ist auch eine KI und hat bei 1694 schon einmal „grün“ gemeldet. Entkräftet: Damals prüfte eine Messung, nicht ein zweites Auge am Bild; der Prüfer sieht sich das Bild an und gibt bei Zweifel an den Chef.
- 13.4.2 *Lücke B, Weg zum Chef:* neuer Pfeil 2.6 → 2.2: braucht ein Fund deine Entscheidung, geht er über Sokrates in die Chefsache, nie direkt vom Büro oder Macher.
- 13.4.3 *Lücke C, Kosten (berichtigt 10:12):* Eine Kostenschwelle gibt es schon: 40 $ je Vorgang, dann hält er an und Perikles gibt frei (1538, `startbar.py`). 760 lag mit 37 $ knapp darunter, darum griff sie nicht; die Lücke ist also die Höhe, nicht das Fehlen. Neu: die Schwelle meldet an Sokrates (wie „steckt fest“), und ihre Höhe wird in der Probewoche geprüft; meine 10 $ von 10:06 waren geraten.
- 13.4.5 *Wann gebucht wird* (Chef 10:12: „Kosten werden im Büro nach Rückläufer eines Machers klargezogen. Richtig?“): **Ja, mit zwei Ergänzungen.** Heute bucht Ford beim Archivieren einer Sitzung ihre Kosten (`cost_usd`, `kosten.py`) auf die Nummern der Übergabe. Neu bucht das Büro bei **jeder** Rückmeldung „fertig“ den Zuwachs seit der letzten Buchung, nicht erst am Sitzungsende; sonst lassen sich Folgeaufträge in einer Sitzung (3.9) nicht trennen. Zweitens zählen auch Prüfer, Arbeitsvorbereitung und Sokrates auf den Vorgang, sonst sieht die Schwelle nur einen Teil (8.4). Buchen tut ein Werkzeug, das Büro prüft nur.
- 13.4.4 *Was alle drei Fälle zeigen:* Am meisten spart der Prüfer vor dir. In allen drei Fällen kam ein Ergebnis zu dir, das ein zweiter Blick ohne Geschmacksurteil hätte zurückweisen können.

## 14 Gegenlesen 2: Bleibt ein Vorgang irgendwo liegen? (19.11., 11:30)

Auftrag Chef 11:29: „dass es liegen bleibt, darf halt nicht sein. Es muss immer … von Erstellung eines Auftrags bis zur Beendigung … durchlaufen, bis irgendeiner beendet sagt.“ Frischer Prozessprüfer, nur mit diesem Blickwinkel. Urteil: „Der Entwurf beschreibt den glücklichen Weg sauber, aber ohne Fristen, Wächter und benannte Endzustände kann ein Vorgang an fast jedem Kasten stillschweigend liegen bleiben.“ **Stimmt; das ist die größte Lücke des Entwurfs.**

**14.1 Grundsatz neu:** Jeder Stand hat einen, der ihn weiterbewegt, eine Frist und einen Wächter, der die Frist prüft. Der Wächter ist Code, nicht eine Sitzung. Und es gibt genau einen Schließer.

**14.2 Stände mit Frist** (ersetzt 3.10.6; Fristen sind Annahmen bis zur Probewoche; je Stufe kürzer oder länger, 3.15):

| Nr. | Stand | Bewegt weiter | Frist | Wenn nichts passiert (Wächter) |
|---|---|---|---|---|
| 14.2.1 | Fund, Idee (vor dem Anlegen) | wer findet, über `fund.py` | sofort | nur im Chat genannt gilt als verloren; Rückmeldung mit „Fund“ ohne Nummer wird nicht angenommen |
| 14.2.2 | Ideenliste | Sokrates | wöchentlich | Sokrates urteilt, Liste an den Chef, der Chef holt zurück (wie heute Homer sonntags, 3.6.4) |
| 14.2.3 | neu | Büro (Abgleich, Vorrang) | 1 Tag | Tagesmeldung „ohne Auftrag“ |
| 14.2.4 | Auftrag | Büro (Start) | nach Vorrang | Leichenprüfung (heute 1189) |
| 14.2.5 | in Arbeit | Macher | Höchstdauer und Höchstkosten je Auftrag | Sitzung weg, abgebrochen oder still: Sperre lösen, zurück auf „Auftrag“, ein Neustart; beim zweiten Mal „steckt fest“ |
| 14.2.6 | beim Prüfer | Prüfer | 1 Tag | neuer Prüfer; bei leerem Guthaben Kerntest statt Sitzung, wo die Prüfart es erlaubt |
| 14.2.7 | abgenommen | Büro (nächster Build) | bis zum nächsten Build | Tagesmeldung |
| 14.2.8 | im Build | Macher Profil Build | Build-Lauf | Build rot: eigener Stand, zählt nicht als Runde, zurück ans Büro; zweites Mal Sokrates |
| 14.2.9 | Chef testet | Chef | 5 Tage Erinnerung (Tagesbericht) | nach 14 Tagen „ruht“ mit Datum, nie still |
| 14.2.10 | Chefsache | Chef | Chefrunde | **Einwand gegen den Prüfer:** kein „nach 7 Tagen gilt der Vorschlag“; Story, Aussehen, Geld entscheidest nur du. Stattdessen: Zahl und Alter offener Punkte im Tagesbericht, Chefrunde bündelt |
| 14.2.11 | ruht | – | Pflichtdatum und Grund | ohne Datum lehnt `vorgang.py` ab (heute gibt es „ruht“ ohne Datum, z. B. 1533, 1534); am Datum zurück auf „Auftrag“ |
| 14.2.12 | steckt fest | Sokrates | 48 h | dann Chefsache von selbst |
| 14.2.13 | wartet auf | wer das Erwartete liefert | wie dessen Stand | `vorgang.py` lehnt Kreise ab (A wartet auf B wartet auf A) |
| 14.2.14 | Konflikt beim Zusammenführen | Büro | 1 Tag | zählt nicht als Runde; Auftrag zurück an denselben Profil-Macher |

**14.3 Endzustände und ein Schließer:** `vorgang.py schliessen <Nr> --grund erledigt | verworfen | doppelt | überholt`, nur das Büro. *Erledigt* auf Abnahme nach Prüfart (Prüfer ja, und wo das Urteil beim Chef liegt, sein „gut“). *Verworfen, doppelt, überholt* nur auf Wort von Sokrates oder Chef, bei doppelt und überholt mit der Ersatznummer. **Einwand gegen den Prüfer:** „erledigt braucht immer Prüfer-ja plus Chef-gut“ passt nicht für Abläufe und Werkzeuge; dort reicht die Abnahme nach Prüfart.

**14.4 Wer wacht über den Wächter:** Fällt `lauf.py` aus, bewegt sich nichts, und keiner merkt es. Darum Herzschlag: `lauf.py` schreibt bei jedem Lauf eine Zeitmarke; ein Ablauf auf GitHub (kostet keine Token) meldet per Telegram, wenn sie älter als 2 h ist. Guthaben leer: Büro schaltet auf „nur Muss, nur Kerntest“ und meldet es einmal.

**14.5 Bestand:** Teile gibt es schon und gehen darin auf: Leichenprüfung (1189), Startwarnung nach 6 h als Vorgang (1642), Kostenschwelle (1538), Termin bei „ruht“ im Listenkopf (1129 A, aber nicht erzwungen), Wache-Sitzung (kostet Token; der GitHub-Herzschlag ersetzt sie).

**14.6 Mein Wort zu den acht Befunden:** 1 Macher bricht ab: stimmt. 2 Frist je Stand: stimmt; Meldungen an den Chef gebündelt einmal täglich, nicht einzeln. 3 Chefsache: Einwand (14.2.10). 4 ruht und steckt fest: stimmt. 5 Funde und Ideenliste: stimmt, die fehlende Ideen-Runde war meine Lücke aus 3.6.4; **Einwand** gegen automatisches Verwerfen nach 4 Wochen (deine Ideen wirft kein Werkzeug weg). 6 Kreise, Konflikt, Build rot: stimmt. 7 Herzschlag und Guthaben: stimmt. 8 Endzustände: stimmt, mit Einwand (14.3).

## 15 Was der Chef sagen soll

„Richtung ja“ (dann ab Samstag 12.1) oder dein Einwand mit Nummer.
