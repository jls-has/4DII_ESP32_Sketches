#[compute]
#version 450

// set the number of invocations
layout (local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer Agent_Data_Buffer {
    vec3 data[];
	//pos.x, pos.y, angle
} agents;

// declare shader parameters
// we do not need to rewrite them here so the variable is readonly
layout(set = 0, binding = 1, std430) restrict readonly buffer custom_parameters {
	float num_agents;
	float agent_speed;
	float screen_width;
	float screen_height;
	float brightness;
	float contrast;
	float delta_time;
} params;


// declare texture inputs
// the format should match the one we specified in the Godot script
layout(set = 0, binding = 2, rgba32f) readonly restrict uniform image2D input_texture;
layout(set = 0, binding = 3, rgba32f) writeonly restrict uniform image2D output_texture;


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

void update_agents(){
	int agent_index = int(gl_GlobalInvocationID.x);
	if(agent_index >= params.num_agents) return;
	vec2 agent_pos = vec2(agents.data[agent_index].x, agents.data[agent_index].y) ;
    float agent_angle = agents.data[agent_index].z;
	uint random = hash(
		uint(
			agent_pos.y * params.screen_width + agent_pos.x + hash(uint(agent_index))
			)
		);

	//move agent
	vec2 direction = vec2(cos(agent_angle), sin(agent_angle));
	vec2 new_pos = agent_pos + direction * params.agent_speed * params.delta_time;
	//clamp position and choose new angle
	//float new_angle = agent_angle;

	//set new position
	//agent_angle = new_angle;
	agents.data[agent_index] = vec3(new_pos.x, new_pos.y, agent_angle);
	agents.data[0] = vec3(params.agent_speed,params.delta_time,agent_index);

	//draw
	ivec2 texel_coords = ivec2(new_pos.x, new_pos.y);
	vec4 texel = vec4(1.0,1.0,1.0,1.0);
	imageStore(output_texture, texel_coords, texel);
}

void main() {
	
	update_agents();

	// get texel coordinates	
	//ivec2 texel_coords = ivec2(gl_GlobalInvocationID.xy);

	// read pixels from the input texture
	//vec4 texel = imageLoad(input_texture, texel_coords);

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