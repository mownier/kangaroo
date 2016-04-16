
extends Node

const key = "213jk2jkjsdkfjskdjfk-eriweuiorwerjwero"
const path = "user://data.db"
const auth = "mCLnl5NWyR8yljQ3jVcfbptLWifE0t2wiZyARrwB"

var username = "" setget set_username, get_username
var player_points = 0 setget set_player_points, get_player_points
var message_index = 0 setget set_message_index, get_message_index
var user_id = "" setget set_user_id, get_user_id
var valid_session = false setget set_valid_session, is_valid_session

func _ready():
	connect("exit_tree", self, "_will_exit_tree")

func set_username(data):
	username = data

func get_username():
	return username

func set_player_points(data):
	if(data <= 0):
		player_points = 0
	else:
		player_points = data

func get_player_points():
	return player_points

func set_message_index(data):
	message_index = data

func get_message_index():
	return message_index

func set_user_id(data):
	user_id = data

func get_user_id():
	return user_id

func set_valid_session(valid):
	if(!valid):
		user_id = ""
		username = ""
		message_index = -1
		player_points = -1
	valid_session = valid

func is_valid_session():
	return valid_session

func save():
	var json = _construct_json()
	_write_data(json, false)

func get_player_info():
	var json = _read_data()
	var info = Dictionary()
	info.parse_json(json)
	return info

func _will_exit_tree():
	save()

func _construct_json():
	var dict = Dictionary()
	dict["username"] = username
	dict["user_id"] = user_id
	dict["player_points"] = player_points
	dict["message_index"] = message_index
	dict["valid_session"] = valid_session
	return dict.to_json()

func _write_data(data, append=true):
	var content = ""
	if(append):
		content += _read_data()
	var file = File.new()
	file.open(path, File.WRITE)
	content += str(data)
	file.store_string(content)
	file.close()

func _read_data():
	var data = ""
	var file = File.new()
	if(file.file_exists(path)):
		file.open(path, File.READ)
		data = file.get_as_text()
	if(file.is_open()):
		file.close()
	return data