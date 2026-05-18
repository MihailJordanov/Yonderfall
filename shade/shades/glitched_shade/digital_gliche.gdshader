shader_type canvas_item;

uniform float speed : hint_range(0.0, 20.0, 0.01) = 10.0;
uniform float density : hint_range(1.0, 500.0, 1.0) = 500.0;
uniform float glitch_chance : hint_range(0.0, 1.0, 0.01) = 0.65;
uniform float max_pixels : hint_range(1.0, 20.0, 1.0) = 20.0;

float hash11(float n) {
	return fract(sin(n) * 43758.5453);
}

float hash12(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (base.a < 0.1) {
		COLOR = base;
	} else {
		vec2 texel = TEXTURE_PIXEL_SIZE;
		float t = floor(TIME * speed);

		vec2 block = floor(UV * density);
		float rnd = hash12(block + t);

		vec2 offset = vec2(0.0);

		if (rnd < glitch_chance) {
			float px = floor(hash12(block + t + 10.0) * max_pixels) + 1.0;
			float dir = hash12(block + t + 20.0) < 0.5 ? -1.0 : 1.0;

			offset.x = px * dir * texel.x;
		}
		vec2 offset_r = offset;
		vec2 offset_g = offset * vec2(-0.5, 0.5);
		vec2 offset_b = offset * -1.0;

		vec4 r = texture(TEXTURE, UV + offset_r);
		vec4 g = texture(TEXTURE, UV + offset_g);
		vec4 b = texture(TEXTURE, UV + offset_b);

		COLOR = vec4(r.r, g.g, b.b, base.a);
	}
}