shader_type spatial;
render_mode unshaded;

uniform float num_leds;
uniform sampler2D color_texture;

varying vec4 color;

void vertex() {
	ivec2 color_texture_size = textureSize(color_texture, 0);
	ivec2 texel_pos = ivec2(
		int(mod(float(INSTANCE_ID), float( color_texture_size.x))),
		int(float(INSTANCE_ID)/float(color_texture_size.x)));
	
	//color = texture(color_texture, pixel_pos);
	color = texelFetch(color_texture, texel_pos, 0);
	//COLOR = vec4(float(INSTANCE_ID)/num_leds);


}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
