@tool
extends Popup

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
	
	# All all buttons into interface
	for path in EventConst.ScriptScanFolders:
		var dir: DirAccess = DirAccess.open(path)
		for file in dir.get_files():
			_create_button(path + file)

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
	
	var tree_item: TreeItem = item.add_to_tree(tree.get_root(), root)
	
	if tree.get_selected():
		tree_item.move_after(tree.get_selected())
	
	tree.set_selected(tree_item, 0)
	
	root.save()
	visible = false

func _on_debug_refresh_pressed():
	_ready()
