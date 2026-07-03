class_name RememberingLineEdit
extends LineEdit

signal remembering_text_changed(old_text: String, new_text: String)

var _text: String


func _ready() -> void:
	_text = text
	text_changed.connect(_text_changed)


func _text_changed(new_text: String) -> void:
	emit_signal("remembering_text_changed", _text, new_text)
	_text = new_text
