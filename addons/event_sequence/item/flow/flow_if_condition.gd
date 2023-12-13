@tool
extends EventItemScriptBase

#region Config

func get_name() -> String:
	return "If Condition"

func get_description() -> String:
	return "Only play this item's children if this variable matches a condition."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func is_allow_in_editor() -> bool:
	return true

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
			EventConst.userdata_key_display: "Condition",
			EventConst.userdata_key_desc: "Write GDScript here for your condition. Use \"input\" to access variable. Return true/false for if the condition was successful.",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_type_hint: "text_edit",
			EventConst.userdata_key_require: true,
		}
	]

func get_color() -> Color:
	return Color.ORANGE_RED.lightened(0.2)

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowIfCondition.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _run_script(event_node)
	
	if typeof(result) != TYPE_BOOL:
		error("Failed to run, did not recieve boolean from script execution!")
		return EventConst.ItemResponseType.TERMINATE
	
	if result == true:
		return EventConst.ItemResponseType.OK
	else:
		return EventConst.ItemResponseType.SKIP_CHILDREN
