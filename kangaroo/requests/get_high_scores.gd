
extends HTTPRequest

signal on_get_high_scores_completed(high_scores, status_code)

const url = 'https://kangarooph.firebaseio.com/player.json?orderBy="player_points"&limitToLast='

var auth

func _ready():
	connect("request_completed", self, "_on_request_completed")

func get_high_scores(limit):
	cancel_request()
	var request_url = _construct_url(limit)
	request(request_url)

func _construct_url(limit):
	return str(url, limit, "&auth=", auth)

func _on_request_completed(result, response_status, headers, body):
	var response = Dictionary()
	response.parse_json(body.get_string_from_utf8())
	emit_signal("on_get_high_scores_completed", response, response_status)
	cancel_request()