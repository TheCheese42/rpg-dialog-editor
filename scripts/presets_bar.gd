extends VSplitContainer

var _selected_name: String = ""
var _generic_preset_editor_scene: PackedScene = preload("res://scenes/generic_preset_editor.tscn")

@onready var generic_preset_grid: GridContainer = $VBoxContainer4/ScrollContainer/GenericPresetGrid
@onready var generic_remove_button: TextureButton = $VBoxContainer4/HBoxContainer/GenericRemoveButton
@onready var generic_up_button: TextureButton = $VBoxContainer4/HBoxContainer/GenericUpButton
@onready var generic_down_button: TextureButton = $VBoxContainer4/HBoxContainer/GenericDownButton
@onready var color_preset_grid: GridContainer = $VBoxContainer/ScrollContainer/ColorPresetGrid
@onready var color_remove_button: TextureButton = $VBoxContainer/HBoxContainer/ColorRemoveButton
@onready var color_up_button: TextureButton = $VBoxContainer/HBoxContainer/ColorUpButton
@onready var color_down_button: TextureButton = $VBoxContainer/HBoxContainer/ColorDownButton
@onready var speed_preset_grid: GridContainer = $VBoxContainer2/ScrollContainer2/SpeedPresetGrid
@onready var speed_remove_button: TextureButton = $VBoxContainer2/HBoxContainer2/SpeedRemoveButton
@onready var speed_up_button: TextureButton = $VBoxContainer2/HBoxContainer2/SpeedUpButton
@onready var speed_down_button: TextureButton = $VBoxContainer2/HBoxContainer2/SpeedDownButton
@onready var delay_preset_grid: GridContainer = $VBoxContainer3/ScrollContainer3/DelayPresetGrid
@onready var delay_remove_button: TextureButton = $VBoxContainer3/HBoxContainer3/DelayRemoveButton
@onready var delay_up_button: TextureButton = $VBoxContainer3/HBoxContainer3/DelayUpButton
@onready var delay_down_button: TextureButton = $VBoxContainer3/HBoxContainer3/DelayDownButton


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	_on_focus_changed($"." as Control)  # Get rid of focus
	_rebuild_ui()


func _on_focus_changed(control: Control) -> void:
	if control in [
		generic_remove_button, generic_up_button, generic_down_button,
		color_remove_button, color_up_button, color_down_button,
		speed_up_button, speed_up_button, speed_up_button,
		delay_down_button, delay_down_button, delay_down_button,
	]:
		return
	generic_remove_button.disabled = true
	color_remove_button.disabled = true
	speed_remove_button.disabled = true
	delay_remove_button.disabled = true
	generic_up_button.disabled = true
	color_up_button.disabled = true
	speed_up_button.disabled = true
	delay_up_button.disabled = true
	generic_down_button.disabled = true
	color_down_button.disabled = true
	speed_down_button.disabled = true
	delay_down_button.disabled = true
	if is_instance_of(control, LineEdit):
		if control.get_parent() == generic_preset_grid:
			generic_remove_button.disabled = false
			generic_up_button.disabled = false
			generic_down_button.disabled = false
		elif control.get_parent() == color_preset_grid:
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


func _open_generic_preset_editor(preset: String) -> void:
	var editor: GenericPresetEditor = _generic_preset_editor_scene.instantiate()
	editor.load_preset(Globals.generic_presets[preset])
	editor.preset_changed.connect(func(new: Dictionary) -> void:
		Globals.generic_presets[preset] = new)
	get_tree().root.add_child(editor)


