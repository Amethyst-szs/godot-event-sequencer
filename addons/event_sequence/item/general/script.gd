@tool
extends EventItemScriptBase

func get_name() -> String:
	return "Script"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.General

func get_description() -> String:
	return "Write GDScript and run it.
		The code is compiled at runtime, making this not performance friendly.
		Try to avoid writing more than a couple simple lines."

func is_allow_in_editor() -> bool:
	return true

func get_color() -> Color:
	return Color.LIGHT_BLUE

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Script.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var result = _build_and_run_script(event_node)
	if result == "__FAILED":
		return EventConst.ItemResponseType.TERMINATE
	
	return EventConst.ItemResponseType.OK
