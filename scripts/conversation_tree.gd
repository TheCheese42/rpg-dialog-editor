class_name ConversationTree
extends Tree

var _conversation: DialogFile.Conversation


func _ready() -> void:
	create_item().set_metadata(0, DialogFile.Conversation.new())


func _get_drag_data(at_position: Vector2) -> Variant:
	var item := get_item_at_position(at_position)
	var next_child: TreeItem = get_next_selected(null)
	var preview := VBoxContainer.new()
	while next_child:
		if get_root() == next_child.get_parent():
			var label := Label.new()
			label.text = next_child.get_text(0)
			preview.add_child(label)
		next_child = get_next_selected(next_child)
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
	if is_instance_of(data, DialogFile.DialogComponent):
		# Dragged from button
		var component: DialogFile.DialogComponent = data
		data = create_item()
		apply_component_to_item(data as TreeItem, component)
	var item: TreeItem = data
	var drop_section := get_drop_section_at_position(at_position)
	if drop_section == -100:
		return
	var other_item := get_item_at_position(at_position)
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


func load_conversation(conversation: DialogFile.Conversation) -> void:
	_conversation = conversation
	visible = true


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
