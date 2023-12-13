@tool
extends EventItemBase
class_name EventItemScriptBase

#region Configuration

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
			EventConst.userdata_key_name: "input",
			EventConst.userdata_key_display: "Input Variable",
			EventConst.userdata_key_desc: "Variable to pass into function",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: false,
		},
		{
			EventConst.userdata_key_name: "code",
			EventConst.userdata_key_desc: "Write GDScript here. Use \"input\" to access variable.",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_type_hint: "text_edit",
			EventConst.userdata_key_require: true,
		},
	]

#endregion

#region Script Caching

var user_script_inst = null

func prepare():
	_build_script()

func _build_script():
	# Ensure the code userdata key exists and is valid
	if not is_valid_userdata("code") or userdata["code"].is_empty():
		error("No code has been set up! Write a script first!")
		return
	
	# Simple search and replace throughout the condition in userdata
	userdata["code"] = userdata["code"].replace("\n", "\n\t")
	userdata["code"] = userdata["code"].replace("input", "_input")
	
	# Generate GDScript file at runtime
	var script := GDScript.new()
	script.source_code = "func execute(_input = null):\n\t%s" % [userdata["code"]]
	var error: Error = script.reload()
	
	# Ensure script was compiled correctly
	if error != OK:
		error("Code failed to parse correctly, check your GDScript!")
		return
	
	# Generate instance of script
	user_script_inst = script.new()

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _run_script(event_node)
	return EventConst.ItemResponseType.OK

func _run_script(event_node: EventNode):
	if not user_script_inst:
		error("Skipping script, hasn't been precompiled!")
		return "__FAILED"
	
	# If script uses "input" value, ensure it actually exists
	if userdata["code"].contains("input"):
		if not userdata.has("input") or not event_node.var_database.has(userdata["input"]):
			error("Script uses input variable, but \"%s\" doesn't exist!" % [userdata["input"]])
			return "__FAILED"
	
	var result
	if userdata.has("input") and event_node.var_database.has(userdata["input"]):
		result = user_script_inst.execute(event_node.var_database[userdata["input"]])
	else:
		result = user_script_inst.execute()
	
	return result
