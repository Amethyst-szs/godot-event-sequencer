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

#region Event Data

var name: String
var script_path: String

var event_variable = null
var userdata: Dictionary = {}

#endregion

#region Implementation

func _ready():
	if name.is_empty():
		name = get_name()

func add_to_tree(parent: TreeItem, editor: Control) -> TreeItem:
	var item: TreeItem = parent.create_child()
	
	# Name column
	if name.is_empty():
		name = get_name()
	
	# Name column
	item.set_text(EventConst.EditorColumn.NAME, name)
	item.set_metadata(EventConst.EditorColumn.NAME, script_path)
	item.set_tooltip_text(EventConst.EditorColumn.NAME, "%s\n%s"
			% [get_name(), get_description()])
	
	var texture = load(get_icon_path())
	var image: Image = texture.get_image()
	item.set_icon(EventConst.EditorColumn.NAME, ImageTexture.create_from_image(image))
	
	item.set_custom_bg_color(EventConst.EditorColumn.NAME, get_color(), true)
	item.set_editable(EventConst.EditorColumn.NAME, true)
	
	# Custom columns
	_setup_column_config(item, EventConst.EditorColumn.VARIABLE, get_first_column_config())
	_setup_column_config(item, EventConst.EditorColumn.USERDATA, get_second_column_config())
	
	return item

func _setup_column_config(item: TreeItem, column: EventConst.EditorColumn, config: Dictionary):
	item.set_metadata(column, config["name"])
	item.set_tooltip_text(column, config["name"])
	item.set_editable(column, config["editable"])
	item.set_cell_mode(column, config["cell_mode"])
	
	match(item.get_cell_mode(column)):
		TreeItem.CELL_MODE_STRING:
			if column == EventConst.EditorColumn.VARIABLE and event_variable:
				item.set_text(column, event_variable)
			else: if userdata.has(EventConst.item_key_userdata_generic):
				item.set_text(column, userdata[EventConst.item_key_userdata_generic])
		TreeItem.CELL_MODE_RANGE:
			if column == EventConst.EditorColumn.VARIABLE and event_variable:
				item.set_range(column, event_variable)
			else: if userdata.has(EventConst.item_key_userdata_generic):
				item.set_range(column, userdata[EventConst.item_key_userdata_generic])
		TreeItem.CELL_MODE_CUSTOM:
			for idx in userdata:
				item.set_meta(userdata.keys()[idx], userdata.values()[idx])

func run(event_node: EventNode) -> bool:
	print(name)
	return true

func parse_dict(dict: Dictionary) -> void:
	name = dict[EventConst.item_key_name]
	if dict.has(EventConst.item_key_variable):
		event_variable = dict[EventConst.item_key_variable]
	
	if dict.has(EventConst.item_key_userdata):
		if typeof(dict[EventConst.item_key_userdata]) == TYPE_DICTIONARY:
			userdata = dict[EventConst.item_key_userdata]

func build_userdata_from_tree(item: TreeItem) -> Dictionary:
	userdata = {}
	
	for meta in item.get_meta_list():
		if meta.begins_with("__"):
			continue
		
		userdata[meta] = item.get_meta(meta)
	
	return userdata

#endregion
