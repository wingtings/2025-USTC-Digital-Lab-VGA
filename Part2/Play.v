module Play(
    input clk,
    input rstn,
    output reg [1:0] state,
    input [3:0] cursor_x,
    input [3:0] cursor_y,
    input is_pressed,
    // output reg [1:0] next_state,
    output [12*64-1:0] board_data,
    output reg [2:0] sound_code,
    output reg play_sound,
    output reg [1:0] game_over
);

    // 棋盘寄存器堆: 8x8, 每个寄存器 8 位
    // [4]: 有效位 (1: 有棋子, 0: 无棋子)
    // [3]: 阵营 (0: 白方, 1: 黑方)
    // [2:0]: 棋子类型
    reg [7:0] board [7:0][7:0];

    // 游戏状态
    reg turn; // 当前回合: 0: 白方, 1: 黑方
    reg has_selected; // 是否已选中棋子
    reg [3:0] sel_x; // 选中棋子 X 坐标
    reg [3:0] sel_y; // 选中棋子 Y 坐标

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
    localparam SETTLE_STATE = 2'b10;

    // 按键边沿检测
    reg prev_pressed;
    wire pressed_pulse = is_pressed && !prev_pressed;   // 检测按下的上升沿脉冲

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
                assign board_data[((gy * 8 + gx) * 12) + 11 : (gy * 8 + gx) * 12] = 
                    {2'b0, has_selected, (sel_x == gx && sel_y == gy), board[gy][gx]};
            end
        end
    endgenerate

    integer i, j;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位逻辑
            state <= PLAY_STATE;
            game_over <= 2'b00;
            turn <= WHITE;
            has_selected <= 0;
            sel_x <= 0;
            sel_y <= 0;
            sound_code <= 0;
            play_sound <= 0;
            prev_pressed <= 0;

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
            play_sound <= 0; // 脉冲信号, 默认拉低

            case (state)
                PLAY_STATE: begin
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
                                sound_code <= 3'd1; // 选择音效
                                play_sound <= 1;
                            end
                        end else begin
                            // 已经选中棋子
                            if (cursor_x == sel_x && cursor_y == sel_y) begin
                                // 点击自己: 取消选择
                                has_selected <= 0;
                            end else begin
                                // 点击其他位置
                                // 检查是否是己方棋子 (换选)
                                if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][3] == turn) begin
                                    sel_x <= cursor_x;
                                    sel_y <= cursor_y;
                                    sound_code <= 3'd1; // 选择音效
                                    play_sound <= 1;
                                end else begin
                                    // 移动或吃子 (目标是空地或敌方)
                                    // TODO: 这里可以添加移动规则校验
                                    
                                    // 检查游戏结束 (吃掉王)
                                    if (board[cursor_y][cursor_x][4] && board[cursor_y][cursor_x][2:0] == KING) begin
                                        game_over <= (turn == WHITE) ? 2'b10 : 2'b01; // 白胜 : 黑胜
                                        state <= SETTLE_STATE;
                                    end

                                    // 执行移动
                                    board[cursor_y][cursor_x] <= board[sel_y][sel_x];
                                    board[sel_y][sel_x] <= 8'b0; // 清空原位置
                                    
                                    // 切换回合
                                    turn <= ~turn;
                                    has_selected <= 0;
                                    
                                    sound_code <= 3'd2; // 移动/吃子音效
                                    play_sound <= 1;
                                end
                            end
                        end
                    end else begin
                        // 光标在棋盘外 (按钮区域)
                        // TODO: 处理认输, 悔棋, 求和, 重开等按钮
                    end
                end
                end
                SETTLE_STATE: begin
                    // 游戏结束状态
                    // TODO: 添加重开逻辑
                end
            endcase
        end
    end

endmodule