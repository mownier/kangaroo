
extends HTTPRequest

signal on_login_complete(response, status_code)

const get_url = 'https://kangarooph.firebaseio.com/player.json?orderBy="username"&limitToFirst=1&'
const post_url = 'https://kangarooph.firebaseio.com/player.json'

var username = ""
var auth

func _ready():
	connect("request_completed", self, "_on_request_completed")

func login():
	cancel_request()
	var request_url = _construct_get_url()
	request(request_url)

func _construct_get_url():
	return str(get_url, 'equalTo="', username, '"', "&auth=", auth)

func _construct_post_url():
	return str(post_url, "?auth=", auth)

func _construct_json(key):
	return str('{"',key,'":',_construct_param(),'}')

func _construct_param():
	return str('{"message_index":0,"player_points":0,"username":','"',username,'"}')

func _add_user():
	var param = _construct_param()
	var request_url = _construct_post_url()
	request(request_url, ["Content-type:application/json"], true, HTTPClient.METHOD_POST, param)

func _on_request_completed(result, response_code, headers, body):
	cancel_request()
	if(_is_body_null(body)):
		_add_user()
	else:
		var response = Dictionary()
		response.parse_json(body.get_string_from_utf8())
		if(response.has("name")):
			var key = response["name"]
			var json = _construct_json(key)
			response.clear()
			response.parse_json(json)
		emit_signal("on_login_complete", response, response_code)

func _is_body_null(body):
	if(body == null or body.size() == 0 or body.get_string_from_utf8() == "null"):
		return true
	else:
		return false