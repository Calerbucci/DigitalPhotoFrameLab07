module mem_addr_gen(
   input clk,
   input rst,
   input en,
   input dir,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output [16:0] pixel_addr
   );
    
   reg [7:0] position;
  
   assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;  //640*480 --> 320*240 
   
   always @ (posedge clk or posedge rst) begin
      if(rst) begin
          position <= 0;
      end
      else begin
        if(en==1)
            if(dir == 0) begin
                if(position < 239) begin
                    position <= position + 1;
                end
                else begin
                    position <= 0;
                end
            end
            else if(dir == 1) begin
                if(position > 1) begin
                    position <= position -1;
                end
                else begin
                    position <= 240;
                end
            end
        end
      
//      else if(en == 1) begin
//            if(dir == 0) begin
//               if(position < 239) begin
//                   position <= position + 1;
//               end
//               else begin
//                   position <= 0;
//               end
//             end
//             else if(dir == 1) begin
//                    if(position > 1) begin
//                        position <= position -1;
//                    end
//                    else begin
//                        position <= 240;
//                    end
//             end
//          end
     end
    
endmodule
