shader_type canvas_item;
uniform sampler2D wallOilGoopFire;
uniform sampler2D toxicIce;
uniform float deltaTime;

const float diff = 0.0078125;

const float minVal = 0.01;
const float fireDestory = 0.5;
const float fireBurnRate = 0.025;
const float fireSpreadRate = 0.05;

void fragment() {	
	vec2[8] dists = {UV + vec2(diff, 0.0), UV + vec2(-diff, 0.0), 
					UV + vec2(0.0, diff), UV + vec2(0.0, -diff),
					UV + vec2(diff, diff), UV + vec2(-diff, diff), 
					UV + vec2(-diff, -diff), UV + vec2(diff, -diff)};
					
	vec4 wallOilGoopFireVal = texture(wallOilGoopFire,UV);
	
	float wall = wallOilGoopFireVal.x;
	float oil = wallOilGoopFireVal.y;
	float fire = wallOilGoopFireVal.w;
	float goop = wallOilGoopFireVal.z;
	
	if (fire > minVal) {
		fire += oil;
		oil = 0.0;
	}
	
	fire -= fireBurnRate * deltaTime;
	
	if (wall > minVal) {
		for (int i = 0; i < 8; i++) {
			vec4 wallOilGoopFireOther = texture(wallOilGoopFire,dists[i]);
			
			if (wallOilGoopFireOther.w > minVal) {
				wall -= wallOilGoopFireOther.w * fireDestory * deltaTime;
			}
		}
	} else {
		for (int i = 0; i < 8; i++) {
			vec4 wallOilGoopFireOther = texture(wallOilGoopFire,dists[i]);
			
			if (wallOilGoopFireOther.w > minVal) {
				fire += oil + (wallOilGoopFireOther.w * fireSpreadRate * deltaTime);
				
				oil = 0.0;
			}
			if (wallOilGoopFireOther.x <= minVal) {
				fire -= fire * fireSpreadRate * deltaTime;
			}
		}
	}
	
}
