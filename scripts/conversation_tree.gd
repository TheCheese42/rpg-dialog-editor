class_name ConversationTree
extends Tree

signal conversation_changed(conversation: DialogFile.Conversation)

@onready var speaker_button: DragButton = $"../HBoxContainer2/SpeakerButton"
@onready var page_button: DragButton = $"../HBoxContainer2/PageButton"
@onready var choice_button: DragButton = $"../HBoxContainer2/ChoiceButton"
@onready var goto_button: DragButton = $"../HBoxContainer2/GotoButton"
@onready var script_button: DragButton = $"../HBoxContainer2/ScriptButton"

var _conversation: DialogFile.Conversation


func _ready() -> void:
	clear()


func _get_drag_data(at_position: Vector2) -> Variant:
	var item := get_item_at_position(at_position)
	if not item:
		return
	var preview := Button.new()
	preview.text = item.get_text(0)
	preview.icon = item.get_icon(0)
	set_drag_preview(preview)
	return item


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	drop_mode_flags = (
		DropModeFlags.DROP_MODE_INBETWEEN | DropModeFlags.DROP_MODE_ON_ITEM
	)
	var drop_section := get_drop_section_at_position(at_position)
	var other_item: TreeItem
	if drop_section == -100:
		other_item = get_root()
	else:
		other_item = get_item_at_position(at_position)
	var component: DialogFile.DialogComponent
	if is_instance_of(data, DialogFile.DialogComponent):
		# Dragged from button
		component = data
	elif is_instance_of(data, TreeItem):
		component = (data as TreeItem).get_metadata(0)
	else:
		return false
	if other_item == data:
		return false
	var parent: DialogFile.DialogComponent = (
		other_item.get_metadata(0)
	)
	if drop_section in [-1, 1]:
		parent = other_item.get_parent().get_metadata(0)
	if (
		(is_instance_of(parent, DialogFile.Conversation)
		or is_instance_of(parent, DialogFile.Speaker)
		or is_instance_of(parent, DialogFile.Choice))
		and is_instance_of(component, DialogFile.ConversationContent)
	) or (
		is_instance_of(parent, DialogFile.Page)
		and is_instance_of(component, DialogFile.Choice)
	):
		return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var item: TreeItem
	var component: DialogFile.DialogComponent
	if is_instance_of(data, DialogFile.DialogComponent):
		# Dragged from button
		component = data
		item = get_root().create_child()
		apply_component_to_item(item, component)
		item.set_editable(0, true)
	else:
		item = data
		component = item.get_metadata(0)
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	if other_item == null:
		other_item = get_root()
	var parent: TreeItem = item.get_parent()
	var parent_component: DialogFile.DialogComponent = parent.get_metadata(0)
	var parent_contents: Array = (parent_component.get("contents"))
	if not is_instance_of(data, DialogFile.DialogComponent):
		# This if statement is the last resort solution to prevent an error
		# from showing up. Do not try to investigate.
		parent_contents.erase(component)
	match drop_section:
		-1:  # Previous sibling
			if other_item:
				item.move_before(other_item)
		1:  # Next sibling
			if other_item:
				item.move_after(other_item)
		2:  # First child
			item.get_parent().remove_child(item)
			other_item.add_child(item)
			if other_item.get_child(0) != item:
				item.move_before(other_item.get_child(0))
		0:  # Last child
			item.get_parent().remove_child(item)
			other_item.add_child(item)

	# Update model data
	var new_parent: TreeItem = item.get_parent()
	var new_parent_component: DialogFile.DialogComponent = (
		new_parent.get_metadata(0))
	var new_parent_contents: Array = (new_parent_component.get("contents"))
	var pos: int = 0
	for i: int in new_parent.get_child_count():
		if new_parent.get_child(i) == item:
			pos = i
	new_parent_contents.insert(pos, component)

	emit_signal("conversation_changed", _conversation)


func _on_multi_selected(item: TreeItem, _column: int, selected: bool) -> void:
	if not selected:
		return
	_update_children_recursively(get_root(), true)
	var component: DialogFile.DialogComponent = item.get_metadata(0)
	if is_instance_of(component, DialogFile.Speaker):
		item.set_text(0, (component as DialogFile.Speaker).name)
	elif is_instance_of(component, DialogFile.Page):
		item.set_text(0, str((component as DialogFile.Page).id))
	elif is_instance_of(component, DialogFile.Choice):
		item.set_text(0, (component as DialogFile.Choice).text)
	elif is_instance_of(component, DialogFile.Goto):
		item.set_text(0, (component as DialogFile.Goto).target_id)
	elif is_instance_of(component, DialogFile.Script_):
		item.set_text(0, (component as DialogFile.Script_).script_id)


func _on_item_edited() -> void:
	_update_children_recursively(get_root())


func _on_empty_clicked(_click_position: Vector2, _mouse_button_index: int) -> void:
	var item: TreeItem = null
	while true:
		item = get_next_selected(item)
		if not item:
			break
		item.set_text(0, str(item.get_metadata(0)))
	deselect_all()


func load_conversation(conversation: DialogFile.Conversation) -> void:
	clear_conversation()
	_conversation = conversation
	_populate_tree(_conversation)
	visible = true


func clear_conversation() -> void:
	clear()
	_conversation = null
	visible = false


func free_selected() -> void:
	var selected := get_selected()
	if selected:
		var component: DialogFile.DialogComponent = selected.get_metadata(0)
		component.unregister()
		selected.free()


func apply_component_to_item(
	item: TreeItem,
	component: DialogFile.DialogComponent,
) -> void:
	item.set_metadata(0, component)
	item.set_text(0, str(component))
	if is_instance_of(component, DialogFile.Speaker):
		item.set_icon(0, speaker_button.icon)
	elif is_instance_of(component, DialogFile.Page):
		item.set_icon(0, page_button.icon)
	elif is_instance_of(component, DialogFile.Choice):
		item.set_icon(0, choice_button.icon)
	elif is_instance_of(component, DialogFile.Goto):
		item.set_icon(0, goto_button.icon)
	elif is_instance_of(component, DialogFile.Script_):
		item.set_icon(0, script_button.icon)


func _populate_tree(
	component: DialogFile.DialogComponent,
	parent: TreeItem = null,
) -> void:
	var item: TreeItem
	if parent:
		item = parent.create_child()
	else:
		item = create_item()
	item.set_editable(0, true)
	apply_component_to_item(item, component)
	if component.get("contents"):
		var contents: Array = component.get("contents")
		for content: DialogFile.DialogComponent in contents:
			_populate_tree(content, item)


func _update_children_recursively(
	item: TreeItem,
	only_reset_text: bool = false,
) -> void:
	for child: TreeItem in item.get_children():
		_update_children_recursively(child)
		var component: DialogFile.DialogComponent = child.get_metadata(0)
		if child.get_text(0) == str(component):
			# Nothing changed
			continue
		if not only_reset_text:
			if is_instance_of(component, DialogFile.Speaker):
				(component as DialogFile.Speaker).name = child.get_text(0)
			elif is_instance_of(component, DialogFile.Page):
				(component as DialogFile.Page).id.set_id(child.get_text(0))
			elif is_instance_of(component, DialogFile.Choice):
				(component as DialogFile.Choice).text = child.get_text(0)
			elif is_instance_of(component, DialogFile.Goto):
				(component as DialogFile.Goto).target_id = child.get_text(0)
			elif is_instance_of(component, DialogFile.Script_):
				(component as DialogFile.Script_).script_id = child.get_text(0)
		child.set_text(0, str(component))
