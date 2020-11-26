module lab07_2(
    input clk,
    input rst,
    input shift,
    input split,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync
    );
    
    wire [11:0] data;
    wire [11:0] pixel;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    wire clk_25MHz;
    wire clk_22;
    wire valid;
    
    reg [16:0] pixel_addr;
    reg [9:0] position;
    reg [9:0] black_frame;
    reg [9:0] f1;
    reg [9:0] f2;
    
    reg [1:0] play;
    reg shift_left, done;
    
    clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );
     
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
    ); 

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
    always@(posedge clk or posedge rst) begin
        if(rst || done) begin
            play = 2'd0;
        end
        else begin
            if(play == 0) begin
                if(shift)
                    play = 2'd1;
                else if(split)
                    play = 2'd2;
                else
                    play = play;
            end
            else begin
                play = play;
            end
        end
    end
    
    always@(posedge clk_22 or posedge rst) begin
        if(rst || done) begin
            position <= 0;
            black_frame <= 640;
            f1 <= 0;
            f2 <= 0;
            shift_left <= 1;
            done <= 0;
        end
        else begin
            case(play)
                2'd0 : begin
                    position <= 0;
                    black_frame <= 640;
                    shift_left <= 1;
                    done <= 0;
                end
                2'd1 : begin
                    if(shift_left) begin
                        if(black_frame > 0) begin
                            black_frame = black_frame - 2;
                            shift_left = shift_left;
                            done = 0;
                        end
                        else begin
                            black_frame <= 0;
                            shift_left <= 0;
                            done = 0;
                        end
                    end
                    else begin
                        if(black_frame < 480) begin
                            black_frame = black_frame + 2;
                            done = 0;
                        end
                        else begin
                            black_frame = 479;
                            done = 1;
                        end
                    end
                end
                2'd2 : begin
                    f1 = (f1 == 240) ? 240 : f1 + 2;
                    if(f2 == 320) begin
                        f2 = 320;
                        done = 1;
                        position = position;
                    end
                    else begin
                        f2 = f2 + 2;
                        position = position + 1;
                    end
                end
                default : begin
                    position <= position;
                    done <= 0;
                end
            endcase
        end
    end
    
    always@(posedge clk) begin
        if(valid) begin
            case(play)
                2'd0 : begin
                    pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;
                    {vgaRed, vgaBlue, vgaGreen} = pixel;
                end
                2'd1 : begin
                    if(shift_left) begin
                        pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1))% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = (h_cnt > black_frame) ? 12'h0 : pixel;
                    end
                    else begin
                        pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1))% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = (v_cnt > black_frame) ? 12'h0 : pixel;
                    end
                end
                2'd2 : begin
                    if(v_cnt >= 0 && v_cnt < 240 - f1 && h_cnt < 320 && h_cnt >= 0) begin
                        pixel_addr = ((h_cnt>>1) + 320*(v_cnt>>1) + 320* position)% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = pixel;
                    end
                    else if(v_cnt >= 0 && v_cnt < 240 && h_cnt < 640 && h_cnt >= 320 + f2 ) begin
                        pixel_addr = ((((h_cnt>>1) + position * 319)%320 + 320*(v_cnt>>1)))% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = pixel;
                    end
                    else if(v_cnt >= 240 && v_cnt < 480 && h_cnt < 320 - f2 && h_cnt >= 0) begin
                        pixel_addr = ((((h_cnt>>1) + position) + 320*(v_cnt>>1)))% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = pixel;
                    end
                    else if(v_cnt >= 240 + f1 && v_cnt < 480 && h_cnt < 640 && h_cnt >= 320) begin
                        pixel_addr = ((h_cnt>>1) + (320*(v_cnt>>1) + 320* (240 - position)))% 76800;
                        {vgaRed, vgaBlue, vgaGreen} = pixel;
                    end
                    else begin
                        {vgaRed, vgaBlue, vgaGreen} = 12'h0;
                    end
                end
                default : begin
                    pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;
                    {vgaRed, vgaBlue, vgaGreen} = pixel;
                end
            endcase
        end
        else begin
            pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;
            {vgaRed, vgaBlue, vgaGreen} = 12'h0;
        end
    end
    
endmodule