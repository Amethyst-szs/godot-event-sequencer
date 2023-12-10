@tool
extends Popup

# Node references
@onready var root: Control = get_parent()
@onready var tree: Tree = %Tree
@onready var tabs: TabContainer = %AddPopupTabs

func _ready():
	# Destroy any pre-existing tabs
	for item in tabs.get_children():
		item.free()
	
	# Create all window tabs
	for tab in EventConst.EditorDialogTab.keys():
		var container: VBoxContainer = VBoxContainer.new()
		container.name = tab
		tabs.add_child(container)
	
	# Add all built-in buttons into interface
	for path in EventConst.ScriptScanFolders:
		if not DirAccess.dir_exists_absolute(path):
			continue
		
		var dir: DirAccess = DirAccess.open(path)
		for file in dir.get_files():
			_create_button(path + file)
	
	# Fetch macro directory and add new menu tab
	DirAccess.make_dir_recursive_absolute(EventConst.ScriptMacroFolder)
	var macro_dir: DirAccess = DirAccess.open(EventConst.ScriptMacroFolder)
	
	var macro_container: VBoxContainer = VBoxContainer.new()
	macro_container.name = "Macros"
	tabs.add_child(macro_container)
	
	# Create new menu tab container for each macros
	var macro_tabs: TabContainer = TabContainer.new()
	macro_tabs.clip_tabs = false
	macro_container.add_child(macro_tabs)
	
	# Add buttons for each macro item
	for file in macro_dir.get_files():
		var path: String = EventConst.ScriptMacroFolder + file
		var macro: Dictionary = _read_macro_file(path)
		if macro.is_empty():
			continue
		
		var macro_meta: Dictionary = macro["macro"]
		
		if not macro_tabs.has_node(macro_meta["category"]):
			_create_macro_category(macro_tabs, macro_meta["category"])
		
		var container: VBoxContainer = macro_tabs.get_node(macro_meta["category"])
		_create_macro_button(path, container, macro_meta)

#region Built-in button methods

func _create_button(script_path: String) -> void:
	if not script_path.ends_with(".gd"):
		return
	
	# Load in the item's script
	var script: Script = ResourceLoader.load(script_path, "Script")
	var item = script.new()
	
	if not item.is_allow_in_editor():
		return
	
	# Build button
	var button: Button = Button.new()
	
	button.text = item.get_name()
	button.tooltip_text = item.get_description()
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var texture = load(item.get_icon_path())
	var image: Image = texture.get_image()
	button.icon = ImageTexture.create_from_image(image)
	
	button.add_theme_constant_override("icon_max_width", 42)
	button.add_theme_constant_override("font_size", 22)
	
	# Add button to parent tab
	var parent: VBoxContainer = tabs.get_child(item.get_editor_tab())
	parent.add_child(button)
	
	# Connect button to signal function
	button.pressed.connect(_button_pressed.bind(script_path))

func _button_pressed(script_path: String):
	var script: Script = ResourceLoader.load(script_path, "Script")
	var item: EventItemBase = script.new()
	
	item.script_path = script_path
	
	var tree_item: TreeItem = item.add_to_tree(tree.get_root(), root, false)
	
	if tree.get_selected():
		tree_item.move_after(tree.get_selected())
	
	tree.set_selected(tree_item, 0)
	
	root.save()
	visible = false

func _on_debug_refresh_pressed():
	_ready()

#endregion

#region Macro methods

func _create_macro_button(path: String, container: VBoxContainer, meta: Dictionary):
	# Build button
	var button: Button = Button.new()
	
	button.text = meta["name"]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	if meta.has("desc"):
		button.tooltip_text = meta["desc"]
	
	button.add_theme_constant_override("icon_max_width", 42)
	button.add_theme_constant_override("font_size", 22)
	
	# Add button to parent tab
	container.add_child(button)
	button.pressed.connect(_pressed_macro_button.bind(path, meta["name"]))

func _create_macro_category(container: TabContainer, category: String):
	var box := VBoxContainer.new()
	box.name = category
	container.add_child(box)

func _pressed_macro_button(path: String, macro_name: String):
	# Ensure dict in inspector is up to date with tree
	root.save()
	
	# Get the selected event node
	var event_node: EventNode = root.selected_node
	if not event_node:
		printerr("Could not find selected event node to add macro to!")
		return
	
	# Get data from macro file
	var data: Dictionary = _read_macro_file(path)
	if not data.has("self"):
		printerr("Bad macro data! (Missing \"self\" key)")
		return
	
	# Override the first item name with the macro name
	data["self"]["name"] = macro_name
	
	# Add data into node dict and reload tree
	event_node.event_list.push_back(data)
	root._new_tree()
	
	# Hide menu and scroll to new macro
	root.tree.scroll_to_item(root.tree.get_root().get_child(-1), true)
	visible = false

func _read_macro_file(path: String) -> Dictionary:
	# Get the content of the path
	var content = _read_raw_file(path)
	if content == null or content.is_empty():
		return {}
	
	# Convert this content into a JSON if possible
	var data: Dictionary = JSON.parse_string(content)
	if data == null:
		printerr("Cannot parse %s as json string, data is null! (%s)" % [path, content])
		return {}
	
	# Print message saying that the dictionary is empty if needed
	if data.is_empty():
		printerr("File at %s was parsed correctly, but contains no data" % [path])
	
	# Return the JSON data to then be converted into a object later
	return data

func _read_raw_file(path: String) -> String:
	# Verify the file exists and return early if not
	if not FileAccess.file_exists(path):
		printerr("Cannot open non-existent file at %s" % [path])
		return ""
	
	# Open the file and return if something goes wrong (another program controlling it for example)
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("FileAccess open error: " + str(FileAccess.get_open_error()))
		return ""
	
	# Get the content of the open file
	var content = file.get_as_text()
	file.close()
	
	# Print message saying that the dictionary is empty if needed
	if content.is_empty():
		printerr("File at %s was parsed correctly, but contains no data" % [path])
	
	# Return the JSON data to then be converted into a object later
	return content

#endregion
