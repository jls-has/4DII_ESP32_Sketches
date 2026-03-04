extends Node3D

@export var bubbles_in : float = 5.0
@export var bubbles_out : float = 5.0
@export var bubbles_speed : float = 10.0


var phone : MeshInstance3D
var light : Light3D
var area : Area3D
var audio : AudioStreamPlayer3D
var bubbles : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area = $Area3D
	phone = $Phone
	audio = $AudioStreamPlayer3D
	area = $Area3D
	light = $OmniLight3D
	bubbles = $Bubbles
	
	area.body_entered.connect(_on_body_entered)
	audio.finished.connect(_on_audio_finished)
	
	bubbles.scale = Vector3.ZERO
	bubbles.visible = false
	
	
func _process(delta: float) -> void:
	if bubbles.visible:
		bubbles.rotate_y(bubbles_speed*delta)
	
func _on_body_entered(_body: Node3D)->void:
	if _body.name == "CharacterBody3D":
		audio.play()

func _on_audio_finished()->void:
	light.light_color = Color(1,0,0,1)
	start_bubbles()
	
func start_bubbles()->void:
	bubbles.visible = true
	var t :Tween = get_tree().create_tween()
	t.tween_property(bubbles, "scale", Vector3.ONE, bubbles_in)
	t.tween_property(bubbles, "scale", Vector3.ZERO, bubbles_out)
