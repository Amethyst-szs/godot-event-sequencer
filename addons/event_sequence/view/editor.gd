@tool
extends Control

# State variables
var save_timer: float = -1.0

# Node references
@onready var tree_screen: MarginContainer = $TreeContainer
@onready var notree_screen: MarginContainer = $NoTree

@onready var tree: Tree = %Tree
@onready var copy_paste_tree: Tree = %CopyPasteDataTree
@onready var tree_header_menu: MenuBar = %HeaderMenu

@onready var popup_tree_add: Popup = $TreeAddPopup
@onready var popup_userdata_edit: Popup = $UserdataEditPopup
@onready var popup_macros: Popup = $MacroPopup
@onready var popup_macro_delete: FileDialog = $MacroDeleteWindow
@onready var userdata_edit_list := $UserdataEditPopup/Scroll/List
@onready var popup_plugin_installer: Popup = $PluginInstallerPopup

var selected_node: EventNode = null

# Reference to editor plugin
var editor_plugin: EditorPlugin
var undo_redo: EditorUndoRedoManager = null

# Constants
const default_item_name: String = "Start"
const default_item_path: String = "res://addons/event_sequence/item/general/comment.gd"

#region Initalization

func _enter_tree():
	if not editor_plugin:
		return
	
	undo_redo = editor_plugin.get_undo_redo()
	
	# Connect to editor interface's selection
	var editor_selection := EditorInterface.get_selection()
	editor_selection.selection_changed.connect(_new_tree)

# When the node is fully ready, connect to every other important signal
func _ready():
	# Connect to various tree signals for editor functionality
	tree.cell_selected.connect(_tree_cell_clicked)
	tree.button_clicked.connect(_tree_button_pressed)
	tree.item_mouse_selected.connect(_tree_item_clicked)
	tree.empty_clicked.connect(_tree_empty_clicked)
	tree.refresh_tree.connect(_tree_refresh)
	
	# Connect to macro signals
	popup_macros.request_macro_contents.connect(_macro_create)

#endregion

#region Signal Responses and Input

# Listen for special inputs if node is selected and editor is visible
func _input(event: InputEvent):
	if not selected_node or not visible:
		return
	
	# Check for actions built in to Godot
	if Input.is_action_just_pressed("ui_cut"):
		copy_paste_tree.cut()
		get_viewport().set_input_as_handled()
	
	if Input.is_action_just_pressed("ui_copy"):
		copy_paste_tree.copy()
		get_viewport().set_input_as_handled()
	
	if Input.is_action_just_pressed("ui_paste"):
		copy_paste_tree.paste()
		get_viewport().set_input_as_handled()
	
	if Input.is_action_just_pressed("ui_graph_delete"):
		var item: TreeItem = tree.get_next_selected(null)
		while item != null:
			item.free()
			item = tree.get_next_selected(item)
		
		save()
		get_viewport().set_input_as_handled()
	
	# Check for special events that aren't built into Godot
	if event is InputEventKey and event.is_pressed():
		match event.as_text():
			"Ctrl+S", "Command+S", "F5", "F6":
				save()
			"Ctrl+M", "Command+M":
				_set_macro_flag(true)

func _tree_cell_clicked():
	var select: TreeItem = tree.get_next_selected(null)
	var column: int = tree.get_selected_column()
	
	if select:
		# Update columns from metadata
		var column_1_title: String = select.get_metadata(EventConst.EditorColumn.VARIABLE)
		tree.set_column_title(EventConst.EditorColumn.VARIABLE, column_1_title)
		
		var column_2_title: String = select.get_metadata(EventConst.EditorColumn.USERDATA)
		tree.set_column_title(EventConst.EditorColumn.USERDATA, column_2_title)
	else:
		# Clear column names
		tree.set_column_title(EventConst.EditorColumn.VARIABLE, "None")
		tree.set_column_title(EventConst.EditorColumn.USERDATA, "None")

# When clicking on a tree button, open the userdata editor panel
func _tree_button_pressed(item: TreeItem, column: int, id: int, mouse_button_index: int):
	# Build inspector panel
	tree.set_selected(item, column)
	popup_userdata_edit.build_menu(item, column)

# When clicking a tree item with the right mouse button, open the add popup
func _tree_item_clicked(position: Vector2, mouse_button_index: int):
	# If right clicked on a tree item, open the add popup
	if mouse_button_index == 2:
		_open_add_dialog()

# When right clicking on nothing in the tree, deselect and open add popup on nothing
func _tree_empty_clicked(position: Vector2, mouse_button_index: int):
	# If right clicked on nothing, deselect and open the add popup
	if mouse_button_index == 2:
		tree.deselect_all()
		_open_add_dialog()

