@tool

extends Popup

var macro_create_data: Dictionary = {}

# Node references
var parent: Control = null
@onready var name_line_edit: LineEdit = $Panel/VBox/Settings/MacroNameEdit
@onready var category_line_edit: LineEdit = $Panel/VBox/Settings/MacroCategoryEdit
@onready var create_macro_button: Button = $Panel/VBox/CreateButton

# Signals
signal request_macro_contents

# Consts
const macro_path: String = "res://addons/event_sequence/macro/"

func _ready():
	macro_create_data = {}
	
	parent = get_parent()
	name_line_edit.text_changed.connect(_create_field_edited.bind("name"))
	category_line_edit.text_changed.connect(_create_field_edited.bind("category"))
	
	create_macro_button.pressed.connect(_pressed_macro_create_button)

func popup(rect: Rect2i = Rect2i(0, 0, 0, 0)) -> void:
	super(rect)
	
	print("popup hi wave")

func write_macro(self_data: Dictionary, child_data: Array[Dictionary]):
	# Ensure a tree item is selected
	if not parent.tree.get_selected():
		print("Cannot write macro with no tree item selected!")
		visible = false
		return
	
	# Create macro dictionary to write to disk
	var macro_dict: Dictionary = {}
	macro_dict[EventConst.item_key_self] = self_data
	macro_dict[EventConst.item_key_child] = child_data
	macro_dict["macro"] = macro_create_data
	
	# Write JSON to disk
	var json_string: String = JSON.stringify(macro_dict, "\t")
	disk_write(macro_create_data["name"], json_string)
	
	# Reset self
	macro_create_data = {}
	name_line_edit.clear()
	category_line_edit.clear()
	
	visible = false

#region Signal Functions

func _create_field_edited(data: String, key: String):
	macro_create_data[key] = data

func _pressed_macro_create_button():
	if not macro_create_data.has("name") or macro_create_data["name"].is_empty():
		print("Macro must have a name!")
		return
	
	if not macro_create_data.has("category") or macro_create_data["category"].is_empty():
		print("Macro must have a category!")
		return
	
	request_macro_contents.emit()

#endregion

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
