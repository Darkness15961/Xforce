shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0.0, 4.0) = 1.0;
uniform bool enabled = false;
uniform bool pulse = true;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	if (!enabled) {
		COLOR = col;
	} else {
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
		
		// Coordenadas relativas dentro del frame de 32x32 del spritesheet
		float frame_x = mod(UV.x / TEXTURE_PIXEL_SIZE.x, 32.0);
		float frame_y = UV.y / TEXTURE_PIXEL_SIZE.y;
		bool on_frame_edge = (frame_x < 1.0 || frame_x >= 31.0 || frame_y < 1.0 || frame_y >= 31.0);
		
		float a_up = texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
		float a_down = texture(TEXTURE, UV + vec2(0.0, size.y)).a;
		float a_left = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
		float a_right = texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		
		float a_ul = texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		float a_ur = texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		float a_dl = texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		float a_dr = texture(TEXTURE, UV + vec2(size.x, size.y)).a;
		
		float min_neighbor = min(min(min(a_up, a_down), min(a_left, a_right)), min(min(a_ul, a_ur), min(a_dl, a_dr)));
		float max_neighbor = max(max(max(a_up, a_down), max(a_left, a_right)), max(max(a_ul, a_ur), max(a_dl, a_dr)));
		
		float pulse_alpha = 1.0;
		if (pulse) {
			pulse_alpha = 0.82 + 0.18 * sin(TIME * 7.0);
		}
		vec4 border_color = vec4(line_color.rgb, line_color.a * pulse_alpha);
		
		// Borde interno sobre el sprite cuando linda con transparencia o el borde del frame
		if (col.a > 0.5 && (min_neighbor < 0.5 || on_frame_edge)) {
			COLOR = border_color;
		}
		// Borde externo alrededor del sprite cuando hay espacio transparente disponible
		else if (col.a < 0.5 && max_neighbor > 0.5 && !on_frame_edge) {
			COLOR = border_color;
		} else {
			COLOR = col;
		}
	}
}
