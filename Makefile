PROJECT = argus
TESTBENCH = testbench.v
SIM_BIN = testbench.vvp
WAVEFORM = waveform.vcd

SRCS = top.v pll.v

PACKAGE = sg48
DEVICE = up5k
PCF = icesugar.pcf
FLASH_PATH = /run/media/$(USER)/iCELink


# Synthesize
SYNTH_CMD = yosys -p "synth_ice40 -top top -json $(PROJECT).json" -sv $(SRCS)
# Place and route
PNR_CMD = nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(PROJECT).json --pcf $(PCF) --asc $(PROJECT).asc
# Package
PACK_CMD = icepack $(PROJECT).asc $(PROJECT).bin


all: $(PROJECT).bin

$(PROJECT).bin: $(PROJECT).asc
	$(PACK_CMD)

$(PROJECT).asc: $(PROJECT).json $(PCF)
	$(PNR_CMD)

$(PROJECT).json: $(SRCS)
	$(SYNTH_CMD)

clean: clean_sim
	rm -f $(PROJECT).json $(PROJECT).asc $(PROJECT).bin

flash: $(PROJECT).bin
	@echo "Programming..."
	@if [ -d "$(FLASH_PATH)" ]; then \
		cp $(PROJECT).bin "$(FLASH_PATH)/"; \
		sync; \
		echo "Done."; \
	else \
		echo "iCESugar not found."; \
		exit 1; \
	fi

simulate:
	@echo "### Compiling for Simulation ###"
	iverilog -D SIMULATION -o $(SIM_BIN) $(TESTBENCH) lcd_driver.v
	
	@echo "### Running Simulation ###"
	vvp $(SIM_BIN)
	
	@echo "### Opening Waveform ###"
	gtkwave $(WAVEFORM)

clean_sim:
	rm -f $(SIM_BIN) $(WAVEFORM) sim_output
