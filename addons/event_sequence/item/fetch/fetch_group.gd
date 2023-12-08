@tool
extends EventItemFetchBase

func get_name() -> String:
	return "Fetch Nodes by Group"

func get_description() -> String:
	return "Get an array of nodes in a group, and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Group Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, true):
		return EventConst.ItemResponseType.OK
	
	# Get array of nodes
	var group_name: String = userdata[EventConst.item_key_userdata_generic]
	var nodes: Array[Node] = event_node.get_tree().get_nodes_in_group(group_name)
	event_node.fetch_database[event_variable] = nodes
	
	return EventConst.ItemResponseType.OK
