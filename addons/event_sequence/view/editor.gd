@tool
extends Control

# Node references
@onready var tree_screen: MarginContainer = $TreeContainer
@onready var notree_screen: MarginContainer = $NoTree

@onready var tree: Tree = %Tree
@onready var popup_tree_add: Popup = $TreeAddPopup

var selected_node: EventNode = null

# Reference to editor plugin
var editor_plugin: EditorPlugin

# Constants
const default_item_name: String = "Start"
const default_item_path: String = "res://addons/event_sequence/item/general/comment.gd"

#region Init and Destructor

func _enter_tree():
	if not editor_plugin:
		return
	
	# Connect to editor interface's selection
	var editor_selection := EditorInterface.get_selection()
	editor_selection.selection_changed.connect(_new_tree)

func _ready():
	# Connect clicking on a tree item to a function
	tree.cell_selected.connect(_tree_cell_clicked)
	
	tree.item_mouse_selected.connect(_tree_clicked)
	tree.empty_clicked.connect(_tree_clicked)
	
	tree.refresh_tree.connect(_tree_refresh)

func _exit_tree():
	var editor_selection := EditorInterface.get_selection()
	if editor_selection.selection_changed.is_connected(_new_tree):
		editor_selection.selection_changed.connect(_new_tree)
	
	if tree.cell_selected.is_connected(_tree_cell_clicked):
		tree.cell_selected.disconnect(_tree_cell_clicked)
		
	if tree.item_mouse_selected.is_connected(_tree_clicked):
		tree.item_mouse_selected.disconnect(_tree_clicked)
	if tree.empty_clicked.is_connected(_tree_clicked):
		tree.empty_clicked.disconnect(_tree_clicked)
	
	if tree.refresh_tree.is_connected(_tree_refresh):
		tree.refresh_tree.disconnect(_tree_refresh)

#endregion

#region Tree Interaction

func _tree_cell_clicked():
	var select: TreeItem = tree.get_selected()
	var column: int = tree.get_selected_column()
	
	if select:
		var column_1_title: String = select.get_metadata(EventConst.EditorColumn.PROPERTY1)
		tree.set_column_title(EventConst.EditorColumn.PROPERTY1, column_1_title)
		
		var column_2_title: String = select.get_metadata(EventConst.EditorColumn.PROPERTY2)
		tree.set_column_title(EventConst.EditorColumn.PROPERTY2, column_2_title)
	else:
		tree.set_column_title(EventConst.EditorColumn.PROPERTY1, "None")
		tree.set_column_title(EventConst.EditorColumn.PROPERTY2, "None")

func _tree_clicked(position: Vector2, mouse_button_index: int):
	# If right clicked on a tree item, open the add popup	
	if mouse_button_index == 2:
		popup_tree_add.popup()
		popup_tree_add.position = DisplayServer.mouse_get_position()

func _tree_refresh():
	if not selected_node:
		return
	
	selected_node.event_list = _build_dict_from_tree(tree.get_root())
	_new_tree()

func _input(event: InputEvent):
	if not selected_node:
		return
	
	if event is InputEventKey and event.is_pressed():
		match event.as_text():
			"Ctrl+S", "Command+S":
				save()
			"Delete":
				tree.get_selected().free()
				save()
				get_viewport().set_input_as_handled()

#endregion

#region Tree Saving and Loading

func save() -> void:
	if selected_node:
		selected_node.event_list = _build_dict_from_tree(tree.get_root())

func setup_default_tree(parent: TreeItem) -> void:
	var default_item_script: Script = ResourceLoader.load(default_item_path, "Script")
	var default_item = default_item_script.new()
			
	default_item.name = default_item_name
	default_item.script_path = default_item_path
	default_item.add_to_tree(parent, self)

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
		
		# Ensure it has the property "self"
		if not event_dict.has("self"):
			continue
		
		# Create a new tree item and add it using the current parent and dictionary
		var item: TreeItem = _build_item_from_dict(parent, event_dict["self"])
		
		# Check if this dictionary has children
		if not event_dict.has("children"):
			continue
		
		# Create array of the child dictionary data and iterate through it
		_try_build_tree(item, event_dict["children"])
	
	return true

func _build_item_from_dict(parent_item: TreeItem, dict: Dictionary) -> TreeItem:
	# Load in the item's script
	var script: Script = ResourceLoader.load(dict["script"], "Script")
	var item = script.new()
	
	# Pasrse the current dictionary and let it add itself to the list
	item.script_path = dict["script"]
	item.parse_dict(dict)
	return item.add_to_tree(parent_item, self)

func _build_dict_from_tree(root: TreeItem) -> Array[Dictionary]:
	if not root:
		return []
	
	var dict_list: Array[Dictionary]
	var children: Array[TreeItem] = root.get_children()
	
	for child in children:
		var dict: Dictionary = {}
		dict["self"] = _build_dict_from_item(child)
		
		if child.get_child_count() > 0:
			dict["children"] = _build_dict_from_tree(child)
		
		dict_list.push_back(dict)
	
	return dict_list

func _build_dict_from_item(item: TreeItem) -> Dictionary:
	var dict: Dictionary = {}
	
	dict["name"] = item.get_text(EventConst.EditorColumn.NAME)
	dict["script"] = item.get_metadata(EventConst.EditorColumn.NAME)
	
	var property1 = _get_property_from_column(item, EventConst.EditorColumn.PROPERTY1)
	if property1:
		dict["p1"] = property1
	
	var property2 = _get_property_from_column(item, EventConst.EditorColumn.PROPERTY2)
	if property2:
		dict["p2"] = property2

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
