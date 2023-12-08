@tool
extends EventItemBase

func get_name() -> String:
	return "Test Item"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Method

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Variable Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Custom",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "test",
			"type": TYPE_STRING
		}
	]

func get_color() -> Color:
	return Color.MAGENTA

func get_icon_path() -> String:
	return "res://icon.svg"
