@icon("res://icon.svg")

extends Node
class_name EventNode

#region Exports & Other Variables

## Should this event sequence automatically start on scene load?
@export var autostart: bool = true
## Should this sequence automatically free itself after ending?
@export var autofree: bool = true
## What label should the sequence start on? (Leave blank for default behavior)
@export var start_label: String = ""

# Lists and Databases

# This is an @export_storage variable.
# This lets the event editor modify the variable without exposing
# it to the inspector. Code for this is in _validate_property
@export var event_list: Array[Dictionary] = []

var label_list: Dictionary = {}
var var_database: Dictionary = {}

# Status
var is_terminating: bool = false
var label_jump_target: String = ""
var new_for_loop_length: int = -1

var while_loop_condition_script: GDScript = null
var while_loop_condition_input: String = ""

#endregion

#region End-User Functions

## Starts the sequence from the top (unless overriden by "start_label" in inspector)
func start():
	if not start_label.is_empty():
		start_from_label(start_label)
		return
	
	_run_dictionary_list(event_list, true)

## Start the sequence from a specific label, don't modify "is_external_call" unless you know
## what you are doing
func start_from_label(label: String, is_external_call: bool = true):
	if not label_list.has(label):
		push_warning("Cannot start %s from label %s cause it doesn't exist" % [name, label])
		return
	
	# Get base data
	var idx_path: Array[int] = label_list[label]
	var dict: Array[Dictionary] = event_list
	
	# For each item in the idx_path, navigate down event list
	var item: int = 0
	while item < idx_path.size() - 1:
		dict = dict[idx_path[item]][EventConst.item_key_child]
		item += 1
	
	# Reset the jump target and start
	label_jump_target = ""
	await _run_dictionary_list(dict, is_external_call, idx_path.back())

## Forcefully end the current sequence at the current point
func end_force():
	is_terminating = true

#endregion

#region Virtual Functions

func _ready():
	# Create an instance of every script item and create label index list
	preload_scripts_and_labels(event_list)
	
	if autostart:
		start()

func _process(_delta: float):
	# Check if there is a label_jump_target and start there if so
	if not label_jump_target.is_empty():
		start_from_label(label_jump_target, false)

func _validate_property(property):
	if property.name == "event_list":
		property.usage &= PROPERTY_USAGE_STORAGE

#endregion

#region Implementation

func preload_scripts_and_labels(dict_list: Array[Dictionary], index_path: Array[int] = []):
	# Never ever do this in the editor
	if Engine.is_editor_hint():
		return
	
	# Iterate through the event list
	for event in dict_list:
		# Ensure this item has self dict
		if not event.has(EventConst.item_key_self):
			continue
		
		# Create instance of this item's script
		var script: Script = await load(event[EventConst.item_key_self][EventConst.item_key_script])
		var inst = script.new()
		inst.parse_dict(event[EventConst.item_key_self])
		
		# Save this instance to the dictionary
		event[EventConst.item_key_self][EventConst.item_key_instance] = inst
		
		# Get index path to this specific item
		var self_index_path: Array[int] = index_path.duplicate()
		self_index_path.push_back(dict_list.find(event))
		
		# If this event is a label marker, add to label list
		if event.has(EventConst.item_key_flag_label):
			var label_name: String = event[EventConst.item_key_self][EventConst.item_key_name]
			if label_list.has(label_name):
				push_warning("EventNode \"%s\" has multiple labels with name \"%s\"" % [name, label_name])
			
			label_list[label_name] = self_index_path
		
		# If this event has children, look through them recursively as well
		if event.has(EventConst.item_key_child):
			preload_scripts_and_labels(event[EventConst.item_key_child], self_index_path)

func _run_dictionary_list(list: Array[Dictionary], is_first_recursion: bool = false, start_idx: int = 0, loop_count: int = -1):
	var idx: int = start_idx
	var loops: int = loop_count
	
	while idx < list.size():
		# Leave here if terminating or jumping to label
		if is_terminating or not label_jump_target.is_empty():
			return
		
		# Get event dictionary
		var event_root: Dictionary = list[idx]
		if not event_root.has(EventConst.item_key_self):
			continue
		
		var event_self: Dictionary = event_root[EventConst.item_key_self]
		
		# Get instance of script
		var script_instance = event_self[EventConst.item_key_instance]
		
		# Increment counter
		idx += 1
		
		# Check if this is a comment type event, skip if so
		if script_instance.is_comment() or script_instance.is_label():
			if event_root.has(EventConst.item_key_child):
				await _run_dictionary_list(event_root[EventConst.item_key_child])
			
			continue
		
		# Wait for the script to run and then continue
		var result: EventConst.ItemResponseType = await script_instance.run(self)
		
		match(result):
			EventConst.ItemResponseType.OK:
				if event_root.has(EventConst.item_key_child):
					await _run_dictionary_list(event_root[EventConst.item_key_child])
			EventConst.ItemResponseType.SKIP_CHILDREN:
				continue
			EventConst.ItemResponseType.JUMP:
				continue
			EventConst.ItemResponseType.JUMP_AND_RETURN:
				await start_from_label(label_jump_target, false)
			EventConst.ItemResponseType.LOOP_FOR:
				if event_root.has(EventConst.item_key_child):
					await _run_dictionary_list(event_root[EventConst.item_key_child], false, 0, new_for_loop_length)
			EventConst.ItemResponseType.LOOP_WHILE:
				if event_root.has(EventConst.item_key_child):
					await _run_dictionary_list(event_root[EventConst.item_key_child])
			EventConst.ItemResponseType.TERMINATE:
				is_terminating = true
		
		# If not at the final local child, continue here
		if idx < list.size():
			continue
		
		# If still in for loop, restart here
		if loop_count > 0:
			loop_count -= 1
			idx = start_idx
		
		# If in while loop, check condition here
		if while_loop_condition_script:
			var inst := while_loop_condition_script.new()
			if inst.execute(var_database[while_loop_condition_input]):
				idx = start_idx
			else:
				while_loop_condition_script = null
				while_loop_condition_input = ""
	
	# Once iterating through events is complete, cleanup
	if is_first_recursion and label_jump_target.is_empty():
		is_terminating = false
		var_database.clear()
		
		if autofree:
			queue_free()

#endregion
