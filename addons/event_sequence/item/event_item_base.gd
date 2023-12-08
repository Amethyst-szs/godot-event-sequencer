@tool
extends RefCounted
class_name EventItemBase

#region Overridable Config

func get_name() -> String:
	return "Event Item Base"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.General

func is_comment() -> bool:
	return false

func get_color() -> Color:
	return Color.ORANGE

func get_icon_path() -> String:
	return "res://icon.svg"


#endregion

#region Event Data

var name: String
var script_path: String

#endregion

#region Implementation

func _ready():
	if name.is_empty():
		name = get_name()

func add_to_tree(parent: TreeItem) -> TreeItem:
	var item: TreeItem = parent.create_child()
	
	# Name column
	item.set_text(EventConst.EditorColumn.NAME, name)
	item.set_metadata(EventConst.EditorColumn.NAME, script_path)
	
	var texture = load(get_icon_path())
	var image: Image = texture.get_image()
	item.set_icon(EventConst.EditorColumn.NAME, ImageTexture.create_from_image(image))
	
	item.set_custom_bg_color(EventConst.EditorColumn.NAME, get_color(), true)
	item.set_editable(EventConst.EditorColumn.NAME, true)
	
	return item

func run(event_node: EventNode) -> bool:
	print(name)
	return true

func parse_dict(dict: Dictionary) -> void:
	name = dict["name"]

#endregion
