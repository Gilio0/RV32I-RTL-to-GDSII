# Architecture

## Scope

The first implementation targets the **RV32I base integer ISA** with 32-bit registers and a 32-bit program counter. Privileged architecture, caches, MMU, interrupts, and optional extensions are intentionally out of scope for the first milestone.

## Microarchitecture

Target implementation: classic 5-stage pipeline.

```text
IF → ID → EX → MEM → WB
```

### Pipeline responsibilities

- **IF:** program counter, instruction fetch, next-PC selection
- **ID:** instruction decode, register-file read, immediate generation
- **EX:** ALU operations, branch comparison/target calculation
- **MEM:** load/store interface
- **WB:** architectural register write-back

## Core interfaces

The core will use explicit instruction and data-memory interfaces rather than embedding large memories in the processor. This keeps the CPU reusable and makes the UVM environment and ASIC integration cleaner.

### Instruction interface

- `imem_valid`
- `imem_addr`
- `imem_rdata`

### Data interface

- `dmem_valid`
- `dmem_we`
- `dmem_addr`
- `dmem_wdata`
- `dmem_wstrb`
- `dmem_rdata`

The exact handshake will be frozen before RTL implementation and documented in the interface package.

## RV32I instruction groups

The decoder will cover:

- LUI / AUIPC
- JAL / JALR
- conditional branches
- loads
- stores
- immediate ALU operations
- register-register ALU operations

## Design invariants

- `x0` always reads as zero.
- Writes to `x0` are ignored.
- Instructions advance only when their pipeline control permits it.
- Taken control transfers flush younger instructions.
- Load-use dependencies are stalled or otherwise resolved according to the hazard unit design.

## Future extensions

After the base core is stable, possible extensions include Zicsr, machine-mode support, interrupts, simple caches, and additional ISA extensions. These are not part of the initial signoff target.
