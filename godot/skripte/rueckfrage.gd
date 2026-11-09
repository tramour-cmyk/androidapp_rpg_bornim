class_name Rueckfrage
extends RefCounted
# 526 (Abgleich Build 249; alt Dialogs.kt ConfirmDialog, SlotsScreen BackHandler): ein Baustein fuer alle Rueckfragen und kleinen
# Fenster ueber einem Schirm. Der Schleier (schwarz 0,82) liegt ueber allem; ein Tippen daneben schliesst wie „Abbrechen“
# (alt .tap(onDismiss)), ein Tippen in den Kasten nicht (alt .tap {}); Android-Zurueck schliesst erst das Fenster (416.1,
# zurueck.gd), dann erst den Schirm darunter. [zu] tut, was „Abbrechen“ tut; ohne [zu] verschwindet nur der Schleier.

const DP := AktionsKnopf.DP
const TIPP_DP := 12.0                        # so weit darf der Finger wandern, und es ist noch ein Tippen (menue.gd tippbar)

static func schleier(eltern: Node, zu := Callable()) -> ColorRect:
	var s := ColorRect.new()
	s.color = Color(0, 0, 0, 0.82)
	s.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	s.mouse_filter = Control.MOUSE_FILTER_STOP
	eltern.add_child(s)
	var tat := zu if zu.is_valid() else func(): s.queue_free()
	Zurueck.melde(s, tat)
	var da := {"p": Vector2.INF}
	s.gui_input.connect(func(e: InputEvent):
		if not (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT): return
		if e.pressed: da["p"] = e.position
		elif da["p"] != Vector2.INF:
			var weit: float = e.position.distance_to(da["p"])
			da["p"] = Vector2.INF
			if weit < TIPP_DP * DP and not s.is_queued_for_deletion():
				s.accept_event()
				tat.call())
	return s

# der Kasten nimmt jedes Tippen selbst, damit es nicht zum Schleier durchgeht und das Fenster schliesst
static func halte(k: Control) -> Control:
	k.mouse_filter = Control.MOUSE_FILTER_STOP
	k.set_meta("haelt", true)   # 571: wischen.gd laesst den Kasten auch in einer Liste so
	return k
