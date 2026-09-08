# Verification Plan

## Verification philosophy

Verification is organized around **architectural behavior**, not internal pipeline implementation details. The scoreboard will compare committed register and memory effects against a reference model.

## UVM environment

Planned components:

```text
uvm_test
  └── rv32i_env
       ├── instruction_agent
       │    ├── sequencer
       │    ├── driver
       │    └── monitor
       ├── data_agent
       │    ├── sequencer
       │    ├── driver
       │    └── monitor
       ├── scoreboard
       ├── coverage
       └── reference_model
```

Depending on the final memory protocol, the instruction side may be modeled as a passive observation interface while the testbench provides a deterministic memory model.

## Test levels

### Level 1 — Unit tests

ALU, decoder, register file, immediate generation, branch logic, and hazard/forwarding blocks.

### Level 2 — Core directed tests

- arithmetic instructions
- logical instructions
- shifts
- comparisons
- branches
- jumps
- loads/stores
- sign extension
- x0 behavior
- dependency hazards
- forwarding paths
- pipeline flushes

### Level 3 — Random instruction testing

Generate legal RV32I instruction streams with constraints for register dependencies, branches, loads/stores, and corner-case immediates.

### Level 4 — Architectural/reference-model comparison

Compare architectural state at instruction retirement/commit against a trusted software reference model.

## Functional coverage

Coverage targets include:

- opcode
- funct3/funct7 combinations
- source/destination register classes
- immediate corner cases
- branch taken/not-taken
- forwarding selections
- load-use stalls
- pipeline flushes
- memory read/write operations
- cross coverage of instruction class and hazard type

## Assertions

Initial assertion set:

- reset establishes a known PC/control state
- x0 remains zero
- no register write occurs to x0
- valid transactions remain stable until accepted
- taken branches cause the required flush
- load-use hazards generate the required stall
- pipeline control signals are mutually consistent

## Exit criteria

A milestone is considered complete only when directed tests pass, assertions are clean, coverage goals are met or justified, and the regression is reproducible from scripts.
