shader_type canvas_item;

uniform sampler2D gradient : filter_linear;

void fragment() {
	float value = texture(TEXTURE, UV).r;
	vec4 color = texture(gradient, vec2(value, 0.0));
	COLOR = vec4(color.xyz, 1.0);
}
