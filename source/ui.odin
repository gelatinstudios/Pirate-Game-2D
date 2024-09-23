
package pirates

import "core:math"

import rl "vendor:raylib"

ui_sprites := map[string]Sprite {
    "banner_classic_curtainimg"             = { x=0,   y=64,  width=256, height=64 },
    "banner_hangingimg"                     = { x=0,   y=0,   width=256, height=64 },
    "banner_modernimg"                      = { x=0,   y=128, width=256, height=48 },
    "button_brown_closeimg"                 = { x=96,  y=576, width=48,  height=24 },
    "button_brownimg"                       = { x=144, y=576, width=48,  height=24 },
    "button_grey_closeimg"                  = { x=192, y=576, width=48,  height=24 },
    "button_greyimg"                        = { x=240, y=576, width=48,  height=24 },
    "button_red_closeimg"                   = { x=0,   y=576, width=48,  height=24 },
    "button_redimg"                         = { x=48,  y=576, width=48,  height=24 },
    "checkbox_beige_checkedimg"             = { x=458, y=576, width=24,  height=24 },
    "checkbox_beige_crossimg"               = { x=482, y=576, width=24,  height=24 },
    "checkbox_beige_emptyimg"               = { x=314, y=576, width=24,  height=24 },
    "checkbox_brown_checkedimg"             = { x=338, y=576, width=24,  height=24 },
    "checkbox_brown_crossimg"               = { x=386, y=576, width=24,  height=24 },
    "checkbox_brown_emptyimg"               = { x=362, y=576, width=24,  height=24 },
    "checkbox_grey_checkedimg"              = { x=506, y=576, width=24,  height=24 },
    "checkbox_grey_crossimg"                = { x=410, y=576, width=24,  height=24 },
    "checkbox_grey_emptyimg"                = { x=434, y=576, width=24,  height=24 },
    "hexagon_brown_darkimg"                 = { x=496, y=448, width=48,  height=64 },
    "hexagon_brownimg"                      = { x=496, y=512, width=48,  height=64 },
    "hexagon_damaged_brown_darkimg"         = { x=448, y=448, width=48,  height=64 },
    "hexagon_damaged_brownimg"              = { x=448, y=512, width=48,  height=64 },
    "hexagon_grey_darkimg"                  = { x=512, y=128, width=48,  height=64 },
    "hexagon_grey_greenimg"                 = { x=512, y=192, width=48,  height=64 },
    "hexagon_grey_redimg"                   = { x=512, y=0,   width=48,  height=64 },
    "hexagon_greyimg"                       = { x=512, y=64,  width=48,  height=64 },
    "minimap_arrow_aimg"                    = { x=64,  y=560, width=16,  height=16 },
    "minimap_arrow_bimg"                    = { x=48,  y=560, width=16,  height=16 },
    "minimap_arrow_cimg"                    = { x=576, y=152, width=12,  height=16 },
    "minimap_arrow_dimg"                    = { x=560, y=536, width=16,  height=16 },
    "minimap_compass_future_eimg"           = { x=544, y=364, width=20,  height=22 },
    "minimap_compass_future_nimg"           = { x=544, y=320, width=20,  height=22 },
    "minimap_compass_future_simg"           = { x=544, y=342, width=20,  height=22 },
    "minimap_compass_future_wimg"           = { x=544, y=386, width=20,  height=22 },
    "minimap_compass_toon_eimg"             = { x=576, y=408, width=16,  height=20 },
    "minimap_compass_toon_nimg"             = { x=530, y=576, width=20,  height=20 },
    "minimap_compass_toon_simg"             = { x=544, y=480, width=16,  height=20 },
    "minimap_compass_toon_wimg"             = { x=288, y=576, width=26,  height=20 },
    "minimap_icon_exclamation_redimg"       = { x=576, y=168, width=8,   height=16 },
    "minimap_icon_exclamation_whiteimg"     = { x=576, y=184, width=8,   height=16 },
    "minimap_icon_exclamation_yellowimg"    = { x=576, y=200, width=8,   height=16 },
    "minimap_icon_jewel_redimg"             = { x=240, y=560, width=16,  height=16 },
    "minimap_icon_jewel_whiteimg"           = { x=0,   y=560, width=16,  height=16 },
    "minimap_icon_jewel_yellowimg"          = { x=208, y=560, width=16,  height=16 },
    "minimap_icon_star_redimg"              = { x=566, y=584, width=16,  height=16 },
    "minimap_icon_star_whiteimg"            = { x=192, y=560, width=16,  height=16 },
    "minimap_icon_star_yellowimg"           = { x=16,  y=560, width=16,  height=16 },
    "minimap_ring_brown_detailimg"          = { x=0,   y=176, width=128, height=128 },
    "minimap_ring_brownimg"                 = { x=128, y=304, width=128, height=128 },
    "minimap_ring_grey_detailimg"           = { x=0,   y=304, width=128, height=128 },
    "minimap_ring_greyimg"                  = { x=0,   y=432, width=128, height=128 },
    "minimap_ring_whiteimg"                 = { x=128, y=176, width=128, height=128 },
    "panel_border_brown_detailimg"          = { x=192, y=496, width=64,  height=64 },
    "panel_border_brownimg"                 = { x=256, y=512, width=64,  height=64 },
    "panel_border_grey_detailimg"           = { x=320, y=0,   width=64,  height=64 },
    "panel_border_greyimg"                  = { x=320, y=64,  width=64,  height=64 },
    "panel_brown_arrows_dark_detailimg"     = { x=320, y=128, width=64,  height=64 },
    "panel_brown_arrows_darkimg"            = { x=320, y=192, width=64,  height=64 },
    "panel_brown_arrows_detailimg"          = { x=320, y=256, width=64,  height=64 },
    "panel_brown_arrowsimg"                 = { x=128, y=496, width=64,  height=64 },
    "panel_brown_corners_aimg"              = { x=320, y=320, width=64,  height=64 },
    "panel_brown_corners_bimg"              = { x=320, y=384, width=64,  height=64 },
    "panel_brown_damaged_darkimg"           = { x=192, y=432, width=64,  height=64 },
    "panel_brown_damagedimg"                = { x=448, y=384, width=64,  height=64 },
    "panel_brown_dark_corners_aimg"         = { x=128, y=432, width=64,  height=64 },
    "panel_brown_dark_corners_bimg"         = { x=320, y=512, width=64,  height=64 },
    "panel_brown_darkimg"                   = { x=384, y=0,   width=64,  height=64 },
    "panel_brownimg"                        = { x=384, y=64,  width=64,  height=64 },
    "panel_grey_blueimg"                    = { x=384, y=128, width=64,  height=64 },
    "panel_grey_bolts_blueimg"              = { x=384, y=192, width=64,  height=64 },
    "panel_grey_bolts_darkimg"              = { x=384, y=256, width=64,  height=64 },
    "panel_grey_bolts_detail_aimg"          = { x=384, y=320, width=64,  height=64 },
    "panel_grey_bolts_detail_bimg"          = { x=384, y=384, width=64,  height=64 },
    "panel_grey_bolts_greenimg"             = { x=384, y=448, width=64,  height=64 },
    "panel_grey_bolts_redimg"               = { x=384, y=512, width=64,  height=64 },
    "panel_grey_boltsimg"                   = { x=448, y=0,   width=64,  height=64 },
    "panel_grey_darkimg"                    = { x=448, y=64,  width=64,  height=64 },
    "panel_grey_greenimg"                   = { x=448, y=128, width=64,  height=64 },
    "panel_grey_redimg"                     = { x=448, y=192, width=64,  height=64 },
    "panel_greyimg"                         = { x=448, y=256, width=64,  height=64 },
    "panel_grid_blueprintimg"               = { x=448, y=320, width=64,  height=64 },
    "panel_grid_paperimg"                   = { x=320, y=448, width=64,  height=64 },
    "pattern_diagonal_grey_largeimg"        = { x=544, y=288, width=32,  height=32 },
    "pattern_diagonal_grey_smallimg"        = { x=544, y=256, width=32,  height=32 },
    "pattern_diagonal_red_largeimg"         = { x=512, y=416, width=32,  height=32 },
    "pattern_diagonal_red_smallimg"         = { x=512, y=384, width=32,  height=32 },
    "pattern_diagonal_transparent_largeimg" = { x=512, y=352, width=32,  height=32 },
    "pattern_diagonal_transparent_smallimg" = { x=512, y=320, width=32,  height=32 },
    "pattern_grid_blueprintimg"             = { x=512, y=288, width=32,  height=32 },
    "pattern_grid_paperimg"                 = { x=512, y=256, width=32,  height=32 },
    "progress_blue_borderimg"               = { x=560, y=192, width=16,  height=32 },
    "progress_blue_small_borderimg"         = { x=128, y=560, width=16,  height=16 },
    "progress_blue_smallimg"                = { x=112, y=560, width=16,  height=16 },
    "progress_blueimg"                      = { x=560, y=160, width=16,  height=32 },
    "progress_green_borderimg"              = { x=560, y=128, width=16,  height=32 },
    "progress_green_small_borderimg"        = { x=96,  y=560, width=16,  height=16 },
    "progress_green_smallimg"               = { x=80,  y=560, width=16,  height=16 },
    "progress_greenimg"                     = { x=560, y=96,  width=16,  height=32 },
    "progress_red_borderimg"                = { x=560, y=64,  width=16,  height=32 },
    "progress_red_small_borderimg"          = { x=32,  y=560, width=16,  height=16 },
    "progress_red_smallimg"                 = { x=224, y=560, width=16,  height=16 },
    "progress_redimg"                       = { x=566, y=552, width=16,  height=32 },
    "progress_transparent_smallimg"         = { x=176, y=560, width=16,  height=16 },
    "progress_transparentimg"               = { x=564, y=352, width=16,  height=32 },
    "progress_white_borderimg"              = { x=564, y=320, width=16,  height=32 },
    "progress_white_small_borderimg"        = { x=160, y=560, width=16,  height=16 },
    "progress_white_smallimg"               = { x=144, y=560, width=16,  height=16 },
    "progress_whiteimg"                     = { x=560, y=224, width=16,  height=32 },
    "round_brown_darkimg"                   = { x=256, y=448, width=64,  height=64 },
    "round_brownimg"                        = { x=256, y=384, width=64,  height=64 },
    "round_damaged_brown_darkimg"           = { x=256, y=320, width=64,  height=64 },
    "round_damaged_brownimg"                = { x=256, y=256, width=64,  height=64 },
    "round_grey_darkimg"                    = { x=256, y=192, width=64,  height=64 },
    "round_grey_detailed_greenimg"          = { x=256, y=128, width=64,  height=64 },
    "round_grey_detailed_redimg"            = { x=256, y=64,  width=64,  height=64 },
    "round_greyimg"                         = { x=256, y=0,   width=64,  height=64 },
    "scrollbar_brown_smallimg"              = { x=550, y=564, width=16,  height=24 },
    "scrollbar_brownimg"                    = { x=560, y=472, width=16,  height=64 },
    "scrollbar_future_grey_smallimg"        = { x=564, y=384, width=16,  height=24 },
    "scrollbar_future_greyimg"              = { x=576, y=0,   width=16,  height=64 },
    "scrollbar_future_red_smallimg"         = { x=544, y=432, width=16,  height=24 },
    "scrollbar_future_redimg"               = { x=544, y=500, width=16,  height=64 },
    "scrollbar_future_transparent_smallimg" = { x=544, y=456, width=16,  height=24 },
    "scrollbar_future_transparentimg"       = { x=560, y=0,   width=16,  height=64 },
    "scrollbar_grey_smallimg"               = { x=544, y=408, width=16,  height=24 },
    "scrollbar_greyimg"                     = { x=560, y=408, width=16,  height=64 },
    "scrollbar_transparent_smallimg"        = { x=576, y=64,  width=16,  height=24 },
    "scrollbar_transparentimg"              = { x=576, y=88,  width=16,  height=64 },
}

