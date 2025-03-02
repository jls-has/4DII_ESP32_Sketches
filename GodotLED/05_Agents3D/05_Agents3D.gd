extends Node3D
#https://www.youtube.com/watch?v=v4cfPaa1Gkw&t=96s



@export_category("agent")
@export var num_agents :int = 2000 : 
	set(value):
		num_agents = value
		if particles:
			particles.amount = num_agents
			particles.init_agents()
@export var agent_speed : float = 1;
@export var fade_speed : float = 0.25;
@export var blur_speed : float = 1.0;
@export var blur_radius : float = 15.0;
var positions: PackedVector3Array : 
	set(value):
		positions = value
		if particles:
			particles.positions = positions
var velocities: PackedVector3Array : 
	set(value):
		velocities = value
		if particles:
			particles.velocities = value
			
var positions_texture : Texture2DRD : 
	set(value):
		positions_texture = value
		if positions_sprite:
			positions_sprite.texture = positions_texture
		if particles:
			(particles.process_material as ShaderMaterial).set_shader_parameter("position_texture", positions_texture)
		

		

@export_category("Scene Nodes")
@export var multi_mesh_inst: MultiMeshInstance3D
@export var particles: GPUParticles3D
@export var positions_sprite : Sprite3D
@export var colors_sprite : Sprite3D

var delta : float = 0.0
var frame : int = 0

# SHADER VARIABLES
@export_category("Shader Variables")
@export_file("*.glsl") var agent_shader_path : String 
@export_file("*.glsl") var image_shader_path : String 
@export var image_format := Image.FORMAT_RGBAF
var agent_shader : ComputeHelper
var image_shader : ComputeHelper
var agent_shader_groups : Vector3i
var image_shader_groups : Vector3i
var input_image_uniform : ImageUniform
var positions_image_size : int
var positions_image_uniform : ImageUniform
var velocities_buffer : StorageBufferUniform
var positions_buffer : StorageBufferUniform
var shader_parameters_buffer : StorageBufferUniform
var shader_parameters : PackedFloat32Array = [0.0] 

func _ready() -> void:
	particles.init_agents()
	positions = particles.positions
	velocities = particles.velocities
	RenderingServer.call_on_render_thread(init_agent_shader)

func _process(_delta: float) -> void:
	delta = _delta
	update_shaders()

func init_agent_shader():

	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	#texture = Texture2DRD.new()
	positions_texture = Texture2DRD.new()
	
	
	# init shader and shader pipeline
	agent_shader = ComputeHelper.create(agent_shader_path)
		
	# calculate number of work groups
	var x_groups = max(num_agents, num_agents / 256.0)
	var y_groups = 1
	var z_groups = 1
	agent_shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# init empty buffer for shader uniforms
	#agents_data_buffer = StorageBufferUniform.create(agents_data.to_byte_array())
	positions_buffer = StorageBufferUniform.create(positions.to_byte_array())
	velocities_buffer = StorageBufferUniform.create(velocities.to_byte_array())
	shader_parameters_buffer = StorageBufferUniform.create(shader_parameters.to_byte_array())
	
	positions_image_size = ceil(sqrt(num_agents))
	#init texture buffers
	var positions_image = Image.create(positions_image_size, positions_image_size, false, image_format)
	positions_image_uniform = ImageUniform.create(positions_image)
	input_image_uniform = ImageUniform.create(positions_image)
	## link current TextureRect texture to output_texture by assigning equal IDs
	positions_texture.texture_rd_rid = positions_image_uniform.texture
	#print('positions_texture rd rid: ', positions_texture.texture_rd_rid)
	#print("sprite rid: ", positions_sprite.texture.texture_rd_rid)
	#print("agent shader texture", (particles.process_material as ShaderMaterial).get_shader_parameter("position_texture").texture_rd_rid)
	
	# add uniforms to shader pipeline
	agent_shader.add_uniform_array([
		positions_buffer,
		velocities_buffer,
		shader_parameters_buffer, 
		input_image_uniform, 
		positions_image_uniform])


func update_shaders():

	update_shader_params()
	
	
	# execute shader
	agent_shader.run(agent_shader_groups)
	#image_shader.run(image_shader_groups)
	
	#var positions_read : PackedFloat32Array = positions_buffer.get_data().to_float32_array()
	#
	#for i in 10:
		#print(frame, ": agent", i, ": ", positions_read[3*i], " ", positions_read[(3*i)+1])
		#pass
	#print(positions_read[0], " ", positions_read[1])
	#frame += 1

func update_shader_params()->void:
	shader_parameters = [
		num_agents,
		agent_speed,
		fade_speed,
		blur_speed,
		blur_radius,
		particles.extents.x,
		particles.extents.y,
		particles.extents.z,
		delta,
		frame,
		positions_image_size	]

	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
