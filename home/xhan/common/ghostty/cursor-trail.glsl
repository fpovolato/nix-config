// Cursor trail for Ghostty: a fading smear from the previous cursor
// position to the current one. Uses Ghostty's cursor shader uniforms.

const float DURATION = 0.15;    // Seconds until the trail disappears.
const float MIN_DISTANCE = 1.5; // In line heights; skips short moves such as typing.
const float OPACITY = 0.6;

float sdBox(vec2 p, vec2 halfSize) {
    vec2 d = abs(p) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Distance to a box swept along the segment from a to b.
float sdSweptBox(vec2 p, vec2 a, vec2 b, vec2 halfSize) {
    vec2 ab = b - a;
    float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0);
    return sdBox(p - (a + ab * t), halfSize);
}

// Cursor xy is the top-left corner in pixels, with y pointing up.
vec2 cursorCenter(vec4 cursor) {
    return vec2(cursor.x + cursor.z * 0.5, cursor.y - cursor.w * 0.5);
}

float easeOutCubic(float x) {
    return 1.0 - pow(1.0 - x, 3.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    if (iFocus == 0 || iCursorVisible == 0) {
        return;
    }

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    vec2 current = cursorCenter(iCurrentCursor);
    vec2 previous = cursorCenter(iPreviousCursor);
    vec2 halfSize = iCurrentCursor.zw * 0.5;
    if (progress >= 1.0
        || distance(current, previous) < iCurrentCursor.w * MIN_DISTANCE) {
        return;
    }

    // The tail catches up with the cursor while the trail fades out.
    vec2 tail = mix(previous, current, easeOutCubic(progress));
    float mask = 1.0 - smoothstep(-1.0, 1.0, sdSweptBox(fragCoord, tail, current, halfSize));
    // Leave the real cursor untouched.
    mask *= step(0.0, sdBox(fragCoord - current, halfSize));

    float alpha = mask * OPACITY * (1.0 - progress);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, alpha);
}
