@tool

extends Popup

# Macro Data
var macro_create_data: Dictionary = {}
const required_macro_data_keys: Array[String] = [
	"name",
	"category"
]

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

func check_is_tree_have_selected():
	macro_create_data = {}
	
	var selection: TreeItem = parent.tree.get_selected()
	if not selection:
		create_macro_button.text = "Select an item first!"
		create_macro_button.disabled = true
	else:
		create_macro_button.text = "Create Macro"
		create_macro_button.disabled = false

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
	var is_all_required_set: bool = true
	for key in required_macro_data_keys:
		if not macro_create_data.has(key) or macro_create_data[key].is_empty():
			is_all_required_set = false
			print("New macro has required parameter \"%s\" not set!" % [key])
	
	if not is_all_required_set:
		return
	
	request_macro_contents.emit()

#endregion

#region Disk Utility

func disk_write(file_name: String, file_data: String):
	ensure_macro_dir()
	
	var file_name_lower: StringName = file_name
	var file_path = macro_path + file_name_lower.to_snake_case() + ".esmacro"
	
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
