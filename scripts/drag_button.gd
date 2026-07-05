class_name DragButton
extends Button

var component: DialogFile.DialogComponent


func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(duplicate() as Button)
	return component
