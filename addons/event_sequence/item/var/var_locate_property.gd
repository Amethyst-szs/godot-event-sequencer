@tool
extends EventItemVarBase

func get_name() -> String:
	return "Get Property from Object"

func get_description() -> String:
	return "Get a property from an event variable object and add it to your event variables"

func is_allow_in_editor() -> bool:
	return true

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-GetProperty.svg"

func get_second_column_config() -> Dictionary:
	return {
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			EventConst.userdata_key_name: "object",
			EventConst.userdata_key_display: "Object/Node",
			EventConst.userdata_key_desc: "Var name with object",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
		{
			EventConst.userdata_key_name: "property",
			EventConst.userdata_key_desc: "Name of property",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
	]

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, true):
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
	
	var property = obj.get(userdata["property"])
	if not property:
		warn("Object doesn't have property %s" % [userdata["property"]])
		return EventConst.ItemResponseType.OK
	
	event_node.var_database[event_variable] = property
	return EventConst.ItemResponseType.OK
