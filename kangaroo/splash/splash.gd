
extends Node

func _ready():
	_connect_request()
	_connect_animation_player()

func _center_greetings_label():
	var label = get_node("greetings")
	var x = (_get_root_size().width - label.get_size().width) / 2
	var y = (_get_root_size().height - label.get_size().height) / 2
	var center = Vector2(x, y)
	label.set_pos(center)

func _get_root_size():
	return get_tree().get_root().get_rect().size

func _connect_animation_player():
	var anim_player = get_node("animation_player")
	anim_player.connect("finished", self, "_did_finish_animation")

func _connect_request():
	var request = get_node("update_player")
	request.auth = get_node("/root/global").auth
	request.connect("on_update_player_completed", self, "_on_update_completed")

func _did_finish_animation():
	_goto_appropriate_scene()

func _goto_appropriate_scene():
	var global = get_node("/root/global")
	var info = global.get_player_info()
	if(info.size() == 0 or !info.has("valid_session") or !info["valid_session"]):
		_goto_login()
	else:
		_bind_player_info(info)
		_update_player(info)

func _update_player(info):
	var request = get_node("update_player")
	var user_id = info["user_id"]
	var message_index = info["message_index"]
	var player_points = info["player_points"]
	request.update(user_id, message_index, player_points)

func _on_update_completed(status_code):
	if(status_code == HTTPClient.RESPONSE_OK):
		_goto_main()
	else:
		_goto_login()

func _bind_player_info(info):
	var global = get_node("/root/global")
	global.set_username(info["username"])
	global.set_user_id(info["user_id"])
	global.set_player_points(info["player_points"])
	global.set_message_index(info["message_index"])
	global.set_valid_session(info["valid_session"])

func _goto_login():
	get_tree().change_scene("res://kangaroo/login/login.scn")

func _goto_main():
	get_tree().change_scene("res://kangaroo/main/main.scn")