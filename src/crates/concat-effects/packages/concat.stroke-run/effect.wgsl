struct Params { dash: f32, speed: f32 }

// One pass, then gone. The outline draws itself round the figure over
// `speed` seconds - that is the duration, the whole life of the animation -
// and the instant that time is reached the outline is simply off. It does not
// hold, retract, or loop. `dash` is kept only so the uniform layout the host
// fills still lines up; nothing reads it now. Off the border the baked arc map
// reads zero and the pixel is left exactly as painted, so a filled figure
// keeps its fill and only its edge draws.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let c = sample(uv);
    let arc = reveal_order(uv);
    if (arc <= 0.0) {
        return c;
    }
    // The outline's one pass lasts `speed` seconds; past that it is gone.
    let duration = max(params.speed, 0.0001);
    if (frame.clip_time >= duration) {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }
    // How much of the outline is drawn so far: 0 at the start, whole at the
    // end of the pass.
    let reveal = frame.clip_time / duration;
    // Solid behind the pen head and feathered just at it, so it reads as a
    // line being drawn on rather than the whole edge blinking in.
    let lit = 1.0 - smoothstep(reveal - 0.02, reveal, arc);
    return vec4<f32>(c.rgb, c.a * lit);
}
