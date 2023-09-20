uniform int gameWidth = 400;
uniform int gameHeight = 240;
uniform int showbadcolors = 0;

const vec4 originalcolors[4] = vec4[4](
	vec4(1.0,1.0,1.0,1.0), //white
	vec4(0.0,0.0,0.0,1.0), //black
	vec4(1.0,0.0,0.0,1.0), //red
	vec4(0.0,0.0,1.0,1.0)  //blue
);

uniform vec4 newcolors[4] = vec4[4](
	vec4(1.0,1.0,1.0,1.0),  //white
	vec4(0.0,0.0,0.0,1.0),  //black
	vec4(0.5,0.5,0.5,1.0),  //dgray
	vec4(0.25,0.25,0.25,1.0)//lgray
);

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	
	vec4 pixel = Texel(tex, texture_coords);
	for(int i=0; i<4; i++){
		if(pixel == originalcolors[i]){
			return newcolors[i];
		}
	}
	
	if(showbadcolors == 0){
	
		if(mod(floor(texture_coords.x * gameWidth + texture_coords.y * gameHeight),2) == 0){
			return vec4(1.0,0.0,1.0,1.0);
		}
		else{
			return vec4(0.0,0.0,0.0,1.0);
		}
	}else{
		return pixel;
	}
	
}