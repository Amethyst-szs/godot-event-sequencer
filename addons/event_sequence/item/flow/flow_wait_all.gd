@tool
extends EventItemFlowBase

var signal_tally: int = 0
var signal_tally_target: int = 0

signal event_complete

#region Config

func get_name() -> String:
	return "Wait for Signal from All"

func get_description() -> String:
	return "Wait at this point for a signal from node(s). If multiple nodes are given, wait for all to emit this signal."

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Signal Name",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_STRING
	}

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowWaitSignalAll.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	if not is_valid_generic(event_node, false):
		return EventConst.ItemResponseType.OK
	
	# Get the item from the fetch data and the name of the signal
	var target = event_node.var_database[event_variable]
	var signal_name: String = userdata[EventConst.item_key_userdata_generic]
	
	# Handle differently depending on the type of "target"
	match(typeof(target)):
		TYPE_OBJECT:
			_add_node_signal_to_tally(target, signal_name)
		TYPE_ARRAY:
			for item in target:
				if typeof(item) == TYPE_OBJECT:
					_add_node_signal_to_tally(item, signal_name)
		_:
			warn("Data in variable \"%s\" isn't a node or array of nodes" % [event_variable])
			return EventConst.ItemResponseType.OK
	
	if signal_tally_target == 0:
		warn("Skipping signal wait cause no signals were connected successfully!")
		return EventConst.ItemResponseType.OK
	
	await event_complete
	return EventConst.ItemResponseType.OK

func _add_node_signal_to_tally(node, signal_name: String) -> void:
	# Ensure this item is a node
	if not node is Node:
		warn("Variable \"%s\" has item that isn't of type \"Node\"!" % [event_variable])
		return
	
	if not node.has_signal(signal_name):
		warn("Node in variable \"%s\" doesn't have signal \"%s\"" % [event_variable, signal_name])
		return
	
	node.connect(signal_name, _signal_tally.bind(node, signal_name))
	signal_tally_target += 1

func _signal_tally(node: Node, signal_name: String) -> void:
	# Disconnect this node from the tally function
	if node.is_connected(signal_name, _signal_tally):
		node.disconnect(signal_name, _signal_tally)
	
	# Increment tally counter
	signal_tally += 1
	if signal_tally >= signal_tally_target:
		_event_complete_trigger()

func _event_complete_trigger() -> void:
	event_complete.emit()
