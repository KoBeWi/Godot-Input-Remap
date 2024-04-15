@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("addons/ControlsRemap/action_list"):
		var defaults: Array[StringName]
		defaults.assign([&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_accept", &"ui_cancel"])
		ProjectSettings.set_setting("addons/ControlsRemap/action_list", defaults)
	ProjectSettings.add_property_info({ "name": "addons/ControlsRemap/action_list", "type": TYPE_ARRAY, "hint": PROPERTY_HINT_TYPE_STRING, "hint_string": "21:StringName" })
