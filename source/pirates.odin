
package pirates

import "core:fmt"

import rl "vendor:raylib"

v2 :: [2]f32

WORLD_MIN_X :: (-WORLD_TILE_COUNT_X/2) * tile_width
WORLD_MAX_X ::  (WORLD_TILE_COUNT_X/2) * tile_width

WORLD_MIN_Y :: (-WORLD_TILE_COUNT_Y/2) * tile_height
WORLD_MAX_Y ::  (WORLD_TILE_COUNT_Y/2) * tile_height

WORLD_MIN :: v2 {WORLD_MIN_X, WORLD_MIN_Y}
WORLD_MAX :: v2 {WORLD_MAX_X, WORLD_MAX_Y}




is_paused: bool
camera: rl.Camera2D


init :: proc() {
    rl.InitWindow(1280, 720, "VERY COOL PIRATE GAME YES")

    font_init()
    sprites_init()
    tiles_init()                        
    world_tiles_init()
    entities_init()

    camera.zoom = 1

    when false {
        gen_labeled_tilesheet_as_png()
    }
}

update :: proc() {
    dt := rl.GetFrameTime()

    player := get_player()

    ship_update(player, get_left_stick())

    for &e in entities[1:] {
        switch e.type {
            case .Player: // ignore

            case .Enemy:
                ship_update(&e, get_ai_move(e))

            case .Cannonball:
                //entity_move(&e)
        }
    }

    camera.target = player.pos
    camera.offset = screen_end()*.5
}

draw :: proc() {
    rl.ClearBackground(hex_color(0x60EBDB))

    {
        rl.BeginMode2D(camera)
        defer rl.EndMode2D()

        world_tiles_draw(camera)

        //for e in entities 
        {
            e := get_player()^
            it := create_world_tile_iterator(e)

            for wti in world_tile_iterate(&it) {
                size := v2 {tile_width, tile_height}
                rl.DrawRectangleV(wti.world_pos, size, rl.BLACK)
            }

            draw_sprite(e.sprite, e.pos, e.rot - 90)
        }
    }

    when true {
        rl.DrawFPS(5,5)
    }
}

main :: proc() {
    init()

    for !rl.WindowShouldClose() {
        free_all(context.temp_allocator)

        update()

        rl.BeginDrawing()
        draw()
        rl.EndDrawing()
    }
}