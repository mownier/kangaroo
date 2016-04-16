
extends Node

var max_error
var wait_time
var message
var tiles
var shown_tiles
var selected_characters
var errors
var bonus_points
var bonus_time_limit
var end_game_time_left
var game_status
var did_press_quit

func _ready():
	_ready_values()
	_connect_exit()
	_connect_timer()
	_connect_get_data()
	_connect_update_player()
	_retrieve_data()

func _ready_values():
	tiles = []
	shown_tiles = 0
	selected_characters = 0
	errors = 0
	bonus_points = 0
	wait_time = 0
	max_error = 0
	message = ""
	bonus_time_limit = 0
	end_game_time_left = 0
	game_status = "playing"
	did_press_quit = false

func _connect_exit():
	connect("exit_tree", self, "_on_exit_scene")

func _connect_timer():
	var timer = get_node("timer")
	timer.connect("timeout", self, "_on_timeout")
	timer.connect("progress", self, "_on_progress")

func _connect_get_data():
	var http = get_node("get_data")
	http.connect("on_get_message_completed", self, "_on_complete")

func _connect_update_player():
	var http = get_node("update_player")
	http.connect("on_update_player_completed", self, "_on_update_completed")

func _retrieve_data():
	_show_loading()
	var request = get_node("get_data")
	request.auth = get_node("/root/global").auth
	request.get_message(str(_get_message_index()))

func _on_complete(response, status_code):
	if(response.has("end") and response["end"] == 1):
		_goto_game_over()
	else:
		message = response["hidden_msg"]
		max_error = response["chances"]
		wait_time = response["time"]
		bonus_points = response["bonus"]["points"]
		bonus_time_limit = response["bonus"]["time_limit"]
		
		_create_tiles()
		_setup_input_signals()
		
		_display_chances(str(max_error))
		_display_bonus_points(str(bonus_points))
		_display_category(response["category"])
		_display_bonus_desc(response["bonus"]["description"])
		_display_counter(_format_time_left(wait_time))
		_display_actual_points(str(_get_player_points()))
		
		_hide_loading()
		_start_timer()

func _display_chances(text):
	get_node("left_panel/chances").set_text(text)

func _display_counter(text):
	get_node("left_panel/counter").set_text(text)

func _display_category(text):
	get_node("left_panel/category").set_text(text)

func _display_bonus_points(text):
	get_node("left_panel/bonus").set_text(text)

func _display_bonus_desc(text):
	get_node("left_panel/bonus_desc").set_text(text)

func _display_actual_points(text):
	get_node("left_panel/actual_points").set_text(text)

func _show_loading():
	get_node("loading").set_hidden(false)
	get_node("left_panel").set_hidden(true)
	get_node("bottom_panel").set_hidden(true)
	get_tree().call_group(0, "tiles", "set_hidden", true)

func _hide_loading():
	get_node("loading").set_hidden(true)
	get_node("left_panel").set_hidden(false)
	get_node("bottom_panel").set_hidden(false)
	get_tree().call_group(0, "tiles", "set_hidden", false)

func _start_timer():
	var timer = get_node("timer")
	timer.set_wait_time(wait_time)
	timer.start()

func _on_progress(time_left):
	_display_counter(_format_time_left(time_left))
	if(!_valid_bonus_points(time_left)):
		_display_bonus_desc("Agh, You don't get the bonus points. Better luck next time.")

func _on_timeout():
	var counter = get_node("left_panel/counter")
	counter.set_text("0")
	_end_game(false, false)
	_show_game_points(_compute_lost_points_on_timeout())

func _create_tiles():
	var max_width = 720
	var max_height = 480
	var words = _tokenize(message)
	for i in range(words.size()):
		var word = words[i]
		_setup_tiles(word, i, max_width, max_height, words.size())

func _setup_tiles(word, line, max_width, max_height, num_words):
	var string = word.to_upper()
	var tile = load("res://kangaroo/game/tile.scn")
	var num = word.length()
	var x_mul = 0
	for i in range(num):
		var tile_n = tile.instance()
		var y_init = _get_initial_y_pos(num_words, tile_n.height, max_height)
		var x_init = _get_initial_x_pos(num, tile_n.width, max_width)
		var x = (tile_n.width * x_mul) + x_init
		var y = (tile_n.height * line) + y_init
		var pos = Vector2(x, y)
		tile_n.set_pos(pos)
		tile_n.add_to_group("tiles")
		tile_n.add_to_group(string[i])
		add_child(tile_n)
		x_mul += 1

func _tokenize(what):
	var words = what.split(" ", false)
	return words

func _get_initial_y_pos(num_words, tile_height, max_height):
	var total_height = num_words * tile_height
	var y = ((max_height - total_height) / 2) - (tile_height / 2)
	return y

func _get_initial_x_pos(word_len, tile_width, max_width):
	var total_width = word_len * tile_width
	var x = ((max_width - total_width) / 2)
	return x

func _num_of_characters(separator = null):
	if(separator == null):
		return message.length()
	else:
		return message.replace(separator, "").length()

func _setup_input_signals():
	for button in get_node("bottom_panel").get_children():
		button.connect("on_pressed_character", self, "_process_input")

func _process_input(input):
	selected_characters += 1
	var tree = get_tree()
	var group = input.to_upper()
	if(tree.has_group(group)):
		tree.call_group(0, group, "_set_letter", group)
		shown_tiles += get_tree().get_nodes_in_group(group).size()
		if(shown_tiles == _num_of_characters(" ")):
			_end_game(true, false)
			_show_game_points(_compute_win_points())
	else:
		errors += 1
		_display_chances(str(max_error - errors))
		if(errors == max_error):
			_end_game(false, false)
			_show_game_points(_compute_lost_points_on_max_error_reached())
		else:
			var bottom_panel = get_node("bottom_panel")
			if(selected_characters == bottom_panel.get_child_count()):
				_end_game(false, false)
				_show_game_points(_compute_lost_points_on_max_characters())

