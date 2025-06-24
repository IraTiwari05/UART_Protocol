`timescale 1ns / 1ps


module baud_generator #(parameter CLK_FREQ=50_000_000,
parameter BAUD_RATE=9600)(
 input wire clk, input wire rst,
 output wire baud_tick
    );
 
parameter BAUD_DIV=CLK_FREQ/BAUD_RATE;
   
reg [31:0] counter;
reg baud_tick_reg = 0;

always @(posedge clk or posedge rst)begin
 if(rst)begin
  counter<=0;
  baud_tick_reg <=0;
 end
 else begin
  if(counter==BAUD_DIV-1)begin
       baud_tick_reg <=1;
       counter<=0;
  end
  else begin
       counter<=counter+1;
       baud_tick_reg <=0;
  end
 end
end
assign baud_tick = baud_tick_reg;
endmodule
