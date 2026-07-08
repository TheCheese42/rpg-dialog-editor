@tool
class_name DialogFile
extends Resource

@export var original: String = ""
@export var presets: Dictionary[String, Dictionary] = {}
@export var color_presets: Dictionary[String, Color] = {}
@export var speed_presets: Dictionary[String, int] = {}
@export var delay_presets: Dictionary[String, int] = {}
@export var conversations: Array[Conversation] = []


@abstract class DialogComponent extends Resource:
	@abstract func _to_string() -> String

	func unregister() -> void:
		var contents: Array = self.get("contents")
		if contents:
			for content: ConversationContent in contents:
				content.unregister()


class Conversation extends DialogComponent:
	@export var original_hash: String = ""
	@export var id: DialogUID = DialogUID.new()
	@export var preset: String = Globals.generic_preset_names[0]
	@export var contents: Array[ConversationContent] = []

	func _to_string() -> String:
		return str(id)

	func unregister() -> void:
		super.unregister()
		id.unregister()


@abstract class ConversationContent extends DialogComponent:
	pass


class Speaker extends ConversationContent:
	@export var name: String = ""
	@export var contents: Array[ConversationContent]

	func _to_string() -> String:
		return "{0}:".format([name])


class Page extends ConversationContent:
	@export var id: DialogUID = DialogUID.new()
	@export var text: String = ""
	@export var interjection: Interjection = Interjection.new()
	@export var contents: Array[Choice]
	

	func _to_string() -> String:
		return "[{0}] {1}".format([id, text])

	func unregister() -> void:
		super.unregister()
		id.unregister()


class Interjection extends DialogComponent:
	@export var name: String = ""
	@export var text: String = ""

	func _to_string() -> String:
		return "{0}: {1}".format([name, text])


class Goto extends ConversationContent:
	@export var target_id: String = ""

	func _to_string() -> String:
		return "Goto: {0}".format([target_id])


class Script_ extends ConversationContent:
	@export var script_id: String = ""

	func _to_string() -> String:
		return "Script: {0}".format([script_id])


class Choice extends DialogComponent:
	@export var text: String = ""
	@export var contents: Array[ConversationContent] = []

	func _to_string() -> String:
		return "[{0}]".format([text])
