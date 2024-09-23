
package pirates

import "core:strings"
import "core:strconv"

import rl "vendor:raylib"

Sprite :: rl.Rectangle

sprites := map[string]rl.Rectangle {
    "cannon"         = { x=88,  y=422, width=29, height=16 },
    "cannonBall"     = { x=120, y=29,  width=10, height=10 },
    "cannonLoose"    = { x=439, y=496, width=20, height=12 },
    "cannonMobile"   = { x=408, y=489, width=29, height=20 },
    "crew (1)"       = { x=511, y=489, width=22, height=20 },
    "crew (2)"       = { x=463, y=489, width=22, height=20 },
    "crew (3)"       = { x=487, y=489, width=22, height=20 },
    "crew (4)"       = { x=568, y=469, width=22, height=22 },
    "crew (5)"       = { x=439, y=472, width=22, height=22 },
    "crew (6)"       = { x=544, y=469, width=22, height=22 },
    "dinghyLarge1"   = { x=606, y=145, width=20, height=38 },
    "dinghyLarge2"   = { x=610, y=426, width=20, height=38 },
    "dinghyLarge3"   = { x=588, y=426, width=20, height=38 },
    "dinghySmall1"   = { x=628, y=166, width=16, height=26 },
    "dinghySmall2"   = { x=612, y=110, width=16, height=26 },
    "dinghySmall3"   = { x=628, y=138, width=16, height=26 },
    "explosion1"     = { x=0,   y=0,   width=74, height=75 },
    "explosion2"     = { x=544, y=145, width=60, height=59 },
    "explosion3"     = { x=544, y=426, width=42, height=41 },
    "fire1"          = { x=614, y=466, width=18, height=39 },
    "fire2"          = { x=120, y=0,   width=11, height=27 },
    "flag (1)"       = { x=120, y=41,  width=6,  height=22 },
    "flag (2)"       = { x=600, y=486, width=6,  height=22 },
    "flag (3)"       = { x=630, y=110, width=6,  height=22 },
    "flag (4)"       = { x=128, y=41,  width=6,  height=22 },
    "flag (5)"       = { x=592, y=486, width=6,  height=22 },
    "flag (6)"       = { x=632, y=426, width=6,  height=22 },
    "hullLarge (1)"  = { x=596, y=316, width=50, height=108 },
    "hullLarge (2)"  = { x=544, y=206, width=50, height=108 },
    "hullLarge (3)"  = { x=596, y=206, width=50, height=108 },
    "hullLarge (4)"  = { x=544, y=316, width=50, height=108 },
    "hullSmall (1)"  = { x=612, y=0,   width=40, height=108 },
    "hullSmall (2)"  = { x=648, y=330, width=40, height=108 },
    "hullSmall (3)"  = { x=648, y=110, width=40, height=108 },
    "hullSmall (4)"  = { x=648, y=220, width=40, height=108 },
    "nest"           = { x=592, y=466, width=20, height=18 },
    "pole"           = { x=119, y=422, width=12, height=11 },
    "sailLarge (1)"  = { x=408, y=279, width=66, height=47 },
    "sailLarge (10)" = { x=408, y=328, width=66, height=46 },
    "sailLarge (11)" = { x=408, y=376, width=66, height=46 },
    "sailLarge (12)" = { x=408, y=424, width=66, height=46 },
    "sailLarge (13)" = { x=476, y=0,   width=66, height=47 },
    "sailLarge (14)" = { x=476, y=49,  width=66, height=47 },
    "sailLarge (15)" = { x=136, y=460, width=66, height=47 },
    "sailLarge (16)" = { x=68,  y=460, width=66, height=47 },
    "sailLarge (17)" = { x=476, y=98,  width=66, height=47 },
    "sailLarge (18)" = { x=476, y=147, width=66, height=47 },
    "sailLarge (19)" = { x=476, y=293, width=66, height=47 },
    "sailLarge (2)"  = { x=272, y=460, width=66, height=47 },
    "sailLarge (20)" = { x=204, y=460, width=66, height=47 },
    "sailLarge (21)" = { x=340, y=460, width=66, height=47 },
    "sailLarge (22)" = { x=476, y=244, width=66, height=47 },
    "sailLarge (23)" = { x=408, y=230, width=66, height=47 },
    "sailLarge (24)" = { x=476, y=342, width=66, height=47 },
    "sailLarge (3)"  = { x=476, y=391, width=66, height=47 },
    "sailLarge (4)"  = { x=476, y=440, width=66, height=47 },
    "sailLarge (5)"  = { x=544, y=0,   width=66, height=47 },
    "sailLarge (6)"  = { x=0,   y=460, width=66, height=47 },
    "sailLarge (7)"  = { x=476, y=196, width=66, height=46 },
    "sailLarge (8)"  = { x=544, y=97,  width=66, height=46 },
    "sailLarge (9)"  = { x=544, y=49,  width=66, height=46 },
    "sailSmall (1)"  = { x=0,   y=422, width=42, height=9 },
    "sailSmall (10)" = { x=44,  y=422, width=42, height=9 },
    "sailSmall (11)" = { x=0,   y=433, width=42, height=9 },
    "sailSmall (12)" = { x=44,  y=433, width=42, height=9 },
    "sailSmall (13)" = { x=44,  y=444, width=42, height=9 },
    "sailSmall (2)"  = { x=0,   y=444, width=42, height=9 },
    "sailSmall (3)"  = { x=76,  y=0,   width=42, height=8 },
    "sailSmall (4)"  = { x=76,  y=10,  width=42, height=8 },
    "sailSmall (5)"  = { x=76,  y=20,  width=42, height=8 },
    "sailSmall (6)"  = { x=76,  y=30,  width=42, height=8 },
    "sailSmall (7)"  = { x=76,  y=40,  width=42, height=9 },
    "sailSmall (8)"  = { x=76,  y=62,  width=42, height=9 },
    "sailSmall (9)"  = { x=76,  y=51,  width=42, height=9 },
    "ship (1)"       = { x=408, y=0,   width=66, height=113 },
    "ship (10)"      = { x=340, y=345, width=66, height=113 },
    "ship (11)"      = { x=340, y=230, width=66, height=113 },
    "ship (12)"      = { x=340, y=115, width=66, height=113 },
    "ship (13)"      = { x=340, y=0,   width=66, height=113 },
    "ship (14)"      = { x=272, y=345, width=66, height=113 },
    "ship (15)"      = { x=272, y=230, width=66, height=113 },
    "ship (16)"      = { x=272, y=115, width=66, height=113 },
    "ship (17)"      = { x=272, y=0,   width=66, height=113 },
    "ship (18)"      = { x=204, y=345, width=66, height=113 },
    "ship (19)"      = { x=204, y=230, width=66, height=113 },
    "ship (2)"       = { x=408, y=115, width=66, height=113 },
    "ship (20)"      = { x=204, y=0,   width=66, height=113 },
    "ship (21)"      = { x=136, y=345, width=66, height=113 },
    "ship (22)"      = { x=136, y=230, width=66, height=113 },
    "ship (23)"      = { x=136, y=115, width=66, height=113 },
    "ship (24)"      = { x=136, y=0,   width=66, height=113 },
    "ship (3)"       = { x=204, y=115, width=66, height=113 },
    "ship (4)"       = { x=68,  y=192, width=66, height=113 },
    "ship (5)"       = { x=68,  y=77,  width=66, height=113 },
    "ship (6)"       = { x=68,  y=307, width=66, height=113 },
    "ship (7)"       = { x=0,   y=192, width=66, height=113 },
    "ship (8)"       = { x=0,   y=307, width=66, height=113 },
    "ship (9)"       = { x=0,   y=77,  width=66, height=113 },
    "wood (1)"       = { x=88,  y=449, width=15, height=7 },
    "wood (2)"       = { x=408, y=472, width=26, height=10 },
    "wood (3)"       = { x=116, y=440, width=15, height=10 },
    "wood (4)"       = { x=88,  y=440, width=26, height=7 },
}

