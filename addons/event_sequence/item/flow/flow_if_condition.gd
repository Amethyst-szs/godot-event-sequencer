@tool
extends EventItemScriptBase

#region Config

func get_name() -> String:
	return "If Condition"

func get_description() -> String:
	return "Only play this item's children if this variable matches a condition
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func is_allow_in_editor() -> bool:
	return true

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
			"display_name": "Condition",
			"desc": "Write GDScript here for your condition. Use \"input\" to access variable. Return true/false for if the condition was successful.",
			"type": TYPE_STRING,
			"type_hint": "text_edit",
			"require": true,
		}
	]

func get_color() -> Color:
	return Color.MEDIUM_PURPLE.lightened(0.3)

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowIfCondition.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _build_and_run_script(event_node)
	
	if typeof(result) != TYPE_BOOL:
		error("Failed to run, did not recieve boolean from script execution!")
		return EventConst.ItemResponseType.TERMINATE
	
	if result == true:
		return EventConst.ItemResponseType.OK
	else:
		return EventConst.ItemResponseType.SKIP_CHILDREN
