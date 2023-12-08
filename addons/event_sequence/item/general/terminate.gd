@tool
extends EventItemBase

func get_name() -> String:
	return "Stop"

func get_description() -> String:
	return "End sequence here, with an optional error message"

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Optional Error Message",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.DARK_RED

func get_icon_path() -> String:
	return "res://addons/event_sequence/test-icon.svg"

func run(event_node: EventNode) -> bool:
	if not event_variable.is_empty():
		error(event_variable)
	
	return true
