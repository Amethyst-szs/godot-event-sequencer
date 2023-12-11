@tool
extends EventItemFlowBase

#region Config

func get_name() -> String:
	return "If Condition"

func get_description() -> String:
	return "Only play this item's children if this variable matches a condition"

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
			"name": "condition",
			"display_name": "Condition",
			"desc": "Write GDScript here for your condition. Use \"input\" to access variable. Return true/false for if the condition was successful.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
		}
	]

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowIfCondition.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, false) or not is_valid_userdata("condition"):
		return EventConst.ItemResponseType.OK
	
	# Simple search and replace throughout the condition in userdata
	userdata["condition"] = userdata["condition"].replace("\n", "\n\t")
	userdata["condition"] = userdata["condition"].replace("input", "_input")
	
	if userdata["condition"].is_empty():
		error("No condition has been set up! Write a script first!")
		return EventConst.ItemResponseType.TERMINATE
	
	# Generate GDScript file at runtime
	var script := GDScript.new()
	script.source_code = "func condition(_input):\n\t%s" % [userdata["condition"]]
	var error: Error = script.reload()
	
	# Ensure script was compiled correctly
	if error != OK:
		error("Condition failed to parse correctly, check your GDScript!")
		return EventConst.ItemResponseType.TERMINATE
	
	# Call generated function
	var obj = script.new()
	var result = obj.condition(event_node.var_database[event_variable])
	
	# Ensure result is boolean
	if typeof(result) != TYPE_BOOL:
		error("Condition returned non-bool value, check your GDScript!\nValue: %s" % result)
		return EventConst.ItemResponseType.TERMINATE
	
	if result == true:
		return EventConst.ItemResponseType.OK
	else:
		return EventConst.ItemResponseType.SKIP_CHILDREN
