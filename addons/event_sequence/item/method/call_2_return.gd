@tool
extends EventItemBase

var return_data

#region Config

func get_name() -> String:
	return "Call Method (Get Return)"

func get_description() -> String:
	return "Call method on object/node or list of objects/nodes and save the return (no arguments)
		If multiple objects are passed in, new variable will be array of returns from each obj."

func get_editor_tab() -> EventConst.EditorDialogTab:
	return EventConst.EditorDialogTab.Method

func is_allow_in_editor() -> bool:
	return true

func get_first_column_config() -> Dictionary:
	return {
		"name": "New Variable Name",
		"editable": true,
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
			EventConst.userdata_key_name: "object",
			EventConst.userdata_key_display: "Object(s) / Node(s)",
			EventConst.userdata_key_desc: "Variable with obj or array",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
		{
			EventConst.userdata_key_name: "method",
			EventConst.userdata_key_desc: "Name of method to call",
			EventConst.userdata_key_type: TYPE_STRING,
			EventConst.userdata_key_require: true,
		},
	]

func get_color() -> Color:
	return Color.LIME_GREEN

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-MethodCallRet.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_event_variable(event_node, true):
		return EventConst.ItemResponseType.OK
	
	if not is_valid_userdata("object") or not is_valid_userdata("method"):
		return EventConst.ItemResponseType.OK
	
	if not event_node.var_database.has(userdata["object"]):
		warn("No variable with name %s" % userdata["object"])
		return EventConst.ItemResponseType.OK
	
	var data = event_node.var_database[userdata["object"]]
	
	# Call method on object or array of object
	match(typeof(data)):
		TYPE_OBJECT:
			call_on_object(data as Object, false)
		TYPE_ARRAY:
			return_data = Array()
			for item in data:
				if typeof(item) == TYPE_OBJECT:
					call_on_object(item as Object, true)
		_:
			warn("Data in variable \"%s\" isn't an object or array" % [userdata["object"]])
			return EventConst.ItemResponseType.OK
	
	event_node.var_database[event_variable] = return_data
	return EventConst.ItemResponseType.OK

func call_on_object(object: Object, is_part_of_array: bool):
	if not object.has_method(userdata["method"]):
		warn("Object in variable \"%s\" doesn't have method \"%s\"" % [userdata["object"], userdata["method"]])
		return
	
	var call := Callable(object, userdata["method"])
	if not is_part_of_array:
		return_data = call.call()
	else:
		return_data.push_back(call.call())
