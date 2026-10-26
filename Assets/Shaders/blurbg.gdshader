shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float darken_amount : hint_range(0.0, 1.0) = 0.3; 
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 blurred_color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    
    vec3 final_rgb = mix(blurred_color.rgb, vec3(0.0), darken_amount);
    
    COLOR = vec4(final_rgb, blurred_color.a);
}
