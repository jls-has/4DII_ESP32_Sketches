extends Image3DUniform
class_name Sampler3DUniform
## [Uniform] corresponding to a texture. Given to the shader as a sampler.

var sampler: RID ## The [RID] of the corresponding texture. Used internally.
var sampler_state: RDSamplerState ## The sampler's settings.

## Returns a new SamplerUniform object using the given [param image].
static func create(image: Image, depth: int) -> Sampler3DUniform:
	var uniform := Sampler3DUniform.new()
	uniform.texture_size = Vector3i(image.get_size().x, image.get_size().y, depth)
	uniform.image_format = image.get_format()
	uniform.texture_format = Image3DFormatHelper.create_rd_texture_format(uniform.image_format, uniform.texture_size)
	uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image.get_data()])
	uniform.sampler_state = RDSamplerState.new()
	uniform.sampler = ComputeHelper.rd.sampler_create(uniform.sampler_state)
	return uniform

## SamplerUniform's custom implementation of [method Uniform.get_rd_uniform].
func get_rd_uniform(binding: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	uniform.binding = binding
	uniform.add_id(sampler)
	uniform.add_id(texture)
	return uniform

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ComputeHelper.rd.free_rid(sampler)
		ComputeHelper.rd.free_rid(texture)
