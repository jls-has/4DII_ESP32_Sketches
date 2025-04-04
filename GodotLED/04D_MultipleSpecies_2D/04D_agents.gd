extends TextureRect


var positions: PackedVector4Array
var velocities: PackedVector4Array
var colors : PackedVector4Array
@export_category("agent parameters")
@export var reset := false:
	set(value):
		reset = false
		if is_inside_tree():
			_ready()
@export var num_agents :int = 1000000

@export_range(1,4,1) var num_species :int = 2
@export_enum("RANDOMOUT", "RANDOMIN", "CENTEROUT", "CIRCLEIN", "RANDOM") var starting_dir = 0 :
	set(value):
		starting_dir = value
		if is_inside_tree():
			_ready()
@export var trail_weight = 1.0;
@export var agent_speed : float = 100;
@export var turn_speed : float = 100;
@export var fade_speed : float = 0.1; # 0-1?
@export var blur_speed : float = 4.0; # 1-10?
@export var blur_radius : float =1.0; #1-10?
@export var sensor_dist : float = 1.0; #1-10?
@export var sensor_angle : float = PI/2.0 
@export var sensor_radius : float = 1.0
@export var species0_color : Color = Color.RED
@export var species1_color : Color = Color.GREEN
@export var species2_color : Color = Color.BLUE
@export var species3_color : Color = Color.WHITE
var readied : bool = false
var delta : float = 0.0
var frame : int = 0


#var texture_size := Vector2(texture_width, texture_height)
@export var image_format := Image.FORMAT_RGBAF

#Controls
@export_range(-1, 1, 0.1) var brightness : float = 0.0 : set = _on_brightness_slider_value_changed
@export_range(-1, 1, 0.1) var contrast : float = 0.0 : set = _on_contrast_slider_value_changed

# SHADER VARIABLES
@export_file("*.glsl") var agent_shader_path : String 
@export_file("*.glsl") var image_shader_path : String 

var agent_shader : ComputeHelper
var image_shader : ComputeHelper
var agent_shader_groups : Vector3i
var image_shader_groups : Vector3i
var input_texture : ImageUniform
var output_texture : ImageUniform
var velocities_buffer : StorageBufferUniform
var positions_buffer : StorageBufferUniform
var colors_buffer : StorageBufferUniform
var shader_parameters_buffer : StorageBufferUniform
var shader_parameters : PackedFloat32Array = [0.0] 

func _ready() -> void:

	randomize()
	init_agents()
	

	RenderingServer.call_on_render_thread(init_agent_shader)
	RenderingServer.call_on_render_thread(init_image_shader)
	#print("before first frame", positions_buffer.get_data().to_float32_array())
	#RenderingServer.call_on_render_thread(update_shaders)
	#print("after first update", positions_buffer.get_data().to_float32_array())

func _process(_delta: float) -> void:
	delta = _delta
	RenderingServer.call_on_render_thread(update_shaders)
	
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func init_agents()->void:
	positions = []
	velocities = []
	var screen_size : Vector2 = size
	match starting_dir:
		0: #randomout
			for i in num_agents:
				var pos_x : float = randf_range(0, screen_size.x)
				var pos_y : float = randf_range(0, screen_size.y)
				var vel := Vector2(1.0,1.0).rotated(randf()*TAU).normalized() 
				positions.append(Vector4(pos_x, pos_y, 3.0,4.0))
				velocities.append(Vector4(vel.x, vel.y, 3.0, 4.0 ))
		1: #randomin
			var pos_x : float = randf_range(0, screen_size.x)
			var pos_y : float = randf_range(0, screen_size.y)
			var vel := Vector2(pos_x,pos_y).direction_to(screen_size/2.0)
		
			positions.append(Vector4(pos_x, pos_y, 3.0,4.0))
			velocities.append(Vector4(vel.x, vel.y, 3.0, 4.0 ))
		2: #centerout
			for i in num_agents:
				var pos_x : float = screen_size.x/2.0
				var pos_y : float = screen_size.y/2.0
				var vel := Vector2(1.0,1.0).rotated(randf()*TAU).normalized() 
				
				positions.append(Vector4(pos_x, pos_y, 3.0,4.0))
				
				velocities.append(Vector4(vel.x, vel.y, 3.0, 4.0 ))
		3: #circlein
			for i in num_agents:
				var theta : float = randf() * 2 * PI
				var pos := Vector2(cos(theta), sin(theta)) * sqrt(randf())
				var radius : float =  min(screen_size.x, screen_size.y) /2.0
				pos = pos * radius
				pos += screen_size/2.0
				var vel := pos.direction_to(screen_size/2.0)
				
				positions.append(Vector4(pos.x, pos.y, 3.0,4.0))
				velocities.append(Vector4(vel.x, vel.y, 3.0, 4.0 ))
				
		4: # all things totally random
			for i in num_agents:
				var pos_x : float = randf_range(0, screen_size.x)
				var pos_y : float = randf_range(0, screen_size.y)
				var vel := Vector2(1.0,1.0).rotated(randf()*TAU).normalized() 
				var species : float = randi_range(0, num_species-1)
				positions.append(Vector4(pos_x, pos_y, 3.0,species))
				velocities.append(Vector4(vel.x, vel.y, 3.0, 4.0 ))
	
	colors = []
	for i in num_agents:
		var s : int = randi()%num_species
		var color : Color
		match s:
			0: 
				color = species0_color
			1:
				color= species1_color
			2:
				color = species2_color
			3:
				color = species3_color
		colors.append(Vector4(color.r,color.g,color.b,color.a))
		
		
	

