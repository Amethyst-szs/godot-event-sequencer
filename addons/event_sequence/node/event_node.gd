@tool

extends Node
class_name EventNode

@export var event_list: Array[Dictionary] = []
@export var script_list: Array[Script] = []
@export var fetch_database: Dictionary = {}

func _ready():
	if not Engine.is_editor_hint():
		preload_scripts(event_list)
		start()

func preload_scripts(dict_list: Array[Dictionary]):
	# Iterate through the event list
	for event in dict_list:
		# Ensure this item has self dict
		if not event.has("self"):
			continue
		
		# If the resource loader doesn't have this script cached, cache it
		if not ResourceLoader.has_cached(event["self"]["script"]):
			script_list.push_back(await ResourceLoader.load(event["self"]["script"], "Script"))
		
		# If this event has children, look through them recursively as well
		if event.has("children"):
			preload_scripts(event["children"])

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
		var script: Script = ResourceLoader.load(event_self["script"], "Script")
		var script_instance = script.new()
		
		# Check if this is a comment type event, skip if so
		if script_instance.is_comment():
			if event_root.has("children"):
				_run_dictionary_list(event_root["children"])
			
			continue
		
		# Wait for the script to run and then continue
		script_instance.parse_dict(event_self)
		var is_successful: bool = await script_instance.run(self)
		
		if is_successful and event_root.has("children"):
			_run_dictionary_list(event_root["children"])
	
	# Once iterating through events is complete, empty out fetch database
	fetch_database.clear()
