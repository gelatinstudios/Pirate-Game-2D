
package pirates

import "core:strings"
import "core:math/linalg"
import "core:math/rand"

import rl "vendor:raylib"

Entity_Type :: enum u8 {
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
    LAND_FRICTION :: SHIP_FRICTION * 15
    SHIP_MAX_VEL :: 70 // not really max, used for rotation

    dt := rl.GetFrameTime()

    a := angle_to_v2(e.rot)
    b := linalg.normalize0(input)

    vel_t := linalg.length(e.vel) / SHIP_MAX_VEL
    vel_t = clamp(vel_t*dt, 0, 1)

    new_dir := linalg.lerp(a, b, vel_t)
    e.rot = v2_to_angle(new_dir)

    t := linalg.dot(input * SHIP_ACC, new_dir)

    friction: f32 = SHIP_FRICTION
    if pos_has_land(e.pos) {
        friction += LAND_FRICTION
    }

    entity_move(e, input * SHIP_ACC * t, friction)
}




get_ai_move :: proc(e: Entity) -> v2 {
    target := get_player().pos
    return linalg.normalize0(target - e.pos)
}



PLAYER_ENTITY_INDEX :: 0

ENEMY_COUNT :: 2048

entities: [dynamic]Entity

entities_init :: proc() {
    player_sprite :: "ship (3)"

    add_ship(player_sprite, .Player)

    ship_sprites: [dynamic]string
    defer delete(ship_sprites)

    for name in sprites {
        if name != player_sprite && strings.contains(name, "ship") {
            append(&ship_sprites, name)
        }
    }

    for _ in 0 ..< ENEMY_COUNT {
        add_ship(rand.choice(ship_sprites[:]), .Enemy)
    }
}

add_entity :: proc(type: Entity_Type, sprite_name: string, pos: v2, rot: f32 = 0, scale: f32 = 1) {
    entity := Entity {
        type = type,
        sprite = sprites[sprite_name],
        pos = pos,
        rot = rot,
        scale = scale,
    }
    append(&entities, entity)
}

add_ship :: proc(sprite_name: string, type: Entity_Type) {
    pos := rand_pos()
    for pos_has_land(pos) {
        pos = rand_pos()
    }

    add_entity(type, sprite_name, pos, rot = rand.float32_uniform(0, 360))
}

get_player :: proc() -> ^Entity {
    return &entities[PLAYER_ENTITY_INDEX]
}

