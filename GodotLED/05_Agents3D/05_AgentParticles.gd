@tool
extends GPUParticles3D


@export var gen_positions_text:= false :
	set(value):
		cpu_test()

@export_category("agent")
@export var extents := Vector3.ONE
@export var random_start_positions:= false
var positions: PackedVector3Array
var velocities: PackedVector3Array

func _ready() -> void:
	init_agents()

func init_agents()->void:
	positions = []
	velocities = []

	for i in amount:
		
		var agent_position = Vector3.ZERO
		
		if random_start_positions:
			agent_position = Vector3(
				randf_range(-extents.x, extents.x),
				randf_range(-extents.y, extents.y),
				randf_range(-extents.z, extents.z)
			)
	
		var agent_velocity := Vector3(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y),
			randf_range(-extents.z, extents.z)
		).normalized()
	
		positions.append( agent_position )
		velocities.append( agent_velocity )
	
func cpu_test()->void:
	init_agents()
	var image_size :int = ceil(sqrt(amount))
	var positions_image = Image.create(image_size, image_size, false, Image.FORMAT_RGBAF)
	var id : int = 0
	var mat : ShaderMaterial = process_material
	
	for i in amount:
		var pixel_pos = Vector2(int(i/image_size), int(i%image_size))
		var color = Color(positions[i].x,positions[i].y,positions[i].z, 1.0)
		positions_image.set_pixel(pixel_pos.x, pixel_pos.y, color)
	var positions_texture := ImageTexture.create_from_image(positions_image)
	mat.set_shader_parameter("position_texture", positions_texture)
	print(amount)
	print(positions.size())
	
