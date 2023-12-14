@tool
extends EventItemBase
class_name EventItemWaitBase

func get_name() -> String:
	return "WaitBase"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Wait

func is_allow_in_editor() -> bool:
	return false

func get_color() -> Color:
	return Color.LIGHT_SEA_GREEN.lightened(0.3)
