module Sound(
    input clk,
    input rstn,
    input [2:0] sound_code,
    input play_sound,
    output reg audio_out
);

    reg is_playing;
    reg [2:0] current_code;
    reg [26:0] duration_cnt;
    
    // 持续时间: 0.1s @ 100MHz = 10,000,000 cycles
    localparam DURATION = 10000000; 

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            is_playing <= 0;
            current_code <= 0;
            duration_cnt <= 0;
        end else begin
            if (play_sound) begin
                is_playing <= 1;
                current_code <= sound_code;
                duration_cnt <= DURATION;
            end else if (is_playing) begin
                if (duration_cnt > 0)
                    duration_cnt <= duration_cnt - 1;
                else
                    is_playing <= 0;
            end
        end
    end

    reg [26:0] q; // Period count
    always @(*) begin
        case (current_code)
            3'd1: q = 100000000/1046; // Select: High Do (1046Hz)
            3'd2: q = 100000000/784;  // Move: Mid So (784Hz)
            3'd3: q = 100000000/523;  // Check/Other: Mid Do (523Hz)
            3'd4: q = 100000000/1318; // Win: High Mi (1318Hz)
            3'd5: q = 100000000/261;  // Lose: Low Do (261Hz)
            default: q = 0;
        endcase
    end

    reg [26:0] p;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            audio_out <= 0;
            p <= 0;
        end else begin
            if (is_playing && q != 0) begin
                if (p >= q - 1) 
                    p <= 0;
                else 
                    p <= p + 1;
                
                // PWM generation with small duty cycle for volume control
                if (p == 0) audio_out <= 1;
                if (p == q/256) audio_out <= 0; 
            end else begin
                audio_out <= 0;
                p <= 0;
            end
        end
    end

endmodule
