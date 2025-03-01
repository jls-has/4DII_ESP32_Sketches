#[compute]
#version 450

// set the number of invocations
layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// declare shader parameters
// we do not need to rewrite them here so the variable is readonly
layout(set = 0, binding = 0, std430) restrict readonly buffer custom_parameters {
	float num_agents;
	float agent_speed;
	float fade_speed;
	float blur_speed;
	float blur_radius;
	float screen_width;
	float screen_height;
	float brightness;
	float contrast;
	float delta_time;
	float frame;
} params;


// declare texture inputs
// the format should match the one we specified in the Godot script
layout(set = 0, binding = 1, rgba32f) readonly restrict uniform image2D input_texture;
layout(set = 0, binding = 2, rgba32f) restrict uniform image2D output_texture;


// function to change brightness and contrast
vec4 brightnessContrast( vec4 value, float brightness, float contrast ) { 
	return vec4((value.rgb - 0.5) * (contrast + 1) + 0.5 + brightness, value.a); 
}

uint hash(uint state){
	state ^= 2747636319u;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	return state;
}



void main() {

	// get texel coordinates	
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	
	if (id.x <0 || id.x >= params.screen_width || id.y < 0 || id.y >= params.screen_height){
		return;
	}

	// read pixels from the input texture
	vec4 texel = imageLoad(output_texture, id);

	//fade over time
	//texel.a = max(0, texel.a - params.fade_speed*params.delta_time);
	
	//blur over time
	int sample_radius = int(params.blur_radius);
	int samples = 0;
	vec4 sum = vec4(0,0,0,0);
	for (int offset_x = -sample_radius; offset_x < sample_radius; offset_x ++){
		for (int offset_y = -sample_radius; offset_y < sample_radius; offset_y ++){
			int sample_x = id.x + offset_x;
			int sample_y = id.y + offset_y;
			samples++;
			

			if (sample_x >= 0 && sample_x < params.screen_width && sample_y >= 0 && sample_y < params.screen_height){
				sum += imageLoad(output_texture, ivec2(sample_x, sample_y));
				
			}
		}
	}

	vec4 blur_result = sum / float(samples);

	vec4 blurred_value = mix(texel, blur_result, params.blur_speed*params.delta_time);

	//add the fade
	blurred_value.a = max(0, blurred_value.a - params.fade_speed*params.delta_time);

	imageStore(output_texture, id, blurred_value);

	//create random output
	//uint pixelIndex = uint(gl_GlobalInvocationID.y * params.screen_width + gl_GlobalInvocationID.x);
	//uint psuedoRandomNumber = hash(pixelIndex);
	//float r = psuedoRandomNumber / 4294967295.0;
	//vec4 texel = vec4(r,r,r,1.0);

  	// apply the function to the texel
	//texel = brightnessContrast(texel,params.brightness,params.contrast);

	// write modified pixels to output texture
	//imageStore(output_texture, texel_coords, texel);
}