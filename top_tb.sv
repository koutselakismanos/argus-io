`timescale 1ns / 1ps

module top_tb;

  logic clk;
  logic led_r, led_g, led_b;

  top dut (
      .clk  (clk),
      .led_r(led_r),
      .led_g(led_g),
      .led_b(led_b)
  );

  // 3. Clock Generation
  // The iCESugar has a 12MHz crystal.
  // Period = 1 / 12MHz = 83.33ns
  // Half Period = 41.66ns
  initial clk = 0;
  always #41.666 clk = ~clk;

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, top_tb);

    $display("### Simulation Started ###");

    #1000;

    $display("Forcing timer to near-overflow to see LED blink...");
    dut.timer = 28'h7FF_FFF0;  // Just before bit 27 flips to 1

    #2000;

    $display("Forcing timer to rollover...");
    dut.timer = 28'hFFF_FFF0;  // Just before it rolls over to 0

    #2000;

    $display("### Simulation Finished ###");
    $finish;
  end

endmodule
