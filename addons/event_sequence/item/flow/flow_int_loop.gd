@tool
extends EventItemFlowBase

#region Config

func get_name() -> String:
	return "Loop"

func get_description() -> String:
	return "Repeat this item's children some number of times determined by a variable"

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Loop Amount Variable",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowFor.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, false):
		return EventConst.ItemResponseType.SKIP_CHILDREN
	
	var loop_count: int = 0
	match typeof(event_node.var_database[event_variable]):
		TYPE_INT:
			loop_count = event_node.var_database[event_variable]
		TYPE_FLOAT:
			loop_count = int(round(event_node.var_database[event_variable]))
		_:
			warn("Variable passed into loop isn't an INT or FLOAT!")
			return EventConst.ItemResponseType.SKIP_CHILDREN
	
	event_node.new_for_loop_length = loop_count
	return EventConst.ItemResponseType.LOOP_FOR
