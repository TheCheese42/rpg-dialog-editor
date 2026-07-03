extends VBoxContainer

var _color_presets: Dictionary[String, Color] = {}
var _color_preset_names: PackedStringArray = []
var _speed_presets: Dictionary[String, int] = {}
var _speed_preset_names: PackedStringArray = []
var _delay_presets: Dictionary[String, int] = {}
var _delay_preset_names: PackedStringArray = []
var _selected_name: String = ""

@onready var color_preset_grid: GridContainer = $ColorPresetGrid
@onready var color_add_button: TextureButton = $HBoxContainer/ColorAddButton
@onready var color_remove_button: TextureButton = $HBoxContainer/ColorRemoveButton
@onready var color_up_button: TextureButton = $HBoxContainer/ColorUpButton
@onready var color_down_button: TextureButton = $HBoxContainer/ColorDownButton
@onready var speed_preset_grid: GridContainer = $SpeedPresetGrid
@onready var speed_add_button: TextureButton = $HBoxContainer2/SpeedAddButton
@onready var speed_remove_button: TextureButton = $HBoxContainer2/SpeedRemoveButton
@onready var speed_up_button: TextureButton = $HBoxContainer2/SpeedUpButton
@onready var speed_down_button: TextureButton = $HBoxContainer2/SpeedDownButton
@onready var delay_preset_grid: GridContainer = $DelayPresetGrid
@onready var delay_add_button: TextureButton = $HBoxContainer3/DelayAddButton
@onready var delay_remove_button: TextureButton = $HBoxContainer3/DelayRemoveButton
@onready var delay_up_button: TextureButton = $HBoxContainer3/DelayUpButton
@onready var delay_down_button: TextureButton = $HBoxContainer3/DelayDownButton


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	color_remove_button.disabled = true
	speed_remove_button.disabled = true
	delay_remove_button.disabled = true
	color_up_button.disabled = true
	speed_up_button.disabled = true
	delay_up_button.disabled = true
	color_down_button.disabled = true
	speed_down_button.disabled = true
	delay_down_button.disabled = true


func load_presets(
	color_presets: Dictionary[String, Color],
	speed_presets: Dictionary[String, int],
	delay_presets: Dictionary[String, int],
) -> void:
	_color_presets = color_presets
	_color_preset_names = color_presets.keys()
	_speed_presets = speed_presets
	_speed_preset_names = speed_presets.keys()
	_delay_presets = delay_presets
	_delay_preset_names = delay_presets.keys()
	_rebuild_ui()


func _on_focus_changed(control: Control) -> void:
	if control in [
		color_remove_button, speed_remove_button, delay_remove_button,
		color_up_button, speed_up_button, delay_up_button,
		color_down_button, speed_down_button, delay_down_button,
	]:
		return
	color_remove_button.disabled = true
	speed_remove_button.disabled = true
	delay_remove_button.disabled = true
	color_up_button.disabled = true
	speed_up_button.disabled = true
	delay_up_button.disabled = true
	color_down_button.disabled = true
	speed_down_button.disabled = true
	delay_down_button.disabled = true
	if is_instance_of(control, LineEdit):
		if control.get_parent() == color_preset_grid:
			color_remove_button.disabled = false
			color_up_button.disabled = false
			color_down_button.disabled = false
		elif control.get_parent() == speed_preset_grid:
			speed_remove_button.disabled = false
			speed_up_button.disabled = false
			speed_down_button.disabled = false
		elif control.get_parent() == delay_preset_grid:
			delay_remove_button.disabled = false
			delay_up_button.disabled = false
			delay_down_button.disabled = false
		_selected_name = (control as LineEdit).text


func _update_name(
	old: String,
	new: String,
	presets: Dictionary,
	preset_names: PackedStringArray,
) -> void:
	preset_names[preset_names.find(old)] = new
	presets[new] = presets[old]
	presets.erase(old)


func _update_value(
	new: Variant,
	presets: Dictionary,
	name_: String,
) -> void:
	presets[name_] = new


