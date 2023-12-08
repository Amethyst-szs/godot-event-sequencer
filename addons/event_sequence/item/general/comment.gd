@tool
extends EventItemBase

func get_name() -> String:
	return "Comment"

func get_description() -> String:
	return "Skipped when running, use this to leave notes or make folders in your sequence"

func is_allow_in_editor() -> bool:
	return true

func is_comment() -> bool:
	return true

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/test-icon.svg"
