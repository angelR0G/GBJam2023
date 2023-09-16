shader_type canvas_item;

uniform int num_colorsPalette;
uniform sampler2D originalPalette;
uniform sampler2D replacePalette;

vec4 replaceColor(vec4 color){
	float incColor = 1.0/float(num_colorsPalette);
	for(float i=0.0; i < 1.0; i+=incColor){
		vec2 uv = vec2 (i, 0.0);
		vec4 color_og = texture(originalPalette, uv);
		if(distance(color, color_og) <= 0.9)
			return texture(replacePalette, uv);
	}
	return color;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR = replaceColor(color);
}