func _open_add_dialog():
	popup_tree_add.popup()
	
	# Get a bunch of data about user's screens and mouse
	var mouse_rect := Rect2(DisplayServer.mouse_get_position(), Vector2.ONE)
	var screen_index = DisplayServer.get_screen_from_rect(mouse_rect)
	var screen_pos := DisplayServer.screen_get_position(screen_index)
	var screen_size := DisplayServer.screen_get_size(screen_index)
	
	# Calculate window position
	var pos: Vector2i = mouse_rect.position
	if pos.y + popup_tree_add.size.y > screen_pos.y + screen_size.y:
		pos.y -= popup_tree_add.size.y - ((screen_pos.y + screen_size.y) - pos.y) + 25
	
	# Set window position
	popup_tree_add.position = pos

# Save the tree to node and rebuild tree
func _tree_refresh():
	if not selected_node:
		return
	
	save()
	_new_tree()

#endregion

#region Tree Saving and Loading

# Automatically save a short bit after user input
func _process(delta: float) -> void:
	if visible and Input.is_anything_pressed():
		save_timer = 0.5
	
	if save_timer != -1.0:
		save_timer -= delta
		if save_timer <= 0:
			save()
			save_timer = -1

## Write tree to selected node
func save() -> void:
	if selected_node:
		# Create new event list from tree
		var new_event_list := _build_dict_from_tree(tree.get_root())
		
		# Compare if the new and old dict are the same
		if selected_node.event_list.hash() == new_event_list.hash():
			return
		
		# Create new undo/redo action
		undo_redo.create_action("Event Sequence Editor Saved")
		undo_redo.add_do_property(selected_node, "event_list", new_event_list)
		undo_redo.add_do_method(self, "_new_tree")
		undo_redo.add_undo_property(selected_node, "event_list", selected_node.event_list)
		undo_redo.add_undo_method(self, "_new_tree")
		undo_redo.commit_action(false)
		
		# Set event list to new event list
		selected_node.event_list = new_event_list

## Creates a default tree with one comment node
func setup_default_tree(parent: TreeItem) -> void:
	var default_item_script: Script = ResourceLoader.load(default_item_path, "Script")
	var default_item = default_item_script.new()
	
	default_item.name = default_item_name
	default_item.script_path = default_item_path
	default_item.add_to_tree(parent, self, false)

# Destroy the current tree and try to build a new tree, updating UI visiblity in process
func _new_tree() -> void:
	tree.clear()
	
	var can_show_tree: bool = _try_build_tree()
	tree_screen.visible = can_show_tree
	notree_screen.visible = not can_show_tree

func _try_build_tree(parent: TreeItem = null, dict_list: Array = []) -> bool:
	# If this is the first iteration in this function, setup
	if not parent and dict_list.is_empty():
		selected_node = _get_selected_node()
		
		# If the selected node isn't valid, leave
		if not selected_node:
			return false
		
		# Finish generic setup with the selected node
		parent = tree.create_item()
		dict_list = selected_node.event_list
		
		# Check if the node has a complete empty event list and make one node if so
		if dict_list.is_empty():
			setup_default_tree(parent)
			return true
	
	# Iterate through the event dict
	for event_dict in dict_list:
		# Ensure the current array item is a dictionary
		if not typeof(event_dict) == TYPE_DICTIONARY:
			continue
		
		# Ensure it has the property EventConst.item_key_self
		if not event_dict.has(EventConst.item_key_self):
			continue
		
		# Setup macro and collapsed flags
		var is_macro_root: bool = event_dict.has(EventConst.item_key_macro)
		var is_collapsed: bool = event_dict.has(EventConst.item_key_flag_collapsed)
		if is_collapsed:
			is_collapsed = event_dict[EventConst.item_key_flag_collapsed]
		
		# Create a new tree item and add it using the current parent and dictionary
		var item := _build_item_from_dict(parent, event_dict[EventConst.item_key_self], is_macro_root, is_collapsed)
		
		# Add flag metadata
		item.set_meta(EventConst.item_key_flag_macro, is_macro_root)
		item.set_meta(EventConst.item_key_flag_collapsed, is_collapsed)
		
		# If this dict is a label marker, add label metadata tag
		item.set_meta(EventConst.item_key_flag_label, event_dict.has(EventConst.item_key_flag_label))
		
		# Check if this dictionary has children
		if not event_dict.has(EventConst.item_key_child):
			continue
		
		# Create array of the child dictionary data and iterate through it
		_try_build_tree(item, event_dict[EventConst.item_key_child])
	
	return true

func _build_item_from_dict(parent_item: TreeItem, dict: Dictionary, is_macro: bool, is_collapsed: bool = false) -> TreeItem:
	# Load in the item's script
	var script: Script = ResourceLoader.load(dict[EventConst.item_key_script], "Script")
	var script_instance = script.new()
	
	# Parse the current dictionary and let it add itself to the list
	script_instance.script_path = dict[EventConst.item_key_script]
	script_instance.parse_dict(dict)
	return script_instance.add_to_tree(parent_item, self, is_macro, is_collapsed)

