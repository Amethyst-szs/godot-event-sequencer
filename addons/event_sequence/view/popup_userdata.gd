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

func build_menu(item: TreeItem, column: int, open_menu: bool = true):
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
		
		if key.has("display_name"):
			field_name.text = key["display_name"]
		else:
			field_name.text = (key["name"] as String).to_pascal_case()
		
		if key.has("desc"):
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
			data = item.get_meta(key["name"])
		else: if key.has("default"):
			data = key["default"]
		
		# Build edit field based on type
		if not key["type"] == TYPE_ARRAY:
			_add_field(grid, key, key["type"], data)
		else:
			# Create button
			var button := Button.new()
			button.text = "Add Array Item"
			button.pressed.connect(_add_item_to_array.bind(key, column))
			grid.add_child(button)
			
			# If this array doesn't have a meta key, add it
			if not item.has_meta(key["name"]):
				item.set_meta(key["name"], [])
			
			for array_index in range(item.get_meta(key["name"]).size()):
				_add_field(grid, key, key["type_array"], data, array_index)
	
	# Spawn window
	if open_menu:
		popup()
		position = DisplayServer.mouse_get_position()
		position.x -= size.x / 2

func _add_field(container: Control, key: Dictionary, type: Variant.Type, data, array_index: int = -1):
	# If adding an array, add a remove button to the layout firest
	if array_index > -1:
		var remove := Button.new()
		remove.text = "Remove Item"
		remove.flat = true
		remove.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		remove.pressed.connect(_remove_item_from_array.bind(key, array_index))
		container.add_child(remove)
	
	match(type):
		TYPE_STRING:
			var edit
			if key.has("type_hint") and key["type_hint"] == "text_edit":
				edit = CodeEdit.new()
				edit.custom_minimum_size = Vector2(325, 250)
				edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
				edit.gutters_draw_line_numbers = true
				edit.text_changed.connect(_field_edited.bind(edit, key, array_index))
			else:
				edit = LineEdit.new()
				edit.text_changed.connect(_field_edited.bind(key, array_index))
			
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			if key.has("desc"):
				edit.placeholder_text = key["desc"]
			
			if data and typeof(data) == TYPE_STRING:
				edit.text = data
			
			if data and typeof(data) == TYPE_ARRAY and typeof(data[array_index]) != TYPE_NIL:
				edit.text = data[array_index]
			
			container.add_child(edit)
		TYPE_INT, TYPE_FLOAT:
			var spin_box := SpinBox.new()
			spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin_box.allow_greater = true
			spin_box.allow_lesser = true
			spin_box.update_on_text_changed = true
			spin_box.step = 0
			if key["type"] == TYPE_INT:
				spin_box.rounded = true
			
			if data and (typeof(data) == TYPE_INT or typeof(data) == TYPE_FLOAT):
				spin_box.value = data
			
			if data and typeof(data) == TYPE_ARRAY and typeof(data[array_index]) != TYPE_NIL:
				spin_box.value = data[array_index]
			
			spin_box.value_changed.connect(_field_edited.bind(key, array_index))
			container.add_child(spin_box)
		TYPE_BOOL:
			var button := CheckButton.new()
			if key.has("desc"):
				button.text = key["desc"]
			
			if data and typeof(data) == TYPE_BOOL:
				button.button_pressed = data
			
			if data and typeof(data) == TYPE_ARRAY and typeof(data[array_index]) != TYPE_NIL:
				button.button_pressed = data[array_index]
			
			button.toggled.connect(_field_edited.bind(key, array_index))
			container.add_child(button)
		TYPE_COLOR:
			var button := ColorPickerButton.new()
			
			if data and typeof(data) == TYPE_COLOR:
				button.color = data
			
			if data and typeof(data) == TYPE_ARRAY and typeof(data[array_index]) != TYPE_NIL:
				button.color = data[array_index]
			
			button.color_changed.connect(_field_edited.bind(key, array_index))
			container.add_child(button)

func _add_item_to_array(key: Dictionary, column: int):
	var meta = target_item.get_meta(key["name"])
	meta.push_back(null)
	target_item.set_meta(key["name"], meta)
	
	build_menu(target_item, column, false)

func _remove_item_from_array(key: Dictionary, array_index: int):
	var meta = target_item.get_meta(key["name"])
	meta.remove_at(array_index)
	target_item.set_meta(key["name"], meta)
	
	build_menu(target_item, EventConst.EditorColumn.USERDATA, false)

func _field_edited(data, key: Dictionary, array_index: int):
	if not target_item: return
	
	# If this is an array, handle seperately
	if array_index > -1:
		var array: Array = target_item.get_meta(key["name"])
		if not array:
			return
		
		if not data is TextEdit:
			array[array_index] = data
		else:
			array[array_index] = data.text

		return
	
	if not data is TextEdit:
		target_item.set_meta(key["name"], data)
	else:
		target_item.set_meta(key["name"], data.text)
