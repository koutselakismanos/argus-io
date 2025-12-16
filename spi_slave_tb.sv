`timescale 1ns / 1ps

module spi_slave_tb;

  // Signals
  logic clk = 0;
  logic rst = 0;
  logic sclk = 0;
  logic mosi = 0;
  logic cs_n = 1;  // Start inactive (High)
  logic miso;
  logic [7:0] rx_byte;
  logic rx_valid;

  // Instantiate your module
  spi_slave dut (
      .clk(clk),
      .rst(rst),
      .sclk(sclk),
      .mosi(mosi),
      .cs_n(cs_n),
      .miso(miso),
      .tx_byte(8'h42),  // We want the FPGA to send back 0x42
      .rx_byte(rx_byte),
      .rx_valid(rx_valid)
  );

  // System Clock Generation (100MHz)
  always #5 clk = ~clk;

  task static send_byte(input logic [7:0] data);
    integer i;
    begin
      cs_n = 0;  // Select Slave
      #100;

      for (i = 7; i >= 0; i = i - 1) begin
        mosi = data[i];
        #50 sclk = 1;
        #100 sclk = 0;
        #50;
      end

      #100 cs_n = 1;
      #100;
    end
  endtask

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, spi_slave_tb);

    // Reset Sequence
    rst = 1;
    #20 rst = 0;

    // Send 0xA5 (10100101) to FPGA
    send_byte(8'hA5);

    // Send 0x01 to FPGA
    send_byte(8'h01);

    $finish;
  end

endmodule
