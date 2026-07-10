extends Control

@onready var save_button: Button = $MarginContainer2/HBoxContainer/SaveButton

var language_scene: PackedScene = load("res://scenes/language.tscn")


func set_saved_state(state: bool) -> void:
	if state:
		save_button.text = save_button.text.trim_suffix(" *")
	else:
		save_button.text = save_button.text.trim_suffix(" *") + " *"


func _on_close_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Globals.get_saved():
			get_tree().quit()
		else:
			var dialog := ConfirmationDialog.new()
			dialog.title = "Unsaved Changes"
			dialog.dialog_text = (
				"You still have unsaved changes.\n\n" +
				"Are you sure you want to quit?"
			)
			dialog.confirmed.connect(get_tree().quit)
			await get_tree().create_timer(0.0).timeout
			add_child(dialog)
			dialog.popup_centered()


func _on_open_button_pressed() -> void:
	if Globals.get_saved():
		await _open_file_dialog()
	else:
		var dialog := ConfirmationDialog.new()
		dialog.title = "Unsaved Changes"
		dialog.dialog_text = (
			"You still have unsaved changes.\n\n" +
			"Are you sure you want to open another file?"
		)
		dialog.confirmed.connect(_open_file_dialog)
		await get_tree().create_timer(0.0).timeout
		add_child(dialog)
		dialog.popup_centered()


func _open_file_dialog() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.use_native_dialog = true
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_dir = Globals.options.last_working_dir
	file_dialog.add_filter("*.dia", "Dialog Resource")
	file_dialog.file_selected.connect(_open_file)
	await get_tree().create_timer(0.0).timeout
	add_child(file_dialog)
	file_dialog.popup_file_dialog()


func _open_file(path: String) -> void:
	Globals.options.last_working_dir = path.get_base_dir()
	DirAccess.copy_absolute(path, "user://import.tres")
	var dialog: DialogFile = load("user://import.tres")
	DirAccess.remove_absolute("user://import.tres")
	if not dialog:
		var err_dialog := AcceptDialog.new()
		err_dialog.title = "Unable to open file"
		err_dialog.dialog_text = (
			"The selected file could not be opened " +
			"or is not a valid dialog file."
		)
		await get_tree().create_timer(0.0).timeout
		add_child(err_dialog)
		err_dialog.popup_centered()
		return
	Globals.uid_objects.clear()
	Globals.generic_presets = dialog.presets
	Globals.generic_preset_names = dialog.presets.keys()
	Globals.color_presets = dialog.color_presets
	Globals.color_preset_names = dialog.color_presets.keys()
	Globals.speed_presets = dialog.speed_presets
	Globals.speed_preset_names = dialog.speed_presets.keys()
	Globals.delay_presets = dialog.delay_presets
	Globals.delay_preset_names = dialog.delay_presets.keys()
	Globals.conversations.clear()
	Globals.open_file = path
	Globals.set_saved(true)
	for dict: Dictionary in dialog.conversations:
		Globals.conversations.append(DialogFile.Conversation.from_dict(dict))
	get_tree().call_group("main_editor", "clear")
	get_tree().call_group("conversations_list", "rebuild_ui")
	get_tree().call_group("presets_bar", "rebuild_ui")


func _on_save_button_pressed() -> void:
	if not Globals.open_file:
		await _on_save_as_button_pressed()
	else:
		_save_file(Globals.open_file)


func _on_save_as_button_pressed() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.use_native_dialog = true
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.current_dir = Globals.options.last_working_dir
	file_dialog.add_filter("*.dia", "Dialog Resource")
	file_dialog.file_selected.connect(_save_file)
	await get_tree().create_timer(0.0).timeout
	add_child(file_dialog)
	file_dialog.popup_file_dialog()


func _save_file(path: String) -> void:
	Globals.options.last_working_dir = path.get_base_dir()
	var dialog := DialogFile.new()
	for generic: String in Globals.generic_preset_names:
		dialog.presets[generic] = Globals.generic_presets[generic]
	for color: String in Globals.color_preset_names:
		dialog.color_presets[color] = Globals.color_presets[color]
	for speed: String in Globals.speed_preset_names:
		dialog.speed_presets[speed] = Globals.speed_presets[speed]
	for delay: String in Globals.delay_preset_names:
		dialog.delay_presets[delay] = Globals.delay_presets[delay]
	for conversation: DialogFile.Conversation in Globals.conversations:
		dialog.conversations.append(conversation.to_dict())
	ResourceSaver.save(dialog, "user://export.tres")
	DirAccess.rename_absolute("user://export.tres", path)
	DirAccess.remove_absolute("user://export.tres")
	Globals.set_saved(true)
	Globals.open_file = path


func _on_language_button_pressed() -> void:
	var dialog: Language = language_scene.instantiate()
	get_tree().root.add_child(dialog)
