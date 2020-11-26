module lab07_1(
    input clk,
    input rst,
    input en,
    input dir,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
    );
    
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    
    reg [8:0] position;
    
    clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22));
     
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)); 

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt));
    
    assign {vgaRed, vgaBlue, vgaGreen} = (valid==1'b1) ? pixel:12'h0;
    assign pixel_addr = (((h_cnt>>1) + position * 319) % 320 + 320*(v_cnt>>1) + 1)% 76800;
    
    always@(posedge clk_22 or posedge rst) begin
        if(rst) begin
            position <= 0;
        end
        else if(en) begin
            if(dir) begin
                if(position < 319) begin
                    position <= position + 1;
                end
                else begin
                    position <= 0;
                end
            end
            else begin
                if(position > 1) begin
                    position <= position - 1;
                end
                else begin
                    position <= 320;
                end
            end
        end
    end
    
endmodule
