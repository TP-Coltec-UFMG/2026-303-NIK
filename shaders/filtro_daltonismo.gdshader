shader_type canvas_item;

// 0: normal
// 1: protanopia (simular), 2: deuteranopia (simular), 3: tritanopia (simular)
// 4: protanopia (corrigir), 5: deuteranopia (corrigir), 6: tritanopia (corrigir)
uniform int filter_mode : hint_range(0, 6) = 0; 
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

void fragment() {
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    vec3 rgb = original_color.rgb;
    vec3 simulated = rgb;

    if (filter_mode == 1 || filter_mode == 4) { 
        simulated.r = rgb.r * 0.56667 + rgb.g * 0.43333;
        simulated.g = rgb.r * 0.55833 + rgb.g * 0.44167;
        simulated.b = rgb.g * 0.24167 + rgb.b * 0.75833;
    } 
    else if (filter_mode == 2 || filter_mode == 5) { 
        simulated.r = rgb.r * 0.625   + rgb.g * 0.375;
        simulated.g = rgb.r * 0.70    + rgb.g * 0.30;
        simulated.b = rgb.g * 0.30    + rgb.b * 0.70;
    } 
    else if (filter_mode == 3 || filter_mode == 6) { 
        simulated.r = rgb.r * 0.95    + rgb.g * 0.05;
        simulated.g = rgb.r * 0.0     + rgb.g * 0.43333 + rgb.b * 0.56667;
        simulated.b = rgb.g * 0.475   + rgb.b * 0.525;
    }

    vec3 target_color = rgb;

    if (filter_mode >= 4) {
        vec3 error = rgb - simulated;
        vec3 correction = vec3(0.0);
        
        if (filter_mode == 4 || filter_mode == 5) {
            correction.g = (error.r * 0.7) + (error.g * 1.0);
            correction.b = (error.r * 0.7) + (error.b * 1.0);
        } else if (filter_mode == 6) {
            correction.r = (error.r * 1.0) + (error.b * 0.7);
            correction.g = (error.g * 1.0) + (error.b * 0.7);
        }
        
        target_color = rgb + correction;
    } else {
        target_color = simulated;
    }

    vec3 final_rgb = mix(rgb, target_color, intensity);
    
    COLOR = vec4(final_rgb, original_color.a);
}