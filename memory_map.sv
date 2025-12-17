package memory_map;

  typedef enum logic [1:0] {
    PermReadOnly,
    PermReadWrite,
    PermWriteOnly,
    PermLocked
  } permission_t;

  // Packed struct first field defined is the MSB
  typedef struct packed {
    logic [31:0] sig_gen_period;
    logic led_active;
    logic [6:0] _padding;  // 7 bits padding
    logic [7:0] io_pin_mode;
    logic [7:0] sys_version;
    logic [4:0][7:0] sys_id;
  } fpga_settings_t;

  localparam int StructBytes = (32 + 8 * 8) / 8;

  typedef union packed {
    fpga_settings_t fields;
    logic [StructBytes-1:0][7:0] bytes;
  } settings_union_t;

  localparam fpga_settings_t DefaultSettings = {
    32'd12000,  // sig_gen_period
    1'b0,  // led_active
    7'b0,  //_padding
    8'h00,  // io_pin_mode
    8'h01,  // version 1
    "S",
    "U",
    "G",
    "R",
    "A"
  };

  localparam logic [7:0] AddrReadOnly = 8'h05;  // 0x00 - 0x05 is PermReadOnly

  localparam logic [7:0] AddrSysId0 = 8'h00;
  // localparam logic [7:0] AddrSysId1 = 8'h01;
  // localparam logic [7:0] AddrSysId2 = 8'h02;
  // localparam logic [7:0] AddrSysId3 = 8'h03;
  // localparam logic [7:0] AddrSysId4 = 8'h04;
  // localparam logic [7:0] AddrSysVersion = 8'h05;
  //
  localparam logic [7:0] AddrLedCtrl = 8'h06;
  localparam logic [7:0] AddrIoPinMode = 8'h07;
  //
  // localparam logic [7:0] AddrSigGenPeriod0 = 8'h08;
  // localparam logic [7:0] AddrSigGenPeriod1 = 8'h09;
  // localparam logic [7:0] AddrSigGenPeriod2 = 8'h10;
  // localparam logic [7:0] AddrSigGenPeriod3 = 8'h11;
endpackage


