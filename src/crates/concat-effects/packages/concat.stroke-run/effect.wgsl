struct Params { dash: f32, speed: f32 }

// One pass over the clip's own length. The host hands `speed` the clip's
// duration in seconds, so the outline draws itself round the figure across
// exactly the time the clip is on screen: trim the clip on the track and the
// drawing speeds up or slows down to match, the way a built-in sticker's
// entrance does. It finishes a hair before the last frame, so the closing
// segment is fully drawn and holds whole to the cut - no loop, no hold past
// the end, no retract. Off the border the baked arc map reads zero and the
// pixel is left exactly as painted; the map is baked a touch wider than the
// border so its soft edge is covered too, leaving no faint rim behind. `dash`
// is kept only so the uniform layout the host fills still lines up.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let c = sample(uv);
    let arc = reveal_order(uv);
    if (arc <= 0.0) {
        return c;
    }
    // The pass spans the clip: `speed` is the clip's length in seconds, so
    // dragging the clip's edge on the track is what sets the duration.
    let duration = max(params.speed, 0.0001);
    let progress = clamp(frame.clip_time / duration, 0.0, 1.0);
    // Run the reveal a little past the far end of the arc so the last pixel
    // is fully lit by the final frame rather than caught in the pen's tip.
    let reveal = progress * 1.06;
    // A soft tip behind the pen head, so the line is drawn on rather than
    // appearing in hard steps.
    let lit = 1.0 - smoothstep(reveal - 0.06, reveal, arc);
    return vec4<f32>(c.rgb, c.a * lit);
}
