extends VBoxContainer

@onready var conversation_list: ItemList = $ConversationList
@onready var conversation_remove_button: TextureButton = $HBoxContainer/ConversationRemoveButton
@onready var conversation_up_button: TextureButton = $HBoxContainer/ConversationUpButton
@onready var conversation_down_button: TextureButton = $HBoxContainer/ConversationDownButton


func load_conversations(conversations: PackedStringArray) -> void:
	Globals.conversations = conversations
	rebuild_ui()


func rebuild_ui() -> void:
	conversation_list.clear()
	for conversation: DialogFile.Conversation in Globals.conversations:
		conversation_list.add_item(str(conversation.id))


func _on_conversation_add_button_pressed() -> void:
	var conversation := DialogFile.Conversation.new()
	var new_uid: String = "New Conversation"
	var i: int = 1
	while true:
		if conversation.id.set_id(new_uid):
			break
		new_uid = "New Conversation ({0})".format([i])
		i += 1
	Globals.conversations.append(conversation)
	rebuild_ui()
	conversation_list.select(len(Globals.conversations) - 1)
	get_tree().call_group(
		"main_editor", "load_conversation", Globals.conversations[
			len(Globals.conversations) - 1])


func _on_conversation_remove_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		Globals.conversations[selected[0]].unregister()
		Globals.conversations.remove_at(selected[0])
	rebuild_ui()
	get_tree().call_group("main_editor", "clear")


func _on_conversation_up_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		if selected[0] == 0:
			return
		var swap: DialogFile.Conversation = Globals.conversations[selected[0]]
		Globals.conversations[selected[0]] = (
			Globals.conversations[selected[0] - 1]
		)
		Globals.conversations[selected[0] - 1] = swap
		rebuild_ui()
		conversation_list.select(selected[0] - 1)


func _on_conversation_down_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		if selected[0] == len(Globals.conversations) - 1:
			return
		var swap: DialogFile.Conversation = Globals.conversations[selected[0]]
		Globals.conversations[selected[0]] = (
			Globals.conversations[selected[0] + 1]
		)
		Globals.conversations[selected[0] + 1] = swap
		rebuild_ui()
		conversation_list.select(selected[0] + 1)


func _on_conversation_list_item_selected(i: int) -> void:
	get_tree().call_group(
		"main_editor", "load_conversation", Globals.conversations[i]
	)
