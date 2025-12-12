module Chess(
    input clkk,
    input rstn,
    input PS2_CLK,
    input PS2_DATA,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue,
    output hs,
    output vs,
    output pwm,
    output start // Audio enable 声音使能信号
);

    wire clk; // System clock   系统时钟
    wire pclk; // Pixel clock   像素时钟, 用于驱动显示器
    wire locked;    // Clock locked signal 时钟锁定信号
    
    // Instantiate Clock Wizard
    clk_wiz_0 clk_wiz_inst (
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(locked),    // 时钟锁定信号, 只有当时钟稳定后该信号才会被拉高
        .clk_in1(clkk)
    );

    // 游戏状态寄存器和定义
    reg [1:0] state;
    localparam MENU = 2'b00;
    localparam PLAY = 2'b01;
    localparam SETTLE = 2'b10;
    
    // 次态线
    wire [1:0] next_state_menu;
    wire [1:0] next_state_play;
    wire [1:0] next_state_settle;
    
    // 状态更新逻辑, 每个时钟周期根据当前状态和次态线更新状态
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            state <= MENU;
        end else begin
            case (state)
                MENU: state <= next_state_menu;
                PLAY: state <= next_state_play;
                SETTLE: state <= next_state_settle;
                default: state <= MENU;
            endcase
        end
    end

    // 键盘输入寄存器
    wire [10:0] key_event;
    keyboard keyboard_inst (
        .clk_100mhz(clk),   // 时钟
        .rst_n(rstn),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .key_event(key_event)
    );

    // 选择器光标模块
    wire [3:0] cursor_x;
    wire [3:0] cursor_y;
    wire is_pressed;    // 选择器是否按下逻辑线
    wire [11:0] selected_piece; // 被选择的棋子信息
    
    Selector selector_inst (
        .clk(clk),
        .rstn(rstn),
        .key_event(key_event),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
        .is_pressed(is_pressed),
        .selected_piece(selected_piece)
    );

    // 菜单模块
    Menu menu_inst (
        .clk(clk),
        .rstn(rstn),
        .state(state),
        .is_pressed(is_pressed),
        .next_state(next_state_menu)
    );

    // 对局模块
    wire [12*64-1:0] board_data;
    wire [2:0] sound_code;
    wire play_sound;
    
    Play play_inst (
        .clk(clk),
        .rstn(rstn),
        .state(state),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
        .is_pressed(is_pressed),
        .next_state(next_state_play),
        .board_data(board_data),
        .sound_code(sound_code),
        .play_sound(play_sound)
    );

    // Settle
    Settle settle_inst (
        .clk(clk),
        .rstn(rstn),
        .state(state),
        .is_pressed(is_pressed),
        .next_state(next_state_settle)
    );

    // GFX
    GFX gfx_inst (
        .clk(clk),
        .pclk(pclk),
        .rstn(rstn),
        .state(state),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
        .board_data(board_data),
        .red(red),
        .green(green),
        .blue(blue),
        .hs(hs),
        .vs(vs)
    );

    // Music
    assign start = 1'b1; // Enable audio amp
    MUSIC music_inst (
        .clk(clk),
        .start(play_sound), 
        .rstn(rstn),
        .B(pwm)
    );

endmodule