@tool
extends Popup

#region Properties

# Node References
@onready var userdata_list: VBoxContainer = $Scroll/List

# Properties
var target_item: TreeItem = null

# Textures (Loaded during ready function)
var texture_reset := Texture2D.new()
var texture_reset_off := Texture2D.new()

var texture_require := Texture2D.new()
var texture_field_okay := Texture2D.new()

#endregion

#region Setup and Destroy Functions

func _ready():
	_create_texture("texture_reset", "res://addons/event_sequence/icon/Userdata-Reset.svg")
	_create_texture("texture_reset_off", "res://addons/event_sequence/icon/Userdata-ResetOff.svg")
	_create_texture("texture_require", "res://addons/event_sequence/icon/Required.svg")
	_create_texture("texture_field_okay", "res://addons/event_sequence/icon/Userdata-FieldOkay.svg")
	
	popup_hide.connect(_close_menu)

func _create_texture(variable: String, path: String):
	var texture = load(path)
	var image: Image = texture.get_image()
	set(variable, ImageTexture.create_from_image(image))

func _exit_tree():
	if popup_hide.is_connected(_close_menu):
		popup_hide.disconnect(_close_menu)

func _close_menu():
	target_item = null

#endregion

#region Menu Builder

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
	grid.custom_minimum_size = Vector2(500, 0)
	grid.columns = 4
	userdata_list.add_child(grid)
	
	# Add all edit fields into grid
	var keys: Array[Dictionary] = item_inst.get_userdata_keys()
	for key in keys:
		# Create all univsersal control nodes here and add to dictionary
		var field_name: Label = Label.new()
		var reset_button := TextureButton.new()
		var require_icon := TextureRect.new()
		
		key["field_node"] = field_name
		key["reset_node"] = reset_button
		key["require_node"] = require_icon
		
		# Build field name
		if key.has(EventConst.userdata_key_display):
			field_name.text = key[EventConst.userdata_key_display]
		else:
			field_name.text = (key[EventConst.userdata_key_name] as String).to_pascal_case()
		
		if key.has(EventConst.userdata_key_desc):
			field_name.tooltip_text = key[EventConst.userdata_key_desc]
		
		field_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(field_name)
		
		# Add reset button for field
		reset_button.disabled = false
		reset_button.texture_normal = texture_reset
		reset_button.texture_disabled = texture_reset_off
		reset_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		reset_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		reset_button.pressed.connect(_field_reset.bind(key))
		
		grid.add_child(reset_button)
		
		# Get data from tree item metadata
		var data
		if item.has_meta(key[EventConst.userdata_key_name]):
			data = item.get_meta(key[EventConst.userdata_key_name])
		else: if key.has(EventConst.userdata_key_default):
			data = key[EventConst.userdata_key_default]
		
		# Build edit field based on type
		if not key[EventConst.userdata_key_type] == TYPE_ARRAY:
			_add_field(grid, key, key[EventConst.userdata_key_type], data)
		else:
			# Create button
			var button := Button.new()
			button.text = "Add Array Item"
			button.pressed.connect(_add_item_to_array.bind(key, column))
			grid.add_child(button)
			
			# If this array doesn't have a meta key, add it
			if not item.has_meta(key[EventConst.userdata_key_name]):
				item.set_meta(key[EventConst.userdata_key_name], [])
			
			for array_index in range(item.get_meta(key[EventConst.userdata_key_name]).size()):
				_add_field(grid, key, key[EventConst.userdata_key_type_array], data, array_index)
		
		# Add required status indicator for field
		if not require_icon.texture:
			require_icon.texture = texture_field_okay
		require_icon.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		require_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		grid.add_child(require_icon)
		
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
			if key.has(EventConst.userdata_key_type_hint) and key[EventConst.userdata_key_type_hint] == "text_edit":
				edit = CodeEdit.new()
				edit.custom_minimum_size = Vector2(325, 250)
				edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
				edit.gutters_draw_line_numbers = true
				edit.text_changed.connect(_field_edited.bind(edit, key, array_index))
			else:
				edit = LineEdit.new()
				edit.text_changed.connect(_field_edited.bind(key, array_index))
			
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			if key.has(EventConst.userdata_key_desc):
				edit.placeholder_text = key[EventConst.userdata_key_desc]
			
			_setup_default_value(data, key, edit, "text", array_index)
			
			container.add_child(edit)
		TYPE_INT, TYPE_FLOAT:
			var spin_box := SpinBox.new()
			spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin_box.allow_greater = true
			spin_box.allow_lesser = true
			spin_box.update_on_text_changed = true
			spin_box.step = 0
			if key[EventConst.userdata_key_type] == TYPE_INT:
				spin_box.rounded = true
			
			_setup_default_value(data, key, spin_box, "value", array_index)
			
			spin_box.value_changed.connect(_field_edited.bind(key, array_index))
			container.add_child(spin_box)
		TYPE_BOOL:
			var button := CheckButton.new()
			if key.has(EventConst.userdata_key_desc):
				button.text = key[EventConst.userdata_key_desc]
			
			_setup_default_value(data, key, button, "button_pressed", array_index)
			
			button.toggled.connect(_field_edited.bind(key, array_index))
			container.add_child(button)
		TYPE_COLOR:
			var button := ColorPickerButton.new()
			_setup_default_value(data, key, button, "color", array_index)
			
			button.color_changed.connect(_field_edited.bind(key, array_index))
			container.add_child(button)

