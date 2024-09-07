
package pirates

import "core:math/linalg"
import "core:math/rand"

import rl "vendor:raylib"

Entity_Type :: enum {
    Player,
    Enemy,
    Cannonball,
}

Entity :: struct {
    type: Entity_Type,
    sprite: Sprite,
    pos, vel: v2,
    rot, scale: f32,
}

entity_move :: proc(e: ^Entity, acc: v2, friction: f32) {
    dt := rl.GetFrameTime()

    e.pos += dt*e.vel + dt*dt*acc
    e.vel += dt*acc
    e.vel *= 1 - friction
}




ship_update :: proc(e: ^Entity, input: v2) {
    SHIP_ACC :: 20
    SHIP_FRICTION :: 0.0001
    SHIP_MAX_VEL :: 70 // not really max, used for rotation

    dt := rl.GetFrameTime()

    a := angle_to_v2(e.rot)
    b := linalg.normalize0(input)

    vel_t := linalg.length(e.vel) / SHIP_MAX_VEL
    vel_t = clamp(vel_t*dt, 0, 1)

    new_dir := linalg.lerp(a, b, vel_t)
    e.rot = v2_to_angle(new_dir)

    t := linalg.dot(input * SHIP_ACC, new_dir)

    entity_move(e, input * SHIP_ACC * t, SHIP_FRICTION)
}




get_ai_move :: proc(e: Entity) -> v2 {
    // TODO:
    return {}
}



PLAYER_ENTITY_INDEX :: 0

ENEMY_COUNT :: 512

entities: [dynamic]Entity

entities_init :: proc() {
    add_entity("ship (1)", {}, 180)

    for _ in 0 ..< ENEMY_COUNT {
        pos := v2 {
            rand.float32_uniform(WORLD_MIN_X, WORLD_MAX_X),
            rand.float32_uniform(WORLD_MIN_Y, WORLD_MAX_Y),
        }
        rot := rand.float32_uniform(0, 360)
        add_entity("ship (2)", pos, rot)
    }
}

add_entity :: proc(sprite_name: string, pos: v2, rot: f32 = 0, scale: f32 = 1) {
    entity := Entity {
        sprite = sprites[sprite_name],
        pos = pos,
        rot = rot,
        scale = scale,
    }
    append(&entities, entity)
}

get_player :: proc() -> ^Entity {
    return &entities[PLAYER_ENTITY_INDEX]
}

