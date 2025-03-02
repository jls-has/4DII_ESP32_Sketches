@tool
extends MultiMeshInstance3D

@export var generate_leds := false:
	set(value):
		init_leds()
@export_category("LED Grid")
@export var led_dimensions := Vector3i(16,16,16)
@export var led_size : float = 1.0
@export var led_spacing : float = 0.01
var led_positions : PackedVector3Array
var led_colors : PackedColorArray



func init_leds()->void:
	led_positions = []
	led_colors = []
	var num_leds : int = led_dimensions.x*led_dimensions.y*led_dimensions.z
	var mat = (material_override as ShaderMaterial)
	mat.set_shader_parameter("num_leds", num_leds)
	multimesh.instance_count = num_leds
	multimesh.mesh.size = Vector3(led_size, led_size, led_size)
	
	var image_size :int = ceil(sqrt(num_leds))
	var color_image = Image.create(image_size, image_size, false, Image.FORMAT_RGBAF)
	
	var id : int = 0
	for x in led_dimensions.x:
		for y in led_dimensions.y:
			for z in led_dimensions.z:
				var led_position := Vector3(
					x * (led_size + led_spacing),
					y * (led_size + led_spacing),
					z * (led_size + led_spacing) )
					
				var led_color := Color(randf(),randf(),randf(), 0.5)
				
				led_positions.append(led_position)
				led_colors.append(led_color)
				
				multimesh.set_instance_transform(id, Transform3D(Basis(), led_position))
				id+= 1;
				
	#move multimesh to center front of camera
	position = Vector3(
		(-led_dimensions.x * (led_size + led_spacing))/2.0,
		(-led_dimensions.y * (led_size + led_spacing))/2.0,
		(-led_dimensions.x * (led_size + led_spacing))*1.5
	)
	
	for i in num_leds:
		var pixel_pos = Vector2(int(i/image_size), int(i%image_size))
		color_image.set_pixel(pixel_pos.x, pixel_pos.y, Color(led_colors[i]))
	var color_texture = ImageTexture.create_from_image(color_image)
	mat.set_shader_parameter("color_texture", color_texture)

	
	
