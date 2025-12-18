`timescale 1ns / 1ps

module pwm_generator_tb;

  // 1. Declare signals to connect to the module
  logic clk;
  logic rst;
  logic [31:0] period_ticks;
  logic [31:0] duty_cycle_ticks;
  logic pulse;

  // 2. Instantiate your Device Under Test (DUT)
  pwm_generator dut (
      .clk(clk),
      .rst(rst),
      .period_ticks(period_ticks),
      .duty_cycle_ticks(duty_cycle_ticks),
      .pulse(pulse)
  );

  // 3. Clock Generation
  // 100 MHz = 10ns period. We toggle every 5ns.
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, pwm_generator_tb);


    clk = 0;
    forever #5 clk = ~clk;
  end

  // 4. Test Stimulus
  initial begin
    // --- Initialize Inputs ---
    rst              = 1;  // Start in Reset
    period_ticks     = 0;
    duty_cycle_ticks = 0;

    // Wait 100ns and release reset
    #100;
    rst = 0;
    #20;  // Wait a tiny bit after reset

    // -------------------------------------------------------
    // TEST CASE 1: 50% Duty Cycle
    // We use small numbers (100 ticks) so the simulation waveform fits on screen.
    // -------------------------------------------------------
    $display("Starting Test 1: 50%% Duty Cycle");
    period_ticks     = 100;  // Total period
    duty_cycle_ticks = 50;  // High for 50 ticks

    // Wait for 2000ns (200 clock cycles) to watch it run twice
    #2000;


    // -------------------------------------------------------
    // TEST CASE 2: 25% Duty Cycle
    // -------------------------------------------------------
    $display("Starting Test 2: 25%% Duty Cycle");
    period_ticks     = 100;  // Keep period same
    duty_cycle_ticks = 25;  // High for 25 ticks (shorter pulse)

    #2000;


    // -------------------------------------------------------
    // TEST CASE 3: 75% Duty Cycle
    // -------------------------------------------------------
    $display("Starting Test 3: 75%% Duty Cycle");
    period_ticks     = 100;  // Keep period same
    duty_cycle_ticks = 75;  // High for 75 ticks (longer pulse)

    #2000;

    // -------------------------------------------------------
    // End Simulation
    // -------------------------------------------------------
    $display("Test Complete");
    $finish;
  end

endmodule
