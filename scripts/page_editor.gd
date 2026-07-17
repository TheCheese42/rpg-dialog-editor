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
@onready var preview_margin: MarginContainer = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/PreviewMargin

var _dialog_box_scene: PackedScene = preload("res://addons/rpg_dialog_printer/dialog_box.tscn")
var _conversation: DialogFile.Conversation


func init(conversation: DialogFile.Conversation) -> void:
	_conversation = conversation


func _ready() -> void:
	text_edit.grab_focus()
	await get_tree().create_timer(0.0).timeout
	# Delete newline inserted by ctrl+space shortcut
	text_edit.text = text_edit.text.rstrip(" \n")
	text_edit.text_changed.connect(_update_preview)
	interjection_text_edit.text_changed.connect(
		func(_text: String) -> void: await _update_preview()
	)
	await _update_preview()


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


func _on_preview_button_pressed() -> void:
	await _update_preview(false)


func _update_preview(instant: bool = true) -> void:
	for child: Node in preview_margin.get_children():
		child.queue_free()
	var dialog_box: DialogBox = _dialog_box_scene.instantiate()
	preview_margin.add_child(dialog_box)
	#await get_tree().process_frame
	dialog_box.init(
		_conversation,
		Globals.generic_presets,
		Globals.color_presets,
		Globals.speed_presets,
		Globals.delay_presets,
		{},
	)
	var page := DialogFile.Page.new()
	page.text = text_edit.text
	var interjection := DialogFile.Interjection.new()
	interjection.name = ""  # We don't have the portrait anyway
	interjection.text = interjection_text_edit.text
	page.interjection = interjection
	if instant:
		dialog_box.skip_to_end()
	await dialog_box.execute_page(page, SpeakerMeta.new(
		"", null, null, preview_margin.theme.default_font,
		preview_margin.theme.default_font_size,
	))
	page.unregister()
