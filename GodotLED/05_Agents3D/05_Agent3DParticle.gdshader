shader_type particles;


uniform sampler2D position_texture;

float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}
void start() {
	uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
	uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
	uint alt_seed3 = hash(NUMBER + uint(43) + RANDOM_SEED);
	uint alt_seed4 = hash(NUMBER + uint(111) + RANDOM_SEED);

	CUSTOM.x = rand_from_seed(alt_seed1);

	vec3 position = vec3(0,0,0);
	TRANSFORM[3].xyz = position;



	}

void process() {
	ivec2 pos_image_size = textureSize(position_texture, 0);
	ivec2 texel_pos = ivec2(
		int(mod(float(INDEX), float( pos_image_size.x))),
		int(float(INDEX)/float(pos_image_size.x)));

	vec4 position = texelFetch(position_texture, texel_pos, 0);
	TRANSFORM[3].xyz = vec3(position.x,position.y,position.z);
	//VELOCITY.y = -1.0;
	/*ivec2 img_size = textureSize(position_texture,0);
	vec2 pixel_pos = vec2(float(INDEX)/float(img_size.x), mod(float(INDEX), float(img_size.y)));
	vec3 position = texture(position_texture, pixel_pos).xyz;
	TRANSFORM[3].xyz = position;
	*/
}
