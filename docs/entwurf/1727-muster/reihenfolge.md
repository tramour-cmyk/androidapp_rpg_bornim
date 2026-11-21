# 1727, Reihenfolge bis zur Umstellung (Fassung 2, Sokrates 21.11., 10:18, gegengeprüft)

Anlass: Vorschlag 20.11., 21:41 „Aufräumen → Arbeitsdateien → Profil Technik → Bauliste → Feste Regeln → Falltest“, ohne Wort des Chefs. Maßstab Chef 20.11., 16:50: „Der Falltest kann erst kommen, wenn wir doch die ganzen Rollendateien umgemünzt haben auf Sockel, Kern, Profildateien, respektive dann Arbeitsdateien zum Testen.“ 16:49: Abgenommenes nur nach Gespräch, Größe je Änderung.

## Reihenfolge

1. **Herausziehen, nur kopieren:** je Sockel, Kern, Profil die letzte gültige Fassung aus dem Gesamtbild in eine eigene Arbeitsdatei, Text unverändert (Unterschied per diff belegt); Größen und Ladesumme per Skript (frische Vorher-Zahlen für 16:49). Gesamtbild danach eingefroren (Verlauf). Kein Aufräumen im Gesamtbild (doppelte Arbeit, Befund 1).
2. **Umgemünzt fertig schreiben, direkt in den Arbeitsdateien:**
   - Abgleich der Rollendateien je Punkt: übernehmen (wohin) oder „fällt“ (16:50); vorher gegen die Entscheide seit 16:42 auffrischen.
   - Inhalt der Vorräte (Gesamtbild 4, „Teil von Schritt 1 vor dem Falltest“): „Zu <Nr>“ in Vorgangsdateien, Lehren durchsehen wie der Abgleich.
   - Fehlende Texte: Profil Technik zuerst (Build, Merge, Release ohne Träger), Profil Disponent und Kern Büro nach 3.3, Werkzeug, Fremde Inhalte, Spieltext einbauen, Büro-Profile Release und Kosten, Rundblick, Routinen Tagesbericht und Wache, Chefrunde.
   - Feste Regeln mit Ort: Tabelle „bleibt, wo“ neu in 0c; Lücken nach Wegfall von Leitbild, Rollen, `CLAUDE.md`; Meldewege je erstes Wort; Regler „Zahl der Werkstätten“.
   - Berichtigungen als eigene Commits mit Größe: eine Feldliste nur im Werkzeug, keine Doppeltexte, „Fachkraft“ statt „Macher“, Kleineres; Rest aus dem Vorrat („ab Sa 20:00“: Vorgänge auf Bereich, Arten „Probe“ und „Recherche“ in 0a, Wortliste 1732, Sperrliste Rufnamen).
   - **Gespräch nötig, bevor geändert wird** (Abgenommenes): Sockel (`add_repo`, 1.110 von 1.200 Byte), Kern Leitung (Lehren), Profil 2.3, Profil Welt, Kern Arbeitsplaner (Fassung 2 vor 3.3 geschrieben, jetzt Profil).
3. **Gegenprüfung aller ungeprüften Teile:** 0c, 1a Leitbild verteilen, 6b Rundblick, 6d Wochenzählung und alle Texte aus Schritt 2, je frischer Prüfer gegen den ganzen Entwurf.
4. **Falltest auf den Arbeitsdateien:** Fälle Sokrates (F1–F14), Abnahme und Tester, Build-Kette (Archiv 19.11., 22:05), Wiederholer und Liegezeit (Vorrat), Übergaben zählen wie Prüfung 20.11., Bremsen auf zwei, Verweisprüfung per grep.

**Nebenher:** Werkzeuge nach Bauliste 7.1 (Spike; 1760 startbar ab 21.11., 20:00, läuft noch nicht); die Bauliste wird in Schritt 2 vollständig (je Werkzeug eine Zeile, auch Rufnamen). Umstellung erst, wenn Falltest bestanden und jedes Werkzeug grün.

## Stärkstes Gegenargument

Beim Herausziehen kann sich Abgenommenes unbemerkt ändern, und eine Arbeitsdatei je Text vervielfacht die Dateien. Abhilfe: Schritt 1 nur kopieren mit diff-Beleg; Änderungen erst in Schritt 2, je eigener Commit mit Größe.

## Gegenprüfung 10:16 (frischer Helfer, 7 Befunde), mein Wort

1 Getrennte Schritte nur meine Lesart von 16:50: **stimmt**, Falltest bleibt zuletzt · 2 Abgenommenes nicht genannt: **stimmt**, Liste „Gespräch nötig“ · 3 Folgen aus 3.3 nicht nachgezogen (Profil Disponent): **stimmt** · 4 fehlen Vorräte, Gegenprüfungen, Vorrat ab Sa 20:00, Regler, Fall Build, Abnahme und Tester: **stimmt**, eingebaut; Befund 12 (Grundsatz 07:22) erledigt durch 3.3 · 5 Aufräumen fällt, kleine Pflege nötig: **stimmt**, Auffrischen in Schritt 1 und 2 · 6 „erst herausziehen“ stärker: **stimmt**, übernommen · 7 vier Schritte: **stimmt**.
