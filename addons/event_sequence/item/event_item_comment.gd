@tool
extends EventItem

func is_comment() -> bool:
	return true

func _get_color() -> Color:
	return Color.PURPLE

func _get_icon_path() -> String:
	return "res://addons/event_sequence/test-icon.svg"
