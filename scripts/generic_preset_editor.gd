class_name GenericPresetEditor
extends CanvasLayer

signal preset_changed(values: Dictionary)

var _values: Dictionary

@onready var color_picker_button: ColorPickerButton = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorPickerButton
@onready var speed_spin: SpinBox = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/SpeedSpin
@onready var wave_intensity_spin: SpinBox = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/WaveIntensitySpin
@onready var wave_speed_spin: SpinBox = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/WaveSpeedSpin
@onready var shake_intensity_spin: SpinBox = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/ShakeIntensitySpin
@onready var shake_speed_spin: SpinBox = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer/ShakeSpeedSpin


func _ready() -> void:
	color_picker_button.color = _values["color"]
	speed_spin.value = _values["speed"]
	wave_intensity_spin.value = _values["wave_intensity"]
	wave_speed_spin.value = _values["wave_speed"]
	shake_intensity_spin.value = _values["shake_intensity"]
	shake_speed_spin.value = _values["shake_speed"]


func load_preset(values: Dictionary) -> void:
	_values = values


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_confirm_button_pressed() -> void:
	emit_signal("preset_changed", {
		"color": color_picker_button.color,
		"speed": speed_spin.value,
		"wave_intensity": wave_intensity_spin.value,
		"wave_speed": wave_speed_spin.value,
		"shake_intensity": shake_intensity_spin.value,
		"shake_speed": shake_speed_spin.value,
	})
	queue_free()
