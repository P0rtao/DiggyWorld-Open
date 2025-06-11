shader_type canvas_item;

uniform float radius : hint_range(0, 1152, 1) = 1152.0;
uniform vec2 center = vec2(576, 324);

void fragment() {
	float x = UV.x * 1152.0;
	float y = UV.y * 648.0;

	float alpha = float((x - center.x) * (x - center.x) + (y - center.y) * (y - center.y) > radius * radius);

	COLOR.a = alpha;
}

