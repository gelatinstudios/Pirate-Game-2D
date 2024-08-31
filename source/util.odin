
package pirates

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