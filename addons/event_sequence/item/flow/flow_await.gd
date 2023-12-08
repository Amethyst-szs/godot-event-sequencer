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

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, false):
		return EventConst.ItemResponseType.OK
	
	# Get the item from the fetch data and the name of the signal
	var target = event_node.fetch_database[event_variable]
	var signal_name: String = userdata[EventConst.item_key_userdata_generic]
	
	# Ensure this item is a node
	if not target is Node:
		warn("Variable \"%s\" must contain a singular node, nothing else!" % [event_variable])
		return EventConst.ItemResponseType.OK
	
	if not target.has_signal(signal_name):
		warn("Node in variable \"%s\" doesn't have signal \"%s\"" % [event_variable, signal_name])
		return EventConst.ItemResponseType.OK
	
	target.connect(signal_name, _event_complete_trigger)
	await event_complete
	
	return EventConst.ItemResponseType.OK

func _event_complete_trigger():
	event_complete.emit()
