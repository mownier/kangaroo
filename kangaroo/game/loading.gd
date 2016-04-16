
extends Node2D

func _ready():
	start()
	pass
#	_center_loading_label()

func _center_loading_label():
	var label = get_node("loading_label")
	var x = (get_viewport_rect().size.width - label.get_size().width) / 2
	var y = (get_viewport_rect().size.height - label.get_size().height) / 2
	var pos = Vector2(x, y)
	label.set_pos(pos)

func start():
	var anim_player = get_node("animation_player")
	anim_player.play("loading")

func stop():
	var anim_player = get_node("animation_player")
	anim_player.stop_all()