module pwm_generator (
    input logic clk,
    input logic rst,
    input logic [31:0] period_ticks,
    input logic [31:0] duty_cycle_ticks,
    output logic pulse
);
  logic [31:0] counter;

  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= 32'b0;
    end else if (counter >= period_ticks - 1) begin
      counter <= 32'b0;
    end else begin
      counter <= counter + 1;
    end
  end

  assign pulse = counter < duty_cycle_ticks;
endmodule
