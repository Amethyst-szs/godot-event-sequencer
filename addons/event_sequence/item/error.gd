@tool
extends EventItemBase

func get_description() -> String:
	return "The script for this item is missing! Here's a couple possible issues:
		This item is from an Event Sequencer Plugin and the plugin was disabled.
		The script that this item uses was manually deleted.
		Some file got corrupted."

func is_allow_in_editor() -> bool:
	return false

func get_color() -> Color:
	return Color.DARK_RED

func get_icon_path() -> String:
	return "res://addons/event_sequence/icon/EventItem-Error.svg"
