@icon("res://addons/ControlsRemap/Icon.png")
extends Resource
class_name ControlsRemap

## A resource for modifying, saving and loading project's InputMap.

## List of actions you want to handle. Define it in "addons/ControlsRemap/action_list" project setting.
var action_list: Array[StringName]

## Prefix for this remap resource (useful for multiple control schemes in multiplayer games etc).
@export var prefix: String:
	set(p_prefix):
		prefix = p_prefix
		_load_defaults()

@export var _keyboard_remap: Dictionary
@export var _joypad_remap: Dictionary

var _default_keyboard: Dictionary
var _default_joypad: Dictionary

var _stashed_keyboard: Dictionary
var _stashed_joypad: Dictionary

func _init(p_prefix := "") -> void:
	prefix = p_prefix
	action_list = ProjectSettings.get_setting("addons/ControlsRemap/action_list")
	_load_defaults()

## Creates a remap by fetching the actions from ActionMap. Only non-default actions are stored.
func create_remap():
	_keyboard_remap.clear()
	_joypad_remap.clear()
	var keyboard_actions: Dictionary
	var joypad_actions: Dictionary
	
	for action in action_list:
		_map_input(keyboard_actions, action, get_action_key(action))
		_map_input(joypad_actions, action, get_action_button(action))
	
	for action in action_list:
		if action in keyboard_actions and action in _default_keyboard:
			if keyboard_actions[action] != _default_keyboard[action]:
				_keyboard_remap[action] = keyboard_actions[action]
		
		if action in joypad_actions and action in _default_joypad:
			if joypad_actions[action] != _default_joypad[action]:
				_joypad_remap[action] = joypad_actions[action]

## Applies the inputs from this ControlsRemap to the projects InputMap.
func apply_remap():
	restore_default_controls()
	for action in action_list:
		_demap_input(_keyboard_remap, action, get_action_key(action))
		_demap_input(_joypad_remap, action, get_action_button(action))

## Restores all actions to the defaults defined in project's settings.
func restore_default_controls():
	for action in action_list:
		restore_action_default(action)

## Restores a single action to its default state.
func restore_action_default(action: String):
	_demap_input(_default_keyboard, action, get_action_key(action))
	_demap_input(_default_joypad, action, get_action_button(action))

## Creates an internal clone of the remap resource.
func clone_remap():
	_stashed_keyboard = _keyboard_remap.duplicate()
	_stashed_joypad = _joypad_remap.duplicate()

## Restores remap from the internal clone.
func restore_cloned_remap():
	_keyboard_remap = _stashed_keyboard.duplicate()
	_joypad_remap = _stashed_joypad.duplicate()

## Replaces the first InputEventKey in an action with the given one.
func set_action_key(action: String, key: InputEventKey) -> bool:
	for event in InputMap.action_get_events(prefix + action):
		if event is InputEventKey:
			event.keycode = key.keycode
			return true
	return false

## Returns the first InputEventKey assigned to the action.
func get_action_key(action: String) -> InputEventKey:
	for event in InputMap.action_get_events(prefix + action):
		if event is InputEventKey:
			return event
	return null

## Replaces the first InputEventJoypadButton in an action with the given one.
func set_action_button(action: String, button: InputEventJoypadButton) -> bool:
	for event in InputMap.action_get_events(prefix + action):
		if event is InputEventJoypadButton:
			event.button_index = button.button_index
			return true
	return false

## Returns the first InputEventJoypadButton assigned to the action.
func get_action_button(action: String) -> InputEventJoypadButton:
	for event in InputMap.action_get_events(prefix + action):
		if event is InputEventJoypadButton:
			return event
	return null

## Returns an array of action names that have assigned conflicting input events.
func find_duplicates() -> Array[String]:
	var dupes: Array[String]
	
	for action in action_list:
		var key1 := get_action_key(action)
		if key1:
			for action2 in action_list:
				if action == action2:
					continue
				
				var key2 := get_action_key(action2)
				if key2:
					if key1.scancode == key2.scancode:
						dupes.append(action)
						break
	
	for action in action_list:
		if action in dupes:
			continue
		
		var button1 := get_action_button(action)
		if button1:
			for action2 in action_list:
				if action == action2:
					continue
				
				var button2 := get_action_button(action2)
				if button2:
					if button1.button_index == button2.button_index:
						dupes.append(action)
						break
	
	return dupes

func _load_defaults():
	for action in action_list:
		_map_input(_default_keyboard, action, get_action_key(action))
		_map_input(_default_joypad, action, get_action_button(action))

func _map_input(map: Dictionary, action: String, input):
	if input is InputEventKey:
		map[action] = input.keycode
	elif input is InputEventJoypadButton:
		map[action] = input.button_index

func _demap_input(map: Dictionary, action: String, input):
	if not action in map:
		return
	
	if input is InputEventKey:
		input.keycode = map[action]
	elif input is InputEventJoypadButton:
		input.button_index = map[action]
