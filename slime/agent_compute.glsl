#[compute]
#version 450

struct Agent {
	vec2 position;
	float angle;
};

layout(set = 0, binding = 0, std430) readonly buffer custom_parameters {
	float rand_num;
	float screen_x;
	float screen_y;
	float speed; //premultiplied by delta
	float turn_speed; //premultiplied by delta
	float look_ahead;
	float fov;
	float trail; //premultiplied by delta
	float sensor_extend;
}
parameters;

layout(set = 0, binding = 1, std430) buffer agents_array {
	Agent[] agent_values;
}
agents;

layout(set = 0, binding = 2, rgba32f) readonly uniform image2D input_texture;
layout(set = 0, binding = 3, rgba32f) writeonly restrict uniform image2D output_texture;

float rand(float id) {
	return fract(id * parameters.rand_num * 0.624 - 15.578);
}

float sense(Agent current_agent, float angle) {
	vec2 center = current_agent.position + vec2(cos(angle), sin(angle)) * parameters.look_ahead;
	vec4 color_info;
	
	if (center.x <= parameters.look_ahead + 1.0 || center.x >= parameters.screen_x - 1.0 - parameters.look_ahead || center.y <= parameters.look_ahead + 1.0 || center.y >= parameters.screen_y - 1.0 - parameters.look_ahead) {
		return 0.0;
	}
	
	int sensor_size = int(parameters.sensor_extend);
	float total = 0.0;
	for (int x = -sensor_size; x <= sensor_size; x++) {
		for (int y = -sensor_size; y <= sensor_size; y++) {
			color_info = imageLoad(input_texture, ivec2(center + vec2(x, y)));
			total += color_info.r * color_info.a;
		}
	}
	return total;
}

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
void main() {
	uint id = gl_GlobalInvocationID.x;
	Agent current_agent = agents.agent_values[id];
	current_agent.position += vec2(cos(current_agent.angle), sin(current_agent.angle)) * parameters.speed;
	
	vec2 screen_res = vec2(parameters.screen_x, parameters.screen_y);
	float rng = rand(id);

	float a = sense(current_agent, current_agent.angle);
	float b = sense(current_agent, current_agent.angle - parameters.fov);
	float c = sense(current_agent, current_agent.angle + parameters.fov);
	if (!(a > b && a > c)) {
		if (a < b && a < c)
			current_agent.angle += parameters.turn_speed * (2.0 * rng - 1.0);
		else if (b > c)
			current_agent.angle -= parameters.turn_speed * rng;
		else if (c > b)
			current_agent.angle += parameters.turn_speed * rng;
	}

	current_agent.position = clamp(current_agent.position, vec2(1.0), screen_res - vec2(1.0));
	current_agent.angle += 6.2832 * rng * (step(0.5, length(step(current_agent.position, vec2(1.0)) + step(screen_res - vec2(1.0), current_agent.position))));

	agents.agent_values[id] = current_agent;

	vec4 trail = vec4(vec3(parameters.trail), 0.0) + imageLoad(input_texture, ivec2(current_agent.position));
	imageStore(output_texture, ivec2(current_agent.position), trail);
}