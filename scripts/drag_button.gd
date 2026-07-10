class_name DragButton
extends Button

var component: DialogFile.DialogComponent


func new_component() -> DialogFile.DialogComponent:
	var component_: DialogFile.DialogComponent = component.duplicate(true)
	if component_.get("id"):
		(component_.get("id") as DialogUID).unregister()
		component_.set("id", DialogUID.new())
	return component_


func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(duplicate() as Button)
	return new_component()
