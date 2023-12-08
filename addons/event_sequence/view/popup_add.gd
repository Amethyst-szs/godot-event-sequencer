@tool
extends Popup

@onready var tree: Tree = %Tree
@onready var tabs: TabContainer = %AddPopupTabs

func _ready():
	pass

func _on_button_pressed():
	var item: EventItem = EventItem.new()
	item.name = "New Name"
	item.add_to_tree(tree.get_selected().get_parent())
