@tool
extends Popup

# Data
var database_str: String:
	set(value):
		database = JSON.parse_string(value)

var database: Dictionary

# Constants
const temp_file_path: String = "res://addons/event_sequence/"
const repo_path: String = "https://raw.githubusercontent.com/Amethyst-szs/godot-event-sequencer/main/"

# Called when the node enters the scene tree for the first time.
func _ready():
	about_to_popup.connect(open)
	popup_hide.connect(close)

func open():
	database = {}
	download_http(repo_path + "icon.svg", "database_str")

func close():
	print(database)

#region HTTP request tools

func download_http(link: String, store_variable_name: String):
	# Create new HTTPRequest node
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	
	# Set the temp file to download the HTTP data into
	var file_name: String = "temp" + str(randi_range(1000000, 9999999))
	http.set_download_file(temp_file_path + file_name)
	
	# Connect request completed to function
	http.request_completed.connect(_http_request_completed.bind(file_name, store_variable_name, http))
	
	# If errored, push that error
	var error = http.request(link)
	if error != OK:
		push_error("Http request error: %s" % [error])

func _http_request_completed(result, _response_code, _headers, _body, file_name, var_name, node):
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
	set(var_name, content)
	
	# Destroy temporary file
	if dir_access.file_exists(file_name):
		dir_access.remove(file_name)
	
	print(plugin_database)

#endregion
