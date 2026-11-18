package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/bits"

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

GameState :: struct {
    turn_count: int,
    is_whites_turn: bool,
    bitboard: [Piece]u64,
}

initial_game_state :: proc() -> GameState {
    return GameState{
        turn_count = 0,
        is_whites_turn = true,
        bitboard = {
            .WhitePawn   = 65280,
            .WhiteRook   = 129,
            .WhiteKnight = 66,
            .WhiteBishop = 36,
            .WhiteQueen  = 8,
            .WhiteKing   = 16,
            .BlackPawn   = 71776119061217280,
            .BlackRook   = 9295429630892703744,
            .BlackKnight = 4755801206503243776,
            .BlackBishop = 2594073385365405696,
            .BlackQueen  = 576460752303423488,
            .BlackKing   = 1152921504606846976,
        },
        // bitboard = {
        //     .WhitePawn   = 1 << 8 | 1 << 9 | 1 << 10 | 1 << 11 | 1 << 12 | 1 << 13 | 1 << 14 | 1 << 15,
        //     .WhiteRook   = 1 << 0 | 1 << 7,
        //     .WhiteKnight = 1 << 1 | 1 << 6,
        //     .WhiteBishop = 1 << 2 | 1 << 5,
        //     .WhiteQueen  = 1 << 3,
        //     .WhiteKing   = 1 << 4,
        //     .BlackPawn   = 1 << 48 | 1 << 49 | 1 << 50 | 1 << 51 | 1 << 52 | 1 << 53 | 1 << 54 | 1 << 55,
        //     .BlackRook   = 1 << 56 | 1 << 63,
        //     .BlackKnight = 1 << 57 | 1 << 62,
        //     .BlackBishop = 1 << 58 | 1 << 61,
        //     .BlackQueen  = 1 << 59,
        //     .BlackKing   = 1 << 60,
        // },
    }
}

main :: proc() {
    rl.InitWindow(1000, 800, "mechanical turk")
    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(144)

    piece_atlas = rl.LoadTexture(piece_atlas_path)

    board := initial_game_state()
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        
        draw_board(board_light_color, board_dark_color)
        draw_game_state(&board)

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

draw_piece :: proc(piece: Piece, row: u8, col: u8) {
    x := f32(col) * square_size
    y := f32(7 - row) * square_size
    rl.DrawTextureRec(
        piece_atlas,
        piece_texture_rects[piece],
        rl.Vector2{x, y},
        rl.WHITE,
    )
}

draw_game_state :: proc(gs: ^GameState) {
    draw_piece_bitboard(gs, .WhitePawn)
    draw_piece_bitboard(gs, .WhiteRook)
    draw_piece_bitboard(gs, .WhiteKnight)
    draw_piece_bitboard(gs, .WhiteBishop)
    draw_piece_bitboard(gs, .WhiteQueen)
    draw_piece_bitboard(gs, .WhiteKing)
    draw_piece_bitboard(gs, .BlackPawn)
    draw_piece_bitboard(gs, .BlackRook)
    draw_piece_bitboard(gs, .BlackKnight)
    draw_piece_bitboard(gs, .BlackBishop)
    draw_piece_bitboard(gs, .BlackQueen)
    draw_piece_bitboard(gs, .BlackKing)
}

draw_piece_bitboard :: proc(gs: ^GameState, piece: Piece) {
    bitboard := gs.bitboard[piece]
    for bitboard != 0 {
        idx := bits.count_trailing_zeros(bitboard)
        row := u8(idx / 8)
        col := u8(idx % 8)
        bitboard &= ~(1 << idx)
        draw_piece(piece, row, col)
    }
}
