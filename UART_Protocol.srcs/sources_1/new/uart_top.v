`timescale 1ns / 1ps

module uart_top (
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,
    input wire parity_en,
    input wire rx,                      // UART RX line
    output wire tx,                     // UART TX line
    output wire [7:0] rx_data,
    output wire rx_done,
    output wire parity_error,
    output wire tx_busy
);

    wire baud_tick;

    // Baud Generator
    baud_generator #(
        .CLK_FREQ(50000000),    // Match your board clock
        .BAUD_RATE(9600)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .parity_en(parity_en),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .parity_en(parity_en),
        .baud_tick(baud_tick),
        .data_out(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

endmodule
