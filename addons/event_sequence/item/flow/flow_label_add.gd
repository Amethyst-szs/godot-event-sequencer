@tool
extends EventItemFlowBase

func get_name() -> String:
	return "Label"

func get_description() -> String:
	return "Create a label you can jump at any time"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

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
		"name": "None",
		"editable": false,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func is_label() -> bool:
	return true

func get_icon_path() -> String:
	return "res://icon.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	return EventConst.ItemResponseType.OK
