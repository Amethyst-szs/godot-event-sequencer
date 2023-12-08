@tool
extends EventItemFetchBase

func get_name() -> String:
	return "Fetch Nodes by Group"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Group Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> bool:
	if typeof(property2) == TYPE_NIL:
		push_warning("EventNode tried to fetch group but didn't have a group name!")
		return true
	
	var nodes: Array[Node] = event_node.get_tree().get_nodes_in_group(property2)
	event_node.fetch_database[property1] = nodes
	return true
