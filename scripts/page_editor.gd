extends CanvasLayer

signal text_changed(text: String)

@onready var text_edit: TextEdit = $ColorRect/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TextEdit


func _ready() -> void:
	text_edit.grab_focus()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("submit_page"):
		emit_signal("text_changed", text_edit.text)
