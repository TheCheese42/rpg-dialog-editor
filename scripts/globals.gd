extends Node

var DEFAULT_GENERIC_PRESET: Dictionary = {
	"color": Color.WHITE,
	"speed": 100,
	"wave_intensity": 0,
	"wave_speed": 0,
	"shake_intensity": 0,
	"shake_speed": 0,
}
var locale: String
var relative_path_to_original: String
var conversations: Array[DialogFile.Conversation]
var generic_presets: Dictionary[String, Dictionary]
var generic_preset_names: PackedStringArray
var color_presets: Dictionary[String, Color]
var color_preset_names: PackedStringArray
var speed_presets: Dictionary[String, int]
var speed_preset_names: PackedStringArray
var delay_presets: Dictionary[String, int]
var delay_preset_names: PackedStringArray

var uid_objects: Array[DialogUID]
var options: Options = load_options()
var _open_file: String
var _is_saved: bool = true
var original_conversation_dicts: Array[Dictionary]


func _init() -> void:
	DisplayServer.window_set_position(options.window_pos)
	DisplayServer.window_set_size(options.window_size)
	DisplayServer.window_set_mode(options.window_mode)


func _ready() -> void:
	reset(false)


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


func reset(should_set_saved: bool = true) -> void:
	locale = ""
	relative_path_to_original = ""
	conversations = []
	generic_presets = {"Default": DEFAULT_GENERIC_PRESET}
	generic_preset_names = ["Default"]
	color_presets = {}
	color_preset_names = []
	speed_presets = {}
	speed_preset_names = []
	delay_presets = {}
	delay_preset_names = []
	uid_objects = []
	set_open_file("")
	if should_set_saved:
		set_saved(true)
	original_conversation_dicts = []


func refresh_language() -> void:
	original_conversation_dicts = []
	if relative_path_to_original:
		var path: String = get_open_file().get_base_dir().path_join(
			relative_path_to_original
		)
		if FileAccess.file_exists(path):
			DirAccess.copy_absolute(path, "user://lang_import.tres")
			var dialog: DialogFile = load("user://lang_import.tres")
			DirAccess.remove_absolute("user://lang_import.tres")
			if dialog:
				for dict: Dictionary in dialog.conversations:
					var exists: bool = false
					for conv: DialogFile.Conversation in conversations:
						if str(conv.id) == dict["id"]:
							exists = true
					if not exists:
						conversations.append(
							DialogFile.Conversation.from_dict(dict)
						)
				original_conversation_dicts = dialog.conversations
				get_tree().call_group("conversations_list", "rebuild_ui")


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


func set_open_file(file: String) -> void:
	_open_file = file
	DisplayServer.window_set_title(
		"RPG Dialog Editor - Editing {0}".format([file])
	)


func get_open_file() -> String:
	return _open_file
