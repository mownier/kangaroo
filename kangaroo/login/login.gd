
extends Node

func _ready():
	get_node("signin_button").connect("pressed",self,"_on_button_pressed")
	get_node("login_request").connect("on_login_complete", self, "_on_login_completed")

func _on_button_pressed():
	var username = get_node("username_field").get_text()
	if(_should_request(username)):
		var request = get_node("login_request")
		request.username = username
		request.auth = get_node("/root/global").auth
		_show_loading(true)
		request.login()
	else:
		_show_alert("Provide username")

func _show_alert(message):
	get_node("alert").set_text(message)
	get_node("alert").popup_centered()

func _should_request(username):
	return username.length() > 0

func _show_loading(show):
	var loading = get_node("loading")
	loading.set_hidden(!show)

func _on_login_completed(response, status_code):
	_show_loading(false)
	if(status_code == HTTPClient.RESPONSE_OK):
		var user_id = response.keys()[0]
		var username = response[user_id]["username"]
		var player_points = response[user_id]["player_points"]
		var message_index = response[user_id]["message_index"]
		_bind_player_info(user_id, username, player_points, message_index)
		_save_player_info()
		_goto_main()
	else:
		_show_alert("Something went wrong")

func _save_player_info():
	var global = get_node("/root/global")
	global.save()

func _goto_main():
	get_tree().change_scene("res://kangaroo/main/main.scn")

func _bind_player_info(user_id, username, player_points, message_index):
	var global = get_node("/root/global")
	global.set_username(username)
	global.set_user_id(user_id)
	global.set_player_points(player_points)
	global.set_message_index(message_index)
	global.set_valid_session(true)