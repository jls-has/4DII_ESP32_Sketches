extends Uniform
class_name Image3DUniform
## [Uniform] corresponding to a texture. Given to the shader as an image.

var texture: RID ## The [RID] of the corresponding texture. Used internally.
var texture_size: Vector3i ## The resolution of the texture.
var image_format: Image.Format ## The [enum Image.Format] of the texture.
var texture_format: RDTextureFormat ## The [RDTextureFormat] of the texture.

## Returns a new ImageUniform object using the given [param image].
static func create(image: Image, depth: int) -> Image3DUniform:
	var uniform := Image3DUniform.new()

	uniform.texture_size = Vector3(image.get_size().x, image.get_size().y, depth)
	uniform.image_format = image.get_format()
	uniform.texture_format = Image3DFormatHelper.create_rd_texture_format(uniform.image_format,uniform.texture_size)
	#print(uniform.texture_format.get_texture_type())
	
	#For array layers
	#var image_array : Array[PackedByteArray] = []
	#for z in depth:
		#image_array.append(image.get_data())
	#print(uniform.texture_format.depth)
	#for image3D
	var image_array :PackedByteArray = []
	
	for z in depth:
		image_array.append_array(image.get_data())
	
	uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image_array])
	print(uniform.texture)
	return uniform

## ImageUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

## Updates the texture to match [param image].
func update_image(image: Image, depth: int) -> void:
	if texture_size == Vector3i(image.get_size().x, image.get_size().y, depth) and image_format == image.get_format():
		for layer in depth:
			ComputeHelper.rd.texture_update(texture, layer, image.get_data())
	else:
		ComputeHelper.rd.free_rid(texture)
		image_format = image.get_format()
		texture_size = Vector3i(image.get_size().x, image.get_size().y, depth)
		texture_format = Image3DFormatHelper.create_rd_texture_format(image_format, Vector3i(texture_size.x,texture_size.y, depth))
		texture = ComputeHelper.rd.texture_create(texture_format, ComputeHelper.view, [image.get_data()])
		rid_updated.emit(self)

## Returns a new [Image] that has the data of the texture. [b]Warning:[/b] Getting data from the GPU is very slow.
func get_image() -> Image:
	var image_data := ComputeHelper.rd.texture_get_data(texture, 0)
	return Image.create_from_data(texture_size.x, texture_size.y, false, image_format, image_data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(texture)
