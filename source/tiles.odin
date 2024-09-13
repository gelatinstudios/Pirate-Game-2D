
package pirates

import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"

Tile_Rotation :: enum u8 {None, Rot90, Rot180, Rot270}
Tile_ID :: distinct u8

tile_width :: 64
tile_height :: 64


tilesheet: rl.Texture
tile_counts: [2]int
tile_count: int


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

    w := int(im.width)
    h := int(im.height)
    tile_counts = {w / tile_width, h / tile_height}
    tile_count = tile_counts.x * tile_counts.y
}

get_tile_rect :: proc(id: Tile_ID) -> rl.Rectangle {
    index := int(id)
    tile_x := index % tile_counts.x
    tile_y := index / tile_counts.x

    return { 
        f32(tile_x) * tile_width, 
        f32(tile_y) * tile_height, 
        tile_width, 
        tile_height 
    }
}

tile_draw :: proc(id: Tile_ID, pos: v2, rot: Tile_Rotation) {
    assert(int(id) < tile_count)

    source := get_tile_rect(id)

    dest := rl.Rectangle {
        pos.x,
        pos.y,
        tile_width,
        tile_height,
    }

    center := v2 {tile_width*.5, tile_height*.5}

    rl.DrawTexturePro(tilesheet, source, dest, center, rot_angles[rot], rl.WHITE)
}



// NOTE: not for in-game-use
gen_labeled_tilesheet_as_png :: proc() {
    padding :: 32
    render_texture := rl.LoadRenderTexture(tilesheet.width  + padding * cast(i32)tile_counts.x, 
                                           tilesheet.height + padding * cast(i32)tile_counts.y)
    defer rl.UnloadRenderTexture(render_texture)

    rl.BeginTextureMode(render_texture)

    id: Tile_ID
    for tile_y in 0..<tile_counts.y {
        for tile_x in 0..<tile_counts.x {
            x := f32(tile_x * (tile_width  + padding))
            y := f32(tile_y * (tile_height + padding) )
            pos := v2 {x, y}

            source := get_tile_rect(id)
            rl.DrawTextureRec(tilesheet, source, pos, rl.WHITE)

            pos.x += tile_width*.5
            pos.y += tile_height + padding*.5

            draw_text(.Regular, rl.WHITE, pos, fmt.ctprint(id))

            id += 1
        }
    }

    rl.EndTextureMode()

    im := rl.LoadImageFromTexture(render_texture.texture)
    rl.ImageFlipVertical(&im)
    rl.ExportImage(im, "tilesheet.png")
}

Tile_Prop_ID :: distinct u8
TILE_PROP_ID_MAX :: 12

tile_prop_tile_id :: proc(id: Tile_Prop_ID) -> (Tile_ID, bool) {
    switch id {
        case  1: return 48, true
        case  2: return 49, true
        case  3: return 50, true
        case  4: return 64, true
        case  5: return 65, true
        case  6: return 66, true
        case  7: return 69, true
        case  8: return 70, true
        case  9: return 71, true
        case 10: return 86, true
        case 11: return 87, true
    }
    return 0, false
}


WORLD_TILE_COUNT_X :: 1000
WORLD_TILE_COUNT_Y :: 1000

World_Tile :: bit_field u16 {
    tile: Tile_ID | 7,
    prop: Tile_Prop_ID | 4,
    rot: Tile_Rotation | 2,
    is_land: bool | 1,
    mark: bool | 1, // various uses
    // we have one more bit...
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
    x := math.floor_div(int(pos.x), tile_width)  + WORLD_TILE_COUNT_X/2
    y := math.floor_div(int(pos.y), tile_height) + WORLD_TILE_COUNT_X/2
    return x, y
}

world_tile_has_land :: proc(x, y: int) -> bool {
    index := world_tile_index(x, y)
    if index >= 0 {
        return world_tiles[index].is_land
    }
    return false
}

pos_has_land :: proc(v: v2) -> bool {
    return world_tile_has_land(pos_to_world_tile(v))
}



