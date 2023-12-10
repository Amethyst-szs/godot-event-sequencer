@tool
extends EventItemBase

func get_name() -> String:
	return "Print Variable"

func get_description() -> String:
	return "Write contents of a variable to the output log"

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Variable Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Print.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not event_variable.is_empty() and event_node.var_database.has(event_variable):
		print(event_node.var_database[event_variable])
	
	return EventConst.ItemResponseType.OK
