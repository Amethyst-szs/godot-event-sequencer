@tool
extends EventItemFetchBase

func get_name() -> String:
	return "Fetch Singleton"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Singleton Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> bool:
	#var tree_root: Window = event_node.get_tree().root
	#for node in tree_root.get_children():
	#	if property2 == node.name:
	#		event_node.fetch_database[property1] = node
	#		return true
	
	#push_warning("EventNode tried to fetch Singleton/Autoload \"%s\" but couldn't find it!"
	#		% [property2])
	
	return true
