extends Node3D

var phone : MeshInstance3D
var light : Light3D
var area : Area3D
var audio : AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area = $Area3D
	phone = $Phone
	audio = $AudioStreamPlayer3D
	area = $Area3D
	light = $OmniLight3D
	
	area.body_entered.connect(_on_body_entered)
	audio.finished.connect(_on_audio_finished)
	
func _on_body_entered(_body: Node3D)->void:
	if _body.name == "CharacterBody3D":
		audio.play()

func _on_audio_finished()->void:
	light.light_color = Color(1,0,0,1)