func _setup_default_value(data, key: Dictionary, node: Control, property: String, array_index: int):
	var set_data: bool = false
	
	if data and typeof(data) == key[EventConst.userdata_key_type]:
		node.set(property, data)
		set_data = true
			
	if data and typeof(data) == key[EventConst.userdata_key_type] and typeof(data[array_index]) != key[EventConst.userdata_key_type]:
		var array: Array = node.get(property)
		array[array_index] = data
		set_data = true
			
	if set_data:
		_set_field_state_modified(key)
	else:
		_set_field_state_default(key)

func _add_item_to_array(key: Dictionary, column: int):
	var meta = target_item.get_meta(key[EventConst.userdata_key_name])
	meta.push_back(null)
	target_item.set_meta(key[EventConst.userdata_key_name], meta)
	
	build_menu(target_item, column, false)

func _remove_item_from_array(key: Dictionary, array_index: int):
	var meta = target_item.get_meta(key[EventConst.userdata_key_name])
	meta.remove_at(array_index)
	target_item.set_meta(key[EventConst.userdata_key_name], meta)
	
	build_menu(target_item, EventConst.EditorColumn.USERDATA, false)

#endregion

#region Menu Editing

func _field_edited(data, key: Dictionary, array_index: int):
	if not target_item: return
	
	# If this is an array, handle seperately
	if array_index > -1:
		_field_edited_array(data, key, array_index)
	
	# Copy field data into TreeItem metadata
	if not data is TextEdit:
		target_item.set_meta(key[EventConst.userdata_key_name], data)
	else:
		target_item.set_meta(key[EventConst.userdata_key_name], data.text)
	
	# Update reset and required control node indicators
	if not key.has(EventConst.userdata_key_default):
		_set_field_state_modified(key)
		return
	
	# Update reset and required control node indicators
	if typeof(data) == typeof(key[EventConst.userdata_key_default]) and data == key[EventConst.userdata_key_default]:
		_set_field_state_default(key)
	else:
		_set_field_state_modified(key)

func _field_edited_array(data, key: Dictionary, array_index: int):
	var array: Array = target_item.get_meta(key[EventConst.userdata_key_name])
	if not array:
		return
		
	if not data is TextEdit:
		array[array_index] = data
	else:
		array[array_index] = data.text
	
	# Update reset and required control node indicators
	if array.is_empty():
		_set_field_state_default(key)
	else:
		_set_field_state_modified(key)

# Reset the field to the EventConst.userdata_key_default key
func _field_reset(key: Dictionary):
	if key[EventConst.userdata_key_type] != TYPE_ARRAY:
		if key.has(EventConst.userdata_key_default):
			target_item.set_meta(key[EventConst.userdata_key_name], key[EventConst.userdata_key_default])
		else:
			target_item.remove_meta(key[EventConst.userdata_key_name])
		
		_set_field_state_default(key)
	else:
		target_item.set_meta(key[EventConst.userdata_key_name], [])
		_set_field_state_default(key)
	
	build_menu(target_item, EventConst.EditorColumn.USERDATA, false)

# Enable the reset button and show the okay checkmark
func _set_field_state_modified(key: Dictionary):
	key["reset_node"].disabled = false
	if key.has(EventConst.userdata_key_require) and key[EventConst.userdata_key_require]:
		key["require_node"].texture = texture_field_okay

# Disable the reset button and show required star if this is a required field
func _set_field_state_default(key: Dictionary):
	key["reset_node"].disabled = true
	if key.has(EventConst.userdata_key_require) and key[EventConst.userdata_key_require]:
		key["require_node"].texture = texture_require
	else:
		key["require_node"].texture = texture_field_okay

#endregion
