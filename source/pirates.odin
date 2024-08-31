
package pirates

import "core:fmt"

import rl "vendor:raylib"

v2 :: [2]f32

Entity :: struct {
	sprite: Sprite,
	pos, vel, acc, prev_acc: v2,
}

game: struct {
	is_paused: bool,
	camera: rl.Camera2D,
	entities: [dynamic]Entity
}

game_init :: proc() {
	game.camera.zoom = 1
}

update :: proc() {
	dt := rl.GetFrameTime()

	VEL :: 100
	if rl.IsKeyDown(.LEFT)  do game.camera.target.x -= dt * VEL
	if rl.IsKeyDown(.RIGHT) do game.camera.target.x += dt * VEL
	if rl.IsKeyDown(.UP)    do game.camera.target.y -= dt * VEL
	if rl.IsKeyDown(.DOWN)  do game.camera.target.y += dt * VEL

	game.camera.offset = screen_end()*.5
}

draw :: proc() {
	rl.ClearBackground(hex_color(0x60EBDB))

	rl.BeginMode2D(game.camera)
	world_tiles_draw(game.camera)
	rl.EndMode2D()
}

main :: proc() {
	rl.InitWindow(1280, 720, "VERY COOL PIRATE GAME YES")

	font_init()
	sprites_init()
	tiles_init()
	world_tiles_init()
	game_init()

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)

		update()

		rl.BeginDrawing()
		draw()
		rl.EndDrawing()
	}
}