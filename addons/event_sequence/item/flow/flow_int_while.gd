@tool
extends EventItemFlowBase

func get_name() -> String:
	return "While Condition"

func get_description() -> String:
	return "Run this item's children repeatedly until a GDScript condition is false.
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "None",
		"editable": false,
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
			EventConst.userdata_key_name: "input",
			EventConst.userdata_key_display: "Input Variable",
			EventConst.userdata_key_desc: "Variable to pass into function",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
		{
			EventConst.userdata_key_name: "code",
			EventConst.userdata_key_desc: "Write GDScript here. Use \"input\" to access variable. Return true/false for if the condition was successful.",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_type_hint: "text_edit",
			EventConst.userdata_key_require: true,
		},
	]

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowInWhile.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	# Ensure this isn't a nested while loop, those aren't supported
	if event_node.while_loop_condition_script:
		warn("Ignoring nested while condition. EventNodes do not support nested while loops.")
		return EventConst.ItemResponseType.SKIP_CHILDREN
	
	if not is_valid_userdata("code"):
		return EventConst.ItemResponseType.TERMINATE
	
	# Ensure input value exists
	if not userdata.has("input") or not event_node.var_database.has(userdata["input"]):
		error("Input variable not defined \"%s\"!" % [userdata["input"]])
		return EventConst.ItemResponseType.TERMINATE
	
	# Simple search and replace throughout the condition in userdata
	userdata["code"] = userdata["code"].replace("\n", "\n\t")
	
	if userdata["code"].is_empty():
		error("No code has been set up! Write a script first!")
		return EventConst.ItemResponseType.TERMINATE
	
	# Generate GDScript file at runtime
	var script := GDScript.new()
	script.source_code = "func execute(input):\n\t%s" % [userdata["code"]]
	var error: Error = script.reload()
	
	# Ensure script was compiled correctly
	if error != OK:
		error("Code failed to parse correctly, check your GDScript!")
		return EventConst.ItemResponseType.TERMINATE
	
	event_node.while_loop_condition_script = script
	event_node.while_loop_condition_input = userdata["input"]
	return EventConst.ItemResponseType.LOOP_WHILE

