@icon("uid://rdhqkhh5bmca")
class_name ControlsRemap extends Resource

## A resource for modifying, saving and loading project's InputMap.
##
## Stores and applies input map changes. The action list can be configured via "addons/ControlsRemap/action_list" project setting. Physical key events are not supported.

const _SETTING_NAME = "addons/ControlsRemap/action_list"
const _DEFAULT_ACTION_LIST: Array[StringName] = [&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_accept", &"ui_cancel"]

## Prefix for this remap resource (useful for multiple control schemes in multiplayer games etc).
## [br][br][b]Note:[/b] Setting this property erases remaps stored in this resource. Set it only during initialization.
@export var prefix: String:
	set(p_prefix):
		prefix = p_prefix
		
		_action_list = ProjectSettings.get_setting(_SETTING_NAME, _DEFAULT_ACTION_LIST)
		if not prefix.is_empty():
			_action_list.assign(_action_list.map(func(action: StringName) -> StringName: return prefix + action))
		
		_keyboard_remap.clear()
		_joypad_remap.clear()
		_load_defaults()

@export_storage var _keyboard_remap: Dictionary[StringName, int]
@export_storage var _joypad_remap: Dictionary[StringName, int]

var _action_list: Array[StringName]

var _default_keyboard: Dictionary[StringName, int]
var _default_joypad: Dictionary[StringName, int]

var _stashed_keyboard: Dictionary[StringName, int]
var _stashed_joypad: Dictionary[StringName, int]

func _init(p_prefix := "") -> void:
	prefix = p_prefix

## Creates a remap by fetching the actions from [InputMap]. Only non-default actions are stored.
func create_remap():
	_keyboard_remap.clear()
	_joypad_remap.clear()
	
	var keyboard_actions: Dictionary[StringName, int]
	var joypad_actions: Dictionary[StringName, int]
	
	for action in _action_list:
		_map_input(keyboard_actions, action, get_action_key(action))
		
		if keyboard_actions.get(action, -1) != _default_keyboard.get(action, -1):
			_keyboard_remap[action] = keyboard_actions[action]
		
		_map_input(joypad_actions, action, get_action_button(action))
		
		if joypad_actions.get(action, -1) != _default_joypad.get(action, -1):
			_joypad_remap[action] = joypad_actions[action]

## Applies the inputs from this ControlsRemap to the projects InputMap.
func apply_remap():
	restore_default_controls()
	for action in _action_list:
		_demap_input(_keyboard_remap, action, get_action_key(action))
		_demap_input(_joypad_remap, action, get_action_button(action))

## Restores all actions to the defaults defined in project's settings.
func restore_default_controls():
	for action in _action_list:
		restore_action_default(action)

## Restores a single action to its default state.
func restore_action_default(action: String):
	_demap_input(_default_keyboard, action, get_action_key(action))
	_demap_input(_default_joypad, action, get_action_button(action))

## Creates an internal clone of the remap resource.
func clone_remap() -> void:
	_stashed_keyboard = _keyboard_remap.duplicate()
	_stashed_joypad = _joypad_remap.duplicate()

## Restores remap from the internal clone.
func restore_cloned_remap() -> void:
	_keyboard_remap = _stashed_keyboard.duplicate()
	_joypad_remap = _stashed_joypad.duplicate()

## Replaces the first [InputEventKey] in an action with the given one.
func set_action_key(action: String, key: InputEventKey) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			event.keycode = key.keycode
			return true
	return false

## Returns the first [InputEventKey] assigned to the action.
func get_action_key(action: String) -> InputEventKey:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event
	return null

## Replaces the first [InputEventJoypadButton] in an action with the given one.
func set_action_button(action: String, button: InputEventJoypadButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			event.button_index = button.button_index
			return true
	return false

## Returns the first [InputEventJoypadButton] assigned to the action.
func get_action_button(action: String) -> InputEventJoypadButton:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return event
	return null

## Returns an array of action names that have assigned conflicting input events.
func find_duplicates() -> Array[StringName]:
	var dupes: Array[StringName]
	
	for action in _action_list:
		var key1 := get_action_key(action)
		if not key1:
			continue
		
		for action2 in _action_list:
			if action == action2:
				continue
			
			var key2 := get_action_key(action2)
			if key2 and key1.keycode == key2.keycode:
				dupes.append(action)
				break
	
	for action in _action_list:
		if action in dupes:
			continue
		
		var button1 := get_action_button(action)
		if not button1:
			continue
		
		for action2 in _action_list:
			if action == action2:
				continue
			
			var button2 := get_action_button(action2)
			if button2 and button1.button_index == button2.button_index:
				dupes.append(action)
				break
	
	return dupes

func _load_defaults():
	_default_keyboard.clear()
	_default_joypad.clear()
	
	for action in _action_list:
		_map_input(_default_keyboard, action, get_action_key(action))
		_map_input(_default_joypad, action, get_action_button(action))

func _map_input(map: Dictionary[StringName, int], action: StringName, input: InputEvent):
	var k := input as InputEventKey
	if k:
		map[action] = k.keycode
		return
	
	var j := input as InputEventJoypadButton
	if j:
		map[action] = j.button_index

func _demap_input(map: Dictionary[StringName, int], action: StringName, input: InputEvent):
	if not action in map:
		return
	
	var k := input as InputEventKey
	if k:
		k.keycode = map[action]
		return
	
	var j := input as InputEventJoypadButton
	if j:
		j.button_index = map[action]
