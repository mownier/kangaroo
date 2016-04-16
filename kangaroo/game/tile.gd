
extends Node2D

export var width = 200
export var height = 200

var char = ""

func _ready():
	_setup_container()
	_center_letter()
	_setup_line()

func _center_letter():
	var letter = get_node("container/letter")
	var container = get_node("container")
	var size = letter.get_size()
	var x = (width - size.width) / 2
	var y = (height - size.height) / 2
	var pos = Vector2(x, y)
	letter.set_text(char)
	letter.set_pos(pos)

func _setup_container():
	var container = get_node("container")
	var polygon = container.get_polygon()
	polygon.set(1, Vector2(0, height))
	polygon.set(2, Vector2(width, height))
	polygon.set(3, Vector2(width, 0))
	container.set_polygon(polygon)

func _setup_line():
	var letter = get_node("container/letter")
	var line = get_node("container/line")
	var size = Vector2(letter.get_size().width, 5)
	var pos = Vector2(letter.get_pos().x, letter.get_pos().y + letter.get_size().height)
	line.set_size(size)
	line.set_pos(pos)

func _set_letter(what):
	var letter = get_node("container/letter")
	letter.set_text(what)
