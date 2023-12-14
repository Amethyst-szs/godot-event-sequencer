@tool
extends EventItemWaitBase

signal timer_complete

#region Config

func get_name() -> String:
	return "Wait for Timer"

func get_description() -> String:
	return "Wait at this point for a customizable amount of time"

func is_allow_in_editor() -> bool:
	return true

func get_second_column_config() -> Dictionary:
	return {
		"name": "Config",
		"editable": true,
		"cell_mode": TreeItem.CELL_MODE_CUSTOM
	}

func get_userdata_keys() -> Array[Dictionary]:
	return [
		{
			EventConst.userdata_key_name: "dur",
			EventConst.userdata_key_display: "Time in Seconds",
			EventConst.userdata_key_desc: "",
			EventConst.userdata_key_type: TYPE_FLOAT,
			EventConst.userdata_key_require: false,
			EventConst.userdata_key_default: 1.0,
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
