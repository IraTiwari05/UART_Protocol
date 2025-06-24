`timescale 1ns / 1ps

module uart_rx(
input wire clk,input wire rst,
input wire rx, input wire baud_tick,input wire parity_en,
output reg [7:0] data_out, output reg rx_done, output reg parity_error
  );
   parameter IDLE=3'd0,START=3'd1, DATA=3'd2, PARITY=3'd3, STOP=3'd4;
reg [2:0] state=IDLE;
reg sampled_parity=0;
reg parity_bit=0;
reg [7:0] shift_reg;
reg [2:0] bit_idx=0;

always @(posedge clk or posedge rst)begin
   if(rst)begin
     data_out<=0;
     rx_done<=0;
     shift_reg<=0;
     parity_error<=0;
     state<=IDLE;
     bit_idx<=0;
   end
   else if(baud_tick)begin
      case(state)
      IDLE:begin
      rx_done<=0;
      parity_error<=0;
          if(rx==0)begin
             state<=START;
          end
      end
      START:begin
           if(rx==0)begin
             bit_idx<=0;
             state<=DATA;
           end
           else begin
              state<=IDLE;
           end
      end
      DATA:begin
           shift_reg<={rx,shift_reg[7:1]};
           bit_idx<=bit_idx+1;
           if(bit_idx==3'd7)begin
               state<=(parity_en)?PARITY:STOP;
           end
      end
      PARITY:begin
        sampled_parity<=rx;
        parity_bit=^shift_reg;
        state<=STOP;
    end
    STOP:begin
        if(rx==1)begin
         data_out<=shift_reg;
         rx_done<=1;
         if(parity_en)begin
            parity_error<=(parity_bit!=sampled_parity);
         end
         state<=IDLE;
        end         
    end
      endcase
   end
end

endmodule
