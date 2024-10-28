
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

