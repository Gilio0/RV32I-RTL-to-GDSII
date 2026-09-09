# RV32I RTL-to-GDSII

A complete RV32I RISC-V processor project progressing from RTL design through verification, synthesis, physical design, signoff, and GDSII generation.

## Current status

### Phase 1 — RV32I single-cycle baseline completed

The project now starts from a previously implemented RV32I single-cycle processor baseline. The baseline includes the core RTL blocks and their existing directed testbenches.

The initial implementation was provided by **Bitspinner** and is being used as the functional starting point for the next stage of the project.

### Phase 2 — 5-stage pipeline migration in progress

The next step is to transform the working single-cycle datapath into a classic:

```text
IF → ID → EX → MEM → WB
```

The existing RTL and testbenches are intentionally preserved unchanged while the pipeline architecture is developed.

## Single-cycle baseline

The baseline contains:

- Program counter
- Instruction memory
- RV32I decoder
- Register file
- Immediate/sign extension logic
- ALU
- Branch unit
- Data memory
- Single-cycle control and write-back paths

The baseline instruction reference is stored in `docs/reference/rv32i_instruction_table.pdf`.

## Migration to pipeline

The single-cycle datapath will be partitioned using four pipeline registers:

```text
IF/ID → ID/EX → EX/MEM → MEM/WB
```

Target stage responsibilities:

- **IF:** PC and instruction fetch
- **ID:** decode, register-file read, immediate generation
- **EX:** ALU, branch comparison and target calculation
- **MEM:** data-memory access
- **WB:** register write-back

The pipeline phase will add the required control/data propagation, forwarding, hazard detection, stalls, and flushes without modifying the original single-cycle RTL/testbench baseline.

## Documentation and references

- `docs/images/` — architecture diagrams
- `docs/reference/` — ISA reference material
- `docs/PIPELINE_MIGRATION.md` — migration plan and current work
- `docs/ARCHITECTURE.md` — processor architecture
- `docs/VERIFICATION.md` — verification plan

## Planned flow

```text
RV32I single-cycle baseline
        ↓
5-stage pipelined RTL
        ↓
Forwarding + hazard detection
        ↓
UVM verification
        ↓
Assertions + functional coverage
        ↓
ISA-level regression
        ↓
Synthesis + STA
        ↓
Sky130 floorplan / placement / CTS / routing
        ↓
DRC / LVS / final STA
        ↓
GDSII
```
