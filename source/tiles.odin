
package pirates

import "core:fmt"
import "core:math/rand"

import rl "vendor:raylib"


tilesheet: rl.Texture

tile_width :: 64
tile_height :: 64

tile_counts: [2]i32
tile_count: i32

Tile_Rotation :: enum u8 {None, Rot90, Rot180, Rot270}

rot_angles := [Tile_Rotation]f32 {
	.None = 0,
	.Rot90 = 90,
	.Rot180 = 180,
	.Rot270 = 270,
}

tiles_init :: proc() {
	png_data :: #load("../assets/Tilesheet/tiles_sheet.png")
	im := rl.LoadImageFromMemory(".png", raw_data(png_data), i32(len(png_data)))
	defer rl.UnloadImage(im)
	tilesheet = rl.LoadTextureFromImage(im)

	tile_counts = {im.width / tile_width, im.height / tile_height}
	tile_count = tile_counts.x * tile_counts.y
}

tile_draw :: proc(index: i32, pos: v2, rot: Tile_Rotation) {
	assert(index < tile_count)

	tile_x := index % tile_counts.x
	tile_y := index / tile_counts.x

	source := rl.Rectangle { 
		f32(tile_x) * tile_width, 
		f32(tile_y) * tile_height, 
		tile_width, 
		tile_height 
	}

	dest := rl.Rectangle {
		pos.x,
		pos.y,
		tile_width,
		tile_height,
	}

	center := v2 {tile_width*.5, tile_height*.5}

	rl.DrawTexturePro(tilesheet, source, dest, center, rot_angles[rot], rl.WHITE)
}



WORLD_TILE_COUNT_X :: 50
WORLD_TILE_COUNT_Y :: 50

World_Tile :: bit_field u16 {
	back_tile_id:  u8 | 7,
	front_tile_id: u8 | 7,
	rot: Tile_Rotation | 2 
}

world_tiles: [WORLD_TILE_COUNT_X * WORLD_TILE_COUNT_Y] World_Tile

world_tile_in_bounds :: proc(x, y: int) -> bool {
	return x >= 0 && x < WORLD_TILE_COUNT_X &&
	       y >= 0 && y < WORLD_TILE_COUNT_Y
}

world_tile_index :: proc(x, y: int) -> int {
	if !world_tile_in_bounds(x, y) do return -1
	return x + y*WORLD_TILE_COUNT_X
}

world_tile_to_pos :: proc(x, y: int) -> v2 {
	return {
		f32(x - WORLD_TILE_COUNT_X/2) * tile_width,
		f32(y - WORLD_TILE_COUNT_Y/2) * tile_height,
	}
}

pos_to_world_tile :: proc(pos: v2) -> (int, int) {
	x := int(pos.x / tile_width)  + WORLD_TILE_COUNT_X/2
	y := int(pos.y / tile_height) + WORLD_TILE_COUNT_X/2
	return x, y
}



world_tiles_init :: proc() {
	for &tile in world_tiles {
		tile.back_tile_id = u8(rand.int31_max(tile_count))
		tile.front_tile_id = u8(rand.int31_max(tile_count))
		tile.rot = rand.choice_enum(Tile_Rotation)
	}
}

world_tiles_draw :: proc(camera: rl.Camera2D) {
	start_x, start_y := pos_to_world_tile(rl.GetScreenToWorld2D({}, camera))
	end_x, end_y     := pos_to_world_tile(rl.GetScreenToWorld2D(screen_end(), camera))

	for tile_y in start_y-1 ..= end_y+1 {
		for tile_x in start_x-1 ..= end_x+1 {
			index := world_tile_index(tile_x, tile_y)

			if index >= 0 && index < len(world_tiles) {
				tile := world_tiles[index]
				pos := world_tile_to_pos(tile_x, tile_y)
				rot := tile.rot

				tile_draw(i32(tile.back_tile_id), pos, rot)
				tile_draw(i32(tile.front_tile_id), pos, rot)
			}
		}
	}
}