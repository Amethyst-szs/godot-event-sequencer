@tool
extends Tree

signal refresh_tree

func _ready():
	set_column_title(EventConst.EditorColumn.NAME, "Name")
	set_column_title(EventConst.EditorColumn.PROPERTY1, "None")
	set_column_title(EventConst.EditorColumn.PROPERTY2, "None")

#region Drag and Drop Functionality

func _get_drag_data(position: Vector2):
	if not get_selected():
		return
	
	set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)

	var preview = Label.new()
	preview.text = get_selected().get_text(0)
	set_drag_preview(preview)
	
	return get_selected()

func _can_drop_data(position: Vector2, data) -> bool:
	var to_item: TreeItem = get_item_at_position(position)
	var shift: int = get_drop_section_at_position(position)
	
	if shift != 0:
		return data is TreeItem
	
	var is_bad_drop: bool = _check_for_target_in_data(to_item, data.get_children())
	return not is_bad_drop

func _check_for_target_in_data(target_item: TreeItem, source_children: Array[TreeItem]):
	for item in source_children:
		if item == target_item:
			return true
		
		if item.get_child_count() > 0:
			if _check_for_target_in_data(target_item, item.get_children()):
				return true
	
	return false

func _drop_data(position, item):
	var to_item: TreeItem = get_item_at_position(position)
	var shift: int = get_drop_section_at_position(position)
	
	match(shift):
		0:
			if item == to_item:
				return
			
			item.get_parent().remove_child(item)
			to_item.add_child(item)
		-1:
			item.move_before(to_item)
		1:
			item.move_after(to_item)
		-100:
			if position.y > 100:
				item.move_after(get_root().get_child(get_root().get_child_count() - 1))
			else:
				item.move_before(get_root().get_first_child())
	
	refresh_tree.emit()
	
	#endregion
