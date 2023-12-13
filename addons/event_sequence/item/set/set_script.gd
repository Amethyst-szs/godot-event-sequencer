@tool
extends EventItemScriptBase

func get_name() -> String:
	return "Set Property with Script"

func get_description() -> String:
	return "Set a variable in an object using GDScript.
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Set

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
			EventConst.userdata_key_name: "object",
			EventConst.userdata_key_display: "Object/Node",
			EventConst.userdata_key_desc: "Var name with object",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
		{
			EventConst.userdata_key_name: "property",
			EventConst.userdata_key_desc: "Name of property",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
		{
			EventConst.userdata_key_name: "input",
			EventConst.userdata_key_display: "Input Variable",
			EventConst.userdata_key_desc: "Variable to pass into function",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: false,
		},
		{
			EventConst.userdata_key_name: "code",
			EventConst.userdata_key_desc: "Write GDScript here. Use \"input\" to access input variable. Return data to write to property.",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_type_hint: "text_edit",
			EventConst.userdata_key_require: true,
		},
	]

func get_color() -> Color:
	return Color.ROYAL_BLUE.lightened(0.2)

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-SetScript.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_userdata("object") or not is_valid_userdata("property"):
		return EventConst.ItemResponseType.OK
	
	if not event_node.var_database.has(userdata["object"]):
		warn("No variable with name %s" % userdata["object"])
		return EventConst.ItemResponseType.OK
	
	var obj = event_node.var_database[userdata["object"]]
	if typeof(obj) != TYPE_OBJECT:
		warn("Variable provived as object does not contain object")
		return EventConst.ItemResponseType.OK
	
	var result = _build_and_run_script(event_node)
	
	if typeof(result) == TYPE_STRING and result == "__FAILED":
		error("Failed to run, did not recieve return data from script execution!")
		return EventConst.ItemResponseType.TERMINATE
	
	obj.set(userdata["property"], result)
	return EventConst.ItemResponseType.OK
