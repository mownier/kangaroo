
extends HTTPRequest

signal on_update_player_completed(status_code)

const url = "https://kangarooph.firebaseio.com/player/"

var auth

func _ready():
	connect("request_completed", self, "_on_update_player_completed")

func update(user_id, message_index, player_points):
	cancel_request()
	var request_url = _construct_url(user_id)
	var param = _construct_param(message_index, player_points)
	request(request_url, ["Content-type:application/json","X-HTTP-Method-Override:PATCH"], true, HTTPClient.METHOD_PUT, param)

func _construct_param(message_index, player_points):
	var param = str('{"message_index":',message_index,',"player_points":',player_points,'}')
	return param

func _construct_url(user_id):
	return str(url, user_id, ".json?auth=", auth)

func _on_update_player_completed(result, response_code, header, body):
	cancel_request()
	var response = Dictionary()
	response.parse_json(body.get_string_from_utf8())
	emit_signal("on_update_player_completed", response_code)