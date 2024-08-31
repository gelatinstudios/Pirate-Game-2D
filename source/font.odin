
package pirates

import rl "vendor:raylib"

Font_Size :: enum { 
	Heading, 
	Regular,
}

font_sizes := [Font_Size]i32 {
	.Heading = 72,
	.Regular = 36,
}

fonts: [Font_Size]rl.Font

font_init :: proc() {
	ttf :: #load("../assets/booter.zero-zero.ttf")

	for &font, i in fonts {
		size := font_sizes[i]
		font = rl.LoadFontFromMemory(".ttf", raw_data(ttf), i32(len(ttf)), size, nil, 0)
	}
}

draw_text :: proc(size: Font_Size, color: rl.Color, center: v2, text: cstring) {
	font := fonts[size]
	size := f32(font_sizes[size])

	dims := rl.MeasureTextEx(font, text, size, 0)
	pos := center - dims*.5
	rl.DrawTextEx(font, text, pos, size, 0, color)
}