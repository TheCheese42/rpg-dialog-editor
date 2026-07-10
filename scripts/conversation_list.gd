extends VBoxContainer

@onready var conversation_list: ItemList = $ConversationList
@onready var conversation_remove_button: TextureButton = $HBoxContainer/ConversationRemoveButton
@onready var conversation_up_button: TextureButton = $HBoxContainer/ConversationUpButton
@onready var conversation_down_button: TextureButton = $HBoxContainer/ConversationDownButton


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("delete"):
		if conversation_list.has_focus():
			_on_conversation_remove_button_pressed()


func rebuild_ui() -> void:
	conversation_list.clear()
	for conversation: DialogFile.Conversation in Globals.conversations:
		var idx: int = conversation_list.add_item(str(conversation.id))
		if Globals.original_conversation_dicts:
			var matching: Dictionary = {}
			for dict: Dictionary in Globals.original_conversation_dicts:
				if str(conversation.id) == dict["id"]:
					matching = dict
			if not matching:
				conversation_list.set_item_icon(
					idx, preload("res://assets/icons/trash-2.svg")
				)
				conversation_list.set_item_tooltip(
					idx, "Conversation doesn't exist in original.\n" +
					"Double click to delete."
				)
				conversation_list.set_item_metadata(idx, "delete")
			elif hash(matching) != conversation.original_hash:
				conversation_list.set_item_icon(
					idx, preload("res://assets/icons/edit-3.svg")
				)
				conversation_list.set_item_tooltip(
					idx, "Original conversation was modified.\n" +
					"Double click to confirm the up-to-dateness."
				)
				conversation_list.set_item_metadata(
					idx, ["update_hash", hash(matching)]
				)


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
	Globals.set_saved(false)


func _on_conversation_remove_button_pressed() -> void:
	var selected := conversation_list.get_selected_items()
	if selected:
		Globals.conversations[selected[0]].unregister()
		Globals.conversations.remove_at(selected[0])
		rebuild_ui()
		get_tree().call_group("main_editor", "clear")
		Globals.set_saved(false)


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
		Globals.set_saved(false)


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
		Globals.set_saved(false)


func _on_conversation_list_item_selected(i: int) -> void:
	get_tree().call_group(
		"main_editor", "load_conversation", Globals.conversations[i]
	)


func _on_conversation_list_item_activated(index: int) -> void:
	var meta: Variant = conversation_list.get_item_metadata(index)
	if meta is String and meta == "delete":
		Globals.conversations.remove_at(index)
		Globals.set_saved(false)
		rebuild_ui()
	elif meta is Array and len(meta as Array) > 0:
		if (meta as Array)[0] == "update_hash" and len(meta as Array) > 1:
			Globals.conversations[index].original_hash = (meta as Array)[1]
			rebuild_ui()
			Globals.set_saved(false)
