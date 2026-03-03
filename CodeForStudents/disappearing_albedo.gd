extends MeshInstance3D

@export var max_distance : float = 10
var camera : Camera3D
var material : StandardMaterial3D
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	material = get_active_material(0)


func _process(delta: float) -> void:
	var d : float = self.global_position.distance_squared_to(camera.global_position)
	var max_d : float = max_distance * max_distance
	if d < max_d:
		material.albedo_color.a = lerpf(1.0, 0.0, (1.0-d/max_d)*2) #change the last number to make it happen sooner or later
		print(material.albedo_color.a)
		
	
