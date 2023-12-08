@tool
extends EventItemFlowBase

signal event_complete

func get_name() -> String:
	return "Await Signal from Node"

func get_description() -> String:
	return "Wait at this point for a signal from a node. Fetched variable must contain a node"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Signal Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> bool:
	var signal_name: String = userdata[EventConst.item_key_userdata_generic]
	
	if typeof(event_variable) == TYPE_NIL or typeof(signal_name) == TYPE_NIL:
		push_warning("EventNode cannot await for signal from node without node variable and signal name")
		return true
	
	if not event_node.fetch_database.has(event_variable):
		push_warning("EventNode cannot await for signal from node with an unknown variable name (%s)"
		% [event_variable])
		return true
	
	var target: Node = event_node.fetch_database[event_variable]
	
	if not event_node.fetch_database[event_variable] is Node:
		push_warning("EventNode cannot await for signal from node using variable name that isn't node
		Variable: %s - Signal: %s" % [str(event_variable), str(signal_name)])
		return true
	
	if not target.has_signal(signal_name):
		push_warning("EventNode cannot await for signal from node since node doesn't have signal (%s)"
		% [signal_name])
		return true
	
	target.connect(signal_name, _event_complete_trigger)
	await event_complete
	
	return true

func _event_complete_trigger():
	event_complete.emit()
