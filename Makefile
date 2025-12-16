PROJECT = argus
# Default module to simulate if none is specified
MOD ?= top

BUILD_DIR = build
SIM_DIR = sim_build

SRCS = regs_pkg.sv top.sv pll.sv spi_slave.sv

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
	@echo "### Setting up Simulation Directory ###"
	@mkdir -p $(SIM_DIR)
	
	@echo "### Compiling Testbench for: $(MOD) ###"
	iverilog -g2012 -D SIMULATION -o $(SIM_DIR)/$(MOD).vvp $(SRCS) $(MOD)_tb.sv
	
	@echo "### Running Simulation ###"
	vvp -n $(SIM_DIR)/$(MOD).vvp
	
	@echo "### Opening Waveform ###"
	gtkwave waveform.vcd
clean:
	rm -f $(PROJECT).json $(PROJECT).asc $(PROJECT).bin
	rm -rf $(SIM_DIR) waveform.vcd
