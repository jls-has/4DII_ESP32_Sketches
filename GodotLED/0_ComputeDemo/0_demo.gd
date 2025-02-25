extends TextureRect
#https://github.com/tsutsen/GodotComputeShaderImageEditing

var readied : bool = false
# IMAGE VARIABLES
# any image can be dragged/assigned to texture of this TextureRect
# you can try different images from sample_images folder
var image : Image 
var image_size : Vector2 
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
var shader_parameters : Array = [0.0, 0.0]

func _ready():
	# to safely access rendering internals, it is better to call functions this way
	init_image()
	RenderingServer.call_on_render_thread(init_shader)
	readied = true
	
func init_image()->void:
	image_size = size
	image = Image.create(image_size.x, image_size.y, false, image_format)
	image.fill(Color.RED)
	
func init_shader():

	#image.convert(image_format)
	#image_size = image.get_size() 
	# assign Texture2DRD to current texture so that its data could be synced with data on GPU
	texture = Texture2DRD.new()
	
	# init shader and shader pipeline
	compute_shader = ComputeHelper.create(shader_path)
	
	# init image uniforms
	input_texture = ImageUniform.create(image)
	output_texture = ImageUniform.create(image)
	# link current TextureRect texture to output_texture by assigning equal IDs
	# all changes made to output_texture uniform will be displayed in this TextureRect
	texture.texture_rd_rid = output_texture.texture
	
	# calculate number of work groups
	var x_groups = (image_size.x - 1) / 8 + 1
	var y_groups = (image_size.y - 1) / 8 + 1
	var z_groups = 1
	shader_groups = Vector3i(x_groups, y_groups, z_groups)
	
	# init empty buffer for shader parameters
	shader_parameters_buffer = StorageBufferUniform.create(PackedFloat32Array([0.0]).to_byte_array())
	
	# add uniforms to shader pipeline
	compute_shader.add_uniform_array([shader_parameters_buffer, input_texture, output_texture])


func update_shader():
	# send shader_parameters to shader
	shader_parameters_buffer.update_data(PackedFloat32Array(shader_parameters).to_byte_array())
	# execute shader
	compute_shader.run(shader_groups)


func _on_brightness_slider_value_changed(value):
	if not readied:
		brightness = 0
		return
	brightness = value
	# change first value in shader_parameters array (brightness)
	shader_parameters[0] = value
	# execute shader
	RenderingServer.call_on_render_thread(update_shader)


func _on_contrast_slider_value_changed(value):
	if not readied:
		contrast = 0
		return
	contrast = value
	# change second value in shader_parameters array (contrast)
	shader_parameters[1] = value
	# execute shader
	RenderingServer.call_on_render_thread(update_shader)
	#update_shader(shader_parameters)


func _on_size_flags_changed() -> void:
	image_size = size
	init_image()
