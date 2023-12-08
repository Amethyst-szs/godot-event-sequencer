@tool
extends EventItemFetchBase

func get_name() -> String:
	return "Fetch Singleton"

func get_description() -> String:
	return "Get the root node of a singleton by name, and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Singleton Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> bool:
	var singleton_name: String = userdata[EventConst.item_key_userdata_generic]
	var tree_root: Window = event_node.get_tree().root
	
	if event_variable.is_empty():
		push_warning("EventNode: You must set the variable name to store this fetch into!")
		return true
	
	for node in tree_root.get_children():
		if singleton_name == node.name:
			event_node.fetch_database[event_variable] = node
			return true
	
	push_warning("EventNode tried to fetch Singleton/Autoload \"%s\" but couldn't find it!"
			% [singleton_name])
	
	return true
