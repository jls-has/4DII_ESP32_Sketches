shader_type spatial;
render_mode unshaded;

uniform float num_leds;
uniform sampler2D color_texture;

void vertex() {
	COLOR = vec4(float(INSTANCE_ID)/num_leds);
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
