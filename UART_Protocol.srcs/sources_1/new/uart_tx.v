`timescale 1ns / 1ps
module uart_tx(input wire clk, input wire rst, 
input wire [7:0] data_in,
input wire parity_en,
input wire baud_tick,
input wire tx_start,
output reg tx, output reg tx_busy
  );
 parameter IDLE=3'd0,START=3'd1, DATA=3'd2, PARITY=3'd3, STOP=3'd4;
 
 reg [2:0] state=IDLE;
 reg [7:0] shift_reg=0;
 reg parity_bit=0;
 reg bit_idx=0;
 always @(posedge clk or posedge rst)begin
  if(rst)begin
   shift_reg<=0;
   state<=IDLE;
   tx<=1;
   tx_busy<=0;
  end
  else begin
  
  case(state)
   IDLE:begin
     tx<=1; tx_busy<=0;
       if(tx_start)begin
       tx_busy<=1;
       state<=IDLE;
       parity_bit<=^data_in;
       end
   end
   START:begin
         shift_reg<=data_in;
         state<=DATA;
         tx<=0;
   end
   DATA:begin
        tx<=shift_reg[0];
        shift_reg<=shift_reg>>1;
        bit_idx<=bit_idx+1;
        if(bit_idx==3'd7)begin
          state<=(parity_en)?PARITY:STOP;
        end
   end
   PARITY:begin
         tx<=parity_bit;
         state<=STOP;
   end
   STOP:begin
       tx<=1'b1;
       state<=IDLE;
       tx_busy<=0;
      end
    endcase
    end
 end
 
endmodule
