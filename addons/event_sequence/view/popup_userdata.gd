@tool
extends Popup

@onready var userdata_list: VBoxContainer = $Scroll/List

func build_menu(item: TreeItem, column: int):
	# Destroy the children of the userdata inspector
	for child in userdata_list.get_children():
		userdata_list.remove_child(child)
		child.queue_free()
	
	# Get copy of script from TreeItem
	var script_name: String = item.get_metadata(EventConst.EditorColumn.NAME)
	var item_script: Script = ResourceLoader.load(script_name, "Script")
	var item_inst = item_script.new()
	
	# Get list of userdata keys
	var keys: Array[Dictionary] = item_inst.get_userdata_keys()
	for key in keys:
		var line_edit: LineEdit = LineEdit.new()
		line_edit.placeholder_text = key["name"]
		userdata_list.add_child(line_edit)
