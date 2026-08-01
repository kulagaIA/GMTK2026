shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform float rotation_speed: hint_range(0.0, 10.0) = 1.0;
uniform float duplicate_distance: hint_range(0.0, 0.2) = 0.1;
uniform int duplicate_count: hint_range(0, 10) = 2;
uniform float opacity: hint_range(0, 1.0) = .75; 

void fragment() {
	vec4 accumulated_color = vec4(0);
	for (int i = 0; i < duplicate_count; ++i) {
		float offset = 2.0 * PI / float(duplicate_count) * float(i) + TIME * rotation_speed;
		vec2 uv_offset = vec2(cos(offset), sin(offset)) * duplicate_distance;
		accumulated_color += vec4(texture(SCREEN_TEXTURE, UV + uv_offset).rgb, 0.0);
	}
	accumulated_color /= float(duplicate_count);
	COLOR = vec4(accumulated_color.rgb, opacity);
}