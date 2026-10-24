struct Params { dash: f32, speed: f32 }

// The border the painter laid down solid, drawn on a pass at a time. Where the
// baked arc map marks a border pixel it is revealed once the drawing head has
// passed it, so the outline traces itself on from its start point, holds whole
// for a beat, then retracts back the way it came and loops. `speed` is how many
// seconds one pass takes (the duration); `dash` is what fraction of a pass the
// finished outline is held before it retracts (the hold). Off the border the
// map reads zero and the pixel is left exactly as painted, so a filled figure
// keeps its fill and only its edge draws.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let c = sample(uv);
    let arc = reveal_order(uv);
    if (arc <= 0.0) {
        return c;
    }
    // Seconds for one pass, and the loop drawn out of them: in, held, out.
    let duration = max(params.speed, 0.0001);
    let hold = clamp(params.dash, 0.0, 1.0) * duration;
    let cycle = 2.0 * duration + hold;
    // Where this frame sits in the loop, from the clip's own first frame.
    let phase = frame.clip_time / cycle;
    let t = (phase - floor(phase)) * cycle;
    // How much of the outline is drawn at this instant: 0 empty, 1 whole.
    var reveal = 1.0;
    if (t < duration) {
        reveal = t / duration;
    } else if (t > duration + hold) {
        reveal = 1.0 - (t - duration - hold) / duration;
    }
    // Solid behind the head and feathered at it, so it reads as a pen drawing
    // the line rather than the whole edge blinking on and off.
    let lit = 1.0 - smoothstep(reveal - 0.03, reveal, arc);
    return vec4<f32>(c.rgb, c.a * lit);
}
