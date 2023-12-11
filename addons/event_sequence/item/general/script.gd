@tool
extends EventItemBase

func get_name() -> String:
	return "Script"

func get_description() -> String:
	return "Write GDScript and run it.
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Input Variable",
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
			"name": "code",
			"desc": "Write GDScript here. Use \"input\" to access variable.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
		}
	]

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Script.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, false) or not is_valid_userdata("code"):
		return EventConst.ItemResponseType.OK
	
	# Simple search and replace throughout the condition in userdata
	userdata["code"] = userdata["code"].replace("\n", "\n\t")
	userdata["code"] = userdata["code"].replace("input", "_input")
	
	if userdata["code"].is_empty():
		error("No code has been set up! Write a script first!")
		return EventConst.ItemResponseType.TERMINATE
	
	# Generate GDScript file at runtime
	var script := GDScript.new()
	script.source_code = "func execute(_input):\n\t%s" % [userdata["code"]]
	var error: Error = script.reload()
	
	# Ensure script was compiled correctly
	if error != OK:
		error("Code failed to parse correctly, check your GDScript!")
		return EventConst.ItemResponseType.TERMINATE
	
	# Call generated function
	var obj = script.new()
	obj.execute(event_node.var_database[event_variable])
	
	return EventConst.ItemResponseType.OK