func _build_dict_from_tree(root: TreeItem) -> Array[Dictionary]:
	if not root:
		return []
	
	var dict_list: Array[Dictionary]
	var children: Array[TreeItem] = root.get_children()
	
	for child in children:
		var dict: Dictionary = {}
		dict[EventConst.item_key_self] = _build_dict_from_item(child)
		
		if child.has_meta(EventConst.item_key_flag_macro) and child.get_meta(EventConst.item_key_flag_macro):
			dict[EventConst.item_key_macro] = true
		
		if child.has_meta(EventConst.item_key_flag_label) and child.get_meta(EventConst.item_key_flag_label):
			dict[EventConst.item_key_flag_label] = true
		
		dict[EventConst.item_key_flag_collapsed] = child.collapsed
		
		if child.get_child_count() > 0:
			dict[EventConst.item_key_child] = _build_dict_from_tree(child)
		
		dict_list.push_back(dict)
	
	return dict_list

func _build_dict_from_item(item: TreeItem) -> Dictionary:
	var dict: Dictionary = {}
	
	dict[EventConst.item_key_name] = item.get_text(EventConst.EditorColumn.NAME)
	dict[EventConst.item_key_script] = item.get_metadata(EventConst.EditorColumn.NAME)
	
	# New instance of script
	var script: Script = ResourceLoader.load(dict[EventConst.item_key_script], "Script")
	var script_instance = script.new()
	
	var variable = _get_property_from_column(item, EventConst.EditorColumn.VARIABLE)
	if variable:
		dict[EventConst.item_key_variable] = variable
	
	var userdata_cellmode: int = item.get_cell_mode(EventConst.EditorColumn.USERDATA)
	if userdata_cellmode == TreeItem.CELL_MODE_CUSTOM:
		var userdata: Dictionary = script_instance.build_userdata_from_tree(item)
		if not userdata.is_empty():
			dict[EventConst.item_key_userdata] = userdata
	else:
		var userdata = _get_property_from_column(item, EventConst.EditorColumn.USERDATA)
		if userdata:
			dict[EventConst.item_key_userdata] = {}
			dict[EventConst.item_key_userdata][EventConst.item_key_userdata_generic] = userdata

	return dict

func _get_property_from_column(item: TreeItem, column: int) -> Variant:
	match item.get_cell_mode(column):
		TreeItem.CELL_MODE_STRING:
			var text: String = item.get_text(column)
			if not text.is_empty():
				return text
		TreeItem.CELL_MODE_RANGE:
			return item.get_range(column)
	
	return null

func _get_selected_node() -> EventNode:
	# Get list of selected nodes in edtior
	var editor_selection := EditorInterface.get_selection()
	var selected_nodes := editor_selection.get_selected_nodes()
	var node: EventNode = null
	
	# Find the first EventNode in selection
	for item in selected_nodes:
		if item is EventNode:
			return item
	
	# If no event node is selected, return null
	return null

#endregion

#region Macro Integration

func _macro_create():
	var selection: TreeItem = tree.get_selected()
	if not selection:
		var arugment: Array[Dictionary] = [{}]
		popup_macros.write_macro({}, arugment)
		return
	
	var self_data: Dictionary = _build_dict_from_item(selection)
	var child_data: Array[Dictionary] = _build_dict_from_tree(selection)
	await popup_macros.write_macro(self_data, child_data)
	
	popup_tree_add._ready()

func _on_macro_delete_window_files_selected(paths: PackedStringArray):
	for path in paths:
		var error := DirAccess.remove_absolute(path)
		if error != OK:
			printerr("Deleting macro failed: %s (%s)" % [error, path])
	
	popup_tree_add._ready()

func _set_macro_flag(is_toggle: bool, value: bool = false):
	var item: TreeItem = tree.get_selected()
	if item:
		if not is_toggle:
			item.set_meta(EventConst.item_key_flag_macro, value)
		else:
			var old: bool = item.get_meta(EventConst.item_key_flag_macro)
			item.set_meta(EventConst.item_key_flag_macro, not old)
		
		_tree_refresh()

#endregion

#region Top-bar menu buttons pressed

func _on_edit_index_pressed(index):
	match(index):
		0:
			copy_paste_tree.copy(true)
		1:
			copy_paste_tree.copy(false)
		2:
			copy_paste_tree.paste()

func _on_macro_menu_index_pressed(index):
	match(index):
		0:
			popup_macros.check_is_tree_have_selected()
			popup_macros.popup()
		1:
			popup_macro_delete.title = "Select macros to delete"
			popup_macro_delete.ok_button_text = "Delete Macro(s)"
			popup_macro_delete.popup()
		3:
			_set_macro_flag(false, true)
		4:
			_set_macro_flag(false, false)

func _on_plugins_index_pressed(index):
	match(index):
		0:
			popup_plugin_installer.popup()

func _on_debug_index_pressed(index):
	match(index):
		0:
			popup_tree_add._ready()
		1:
			if not tree.get_selected():
				return
			
			print("\n- Selection Metadata: -")
			for meta in tree.get_selected().get_meta_list():
				print("%s: %s" % [meta, tree.get_selected().get_meta(meta)])

#endregion
