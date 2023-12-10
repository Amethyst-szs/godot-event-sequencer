@tool
extends EventItemBase

func get_name() -> String:
	return "Call Method (No Args, No Return)"

func get_description() -> String:
	return "Call method on object/node or list of objects/nodes without arguments or saving the return value"

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Method

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "None",
		"editable": false,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_second_column_config() -> Dictionary:
	return {
		"name": "Method",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "object",
			"display_name": "Object(s) / Node(s)",
			"desc": "Variable with obj or array",
			"type": TYPE_STRING,
			"require": true,
		},
		{
			"name": "method",
			"desc": "Name of method to call",
			"type": TYPE_STRING,
			"require": true,
		},
	]

func get_color() -> Color:
	return Color.LIME_GREEN

func get_icon_path() -> String:
	return "res://icon.svg"

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_userdata("object") or not is_valid_userdata("method"):
		return EventConst.ItemResponseType.OK
	
	if not event_node.var_database.has(userdata["object"]):
		warn("No variable with name %s" % userdata["object"])
		return EventConst.ItemResponseType.OK
	
	var data = event_node.var_database[userdata["object"]]
	
	# Call method on object or array of object
	match(typeof(data)):
		TYPE_OBJECT:
			call_on_object(data as Object)
		TYPE_ARRAY:
			for item in data:
				if typeof(item) == TYPE_OBJECT:
					call_on_object(item as Object)
		_:
			warn("Data in variable \"%s\" isn't an object or array" % userdata["object"])
			return EventConst.ItemResponseType.OK
	
	return EventConst.ItemResponseType.OK

func call_on_object(object: Object):
	if not object.has_method(userdata["method"]):
		warn("Object in variable \"%s\" doesn't have method \"%s\"" % [userdata["object"], userdata["method"]])
		return
	
	var call := Callable(object, userdata["method"])
	call.call()
