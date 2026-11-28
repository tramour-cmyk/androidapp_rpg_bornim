# 1931 · Bericht der Hilfssitzung (22.11., 13:10)

Auftrag wie „Zu 1931“ in `ARBEIT-BERATUNG.md`; alle 16 Punkte eingebaut, je Datei ein Commit auf `main` (`git log --grep "1931"`).

| Nr. | Datei | Byte Teil A vorher → nachher | Commit |
|---|---|---|---|
| V3, V4, Frage 11, Lücken 1–3, Bauskript | `1727-muster/kern-arbeitsplaner.md` | 2.649 → 3.156 | 76f4a4b27 |
| V6 | `kern-buero.md` | 680 → 759 | a21aaf8bd |
| V1 Größe, Eingang, Lücke 6 | `1727-gesamtbild.md` Kern Leitung | 2.837 → 2.988 | 305a2e762 |
| Fragen 2, 3 | `profil-pruefer.md` | 2.831 → 2.935 | 6eebfe866 |
| Frage 12 | `profil-fremde-inhalte.md` | 1.168 → 1.231 | bb9ddce02 |
| Frage 8, Marke | `profil-disponent.md` | 3.775 → 4.083 | f6e35b12b |
| V7 | `profil-zugang-kaufrepo.md` (neu) | 512 | 8f1185ada |
| Rollensätze | Technik, Werkzeug, Welt, Kampf, Regeln (+ Lücke 7), Klang, Oberfläche, Story | je +130 bis +250 | 771779da9 … d9bd2e6b0 |
| Lücke 4 | `profil-figur-und-pruefbild.md` | 1.303 → 1.427 | cb43ffb89 |
| Chef-Lesung | `profil-chefrunde.md` | 574 → 959 | 7eb70c47c |
| Gedächtnis | `docs/leitung/gedaechtnis.md` (neu, 20 Lehren) | 3.612 | d4ff25dc3 |
| 1909 | `routine-ideenlauf.md` (neu) | 1.074 | cd34c40e3 |
| PROBEBILD | `DESIGN-ABNAHME.md` Z. 11 Vermerk | – | 930dbeaf2 |

Ladesummen (Sockel 1.109): Leitung 3.946 → 4.097 (+ Gedächtnis 3.612); Disponent 5.564 → 5.951; Arbeitsplaner 4.438 → 5.024; Prüfer 5.507 → 5.611; Tester 5.302 → 5.814; Welt 4.453 → 4.766 (mit Kaufrepo 5.278); Text 2.519 → 2.757. `herausgezogen.md` nicht nachgezogen.

## Offen für den Nachfolger (Sokrates)

1. **Story-Rollensatz endet mit „legen Chef und Homer fest“** – Homer gibt es nicht mehr (Chef 12:42/12:43). Berichtigen (etwa „was gilt, legt der Chef fest“), auch in `1933-rollensaetze.md`.
2. Kern Arbeitsplaner 3.156 Byte über Grenze 3 KB (entschiedene Teile allein 2.866; Rest Lücken 1–3, Bauskript-Hinweis): kürzen oder dem Chef mit Byte vorlegen.
3. Gedächtnis 3.612 Byte gegen 3 KB im Kern Leitung.
4. Satz Eingang: Vorlage 1727i ohne Wortlaut, aus 1727d L-O1 genommen – prüfen.
5. V1 nein: abgenommene Gegenprüf-Zeile im Kern Leitung steht noch; nach Archiv „gilt nur für den Umbau 1727“ anpassen?
6. Lücke 7 im Profil Regeln statt Kern Leitung (Abgleich nannte Kern Leitung).
7. Frage 12: Kern Arbeitsplaner Feld 4 „(auch Bauskript am Kaufmodell)“ ergänzt, obwohl Vorlage „kein Textwechsel“ sagte.
8. Chef-Lesung 385 statt etwa 300 Byte.
9. Profil Markt und Recherche verweist weiter auf `ROLLE-BERATUNG.md` „Begründungen“.
10. Feld „Alt“ braucht Kaufrepo, Arbeitsplaner nicht in `BRAUCHT_KAUFREPO` (Spike).
11. Nicht gemacht: `docs/profile/` (macht Spike in 1928 aus diesen Texten), 822 Bereichslisten gegen Profile.
12. Danach: frische Gegenprüfung aller Commits gegen Archiv, dann Chef-Lesung, dann dem Chef kurz vorlegen; 1928 an Spike melden.
