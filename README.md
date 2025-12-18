# Argus - FPGA Accelerated Embedded testing tool and analysis

Project status in development

`Argus` is an open-source, Swiss army knife testing and analysis tool for embedded
systems.

## Core Features

- [ ] **Signal Generator**: Multi-channel PWM and square wave generation for
stimulating and testing circuits.
- [ ] **FPGA-Accelerated Logic Analyzer**: 16+ channels at 100MHz+ with
hardware-assisted protocol decoding.
- [ ] **Universal JTAG/SWD Debug Probe**: High-speed, CMSIS-DAP v2 compliant
debugger for flashing and step-through debugging of ARM, RISC-V, and ESP32 targets.
- [ ] **Interactive Protocol Exerciser**: Actively communicate with I2C, SPI,
and UART devices directly from the software dashboard or a script.
- [ ] **Basic Oscilloscope & Voltmeter**: A 2-channel, 0-20V analog front-end
for visualizing signals and checking power rails.
- [ ] **Wireless Connectivity**: A built-in web server hosted on the ESP32
allows for real-time monitoring and control from a phone or tablet.
- [ ] **Python Scripting API**: Automate complex testing, characterization,
and validation workflows.
- [ ] **Advanced Tools**: Includes specialized FPGA bitstreams for
reverse engineering tasks like JTAG pinout brute-forcing and "Man-in-the-Middle"
protocol sniffing.

## Register Map

Communication between the ESP32-S3 (Master) and the FPGA (Slave) is handled via
a byte-addressable register map over a high-speed SPI bus. This architecture supports
multi-byte burst read/write operations for efficient data transfer.

- **R/W:** Read/Write
- **R:** Read-Only
- **W:** Write-Only
- **RO-SC:** Read-Only, Self-Clearing (reading the register resets its
value to `0`).

---

## **Zone 0: System Control & Status (0x00 - 0x0F)**

*This zone handles basic identification, global control, and interrupt status.*

| Address | Register Name | R/W | Bits | Description |
| :--- | :--- | :--- | :--- | :--- |
| **0x00** | `SysId0` | R | 7:0 | Returns `A`. |
| **0x01** | `SydId1` | R | 7:0 | Returns `R`. |
| **0x02** | `SydId2` | R | 7:0 | Returns `R`. |
| **0x03** | `SydId3` | R | 7:0 | Returns `G`. |
| **0x04** | `SydId4` | R | 7:0 | Returns `U`. |
| **0x05** | `SydId5` | R | 7:0 | Returns `S`. |
| **0x05** | `SysVersion` | R | 7:0 | Returns `0x01` (Version 1). |

*Not complete map...*
