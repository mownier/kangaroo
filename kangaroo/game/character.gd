
extends Button

const width = 44
const height = 44

signal on_pressed_character(character)

func _ready():
	_change_size()

func _change_size():
	var size = Vector2(width, height)
	var name = get_name()
	set_size(size)
	set_text(name)

func _pressed():
	set_disabled(true)
	emit_signal("on_pressed_character", get_text())
