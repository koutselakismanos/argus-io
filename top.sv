module top (
    input clk,

    output led_r,
    output led_g,
    output led_b
);
  logic clk_100;
  logic locked;

  pll _pll (
      .clock_in(clk),
      .clock_out(clk_100),
      .locked(locked)
  );

  reg [27:0] timer;
  always @(posedge clk_100) begin
    timer <= timer + 1;
  end

  assign led_r = timer[27];
  assign led_g = timer[26];
  assign led_b = timer[25];
endmodule
