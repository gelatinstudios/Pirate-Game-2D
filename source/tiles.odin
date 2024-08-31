
package pirates

import rl "vendor:raylib"

tilesheet: rl.Texture

tile_width :: 64
tile_height :: 64

tile_counts: [2]i32
tile_count: i32

tiles_init :: proc() {
	png_data :: #load("../assets/Tilesheet/tiles_sheet.png")
	im := rl.LoadImageFromMemory(".png", raw_data(png_data), i32(len(png_data)))
	defer rl.UnloadImage(im)
	tilesheet = rl.LoadTextureFromImage(im)

	tile_counts = {im.width / tile_width, im.height / tile_height}
	tile_count = tile_counts.x * tile_counts.y
}

tile_draw :: proc(index: i32, pos: v2) {
	assert(index < tile_count)

	tile_x := index % tile_counts.x
	tile_y := index / tile_counts.x
	source := rl.Rectangle { f32(tile_x), f32(tile_y), tile_width, tile_height }

	rl.DrawTextureRec(tilesheet, source, pos, rl.WHITE)
}