func _rebuild_ui() -> void:
	for grid: GridContainer in [
		color_preset_grid, speed_preset_grid, delay_preset_grid
	]:
		for child: Control in grid.get_children():
			child.queue_free()

	for preset: String in _color_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			_color_presets, _color_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.text = preset
		color_preset_grid.add_child(label)
		var button := ColorPickerButton.new()
		button.color_changed.connect(_update_value.bind(
			_color_presets, preset,
		))
		button.custom_minimum_size = Vector2(80, 0)
		button.color = _color_presets[preset]
		color_preset_grid.add_child(button)

	for preset: String in _speed_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			_speed_presets, _speed_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.text = preset
		speed_preset_grid.add_child(label)
		var spin := SpinBox.new()
		spin.value_changed.connect(_update_value.bind(
			_speed_presets, preset,
		))
		spin.custom_minimum_size = Vector2(80, 0)
		spin.max_value = 20000
		spin.value = _speed_presets[preset]
		speed_preset_grid.add_child(spin)

	for preset: String in _delay_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			_delay_presets, _delay_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.text = preset
		delay_preset_grid.add_child(label)
		var spin := SpinBox.new()
		spin.value_changed.connect(_update_value.bind(
			_delay_presets, preset,
		))
		spin.custom_minimum_size = Vector2(80, 0)
		spin.max_value = 20000
		spin.value = _delay_presets[preset]
		delay_preset_grid.add_child(spin)


func _on_add_button_pressed(
	presets: Dictionary,
	preset_names: PackedStringArray,
	default: Variant,
) -> void:
	var new_name: String = "New Preset"
	var i: int = 1
	while new_name in preset_names:
		new_name = "New Preset ({0})".format([i])
		i += 1
	preset_names.append(new_name)
	presets[new_name] = default
	_rebuild_ui()


func _on_remove_button_pressed(
	presets: Dictionary,
	presets_names: PackedStringArray
) -> void:
	presets.erase(_selected_name)
	presets_names.erase(_selected_name)
	_on_focus_changed($"." as Control)  # Get rid of focus
	_rebuild_ui()


func _on_up_button_pressed(presets_names: PackedStringArray) -> void:
	var swap: String = _selected_name
	var idx: int = presets_names.find(swap)
	if idx == 0:
		return
	presets_names[idx] = presets_names[idx - 1]
	presets_names[idx - 1] = swap
	_rebuild_ui()


func _on_down_button_pressed(presets_names: PackedStringArray) -> void:
	var swap: String = _selected_name
	var idx: int = presets_names.find(swap)
	if idx == len(presets_names) - 1:
		return
	presets_names[idx] = presets_names[idx + 1]
	presets_names[idx + 1] = swap
	_rebuild_ui()


func _on_color_add_button_pressed() -> void:
	_on_add_button_pressed(_color_presets, _color_preset_names, Color.WHITE)


func _on_color_remove_button_pressed() -> void:
	_on_remove_button_pressed(_color_presets, _color_preset_names)


func _on_color_up_button_pressed() -> void:
	_on_up_button_pressed(_color_preset_names)


func _on_color_down_button_pressed() -> void:
	_on_down_button_pressed(_color_preset_names)


func _on_speed_add_button_pressed() -> void:
	_on_add_button_pressed(_speed_presets, _speed_preset_names, 100)


func _on_speed_remove_button_pressed() -> void:
	_on_remove_button_pressed(_speed_presets, _speed_preset_names)


func _on_speed_up_button_pressed() -> void:
	_on_up_button_pressed(_speed_preset_names)


func _on_speed_down_button_pressed() -> void:
	_on_down_button_pressed(_speed_preset_names)


func _on_delay_add_button_pressed() -> void:
	_on_add_button_pressed(_delay_presets, _delay_preset_names, 1000)


func _on_delay_remove_button_pressed() -> void:
	_on_remove_button_pressed(_delay_presets, _delay_preset_names)


func _on_delay_up_button_pressed() -> void:
	_on_up_button_pressed(_delay_preset_names)


func _on_delay_down_button_pressed() -> void:
	_on_down_button_pressed(_delay_preset_names)
