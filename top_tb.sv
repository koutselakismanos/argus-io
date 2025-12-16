`timescale 1ns / 1ps

// 1. Import Package at the top (Safe for Icarus if compiled first)
import regs_pkg::*;

module top_tb;

  // --- Signals ---
  logic clk;
  logic led_r, led_g, led_b;
  logic sclk, mosi, miso, cs_n;

  // --- Test Variables (MOVED HERE TO FIX ERROR) ---
  // We declare them here so they are available for the whole simulation
  logic [7:0] received_bytes[7];
  logic [7:0] garbage;  // Scratch variable for writes

  // --- Instantiate the Device Under Test (DUT) ---
  top dut (.*);

  // --- Clock Generation (12MHz) ---
  initial clk = 0;
  always #41.666 clk = ~clk;

  // --- SPI Master Task ---
  task static spi_transaction(input logic [7:0] tx_data, output logic [7:0] rx_data);
    integer i;
    begin
      for (i = 7; i >= 0; i = i - 1) begin
        mosi = tx_data[i];
        #200;
        sclk = 1;
        #200;
        rx_data[i] = miso;
        #200;
        sclk = 0;
        #200;
      end
    end
  endtask

  // --- Main Test Sequence ---
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, top_tb);
    $display("### Simulation Started ###");

    // Initialize Signals
    sclk = 0;
    mosi = 0;
    cs_n = 1;

    #2000;


    // --- TEST 1: READ DEVICE ID ---
    $display("--- TEST 1: Reading Device ID ---");

    cs_n = 0;
    #100;

    // 1. Send Address (FPGA calculates address after this)
    spi_transaction(REG_SYS_ID_0, garbage);

    // 2. Read 7 bytes (1 Latency Byte + 5 ID + 1 Version)
    spi_transaction(8'hFF, received_bytes[0]);  // Latency Byte (Garbage/Old Data)
    spi_transaction(8'hFF, received_bytes[1]);  // Real 'A'
    spi_transaction(8'hFF, received_bytes[2]);  // Real 'R'
    spi_transaction(8'hFF, received_bytes[3]);  // Real 'G'
    spi_transaction(8'hFF, received_bytes[4]);  // Real 'U'
    spi_transaction(8'hFF, received_bytes[5]);  // Real 'S'
    spi_transaction(8'hFF, received_bytes[6]);  // Real Version

    cs_n = 1;
    #100;

    // --- VERIFICATION ---
    // Note: We skip received_bytes[0]
    $display("Received Sequence: %c %c %c %c %c %c %h", received_bytes[0], received_bytes[1],
             received_bytes[2], received_bytes[3], received_bytes[4], received_bytes[5],
             received_bytes[6]);

    // Check starting from Index 1
    if (received_bytes[1] == "A" && received_bytes[5] == "S" && received_bytes[6] == 8'h01) begin
      $display(">>> TEST 1 PASSED! <<<");
    end else begin
      $display("!!! TEST 1 FAILED! !!!");
    end

    #2000;

    // --- TEST 2: WRITE TO LED REGISTER ---
    $display("--- TEST 2: Writing 0x01 to REG_LED_CTRL ---");

    cs_n = 0;
    #100;

    // spi_transaction(REG_LED_CTRL, garbage);
    spi_transaction(8'h01, garbage);

    cs_n = 1;
    #100;

    $display(">>> TEST 2 Complete. <<<");

    #5000;
    $display("### Simulation Finished ###");
    $finish;
  end

endmodule
