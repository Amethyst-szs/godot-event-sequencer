@tool
extends EventItemVarBase

func get_name() -> String:
	return "Create New Boolean"

func get_description() -> String:
	return "Create a new boolean value and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetMakeBool.svg"

func get_second_column_config() -> Dictionary:
	return {
		"name": "State",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			EventConst.userdata_key_name: "state",
			EventConst.userdata_key_desc: "False/True",
			EventConst.userdata_key_type: TYPE_BOOL,
			EventConst.userdata_key_require: true,
			EventConst.userdata_key_default: false,
		}
	]

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, true):
		return EventConst.ItemResponseType.OK
	
	if not userdata.has("state"):
		event_node.var_database[event_variable] = false
		return EventConst.ItemResponseType.OK
	
	event_node.var_database[event_variable] = userdata["state"]
	return EventConst.ItemResponseType.OK
