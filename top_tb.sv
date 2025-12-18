`timescale 1ns / 1ps
`include "memory_map.sv"
import memory_map::*;

module top_tb;
  logic clk;
  logic sclk, mosi, miso, cs_n;
  logic led_r, led_g, led_b;

  // Test Variables
  logic [7:0] rx_buffer         [7];
  logic [7:0] temp_rx_byte;
  logic       initial_led_state;
  logic       sys_rst;

  top dut (.*);
  initial clk = 0;
  always #41.666 clk = ~clk;

  task automatic spi_transaction(input logic [7:0] tx_data, output logic [7:0] rx_data);
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

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, top_tb);
    $display("### Simulation Started ###");
    sclk = 0;
    mosi = 0;
    cs_n = 1;
    sys_rst = 1;
    #2000;
    sys_rst = 0;
    #1000;

    // --- TEST 1: READ ID ---
    $display("--- TEST 1: Reading Device ID ---");
    cs_n = 0;
    #500;
    spi_transaction(AddrSysId0, temp_rx_byte);  // Use temp var

    // --- THE PATTERN ---
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[0] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[1] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[2] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[3] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[4] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[5] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[6] = temp_rx_byte;

    cs_n = 1;
    #500;

    if (rx_buffer[1] == "A" && rx_buffer[5] == "S") $display(">>> TEST 1 PASSED <<<");
    else $display("!!! TEST 1 FAILED !!!");

    $display("--- TEST 2: Writing to LED ---");
    initial_led_state = led_b;
    cs_n = 0;
    #500;
    spi_transaction(AddrLedCtrl, temp_rx_byte);
    spi_transaction(8'h01, temp_rx_byte);
    cs_n = 1;
    #500;

    if (led_b != initial_led_state) $display(">>> TEST 2 PASSED <<<");
    else $display("!!! TEST 2 FAILED !!!");

    $display("--- TEST 3: Reading back LED ---");
    cs_n = 0;
    #500;
    spi_transaction(AddrLedCtrl, temp_rx_byte);

    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[0] = temp_rx_byte;
    spi_transaction(8'hFF, temp_rx_byte);
    rx_buffer[1] = temp_rx_byte;

    cs_n = 1;
    #500;

    if (rx_buffer[1] == 8'h01) $display(">>> TEST 3 PASSED <<<");
    else $display("!!! TEST 3 FAILED !!!");

    #20000;
    $finish;
  end
endmodule
