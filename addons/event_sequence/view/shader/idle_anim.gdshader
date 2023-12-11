shader_type canvas_item;

void vertex() {
	UV.x = (UV.x + TIME);
}