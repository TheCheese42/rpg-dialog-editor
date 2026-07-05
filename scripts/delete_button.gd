extends Button


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if is_instance_of(data, TreeItem):
		return true
	return false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if is_instance_of(data, TreeItem):
		var component: DialogFile.DialogComponent = (
			data as TreeItem).get_metadata(0)
		component.unregister()
		(data as TreeItem).free()


func _on_pressed() -> void:
	get_tree().call_group("conversation_tree", "free_selected")
