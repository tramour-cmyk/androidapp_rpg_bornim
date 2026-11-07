# 618 · Wie heißt der Knopf, der einen Schirm verlässt? · Team Tom · 07.11., 22:10
Team Tom · 07.11., 22:10 · E Oberfläche · Kurz: Zurück, Abbrechen, Schließen nach einer Regel; Brett, Rast, Kampfende zuerst

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/skripte/brettschirm.gd

**Frage:** Gilt diese Regel auf allen Schirmen?
1. **Zurück**: zur vorigen Ansicht im selben Schirm (Wechselliste → Ausrüstung, Spielstände → Hauptmenü, Kampf: Zielwahl → Befehle).
2. **Abbrechen**: ein Fenster mit einer Handlung zu, ohne dass etwas geschieht (Rückfrage, Mengenfenster, Gegenstandsfenster).
3. **Schließen**: der ganze Schirm zu, zurück ins Spiel (Menü, Laden, Brett, Rast, Kampfende).

**Votum Tom:** ja. Dann zuerst Brett, Rast, Kampfende, danach die alten Fenster im Laden und im Menü im neuen Stil (ohne Kasten, Knopf links mit „‹“).

**Berührt:** 618, 549a, 557, Kampf bei Jerry (Kampfende), Aussehen eingefroren bis zum Durchspielen (488).

**Begründung:** Heute heißt derselbe Weg zurück ins Spiel einmal „Zurück“ (Brett, Rast, Kampfende) und einmal „Schließen“ (Menü, Laden). Ein Wort für eine Wirkung macht die Knöpfe ohne Nachdenken lesbar.

**Sachverhalt** (Bestandsliste aus dem Code, 28 Stellen):
- falsches Wort: **Anschlagbrett** „Zurück“ führt ins Spiel, dazu alter Stil (Kasten, mittig); **Rast** am Feuer, an der Theke, im Zimmer „‹ Zurück“ führt ins Spiel; **Kampfende** „Zurück“ führt in die Welt (eigener Kampfstil); **angelegtes Stück antippen** im Reiter Ausrüstung „Schließen“ statt „Abbrechen“; **„Punkte verteilen?“** „Nein“ statt „Abbrechen“; **Zwischensequenz überspringen?** „Weiter ansehen“.
- Wort richtig, Stil alt: Laden (Mengenfenster, Gegenstandsfenster, drei Rückfragen), Menü selbst („Schließen“ mittig), Anleitung, Über das Spiel, Erschaffung.
- richtig und neu: Wechselliste, Gegenstandsfenster, Wegwerfen, Spielstände, Löschen, Laden-Fuß, Brauen.

**Stärkstes Gegenargument:** Du hast am 04.11., 17:40 für die Rast selbst gesagt: „sinnvoller wäre ein Zurück oder ein Abbrechen“. Nach der Regel hieße sie „Schließen“. Wenn dir „Zurück“ für alles, was ins Spiel führt, lieber ist, dann gilt umgekehrt: „Schließen“ beim Menü und beim Laden wird „Zurück“. Wichtig ist nur, dass es überall gleich ist.

**Folgerungen:** Bei „ja“: Brett, Rast und Wörter in einem Build (Tom; Kampfende Jerry), der Stil der alten Fenster danach, nach dem Durchspielen (488). Bei „Zurück für alles ins Spiel“: Menü und Laden umbenennen, sonst gleich.
