@tool
extends EventItemFlowBase

func get_name() -> String:
	return "Label"

func get_description() -> String:
	return "Create a label you can jump at any time.
		When this label is jumped to, the execution will continue from this point until
		reaching the end of its layer in the tree. It will not go to parent items of this label."

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
	return "res://addons/event_sequence/icon/EventItem-FlowLabel.svg"
