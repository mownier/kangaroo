
extends Timer

signal progress(time_left)

func _ready():
	pass

func _process(delta):
	emit_signal("progress", get_time_left())