package main

import rl "vendor:raylib"

square_size :: 100
piece_atlas_path   :: "./assets/pieces.png"
piece_atlas_width  :: 600
piece_atlas_height :: 200
piece_sprite_size  :: 100

board_light_color :: rl.Color{226, 210, 206, 255}
board_dark_color  :: rl.Color{85, 64, 58, 255}

Piece :: enum {
    WhitePawn,
    WhiteRook,
    WhiteKnight,
    WhiteBishop,
    WhiteQueen,
    WhiteKing,
    BlackPawn,
    BlackRook,
    BlackKnight,
    BlackBishop,
    BlackQueen,
    BlackKing,
}

@(rodata)
piece_texture_rects: [Piece]rl.Rectangle = {
    .WhitePawn   = { x = 0 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .WhiteRook   = { x = 1 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .WhiteKnight = { x = 2 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .WhiteBishop = { x = 3 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .WhiteQueen  = { x = 4 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .WhiteKing   = { x = 5 * piece_sprite_size, y = 0,                 width = piece_sprite_size, height = piece_sprite_size },
    .BlackPawn   = { x = 0 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
    .BlackRook   = { x = 1 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
    .BlackKnight = { x = 2 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
    .BlackBishop = { x = 3 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
    .BlackQueen  = { x = 4 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
    .BlackKing   = { x = 5 * piece_sprite_size, y = piece_sprite_size, width = piece_sprite_size, height = piece_sprite_size },
}

piece_atlas: rl.Texture2D

main :: proc() {
    rl.InitWindow(1000, 800, "mechanical turk")
    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(60)

    piece_atlas = rl.LoadTexture(piece_atlas_path)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        
        draw_board(board_light_color, board_dark_color)
        draw_initial_position()

        rl.EndDrawing()
    }

    rl.UnloadTexture(piece_atlas)
    rl.CloseWindow()
}

draw_board :: proc(light: rl.Color, dark: rl.Color) {
    color0 := light
    color1 := dark
    for y in 0..<8 {
        for x in 0..< 4 {
            rl.DrawRectangle(i32(2*x * square_size), i32(y * square_size), square_size, square_size, color0)
            rl.DrawRectangle(i32((2*x + 1) * square_size), i32(y * square_size), square_size, square_size, color1)
        }
        color0, color1 = color1, color0
    }

}

draw_piece :: proc(piece: Piece, x: int, y: int) {
    rl.DrawTextureRec(
        piece_atlas,
        piece_texture_rects[piece],
        rl.Vector2{f32(x * square_size), f32(y * square_size)},
        rl.WHITE,
    )
}

draw_initial_position :: proc() {
    draw_piece(.BlackRook,   0, 0)
    draw_piece(.BlackKnight, 1, 0)
    draw_piece(.BlackBishop, 2, 0)
    draw_piece(.BlackQueen,  3, 0)
    draw_piece(.BlackKing,   4, 0)
    draw_piece(.BlackBishop, 5, 0)
    draw_piece(.BlackKnight, 6, 0)
    draw_piece(.BlackRook,   7, 0)
    draw_piece(.WhiteRook,   0, 7)
    draw_piece(.WhiteKnight, 1, 7)
    draw_piece(.WhiteBishop, 2, 7)
    draw_piece(.WhiteQueen,  3, 7)
    draw_piece(.WhiteKing,   4, 7)
    draw_piece(.WhiteBishop, 5, 7)
    draw_piece(.WhiteKnight, 6, 7)
    draw_piece(.WhiteRook,   7, 7)
    for i in 0..<8 {
        draw_piece(.BlackPawn, i, 1)
        draw_piece(.WhitePawn, i, 6)
    }
}