func _disable_all():
	var bottom_panel = get_node("bottom_panel")
	for input in bottom_panel.get_children():
		input.set_disabled(true)

func _end_game(did_win, disable_all_input):
	game_status = "game_over"
	var timer = get_node("timer")
	end_game_time_left = timer.get_time_left()
	timer.stop()
	_set_message_index(_get_message_index() + 1)
	
	if(did_win):
		_win(disable_all_input)
	else:
		_lost(disable_all_input)

func _win(disable_all_input):
	if(disable_all_input):
		_disable_all()
	_show_win()

func _lost(disable_all_input):
	if(disable_all_input):
		_disable_all()
	_show_lost()

func _show_win():
	_show_dialog("Congratulations! You have successfully uncover the message.")

func _show_lost():
	_show_dialog("You have failed on this level.\nSorry, there is no turning back.")

func _show_dialog(text, ok="Next level"):
	var dialog = get_node("status_dialog")
	dialog.set_text(text)
	dialog.get_ok().set_text(ok)
	dialog.popup_centered()

func _on_status_dialog_confirmed():
	_show_loading()
	_update_player()

func _goto_main():
	get_tree().change_scene("res://kangaroo/main/main.scn")

func _goto_game_over():
	get_tree().change_scene("res://kangaroo/end/end.scn")

func _valid_bonus_points(time_left):
	var x = wait_time - time_left
	if(bonus_time_limit == 0 or x <= bonus_time_limit):
		return true
	else:
		return false

func _show_game_points(game_points):
	var current_points = _get_player_points()
	var total_points = game_points + current_points
	_set_player_points(total_points)
	_display_actual_points(_format_points(_get_player_points()))

func _compute_win_points():
	var x = (end_game_time_left / wait_time)
	var y = max_error - errors
	var bonus = _compute_bonus_points()
	var points = round(x * 100) + y + bonus
	return points

func _compute_bonus_points():
	if(_valid_bonus_points(end_game_time_left)):
		return bonus_points
	else:
		return 0

func _compute_lost_points_on_timeout():
	var x = wait_time * 0.25
	var y = (errors / max_error) * 10
	var points = round(x + y)
	return points * -1

func _compute_lost_points_on_max_error_reached():
	var x = wait_time * 0.30
	var y = ((wait_time - end_game_time_left) / wait_time) * 15
	var points = round(x + y)
	return points * -1

func _compute_lost_points_on_max_characters():
	var x = wait_time * 0.35
	var y1 = errors / max_error
	var y2 = (wait_time - end_game_time_left) / wait_time
	var y3 = (y1 + y2) / 2
	var y = y3 * 20
	var points = round(x + y)
	return points * -1

func _compute_lost_points_on_quit():
	return round(wait_time + max_error) * -1

func _format_points(points, separator=","):
	if(points >= 1000):
		var points_str = str(points)
		var formatted = ""
		while(points_str.length() > 3):
			var start_pos = points_str.length() - 3
			var substr = points_str.substr(start_pos, 3)
			points_str = points_str.replace(substr, "")
			formatted = str(separator, substr, formatted)
		formatted = str(points_str, formatted)
		return formatted
	else:
		return str(points)

func _get_player_points():
	var global = get_node("/root/global")
	return global.get_player_points()

func _set_player_points(what):
	var global = get_node("/root/global")
	global.set_player_points(what)

func _get_message_index():
	var global = get_node("/root/global")
	return global.get_message_index()

func _set_message_index(what):
	var global = get_node("/root/global")
	global.set_message_index(what)

func _format_time_left(time_left):
	var minutes = int(ceil(time_left) / 60)
	var seconds = int(ceil(time_left) - (minutes * 60))
	var formatted = str(minutes, ":")
	if(seconds < 10):
		formatted += str(0,seconds)
	else:
		formatted += str(seconds)
	return formatted

func _should_deduct_on_quit():
	return selected_characters > 0

func _on_quit():
	did_press_quit = true
	if(_should_deduct_on_quit()):
		_set_message_index(_get_message_index() + 1)
		print("message_index: ", _get_message_index())
		var points = _compute_lost_points_on_quit()
		_show_game_points(points)
		var text = str("You are deducted with ", (points * -1), " points. See you next time.")
		_show_dialog(text, "OK")
	else:
		_goto_main()

func _on_exit_scene():
	if(selected_characters > 0 and game_status == "playing" and !did_press_quit):
		var points = _get_player_points()
		var deducted_points = _compute_lost_points_on_quit()
		var current_points = points + deducted_points
		_set_player_points(current_points)
		_set_message_index(_get_message_index() + 1)
		_write_data()

func _write_data():
	pass

func _update_player():
	var request = get_node("update_player")
	var global = get_node("/root/global")
	var user_id = global.get_user_id()
	var message_index = _get_message_index()
	var player_points = _get_player_points()
	request.auth = global.auth
	request.update(user_id, message_index, player_points)

func _on_update_completed(status_code):
	if(status_code == HTTPClient.RESPONSE_OK):
		if(game_status == "game_over"):
			_reload()
		else:
			_goto_main()

func _reload():
	get_tree().reload_current_scene()

# Finds all occurrence of a given substring.
func _find_all(string, sub_string):
	var start = 0
	var indices = []
	while(true):
		start = string.find(sub_string, start)
		if(start == -1):
			break
		else:
			indices.append(start)
			start += sub_string.length()
	var occurrences = IntArray(indices)
	return occurrences