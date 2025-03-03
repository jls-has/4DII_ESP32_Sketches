#[compute]
#version 450

// set the number of invocations
layout (local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer Positions {
    vec3 data[];
	
} pos;

layout(set = 0, binding = 1, std430) restrict buffer Velocities {
    vec3 data[];
} vel;

// declare shader parameters
// we do not need to rewrite them here so the variable is readonly
layout(set = 0, binding = 2, std430) restrict readonly buffer custom_parameters {
	float num_agents;
	float agent_speed;
	float turn_speed;
	float fade_speed;
	float blur_speed;
	float blur_radius;
	float sensor_radius;
	float sensor_offset_dist;
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
layout(set = 0, binding = 3, rgba32f) readonly restrict uniform image2D input_texture;
layout(set = 0, binding = 4, rgba32f) writeonly restrict uniform image2D output_texture;




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
	if(agent_index >= params.num_agents) {return;}

	vec2 agent_pos = vec2(pos.data[agent_index].x, pos.data[agent_index].y) ;
    vec2 agent_vel = vec2(vel.data[agent_index].x,vel.data[agent_index].y);
	
	uint randi = hash(uint(agent_pos.y * params.screen_width + agent_pos.x + hash(uint(agent_index))));
	float randf = randi / 4294967295.0;

	//add screen edge behavior
	if (agent_pos.x >= params.screen_width-5 || agent_pos.x <= 5){
		agent_vel.x *= -1.0;
		agent_vel = normalize(agent_vel);
	}
	if (agent_pos.y >= params.screen_height-5 || agent_pos.y <= 5){
		agent_vel.y *= -1.0;
		agent_vel = normalize(agent_vel);
	}
	

	

	//move agent
	vec2 new_pos = agent_pos + (agent_vel * params.agent_speed * params.delta_time);


	if (params.frame < 1.0){
		new_pos = vec2(params.screen_width/2.0, params.screen_height/2.0);
	}

	//
	pos.data[agent_index] = vec3(new_pos.x, new_pos.y, 0.0);
	vel.data[agent_index] = vec3(agent_vel.x, agent_vel.y, 0.0);

	//draw
	ivec2 texel_coords = ivec2(new_pos.x, new_pos.y);
	vec4 texel = vec4(1.0,1.0,1.0,1.0);
	imageStore(output_texture, texel_coords, texel);
}

void main() {
	
	update_agents();

}