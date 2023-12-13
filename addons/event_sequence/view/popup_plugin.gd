@tool
extends Popup

# State
var changes_made: bool = false:
	set(value):
		changes_made = value
		if reload_warn:
			reload_warn.visible = changes_made

# Constants
const plugin_folder: String = "res://addons/event_sequence/plugin/"

# Node references
@onready var editor: Control = $"../"
@onready var item_list: VBoxContainer = $Panel/Scroll/List/Items
@onready var reload_warn: Container = $Panel/WarnReload

#region Initalization and Close

func _ready():
	about_to_popup.connect(open)
	popup_hide.connect(close)

func open():
	# Reset changes flag
	changes_made = false
	
	# Destroy current panels
	for item in item_list.get_children():
		item_list.remove_child(item)
	
	# Get status of enabled plugins
	var enabled_plugins: PackedStringArray = _get_plugin_list()
	
	# Load plugins directory
	var plugin_dir := DirAccess.open(plugin_folder)
	if plugin_dir.get_open_error() != OK:
		printerr("EventNode couldn't open plugins folder")
		return
	
	# For each directory in plugins dir, try to create a new panel
	for dir in plugin_dir.get_directories():
		var dir_access := DirAccess.open(plugin_folder + dir)
		if dir_access.get_open_error() != OK:
			printerr("EventNode couldn't open %s plugin" % [dir])
			return
		
		# Ensure the directory has a config file
		if not dir_access.file_exists("esplugin.cfg"):
			continue
		
		# Load configuration
		var config = ConfigFile.new()
		config.load(plugin_folder + dir + "/esplugin.cfg")
		
		# Create seperation
		item_list.add_child(HSeparator.new())
		
		# Create root panel
		var container := HBoxContainer.new()
		item_list.add_child(container)
		
		# Create texture and panel on far left
		var texture = null
		if dir_access.file_exists("esplugin.svg"):
			var resource := load(plugin_folder + dir + "/esplugin.svg")
			var image: Image = resource.get_image()
			texture = ImageTexture.create_from_image(image)
		else:
			texture = PlaceholderTexture2D.new()
			texture.size = Vector2(64, 64)
		
		var texture_panel := TextureRect.new()
		texture_panel.texture = texture
		texture_panel.custom_minimum_size = Vector2(64, 64)
		texture_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		texture_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		container.add_child(texture_panel)
		
		# Create text organization panel
		var info_container := VBoxContainer.new()
		container.add_child(info_container)
		
		# Add text info
		var label_name := Label.new()
		label_name.text = config.get_value("esplugin", "name", "Name Missing!")
		info_container.add_child(label_name)
		
		var label_desc := Label.new()
		label_desc.text = config.get_value("esplugin", "desc", "Desc Missing!")
		info_container.add_child(label_desc)
		
		# Add prerequest marker
		var missing_prerequest: bool = false
		if config.get_value("prerequest", "require", false):
			missing_prerequest = _add_prerequest_data(info_container, config, enabled_plugins)
		
		# Add toggle plugin button
		var toggle := CheckButton.new()
		toggle.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		toggle.text = "Enabled"
		toggle.disabled = missing_prerequest
		toggle.button_pressed = config.get_value("enabled", "is_enabled", false)
		container.add_child(toggle)
		
		# Hook up toggle to function
		toggle.toggled.connect(_toggle_button_hit.bind(dir))

func _add_prerequest_data(container: Control, config: ConfigFile, plugin_list: PackedStringArray) -> bool:
	var label_prerequest := Label.new()
	container.add_child(label_prerequest)
	
	var is_valid := _is_active_plugin(plugin_list, config.get_value("prerequest", "name", "NONE"))
	if is_valid:
		label_prerequest.text = "Your project has required prerequest for this plugin"
		label_prerequest.add_theme_color_override("font_color", Color.GRAY)
		return false
	
	label_prerequest.text = "Missing Prerequest: %s" % config.get_value("prerequest", "name", "NONE")
	label_prerequest.add_theme_color_override("font_color", Color.LIGHT_CORAL)
	
	var prequest_url_button := LinkButton.new()
	prequest_url_button.text = "- Check out prerequest here- "
	prequest_url_button.uri = config.get_value("prerequest", "url", "https://google.com")
	container.add_child(prequest_url_button)
	return true

func close():
	# Destroy current panels
	for item in item_list.get_children():
		item_list.remove_child(item)
	
	# Restart editor if needed
	if changes_made:
		editor.editor_plugin.get_editor_interface().restart_editor(true)

#endregion

#region Plugin toggling

func _toggle_button_hit(state: bool, dir: String):
	# Load configuration
	var config = ConfigFile.new()
	config.load(plugin_folder + dir + "/esplugin.cfg")
	
	# Get the script directory
	var script_dir: String = config.get_value("esplugin", "script_dir", "script")
	var dir_access := DirAccess.open(plugin_folder + dir + "/" + script_dir)
	if dir_access.get_open_error() != OK:
		printerr("EventNode couldn't open script folder for plugin")
		return
	
	# Modify all values in the script directory
	for item in dir_access.get_files():
		var new_name: String = item
		
		if not state:
			new_name = new_name.replace(".gd", ".espdisabled")
		else:
			new_name = new_name.replace(".espdisabled", ".gd")
		
		dir_access.rename(item, new_name)
	
	# Set configuration
	config.set_value("enabled", "is_enabled", state)
	config.save(plugin_folder + dir + "/esplugin.cfg")
	
	# Set changes made flag
	changes_made = true

#endregion

#region Prerequests

func _get_plugin_list() -> PackedStringArray:
	var config = ConfigFile.new()
	config.load("res://project.godot")
	return config.get_value("editor_plugins", "enabled")

func _is_active_plugin(plugin_list: PackedStringArray, plugin_folder_name: String) -> bool:
	for item in plugin_list:
		var path: String = item.substr(0, item.rfind("/"))
		var folder: String = path.substr(path.rfind("/") + 1, -1)
		if folder.is_empty():
			printerr("EventNode: Something went wrong reading plugin at \"%s\"" % [item])
			continue
		
		if folder == plugin_folder_name:
			return true
	
	return false

#endregion
