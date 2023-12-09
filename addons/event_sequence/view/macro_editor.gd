@tool

extends RefCounted
class_name EventSequenceMacroEditor

var parent: Control = null
var popup: Popup = null

const macro_path: String = "res://addons/event_sequence/macro/"

func _init(parent_node: Control, popup_node: Popup):
	parent = parent_node
	popup = popup_node
	ensure_macro_dir()

func write_macro(name: String, self_data: Dictionary, child_data: Array[Dictionary]):
	popup.popup()
	
	var macro_dict: Dictionary = {}
	macro_dict["name"] = name
	macro_dict[EventConst.item_key_self] = self_data
	macro_dict[EventConst.item_key_child] = child_data
	
	var json_string: String = JSON.stringify(macro_dict, "\t")
	disk_write(name, json_string)

#region Disk Utility

func disk_write(file_name: String, file_data: String):
	ensure_macro_dir()
	
	var file_path = macro_path + file_name
	
	# Attempt to open new file and print an error if it fails
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		printerr("FileAccess open error: " + str(FileAccess.get_open_error()))
		return false
	
	file.store_string(file_data)
	file.close()

func ensure_macro_dir():
	if Engine.is_editor_hint():
		DirAccess.make_dir_recursive_absolute(macro_path)

#endregion
