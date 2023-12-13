extends Control

# Node references
@onready var fps_info: Label = %FPSInfoField
@onready var system_info: Label = %SystemInfoField
@onready var memory_info: Label = %MemoryInfoField
@onready var result_container: VBoxContainer = %BenchmarkResults

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_system_info()

func _process(delta: float):
	fps_info.text = "%s FPS" % [roundf(1 / delta)]

func _setup_system_info():
	var os_name = OS.get_name()
	var distro := OS.get_distribution_name()
	var arch := Engine.get_architecture_name()
	var version: String = Engine.get_version_info().string
	
	var format: String = "OS: %s (Distro: %s) Architecture: %s\n" % [os_name, distro, arch]
	format += "Godot %s\n" % [version]
	system_info.text = format
	
	memory_info.text = JSON.stringify(OS.get_memory_info())

func _run_benchmark():
	for item in result_container.get_children():
		item.queue_free()
	
	result_container.add_child(HSeparator.new())
	
	var events: Array[Node] = %EventList.get_children()
	for event in events:
		if event is HSeparator:
			result_container.add_child(HSeparator.new())
			continue
		
		if not event is EventNode:
			continue
		
		var start_time: int = Time.get_ticks_usec()
		await event.start()
		if not event.is_event_finished:
			await event.event_finished
		
		var end_time: int = Time.get_ticks_usec()
		
		var dif: int = end_time - start_time
		var dif_ms: int = dif / 1000
		
		var result := Label.new()
		result.text = "%s: %s milli (%s micro)" % [event.name, str(dif_ms), str(dif)]
		result.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		result_container.add_child(result)
