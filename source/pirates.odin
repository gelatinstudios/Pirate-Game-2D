
package pirates

import rl "vendor:raylib"

v2 :: [2]f32

Entity :: struct {
	sprite: Sprite,
	pos, vel, acc, prev_acc: v2,
}

game: struct {
	is_paused: bool,
	entities: [dynamic]Entity
}

update :: proc() {

}

draw :: proc() {
	rl.ClearBackground(hex_color(0x60EBDB))
}

main :: proc() {
	rl.InitWindow(1280, 720, "VERY COOL PIRATE GAME YES")

	font_init()
	sprites_init()
	tiles_init()

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)

		update()

		rl.BeginDrawing()
		draw()
		rl.EndDrawing()
	}
}