ship_sprites: [dynamic]Sprite
explosion_sprites: [dynamic]Sprite
cannonball_sprite: Sprite

spritesheet: rl.Texture

sprites_init :: proc() {
    png_data :: #load("../assets/Spritesheet/shipsMiscellaneous_sheet.png")
    im := rl.LoadImageFromMemory(".png", raw_data(png_data), i32(len(png_data)))
    defer rl.UnloadImage(im)
    spritesheet = rl.LoadTextureFromImage(im)
    rl.SetTextureFilter(spritesheet, .TRILINEAR)

    for name, sprite in sprites {
        if strings.contains(name, "ship (") {
            index, _ := strconv.parse_int(name[6:])
            assert(index > 0)
            assign_at(&ship_sprites, index, sprite)
        }

        if strings.contains(name, "explosion") {
            append(&explosion_sprites, sprite)
        }
    }

    cannonball_sprite = sprites["cannonBall"]
}

draw_sprite :: proc(sprite: Sprite, pos: v2, rot: f32, scale: f32 = 1, tint := rl.WHITE) {
    dest := rl.Rectangle { pos.x, pos.y, sprite.width * scale, sprite.height * scale }
    rl.DrawTexturePro(spritesheet, sprite, dest, v2{sprite.width, sprite.height}*.5 * scale, rot, tint)
}