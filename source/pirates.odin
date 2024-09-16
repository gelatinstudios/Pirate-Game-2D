
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
    ui_init()
    tiles_init()                        
    world_tiles_init()
    entities_init()

    camera.zoom = 1

    when false {
        gen_labeled_tilesheet_as_png()
    }

    fmt.println("entity size =", size_of(Entity), "bytes")
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

    world_tile_entity_map_set()

    player := get_player()
    player_ship := &player.variant.(Ship)

    { // player update
        ship_update(player, get_left_stick())

        switch cannon_state {
            case .Inactive: // do nothing

            case .Aiming:
                cannon_aim = get_right_stick() * CANNON_AIM_MAG

            case .Fired: 
                vel := linalg.normalize0(cannon_aim) * CANNONBALL_VEL_INIT
                vel += player.vel
                e := Entity {
                    type = .Cannonball,
                    variant = Cannonball {
                        origin = player.pos,
                        target = player.pos + cannon_aim * 12, // TODO: this is wrong
                        vel_from_player = player.vel,
                    },
                    pos = player.pos,
                    vel = vel,
                }
                append(&entities, e)
        }

        // TEST
        when true {
            if rl.IsGamepadButtonPressed(0, .LEFT_FACE_DOWN) do player_ship.health -= 10
            if rl.IsGamepadButtonPressed(0, .LEFT_FACE_UP)   do player_ship.health += 10
        }
    }

    dt := rl.GetFrameTime()

    entities_to_remove: [dynamic]i16
    defer delete(entities_to_remove)

    for &e, i in entities {
        switch e.type {
            case .Player: // ignore

            case .Enemy:
                ship := &e.variant.(Ship)

                if ship.health == 0 {
                    append(&entities_to_remove, i16(i))
                }

            case .Cannonball:
                v := &e.variant.(Cannonball)

                t := linalg.unlerp(v.origin, v.target, e.pos)

                t.x = f32_normalize(t.x)
                t.y = f32_normalize(t.y)

                if t.x >= 1 || t.y >= 1 {
                    append(&entities_to_remove, i16(i))

                    // check if cannonball hit ship
                    indices := world_tile_entities(pos_to_world_tile(e.pos))

                    for i in indices {
                        e := &entities[i]


                        ship, ok := &e.variant.(Ship)

                        if ok {
                            damage_ship(ship, 10)
                        }
                    }
                }

                avg_t := (t.x+t.y)*.5

                if avg_t > .5 {
                    v.scale = (1 - (avg_t - .5)*2)*CANNONBALL_SCALE_MAX
                } else {
                    v.scale = avg_t*2*CANNONBALL_SCALE_MAX
                }

                v.origin += dt * v.vel_from_player
                v.target += dt * v.vel_from_player

                entity_move(&e, {}, 0)
        }
    }

    for i in entities_to_remove {
        unordered_remove(&entities, int(i))
    }

    camera.target = player.pos
    camera.offset = screen_end()*.5
}

CANNONBALL_SCALE_MAX :: 2

draw :: proc() {
    rl.ClearBackground(hex_color(0xff00ff))

    {
        rl.BeginMode2D(camera)
        defer rl.EndMode2D()

        world_tiles_draw(camera)

        for e in entities {
            switch v in e.variant {
                case Ship:
                    draw_sprite(ship_sprites[v.sprite], e.pos, v.rot - 90)

                    health_bar_padding :: 10

                    l := cast(f32) max(get_entity_dims(e).x, get_entity_dims(e).y)

                    health_bar_start := e.pos
                    health_bar_start.x -= l*.5
                    health_bar_start.y += l*.5 + health_bar_padding

                    health_bar_end := health_bar_start
                    health_bar_end.x += l

                    // TODO: do this in the ui draw!
                    draw_health_bar(health_bar_start, health_bar_end, v.health)

                case Cannonball:
                    draw_sprite(cannonball_sprite, e.pos, 0, v.scale)
            }
        }
    }

    draw_ui()

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