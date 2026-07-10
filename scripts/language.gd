class_name Language
extends CanvasLayer

@onready var locale_edit: LineEdit = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/GridContainer/LocaleEdit
@onready var path_edit: LineEdit = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/GridContainer/PathEdit
@onready var found_label: Label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FoundLabel
@onready var not_found_label: Label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NotFoundLabel
@onready var invalid_label: Label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/InvalidLabel


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_confirm_button_pressed() -> void:
	Globals.locale = locale_edit.text
	Globals.relative_path_to_original = path_edit.text
	Globals.set_saved(false)
	queue_free()


func _on_path_edit_text_changed(new_text: String) -> void:
	for label: Label in [found_label, not_found_label, invalid_label]:
		label.visible = false
	if not new_text:
		return
	var path: String = Globals.open_file.path_join(new_text)
	if not FileAccess.file_exists(path):
		not_found_label.visible = true
	else:
		DirAccess.copy_absolute(path, "user://lang_import.tres")
		var dialog: DialogFile = load("user://lang_import.tres")
		DirAccess.remove_absolute("user://lang_import.tres")
		if not dialog:
			invalid_label.visible = true
		else:
			found_label.visible = true
