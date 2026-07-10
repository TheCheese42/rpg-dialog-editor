class_name PageEditor
extends CanvasLayer

signal confirmed(
	text: String,
	interjection_speaker: String,
	interjection_text: String,
	preset: String,
)

@onready var text_edit: TextEdit = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TextEdit
@onready var interjection_speaker_edit: LineEdit = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/InterjectionSpeakerEdit
@onready var interjection_text_edit: LineEdit = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/InterjectionTextEdit
@onready var presets_option: OptionButton = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PresetsOption


func _ready() -> void:
	text_edit.grab_focus()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("submit_page"):
		_on_confirm_button_pressed()


func load_text(
	text: String,
	int_speaker: String,
	int_text: String,
	preset: String,
) -> void:
	text_edit.text = text
	interjection_speaker_edit.text = int_speaker
	interjection_text_edit.text = int_text
	presets_option.clear()
	presets_option.add_item("")
	var preset_idx: int = 0
	var i: int = 0
	for global_preset: String in Globals.generic_presets:
		i += 1
		presets_option.add_item(global_preset)
		if preset == global_preset:
			preset_idx = i
	presets_option.select(preset_idx)


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_confirm_button_pressed() -> void:
	emit_signal(
		"confirmed",
		text_edit.text,
		interjection_speaker_edit.text,
		interjection_text_edit.text,
		presets_option.text,
	)
	queue_free()
