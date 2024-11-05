
package pirates

import "core:fmt"
import "core:math/linalg"
import "core:slice"

import rl "vendor:raylib"

v2 :: [2]f32

WORLD_MIN_X :: (-WORLD_TILE_COUNT_X/2) * tile_width
WORLD_MAX_X ::  (WORLD_TILE_COUNT_X/2) * tile_width

WORLD_MIN_Y :: (-WORLD_TILE_COUNT_Y/2) * tile_height
WORLD_MAX_Y ::  (WORLD_TILE_COUNT_Y/2) * tile_height

WORLD_MIN :: v2 {WORLD_MIN_X, WORLD_MIN_Y}
WORLD_MAX :: v2 {WORLD_MAX_X, WORLD_MAX_Y}

MAX_ENEMY_COUNT :: 100
ENEMY_SPAWN_BATCH_COUNT :: 10
ENEMY_SPAWN_TIME :: 10

Cannon_State :: enum { Inactive, Aiming, Fired }


is_paused: bool
camera: rl.Camera2D
player_is_alive: bool
player_last_pos: v2
spawned_enemy_count: int
enemy_spawn_timer: f32

OUT_OF_BOUNDS_DAMAGE :: 50

CANNON_AIM_MAX :: 10
CANNONBALL_VEL_INIT :: 100

init :: proc() {
    rl.InitWindow(1280, 720, "VERY COOL PIRATE GAME YES")

    font_init()
    sprites_init()
    ui_init()
    tiles_init()
    world_tiles_init()
    entities_init()
    enemy_ai_init()

    camera.zoom = 1
    player_is_alive = true // might move to level begin or something

    when false {
        gen_labeled_tilesheet_as_png()
    }

    fmt.println("entity size =", size_of(Entity), "bytes")
}

update :: proc() {
    world_tile_entity_map_set()

     when false { // enemy spawn
        dt := rl.GetFrameTime()

        if spawned_enemy_count < MAX_ENEMY_COUNT {
            enemy_spawn_timer -= dt
            if enemy_spawn_timer <= 0 {
                enemy_spawn_timer = ENEMY_SPAWN_TIME
                spawned_enemy_count += 1

                for _ in 0 ..< ENEMY_SPAWN_BATCH_COUNT {
                    add_enemy()
                }
            }
        }
    } else { // for testing with one enemy
        @(static) b := false
        if !b {
            b = true
            add_enemy()
        }
    }

    update_entities()

    camera.target = player_is_alive ? get_player().pos : player_last_pos
    camera.offset = screen_end()*.5
}

update_entities :: proc() {
    dt := rl.GetFrameTime()

    entities_to_remove: [dynamic]i16
    defer delete(entities_to_remove)

    for &e, i in entities do switch &v in e.variant {
        case Ship:
            if i == PLAYER_ENTITY_INDEX {
                cannon_aim: v2
                if rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_1) {
                    cannon_aim = get_right_stick() * CANNON_AIM_MAX
                }
                ship_update(&e, get_left_stick(), cannon_aim)

                // TEST
                when true {
                    if rl.IsGamepadButtonPressed(0, .LEFT_FACE_DOWN) do v.health -= 100
                    if rl.IsGamepadButtonPressed(0, .LEFT_FACE_UP)   do v.health += 100
                }
            } else { // non-players are enemies
                input, cannon_aim := enemy_ai(e)
                ship_update(&e, input, cannon_aim)
            }

            if !pos_in_bounds(e.pos) { // Out-Of-Bounds Damage
                damage_ship(&v, OUT_OF_BOUNDS_DAMAGE * dt)
            }

            if v.health <= 0 { // Ship Death
                append(&entities_to_remove, i16(i))

                explosion := Entity {
                    variant = Explosion {
                        timer = EXPLOSION_TIME
                    },

                    pos = e.pos,
                    vel = {},
                }

                append(&entities, explosion)

                if i == PLAYER_ENTITY_INDEX {
                    player_is_alive = false
                    player_last_pos = e.pos
                }
            }

            // cannon management
            for &c in v.cannon_timers[:v.cannon_count] {
                if c > 0 {
                    c -= dt
                }
            }

        case Cannonball:
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
                        damage_ship(ship, 100)
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

        case Explosion:
            v.timer -= dt
            if v.timer < 0 {
                append(&entities_to_remove, i16(i))
            } else {
                t := (v.timer / EXPLOSION_TIME)
                n := len(explosion_sprites)
                sprite_index := clamp(int(t * f32(n)), 0, n)
                v.sprite = explosion_sprites[sprite_index]
            }
    }

    entities_new_len := 0
    for _, i in entities {
        if !slice.contains(entities_to_remove[:], i16(i)) {
            entities[entities_new_len] = entities[i]
            entities_new_len += 1
        }
    }
    resize(&entities, entities_new_len)
}

CANNONBALL_SCALE_MAX :: 2

draw :: proc() {
    rl.ClearBackground(hex_color(0xABE3F5))

    {
        rl.BeginMode2D(camera)
        defer rl.EndMode2D()

        world_tiles_draw(camera)

        for e in entities {
            switch v in e.variant {
                case Ship:
                    draw_sprite(ship_sprites[v.sprite], e.pos, v.rot - 90)

                    health_bar_padding :: 10

                    dims := get_entity_dims(e)
                    l := cast(f32) get_entity_dims_max(e)

                    health_bar_start := e.pos
                    health_bar_start.x -= l*.5
                    health_bar_start.y += l*.5 + health_bar_padding

                    health_bar_end := health_bar_start
                    health_bar_end.x += l

                    // TODO: do this in the ui draw!
                    draw_health_bar(health_bar_start, health_bar_end, v.health)

                case Cannonball:
                    draw_sprite(cannonball_sprite, e.pos, 0, v.scale)

                case Explosion:
                    draw_sprite(v.sprite, e.pos, 0)
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