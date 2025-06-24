`timescale 1ns / 1ps

module uart_tb;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // TX interface
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;

    // RX interface
    wire [7:0] rx_data;
    wire rx_done;
    wire parity_error;

    // Parity control
    reg parity_en = 1;

    // Connect TX to RX (loopback)
    wire tx_line;
    assign tx_line = tx;

    // Outputs
    wire tx;
    wire rx;
    assign rx = tx_line;

    wire baud_tick;

    always #10 clk = ~clk; 

    uart_top uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .parity_en(parity_en),
        .rx(rx),
        .tx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error),
        .tx_busy(tx_busy)
    );

    initial begin
        $display("UART Testbench Started");

        tx_start = 0;
        tx_data = 8'h00;
        #100;
        rst = 0;
        #100;

        tx_data = 8'h41;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait (rx_done);
        #100;

        
        $display("TX Data = 0x%0h", tx_data);
        $display("RX Data = 0x%0h", rx_data);
        if (parity_error)
            $display("Parity Error Detected!");
        else
            $display("Parity OK");

        if (rx_data == tx_data)
            $display("Test Passed: Data Matched");
        else
            $display(" Test Failed: Mismatch");

        $display("UART Testbench Finished");
        $finish;
    end

endmodule