func _rebuild_ui() -> void:
	for grid: GridContainer in [
		color_preset_grid, speed_preset_grid,
		delay_preset_grid, generic_preset_grid,
	]:
		for child: Control in grid.get_children():
			child.queue_free()

	for preset: String in Globals.generic_preset_names:
		var label := RememberingLineEdit.new()
		label.custom_minimum_size = Vector2(120, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = preset
		generic_preset_grid.add_child(label)
		var button := Button.new()
		button.pressed.connect(_open_generic_preset_editor.bind(preset))
		label.remembering_text_changed.connect(
			func(old: String, new: String) -> void:
				_update_name(
					old, new, Globals.generic_presets, Globals.generic_preset_names
				)
				button.pressed.disconnect(_open_generic_preset_editor)
				button.pressed.connect(_open_generic_preset_editor.bind(new))
		)
		button.custom_minimum_size = Vector2(80, 0)
		button.text = "Edit"
		generic_preset_grid.add_child(button)

	for preset: String in Globals.color_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			Globals.color_presets, Globals.color_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = preset
		color_preset_grid.add_child(label)
		var button := ColorPickerButton.new()
		button.color_changed.connect(_update_value.bind(
			Globals.color_presets, preset,
		))
		button.custom_minimum_size = Vector2(80, 0)
		button.color = Globals.color_presets[preset]
		color_preset_grid.add_child(button)

	for preset: String in Globals.speed_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			Globals.speed_presets, Globals.speed_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = preset
		speed_preset_grid.add_child(label)
		var spin := SpinBox.new()
		spin.value_changed.connect(_update_value.bind(
			Globals.speed_presets, preset,
		))
		spin.custom_minimum_size = Vector2(80, 0)
		spin.max_value = 20000
		spin.value = Globals.speed_presets[preset]
		speed_preset_grid.add_child(spin)

	for preset: String in Globals.delay_preset_names:
		var label := RememberingLineEdit.new()
		label.remembering_text_changed.connect(_update_name.bind(
			Globals.delay_presets, Globals.delay_preset_names,
		))
		label.custom_minimum_size = Vector2(120, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = preset
		delay_preset_grid.add_child(label)
		var spin := SpinBox.new()
		spin.value_changed.connect(_update_value.bind(
			Globals.delay_presets, preset,
		))
		spin.custom_minimum_size = Vector2(80, 0)
		spin.max_value = 20000
		spin.value = Globals.delay_presets[preset]
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
	_on_add_button_pressed(
		Globals.color_presets, Globals.color_preset_names, Color.WHITE
	)


func _on_color_remove_button_pressed() -> void:
	_on_remove_button_pressed(Globals.color_presets, Globals.color_preset_names)


func _on_color_up_button_pressed() -> void:
	_on_up_button_pressed(Globals.color_preset_names)


func _on_color_down_button_pressed() -> void:
	_on_down_button_pressed(Globals.color_preset_names)


func _on_speed_add_button_pressed() -> void:
	_on_add_button_pressed(
		Globals.speed_presets, Globals.speed_preset_names, 100
	)


func _on_speed_remove_button_pressed() -> void:
	_on_remove_button_pressed(Globals.speed_presets, Globals.speed_preset_names)


func _on_speed_up_button_pressed() -> void:
	_on_up_button_pressed(Globals.speed_preset_names)


func _on_speed_down_button_pressed() -> void:
	_on_down_button_pressed(Globals.speed_preset_names)


func _on_delay_add_button_pressed() -> void:
	_on_add_button_pressed(
		Globals.delay_presets, Globals.delay_preset_names, 1000
	)


func _on_delay_remove_button_pressed() -> void:
	_on_remove_button_pressed(Globals.delay_presets, Globals.delay_preset_names)


func _on_delay_up_button_pressed() -> void:
	_on_up_button_pressed(Globals.delay_preset_names)


func _on_delay_down_button_pressed() -> void:
	_on_down_button_pressed(Globals.delay_preset_names)


func _on_generic_add_button_pressed() -> void:
	_on_add_button_pressed(
		Globals.generic_presets,
		Globals.generic_preset_names,
		Globals.DEFAULT_GENERIC_PRESET,
	)
	get_tree().call_group("main_editor", "update_generic_presets")


func _on_generic_remove_button_pressed() -> void:
	if len(Globals.generic_presets) > 1:
		_on_remove_button_pressed(
			Globals.generic_presets, Globals.generic_preset_names
		)
	get_tree().call_group("main_editor", "update_generic_presets")


func _on_generic_up_button_pressed() -> void:
	_on_up_button_pressed(Globals.generic_preset_names)
	get_tree().call_group("main_editor", "update_generic_presets")


func _on_generic_down_button_pressed() -> void:
	_on_down_button_pressed(Globals.generic_preset_names)
	get_tree().call_group("main_editor", "update_generic_presets")
