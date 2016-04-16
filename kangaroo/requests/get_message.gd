
extends HTTPRequest

signal on_get_message_completed(response, status_code)

const url = "https://kangarooph.firebaseio.com/message/"

var auth

func _ready():
	connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	cancel_request()
	var response = Dictionary()
	response.parse_json(body.get_string_from_utf8())
	emit_signal("on_get_message_completed", response, response_code)

func _construct_url(index):
	return str(url, index, ".json", "?auth=", auth)

func get_message(index):
	cancel_request()
	var request_url = _construct_url(index)
	request(request_url)