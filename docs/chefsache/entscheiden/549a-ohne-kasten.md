# 549a · Oberfläche „ohne Kasten“ als Grundsatz: Linien trennen, ein Rahmen nur für die Entscheidung?
Sokrates · 04.11., 11:1x · A Spiel · berührt 549, 60/42b (DESIGN-STIL „Oberfläche“), 488, alle Menüschirme

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/04-0110-549-Tom.png (Entwurf B, Tom); Spielstände Build 257 (Bild Chef 11:12)

**Frage:** Soll Entwurf B aus 549 die Regel für alle Menüschirme werden: Inhalte durch feine Goldlinien und Abstand getrennt, ein Rahmen nur dort, wo der Spieler gerade entscheidet?

**Votum:** Ja, als Richtung. Bauen jetzt nur die Rast (549). Die Spielstände kommen als zweiter Schirm, weil du sie als Beispiel genannt hast. Alle anderen Schirme folgen erst, wenn sie ohnehin angefasst werden, nach dem Durchspielen (488).

**Berührt:** `DESIGN-STIL.md` „Oberfläche“ (42b: „schwarz, dünner Goldrand“); Tom (Menüs), Jerry (Kampfkästen bleiben, 292.3).

**Begründung:** Ein Rahmen sagt dem Auge „hier ist eine Einheit“. Heute hat jeder Schirm Kästen in Kästen: Die Spielstände zeigen zehn Rahmen, einen um den Titel, einen um jeden Platz und einen um jeden Knopf. Damit sagt ein Rahmen nichts mehr, und der Schirm wirkt wie ein Formular. B ordnet über Schrift, Abstand und Linien. Das wirkt ruhiger und hochwertiger, und das Bild dahinter (Feuer, Welt) trägt die Stimmung. Das passt zu „düster, immersiv“ (Leitbild) besser als ein Gitter.

**Stärkstes Gegenargument:** Ohne Kästen erkennt man nicht, was antippbar ist (so der Prüfer zu B, 01:12). Am Handy ist das ein echter Mangel, kein Geschmack. Lösung, gehört zur Regel: (1) Jede antippbare Zeile hat links ein Zeichen und rechts ein goldenes „›“. Sie nimmt die ganze Breite ein, ist mindestens 48 dp hoch und wird beim Antippen dunkel hervorgehoben. (2) Text, der nur informiert, steht ohne Zeichen und ohne „›“. (3) Ein Rahmen bleibt für die eine Wahl, die gerade gilt (Fokus), und für Rückfragen. Zweites Gegenargument: 42b ist dein eigener Entscheid, und eine Änderung betrifft alle Schirme. Darum gilt sie nur Schirm für Schirm, ohne Umbau aller Schirme vor dem Durchspielen.

**Folgerung für die Spielstände** (Beispiel, nicht gebaut): Titel ohne Rahmen. Jeder Platz eine Zeile zwischen Linien: Name, Volk, Klasse, Stufe; darunter Ort, Tag und Speicherzeit. Rechts als Hauptwahl „Laden ›“ in Gold. „Löschen“ leise in Grau, mit Rückfrage. Heute ist es gleich groß wie „Laden“ und liegt direkt daneben, das lädt zum Fehlgriff ein. Leere Plätze: eine Zeile „Platz 2 · leer“ mit „Neues Spiel ›“ statt eines großen Kastens.

**Folgerungen:** Bei Ja trägt Sokrates die Regel in `DESIGN-STIL.md` „Oberfläche“ ein und vermerkt 42b „teils ersetzt“. Tom baut 549 nach B mit den Merkmalen für Antippbares, danach die Spielstände. Bei Nein bleibt es bei 42b, und 549 wird nach A oder B einzeln entschieden.

**Zu sagen:** „549a ja“, „549a nur Rast“ oder „549a nein“.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Sokrates).
