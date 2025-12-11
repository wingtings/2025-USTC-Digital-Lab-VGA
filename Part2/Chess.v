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
    output start // Audio enable
);

    wire clk; // System clock
    wire pclk; // Pixel clock
    wire locked;
    
    // Instantiate Clock Wizard
    clk_wiz_0 clk_wiz_inst (
        .clk_out1(pclk), 
        .clk_out2(clk),  
        .reset(~rstn),
        .locked(locked),
        .clk_in1(clkk)
    );

    // State Machine
    reg [1:0] state;
    localparam MENU = 2'b00;
    localparam PLAY = 2'b01;
    localparam SETTLE = 2'b10;
    
    wire [1:0] next_state_menu;
    wire [1:0] next_state_play;
    wire [1:0] next_state_settle;
    
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

    // Keyboard
    wire [10:0] key_event;
    keyboard keyboard_inst (
        .clk_100mhz(clk),
        .rst_n(rstn),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .key_event(key_event)
    );

    // Selector
    wire [3:0] cursor_x;
    wire [3:0] cursor_y;
    wire is_pressed;
    wire [11:0] selected_piece;
    
    Selector selector_inst (
        .clk(clk),
        .rstn(rstn),
        .key_event(key_event),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
        .is_pressed(is_pressed),
        .selected_piece(selected_piece)
    );

    // Menu
    Menu menu_inst (
        .clk(clk),
        .rstn(rstn),
        .state(state),
        .is_pressed(is_pressed),
        .next_state(next_state_menu)
    );

    // Play
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