world_tiles_init :: proc() {
    WATER :: 72

    for &tile in world_tiles {
        tile.tile = WATER
        tile.is_land = false
        tile.rot = .Rot90
    }

    ISLAND_SQUARE_COUNT :: 1000

    for _ in 0 ..< ISLAND_SQUARE_COUNT {
        start_x := rand.int_max(WORLD_TILE_COUNT_X - 5)
        start_y := rand.int_max(WORLD_TILE_COUNT_Y - 5)

        end_x := clamp(start_x + 3 + rand.int_max(10), 0, WORLD_TILE_COUNT_X-1)
        end_y := clamp(start_y + 3 + rand.int_max(10), 0, WORLD_TILE_COUNT_Y-1)

        for y in start_y ..= end_y {
            for x in start_x ..= end_x {
                wt := &world_tiles[x + y * WORLD_TILE_COUNT_X]
                wt.is_land = true
                wt.mark = true
            }
        }
    }

    for y in 0 ..< WORLD_TILE_COUNT_Y  {
        for x in 0 ..< WORLD_TILE_COUNT_X {
            wt := &world_tiles[x + y * WORLD_TILE_COUNT_X]
            wt.rot = .None

            if wt.is_land {
                land_up    := world_tile_has_land(x + 0, y - 1)
                land_down  := world_tile_has_land(x + 0, y + 1)
                land_left  := world_tile_has_land(x - 1, y + 0)
                land_right := world_tile_has_land(x + 1, y + 0)

                n: u32
                n |= u32(land_up)    << 3
                n |= u32(land_down)  << 2
                n |= u32(land_left)  << 1
                n |= u32(land_right) << 0

                if wt.mark {
                    wt.mark = false
                    switch n {
                        case 0b0101: wt.tile = 0
                        case 0b0111: wt.tile = 1
                        case 0b0110: wt.tile = 2
                        case 0b1101: wt.tile = 16

                        case 0b1111: 
                            if !world_tile_has_land(x + 1, y + 1) {
                                wt.tile = 3
                            } else if !world_tile_has_land(x - 1, y + 1) {
                                wt.tile = 4
                            } else if !world_tile_has_land(x + 1, y - 1) {
                                wt.tile = 19
                            } else if !world_tile_has_land(x - 1, y - 1) {
                                wt.tile = 20
                            } else {
                                if rand_bool() {
                                    wt.tile = 67
                                } else {
                                    wt.tile = 68
                                }

                                wt.rot = rand.choice_enum(Tile_Rotation)

                                if rand.int_max(7) == 0 {
                                    wt.prop = auto_cast rand.int_max(TILE_PROP_ID_MAX)
                                }
                            }

                        case 0b1110: wt.tile = 18
                        case 0b1001: wt.tile = 32
                        case 0b1011: wt.tile = 33
                        case 0b1010: wt.tile = 34
                    }
                } else {
                    switch n {
                        case 0b0101: wt.tile = 5
                        case 0b0111: wt.tile = rand_bool() ? 6 : 7
                        case 0b0110: wt.tile = 8
                        case 0b1101: wt.tile = rand_bool() ? 21 : 37

                        case 0b1111: 
                            if !world_tile_has_land(x + 1, y + 1) {
                                wt.tile = 35
                            } else if !world_tile_has_land(x - 1, y + 1) {
                                wt.tile = 36
                            } else if !world_tile_has_land(x + 1, y - 1) {
                                wt.tile = 51
                            } else if !world_tile_has_land(x - 1, y - 1) {
                                wt.tile = 52
                            } else {
                                switch rand.int_max(4) {
                                    case 0: wt.tile = 22
                                    case 1: wt.tile = 23
                                    case 2: wt.tile = 38
                                    case 3: wt.tile = 39
                                }

                                wt.rot = rand.choice_enum(Tile_Rotation)

                                if rand.int_max(7) == 0 {
                                    wt.prop = auto_cast rand.int_max(TILE_PROP_ID_MAX)
                                }
                            }

                        case 0b1110: wt.tile = rand_bool() ? 24 : 40
                        case 0b1001: wt.tile = 53
                        case 0b1011: wt.tile = rand_bool() ? 54 : 55
                        case 0b1010: wt.tile = 56
                    }
                }
            }
        }
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


                tile_draw(72, pos, .Rot90)
                tile_draw(tile.tile, pos, rot)

                id, ok := tile_prop_tile_id(tile.prop)
                if ok {
                    tile_draw(id, pos, rot)
                }
            }
        }
    }
}


World_Tile_Iterator :: struct {
    current: [2]int,
    start, end: [2]int,
}

create_world_tile_iterator :: proc(e: Entity) -> World_Tile_Iterator {
    min_x := max(f32)
    min_y := max(f32)
    max_x := min(f32)
    max_y := min(f32)
    for v in get_vertices(e) {
        min_x = min(min_x, v.x)
        min_y = min(min_y, v.y)
        max_x = max(max_x, v.x)
        max_y = max(max_y, v.y)
    }

    result: World_Tile_Iterator 
    result.start.x, result.start.y = pos_to_world_tile(v2 {min_x, min_y})
    result.end.x, result.end.y = pos_to_world_tile(v2 {max_x, max_y})
    result.current = result.start
    return result
}

World_Tile_Info :: struct {
    wt: World_Tile,
    tile_pos: [2]int,
    world_pos: v2,
}

world_tile_iterate :: proc(it: ^World_Tile_Iterator) -> (result: World_Tile_Info, cont: bool) {
    if world_tile_in_bounds(it.current.x, it.current.y) {
        result.wt = world_tiles[it.current.x + it.current.y * WORLD_TILE_COUNT_Y]
        result.tile_pos = it.current
        result.world_pos = world_tile_to_pos(it.current.x, it.current.y)
    }

    cont = it.current.x == it.end.x || it.current.y <= it.end.y
    it.current.x += 1
    if it.current.x > it.end.x {
        it.current.x = it.start.x
        it.current.y += 1
    }

    return
}