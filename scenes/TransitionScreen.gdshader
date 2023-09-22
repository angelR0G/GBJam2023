shader_type canvas_item;

uniform int colorNum = 4;
uniform int transitionType = 0; /*0=menu to game, 1=game to game, 2=game to menu*/
uniform float alpha = 1.0f;
uniform float crossfade = 0.0f;
uniform sampler2D colorPaletteMenu;
uniform sampler2D colorPaletteCurr;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 p1 =  texture(colorPaletteCurr, vec2(0.0, 0.f));
	vec4 p2 =  texture(colorPaletteMenu, vec2(0.0, 0.f));
	vec3 aux = vec3(p1.x, p1.y, p1.z);
	vec3 aux1 = vec3(p2.x, p2.y, p2.z);
	vec3 colorTrans;
	if(transitionType==0){
		colorTrans = mix(aux1, aux, crossfade);
	}else if(transitionType == 1){
		colorTrans = aux;
	}else{
		colorTrans = mix(aux, aux1, crossfade);
	}
	COLOR = vec4(colorTrans, alpha);
	//COLOR = vec4(color.w, 0, 1, 1.);
}
