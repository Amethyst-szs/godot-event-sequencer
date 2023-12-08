@tool
extends EventItemBase

func get_name() -> String:
	return "Event Item Base"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.General

func is_comment() -> bool:
	return false

func get_color() -> Color:
	return Color.ORANGE

func get_icon_path() -> String:
	return "res://icon.svg"
