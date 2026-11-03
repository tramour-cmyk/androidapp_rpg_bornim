# 494a · Dritter Lauf für die Gegner (Wildschwein, Hundertfüßer)?
Jerry · 03.11., 10:59 · E Kampf

Kurz: Beide Läufe zu 494 brachen beim Bauen ab, es gibt keinen Film; ein dritter Lauf?

Geprüft an: Lauf 229 (https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41609700003), Fix d9745467b

**Frage:** Die zwei erlaubten Läufe zu 494 (225, 229) sind verbraucht, beide brachen beim Bau des Hundertfüßers ab, bevor ein Film entstand. Gibst du einen dritten Lauf frei?

**Votum:** „494a ja“: ein Lauf mit Wildschwein und Hundertfüßer; danach geht der Film an dich, wie er ist.

**Berührt:** 494 (Gegner von Kapitel 1), 496 (Durchspiel-Build wartet auf 494), Regel „höchstens zwei Läufe“ (389, 407).

**Begründung:** Das Wildschwein baute in Lauf 229 fehlerfrei; nur der Hundertfüßer fehlte, und weil der ganze Bau abbrach, fiel auch der Film des Wildschweins aus. Ohne Film kann niemand urteilen.

**Sachverhalt:** Der gekaufte Hundertfüßer (MadeCG) liegt nur gepackt vor (`fbx.zip`, dazu Unity-Dateien, deren Bewegungen Blender nicht lesen kann). Unser Bauskript suchte die ausgepackte Datei. Behoben in d9745467b: es packt `fbx.zip` aus; scheitert ein Tier trotzdem, fehlt nur dieses, der Rest baut und der Film kommt.

**Auswertung:** Stärkstes Gegenargument: Die Grenze von zwei Läufen soll Raten verhindern; ein dritter Lauf belohnt ungeprüfte Annahmen über Dateinamen. Trägt nur halb: der Inhalt von `fbx.zip` ist ungesehen, aber der neue Bau fällt nicht mehr ganz aus, der Wildschwein-Film kommt in jedem Fall. Alternative „nein“: 494 wartet, bis Sokrates oder du anders entscheidet; 496 wartet mit.

**Folgerungen:** Bei „ja“ startet Jerry den Lauf sofort, Film an dich, Befund danach. Bei „nein“ ruht 494.

Antwort:
