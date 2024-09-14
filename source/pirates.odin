
package pirates

import "core:fmt"
import "core:math/linalg"

import rl "vendor:raylib"

v2 :: [2]f32

WORLD_MIN_X :: (-WORLD_TILE_COUNT_X/2) * tile_width
WORLD_MAX_X ::  (WORLD_TILE_COUNT_X/2) * tile_width

WORLD_MIN_Y :: (-WORLD_TILE_COUNT_Y/2) * tile_height
WORLD_MAX_Y ::  (WORLD_TILE_COUNT_Y/2) * tile_height

WORLD_MIN :: v2 {WORLD_MIN_X, WORLD_MIN_Y}
WORLD_MAX :: v2 {WORLD_MAX_X, WORLD_MAX_Y}


Cannon_State :: enum { Inactive, Aiming, Fired }


is_paused: bool
camera: rl.Camera2D
cannon_state: Cannon_State
cannon_aim: v2

CANNON_AIM_MAG :: 10
CANNONBALL_VEL_INIT :: 100

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
    if rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_1) {
        switch cannon_state {
            case .Inactive: cannon_state = .Aiming
            case .Aiming:   // still aiming
            case .Fired:    // nothing - one frame time-out
        }
    } else {
        switch cannon_state {
            case .Inactive: // still inactive
            case .Aiming:   cannon_state = .Fired
            case .Fired:    cannon_state = .Inactive
        }
    }

    player := get_player()

    { // player update
        ship_update(player, get_left_stick())

        switch cannon_state {
            case .Inactive: // do nothing

            case .Aiming:
                cannon_aim = get_right_stick() * CANNON_AIM_MAG

            case .Fired: 
                e := Entity {
                    type = .Cannonball,
                    variant = Cannonball {
                        origin = player.pos,
                        target = player.pos + cannon_aim, // TODO: this is wrong
                    },
                    pos = player.pos,
                    vel = linalg.normalize0(cannon_aim) * CANNONBALL_VEL_INIT,
                }
                append(&entities, e)
        }
    }

    for i := 1; i < len(entities);  {
        e := &entities[i]

        removed := false

        switch e.type {
            case .Player: // ignore

            case .Enemy:
                //ship_update(&e, get_ai_move(e))

            case .Cannonball:
                v := e.variant.(Cannonball)

                t := linalg.unlerp(v.origin, v.target, e.pos)
                if t.x >= 1 || t.y >= 1 {
                    unordered_remove(&entities, i)
                    removed = true
                }

                entity_move(e, {}, 0)
        }

        if !removed do i += 1
    }

    camera.target = player.pos
    camera.offset = screen_end()*.5
}

CANNONBALL_SCALE_MAX :: 2

draw :: proc() {
    rl.ClearBackground(hex_color(0x60EBDB))

    {
        rl.BeginMode2D(camera)
        defer rl.EndMode2D()

        world_tiles_draw(camera)

        for e in entities {
            switch v in e.variant {
                case Ship:
                    draw_sprite(ship_sprites[v.sprite], e.pos, v.rot - 90)

                case Cannonball:
                    t := linalg.unlerp(v.origin, v.target, e.pos)


                    draw_sprite(cannonball_sprite, e.pos, 0)
            }
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