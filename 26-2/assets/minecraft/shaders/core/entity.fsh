#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 flatVertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

// implementation note: this is the global entity shader, please use with caution to prevent state leaks
// entities, block entities and solid block items

// add more as needed
bool shouldSkipApplyLightmap(vec4 color) {
    return
        color.a == 200 ||
        color.a == 255;
}

// adjust as needed
bool shouldDisableShading(vec4 color) {
    return
        color.a == 200 ||
        color.a == 255;
}


void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

    color *= ColorModulator;

    vec4 normalized = color * 255;

    if (shouldDisableShading(normalized)) {
        color *= flatVertexColor;
    }
    else {
    	color *= vertexColor;
    }

#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif

#ifndef EMISSIVE
    if (!shouldSkipApplyLightmap(normalized))
        color *= lightMapColor;
#endif

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
