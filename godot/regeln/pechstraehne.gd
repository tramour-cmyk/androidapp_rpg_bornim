# 390 (core MissStreak.kt, Vorgang 18 im alten Spiel): mildert Pechsträhnen des Helden in einem Kampf. Nach drei
# Fehlschlägen in Folge bekommt der nächste Angriff +2, jeder weitere Fehlschlag +1 mehr, höchstens +4; ein Treffer
# beginnt von vorn. Unsichtbar, die Kampfzeilen zeigen keine Würfe. Eine natürliche 1 verfehlt weiter, kritische
# Treffer bleiben unberührt (der Bonus kommt nur zur Summe). Aus zählt sie nur (für den Vergleich der Balance).
extends RefCounted

const START := 3
const MAX := 4

var an := true
var misses := 0
## längste Folge von Fehlschlägen in diesem Kampf, für die Prüfung der Balance
var longest := 0


func _init(on := true) -> void:
	an = on


func bonus() -> int:
	return 0 if not an or misses < START else mini(MAX, misses - 1)


func miss() -> void:
	misses += 1
	longest = maxi(longest, misses)


func hit() -> void:
	misses = 0
