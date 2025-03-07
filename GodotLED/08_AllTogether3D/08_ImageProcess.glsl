#[compute]
#version 450

// set the number of invocations
layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// declare shader parameters
// we do not need to rewrite them here so the variable is readonly
layout(set = 0, binding = 0, std430) restrict readonly buffer custom_parameters {
	float num_agents;
	float trail_weight;
	float agent_speed;
	float turn_speed;
	float fade_speed;
	float blur_speed;
	float blur_radius;
	float sensor_distance;
	float sensor_angle;
	float sensor_radius;
	float screen_width;
	float screen_height;
	float screen_depth;
	float brightness;
	float contrast;
	float delta_time;
	float frame;
} params;

// declare texture inputs
// the format should match the one we specified in the Godot script
layout(set = 0, binding = 1, rgba32f) readonly restrict uniform image2D input_texture;
layout(set = 0, binding = 2, rgba32f) restrict uniform image3D output_texture;


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
	ivec3 id = ivec3(gl_GlobalInvocationID.xyz);
	
	if (id.x <0 || id.x >= params.screen_width || id.y < 0 || id.y >= params.screen_height || id.z < 0 || id.z>=params.screen_depth){
		return;
	}

	// read pixels from the input texture
	vec4 texel = imageLoad(output_texture, id);
	//blur over time
	int sample_radius = int(params.blur_radius);
	int samples = 0;
	vec4 sum = vec4(0,0,0,0);
	for (int offset_x = -sample_radius; offset_x <= sample_radius; offset_x ++){
		for (int offset_y = -sample_radius; offset_y <= sample_radius; offset_y ++){
			for (int offset_z = -sample_radius; offset_z <= sample_radius; offset_z ++){
				int sample_x = id.x + offset_x;
				int sample_y = id.y + offset_y;
				int sample_z = id.z + offset_z;
				samples++;
				

				if (sample_x >= 0 && sample_x < params.screen_width && sample_y >= 0 && sample_y < params.screen_height && sample_z >= 0 && sample_z < params.screen_depth){
					sum += imageLoad(output_texture, ivec3(sample_x, sample_y, sample_z));
					
				}
			}
		}
	}


	vec4 blur_result = sum / float(samples);
	vec4 blurred_value = mix(texel, blur_result, params.blur_speed*params.delta_time);
	blurred_value.a = max(0, blurred_value.a - params.fade_speed*params.delta_time);
	imageStore(output_texture, id, blurred_value);

}
	