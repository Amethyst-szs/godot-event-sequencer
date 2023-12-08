@tool
extends EventItemBase

func get_name() -> String:
	return "Print"

func get_description() -> String:
	return "Write a message to the output log"

func is_allow_in_editor() -> bool:
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
	return "res://addons/event_sequence/test-icon.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not event_variable.is_empty():
		print("%s (From event item \"%s\")" % [event_variable, name])
	
	return EventConst.ItemResponseType.OK
