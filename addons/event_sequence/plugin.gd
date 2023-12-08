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

func _exit_tree():
	if is_instance_valid(editor_view):
		editor_view.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if editor_view:
		editor_view.visible = visible

func _get_plugin_name():
	return "Event"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
