@tool
extends RefCounted
class_name EventItemBase

#region Overridable Config

func get_name() -> String:
	return "Event Item Base"

func get_description() -> String:
	return "Base class for all event items"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.General

func is_allow_in_editor() -> bool:
	return false

func get_first_column_config() -> Dictionary:
	return {
		"name": "None",
		"editable": false,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "None",
		"editable": false,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_userdata_keys() -> Array[Dictionary]:
	return []

func is_first_column_editable() -> bool:
	return false

func is_second_column_editable() -> bool:
	return false

func is_comment() -> bool:
	return false

func get_color() -> Color:
	return Color.RED

func get_icon_path() -> String:
	return "res://icon.svg"

#endregion

#region Data

var name: String
var script_path: String

var event_variable: String = ""
var userdata: Dictionary = {}

#endregion

#region App Functionality

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	print(name)
	return EventConst.ItemResponseType.OK

func parse_dict(dict: Dictionary) -> void:
	name = dict[EventConst.item_key_name]
	if dict.has(EventConst.item_key_variable):
		event_variable = dict[EventConst.item_key_variable]
	
	if dict.has(EventConst.item_key_userdata):
		if typeof(dict[EventConst.item_key_userdata]) == TYPE_DICTIONARY:
			userdata = dict[EventConst.item_key_userdata]

#endregion

#region Editor Functionality

func _ready():
	if name.is_empty():
		name = get_name()

func add_to_tree(parent: TreeItem, editor: Control, is_macro: bool) -> TreeItem:
	var item: TreeItem = parent.create_child()
	
	# Name column
	if name.is_empty():
		name = get_name()
	
	# Name column
	item.set_text(EventConst.EditorColumn.NAME, name)
	item.set_metadata(EventConst.EditorColumn.NAME, script_path)
	
	# Setup tooltip for name column
	var tooltip: String = "%s\n%s" % [get_name(), get_description()]
	if is_macro: tooltip += "\n(Macro)"
	
	item.set_tooltip_text(EventConst.EditorColumn.NAME, tooltip)
	
	var texture = load(get_icon_path())
	var image: Image = texture.get_image()
	item.set_icon(EventConst.EditorColumn.NAME, ImageTexture.create_from_image(image))
	item.set_icon_modulate(EventConst.EditorColumn.NAME, get_color())
	
	var bg_color: Color = get_color()
	if is_macro: bg_color = bg_color.darkened(0.65)
	
	item.set_custom_bg_color(EventConst.EditorColumn.NAME, bg_color, not is_macro)
	item.set_editable(EventConst.EditorColumn.NAME, true)
	
	# Custom columns
	_setup_column_config(item, EventConst.EditorColumn.VARIABLE, get_first_column_config())
	_setup_column_config(item, EventConst.EditorColumn.USERDATA, get_second_column_config())
	
	# Automatically collapse macro items
	if is_macro: item.collapsed = true
	
	return item

func _setup_column_config(item: TreeItem, column: EventConst.EditorColumn, config: Dictionary) -> bool:
	item.set_metadata(column, config["name"])
	item.set_tooltip_text(column, config["name"])
	item.set_editable(column, config["editable"])
	if column == EventConst.EditorColumn.VARIABLE:
		item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
	else:
		item.set_cell_mode(column, config["cell_mode"])
	
	match(item.get_cell_mode(column)):
		TreeItem.CELL_MODE_STRING:
			if column == EventConst.EditorColumn.VARIABLE and event_variable:
				item.set_text(column, event_variable)
			else: if userdata.has(EventConst.item_key_userdata_generic):
				item.set_text(column, userdata[EventConst.item_key_userdata_generic])
		TreeItem.CELL_MODE_RANGE:
			if userdata.has(EventConst.item_key_userdata_generic):
				item.set_range(column, userdata[EventConst.item_key_userdata_generic])
		TreeItem.CELL_MODE_CUSTOM:
			var texture = load("res://addons/event_sequence/icon/Interface-UserdataEdit.svg")
			var image: Image = texture.get_image()
			var img_tex := ImageTexture.create_from_image(image)
			
			item.add_button(EventConst.EditorColumn.USERDATA, img_tex)
			item.set_custom_as_button(EventConst.EditorColumn.USERDATA, true)
			item.set_expand_right(EventConst.EditorColumn.USERDATA, true)
			item.set_button_color(EventConst.EditorColumn.USERDATA, 0, get_color())
			
			for idx in range(userdata.size()):
				item.set_meta(userdata.keys()[idx], userdata.values()[idx])
			
			return true
	
	return false

func build_userdata_from_tree(item: TreeItem) -> Dictionary:
	userdata = {}
	
	for meta in item.get_meta_list():
		if meta.begins_with("__"):
			continue
		
		userdata[meta] = item.get_meta(meta)
	
	return userdata

#endregion

#region Utility

func is_valid_generic(event_node: EventNode, is_fetching: bool) -> bool:
	var is_valid: bool = is_valid_event_variable(event_node, is_fetching)
	is_valid = is_valid and is_valid_userdata(EventConst.item_key_userdata_generic)
	
	if is_valid:
		if userdata[EventConst.item_key_userdata_generic].is_empty():
			warn("Value wasn't set in %s!" % [get_second_column_config()["name"]])
			return false
	
	return is_valid

func is_valid_event_variable(event_node: EventNode, is_fetching: bool) -> bool:
	if event_variable.is_empty():
		warn("Variable Name isn't set!")
		return false
	
	if not is_fetching and not event_node.var_database.has(event_variable):
		warn("Cannot use variable \"%s\" as it hasn't been set yet." % [event_variable])
		return false
	
	return true

func is_valid_userdata(key: String) -> bool:
	if not userdata.has(key):
		warn("Value wasn't set in data! Double-check your sequence.")
		return false
	
	return true

func warn(message: String):
	push_warning("EventNode ran into an problem at item \"%s\"
		%s" % [name, message])

func error(message: String):
	push_error("EventNode ran into a terminating error at item \"%s\"
		%s" % [name, message])

#endregion
