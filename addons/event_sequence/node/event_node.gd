@tool

extends Node
class_name EventNode

@export var event_list: Array[Dictionary] = []
@export var script_list: Array[Script] = []
@export var fetch_database: Dictionary = {}

func _ready():
	if not Engine.is_editor_hint():
		start()

func start():
	_run_dictionary_list(event_list)

func _run_dictionary_list(list: Array[Dictionary]):
	for idx in range(list.size()):
		# Get event dictionary
		var event_root: Dictionary = list[idx]
		if not event_root.has("self"):
			continue
		
		var event_self: Dictionary = event_root["self"]
		
		# New instance of script
		var script: Script = load("res://addons/event_sequence/item/%s" % [event_self["script"]])
		var script_instance = script.new()
		
		# Check if this is a comment type event, skip if so
		if script_instance.is_comment():
			continue
		
		# Wait for the script to run and then continue
		script_instance.parse_dict(event_self)
		var is_success: bool = script_instance.run(self)
		
		if is_success and event_root.has("children"):
			_run_dictionary_list(event_root["children"])
