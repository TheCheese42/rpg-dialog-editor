extends VBoxContainer

@onready var conversation_list: ItemList = $ConversationList
@onready var conversation_remove_button: TextureButton = $HBoxContainer/ConversationRemoveButton
@onready var conversation_up_button: TextureButton = $HBoxContainer/ConversationUpButton
@onready var conversation_down_button: TextureButton = $HBoxContainer/ConversationDownButton


func load_conversations(conversations: PackedStringArray) -> void:
	Globals.conversations = conversations
	_rebuild_ui()


func _rebuild_ui() -> void:
	conversation_list.clear()
	for conversation: String in Globals.conversations:
		conversation_list.add_item(conversation)


func _on_conversation_add_button_pressed() -> void:
	var new_name: String = "New Preset"
	var i: int = 1
	while new_name in Globals.conversations:
		new_name = "New Preset ({0})".format([i])
		i += 1
	Globals.conversations.append(new_name)
	_rebuild_ui()
	conversation_list.select(len(Globals.conversations) - 1)


func _on_conversation_remove_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		Globals.conversations.remove_at(selected[0])
	_rebuild_ui()
	get_tree().call_group("main_editor", "clear")


func _on_conversation_up_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		if selected[0] == 0:
			return
		var swap: String = Globals.conversations[selected[0]]
		Globals.conversations[selected[0]] = (
			Globals.conversations[selected[0] - 1]
		)
		Globals.conversations[selected[0] - 1] = swap
		_rebuild_ui()
		conversation_list.select(selected[0] - 1)


func _on_conversation_down_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		if selected[0] == len(Globals.conversations) - 1:
			return
		var swap: String = Globals.conversations[selected[0]]
		Globals.conversations[selected[0]] = (
			Globals.conversations[selected[0] + 1]
		)
		Globals.conversations[selected[0] + 1] = swap
		_rebuild_ui()
		conversation_list.select(selected[0] + 1)


func _on_conversation_list_item_selected(i: int) -> void:
	get_tree().call_group(
		"main_editor", "load_conversation", Globals.conversations[i]
	)
