class_name PageEditor
extends CanvasLayer

signal text_changed(text: String)

@onready var text_edit: TextEdit = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TextEdit


func _ready() -> void:
	text_edit.grab_focus()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("submit_page"):
		_on_confirm_button_pressed()


func load_text(text: String) -> void:
	text_edit.text = text


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_confirm_button_pressed() -> void:
	emit_signal("text_changed", text_edit.text)
	queue_free()
