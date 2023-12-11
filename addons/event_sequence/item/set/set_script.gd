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
			"name": "object",
			"display_name": "Object/Node",
			"desc": "Var name with object",
			"type": TYPE_STRING,
			"require": true,
		},
		{
			"name": "property",
			"desc": "Name of property",
			"type": TYPE_STRING,
			"require": true,
		},
		{
			"name": "input",
			"display_name": "Input Variable",
			"desc": "Variable to pass into function",
			"type": TYPE_STRING,
			"require": false,
		},
		{
			"name": "code",
			"desc": "Write GDScript here. Use \"input\" to access input variable. Return data to write to property.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
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
