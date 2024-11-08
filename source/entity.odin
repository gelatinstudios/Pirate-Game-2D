
package pirates

import "core:strings"
import "core:math/linalg"
import "core:math/rand"

import rl "vendor:raylib"

SHIP_INITIAL_CANNON_COUNT :: 4
SHIP_MAX_CANNONS :: 16

Ship :: struct {
    sprite: i32, // ship sprite index
    rot: f32,
    health: f32,
    cannon_state: Cannon_State,
    cannon_aim: v2,
    cannon_count: i32,
    cannon_timers: [SHIP_MAX_CANNONS]f32,
}

damage_ship :: proc(s: ^Ship, damage: f32) {
    s.health = clamp(s.health - damage, 0, SHIP_HEALTH_MAX)
}

Cannonball :: struct {
    origin, target: v2,
    vel_from_player: v2,
    scale: f32,
}

EXPLOSION_TIME :: 0.5

Explosion :: struct {
    timer: f32,
    sprite: Sprite,
}

Entity_Variant :: union { Ship, Cannonball, Explosion }

Entity :: struct {
    variant: Entity_Variant,
    pos, vel: v2,
}

entity_move :: proc(e: ^Entity, acc: v2, friction: f32) {
    dt := rl.GetFrameTime()
    e.pos += dt*e.vel + dt*dt*acc
    e.vel += dt*acc

    e.vel *= 1 - friction
}

get_entity_dims :: proc(e: Entity) -> [2]i32 {
    switch _ in e.variant {
        case Ship: return ship_dims
        case Cannonball: return cannonball_dims
        case Explosion: unreachable()
    }
    unreachable()
}

get_entity_dims_max :: proc(e: Entity) -> i32 {
    dims := get_entity_dims(e)
    return max(dims.x, dims.y)
}



ship_update :: proc(e: ^Entity, input: v2, cannon_aim: v2) {
    ship := &e.variant.(Ship)   

    {// movement update
        SHIP_ACC :: 20
        SHIP_FRICTION :: 0.0001
        LAND_FRICTION :: SHIP_FRICTION * 15
        SHIP_MAX_VEL :: 70 // not really max, used for rotation

        dt := rl.GetFrameTime()

        a := angle_to_v2(ship.rot)
        b := linalg.normalize0(input)

        vel_t := linalg.length(e.vel) / SHIP_MAX_VEL
        vel_t = clamp(vel_t*dt, 0, 1)

        new_dir := linalg.lerp(a, b, vel_t)
        ship.rot = v2_to_angle(new_dir)

        t := linalg.dot(input * SHIP_ACC, new_dir)

        friction: f32 = SHIP_FRICTION
        if pos_has_land(e.pos) {
            friction += LAND_FRICTION
        }

        entity_move(e, input * SHIP_ACC * t, friction)
    }

    {// cannon stuff update
        if linalg.length(cannon_aim) > 0 {
            switch ship.cannon_state {
                case .Inactive: ship.cannon_state = .Aiming
                case .Aiming:   // still aiming
                case .Fired:    // nothing - one frame time-out
            }
        } else {
            switch ship.cannon_state {
                case .Inactive: // still inactive
                case .Aiming:   ship.cannon_state = .Fired
                case .Fired:    ship.cannon_state = .Inactive
            }
        }

        switch ship.cannon_state {
            case .Inactive: // do nothing

            case .Aiming:
                ship.cannon_aim = cannon_aim

            case .Fired:
                for &c in ship.cannon_timers[:ship.cannon_count] {
                    if c <= 0 {
                        c = CANNONBALL_GEN_TIME

                        vel := linalg.normalize0(ship.cannon_aim) * CANNONBALL_VEL_INIT
                        vel += e.vel
                        e := Entity {
                            variant = Cannonball {
                                origin = e.pos,
                                target = e.pos + ship.cannon_aim * 12, // TODO: this is wrong
                                vel_from_player = e.vel,
                            },
                            pos = e.pos,
                            vel = vel,
                        }
                        append(&entities, e)
                        
                        break
                    }
                }
        }
    }
}




get_ai_move :: proc(e: Entity) -> v2 {
    target := get_player().pos
    return linalg.normalize0(target - e.pos)
}



PLAYER_ENTITY_INDEX :: 0
ENEMY_COUNT :: 2048

SHIP_HEALTH_MAX :: 1024
CANNONBALL_GEN_TIME :: 2

entities: [dynamic]Entity

ship_dims: [2]i32
cannonball_dims: [2]i32

player_sprite_index :: 3

entities_init :: proc() {
    add_ship(player_sprite_index)

    ship_sprite := sprites["ship (1)"]
    ship_dims.x = i32(ship_sprite.width)
    ship_dims.y = i32(ship_sprite.height)

    cannonball_dims.x = i32(cannonball_sprite.width)
    cannonball_dims.y = i32(cannonball_sprite.height)
}

add_ship :: proc(sprite: i32) {
    pos := rand_pos()
    for pos_has_land(pos) {
        pos = rand_pos()
    }

    e := Entity {
        variant = Ship {
            sprite = sprite,
            health = SHIP_HEALTH_MAX,
            cannon_count = SHIP_INITIAL_CANNON_COUNT,
        },
        pos = pos,
    }
    append(&entities, e)
}

add_enemy :: proc() {
    sprite: i32
    for sprite == 0 || sprite == player_sprite_index {
        sprite = auto_cast rand.int_max(len(ship_sprites))
    }
    add_ship(sprite)
}

fake_player := Entity {
    variant = Ship {}
}

get_player :: proc() -> ^Entity {
    if player_is_alive {
        return &entities[PLAYER_ENTITY_INDEX]
    } else {
        return &fake_player
    }
}