ui_spritesheet: rl.Texture

ui_init :: proc() {
    png_data :: #load("../assets/UI_Spritesheet/spritesheet-default.png")
    im := rl.LoadImageFromMemory(".png", raw_data(png_data), i32(len(png_data)))
    defer rl.UnloadImage(im)
    ui_spritesheet = rl.LoadTextureFromImage(im)
    rl.SetTextureFilter(ui_spritesheet, .TRILINEAR)
}

draw_health_bar :: proc(start, end: v2, health: f32) {
    health_bar_sprite := ui_sprites["progress_white_smallimg"]

    health_bar_height := f32(health_bar_sprite.height)
    health_bar_width := end.x - start.x

    health_bar_dest := rl.Rectangle {
        start.x, 
        start.y - health_bar_height*.5,
        health_bar_width, 
        health_bar_height,
    }

    n := i32(health_bar_width / 4)

    health_bar_npatch := rl.NPatchInfo {
        source = health_bar_sprite,
        layout = .THREE_PATCH_HORIZONTAL,
        left = 8,
        right = 9,
    }

    rl.DrawTextureNPatch(ui_spritesheet, health_bar_npatch, health_bar_dest, {}, 0, rl.WHITE)

    t := f32(health) / SHIP_HEALTH_MAX

    health_bar_dest.width = math.lerp(f32(0), health_bar_dest.width, t)

    health_bar_npatch.source = ui_sprites["progress_red_smallimg"]
    rl.DrawTextureNPatch(ui_spritesheet, health_bar_npatch, health_bar_dest, {}, 0, rl.WHITE)
}

draw_ui :: proc() {
    player := get_player()^
    ship := player.variant.(Ship)

    dims := screen_end()

    player_health_bar_start := v2 {0, dims.y}
    player_health_bar_padding := v2 {dims.x * 0.05, -dims.y * 0.05}
    player_health_bar_start += player_health_bar_padding
    player_health_bar_end := v2 {dims.x * .5, player_health_bar_padding.y}

    draw_health_bar(player_health_bar_start, player_health_bar_end, ship.health)

    available_cannons := 0
    for c in ship.cannon_timers[:ship.cannon_count] {
        available_cannons += int(c <= 0)
    }

    cannonballs_pos := player_health_bar_start
    cannonballs_pos.x += 6
    cannonballs_pos.y -= dims.y*0.03

    for _ in 0 ..< available_cannons {
        draw_sprite(cannonball_sprite, cannonballs_pos, 0)

        cannonballs_pos.x += f32(cannonball_sprite.width) + 1
    }
}