func init_agent_shader():

	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	texture = Texture2DRD.new()
	
	# init shader and shader pipeline
	agent_shader = ComputeHelper.create(agent_shader_path)
		
	# calculate number of work groups
	var x_groups = max(num_agents, num_agents / 256.0)
	var y_groups = 1
	var z_groups = 1
	agent_shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# init empty buffer for shader uniforms
	#agents_data_buffer = StorageBufferUniform.create(agents_data.to_byte_array())
	colors_buffer = StorageBufferUniform.create(colors.to_byte_array())
	positions_buffer = StorageBufferUniform.create(positions.to_byte_array())
	velocities_buffer = StorageBufferUniform.create(velocities.to_byte_array())
	shader_parameters_buffer = StorageBufferUniform.create(shader_parameters.to_byte_array())
	
	#init texture buffers
	var output_image = Image.create(int(size.x), int(size.y), false, image_format)
	output_texture = ImageUniform.create(output_image)
	input_texture = ImageUniform.create(output_image)
	## link current TextureRect texture to output_texture by assigning equal IDs
	texture.texture_rd_rid = output_texture.texture
	# add uniforms to shader pipeline
	agent_shader.add_uniform_array([
		positions_buffer,
		velocities_buffer,
		colors_buffer,
		shader_parameters_buffer, 
		input_texture, 
		output_texture])
	
	#var color_read = colors_buffer.get_data().to_float32_array()

func init_image_shader():

	
	# init shader and shader pipeline
	image_shader = ComputeHelper.create(image_shader_path)
		
	# calculate number of work groups
	# calculate number of work groups
	var screen_size :Vector2= size
	var x_groups := int((screen_size.x - 1) / 8.0 + 1)
	var y_groups := int((screen_size.y - 1) / 8.0 + 1 )
	var z_groups : int= 1
	image_shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# add uniforms to shader pipeline
	image_shader.add_uniform_array([
		shader_parameters_buffer, 
		input_texture, 
		output_texture])


func update_shaders():

	#update input texture
	#input_texture.update_image(input_image)
	
	#update shader parameters
	var screen_size : Vector2= size
	shader_parameters = [
		num_agents,
		trail_weight,
		agent_speed,
		turn_speed,
		fade_speed,
		blur_speed,
		blur_radius,
		sensor_dist,
		sensor_angle,
		sensor_radius,
		screen_size.x, 
		screen_size.y,
		0.0, #screen_depth
		brightness,
		contrast,
		delta,
		frame,	]

	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
	
	# execute shader
	agent_shader.run(agent_shader_groups)
	image_shader.run(image_shader_groups)
	
	#var positions_read : PackedFloat32Array = positions_buffer.get_data().to_float32_array()
	#print(positions_read)
	#for i in 10:
		##print(frame, ": agent", i, ": ", new_agent_array[3*i], " ", new_agent_array[(3*i)+1])
		#pass
	##print(new_agent_array[0], " ", new_agent_array[1])
	frame += 1


	
	
func _on_brightness_slider_value_changed(value):
	if not readied:
		brightness = 0
		return
	brightness = value
	# change first value in shader_parameters array (brightness)
	#now done in update code
	#shader_parameters[3] = value
	# execute shader
	RenderingServer.call_on_render_thread(update_shaders)


func _on_contrast_slider_value_changed(value):
	if not readied:
		contrast = 0
		return
	contrast = value
	# change second value in shader_parameters array (contrast)
	#now done in update code
	#shader_parameters[1] = value 
 
	# execute shader
	RenderingServer.call_on_render_thread(update_shaders)
	#update_shader(shader_parameters)
