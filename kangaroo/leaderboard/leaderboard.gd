
extends Node

const limit = 10

func _ready():
	_connect_request()
	_show_loading(true)
	_get_high_scores(limit)

func _show_loading(show):
	get_node("loading").set_hidden(!show)

func _connect_request():
	var request = get_node("get_high_scores")
	request.auth = get_node("/root/global").auth
	request.connect("on_get_high_scores_completed", self, "_on_request_completed")

func _on_request_completed(high_scores, status_code):
	_show_loading(false)
	var dict = Dictionary()
	var array = Array()
	if(status_code == HTTPClient.RESPONSE_OK):
		var items = _to_array(high_scores, true, false)
		_set_items(items)

func _to_array(high_scores, sort=false, natural=true):
	var array = Array()
	for key in high_scores:
		var value = high_scores[key]
		value["user_id"] = key
		array.append(value)
	if(sort):
		if(natural):
			array.sort_custom(self, "_sort_ascending")
		else:
			array.sort_custom(self, "_sort_descending")
	return array

func _sort_asending(a, b):
	var a_pp = a["player_points"]
	var b_pp = b["player_points"]
	return (a_pp < b_pp)

func _sort_descending(a, b):
	var a_pp = a["player_points"]
	var b_pp = b["player_points"]
	return (a_pp > b_pp)

func _on_back_pressed():
	get_tree().change_scene("res://kangaroo/main/main.scn")

func _set_items(items):
	if(items != null and items.size() > 0):
		var list = get_node("list")
		var rank = 1
		for item in items:
			var item_text = _construct_item_text(rank, item)
			list.add_item(item_text, null, false)
			rank += 1

func _construct_item_text(rank, item):
	var username = item["username"]
	var player_points = item["player_points"]
	var text = str(rank, ".) ", username, " (", player_points, ")")
	return text

func _get_high_scores(limit):
	var request = get_node("get_high_scores")
	request.get_high_scores(limit)
