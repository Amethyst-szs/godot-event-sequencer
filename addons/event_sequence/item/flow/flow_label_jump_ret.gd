@tool
extends EventItemFlowBase

func get_name() -> String:
	return "Jump to Label and Return"

func get_description() -> String:
	return "Jump to a label anywhere in the tree by name, and then return to this point and continue.
		WARNING: This can lead to stack overflows and other infinite loops, use responsibly."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Flow

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Label Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "None",
		"editable": false,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowLabelJumpRet.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if event_variable.is_empty() or not event_node.label_list.has(event_variable):
		error("Cannot jump to label \"%s\" that doesn't exist!" % [event_variable])
		return EventConst.ItemResponseType.TERMINATE
	
	event_node.label_jump_target = event_variable
	return EventConst.ItemResponseType.JUMP_AND_RETURN
