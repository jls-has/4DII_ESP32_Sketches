extends TextureRect
var num_boids = 1000
var boid_positions : PackedVector2Array= []
var boid_velocities :PackedVector2Array= []
var delta : float = 0.0

var boid_data_image_width := int(ceil(sqrt(num_boids)))
var boid_data_image : Image
#CPU ONLY? var boid_data_texture : ImageTexture
var boid_data_texture_rd : Texture2DRD 

@export var boid_particles : GPUParticles2D

@export_category("Boid Settings")
@export_range(0,50, 1.0) var friend_radius : float = 30.0
@export_range(0,50, 1.0) var avoid_radius : float = 15.0
@export_range(0,100, 1.0) var min_vel : float = 25.0
@export_range(0,100, 1.0) var max_vel : float = 50.0
@export_range(0,100, 1.0) var alignment_factor : float = 10.0
@export_range(0,100, 1.0) var cohesion_factor : float = 1.0
@export_range(0,100, 1.0) var separation_factor : float = 2.0

@export_category("Rendering")
@export var boid_color = Color(Color.WHITE) :
	set(new_color):
		boid_color = new_color
		if is_inside_tree():
			boid_particles.process_material.set_shader_parameter("color", boid_color)

enum BoidColorMode {SOLID, HEADING, FRIENDS, BIN, DETECTION}
@export var boid_color_mode : BoidColorMode :
	set(new_color_mode):
		boid_color_mode = new_color_mode
		if is_inside_tree():
			boid_particles.process_material.set_shader_parameter("color_mode", boid_color_mode)
			
@export var boid_max_friends = 10 :
	set(new_max_friends):
		boid_max_friends = new_max_friends
		if is_inside_tree():
			boid_particles.process_material.set_shader_parameter("max_friends", boid_max_friends)

@export var boid_scale = Vector2(.5, .5):
	set(new_scale):
		boid_scale = new_scale
		if is_inside_tree():
			boid_particles.process_material.set_shader_parameter("scale", boid_scale)

@export var bin_grid = false:
	set(new_grid):
		bin_grid = new_grid
		if is_inside_tree():
			$Grid.visible = bin_grid

@export_category("Other")
@export var pause = false :
	set(new_value):
		pause = new_value

# SHADER VARIABLES
@export_file("*.glsl") var shader_path : String 
var compute_shader : ComputeHelper
var shader_groups : Vector3i
var boid_positions_buffer : StorageBufferUniform
var boid_velocities_buffer : StorageBufferUniform
var shader_parameters_buffer : StorageBufferUniform
var boid_data_image_buffer : ImageUniform
var shader_parameters : PackedFloat32Array 

func generate_boids():
	boid_positions = []
	boid_velocities = []
	var screen_size := size
	for i in num_boids:
		boid_positions.append(Vector2(randf() * screen_size.x, randf()  * screen_size.y))
		boid_velocities.append(Vector2(randf_range(-1.0, 1.0) * max_vel, randf_range(-1.0, 1.0) * max_vel))

func init_shader():

	# init shader and shader pipeline
	compute_shader = ComputeHelper.create(shader_path)
		
	# init empty buffer for uniforms
	boid_positions_buffer = StorageBufferUniform.create(boid_positions.to_byte_array())
	boid_velocities_buffer = StorageBufferUniform.create(boid_velocities.to_byte_array())
	shader_parameters_buffer = StorageBufferUniform.create(PackedFloat32Array([0.0]).to_byte_array())
	boid_data_image_buffer = ImageUniform.create(boid_data_image)
	
	#init textures/  particles
	boid_data_texture_rd = Texture2DRD.new()
	texture = boid_data_texture_rd
	boid_particles.process_material.set_shader_parameter("boid_data", boid_data_texture_rd)
	boid_data_texture_rd.texture_rd_rid = boid_data_image_buffer.texture
	
		# calculate number of work groups
	var x_groups :int= max(num_boids/1024.0, num_boids)
	var y_groups :int= 1
	var z_groups :int= 1
	shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# add uniforms to shader pipeline
	var bindings : Array[Uniform] = [
		boid_positions_buffer,
		boid_velocities_buffer,
		shader_parameters_buffer,
		boid_data_image_buffer
	]
	compute_shader.add_uniform_array(bindings)

	print(boid_positions[0], boid_positions[1])
	var updated_boid_positions = boid_positions_buffer.get_data().to_float32_array()
	print(updated_boid_positions[0], " ", updated_boid_positions[1])
func update_shader()->void:
	update_parameters()
	# execute shader
	compute_shader.run(shader_groups)
	#var updated_boid_positions = boid_positions_buffer.get_data().to_float32_array()
	#print(updated_boid_positions[0], " ", updated_boid_positions[1])
	

func update_parameters()->void:
	var screen_size := size
	
	shader_parameters = [
		num_boids, 
		boid_data_image_width, 
		friend_radius,
		avoid_radius,
		min_vel, 
		max_vel,
		alignment_factor,
		cohesion_factor,
		separation_factor,
		screen_size.x,
		screen_size.y,
		delta,
		pause,
		boid_color_mode]
	# send shader_parameters to shader
	shader_parameters_buffer.update_data(shader_parameters.to_byte_array())
	
func _ready() -> void:
	#init boids
	generate_boids()
	
	#init boid data image
	boid_data_image = Image.create(boid_data_image_width, boid_data_image_width, false, Image.FORMAT_RGBAH)

	boid_particles.amount = num_boids
	
	#init shader
	RenderingServer.call_on_render_thread(init_shader)
	
	
func _process(_delta)->void:	
	get_window().title =  " / Boids: " + str(num_boids) + " / FPS: " + str(Engine.get_frames_per_second())
	delta = _delta
	RenderingServer.call_on_render_thread(update_shader)
