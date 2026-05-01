@tool
extends EditorPlugin

const SETTING_NAME = "addons/ControlsRemap/action_list"

func _enter_tree() -> void:
	var defaults: Array[StringName] = [&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_accept", &"ui_cancel"]
	if not ProjectSettings.has_setting(SETTING_NAME):
		ProjectSettings.set_setting(SETTING_NAME, defaults)
	
	ProjectSettings.set_initial_value(SETTING_NAME, defaults)
	ProjectSettings.add_property_info({ "name": SETTING_NAME, "type": TYPE_ARRAY, "hint": PROPERTY_HINT_TYPE_STRING, "hint_string": "21/43:show_builtin" })
