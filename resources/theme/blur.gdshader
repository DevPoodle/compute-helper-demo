shader_type canvas_item;

uniform vec4 bg_color : source_color;
uniform float blur_amount : hint_range(0.0, 10.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
    COLOR = vec4(mix(textureLod(screen_texture, SCREEN_UV, 1.0).rgb, bg_color.rgb, bg_color.a), blur_amount);
}
