
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

rand_bool :: proc(n := 2) -> bool {
	return rand.int_max(n) == 0
}