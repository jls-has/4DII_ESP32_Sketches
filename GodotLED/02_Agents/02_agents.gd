extends TextureRect
#https://github.com/tsutsen/GodotComputeShaderImageEditing

var readied : bool = false
# IMAGE VARIABLES
# any image can be dragged/assigned to texture of this TextureRect
# you can try different images from sample_images folder
var input_image : Image 
@export_range(8, 2048, 1) var texture_width : int = 256 :
	set(value):
		texture_width = value
		_on_texture_size_change()
@export_range(8, 2048, 1) var texture_height : int = 256 :
	set(value):
		texture_height = value
		_on_texture_size_change()

var texture_size := Vector2(texture_width, texture_height)
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
var shader_parameters_buffer : StorageBufferUniform
var shader_parameters : Array = [
	0.0,
	0.0,
	0.0,
	0.0
]

func _ready():
	#size = get_viewport_rect().size
	# to safely access rendering internals, it is better to call functions this way
	create_input_texture()
	RenderingServer.call_on_render_thread(init_shader)
	readied = true
	RenderingServer.call_on_render_thread(update_shader)
	
func create_input_texture()->void:
	
	input_image = Image.create(texture_size.x, texture_size.y, false, image_format)
	#image.fill(Color.RED)
	
func create_output_texture()->void:
	var output_image = Image.create(size.x, size.y, false, image_format)
	output_texture = ImageUniform.create(output_image)
	# link current TextureRect texture to output_texture by assigning equal IDs
	# all changes made to output_texture uniform will be displayed in this TextureRect
	texture.texture_rd_rid = output_texture.texture
	
	
func init_shader():

	#image.convert(image_format)
	#image_size = image.get_size() 
	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	texture = Texture2DRD.new()
	
	# init shader and shader pipeline
	compute_shader = ComputeHelper.create(shader_path)
	
	# init image uniforms
	input_texture = ImageUniform.create(input_image)
	
	create_output_texture()
	#now done in create outpute texture
	#output_texture = ImageUniform.create(image)
	# link current TextureRect texture to output_texture by assigning equal IDs
	# all changes made to output_texture uniform will be displayed in this TextureRect
	#texture.texture_rd_rid = output_texture.texture
	
	# calculate number of work groups
	var x_groups = (texture_size.x - 1) / 8 + 1
	var y_groups = (texture_size.y - 1) / 8 + 1

	var z_groups = 1
	shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# init empty buffer for shader parameters
	shader_parameters_buffer = StorageBufferUniform.create(PackedFloat32Array([0.0]).to_byte_array())
	
	# add uniforms to shader pipeline
	compute_shader.add_uniform_array([shader_parameters_buffer, input_texture, output_texture])


func update_shader():
	var x_groups = (texture_size.x - 1) / 8 + 1
	var y_groups = (texture_size.y - 1) / 8 + 1
	var z_groups = 1
	shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	#update input texture
	input_texture.update_image(input_image)

	
	#update shader parameters
	shader_parameters = [
	texture_size.x, #width
	texture_size.y, #height
	brightness, #brightness
	contrast #contrast
	]
	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
	# execute shader
	compute_shader.run(shader_groups)

func _on_texture_size_change() ->void:
	texture_size = Vector2(texture_width, texture_height)
	create_input_texture()
	create_output_texture()
	#size = get_viewport_rect().size
	
	if not readied:
		return
		
	# execute shader
	RenderingServer.call_on_render_thread(update_shader)
	
	
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
