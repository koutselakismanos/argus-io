PROJECT = argus
# Default module to simulate if none is specified
MOD ?= top

BUILD_DIR = build
SIM_DIR = sim_build

SRCS = memory_map.sv settings_controller.sv top.sv pll.sv spi_slave.sv

PACKAGE = sg48
DEVICE = up5k
PCF = icesugar.pcf
FLASH_PATH = /run/media/$(USER)/iCELink

SYNTH_CMD = yosys -p "read_verilog -sv $(SRCS); synth_ice40 -top top -json $(PROJECT).json"
PNR_CMD = nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(PROJECT).json --pcf $(PCF) --asc $(PROJECT).asc
PACK_CMD = icepack $(PROJECT).asc $(PROJECT).bin

all: $(PROJECT).bin

$(PROJECT).bin: $(PROJECT).asc
	$(PACK_CMD)

$(PROJECT).asc: $(PROJECT).json $(PCF)
	$(PNR_CMD)

$(PROJECT).json: $(SRCS)
	$(SYNTH_CMD)

flash: $(PROJECT).bin
	@echo "Programming..."
	@if [ -d "$(FLASH_PATH)" ]; then \
		cp $(PROJECT).bin "$(FLASH_PATH)/"; \
		sync; \
		echo "Done."; \
	else \
		echo "iCESugar not found at $(FLASH_PATH). Check USB connection."; \
		exit 1; \
	fi

sim:
	@echo "### Setting up Directories ###"
	@mkdir -p $(BUILD_DIR) $(SIM_DIR)

	@echo "### Converting SystemVerilog to Verilog-2005 (sv2v) ###"
	sv2v -D SIMULATION -I. $(SRCS) $(MOD)_tb.sv > $(BUILD_DIR)/converted_sim.v

	# @echo "### Compiling Testbench for: $(MOD) ###"
	# # iverilog -g2012 -D SIMULATION -o $(SIM_DIR)/$(MOD).vvp $(SRCS) $(MOD)_tb.sv
	# iverilog -g2012 -o sim_build/top.vvp build/converted_sim.v
	@echo "### Compiling Testbench for: $(MOD) ###"
	iverilog -g2012 -o $(SIM_DIR)/$(MOD).vvp $(BUILD_DIR)/converted_sim.v

	@echo "### Running Simulation ###"
	vvp -n $(SIM_DIR)/$(MOD).vvp

	@echo "### Opening Waveform ###"
	gtkwave waveform.vcd

# sim:
# 	sv2v -I. memory_map.sv settings_controller.sv top.sv pll.sv spi_slave.sv top_tb.sv > build/converted_sim.v
# 	iverilog -g2012 -o sim_build/top.vvp build/converted_sim.v
# 	vvp sim_build/top.vvp
clean:
	rm -f $(PROJECT).json $(PROJECT).asc $(PROJECT).bin
	rm -rf $(SIM_DIR) waveform.vcd
