extends VBoxContainer

@onready var tree: ConversationTree = $Tree
@onready var speaker_button: DragButton = $HBoxContainer2/SpeakerButton
@onready var page_button: DragButton = $HBoxContainer2/PageButton
@onready var choice_button: DragButton = $HBoxContainer2/ChoiceButton
@onready var goto_button: DragButton = $HBoxContainer2/GotoButton
@onready var script_button: DragButton = $HBoxContainer2/ScriptButton
@onready var id_edit: LineEdit = $HBoxContainer/IDEdit
@onready var preset_option: OptionButton = $HBoxContainer/PresetOption
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var h_box_container_2: HBoxContainer = $HBoxContainer2
@onready var empty_hint_label: Label = $EmptyHintLabel

var _conversation: DialogFile.Conversation


func _ready() -> void:
	speaker_button.component = DialogFile.Speaker.new()
	page_button.component = DialogFile.Page.new()
	choice_button.component = DialogFile.Choice.new()
	goto_button.component = DialogFile.Goto.new()
	script_button.component = DialogFile.Script_.new()
	clear()


func load_conversation(conversation: DialogFile.Conversation) -> void:
	_conversation = conversation
	h_box_container.visible = true
	h_box_container_2.visible = true
	empty_hint_label.visible = false
	id_edit.text = str(_conversation.id)
	preset_option.selected = Globals.generic_preset_names.find(
		_conversation.preset
	) if _conversation.preset in Globals.generic_preset_names else 0
	tree.load_conversation(_conversation)
	update_generic_presets()


func clear() -> void:
	_conversation = null
	h_box_container.visible = false
	h_box_container_2.visible = false
	empty_hint_label.visible = true
	tree.clear_conversation()


func update_generic_presets() -> void:
	preset_option.clear()
	for preset: String in Globals.generic_preset_names:
		preset_option.add_item(preset)
	preset_option.selected = Globals.generic_preset_names.find(
		_conversation.preset
	) if _conversation.preset in Globals.generic_preset_names else 0


func _on_id_edit_text_submitted(new_text: String) -> void:
	if new_text == str(_conversation.id):
		return
	if not _conversation.id.set_id(new_text):
		id_edit.text = str(_conversation.id)
	else:
		get_tree().call_group("conversations_list", "rebuild_ui")


func _on_id_edit_focus_exited() -> void:
	_on_id_edit_text_submitted(id_edit.text)


func _on_preset_option_item_selected(index: int) -> void:
	_conversation.preset = Globals.generic_preset_names[index]
