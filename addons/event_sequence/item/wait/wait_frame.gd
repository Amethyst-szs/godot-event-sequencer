@tool
extends EventItemWaitBase

signal timer_complete

#region Config

func get_name() -> String:
	return "Wait for Single Frame"

func get_description() -> String:
	return "Wait at this point until the next process frame. Useful for preventing large
		event sequences with no other waiting from causing lag on slower machines."

func is_allow_in_editor() -> bool:
	return true

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-FlowWaitFrame.svg"

#endregion

func run(event_node: EventNode) -> EventConst.ItemResponseType:
	var timer := Timer.new()
	event_node.add_child(timer)
	timer.wait_time = 0.000001
	
	timer.timeout.connect(_timer_complete_trigger)
	timer.start()
	await timer_complete
	
	timer.queue_free()
	return EventConst.ItemResponseType.OK

func _timer_complete_trigger() -> void:
	timer_complete.emit()
