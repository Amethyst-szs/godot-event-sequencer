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

func get_first_column_config() -> Dictionary:
	return {
		"name": "Message",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Comment.svg"
