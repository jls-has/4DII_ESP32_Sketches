#[compute]
#version 450

// set the number of invocations
layout (local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer Positions {
    vec4 data[];
	
} pos;

layout(set = 0, binding = 1, std430) restrict buffer Velocities {
    vec4 data[];
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
layout(set = 0, binding = 5, rgba32f) restrict uniform image2D output_texture;




uint hash(uint state){
	state ^= 2747636319u;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	return state;
}

vec4 sense(vec3 _sensor) {
	vec4 sum = vec4(0,0,0,0);
	int r = int(params.sensor_radius);

	for (int x = -r; x<= r; x++){
		for (int y = -r; y <= r; y++){
			for (int z = -r; z <= r; z++){
				ivec3 pos = ivec3(_sensor) + ivec3(x,y,z);
				if (pos.x >= 0 && pos.x <= params.screen_width && pos.y >=0 && pos.y < params.screen_height){
					//sum += imageLoad(output_texture, ivec2(pos.x, pos.y));
					vec4 trail_map = imageLoad(output_texture, ivec2(pos.x, pos.y));
					sum += dot(trail_map, col.data[int(gl_GlobalInvocationID.x)]*2-1);
				}
			}
		}
	}
	return sum;
}

	



/*
vec2 rotate(vec2 _v, float _theta){
	float s = sin(_theta);
	float c = cos(theta);
	return vec2(
		x * c - y * s;
		x * s + y * c;
	);

}
*/

vec3 get_left_sensor(vec3 _v){
	vec3 v = _v;
	float a = params.sensor_angle;
	float s = sin(-a);
	float c = cos(-a);
	vec2 dir = vec2(
		v.x * c - v.y * s,
		v.x * s + v.y * c
	);
	return vec3(dir.x,dir.y,0);
}

vec3 get_right_sensor(vec3 _v){
	vec3 v = _v;
	float a = params.sensor_angle;
	float s = sin(a);
	float c = cos(a);
	vec2 dir = vec2(
		v.x * c - v.y * s,
		v.x * s + v.y * c
	);
	return vec3(dir.x,dir.y,0);
}

vec3 get_random_dir(){
	uint randi = hash(uint(params.frame));
	float randf = randi / 4294967295.0;
	randf = (randf - 0.5) * 2.0;
	vec3 v = vec3(1,1,1) ;
	float a = params.sensor_angle;
	float s = sin(randf);
	float c = cos(randf);
	vec2 dir = vec2(
		v.x * c - v.y * s,
		v.x * s + v.y * c
	);
	return vec3(dir.x,dir.y,0);
}

vec3 get_direction_from_angle(vec3 _vel, float _theta){
	vec3 v = _vel;
	float a = _theta;
	a = a * params.turn_speed * params.delta_time;
	float s = sin(a);
	float c = cos(a);
	vec2 dir = vec2(
		v.x * c - v.y * s,
		v.x * s + v.y * c
	);
	return vec3(dir.x,dir.y,0);

}


void main() {
	
	int agent_index = int(gl_GlobalInvocationID.x);
	if(agent_index >= params.num_agents) {return;}

	vec3 agent_pos = vec3(pos.data[agent_index].x, pos.data[agent_index].y, pos.data[agent_index].z) ;
    vec3 agent_vel = vec3(vel.data[agent_index].x,vel.data[agent_index].y, vel.data[agent_index].z);

	uint randi = hash(uint(agent_pos.y * params.screen_width + agent_pos.x + hash(uint(agent_index))));
	float randf = randi / 4294967295.0;
	
	agent_pos = agent_pos + (agent_vel * params.agent_speed * params.delta_time);
	

	if (params.frame < 1.0){
		agent_pos = vec3(params.screen_width/2.0, params.screen_height/2.0, 0.0);
		agent_vel = normalize(agent_vel);
	}
	//add screen edge behavior
	if (agent_pos.x >= params.screen_width-1 || agent_pos.x <=0){
		agent_vel.x *= -1.0;
		agent_pos.x += agent_vel.x;
		agent_vel = normalize(agent_vel);
		
	}
	if (agent_pos.y >= params.screen_height-1 || agent_pos.y <= 0){
		agent_vel.y *= -1.0;
		agent_pos.y += agent_vel.y;
		agent_vel = normalize(agent_vel);
		
	}

	//get turn_directions
	vec3 turn_left = get_left_sensor(agent_vel);
	vec3 turn_right = get_right_sensor(agent_vel);
	//init sensors
	vec3 left = vec3(agent_pos + turn_left * params.sensor_distance);
	vec3 front = vec3(agent_pos + agent_vel * params.sensor_distance);
	vec3 right = vec3(agent_pos + turn_right * params.sensor_distance);
	//sense
	float w_l= sense(left).a;
	float w_f= sense(front).a;
	float w_r= sense(right).a;
	//choosedirection
	if (w_f > w_l && w_f > w_r){
		agent_vel = agent_vel;
	} else if (w_f < w_l && w_f < w_r){
		agent_vel += normalize(get_direction_from_angle(agent_vel, ((randf - 0.5)*2.0) ))* params.turn_speed * params.delta_time;
	
	}else if (w_l > w_r){
		agent_vel -=normalize(get_direction_from_angle(agent_vel, randf)) * params.turn_speed * params.delta_time;

	} else if (w_r > w_l ){
		agent_vel += normalize(get_direction_from_angle(agent_vel, randf)) * params.turn_speed * params.delta_time;
}
	
		agent_vel = normalize(agent_vel);
	
	/*
	//show sensors
	vec4 red = vec4(1,0,0,1);
	imageStore(output_texture, ivec2(left.x, left.y), red);
	vec4 green = vec4(0,1,0,1);
	imageStore(output_texture, ivec2(front.x, front.y), green);
	vec4 blue = vec4(0,0,1,1);
	imageStore(output_texture, ivec2(right.x, right.y), blue);
	*/

	pos.data[agent_index] = vec4(agent_pos.x, agent_pos.y, agent_pos.z,4.0);
	vel.data[agent_index] = vec4(agent_vel.x, agent_vel.y, agent_vel.z,4.0);

	//draw
	ivec2 texel_coords = ivec2(agent_pos.x, agent_pos.y);

	vec4 prev_texel = imageLoad(output_texture, texel_coords);
	float prev_alpha = prev_texel.a;
	prev_texel *= prev_alpha;
	prev_texel.a = prev_alpha;

	vec4 cur_texel = col.data[agent_index];
	float cur_alpha = params.trail_weight * params.delta_time;
	cur_texel *= cur_alpha;
	cur_texel.a = cur_alpha;

	vec4 texel =  cur_texel; //trailweight * deltaTime * color
	imageStore(output_texture, texel_coords, texel);

}