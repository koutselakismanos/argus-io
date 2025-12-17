import memory_map::*;

module settings_controller (
    input logic clk,
    input logic rst,

    input logic write_enable,
    input logic [7:0] target_addr,
    input logic [7:0] write_data,
    output logic [7:0] read_data,
    output memory_map::fpga_settings_t current_settings
);
  memory_map::permission_t access_permission;
  memory_map::settings_union_t local_storage;


  always_comb begin
    if (target_addr >= StructBytes) begin
      access_permission = PermLocked;
    end else if (target_addr <= AddrReadOnly) begin
      access_permission = PermReadOnly;
    end else begin
      access_permission = PermReadWrite;
    end
  end

  // --- WRITE LOGIC ---
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      local_storage <= DefaultSettings;
    end else if (write_enable) begin
      if (access_permission == PermReadWrite) begin
        local_storage.bytes[target_addr] <= write_data;
      end
    end
  end

  // --- READ LOGIC ---
  always_comb begin
    read_data = 8'h00;
    if (access_permission != PermLocked) begin
      read_data = local_storage.bytes[target_addr];
    end
  end

  assign current_settings = local_storage.fields;
endmodule
