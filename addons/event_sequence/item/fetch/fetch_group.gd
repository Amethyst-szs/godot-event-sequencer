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

func run(event_node: EventNode) -> bool:
	var group_name: String = userdata[EventConst.item_key_userdata_generic]
	
	if event_variable.is_empty():
		push_warning("EventNode: You must set the variable name to store this fetch into!")
		return true
	
	if typeof(group_name) == TYPE_NIL:
		push_warning("EventNode tried to fetch group but didn't have a group name!")
		return true
	
	var nodes: Array[Node] = event_node.get_tree().get_nodes_in_group(group_name)
	event_node.fetch_database[event_variable] = nodes
	return true
