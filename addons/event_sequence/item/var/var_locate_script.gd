@tool
extends EventItemScriptBase

func get_name() -> String:
	return "Create with Script"

func get_description() -> String:
	return "Create or get a variable using GDScript and add it to event variables.
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Variable

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "New Variable Name",
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
			"name": "input",
			"display_name": "Input Variable",
			"desc": "Variable to pass into function",
			"type": TYPE_STRING,
			"require": false,
		},
		{
			"name": "code",
			"desc": "Write GDScript here. Use \"input\" to access variable. Return data to write to new variable.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
		},
	]

func get_color() -> Color:
	return Color.GOLD.darkened(0.2)

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetScript.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _build_and_run_script(event_node)
	
	if typeof(result) == TYPE_STRING and result == "__FAILED":
		error("Failed to run, did not recieve return data from script execution!")
		return EventConst.ItemResponseType.TERMINATE
	
	event_node.var_database[event_variable] = result
	return EventConst.ItemResponseType.OK
