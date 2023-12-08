@tool
extends EventItemBase
class_name EventItemFetchBase

func get_name() -> String:
	return "FetchBase"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Fetch

func is_allow_in_editor() -> bool:
	return false

func get_first_column_config() -> Dictionary:
	return {
		"name": "Variable Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Fetch Target",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.GOLD

func get_icon_path() -> String:
	return "res://icon.svg"
