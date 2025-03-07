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

layout(set = 0, binding = 2, std430) restrict buffer Colors {
    vec4 data[];
} col;

// declare shader parameters
// we do not need to rewrite them here so the variable is readonly
layout(set = 0, binding = 3, std430) restrict readonly buffer custom_parameters {
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
layout(set = 0, binding = 4, rgba32f) readonly restrict uniform image2D input_texture;
layout(set = 0, binding = 5, rgba32f) restrict uniform image3D color_texture;




uint hash(uint state){
	state ^= 2747636319u;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	return state;
}

/*
float sense(vec3 _pos){
	float sum = 0.0;
	vec3 sensor_pos = _pos  * params.sensor_offset_dist;
	int radius = int(params.sensor_radius);

	for (int x = -radius; x <= radius; x++){
		for (int y = -radius; y <= radius; y++){
			for (int z = -radius; z <= radius; z++){
				vec3 pos = sensor_pos + vec3(x,y,z);
				if (x >= 0 && x < params.screen_width && y >= 0 && y < params.screen_height && z >= 0 && z <params.screen_depth){
					vec4 color = imageLoad(color_texture, ivec3(x, y, z));
					sum += color.a;
				}
			}		
		}
	}

	return sum;
}
*/

void update_agents(){
	
	int agent_index = int(gl_GlobalInvocationID.x);
	if(agent_index >= params.num_agents) {return;}

	vec3 agent_pos = vec3(pos.data[agent_index].x, pos.data[agent_index].y, pos.data[agent_index].z) ;
    vec3 agent_vel = vec3(vel.data[agent_index].x, vel.data[agent_index].y, vel.data[agent_index].z);
	
	uint randi = hash(uint(agent_pos.y * params.screen_width + agent_pos.x + hash(uint(agent_index))));
	float randf = randi / 4294967295.0;

	//add screen edge behavior
	if (agent_pos.x >= params.screen_width || agent_pos.x <= 0.0){
		agent_vel.x *= -1.0;
		agent_vel = normalize(agent_vel);
	}
	if (agent_pos.y >= params.screen_height || agent_pos.y <= 0.0){
		agent_vel.y *= -1.0;
		agent_vel = normalize(agent_vel);
	}
	if (agent_pos.z >= params.screen_depth || agent_pos.z <= 0.0){
		agent_vel.z *= -1.0;
		agent_vel = normalize(agent_vel);
	}
	
	/*

	//steer based on sensory data
	
	float w_forward = sense(agent_pos + agent_vel);
	float w_left = sense(agent_pos - vec3(1,0,0) + agent_vel);
	float w_right = sense(agent_pos + vec3(1,0,0)+ agent_vel);
	float w_up = sense(agent_pos - vec3(0,1,0)+ agent_vel);
	float w_down = sense(agent_pos + vec3(0,1,0) +agent_vel);
	float random_steer = randf;
	
	if (w_forward < w_left && w_forward < w_right && w_forward < w_up && w_forward <w_down){
		//steer randomly if forward is weakest
		agent_vel.x += (random_steer-0.5) * 2.0 * params.turn_speed * params.delta_time;

	} else {
		agent_vel.x += (w_right - w_left)*params.turn_speed*params.delta_time;
		agent_vel.y += (w_down - w_up)*params.turn_speed*params.delta_time;
		normalize(agent_vel);
	}
	*/
	//move agent
	vec3 new_pos = agent_pos + (agent_vel * params.agent_speed * params.delta_time);


	if (params.frame < 1.0){
		new_pos = vec3(params.screen_width/2.0, params.screen_height/2.0, params.screen_depth/2.0);
	}

	//
	pos.data[agent_index] = vec3(new_pos.x, new_pos.y,new_pos.z);
	vel.data[agent_index] = vec3(agent_vel.x, agent_vel.y, agent_vel.z);

	//draw
	ivec3 texel_coords = ivec3(new_pos.x, new_pos.y, new_pos.z);
	vec4 texel = vec4(1.0,1.0,1.0,1.0);
	imageStore(color_texture, texel_coords, texel);
}



void main() {
	
	update_agents();

}