extends VBoxContainer

@onready var tree: ConversationTree = $Tree
@onready var speaker_button: DragButton = $HBoxContainer2/SpeakerButton
@onready var page_button: DragButton = $HBoxContainer2/PageButton
@onready var choice_button: DragButton = $HBoxContainer2/ChoiceButton
@onready var goto_button: DragButton = $HBoxContainer2/GotoButton
@onready var script_button: DragButton = $HBoxContainer2/ScriptButton


func _ready() -> void:
	speaker_button.component = DialogFile.Speaker.new()
	page_button.component = DialogFile.Page.new()
	choice_button.component = DialogFile.Choice.new()
	goto_button.component = DialogFile.Goto.new()
	script_button.component = DialogFile.Script_.new()
