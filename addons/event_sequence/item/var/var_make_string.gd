@tool
extends EventItemVarBase

func get_name() -> String:
	return "Create New String"

func get_description() -> String:
	return "Create a new string value and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetMakeString.svg"

func get_second_column_config() -> Dictionary:
	return {
		"name": "Text",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, true):
		return EventConst.ItemResponseType.OK
	
	event_node.var_database[event_variable] = userdata[EventConst.item_key_userdata_generic]
	return EventConst.ItemResponseType.OK
