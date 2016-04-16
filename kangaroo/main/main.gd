
extends Node

func _ready():
	_setup_greetings()

func _setup_greetings():
	var global = get_node("/root/global")
	var username = global.get_username()
	var greetings = str("Howdy, ", username, "!")
	get_node("greetings").set_text(greetings)

func _on_start_game():
	_goto("res://kangaroo/game/game.scn")

func _on_help():
	_goto("res://kangaroo/help/help.scn")

func _on_quit():
	get_tree().quit()

func _on_leaderboard():
	_goto("res://kangaroo/leaderboard/leaderboard.scn")

func _on_signout_pressed():
	_set_invalid_session()
	_goto("res://kangaroo/login/login.scn")

func _set_invalid_session():
	var global = get_node("/root/global")
	global.set_valid_session(false)

func _goto(path):
	get_tree().change_scene(path)