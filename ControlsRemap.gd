extends Resource
class_name ControlsRemap

const ACTION_LIST = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "ui_cancel"]

export var prefix: String setget set_prefix
export var keyboard_remap: Dictionary
export var joypad_remap: Dictionary

var default_keyboard: Dictionary
var default_joypad: Dictionary

var stashed_keyboard: Dictionary
var stashed_joypad: Dictionary

func _init(p_prefix := "") -> void:
	prefix = p_prefix
	load_defaults()

func set_prefix(p_prefix: String):
	prefix = p_prefix
	load_defaults()

func load_defaults():
	for action in ACTION_LIST:
		_map_input(default_keyboard, action, get_action_key(action))
		_map_input(default_joypad, action, get_action_button(action))

func create_remap():
	keyboard_remap.clear()
	joypad_remap.clear()
	var keyboard_actions: Dictionary
	var joypad_actions: Dictionary
	
	for action in ACTION_LIST:
		_map_input(keyboard_actions, action, get_action_key(action))
		_map_input(joypad_actions, action, get_action_button(action))
	
	for action in ACTION_LIST:
		if action in keyboard_actions and action in default_keyboard:
			if keyboard_actions[action] != default_keyboard[action]:
				keyboard_remap[action] = keyboard_actions[action]
		
		if action in joypad_actions and action in default_joypad:
			if joypad_actions[action] != default_joypad[action]:
				joypad_remap[action] = joypad_actions[action]

func apply_remap():
	restore_default_controls()
	for action in ACTION_LIST:
		_demap_input(keyboard_remap, action, get_action_key(action))
		_demap_input(joypad_remap, action, get_action_button(action))

func restore_default_controls():
	for action in ACTION_LIST:
		restore_action_default(action)

func restore_action_default(action: String):
	_demap_input(default_keyboard, action, get_action_key(action))
	_demap_input(default_joypad, action, get_action_button(action))

func clone_remap():
	stashed_keyboard = keyboard_remap.duplicate()
	stashed_joypad = joypad_remap.duplicate()

func restore_cloned_remap():
	keyboard_remap = stashed_keyboard.duplicate()
	joypad_remap = stashed_joypad.duplicate()

func set_action_key(action: String, key: InputEventKey) -> bool:
	for event in InputMap.get_action_list(prefix + action):
		if event is InputEventKey:
			event.scancode = key.scancode
			return true
	return false

func get_action_key(action: String) -> InputEventKey:
	for event in InputMap.get_action_list(prefix + action):
		if event is InputEventKey:
			return event
	return null

func set_action_button(action: String, button: InputEventJoypadButton) -> bool:
	for event in InputMap.get_action_list(prefix + action):
		if event is InputEventJoypadButton:
			event.button_index = button.button_index
			return true
	return false

func get_action_button(action: String) -> InputEventJoypadButton:
	for event in InputMap.get_action_list(prefix + action):
		if event is InputEventJoypadButton:
			return event
	return null

func find_duplicates() -> Array:
	var dupes: Array
	
	for action in ACTION_LIST:
		var key1 := get_action_key(action)
		if key1:
			for action2 in ACTION_LIST:
				if action == action2:
					continue
				
				var key2 := get_action_key(action2)
				if key2:
					if key1.scancode == key2.scancode:
						dupes.append(action)
						break
	
	for action in ACTION_LIST:
		if action in dupes:
			continue
		
		var button1 := get_action_button(action)
		if button1:
			for action2 in ACTION_LIST:
				if action == action2:
					continue
				
				var button2 := get_action_button(action2)
				if button2:
					if button1.button_index == button2.button_index:
						dupes.append(action)
						break
	
	return dupes

func _map_input(map: Dictionary, action: String, input):
	if input is InputEventKey:
		map[action] = input.scancode
	elif input is InputEventJoypadButton:
		map[action] = input.button_index

func _demap_input(map: Dictionary, action: String, input):
	if not action in map:
		return
	
	if input is InputEventKey:
		input.scancode = map[action]
	elif input is InputEventJoypadButton:
		input.button_index = map[action]
