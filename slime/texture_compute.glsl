#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly buffer custom_parameters {
	float blur_speed; //premultiplied by delta
	float decay_speed; //premultiplied by delta
	float player_trail_radius;
	float player_trail;
	float player_x;
	float player_y;
}
parameters;

layout(set = 0, binding = 1, rgba32f) readonly uniform image2D input_texture;
layout(set = 0, binding = 2, rgba32f) writeonly restrict uniform image2D output_texture;

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
void main() {
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	ivec2 image_size = imageSize(input_texture);
	vec4 center_color = imageLoad(input_texture, id);

	vec2 player_position = vec2(parameters.player_x, parameters.player_y);

	vec4 total_color = vec4(0.0);
	total_color += imageLoad(input_texture, id + ivec2(-1));
	total_color += imageLoad(input_texture, id + ivec2(-1, 0));
	total_color += imageLoad(input_texture, id + ivec2(-1, 1));
	total_color += imageLoad(input_texture, id + ivec2(0, -1));
	total_color += center_color;
	total_color += imageLoad(input_texture, id + ivec2(0, 1));
	total_color += imageLoad(input_texture, id + ivec2(1, -1));
	total_color += imageLoad(input_texture, id + ivec2(1, 0));
	total_color += imageLoad(input_texture, id + ivec2(1));

	vec4 box_blur = vec4(total_color.xyz / 9.0, 1.0);
	vec4 decay = vec4(vec3(parameters.decay_speed), 0.0);

	vec4 final_color = clamp(mix(box_blur, center_color, 1.0 - pow(0.5, parameters.blur_speed)) - decay, 0.0, 1.0);
	final_color = max(final_color, vec4(vec3(parameters.player_trail * step(distance(vec2(id), player_position), parameters.player_trail_radius)), 0.0));
	imageStore(output_texture, id, final_color);
}