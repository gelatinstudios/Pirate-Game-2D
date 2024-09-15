
package pirates

import "core:math"
import "core:math/rand"

import rl "vendor:raylib"

hex_color :: proc(n: u32) -> rl.Color {
    return {
        u8(n >> 16),
        u8(n >>  8),
        u8(n >>  0),
        255,
    }
}

screen_center :: proc() -> v2 {
    x := f32(rl.GetScreenWidth()) * .5
    y := f32(rl.GetScreenHeight()) * .5
    return {x, y}
}

screen_end :: proc() -> v2 {
    x := f32(rl.GetScreenWidth())
    y := f32(rl.GetScreenHeight())
    return {x, y}
}

get_left_stick :: proc() -> v2 {
    return {
        rl.GetGamepadAxisMovement(0, .LEFT_X),
        rl.GetGamepadAxisMovement(0, .LEFT_Y),
    }
}

get_right_stick :: proc() -> v2 {
    return {
        rl.GetGamepadAxisMovement(0, .RIGHT_X),
        rl.GetGamepadAxisMovement(0, .RIGHT_Y),
    }
}


angle_to_v2 :: proc(angle: f32) -> v2 {
    a := rl.DEG2RAD * angle
    return {
        math.cos(a),
        math.sin(a),
    }
}

v2_to_angle :: proc(v: v2) -> f32 {
    return rl.RAD2DEG * math.atan2(v.y, v.x)
}

cos :: proc(x: f32) -> f32 {
    return math.cos(x*rl.DEG2RAD)
}

sin :: proc(x: f32) -> f32 {
    return math.sin(x*rl.DEG2RAD)
}

get_vertices :: proc(e: Entity) -> [4]v2 {
    rot: f32 = 0
    if ship, ok := e.variant.(Ship); ok {
        rot = ship.rot
    }

    x_axis := v2 {sin(rot), -cos(rot)}
    y_axis := v2 {x_axis.y, -x_axis.x}

    dims := get_entity_dims(e)

    x_extent := x_axis * f32(dims.x) * 0.5
    y_extent := y_axis * f32(dims.y) * 0.5

    return {
        e.pos - x_extent - y_extent,
        e.pos + x_extent - y_extent,
        e.pos - x_extent + y_extent,
        e.pos + x_extent + y_extent,
    }
}


rand_pos :: proc() -> v2 {
    return {
        rand.float32_uniform(WORLD_MIN_X, WORLD_MAX_X),
        rand.float32_uniform(WORLD_MIN_Y, WORLD_MAX_Y),
    }
}

rand_bool :: proc(n := 2) -> bool {
    return rand.int_max(n) == 0
}

rand_angle :: proc() -> f32 {
    return rand.float32_uniform(0, 360)
}


f32_normalize :: proc(x: f32) -> f32 {
    if math.is_nan(x) || math.is_inf(x) {
        return 0
    }
    return x
}