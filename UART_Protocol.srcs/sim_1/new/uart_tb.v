`timescale 1ns / 1ps

module uart_tb;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Inputs to UART
    reg tx_start;
    reg [7:0] tx_data;
    reg parity_en = 1; // Enable even parity

    // Outputs from UART
    wire [7:0] rx_data;
    wire rx_done;
    wire parity_error;
    wire tx_busy;
    wire tx;

    // Loopback connection: tx connects to rx
    wire rx;
    assign rx = tx;

    // Instantiate UART Top Module
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

    // Clock generation: 50 MHz (20ns period)
    always #10 clk = ~clk;

    // Monitor key signals
    initial begin
        $monitor("Time = %t | tx = %b | rx = %b | tx_busy = %b | rx_done = %b | rx_data = %h | parity_error = %b",
                 $time, tx, rx, tx_busy, rx_done, rx_data, parity_error);
    end

    // Main test sequence
    initial begin
        $display("==== UART Testbench Started ====");

        // Initial values
        tx_start = 0;
        tx_data = 8'h00;

        // Hold rst
        #40;
        rst = 0;
        #40;

        // Transmit byte 'A' = 0x41
        tx_data = 8'h41;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for reception to complete
        wait (rx_done == 1);
        #40;

        // Display results
        $display("TX Data     : 0x%0h", tx_data);
        $display("RX Data     : 0x%0h", rx_data);
        $display("Parity Error: %b", parity_error);

        if (rx_data == tx_data && !parity_error)
            $display("✅ Test Passed: Data matched and parity OK");
        else if (rx_data != tx_data)
            $display("❌ Test Failed: Data mismatch");
        else if (parity_error)
            $display("⚠️  Test Failed: Parity error");

        $display("==== UART Testbench Finished ====");
        $finish;
    end

    // Failsafe: End simulation after 5ms if anything goes wrong
    initial begin
    #5_000_000; // 5ms
    $display("❌ Timeout: UART Testbench didn't finish in time");
    $finish;
end

endmodule
