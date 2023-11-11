shader_type canvas_item;

uniform sampler2D wallOilGoopFire;
uniform sampler2D toxicIce;
uniform sampler2D noise: repeat_enable;
uniform vec2 viewPos;
uniform vec2 viewSize;
uniform float time;

const float minVal = 0.01;


const vec4 wallColor = vec4(1.0,1.0,0.9,1.0);
const vec4 wallBrokenColor = vec4(1.0, 0.89, 0.58, 1.0);
const vec3 iceColor = vec3(0.55,0.7,1.0);
const vec3 oilColor = vec3(0.25,0.3,0.25);
const vec3 goopColor = vec3(0.3,1.0,0.4);
const vec3 tileColor = vec3(0.10,0.15,0.125);
const vec3 toxicColor = vec3(1.0,0.4,0.8);
const vec3 fireColor = vec3(1.0,0.5,0.6);

void fragment() {
	vec2 view = UV * viewSize + viewPos;
	//vec2 view = vec2(1.2,1.2);
	if (view.x > 1.0 || view.y > 1.0 || view.x < 0.0 || view.y < 0.0) {
		COLOR = wallColor;
	} else {
		vec4 wallOilGoopFireVal = texture(wallOilGoopFire,view);
		
		float wall = wallOilGoopFireVal.x;
		if (wall > minVal) {
			COLOR = mix(wallBrokenColor, wallColor, wall);
		} else {
			vec4 toxicIceVal = texture(toxicIce,view);
			
			float ice = toxicIceVal.y;
			float oil = wallOilGoopFireVal.y;
			float goop = wallOilGoopFireVal.z;
			vec3 baseColor;
			
			vec4 noiseValue = texture(noise,view);
			
			float rBase = (ice + oil + goop) * noiseValue.x;
			if (rBase < ice) {
				baseColor = iceColor;
			} else if (rBase < ice+oil) {
				baseColor = oilColor;
			} else if (rBase < ice+oil+goop) {
				baseColor = goopColor;
			} else {
				baseColor = tileColor;
			}

			float fire = wallOilGoopFireVal.w;
			float toxic = toxicIceVal.x;
			float rGas = noiseValue.y + time * 0.5;
			rGas = (toxic + fire + 0.5) * (rGas - floor(rGas));
			
			if (rGas < toxic) {
				float mixValue = (rGas) / toxic - 0.5;
				mixValue = -2.0 * mixValue * mixValue + 0.5;
				COLOR = vec4(mix(baseColor,toxicColor, mixValue), 1.0);
			} else if (rGas < toxic+fire) {
				float mixValue = (rGas-toxic)/fire - 0.5;
				mixValue = -2.0 * mixValue * mixValue + 0.5;
				COLOR = vec4(mix(baseColor,fireColor, mixValue), 1.0);
			} else {
				COLOR = vec4(baseColor,1.0);
			}
		}
	}
}
