shader_type canvas_item;

void fragment() {
    // Get the UV coordinate, which ranges from (0, 0) to (1, 1) across the rect.
    // The center of the rect is (0.5, 0.5).
    vec2 center_uv = UV - vec2(0.5); 
    
    // Calculate the distance from the center.
    // The max distance to a corner is sqrt(0.5^2 + 0.5^2) = 0.707.
    // We normalize the distance so that anything outside a radius of 0.5 is cut off.
    float distance = length(center_uv) * 2.0; 
    
    // Check if the pixel is outside the circle (radius 0.5)
    if (distance > 1.0) {
        // Discard the pixel (make it fully transparent)
        discard;
    } else {
        // Use the ColorRect's color (the default value of COLOR)
        COLOR = COLOR;
    }
}