
package pirates

import "core:fmt"
import "core:math/linalg"

enemy_attack_radius: f32

enemy_ai_init :: proc() {
    enemy_attack_radius = 2 * cast(f32) get_entity_dims_max(get_player()^)
}

enemy_ai :: proc(e: Entity) -> (dir: v2, cannon_aim: v2) {
    ship := e.variant.(Ship)
    player := get_player()

    to_player := player.pos - e.pos
    dist_to_player := linalg.length(to_player)
    
    if dist_to_player > enemy_attack_radius {
        dir = linalg.normalize0(to_player) * min((dist_to_player / 3000), 1)
    } else if dist_to_player <= CANNON_AIM_MAX {
        cannon_aim = to_player
    }

    return
}