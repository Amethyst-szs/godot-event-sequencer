@tool
extends EventItemFlowBase

signal timer_complete

#region Config

func get_name() -> String:
	return "Wait for Timer"

func get_description() -> String:
	return "Wait at this point for a customizable amount of time"

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
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			"name": "dur",
			"display_name": "Time in Seconds",
			"desc": "",
			"type": TYPE_FLOAT,
			"require": false,
			"default": 1.0,
		},
	]

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowWaitTimer.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var timer := Timer.new()
	event_node.add_child(timer)
	
	if userdata.has("dur"):
		timer.wait_time = userdata["dur"]
	
	timer.timeout.connect(_timer_complete_trigger)
	timer.start()
	await timer_complete
	
	timer.queue_free()
	return EventConst.ItemResponseType.OK

func _timer_complete_trigger() -> void:
	timer_complete.emit()
