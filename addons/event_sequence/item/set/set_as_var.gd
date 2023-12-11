@tool
extends EventItemSetBase

func get_name() -> String:
	return "Set Property to Variable"

func get_description() -> String:
	return "Set a property in an object to an event variable"

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "Source Variable",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "object",
			"display_name": "Object/Node",
			"desc": "Var name with object",
			"type": TYPE_STRING,
			"require": true,
		},
		{
			"name": "property",
			"desc": "Name of property",
			"type": TYPE_STRING,
			"require": true,
		},
	]

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-SetProperty.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, false):
		return EventConst.ItemResponseType.OK
	
	if not is_valid_userdata("object") or not is_valid_userdata("property"):
		return EventConst.ItemResponseType.OK
	
	if not event_node.var_database.has(userdata["object"]):
		warn("No variable with name %s" % userdata["object"])
		return EventConst.ItemResponseType.OK
	
	var obj = event_node.var_database[userdata["object"]]
	if typeof(obj) != TYPE_OBJECT:
		warn("Variable provived as object does not contain object")
		return EventConst.ItemResponseType.OK
	
	obj.set(userdata["property"], event_node.var_database[event_variable])
	return EventConst.ItemResponseType.OK
