@tool
extends EventItemVarBase

func get_name() -> String:
	return "Get Node by Unique Name"

func get_description() -> String:
	return "Gets a node in the same scene as this EventNode by its unique name"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Unique Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, true):
		return EventConst.ItemResponseType.OK
	
	# Get node
	var unique_name: String = userdata[EventConst.item_key_userdata_generic]
	var node: Node = event_node.get_node("%s%s" % ["%", unique_name])
	event_node.var_database[event_variable] = node
	
	return EventConst.ItemResponseType.OK
