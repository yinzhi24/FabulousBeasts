extern number dissolve;
extern number time;
extern vec4 texture_details;
extern vec2 image_details;
extern bool shadow;
extern vec4 burn_colour_1;
extern vec4 burn_colour_2;

extern vec2 mouse_screen_pos;
extern number screen_scale;
extern number hovering;

/* Steamodded sends this for the fb_refined edition shader. */
extern vec2 refined;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords) {
    if (dissolve < 0.001) {
        return tex;
    }

    float noise =
        sin(texture_coords.x * 91.7 + time * 3.1) *
        sin(texture_coords.y * 73.3 - time * 2.7);

    float threshold = dissolve * 2.0 - 1.0;

    if (noise < threshold) {
        tex.a *= 0.0;
    }

    if (abs(noise - threshold) < 0.08) {
        tex.rgb = mix(tex.rgb, burn_colour_1.rgb, 0.65);
        tex.rgb = mix(tex.rgb, burn_colour_2.rgb, 0.25);
    }

    return tex;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 tex = Texel(texture, texture_coords);

    tex = dissolve_mask(tex, texture_coords);

    if (tex.a <= 0.0) {
        return tex * colour;
    }

    float keepalive =
        sin(
            mouse_screen_pos.x * 0.00011 +
            mouse_screen_pos.y * 0.00013 +
            screen_scale * 0.017 +
            hovering * 0.031 +
            dissolve * 0.047 +
            texture_details.x * 0.00001 +
            texture_details.y * 0.00001 +
            texture_details.z * 0.00001 +
            texture_details.w * 0.00001 +
            image_details.x * 0.00001 +
            image_details.y * 0.00001 +
            refined.x * 0.013 +
            refined.y * 0.017
        );

    float diagonal = texture_coords.x + texture_coords.y;
    float counter = texture_coords.x - texture_coords.y;
    float swirl = atan(texture_coords.y - 0.5, texture_coords.x - 0.5);
    float radius = distance(texture_coords, vec2(0.5, 0.5));

    float stream_a = sin(diagonal * 24.0 + swirl * 3.0 + time * 5.5 + keepalive * 0.02 + refined.x * 0.05) * 0.5 + 0.5;
    float stream_b = sin(counter * 28.0 - swirl * 4.0 - time * 6.2 + keepalive * 0.02 + refined.y * 0.05) * 0.5 + 0.5;
    float ring = sin(radius * 60.0 - time * 7.0) * 0.5 + 0.5;

    vec3 jade = vec3(0.22, 0.72, 0.52);
    vec3 deep_jade = vec3(0.08, 0.38, 0.28);
    vec3 gold = vec3(1.00, 0.78, 0.25);
    vec3 amber = vec3(0.90, 0.42, 0.06);
    vec3 white_gold = vec3(1.00, 0.96, 0.72);

    vec3 base_col = mix(deep_jade, jade, stream_a);
    vec3 flow_col = mix(amber, gold, stream_b);
    vec3 refined_col = mix(base_col, flow_col, 0.55);

    float shimmer = pow(max(stream_a, stream_b), 7.0) * (0.55 + 0.25 * sin(time * 8.0));
    float center_glow = pow(1.0 - radius * 1.7, 3.0);
    center_glow = clamp(center_glow, 0.0, 1.0);

    refined_col = mix(refined_col, white_gold, shimmer + center_glow * 0.25 + ring * 0.08);

    if (shadow) {
        refined_col *= 0.55;
    }

    vec3 final_rgb = tex.rgb * refined_col * (1.30 + hovering * 0.05);

    return vec4(final_rgb, tex.a) * colour;
}
