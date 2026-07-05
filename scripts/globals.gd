extends Node

var DEFAULT_GENERIC_PRESET: Dictionary = {
	"color": Color.WHITE,
	"speed": 100,
	"wave_intensity": 0,
	"wave_speed": 0,
	"shake_intensity": 0,
	"shake_speed": 0,
}

var conversations: PackedStringArray = []
var generic_presets: Dictionary[String, Dictionary] = {
	"Default": DEFAULT_GENERIC_PRESET
}
var generic_preset_names: PackedStringArray = ["Default"]
var color_presets: Dictionary[String, Color] = {}
var color_preset_names: PackedStringArray = []
var speed_presets: Dictionary[String, int] = {}
var speed_preset_names: PackedStringArray = []
var delay_presets: Dictionary[String, int] = {}
var delay_preset_names: PackedStringArray = []

var uid_objects: Array[DialogUID] = []
