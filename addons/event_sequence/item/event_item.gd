@tool
extends RefCounted
class_name EventItem

func get_script_name() -> String:
	return "event_item.gd"

#region Event Data

var name: String = "EventItem"

enum EditorColumn {
	NAME,
	PROPERTY
}

#endregion

#region Implementation

func add_to_tree(parent: TreeItem) -> TreeItem:
	var item: TreeItem = parent.create_child()
	
	# Name column
	item.set_text(EditorColumn.NAME, name)
	item.set_metadata(EditorColumn.NAME, get_script_name())
	
	var texture = load(_get_icon_path())
	var image: Image = texture.get_image()
	item.set_icon(EditorColumn.NAME, ImageTexture.create_from_image(image))
	
	item.set_custom_bg_color(EditorColumn.NAME, _get_color(), true)
	item.set_editable(EditorColumn.NAME, true)
	
	return item

func run(event_node: EventNode) -> bool:
	print(name)
	return true

func parse_dict(dict: Dictionary) -> void:
	name = dict["name"]

#endregion

#region Virtual Parameter Functions

func is_comment() -> bool:
	return false

func _get_color() -> Color:
	return Color.ORANGE

func _get_icon_path() -> String:
	return "res://icon.svg"

#endregion
