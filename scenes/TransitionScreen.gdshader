shader_type canvas_item;

uniform int colorNum = 4;
uniform float alpha = 1.0f;
uniform float crossfade = 0.0f;
uniform sampler2D colorPalettePrev;
uniform sampler2D colorPaletteCurr;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 p1 =  texture(colorPaletteCurr, vec2(0.0, 0.f));
	vec4 p2 =  texture(colorPalettePrev, vec2(0.0, 0.f));
	vec3 aux = vec3(p1.x, p1.y, p1.z);
	vec3 aux1 = vec3(p2.x, p2.y, p2.z);
	COLOR = vec4(mix(aux1, aux, crossfade), alpha);
	//COLOR = vec4(color.w, 0, 1, 1.);
}
