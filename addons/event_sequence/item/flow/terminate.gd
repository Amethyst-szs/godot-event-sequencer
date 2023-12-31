@tool
extends EventItemBase

func get_name() -> String:
	return "Stop"

func get_description() -> String:
	return "End sequence here, with an optional error message"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Optional Error Message",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.DARK_RED

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Terminate.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not event_variable.is_empty():
		error(event_variable)
	
	return EventConst.ItemResponseType.TERMINATE
