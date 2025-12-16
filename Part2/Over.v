// 游戏结束逻辑判断模块, 接收 board_data, 输出 game_over 信号
module Over(
    input clkk,
    input rstn,
    input [12*64-1:0] board_data,
    input turn, // 0: White, 1: Black
    output reg [1:0] game_over // 00: Draw, 01: Play, 10: Black Win, 11: White Win
);

    // Constants
    localparam WHITE = 1'b0;
    localparam BLACK = 1'b1;
    
    localparam PAWN   = 3'd6;
    localparam ROOK   = 3'd5;
    localparam KNIGHT = 3'd4;
    localparam BISHOP = 3'd3;
    localparam QUEEN  = 3'd2;
    localparam KING   = 3'd1;

    localparam PLAY_STATE = 2'b01;
    localparam BLACK_WIN_STATE = 2'b10;
    localparam WHITE_WIN_STATE = 2'b11;
    localparam DRAW_STATE = 2'b00;

    // Decode Board
    wire [7:0] board [7:0][7:0];
    genvar r, c;
    generate
        for (r = 0; r < 8; r = r + 1) begin : decode_row
            for (c = 0; c < 8; c = c + 1) begin : decode_col
                assign board[r][c] = board_data[((r*8+c)*12)+7 : ((r*8+c)*12)];
            end
        end
    endgenerate

    // State Machine
    reg [3:0] state;
    localparam S_IDLE = 0;
    localparam S_FIND_KING = 1;
    localparam S_SCAN_SRC = 2;
    localparam S_SCAN_DST = 3;
    localparam S_CHECK_SAFETY = 4;
    localparam S_RESULT = 5;
    localparam S_FINAL_CHECK = 6;

    reg [2:0] kx, ky; // King position
    reg [2:0] sx, sy; // Source position
    reg [2:0] dx, dy; // Destination position
    
    reg found_legal;
    reg prev_turn; // To detect turn change

    // Helper signals for current iteration
    wire [7:0] src_piece = board[sy][sx];
    wire [7:0] dst_cell = board[dy][dx];
    wire [2:0] p_type = src_piece[2:0];
    wire p_color = src_piece[3];
    
    // Pseudo-Legal Move Check Logic
    reg is_pseudo_legal;
    reg path_blocked;
    integer k;
    reg [3:0] abs_dx, abs_dy;
    
    always @(*) begin
        is_pseudo_legal = 0;
        path_blocked = 0;
        abs_dx = (dx > sx) ? (dx - sx) : (sx - dx);
        abs_dy = (dy > sy) ? (dy - sy) : (sy - dy);

        // Basic validation: Source must be own piece, Dest must not be own piece
        if (src_piece[4] && src_piece[3] == turn && (!dst_cell[4] || dst_cell[3] != turn)) begin
            case (p_type)
                PAWN: begin
                    if (turn == WHITE) begin
                        // Forward 1
                        if (dx == sx && dy == sy + 1 && !dst_cell[4]) is_pseudo_legal = 1;
                        // Forward 2
                        else if (dx == sx && dy == sy + 2 && sy == 1 && !board[sy+1][sx][4] && !dst_cell[4]) is_pseudo_legal = 1;
                        // Capture
                        else if (abs_dx == 1 && dy == sy + 1 && dst_cell[4]) is_pseudo_legal = 1;
                    end else begin
                        // Forward 1
                        if (dx == sx && dy == sy - 1 && !dst_cell[4]) is_pseudo_legal = 1;
                        // Forward 2
                        else if (dx == sx && dy == sy - 2 && sy == 6 && !board[sy-1][sx][4] && !dst_cell[4]) is_pseudo_legal = 1;
                        // Capture
                        else if (abs_dx == 1 && dy == sy - 1 && dst_cell[4]) is_pseudo_legal = 1;
                    end
                end
                ROOK: begin
                    if (dx == sx || dy == sy) begin
                        // Check path
                        if (dx == sx) begin // Vertical
                            for (k = 1; k < 8; k = k + 1) if (k < abs_dy && board[(dy > sy ? sy + k : sy - k)][sx][4]) path_blocked = 1;
                        end else begin // Horizontal
                            for (k = 1; k < 8; k = k + 1) if (k < abs_dx && board[sy][(dx > sx ? sx + k : sx - k)][4]) path_blocked = 1;
                        end
                        if (!path_blocked) is_pseudo_legal = 1;
                    end
                end
                KNIGHT: begin
                    if ((abs_dx == 1 && abs_dy == 2) || (abs_dx == 2 && abs_dy == 1)) is_pseudo_legal = 1;
                end
                BISHOP: begin
                    if (abs_dx == abs_dy && abs_dx != 0) begin
                        for (k = 1; k < 8; k = k + 1) if (k < abs_dx && board[(dy > sy ? sy + k : sy - k)][(dx > sx ? sx + k : sx - k)][4]) path_blocked = 1;
                        if (!path_blocked) is_pseudo_legal = 1;
                    end
                end
                QUEEN: begin
                    if (dx == sx || dy == sy) begin // Rook-like
                        if (dx == sx) begin
                            for (k = 1; k < 8; k = k + 1) if (k < abs_dy && board[(dy > sy ? sy + k : sy - k)][sx][4]) path_blocked = 1;
                        end else begin
                            for (k = 1; k < 8; k = k + 1) if (k < abs_dx && board[sy][(dx > sx ? sx + k : sx - k)][4]) path_blocked = 1;
                        end
                        if (!path_blocked) is_pseudo_legal = 1;
                    end else if (abs_dx == abs_dy) begin // Bishop-like
                        for (k = 1; k < 8; k = k + 1) if (k < abs_dx && board[(dy > sy ? sy + k : sy - k)][(dx > sx ? sx + k : sx - k)][4]) path_blocked = 1;
                        if (!path_blocked) is_pseudo_legal = 1;
                    end
                end
                KING: begin
                    if (abs_dx <= 1 && abs_dy <= 1) is_pseudo_legal = 1;
                end
            endcase
        end
    end

    // Safety Check Logic (Is King Attacked?)
    // We need to check if the King is attacked AFTER the move (sx,sy)->(dx,dy)
    // If we moved the King, the King is at (dx,dy). Otherwise at (kx,ky).
    reg is_safe;
    reg [2:0] check_kx, check_ky;
    reg [2:0] ax, ay; // Attacker iterator
    reg [3:0] a_abs_dx, a_abs_dy;
    reg a_path_blocked;
    
    always @(*) begin
        is_safe = 1;
        check_kx = (p_type == KING) ? dx : kx;
        check_ky = (p_type == KING) ? dy : ky;
        
        // Iterate all potential attackers
        for (ay = 0; ay < 8; ay = ay + 1) begin
            for (ax = 0; ax < 8; ax = ax + 1) begin
                // Skip if this is the captured piece (at dx, dy)
                if (!(ax == dx && ay == dy)) begin
                    // Skip if this is the piece we moved (at sx, sy) - it's not there anymore
                    if (!(ax == sx && ay == sy)) begin
                        // Check if it's an enemy piece
                        if (board[ay][ax][4] && board[ay][ax][3] != turn) begin
                            // Check if this enemy attacks (check_kx, check_ky)
                            // Considering (sx,sy) is EMPTY and (dx,dy) is BLOCKING (if not captured)
                            
                            a_abs_dx = (check_kx > ax) ? (check_kx - ax) : (ax - check_kx);
                            a_abs_dy = (check_ky > ay) ? (check_ky - ay) : (ay - check_ky);
                            a_path_blocked = 0;
                            
                            case (board[ay][ax][2:0])
                                PAWN: begin
                                    if (board[ay][ax][3] == WHITE) begin // White Pawn attacks up-diag
                                        if (a_abs_dx == 1 && check_ky == ay + 1) is_safe = 0;
                                    end else begin // Black Pawn attacks down-diag
                                        if (a_abs_dx == 1 && check_ky == ay - 1) is_safe = 0;
                                    end
                                end
                                ROOK: begin
                                    if (ax == check_kx || ay == check_ky) begin
                                        if (ax == check_kx) begin // Vertical
                                            for (k = 1; k < 8; k = k + 1) begin
                                                if (k < a_abs_dy) begin
                                                    // Check obstruction at (tx, ty)
                                                    // Logic: Is there a piece at (tx, ty)?
                                                    // (tx, ty) is blocked if:
                                                    // 1. It's (dx, dy) [The piece we moved to]
                                                    // 2. It's occupied on board AND NOT (sx, sy) [Old pos] AND NOT (dx, dy) [Already handled]
                                                    if ((check_ky > ay ? ay + k : ay - k) == dy && ax == dx) a_path_blocked = 1;
                                                    else if (board[(check_ky > ay ? ay + k : ay - k)][ax][4] && !((check_ky > ay ? ay + k : ay - k) == sy && ax == sx)) a_path_blocked = 1;
                                                end
                                            end
                                        end else begin // Horizontal
                                            for (k = 1; k < 8; k = k + 1) begin
                                                if (k < a_abs_dx) begin
                                                    if (ay == dy && (check_kx > ax ? ax + k : ax - k) == dx) a_path_blocked = 1;
                                                    else if (board[ay][(check_kx > ax ? ax + k : ax - k)][4] && !(ay == sy && (check_kx > ax ? ax + k : ax - k) == sx)) a_path_blocked = 1;
                                                end
                                            end
                                        end
                                        if (!a_path_blocked) is_safe = 0;
                                    end
                                end
                                KNIGHT: begin
                                    if ((a_abs_dx == 1 && a_abs_dy == 2) || (a_abs_dx == 2 && a_abs_dy == 1)) is_safe = 0;
                                end
                                BISHOP: begin
                                    if (a_abs_dx == a_abs_dy && a_abs_dx != 0) begin
                                        for (k = 1; k < 8; k = k + 1) begin
                                            if (k < a_abs_dx) begin
                                                if ((check_ky > ay ? ay + k : ay - k) == dy && (check_kx > ax ? ax + k : ax - k) == dx) a_path_blocked = 1;
                                                else if (board[(check_ky > ay ? ay + k : ay - k)][(check_kx > ax ? ax + k : ax - k)][4] && !((check_ky > ay ? ay + k : ay - k) == sy && (check_kx > ax ? ax + k : ax - k) == sx)) a_path_blocked = 1;
                                            end
                                        end
                                        if (!a_path_blocked) is_safe = 0;
                                    end
                                end
                                QUEEN: begin
                                    if (ax == check_kx || ay == check_ky) begin // Rook-like
                                        if (ax == check_kx) begin
                                            for (k = 1; k < 8; k = k + 1) if (k < a_abs_dy) begin
                                                if ((check_ky > ay ? ay + k : ay - k) == dy && ax == dx) a_path_blocked = 1;
                                                else if (board[(check_ky > ay ? ay + k : ay - k)][ax][4] && !((check_ky > ay ? ay + k : ay - k) == sy && ax == sx)) a_path_blocked = 1;
                                            end
                                        end else begin
                                            for (k = 1; k < 8; k = k + 1) if (k < a_abs_dx) begin
                                                if (ay == dy && (check_kx > ax ? ax + k : ax - k) == dx) a_path_blocked = 1;
                                                else if (board[ay][(check_kx > ax ? ax + k : ax - k)][4] && !(ay == sy && (check_kx > ax ? ax + k : ax - k) == sx)) a_path_blocked = 1;
                                            end
                                        end
                                        if (!a_path_blocked) is_safe = 0;
                                    end else if (a_abs_dx == a_abs_dy) begin // Bishop-like
                                        for (k = 1; k < 8; k = k + 1) if (k < a_abs_dx) begin
                                            if ((check_ky > ay ? ay + k : ay - k) == dy && (check_kx > ax ? ax + k : ax - k) == dx) a_path_blocked = 1;
                                            else if (board[(check_ky > ay ? ay + k : ay - k)][(check_kx > ax ? ax + k : ax - k)][4] && !((check_ky > ay ? ay + k : ay - k) == sy && (check_kx > ax ? ax + k : ax - k) == sx)) a_path_blocked = 1;
                                        end
                                        if (!a_path_blocked) is_safe = 0;
                                    end
                                end
                                KING: begin
                                    if (a_abs_dx <= 1 && a_abs_dy <= 1) is_safe = 0;
                                end
                            endcase
                        end
                    end
                end
            end
        end
    end

    // State Machine Implementation
    always @(posedge clkk or negedge rstn) begin
        if (!rstn) begin
            state <= S_IDLE;
            game_over <= PLAY_STATE;
            kx <= 0; ky <= 0;
            sx <= 0; sy <= 0;
            dx <= 0; dy <= 0;
            found_legal <= 0;
            prev_turn <= 0;
        end else begin
            prev_turn <= turn;
            if (turn != prev_turn) begin
                // Turn changed, restart scan
                state <= S_IDLE;
                game_over <= PLAY_STATE;
            end else begin
                case (state)
                    S_IDLE: begin
                        // Start scan
                        state <= S_FIND_KING;
                        found_legal <= 0;
                        kx <= 0; ky <= 0;
                    end
                    
                    S_FIND_KING: begin
                    if (board[ky][kx][4] && board[ky][kx][3] == turn && board[ky][kx][2:0] == KING) begin
                        state <= S_SCAN_SRC;
                        sx <= 0; sy <= 0;
                    end else begin
                        if (kx == 7) begin
                            kx <= 0;
                            if (ky == 7) begin
                                // King not found? Should not happen.
                                state <= S_SCAN_SRC; 
                                sx <= 0; sy <= 0;
                            end else ky <= ky + 1;
                        end else kx <= kx + 1;
                    end
                end

                S_SCAN_SRC: begin
                    if (found_legal) begin
                        state <= S_RESULT;
                    end else begin
                        // Check if we are done with all pieces
                        if (sy == 7 && sx == 7 && !(board[sy][sx][4] && board[sy][sx][3] == turn)) begin
                             // Finished scanning all pieces, no legal move found
                             state <= S_RESULT;
                        end else begin
                            if (board[sy][sx][4] && board[sy][sx][3] == turn) begin
                                // Found a piece, try moves
                                dx <= 0; dy <= 0;
                                state <= S_SCAN_DST;
                            end else begin
                                // Next piece
                                if (sx == 7) begin
                                    sx <= 0;
                                    if (sy == 7) state <= S_RESULT; // Done
                                    else sy <= sy + 1;
                                end else sx <= sx + 1;
                            end
                        end
                    end
                end

                S_SCAN_DST: begin
                    if (found_legal) begin
                        state <= S_RESULT;
                    end else begin
                        // Check pseudo legal
                        if (is_pseudo_legal) begin
                            // Check safety
                            if (is_safe) begin
                                found_legal <= 1;
                                state <= S_RESULT;
                            end
                        end
                        
                        // Next Dest
                        if (dx == 7) begin
                            dx <= 0;
                            if (dy == 7) begin
                                // Done with this piece
                                // Increment sx, sy
                                if (sx == 7) begin
                                    sx <= 0;
                                    if (sy == 7) state <= S_RESULT;
                                    else sy <= sy + 1;
                                end else sx <= sx + 1;
                                state <= S_SCAN_SRC;
                            end else dy <= dy + 1;
                        end else dx <= dx + 1;
                    end
                end

                S_RESULT: begin
                    if (found_legal) begin
                        game_over <= PLAY_STATE;
                        state <= S_IDLE;
                    end else begin
                        // No legal moves. Checkmate or Stalemate?
                        // Check if King is currently in check.
                        // Set sx=kx, sy=ky, dx=kx, dy=ky (No move)
                        sx <= kx; sy <= ky; dx <= kx; dy <= ky;
                        state <= S_FINAL_CHECK;
                    end
                end
                
                S_FINAL_CHECK: begin
                    if (!is_safe) begin
                        // King is in check -> Checkmate
                        game_over <= (turn == WHITE) ? BLACK_WIN_STATE : WHITE_WIN_STATE;
                    end else begin
                        // King not in check -> Stalemate
                        game_over <= DRAW_STATE;
                    end
                    state <= S_IDLE;
                end
            endcase
            end
        end
    end

endmodule