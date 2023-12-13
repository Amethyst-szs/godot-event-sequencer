@tool
extends EventItemVarBase

func get_name() -> String:
	return "Create New Float"

func get_description() -> String:
	return "Create a new float value and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetMakeFloat.svg"

func get_second_column_config() -> Dictionary:
	return {
		"name": "Value",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			EventConst.userdata_key_name: "value",
			EventConst.userdata_key_desc: "Value",
			EventConst.userdata_key_type: TYPE_FLOAT,
			EventConst.userdata_key_require: true,
			EventConst.userdata_key_default: 0.0,
		}
	]

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, true):
		return EventConst.ItemResponseType.OK
	
	if not userdata.has("value"):
		event_node.var_database[event_variable] = 0
		return EventConst.ItemResponseType.OK
	
	event_node.var_database[event_variable] = userdata["value"]
	return EventConst.ItemResponseType.OK
