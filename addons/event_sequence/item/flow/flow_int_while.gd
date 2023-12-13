@tool
extends EventItemScriptBase

#region Config

func get_name() -> String:
	return "While Condition"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func get_description() -> String:
	return "Run this item's children repeatedly until a GDScript condition is false."

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

func get_color() -> Color:
	return Color.ORANGE_RED.lightened(0.2)

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowInWhile.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	# Ensure the user script instance was generated and cached successfully
	if not user_script_inst:
		error("Skipping while loop, script hasn't been precompiled successfully!")
		return EventConst.ItemResponseType.SKIP_CHILDREN
	
	# Ensure this isn't a nested while loop, those aren't supported
	if event_node.while_loop_condition_script:
		warn("Ignoring nested while condition. EventNodes do not support nested while loops.")
		return EventConst.ItemResponseType.SKIP_CHILDREN

	# Ensure input value exists
	if not userdata.has("input") or not event_node.var_database.has(userdata["input"]):
		error("Input variable not defined \"%s\"!" % [userdata["input"]])
		return EventConst.ItemResponseType.TERMINATE
	
	event_node.while_loop_condition_script = user_script_inst
	event_node.while_loop_condition_input = userdata["input"]
	return EventConst.ItemResponseType.LOOP_WHILE
