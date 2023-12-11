@tool
extends EventItemFlowBase

#region Config

func get_name() -> String:
	return "If Defined"

func get_description() -> String:
	return "Only play this item's children if this variable name is defined"

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Variable Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "invert",
			"display_name": "Run if NOT true",
			"desc": "",
			"type": TYPE_BOOL,
			"require": false,
		}
	]

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowWaitSignalAny.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	# Ensure the key exists and it is not null
	var is_valid: bool = event_node.var_database.has(event_variable)
	if is_valid:
		is_valid = typeof(event_node.var_database[event_variable]) != TYPE_NIL
	
	# Flip result if the invert setting is set
	if userdata.has("invert") and userdata["invert"] == true:
		is_valid = not is_valid
	
	if is_valid:
		return EventConst.ItemResponseType.OK
	else:
		return EventConst.ItemResponseType.SKIP_CHILDREN
