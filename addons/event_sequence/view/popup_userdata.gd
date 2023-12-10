@tool
extends Popup

@onready var userdata_list: VBoxContainer = $Scroll/List

var target_item: TreeItem = null

func _ready():
	popup_hide.connect(_close_menu)

func _exit_tree():
	if popup_hide.is_connected(_close_menu):
		popup_hide.disconnect(_close_menu)

func _close_menu():
	target_item = null

func build_menu(item: TreeItem, column: int):
	# Copy tree item reference
	target_item = item
	
	# Destroy the children of the userdata inspector
	for child in userdata_list.get_children():
		userdata_list.remove_child(child)
		child.queue_free()
	
	# Get copy of script from TreeItem
	var script_name: String = item.get_metadata(EventConst.EditorColumn.NAME)
	var item_script: Script = ResourceLoader.load(script_name, "Script")
	var item_inst = item_script.new()
	
	# Add header
	var header: Label = Label.new()
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.text = "Configure %s" % [item.get_text(EventConst.EditorColumn.NAME)]
	userdata_list.add_child(header)
	
	# Add grid
	var grid: GridContainer = GridContainer.new()
	grid.custom_minimum_size = Vector2(400, 0)
	grid.columns = 2
	userdata_list.add_child(grid)
	
	# Add all edit fields into grid
	var keys: Array[Dictionary] = item_inst.get_userdata_keys()
	for key in keys:
		# Build header for key
		var field_name: Label = Label.new()
		field_name.text = (key["name"] as String).to_pascal_case()
		field_name.tooltip_text = key["desc"]
		field_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if key["require"]:
			field_name.label_settings = LabelSettings.new()
			field_name.label_settings.font_size = 18
			field_name.label_settings.font_color = Color.LIGHT_PINK
		
		grid.add_child(field_name)
		
		# Get data from tree item metadata
		var data
		if item.has_meta(key["name"]):
			data =item.get_meta(key["name"])
		
		# Build edit field based on type
		match(key["type"]):
			TYPE_STRING:
				var line_edit := LineEdit.new()
				line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line_edit.placeholder_text = key["desc"]
				
				if data and typeof(data) == TYPE_STRING:
					line_edit.text = data
				
				line_edit.text_changed.connect(_field_edited.bind(key))
				grid.add_child(line_edit)
			TYPE_INT, TYPE_FLOAT:
				var spin_box := SpinBox.new()
				spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				spin_box.allow_greater = true
				spin_box.allow_lesser = true
				spin_box.step = 0
				if key["type"] == TYPE_INT:
					spin_box.rounded = true
				
				if data and (typeof(data) == TYPE_INT or typeof(data) == TYPE_FLOAT):
					spin_box.value = data
				
				spin_box.value_changed.connect(_field_edited.bind(key))
				grid.add_child(spin_box)
			TYPE_BOOL:
				var button := CheckButton.new()
				button.text = key["desc"]
				
				if data and typeof(data) == TYPE_BOOL:
					button.button_pressed = data
				
				button.toggled.connect(_field_edited.bind(key))
				grid.add_child(button)
	
	# Spawn window
	popup()
	position = DisplayServer.mouse_get_position()
	position.x -= size.x / 2

func _field_edited(data, key: Dictionary):
	if not target_item: return
	target_item.set_meta(key["name"], data)
