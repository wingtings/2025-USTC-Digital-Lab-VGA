module Play(
    input clk,
    input rstn,
    output reg [1:0] state, // 当前游戏状态输出
    input [2:0] cursor_x,   // 光标 X 坐标
    input [2:0] cursor_y,   // 光标 Y 坐标
    input is_pressed,   // 现在是否有按键按下
    input is_g_pressed, // 现在 S 键是否按下
    output [12*64-1:0] board_data,  // 一位棋盘数据输出, 这里是把 8x8 的棋盘按照从上到下从左到右的顺序成一维数组, 发给渲染模块(DDP) 进行画面渲染
    output reg [2:0] sound_code,    // 音效码, 发给 Sound 模块指定需要播放的音效
    output reg play_sound,  // 音效使能信号, 发给 Sound 模块指定当前是否需要播放音效
    output [7:0] wanted_promotion // 期望升变的棋子类型, 发给 DDP 模块用于渲染额外棋子, 如果当前棋子不需要升变的话会直接输出当前光标所在格子内的棋子的数据
);

    // 棋盘寄存器堆: 8x8, 每个寄存器 8 位
    // [4]: 有效位 (1: 有棋子, 0: 无棋子)
    // [3]: 阵营 (0: 白方, 1: 黑方)
    // [2:0]: 棋子类型
    reg [7:0] board [7:0][7:0];

    // 游戏状态
    reg turn; // 当前回合: 0: 白方, 1: 黑方
    reg has_selected; // 是否已选中棋子
    reg [2:0] sel_x; // 选中棋子 X 坐标
    reg [2:0] sel_y; // 选中棋子 Y 坐标

    // 特殊规则状态
    reg promoting; // 是否处于升变选择状态
    reg [2:0] prom_piece; // 当前选择的升变棋子类型
    reg [2:0] prom_x, prom_y; // 升变发生的位置

    reg [3:0] en_passant_col; // 记录过路兵的列号 (0-7), 8 表示无效
    
    // 记录棋子是否移动过 (用于王车易位)
    // [0]: White King, [1]: White Rook (0,0), [2]: White Rook (0,7)
    // [3]: Black King, [4]: Black Rook (7,0), [5]: Black Rook (7,7)
    reg [5:0] piece_moved; 

    // 音效码定义
    localparam SND_SELECT   = 3'd1; // 选择
    localparam SND_DESELECT = 3'd2; // 取消选择
    localparam SND_MOVE     = 3'd3; // 移动
    localparam SND_CAPTURE  = 3'd4; // 吃子
    localparam SND_ILLEGAL  = 3'd5; // 非法操作
    localparam SND_PROMOTE  = 3'd6; // 升变
    localparam SND_GAMEOVER = 3'd7; // 游戏结束

    reg game_over_sound_played; // 防止游戏结束音效循环播放

    // 常量定义
    localparam WHITE = 1'b0;
    localparam BLACK = 1'b1;
    
    localparam PAWN   = 3'd6; // 兵
    localparam ROOK   = 3'd5; // 车
    localparam KNIGHT = 3'd4; // 马
    localparam BISHOP = 3'd3; // 象
    localparam QUEEN  = 3'd2; // 后
    localparam KING   = 3'd1; // 王

    localparam PLAY_STATE = 2'b01;
    localparam BLACK_WIN_STATE = 2'b10; // 黑胜
    localparam WHITE_WIN_STATE = 2'b11; // 白胜
    localparam DRAW_STATE = 2'b00; // 和棋

    // 按键边沿检测
    reg prev_pressed;
    wire pressed_pulse = is_pressed && !prev_pressed;   // 检测按下的上升沿脉冲
    
    reg prev_g_pressed;
    wire g_pressed_pulse = is_g_pressed && !prev_g_pressed;

    // ---------------------------------------------------------
    // Legal Moves Mask Generation (for highlighting)
    // ---------------------------------------------------------
    reg [63:0] legal_moves_mask;
    integer tx, ty, k_chk;
    reg path_clear;
    
    always @(*) begin
        legal_moves_mask = 0;
        if (has_selected) begin
            for (ty = 0; ty < 8; ty = ty + 1) begin
                for (tx = 0; tx < 8; tx = tx + 1) begin
                    // Basic check: Target is not own piece (except for castling, but castling target is empty)
                    if (!(board[ty][tx][4] && board[ty][tx][3] == turn)) begin
                        case (board[sel_y][sel_x][2:0])
                            PAWN: begin
                                if (turn == WHITE) begin
                                    // Forward 1
                                    if (tx == sel_x && ty == sel_y + 1 && !board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // Forward 2
                                    else if (tx == sel_x && ty == sel_y + 2 && sel_y == 1 && !board[sel_y+1][sel_x][4] && !board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // Capture
                                    else if ((tx == sel_x + 1 || tx == sel_x - 1) && ty == sel_y + 1 && board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // En Passant
                                    else if ((tx == sel_x + 1 || tx == sel_x - 1) && ty == sel_y + 1 && !board[ty][tx][4] &&
                                             en_passant_col == tx && board[sel_y][tx][4] && board[sel_y][tx][3] == BLACK && board[sel_y][tx][2:0] == PAWN)
                                        legal_moves_mask[ty*8 + tx] = 1;
                                end else begin // BLACK
                                    // Forward 1
                                    if (tx == sel_x && ty == sel_y - 1 && !board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // Forward 2
                                    else if (tx == sel_x && ty == sel_y - 2 && sel_y == 6 && !board[sel_y-1][sel_x][4] && !board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // Capture
                                    else if ((tx == sel_x + 1 || tx == sel_x - 1) && ty == sel_y - 1 && board[ty][tx][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    // En Passant
                                    else if ((tx == sel_x + 1 || tx == sel_x - 1) && ty == sel_y - 1 && !board[ty][tx][4] &&
                                             en_passant_col == tx && board[sel_y][tx][4] && board[sel_y][tx][3] == WHITE && board[sel_y][tx][2:0] == PAWN)
                                        legal_moves_mask[ty*8 + tx] = 1;
                                end
                            end
                            
                            ROOK: begin
                                if (tx == sel_x || ty == sel_y) begin
                                    path_clear = 1;
                                    if (tx == sel_x) begin // Vertical
                                        if (ty > sel_y) begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > sel_y && k_chk < ty && board[k_chk][tx][4]) path_clear = 0;
                                        end else begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > ty && k_chk < sel_y && board[k_chk][tx][4]) path_clear = 0;
                                        end
                                    end else begin // Horizontal
                                        if (tx > sel_x) begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > sel_x && k_chk < tx && board[ty][k_chk][4]) path_clear = 0;
                                        end else begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > tx && k_chk < sel_x && board[ty][k_chk][4]) path_clear = 0;
                                        end
                                    end
                                    if (path_clear) legal_moves_mask[ty*8 + tx] = 1;
                                end
                            end
                            
                            KNIGHT: begin
                                if (((tx > sel_x ? tx - sel_x : sel_x - tx) == 1 && (ty > sel_y ? ty - sel_y : sel_y - ty) == 2) ||
                                    ((tx > sel_x ? tx - sel_x : sel_x - tx) == 2 && (ty > sel_y ? ty - sel_y : sel_y - ty) == 1))
                                    legal_moves_mask[ty*8 + tx] = 1;
                            end
                            
                            BISHOP: begin
                                if ((tx > sel_x ? tx - sel_x : sel_x - tx) == (ty > sel_y ? ty - sel_y : sel_y - ty)) begin
                                    path_clear = 1;
                                    for (k_chk = 1; k_chk < 8; k_chk = k_chk + 1) begin
                                        if (k_chk < (tx > sel_x ? tx - sel_x : sel_x - tx)) begin
                                            if (board[ty > sel_y ? sel_y + k_chk : sel_y - k_chk][tx > sel_x ? sel_x + k_chk : sel_x - k_chk][4]) path_clear = 0;
                                        end
                                    end
                                    if (path_clear) legal_moves_mask[ty*8 + tx] = 1;
                                end
                            end
                            
                            QUEEN: begin
                                path_clear = 1;
                                if (tx == sel_x || ty == sel_y) begin
                                    // Rook-like
                                    if (tx == sel_x) begin // Vertical
                                        if (ty > sel_y) begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > sel_y && k_chk < ty && board[k_chk][tx][4]) path_clear = 0;
                                        end else begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > ty && k_chk < sel_y && board[k_chk][tx][4]) path_clear = 0;
                                        end
                                    end else begin // Horizontal
                                        if (tx > sel_x) begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > sel_x && k_chk < tx && board[ty][k_chk][4]) path_clear = 0;
                                        end else begin
                                            for (k_chk = 0; k_chk < 8; k_chk = k_chk + 1) if (k_chk > tx && k_chk < sel_x && board[ty][k_chk][4]) path_clear = 0;
                                        end
                                    end
                                    if (path_clear) legal_moves_mask[ty*8 + tx] = 1;
                                end else if ((tx > sel_x ? tx - sel_x : sel_x - tx) == (ty > sel_y ? ty - sel_y : sel_y - ty)) begin
                                    // Bishop-like
                                    for (k_chk = 1; k_chk < 8; k_chk = k_chk + 1) begin
                                        if (k_chk < (tx > sel_x ? tx - sel_x : sel_x - tx)) begin
                                            if (board[ty > sel_y ? sel_y + k_chk : sel_y - k_chk][tx > sel_x ? sel_x + k_chk : sel_x - k_chk][4]) path_clear = 0;
                                        end
                                    end
                                    if (path_clear) legal_moves_mask[ty*8 + tx] = 1;
                                end
                            end
                            
                            KING: begin
                                if ((tx > sel_x ? tx - sel_x : sel_x - tx) <= 1 && (ty > sel_y ? ty - sel_y : sel_y - ty) <= 1) begin
                                    legal_moves_mask[ty*8 + tx] = 1;
                                end
                                // Castling
                                else if (ty == sel_y && (tx > sel_x ? tx - sel_x : sel_x - tx) == 2) begin
                                    if (turn == WHITE && !piece_moved[0]) begin
                                        if (tx == 6 && !piece_moved[2] && !board[0][5][4] && !board[0][6][4]) legal_moves_mask[ty*8 + tx] = 1;
                                        else if (tx == 2 && !piece_moved[1] && !board[0][1][4] && !board[0][2][4] && !board[0][3][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    end else if (turn == BLACK && !piece_moved[3]) begin
                                        if (tx == 6 && !piece_moved[5] && !board[7][5][4] && !board[7][6][4]) legal_moves_mask[ty*8 + tx] = 1;
                                        else if (tx == 2 && !piece_moved[4] && !board[7][1][4] && !board[7][2][4] && !board[7][3][4]) legal_moves_mask[ty*8 + tx] = 1;
                                    end
                                end
                            end
                        endcase
                    end
                end
            end
        end
    end

    // 输出映射: 将 2D board 映射到 1D board_data
    // board_data 格式: 每个格子 12 位
    // [11:10]: 预留/填充 (2'b0)
    // [9]: 光标状态(1: 已选中, 0: 未选中) 已选中的是红色光标，未选中是黑色光标
    // [8]: 是否有光标 (1: 有光标, 0: 无光标)
    // [7:0]: 棋盘数据 (board[y][x])
    genvar gy, gx;
    generate
        for (gy = 0; gy < 8; gy = gy + 1) begin : map_row
            for (gx = 0; gx < 8; gx = gx + 1) begin : map_col
                // 选中棋子高亮逻辑: 选中位置的 [9] 和 [8] 都置 1
                wire is_cursor = (cursor_x == gx && cursor_y == gy);
                wire is_selected_pos = ((has_selected && sel_x == gx && sel_y == gy) || (has_selected && cursor_x == gx && cursor_y == gy));
                wire is_hint = legal_moves_mask[gy*8 + gx];
                // is_selected_pos 用于显示红色光标, 仅有两种情况显示红色光标: 当前已经有棋子被选中且光标在该位置, 或者该位置就是被选中的棋子位置
                // 如果正在升变，且是升变位置，显示当前选择的升变棋子
                wire [7:0] cell_wanted_promotion = (promoting && prom_x == gx && prom_y == gy) ? 
                                           {1'b1, turn, prom_piece} : board[gy][gx];

                assign board_data[((gy * 8 + gx) * 12) + 11 : (gy * 8 + gx) * 12] = 
                    {2'b0, (is_selected_pos), (is_cursor || is_selected_pos || is_hint), cell_wanted_promotion};
            end
        end
    endgenerate

    // 输出端口赋值: 升变时显示选择的棋子，否则显示光标下的棋子
    assign wanted_promotion = (promoting) ? {1'b1, turn, prom_piece} : board[cursor_y][cursor_x];

    // 移动逻辑判断
    reg is_legal_move;
    reg path_blocked;
    reg is_castling; // 标记是否是王车易位
    reg is_en_passant; // 标记是否是吃过路兵
    integer k;
    
    wire [2:0] current_piece_type = board[sel_y][sel_x][2:0];   // 当前选中棋子类型
    wire [3:0] abs_dx = (cursor_x > sel_x) ? (cursor_x - sel_x) : (sel_x - cursor_x);   // 水平绝对距离
    wire [3:0] abs_dy = (cursor_y > sel_y) ? (cursor_y - sel_y) : (sel_y - cursor_y);   // 垂直绝对距离

    always @(*) begin
        is_legal_move = 0;
        path_blocked = 0;
        is_castling = 0;
        is_en_passant = 0;

        case (current_piece_type)
            PAWN: begin
                if (turn == WHITE) begin
                    // Move 1 step forward
                    if (abs_dx == 0 && cursor_y == sel_y + 1 && !board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // Move 2 steps forward
                    else if (abs_dx == 0 && cursor_y == sel_y + 2 && sel_y == 1 && !board[sel_y+1][sel_x][4] && !board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // Capture
                    else if (abs_dx == 1 && cursor_y == sel_y + 1 && board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // En Passant
                    else if (abs_dx == 1 && cursor_y == sel_y + 1 && !board[cursor_y][cursor_x][4] && 
                             en_passant_col == cursor_x && board[sel_y][cursor_x][4] && board[sel_y][cursor_x][3] == BLACK && board[sel_y][cursor_x][2:0] == PAWN) begin
                        is_legal_move = 1;
                        is_en_passant = 1;
                    end
                end else begin // BLACK
                    // Move 1 step forward (y decreases)
                    if (abs_dx == 0 && cursor_y == sel_y - 1 && !board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // Move 2 steps forward
                    else if (abs_dx == 0 && cursor_y == sel_y - 2 && sel_y == 6 && !board[sel_y-1][sel_x][4] && !board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // Capture
                    else if (abs_dx == 1 && cursor_y == sel_y - 1 && board[cursor_y][cursor_x][4])
                        is_legal_move = 1;
                    // En Passant
                    else if (abs_dx == 1 && cursor_y == sel_y - 1 && !board[cursor_y][cursor_x][4] && 
                             en_passant_col == cursor_x && board[sel_y][cursor_x][4] && board[sel_y][cursor_x][3] == WHITE && board[sel_y][cursor_x][2:0] == PAWN) begin
                        is_legal_move = 1;
                        is_en_passant = 1;
                    end
                end
            end
            
            ROOK: begin
                if (abs_dx == 0 || abs_dy == 0) begin
                    // Check path
                    if (abs_dx == 0) begin // Vertical
                        for (k = 1; k < 8; k = k + 1) begin
                            if (k < abs_dy) begin
                                if (board[(cursor_y > sel_y ? sel_y + k : sel_y - k)][sel_x][4]) path_blocked = 1;
                            end
                        end
                    end else begin // Horizontal
                        for (k = 1; k < 8; k = k + 1) begin
                            if (k < abs_dx) begin
                                if (board[sel_y][(cursor_x > sel_x ? sel_x + k : sel_x - k)][4]) path_blocked = 1;
                            end
                        end
                    end
                    if (!path_blocked) is_legal_move = 1;
                end
            end
            
            KNIGHT: begin
                if ((abs_dx == 1 && abs_dy == 2) || (abs_dx == 2 && abs_dy == 1))
                    is_legal_move = 1;
            end
            
            BISHOP: begin
                if (abs_dx == abs_dy && abs_dx != 0) begin
                    for (k = 1; k < 8; k = k + 1) begin
                        if (k < abs_dx) begin
                            if (board[(cursor_y > sel_y ? sel_y + k : sel_y - k)][(cursor_x > sel_x ? sel_x + k : sel_x - k)][4]) path_blocked = 1;
                        end
                    end
                    if (!path_blocked) is_legal_move = 1;
                end
            end
            
            QUEEN: begin
                if (abs_dx == 0 || abs_dy == 0) begin
                    // Rook-like move
                    if (abs_dx == 0) begin // Vertical
                        for (k = 1; k < 8; k = k + 1) begin
                            if (k < abs_dy) begin
                                if (board[(cursor_y > sel_y ? sel_y + k : sel_y - k)][sel_x][4]) path_blocked = 1;
                            end
                        end
                    end else begin // Horizontal
                        for (k = 1; k < 8; k = k + 1) begin
                            if (k < abs_dx) begin
                                if (board[sel_y][(cursor_x > sel_x ? sel_x + k : sel_x - k)][4]) path_blocked = 1;
                            end
                        end
                    end
                    if (!path_blocked) is_legal_move = 1;
                end else if (abs_dx == abs_dy) begin
                    // Bishop-like move
                    for (k = 1; k < 8; k = k + 1) begin
                        if (k < abs_dx) begin
                            if (board[(cursor_y > sel_y ? sel_y + k : sel_y - k)][(cursor_x > sel_x ? sel_x + k : sel_x - k)][4]) path_blocked = 1;
                        end
                    end
                    if (!path_blocked) is_legal_move = 1;
                end
            end
            
            KING: begin
                if (abs_dx <= 1 && abs_dy <= 1) begin
                    is_legal_move = 1;
                end else if (abs_dy == 0 && abs_dx == 2) begin
                    // Castling
                    if (turn == WHITE && !piece_moved[0]) begin
                        if (cursor_x == 6 && !piece_moved[2] && !board[0][5][4] && !board[0][6][4]) begin // King side
                            is_legal_move = 1;
                            is_castling = 1;
                        end else if (cursor_x == 2 && !piece_moved[1] && !board[0][1][4] && !board[0][2][4] && !board[0][3][4]) begin // Queen side
                            is_legal_move = 1;
                            is_castling = 1;
                        end
                    end else if (turn == BLACK && !piece_moved[3]) begin
                        if (cursor_x == 6 && !piece_moved[5] && !board[7][5][4] && !board[7][6][4]) begin // King side
                            is_legal_move = 1;
                            is_castling = 1;
                        end else if (cursor_x == 2 && !piece_moved[4] && !board[7][1][4] && !board[7][2][4] && !board[7][3][4]) begin // Queen side
                            is_legal_move = 1;
                            is_castling = 1;
                        end
                    end
                end
            end
        endcase
    end

    integer i, j;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位逻辑
            state <= PLAY_STATE;
            turn <= WHITE;
            has_selected <= 0;
            sel_x <= 0;
            sel_y <= 0;
            sound_code <= 0;
            play_sound <= 0;
            prev_pressed <= 0;
            prev_g_pressed <= 0;
            
            promoting <= 0;
            prom_piece <= QUEEN;
            prom_x <= 0;
            prom_y <= 0;
            en_passant_col <= 8;
            piece_moved <= 0;
            game_over_sound_played <= 0;

            // 初始化棋盘
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    board[i][j] <= 8'b0;
                end
            end

            // 初始化白方 (Row 0, 1)
            board[0][0] <= {1'b1, WHITE, ROOK};
            board[0][1] <= {1'b1, WHITE, KNIGHT};
            board[0][2] <= {1'b1, WHITE, BISHOP};
            board[0][3] <= {1'b1, WHITE, QUEEN};
            board[0][4] <= {1'b1, WHITE, KING};
            board[0][5] <= {1'b1, WHITE, BISHOP};
            board[0][6] <= {1'b1, WHITE, KNIGHT};
            board[0][7] <= {1'b1, WHITE, ROOK};
            for (j = 0; j < 8; j = j + 1) board[1][j] <= {1'b1, WHITE, PAWN};

            // 初始化黑方 (Row 7, 6)
            board[7][0] <= {1'b1, BLACK, ROOK};
            board[7][1] <= {1'b1, BLACK, KNIGHT};
            board[7][2] <= {1'b1, BLACK, BISHOP};
            board[7][3] <= {1'b1, BLACK, QUEEN};
            board[7][4] <= {1'b1, BLACK, KING};
            board[7][5] <= {1'b1, BLACK, BISHOP};
            board[7][6] <= {1'b1, BLACK, KNIGHT};
            board[7][7] <= {1'b1, BLACK, ROOK};
            for (j = 0; j < 8; j = j + 1) board[6][j] <= {1'b1, BLACK, PAWN};

        end else begin
            prev_pressed <= is_pressed;
            prev_g_pressed <= is_g_pressed;
            play_sound <= 0; // 脉冲信号, 默认拉低

            case (state)
                PLAY_STATE: begin
                    game_over_sound_played <= 0; // 在游戏进行中重置标志
                    if (promoting) begin
                        // 升变选择阶段
                        if (pressed_pulse) begin
                            // 切换升变棋子
                            case (prom_piece)
                                QUEEN: prom_piece <= ROOK;
                                ROOK: prom_piece <= BISHOP;
                                BISHOP: prom_piece <= KNIGHT;
                                KNIGHT: prom_piece <= QUEEN;
                                default: prom_piece <= QUEEN;
                            endcase
                            sound_code <= SND_SELECT; // 切换音效
                            play_sound <= 1;
                        end else if (g_pressed_pulse) begin
                            // 确认升变
                            board[prom_y][prom_x] <= {1'b1, turn, prom_piece};
                            promoting <= 0;
                            turn <= ~turn; // 升变完成后才切换回合
                            sound_code <= SND_PROMOTE; // 升变音效
                            play_sound <= 1;
                        end
                    end else begin
                        // 正常游戏阶段
                        if (pressed_pulse) begin
                            if (cursor_x < 8 && cursor_y < 8) begin
                                // 光标在棋盘内
                                if (!has_selected) begin
                                    // 尝试选择棋子
                                    // 检查: 有棋子 且 是己方棋子
                                    if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][3] == turn) begin
                                        has_selected <= 1;
                                        sel_x <= cursor_x;
                                        sel_y <= cursor_y;
                                        sound_code <= SND_SELECT; // 选择音效
                                        play_sound <= 1;
                                    end else begin
                                        // 非法操作: 点击空地或敌方棋子
                                        sound_code <= SND_ILLEGAL;
                                        play_sound <= 1;
                                    end
                                end else begin
                                    // 已经选中棋子
                                    if (cursor_x == sel_x && cursor_y == sel_y) begin
                                        // 点击自己: 取消选择
                                        has_selected <= 0;
                                        sound_code <= SND_DESELECT; // 取消选择音效
                                        play_sound <= 1;
                                    end else begin
                                        // 点击其他位置
                                        // 检查是否是己方棋子 (换选)
                                        if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][3] == turn) begin
                                            sel_x <= cursor_x;
                                            sel_y <= cursor_y;
                                            sound_code <= SND_SELECT; // 选择音效
                                            play_sound <= 1;
                                        end else begin
                                            if (is_legal_move) begin
                                                // 移动或吃子 (目标是空地或敌方)
                                                
                                                // 确定音效类型 (在执行移动前判断)
                                                if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][2:0] == KING) begin
                                                    sound_code <= SND_GAMEOVER; // 吃王 -> 游戏结束音效
                                                    game_over_sound_played <= 1; // 标记已播放，防止状态跳转后重复播放
                                                end else if (board[cursor_y][cursor_x][4] || is_en_passant) begin
                                                    sound_code <= SND_CAPTURE; // 吃子音效
                                                end else begin
                                                    sound_code <= SND_MOVE; // 移动音效
                                                end
                                                play_sound <= 1;

                                                // 检查游戏结束 (吃掉王)
                                                if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][2:0] == KING) begin
                                                    state <= (turn == WHITE) ? WHITE_WIN_STATE : BLACK_WIN_STATE;
                                                end

                                                // 执行移动
                                                board[cursor_y][cursor_x] <= board[sel_y][sel_x];
                                                board[sel_y][sel_x] <= 8'b0; // 清空原位置
                                                
                                                // 特殊规则处理
                                                
                                                // 1. 吃过路兵
                                                if (is_en_passant) begin
                                                    board[sel_y][cursor_x] <= 8'b0; // 清除被吃的兵
                                                end
                                                
                                                // 2. 王车易位
                                                if (is_castling) begin
                                                    if (cursor_x == 6) begin // King side
                                                        board[sel_y][5] <= board[sel_y][7]; // Move Rook
                                                        board[sel_y][7] <= 8'b0;
                                                    end else if (cursor_x == 2) begin // Queen side
                                                        board[sel_y][3] <= board[sel_y][0]; // Move Rook
                                                        board[sel_y][0] <= 8'b0;
                                                    end
                                                end
                                                
                                                // 更新 piece_moved 状态
                                                if (board[sel_y][sel_x][2:0] == KING) begin
                                                    if (turn == WHITE) piece_moved[0] <= 1;
                                                    else piece_moved[3] <= 1;
                                                end else if (board[sel_y][sel_x][2:0] == ROOK) begin
                                                    if (turn == WHITE) begin
                                                        if (sel_x == 0 && sel_y == 0) piece_moved[1] <= 1;
                                                        if (sel_x == 7 && sel_y == 0) piece_moved[2] <= 1;
                                                    end else begin
                                                        if (sel_x == 0 && sel_y == 7) piece_moved[4] <= 1;
                                                        if (sel_x == 7 && sel_y == 7) piece_moved[5] <= 1;
                                                    end
                                                end
                                                
                                                // 更新 en_passant_col
                                                if (board[sel_y][sel_x][2:0] == PAWN && abs_dy == 2) begin
                                                    en_passant_col <= sel_x;
                                                end else begin
                                                    en_passant_col <= 8; // Reset
                                                end
                                                
                                                // 3. 升变检测
                                                if (board[sel_y][sel_x][2:0] == PAWN && 
                                                   ((turn == WHITE && cursor_y == 7) || (turn == BLACK && cursor_y == 0))) begin
                                                    promoting <= 1;
                                                    prom_x <= cursor_x;
                                                    prom_y <= cursor_y;
                                                    prom_piece <= QUEEN; // 默认升变为后
                                                    // 注意：此时不切换回合，等待升变确认
                                                end else begin
                                                    // 切换回合
                                                    turn <= ~turn;
                                                end
                                                
                                                has_selected <= 0;
                                            end else begin
                                                // 非法移动
                                                sound_code <= SND_ILLEGAL;
                                                play_sound <= 1;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                BLACK_WIN_STATE: begin
                    if (!game_over_sound_played) begin
                        sound_code <= SND_GAMEOVER;
                        play_sound <= 1;
                        game_over_sound_played <= 1;
                    end
                end
                WHITE_WIN_STATE: begin
                    if (!game_over_sound_played) begin
                        sound_code <= SND_GAMEOVER;
                        play_sound <= 1;
                        game_over_sound_played <= 1;
                    end
                end
            endcase
        end
    end

endmodule