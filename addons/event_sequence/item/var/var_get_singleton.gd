@tool
extends EventItemVarBase

func get_name() -> String:
	return "Get Singleton"

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

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, true):
		return EventConst.ItemResponseType.OK
	
	var singleton_name: String = userdata[EventConst.item_key_userdata_generic]
	var tree_root: Window = event_node.get_tree().root
	
	for node in tree_root.get_children():
		if singleton_name == node.name:
			event_node.var_database[event_variable] = node
			return EventConst.ItemResponseType.OK
	
	warn("EventNode tried to get Singleton/Autoload \"%s\" but couldn't find it!"
			% [singleton_name])
	
	return EventConst.ItemResponseType.OK
