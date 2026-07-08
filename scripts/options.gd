@tool
class_name Options
extends Resource

@export var window_mode: DisplayServer.WindowMode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
@export var window_size: Vector2i = Vector2i(800, 840)
@export var window_pos: Vector2i = DisplayServer.screen_get_size() / Vector2i(2, 2)
@export var last_working_dir: String = ""
