# 1222: Einzelbilder des Films film_rauch_1222.gd für den Ersteller (783 W1: vorher selbst nachsehen, ob Inhalt da ist; kein Film).
# Aufruf: PROBEBILD=1222 xvfb-run -a godot --rendering-driver opengl3 --path godot --resolution 540x1170 --fixed-fps 30
#   -s res://tests/bild_rauch_1222.gd   BILDER=<Bildnummern, Komma> OUT=<Ordner>
extends "res://tests/film_rauch_1222.gd"

var _bild := 0
var _bilder: Array = Array(OS.get_environment("BILDER").split(",", false)).map(func(x): return int(x))
var _out := OS.get_environment("OUT")


func _process(_delta: float) -> bool:
	_bild += 1
	if _bild in _bilder:
		root.get_texture().get_image().save_png("%s/rauch-%04d.png" % [_out, _bild])
	return false
