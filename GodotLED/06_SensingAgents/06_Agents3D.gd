extends Node3D

@export_category("agent")
@export var num_agents :int = 2000 

@export var agent_speed : float = 1;
@export var fade_speed : float = 0.25;
@export var blur_speed : float = 1.0;
@export var blur_radius : float = 2;
var positions: PackedVector3Array 
var velocities: PackedVector3Array 
var color3D : Texture3DRD 

@export_category("Image Manipulation")
@export var brightness : float = 1.0
@export var contrast : float = 1.0

@export_category("Scene Nodes")
@export var LEDs: MultiMeshInstance3D


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
var color3D_uniform : Image3DUniform
var velocities_buffer : StorageBufferUniform
var positions_buffer : StorageBufferUniform
var shader_parameters_buffer : StorageBufferUniform
var shader_parameters : PackedFloat32Array = [0.0] 

func _ready() -> void:
	LEDs.generate_leds = true
	init_agents()
	RenderingServer.call_on_render_thread(init_agent_shader)
	RenderingServer.call_on_render_thread(init_image_shader)

func _process(_delta: float) -> void:
	delta = _delta
	update_shaders()

func init_agents()->void:
	positions = []
	velocities = []
	
	for a in num_agents:
		#random positions
		#var agent_pos := Vector3(
			#randf()*LEDs.led_dimensions.x,
			#randf()*LEDs.led_dimensions.y,
			#randf()*LEDs.led_dimensions.z)
		
		#start in center
		var agent_pos := Vector3(
			LEDs.led_dimensions.x/2.0,
			LEDs.led_dimensions.y/2.0,
			LEDs.led_dimensions.z/2.0)
			
			
		positions.append(agent_pos)
		var agent_vel := Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)).normalized()
		velocities.append(agent_vel)
	
func init_agent_shader()->void:

	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	color3D = Texture3DRD.new()
	LEDs.material_override.set_shader_parameter("color3D", color3D)
	
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
	
	var color3D_image_size :Vector3i= LEDs.led_dimensions
	#init texture buffers
	var color3D_image = Image.create(color3D_image_size.x, color3D_image_size.y, false, image_format)
	color3D_uniform = Image3DUniform.create(color3D_image, color3D_image_size.z)
	input_image_uniform = ImageUniform.create(color3D_image)

	color3D.texture_rd_rid = color3D_uniform.texture
	#color3D.set_texture_rd_rid(color_image_uniform.texture)
	print("uniform rid: ", color3D_uniform.texture)
	print('colors text rd rid: ', color3D.texture_rd_rid)
	print("leds: ",LEDs.material_override.get_shader_parameter("color3D").texture_rd_rid)
	# add uniforms to shader pipeline
	agent_shader.add_uniform_array([
		positions_buffer,
		velocities_buffer,
		shader_parameters_buffer, 
		input_image_uniform, 
		color3D_uniform])

func init_image_shader():

	
	# init shader and shader pipeline
	image_shader = ComputeHelper.create(image_shader_path)
		
	# calculate number of work groups
	# calculate number of work groups
	var screen_size :Vector3i= LEDs.led_dimensions
	var x_groups : int = (screen_size.x - 1) / 8.0 + 1
	var y_groups : int = (screen_size.y - 1) / 8.0 + 1
	var z_groups : int=  (screen_size.z - 1) / 8.0 + 1
	image_shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# add uniforms to shader pipeline
	image_shader.add_uniform_array([
		shader_parameters_buffer, 
		input_image_uniform, 
		color3D_uniform])
		
func update_shaders()->void:

	update_shader_params()
	
	
	# execute shader
	agent_shader.run(agent_shader_groups)
	image_shader.run(image_shader_groups)

	
	#var positions_read : PackedFloat32Array = positions_buffer.get_data().to_float32_array()
	#
	#for i in 10:
		#print(frame, ": agent", i, ": ", positions_read[3*i], " ", positions_read[(3*i)+1])
		#pass
	#print(positions_read[0], " ", positions_read[1])
	frame += 1

func update_shader_params()->void:
	shader_parameters = [
		num_agents,
		agent_speed,
		fade_speed,
		blur_speed,
		blur_radius,
		LEDs.led_dimensions.x,
		LEDs.led_dimensions.y,
		LEDs.led_dimensions.z,
		brightness,
		contrast,
		delta,
		frame]

	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
