@tool
extends MultiMeshInstance3D

@export var generate_leds := false:
	set(value):
		init_leds()
@export_enum("ALL_OFF","ALL_ON_WHITE","ALL_ON_RANDOMCOLOR", "GRAY_DEPTH") var start_state = 0 
@export_enum("RANDOM","MIDDLE") var agent_state = 0 
@export_range(0.0,1.0,0.1) var off_alpha := 0.5
@export_range(0.0,1.0,0.1) var on_alpha := 0.5
@export_category("LED Grid")
@export var num_leds : int
@export var led_dimensions := Vector3i(16,16,16)
@export var led_size : float = 1.0
@export var led_spacing : float = 0.01
@export var array_size : Vector3
@export var image_array : Array[Image]
var led_positions : PackedVector3Array
var led_colors : PackedColorArray
@export var color3D: ImageTexture3D 

var test_agent_positions: PackedVector2Array


func init_leds()->void:
	led_positions = []
	led_colors = []
	num_leds = led_dimensions.x*led_dimensions.y*led_dimensions.z
	var mat: ShaderMaterial = material_override
	mat.set_shader_parameter("num_leds", num_leds)
	multimesh.instance_count = num_leds
	if multimesh.mesh is BoxMesh:
		multimesh.mesh.size = Vector3(led_size, led_size, led_size)
	elif multimesh.mesh is SphereMesh:
		multimesh.mesh.height = led_size
		multimesh.mesh.radius = led_size/2.0
		multimesh.mesh.rings = 3
		
	
	
	var id : int = 0
	for x in led_dimensions.x:
		for y in led_dimensions.y:
			for z in led_dimensions.z:
				var led_position := Vector3(
					x * (led_size + led_spacing),
					y * (led_size + led_spacing),
					z * (led_size + led_spacing) )
					
				#set coordinates as custom data
				multimesh.set_instance_custom_data(id, Color(x,y,z,0.0 ))
				
				var led_color : Color
				match start_state:
					0: #ALL OFF
						led_color = Color(0,0,0,off_alpha)
					1: #ALL ON WHITE
						led_color = Color(1,1,1,on_alpha)
					2: #ALL ON RANDOM COLOR
						led_color = Color(randf(),randf(),randf(), on_alpha)
					3: #GRAY DEPTH
						led_color = Color(x/float(led_dimensions.z),y/float(led_dimensions.z),z/float(led_dimensions.z), on_alpha)
				
		
				led_positions.append(led_position)
				led_colors.append(led_color)
				
				multimesh.set_instance_transform(id, Transform3D(Basis(), led_position))
				id+= 1;
				
	#move multimesh to center front of camera
	array_size = led_dimensions * (led_size + led_spacing)
	position = Vector3(
		-array_size.x/2.0,
		-array_size.y/2.0,
		-array_size.z*1.5
	)
	

	#gen3Dtexture()

func gen3Dtexture()->void:
	var img_size:Vector3i= led_dimensions
	image_array = []
	for z in led_dimensions.z:
		var led_color : Color
		var color_image = Image.create(led_dimensions.x, led_dimensions.y, false, Image.FORMAT_RGBAF)
		for x in led_dimensions.x:
			for y in led_dimensions.y:
				match start_state:
					0: #ALL OFF
						led_color = Color(0,0,0,off_alpha)
		
					1: #ALL ON WHITE
						led_color = Color(1,1,1,on_alpha)
					2: #ALL ON RANDOM COLOR
						led_color = Color(randf(),randf(),randf(), on_alpha)
					3: #GRAY DEPTH
						led_color = Color(x/float(led_dimensions.x),y/float(led_dimensions.y),z/float(led_dimensions.z), on_alpha)
				color_image.set_pixel(x,y,led_color)
		image_array.append(color_image)
	
	
	var it3D := ImageTexture3D.new()
	it3D.create(Image.FORMAT_RGBAF,img_size.x,img_size.y, img_size.z,false,image_array)
	color3D = it3D
	material_override.set_shader_parameter("color3D", color3D)
	
func gen2Dtexture()->void:
	var image_size :int = ceil(sqrt(num_leds))+1
	var color_image = Image.create(image_size, image_size, false, Image.FORMAT_RGBAF)
	for i in num_leds:
		var pixel_pos := Vector2i(int(i%image_size),int(i/float(image_size)))
		color_image.set_pixel(pixel_pos.x, pixel_pos.y, Color(led_colors[i]))
	var color_texture = ImageTexture.create_from_image(color_image)
	material_override.set_shader_parameter("color2D", color_texture)
	
