@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(ControlsRemap._SETTING_NAME):
		ProjectSettings.set_setting(ControlsRemap._SETTING_NAME, ControlsRemap._DEFAULT_ACTION_LIST)
	
	ProjectSettings.set_initial_value(ControlsRemap._SETTING_NAME, ControlsRemap._DEFAULT_ACTION_LIST)
	ProjectSettings.add_property_info({ "name": ControlsRemap._SETTING_NAME, "type": TYPE_ARRAY, "hint": PROPERTY_HINT_TYPE_STRING, "hint_string": "21/43:show_builtin,loose_mode" })
