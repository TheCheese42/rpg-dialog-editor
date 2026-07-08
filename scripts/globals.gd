extends Node

var DEFAULT_GENERIC_PRESET: Dictionary = {
	"color": Color.WHITE,
	"speed": 100,
	"wave_intensity": 0,
	"wave_speed": 0,
	"shake_intensity": 0,
	"shake_speed": 0,
}

var conversations: Array[DialogFile.Conversation] = []
var generic_presets: Dictionary[String, Dictionary] = {
	"Default": DEFAULT_GENERIC_PRESET
}
var generic_preset_names: PackedStringArray = ["Default"]
var color_presets: Dictionary[String, Color] = {}
var color_preset_names: PackedStringArray = []
var speed_presets: Dictionary[String, int] = {}
var speed_preset_names: PackedStringArray = []
var delay_presets: Dictionary[String, int] = {}
var delay_preset_names: PackedStringArray = []

var uid_objects: Array[DialogUID] = []
var options: Options = load_options()
var open_file: String = ""
var _is_saved: bool = true


func _init() -> void:
	DisplayServer.window_set_position(options.window_pos)
	DisplayServer.window_set_size(options.window_size)
	DisplayServer.window_set_mode(options.window_mode)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_position(options.window_pos)
			DisplayServer.window_set_size(options.window_size)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		options.window_mode = DisplayServer.window_get_mode()
		save_options()
	if DisplayServer.window_get_mode() != options.window_mode:
		options.window_mode = DisplayServer.window_get_mode()
		if options.window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_position(options.window_pos)
			DisplayServer.window_set_size(options.window_size)
		save_options()
	if DisplayServer.window_get_size() != options.window_size:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
			return
		options.window_size = DisplayServer.window_get_size()
		save_options()
	if DisplayServer.window_get_position() != options.window_pos:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
			return
		options.window_pos = DisplayServer.window_get_position()
		save_options()


func load_options() -> Options:
	var options_: Options = load("user://options.tres")
	if options_ == null:
		options_ = Options.new()
	return options_


func save_options() -> void:
	ResourceSaver.save(options, "user://options.tres")


func set_saved(saved: bool) -> void:
	_is_saved = saved
	get_tree().call_group("editor", "set_saved_state", saved)


func get_saved() -> bool:
	return _is_saved
