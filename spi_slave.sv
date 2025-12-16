module spi_slave (
    input logic clk,
    input logic rst,

    input  logic sclk,
    input  logic cs_n,  // active low
    input  logic mosi,
    output logic miso,

    input logic [7:0] tx_byte,
    output logic [7:0] rx_byte,
    output logic rx_valid
);

  logic [1:0] sclk_sync = 0;
  logic [1:0] cs_n_sync = 0;
  logic mosi_sync = 0;

  always_ff @(posedge clk) begin
    sclk_sync <= {sclk_sync[0], sclk};
    cs_n_sync <= {cs_n_sync[0], cs_n};
    mosi_sync <= mosi;
  end

  assign sclk_rising = (sclk_sync == 2'b01);
  assign sclk_falling = (sclk_sync == 2'b10);
  assign cs_active = ~cs_n_sync[1];

  logic [2:0] bit_cnt;
  logic [7:0] rx_shift_reg;
  logic [7:0] tx_shift_reg;

  always_ff @(posedge clk) begin
    if (rst) begin
      rx_valid <= 0;
      miso <= 0;
      bit_cnt <= 0;
      rx_byte <= 0;
      rx_shift_reg <= 0;
      tx_shift_reg <= 0;
    end else if (cs_active) begin
      if (sclk_rising) begin
        rx_shift_reg <= {rx_shift_reg[6:0], mosi_sync};
        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 3'd7) begin
          rx_valid <= 1;
          rx_byte <= {rx_shift_reg[6:0], mosi_sync};

          tx_shift_reg <= tx_byte;
        end else begin
          rx_valid <= 0;
        end
      end else begin
        rx_valid <= 0;
      end

      if (sclk_falling) begin
        miso <= tx_shift_reg[7];
        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
      end

    end else begin
      bit_cnt <= 0;
      rx_valid <= 0;
      tx_shift_reg <= tx_byte;
      miso <= tx_byte[7];
    end
  end

endmodule
