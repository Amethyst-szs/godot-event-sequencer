@tool
extends EditorPlugin

const EditorView = preload("./view/editor.tscn")
var editor_view

func _enter_tree():
	# Return here if editor hint is not present
	if not Engine.is_editor_hint():
		return
	
	# Instantiate save view main screen and hide from view
	editor_view = EditorView.instantiate()
	editor_view.editor_plugin = self
	get_editor_interface().get_editor_main_screen().add_child(editor_view)
	_make_visible(false)
	
	# Connect the editor's selection change signal to func
	var selection := get_editor_interface().get_selection()
	selection.selection_changed.connect(_selection_changed)

func _exit_tree():
	if is_instance_valid(editor_view):
		editor_view.queue_free()
	
	# Remove selection change signal
	var selection := get_editor_interface().get_selection()
	if selection.selection_changed.is_connected(_selection_changed):
		selection.selection_changed.disconnect(_selection_changed)

func _selection_changed():
	# Check if any node is selected
	var selection := get_editor_interface().get_selection()
	if selection.get_selected_nodes().is_empty():
		return
	
	# If this node is an EventNode, switch editor screen
	if selection.get_selected_nodes()[0] is EventNode:
		get_editor_interface().set_main_screen_editor("Event")

func _has_main_screen():
	return true

func _make_visible(visible):
	if editor_view:
		editor_view.visible = visible

func _get_plugin_name():
	return "Event"

func _get_plugin_icon():
	var texture = load("res://addons/event_sequence/icon/IconFlat-Small.svg")
	var image: Image = texture.get_image()
	return ImageTexture.create_from_image(image)
