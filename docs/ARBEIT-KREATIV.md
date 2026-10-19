# Vorrat Homer

Spiel und Design: Story, Texte, Stil, Aussehen, Spielgefühl, Balance, Ideen (`ROLLE-KREATIV.md`). Reihenfolge = Vorrang. Größe höchstens etwa 15 KB.


**Gelesen bis:** `c33b961a` (19.10., 18:10)

**Übergabe (19.10., 18:10):** 223T: Hinweistexte Nahkampf von hinten in `STORY-SPIEL.md` (`[223T.eingebung]`, `[223T.angriff]` ersetzt `[204T.angriff]`, `[223T.reihen]` an `[201.reihen]`), an Jerry (Zu 223). Nachfolger: keiner.


## Zeilen

| Nr. | Kl. | Thema | Stand |
|---|---|---|---|
| 225 | M | **von Sokrates (Chef 19.10., 18:22, Vorgangsarchiv 225):** Knopf „Platz“ → „Wechsel“, Erklärtexte anpassen; Regelseite und lange Drucke einmal ganz gegen den Code von Build 36 lesen | offen: Texte, dann an Jerry (mit 211) |
| 219T.1 | M? | **von Chef (19.10., 18:16, Test 36):** Regelseite „Der Ring.“ sagt das Ergebnis, nicht wie man es erzielt (großer Ring deckungsgleich mit dem kleinen) | offen: Text `[201.ring]` und `[219T.erster]`/`[219T.jetzt]` ergänzen, an Jerry |
| 41 | K | Storyplan; Texte Kapitel 2 | ruht: Texte Kapitel 2 fertig, Bau nach dem Meilenstein (179): Texte Kapitel 2 frei seit 72s.1 und 168 (Garrick fest, „kommt mit“); Zeilen zu 41.1 geschrieben (19.10.); 41.2 Nachtfähre entschieden 19.10. (ja); Bau nach Meilenstein; 5b bleibt „noch nicht“ |
| 72 | K | Profil und Kampfsystem | wartet auf Sokrates (72g–72j, 45); 72a eingetragen (Leitbild, 19.10.); 72c, 72e entschieden 19.10.; Entschiedenes im Vorgangsarchiv, Bau bei Jerry; [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b), `DESIGN-KAMPF.md` |

- **Zu 41** (Thema, Stand im Wortlaut): Storyplan; Texte Kapitel 2 | **168 D** (18.10.): Garrick fest in K2, Söldner ab K3; Grund und Satz „kommt mit“ in Storyplan und Texte. Storyplan `STORY-PLAN-K2.md` Kapitel 2 fertig (ohne 5b). Textentwurf `STORY-K2-ENTWURF.md` frei seit 72s.1 (entschieden 18.10.), nach dem Meilenstein; Prüfpunkt 6.4 = 41.2, ja (19.10.); nichts offen. **D4.1 A** (Chef 15.10., 10:5x): Texte zur Quest vor der Höhle (Morwen, Garrick warnt unter Stufe 3) mit dem Chef, dann Tom
- **Zu 211** (Chef 19.10., 12:30, wörtlich): „Grds. stellen sich bei MARS ja eh noch Design-Fragen. Und zwar nicht nur Hintergrund, Animation, sondern eher im Sinne von Usability, was ist wo, wie groß ist etwas, wie kann ich den Text des Kampfes gut lesen (ist ja z.T. auch ganz nett), wie was die Gegner (und ich) vorhaben als Popup, wie "groß" wird die Zugreihenfolge, wie ist alles angeordnet etc...“ Nachsatz 12:36: „ZU 211: Es geht mal primär nicht um hübsch (das wäre ja Kür), sondern für den Spieler sinnvoll, funktional  und klar.“ Berührt: 204, 210 (Popups), 72u.1 (Kampfort), Idee „Zeichen der Absicht als eigene Zeile“ (`LISTE-IDEEN.md`).
- **Zu 211, Knopf „Platz“** (Chef 19.10., 14:31, an Sokrates): „Hinweis zu Mars, vielleicht die Schaltfläche Platz mit Position beschriften. Was meinst du?“ Sokrates: Knopf wechselt nur die Reihe (182), Auswahl zeigt „vordere/hintere Reihe ⇄ Name“; Vorschlag „Reihe“ statt „Position“ (genauer, kein Fremdwort, „Platz“ heißt auch Speicherplatz). Beschriftung entscheidet Homer, mit 211 an Jerry. **Homer (19.10., 17:08): bleibt „Platz“.** Gegenargument zu „Reihe“: unter dem Knopf liegt seit 72.10a.11 auch der Waffenwechsel, und man geht auch auf einen freien Platz derselben Reihe; „Reihe“ wäre enger als der Knopf, „Position“ Fremdwort. Alle Regeltexte sagen „Platz“ (`[201.zug]`, `[201.halb]`, `[204T.platz]`); der lange Druck erklärt ihn. Nichts an Jerry. **Chef (19.10., 17:24, an Sokrates):** „Hmm, ich dachte, ich hätte irgendwo festgehalten, dass die Schaltfläche "Platz" in MARS "Position" heißen soll.... Homer hat das anscheinend anders gesehen... Aber wenn Position schon ein Fremdwort ist...“ (gilt als Kenntnisnahme; sagt der Chef „Position“, wird umbeschriftet). **Chef (19.10., 18:18, an Sokrates, Test 36 Regelseite):** „Finde Platz immer noch doof, habe deine Antwort zu"Wo wurde das entschieden?" nicht gesehen.“ Gilt nicht mehr als Kenntnisnahme; Wort des Chefs folgt (Vorschlag Sokrates: „Wechsel“). Nachgesehen (Build 36, `SkirmishScreen.kt` Pick.Place): Auswahl bietet nur die andere Reihe („hinten ⇄ Mira“ oder „hinten (frei)“, je mit „+ Waffe“) und „Waffe: …“; ein Platz derselben Reihe kommt nicht vor (182), Homers Gegenargument dazu trifft nicht zu.

Zu 211 (Chef 19.10., 15:37): „Bei der Grafik bei 211 können die Schaltflächen unten ja (zumindest im Bild) deutlich vertikal näher zusammenrücken, oder?“ Stellungnahme Sokrates in der Chefsache-Datei.

- **Zu 219T.1** (Chef 19.10., 18:16, Standbild Regelseite „Der Ring.“, Build 36): „Erklärt das Ergebnis, aber nicht wie es erzielt wird (Großer, sich zusammenziehender Ring sollte möglichst deckungsgleich mit dem kleine Ring sein, um das beste Ergebnis zu erzielen.“ Build 36 zeigt noch die alte Fassung; auch die neue `[201.ring]` sagt nur „wenn er sich schließt“.

- **Zu 225** (Chef 19.10., 18:23): „Oben im Erklärtext kann aber "zwei Reihen" stehen bleiben, da passt es, finde ich.“ Sokrates: ja; Abschnitt „Zwei Reihen.“ (`[201.reihen]`) bleibt, nur ergänzt um `[223T.reihen]`.
