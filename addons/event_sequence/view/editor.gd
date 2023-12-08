@tool
extends Control

# Node references
@onready var tree: Tree = %Tree
@onready var popup_tree_add: Popup = $TreeAddPopup

var selected_node: EventNode = null

# Reference to editor plugin
var editor_plugin: EditorPlugin

#region Init and Destructor

func _enter_tree():
	if not editor_plugin:
		return
	
	# Connect to editor interface's selection
	var editor_selection := EditorInterface.get_selection()
	editor_selection.selection_changed.connect(_new_tree)

func _ready():
	# Connect clicking on a tree item to a function
	tree.item_mouse_selected.connect(_tree_item_clicked)
	tree.nothing_selected.connect(_tree_nothing_clicked)
	tree.refresh_tree.connect(_tree_refresh)

func _exit_tree():
	var editor_selection := EditorInterface.get_selection()
	if editor_selection.selection_changed.is_connected(_new_tree):
		editor_selection.selection_changed.connect(_new_tree)
	
	if tree.item_mouse_selected.is_connected(_tree_item_clicked):
		tree.item_mouse_selected.disconnect(_tree_item_clicked)
	if tree.nothing_selected.is_connected(_tree_nothing_clicked):
		tree.nothing_selected.disconnect(_tree_nothing_clicked)
	if tree.nothing_selected.is_connected(_tree_refresh):
		tree.nothing_selected.disconnect(_tree_refresh)

#endregion

#region Tree Interaction

func _tree_item_clicked(position: Vector2, mouse_button_index: int):
	# If right clicked on a tree item, open the add popup	
	if mouse_button_index == 2:
		popup_tree_add.popup()
		popup_tree_add.position = DisplayServer.mouse_get_position()

func _tree_nothing_clicked():
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
				selected_node.event_list = _build_dict_from_tree(tree.get_root())
			"Delete":
				tree.get_selected().free()
				get_viewport().set_input_as_handled()

#endregion

#region Tree Saving and Loading

func _new_tree() -> void:
	tree.clear()
	_build_tree()

func _build_tree(parent: TreeItem = null, dict_list: Array = []) -> void:
	# If this is the first iteration in this function, setup
	if not parent and dict_list.is_empty():
		selected_node = _get_selected_node()
		
		# If the selected node isn't valid, leave
		if not selected_node:
			return
		
		# Finish generic setup with the selected node
		parent = tree.create_item()
		dict_list = selected_node.event_list
	
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
		_build_tree(item, event_dict["children"])

func _build_item_from_dict(parent_item: TreeItem, dict: Dictionary) -> TreeItem:
	# Load in the item's script
	var script: Script = load("res://addons/event_sequence/item/%s" % [dict["script"]])
	var item = script.new()
	
	# Pasrse the current dictionary and let it add itself to the list
	item.parse_dict(dict)
	return item.add_to_tree(parent_item)

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
	
	dict["name"] = item.get_text(EventItem.EditorColumn.NAME)
	dict["script"] = item.get_metadata(EventItem.EditorColumn.NAME)

	return dict

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
