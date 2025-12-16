import regs_pkg::*;

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
  logic [7:0] tx_byte;
  logic [7:0] tx_valid;
  logic rx_valid;

  spi_slave _spi_slave (
      .clk(clk_100),
      .rst(1'b0),
      .sclk(sclk),
      .cs_n(cs_n),
      .mosi(mosi),
      .miso(miso),
      .tx_byte(tx_byte),
      .rx_byte(rx_byte),
      .rx_valid(rx_valid)
  );


  logic [27:0] timer = 0;
  always_ff @(posedge clk_100) begin
    timer <= timer + 1;
  end

  assign led_r = timer[27];


  typedef enum {
    WAIT_FOR_ADDRESS,
    DATA_TRANSACTION
  } state_t;

  state_t state = WAIT_FOR_ADDRESS;
  logic [7:0] current_address;
  logic reg_write_enable;

  always_ff @(posedge clk_100) begin
    if (cs_n) begin
      state <= WAIT_FOR_ADDRESS;
      reg_write_enable <= 1'b0;
      current_address <= 0;
    end else if (rx_valid) begin
      case (state)
        WAIT_FOR_ADDRESS: begin
          current_address <= rx_byte;
          state <= DATA_TRANSACTION;
        end
        DATA_TRANSACTION: begin
          reg_write_enable <= 1'b1;
          current_address  <= current_address + 1;
        end
        default: begin
          state <= WAIT_FOR_ADDRESS;
        end
      endcase
    end else begin
      reg_write_enable <= 1'b0;
    end
  end

  localparam logic [7:0] Version = 8'h01;


  always_ff @(posedge clk_100) begin
    if (reg_write_enable) begin
      case (current_address)
        default: ;
      endcase
    end
  end

  always_comb begin


    case (current_address)
      RegSysId0: tx_byte = "A";
      RegSysId1: tx_byte = "R";
      RegSysId2: tx_byte = "G";
      RegSysId3: tx_byte = "U";
      RegSysId4: tx_byte = "S";
      RegSysVersion: tx_byte = Version;
      default: tx_byte = 8'h00;
    endcase
  end

endmodule
