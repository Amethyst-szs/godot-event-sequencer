@tool

extends Node
class_name EventNode

@export var event_list: Array[Dictionary] = []
@export var script_list: Array[Script] = []
@export var fetch_database: Dictionary = {}

@export var is_terminating: bool = false

func _ready():
	if not Engine.is_editor_hint():
		preload_scripts(event_list)
		start()

func preload_scripts(dict_list: Array[Dictionary]):
	# Iterate through the event list
	for event in dict_list:
		# Ensure this item has self dict
		if not event.has(EventConst.item_key_self):
			continue
		
		# If the resource loader doesn't have this script cached, cache it
		if not ResourceLoader.has_cached(event[EventConst.item_key_self][EventConst.item_key_script]):
			var script := await ResourceLoader.load(event[EventConst.item_key_self][EventConst.item_key_script], "Script")
			script_list.push_back(script)
		
		# If this event has children, look through them recursively as well
		if event.has(EventConst.item_key_child):
			preload_scripts(event[EventConst.item_key_child])

func start():
	_run_dictionary_list(event_list, true)

func _run_dictionary_list(list: Array[Dictionary], is_first_recursion: bool = false):
	for idx in range(list.size()):
		if is_terminating:
			return
		
		# Get event dictionary
		var event_root: Dictionary = list[idx]
		if not event_root.has(EventConst.item_key_self):
			continue
		
		var event_self: Dictionary = event_root[EventConst.item_key_self]
		
		# New instance of script
		var script: Script = ResourceLoader.load(event_self[EventConst.item_key_script], "Script")
		var script_instance = script.new()
		
		# Check if this is a comment type event, skip if so
		if script_instance.is_comment():
			if event_root.has(EventConst.item_key_child):
				await _run_dictionary_list(event_root[EventConst.item_key_child])
			
			continue
		
		# Wait for the script to run and then continue
		script_instance.parse_dict(event_self)
		var result: EventConst.ItemResponseType = await script_instance.run(self)
		
		match(result):
			EventConst.ItemResponseType.OK:
				if event_root.has(EventConst.item_key_child):
					await _run_dictionary_list(event_root[EventConst.item_key_child])
			EventConst.ItemResponseType.SKIP_CHILDREN:
				continue
			EventConst.ItemResponseType.TERMINATE:
				is_terminating = true
	
	
	# Once iterating through events is complete
	if is_first_recursion:
		fetch_database.clear()
		is_terminating = false
