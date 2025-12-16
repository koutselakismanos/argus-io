module top (
    input logic clk,

    input  logic sclk,
    input  logic cs_n,
    input  logic mosi,
    output logic miso,

    output logic led_r,
    output logic led_g,
    output logic led_b
);
  logic clk_100;
  logic locked;

  pll _pll (
      .clock_in(clk),
      .clock_out(clk_100),
      .locked(locked)
  );

  logic [7:0] rx_byte;
  logic rx_valid;

  spi_slave _spi_slave (
      .clk(clk_100),
      .rst(1'b0),
      .sclk(sclk),
      .cs_n(cs_n),
      .mosi(mosi),
      .miso(miso),
      .tx_byte(8'h0a),
      .rx_byte(rx_byte),
      .rx_valid(rx_valid)
  );

  typedef enum {
    WAIT_FOR_ADDRESS,
    WAIT_FOR_DATA
  } receive_state_t;

  receive_state_t receive_state = WAIT_FOR_ADDRESS;
  logic [7:0] active_address;

  always_ff @(posedge clk_100) begin
    if (rx_valid) begin
      case (receive_state)
        WAIT_FOR_ADDRESS: begin
          active_address <= rx_byte;
          receive_state  <= WAIT_FOR_DATA;
        end
        WAIT_FOR_DATA: begin
          active_address <= rx_byte;
          receive_state  <= WAIT_FOR_DATA;
        end
        default: begin
          state <= WAIT_FOR_ADDRESS;
        end
      endcase
    end
  end

  logic [27:0] timer = 0;
  always_ff @(posedge clk_100) begin
    timer <= timer + 1;
  end

  assign led_r = timer[27];
endmodule
