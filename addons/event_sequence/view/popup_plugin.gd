@tool
extends Popup

# Constants
const temp_file_path: String = "res://addons/event_sequence/"
const repo_path: String = "https://raw.githubusercontent.com/Amethyst-szs/godot-event-sequencer/main/"

# Node references
@onready var idle_screen: CenterContainer = $Panel/DownloadingIdle
@onready var interface_screen: SplitContainer = $Panel/Interface
@onready var plugin_grid: GridContainer = $Panel/Interface/PluginScroll/Plugins

#region Database

var database_str: String:
	set(value):
		database = JSON.parse_string(value)
		print("Downloaded plugin database")

var database: Dictionary:
	set(value):
		database = value
		if value.is_empty():
			_unload_plugin_list()
		else:
			_load_plugin_list()

var plugin_button_icons: Array[Texture2D]

#endregion

#region Initalization and Close

func _ready():
	about_to_popup.connect(open)
	popup_hide.connect(close)

func open():
	database = {}
	download_http(repo_path + "plugins/database.json", "database_str")

func close():
	print(database)

#endregion

#region Load/Unload menu contents

func _load_plugin_list():
	idle_screen.visible = false
	interface_screen.visible = true
	
	for item in plugin_grid.get_children():
		plugin_grid.remove_child(item)
	
	var idx: int = 0
	for item in database["plugins"]:
		# Create placeholder icon
		var texture := PlaceholderTexture2D.new()
		texture.size = Vector2(64, 64)
		plugin_button_icons.push_back(texture)
		
		# Build button
		var button := Button.new()
		button.text = item["name"]
		button.icon = texture
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Add button to grid
		plugin_grid.add_child(button)
		
		# Start download of icon
		download_http(repo_path + "plugins/" + item["path"] + "/" + item["icon"], "", idx)
		idx += 1

func _unload_plugin_list():
	# Destroy buttons
	plugin_button_icons = []
	for item in plugin_grid.get_children():
		plugin_grid.remove_child(item)
	
	idle_screen.visible = true
	interface_screen.visible = false

#endregion

#region HTTP request tools

func download_http(link: String, store_variable_name: String, button_index: int = -1):
	# Create new HTTPRequest node
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	
	# Set the temp file to download the HTTP data into
	var file_name: String = "temp" + str(randi_range(1000000, 9999999))
	if button_index > -1:
		file_name += ".svg"
	
	http.set_download_file(temp_file_path + file_name)
	
	# Connect request completed to function
	http.request_completed.connect(_http_request_completed.bind(file_name, store_variable_name, button_index, http))
	
	# If errored, push that error
	var error = http.request(link)
	if error != OK:
		push_error("Http request error: %s" % [error])

func _http_request_completed(result, _response_code, _headers, _body, file_name, var_name, button_index, node):
	# Destroy HTTP node
	node.queue_free()
	
	# Open temp directory
	var dir_access := DirAccess.open(temp_file_path)
	
	# If the result was a failure, delete the temp file and leave
	if result != OK:
		push_error("Download Failed")
		if dir_access.file_exists(file_name):
			dir_access.remove(file_name)
		return
	
	# If assiging button icon
	if button_index > -1:
		var img: Image = Image.load_from_file(temp_file_path + file_name)
		print(temp_file_path + file_name)
		print(img)
		var tex := ImageTexture.create_from_image(img)
		plugin_button_icons[button_index] = tex
		plugin_grid.get_child(button_index).icon = tex
	
	# Attempt to open the temp file
	var file = FileAccess.open(temp_file_path + file_name, FileAccess.READ)
	if file == null:
		printerr("FileAccess open error: " + str(FileAccess.get_open_error()))
		if dir_access.file_exists(file_name):
			dir_access.remove(file_name)
		return
	
	# Get the content of the open file
	var content = file.get_as_text()
	file.close()
	
	# Write content to variable
	if button_index == -1:
		set(var_name, content)
	
	# Destroy temporary file
	if dir_access.file_exists(file_name):
		dir_access.remove(file_name)

#endregion
