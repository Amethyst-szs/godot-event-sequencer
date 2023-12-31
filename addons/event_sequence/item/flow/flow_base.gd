@tool
extends EventItemBase
class_name EventItemFlowBase

func get_name() -> String:
	return "FlowBase"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func is_allow_in_editor() -> bool:
	return false

func get_first_column_config() -> Dictionary:
	return {
		"name": "Variable Name (Node)",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Condition",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_color() -> Color:
	return Color.ORANGE_RED.lightened(0.2)
