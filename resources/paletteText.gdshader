shader_type canvas_item;

uniform int num_colorsPalette : hint_range(0, 3) = 0;
uniform sampler2D palette;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 c = COLOR;
	COLOR.r = 1.0;
	COLOR.g = 1.0;
	COLOR.b = 1.0;
	vec4 va = c*texture(palette, vec2(float(num_colorsPalette)/4.0, 0.0));
	COLOR *= va;
}
