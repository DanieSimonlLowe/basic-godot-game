shader_type canvas_item;

uniform float wall[2500];
uniform float oil[2500];
uniform float goop[2500];
uniform float fire[2500];
uniform float black[2500];
uniform vec2 viewPos;
uniform vec2 viewSize;

const float minVal = 0.05;
const uint size = uint(50);

//List
vec2 getPosDiff(uint pos, vec2 view) {
	vec2 posv = vec2( (float(pos % size) + 0.5) / 50.0, (float(pos - (pos % size)) + 25.0) / 2450.0);
	return 50.0 * (view - posv) / viewSize;
}

/**/
uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

float random (vec2 view) {
	uvec2 temp = floatBitsToUint(view);
	uint x = hash(temp.x ^ hash(temp.y));
	
	// remove only get the mantisa
	x &= 0x007FFFFFu;
	x |= 0x3F800000u;
	return uintBitsToFloat(x) - 1.0;
 }

vec3 getBaseColor(uint pos, vec2 view) {
	float sum = 0.0;
	
	if (black[pos] > minVal) {
		sum += black[pos];
	}
	if (goop[pos] > minVal) {
		sum += goop[pos];
	}
	if (oil[pos] > minVal) {
		sum += oil[pos];
	}
	
	
	float prob = random(view) * sum;
	if (prob < black[pos]) {
		return vec3(0,0,0);
	} 
	prob -= black[pos];
	if (prob < goop[pos]) {
		return vec3(0.11, 0.65, 0.06);
	}
	prob -= goop[pos];
	if (prob < oil[pos]) {
		return vec3(0.05, 0.16, 0.13);
	}
	
	return vec3(0.3,0.3,0.3); 
}

float getValue(uint pos, vec2 view) {
	if (fire[pos] <= minVal) {
		return 0.0;
	}
	vec2 diff = getPosDiff(pos, view);
	const float minJoinValue = 7.5;
	
	bool left = diff.x < 0.0 && pos % size > uint(0) && fire[pos-uint(1)] > minJoinValue;
	bool right = diff.x > 0.0 && pos % size < uint(49) && fire[pos+uint(1)] > minJoinValue;
	bool top = diff.y < 0.0 && pos > size && fire[pos-size] > minJoinValue;
	bool bottom = diff.y > 0.0 && pos < uint(2499) && fire[pos+size] > minJoinValue;
	
	float horzVal = 0.0;
	float vertVal = 0.0;
	
	if (!left && !right && !top && !bottom) {
		return fire[pos] / ((diff.x * diff.x) + (diff.y * diff.y));
	} else if (left) {
		horzVal = mix(fire[pos], fire[pos-uint(1)], diff.x + 1.0);
	} else if (right) {
		horzVal = mix(fire[pos], fire[pos+uint(1)], diff.x - 1.0);
	}
	if (top) {
		vertVal = mix(fire[pos], fire[pos-size], diff.y - 1.0);
	} else if (bottom) {
		vertVal = mix(fire[pos], fire[pos+size], diff.y + 1.0);
	}  else { 
		return horzVal / (diff.y * diff.y);
	}
	
	if (!left && !right) {
		return vertVal / (diff.x * diff.x);
	}
	
	if ( (top && left && (pos > uint(50) && fire[pos-size-uint(1)] > minJoinValue)) 
	 || (bottom && left && (pos < uint(2450) && fire[pos+size-uint(1)] > minJoinValue))
	 || (top && right && (pos > uint(48) && fire[pos-size+uint(1)] > minJoinValue)) 
	 || (bottom && right && (pos < uint(2448) && fire[pos+size+uint(1)] > minJoinValue))
	) {
		return max(horzVal, vertVal) * 500.0;
	} else {
		//TODO Make this create a cerve from vert to horz value.
		
		return mix(horzVal / (diff.y * diff.y), vertVal / (diff.x * diff.x), abs(diff.y) / (abs(diff.x) + abs(diff.y)));
	}
	
}



vec3 getBlockColor(uint pos, vec2 view) {
	vec3 color = getBaseColor(pos, view);
	
	float fireVal = getValue(pos,view) * (0.065 + 0.07 * random(view)) ;
	if (fireVal > minVal) {
		const vec3 fireColor = vec3(1, 0.61, 0.33);
		float control = log2(fireVal+1.0)*0.3-0.4;
		if (control > 1.0) {
			return fireColor;
		} else if (control < 0.0) {
			return color;
		}
		return mix(color,fireColor, control);
	} else {
		return color;
	}
}

void fragment() {
	vec2 view = UV * viewSize + viewPos;
	if (view.x > 1.0 || view.y > 1.0 || view.x < 0.0 || view.y < 0.0) {
		COLOR = vec4(0.0,1.0,1.0,1.0);
	}
	uint pos = uint(view.x * 50.0) + size * uint(view.y * 49.0);
	
	if (wall[pos] > minVal) {
		COLOR = mix(vec4(1.0, 0.89, 0.58, 1.0), vec4(1.0,1.0,0.9,1.0), wall[pos]*0.01);
	} else {
		COLOR = vec4(getBlockColor(pos, view), 1.0);
	}
	
}
