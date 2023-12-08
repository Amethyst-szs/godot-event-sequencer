@tool
extends EventItemFlowBase

signal event_complete

func get_name() -> String:
	return "Await Signal from Node"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Signal Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func run(event_node: EventNode) -> bool:
	#if typeof(property1) == TYPE_NIL or typeof(property2) == TYPE_NIL:
	#	push_warning("EventNode cannot await for signal from node without node variable and signal name")
	#	return true
	
	#if not event_node.fetch_database.has(property1):
	#	push_warning("EventNode cannot await for signal from node with an unknown variable name (%s)"
	#	% [property1])
	#	return true
	
	#if not event_node.fetch_database[property1] is Node:
	#	push_warning("EventNode cannot await for signal from node using variable name that isn't node
	#	Variable: %s - Signal: %s" % [str(property1), str(property2)])
	#	return true
	
	#var target: Node = event_node.fetch_database[property1]
	
	#if not target.has_signal(property2):
	#	push_warning("EventNode cannot await for signal from node since node doesn't have signal (%s)"
	#	% [property2])
	#	return true
	
	#target.connect(property2, _event_complete_trigger)
	#await event_complete
	
	return true

func _event_complete_trigger():
	event_complete.emit()
