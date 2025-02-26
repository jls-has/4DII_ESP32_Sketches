extends TextureRect

var num_agents :int = 1000
var agents_data : PackedVector3Array
@export_category("agent parameters")
@export var agent_speed : float
var readied : bool = false
var input_image : Image 
var delta : float 

#@export_range(8, 2048, 1) var texture_width : int = 256 :
	#set(value):
		#texture_width = value
		#_on_texture_size_change()
#@export_range(8, 2048, 1) var texture_height : int = 256 :
	#set(value):
		#texture_height = value
		#_on_texture_size_change()
#
#var texture_size := Vector2(texture_width, texture_height)
@export var image_format := Image.FORMAT_RGBAF

#Controls
@export_range(-1, 1, 0.1) var brightness : float = 0.0 : set = _on_brightness_slider_value_changed
@export_range(-1, 1, 0.1) var contrast : float = 0.0 : set = _on_contrast_slider_value_changed

# SHADER VARIABLES
@export_file("*.glsl") var shader_path : String 
var compute_shader : ComputeHelper
var shader_groups : Vector3i
var input_texture : ImageUniform
var output_texture : ImageUniform
var agents_data_buffer : StorageBufferUniform
var shader_parameters_buffer : StorageBufferUniform
var shader_parameters : Array = [
	0.0,
	0.0,
	0.0,
	0.0
]

func _ready():
	init_agents()
	

	RenderingServer.call_on_render_thread(init_shader)
	readied = true
	

func _process(_delta: float) -> void:
	delta = _delta
	RenderingServer.call_on_render_thread(update_shader)

func init_agents()->void:
	agents_data = []
	var screen_size : Vector2 = size
	for i in num_agents:
		var pos_x : float = randf()*screen_size.x
		var pos_y : float = randf()*screen_size.y
		pos_x = screen_size.x / 2.0
		pos_y = screen_size.y / 2.0
		var angle : float = randf()*TAU;
		agents_data.append(Vector3(pos_x,pos_y,angle))
		
#func create_input_texture()->void:
	#
	#input_image = Image.create(texture_size.x, texture_size.y, false, image_format)
	##image.fill(Color.RED)
	
#func create_textures()->void:
	#var output_image = Image.create(size.x, size.y, false, image_format)
	#output_texture = ImageUniform.create(output_image)
	#input_texture = output_texture
	## link current TextureRect texture to output_texture by assigning equal IDs
	## all changes made to output_texture uniform will be displayed in this TextureRect
	#texture.texture_rd_rid = output_texture.texture
	
	
func init_shader():

	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	texture = Texture2DRD.new()
	
	# init shader and shader pipeline
	compute_shader = ComputeHelper.create(shader_path)
		
	# calculate number of work groups
	var x_groups = max(num_agents, num_agents / 1024.0)
	var y_groups = 1
	var z_groups = 1
	shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# init empty buffer for shader uniforms
	agents_data_buffer = StorageBufferUniform.create(agents_data.to_byte_array())
	shader_parameters_buffer = StorageBufferUniform.create(PackedFloat32Array([0.0]).to_byte_array())
	
	#init texture buffers
	var output_image = Image.create(int(size.x), int(size.y), false, image_format)
	output_texture = ImageUniform.create(output_image)
	input_texture = ImageUniform.create(output_image)
	## link current TextureRect texture to output_texture by assigning equal IDs
	texture.texture_rd_rid = output_texture.texture
	
	# add uniforms to shader pipeline
	compute_shader.add_uniform_array([
		agents_data_buffer,
		shader_parameters_buffer, 
		input_texture, 
		output_texture])


func update_shader():

	#update input texture
	#input_texture.update_image(input_image)

	#update shader parameters
	var screen_size : Vector2= size
	shader_parameters = [
		num_agents,
		agent_speed,
		screen_size.x, 
		screen_size.y,
		brightness,
		contrast,
		delta	]

	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
	
	# execute shader
	compute_shader.run(shader_groups)
	
	var new_agent_array : PackedFloat32Array = agents_data_buffer.get_data().to_float32_array()
	print(new_agent_array[0])

#func _on_texture_size_change() ->void:
	#texture_size = Vector2(texture_width, texture_height)
	#create_input_texture()
	#create_output_texture()
	#size = get_viewport_rect().size
	
	#if not readied:
		#return
		#
	## execute shader
	#RenderingServer.call_on_render_thread(update_shader)
	
	
func _on_brightness_slider_value_changed(value):
	if not readied:
		brightness = 0
		return
	brightness = value
	# change first value in shader_parameters array (brightness)
	#now done in update code
	#shader_parameters[3] = value
	# execute shader
	RenderingServer.call_on_render_thread(update_shader)


func _on_contrast_slider_value_changed(value):
	if not readied:
		contrast = 0
		return
	contrast = value
	# change second value in shader_parameters array (contrast)
	#now done in update code
	#shader_parameters[1] = value 

	# execute shader
	RenderingServer.call_on_render_thread(update_shader)
	#update_shader(shader_parameters)
