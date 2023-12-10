@tool
extends EventItemVarBase

func get_name() -> String:
	return "Get First Node in Group"

func get_description() -> String:
	return "Get the first node in a group, and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Group Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetGroupFirst.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, true):
		return EventConst.ItemResponseType.OK
	
	# Get the first node in the group
	var group_name: String = userdata[EventConst.item_key_userdata_generic]
	var node: Node = event_node.get_tree().get_first_node_in_group(group_name)
	event_node.var_database[event_variable] = node
	
	return EventConst.ItemResponseType.OK
