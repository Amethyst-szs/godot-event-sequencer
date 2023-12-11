@tool
extends EventItemBase
class_name EventItemScriptBase

func get_name() -> String:
	return "ScriptBase"

func is_allow_in_editor() -> bool:
	return false

func get_second_column_config() -> Dictionary:
	return {
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "input",
			"display_name": "Input Variable",
			"desc": "Variable to pass into function",
			"type": TYPE_STRING,
			"require": false,
		},
		{
			"name": "code",
			"desc": "Write GDScript here. Use \"input\" to access variable.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
		},
	]

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _build_and_run_script(event_node)
	return EventConst.ItemResponseType.OK

func _build_and_run_script(event_node: EventNode):
	if not is_valid_userdata("code"):
		return "__FAILED"
	
	# If script uses "input" value, ensure it actually exists
	if userdata["code"].contains("input"):
		if not userdata.has("input") or not event_node.var_database.has(userdata["input"]):
			error("Script uses input variable, but \"%s\" doesn't exist!" % [userdata["input"]])
			return "__FAILED"
	
	# Simple search and replace throughout the condition in userdata
	userdata["code"] = userdata["code"].replace("\n", "\n\t")
	userdata["code"] = userdata["code"].replace("input", "_input")
	userdata["code"] = userdata["code"].replace("__input", "_input")
	
	if userdata["code"].is_empty():
		error("No code has been set up! Write a script first!")
		return "__FAILED"
	
	# Generate GDScript file at runtime
	var script := GDScript.new()
	script.source_code = "func execute(_input = null):\n\t%s" % [userdata["code"]]
	var error: Error = script.reload()
	
	# Ensure script was compiled correctly
	if error != OK:
		error("Code failed to parse correctly, check your GDScript!")
		return "__FAILED"
	
	# Call generated function
	var obj = script.new()
	
	var result
	if userdata.has("input") and event_node.var_database.has(userdata["input"]):
		result = obj.execute(event_node.var_database[userdata["input"]])
	else:
		result = obj.execute()
	
	return result
