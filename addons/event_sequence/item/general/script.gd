@tool
extends EventItemScriptBase

func get_name() -> String:
	return "Script"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.General

func get_description() -> String:
	return "Write GDScript and run it."

func is_allow_in_editor() -> bool:
	return true

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Script.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _run_script(event_node)
	if typeof(result) == TYPE_STRING and result == "__FAILED":
		return EventConst.ItemResponseType.TERMINATE
	
	return EventConst.ItemResponseType.OK
