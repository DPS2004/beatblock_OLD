vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	vec4 ccol = VideoTexel(texture_coords);
	if (ccol.r + ccol.g + ccol.b >= 1.5){
		return vec4(1,1,1,1);
	} else {
		return vec4(1,0,0,1);
	}
}