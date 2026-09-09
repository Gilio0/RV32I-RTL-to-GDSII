# Architecture

## Current baseline

The project uses an existing **RV32I single-cycle processor** as the functional baseline. Its RTL blocks and existing directed testbenches are retained unchanged while the microarchitecture is migrated to a pipeline.

The baseline is based on an implementation provided by **Bitspinner**.

## Single-cycle datapath

The baseline datapath contains:

```text
PC
│
├── Instruction Memory
├── Decoder
├── Register File
├── Sign/Immediate Extension
├── ALU
├── Branch Unit
├── Data Memory
└── Write-back / next-PC paths
```

The corresponding architecture diagram is stored under `docs/images/`.

## Pipeline target

The single-cycle datapath will be reorganized into:

```text
IF → ID → EX → MEM → WB
```

with pipeline registers:

```text
IF/ID → ID/EX → EX/MEM → MEM/WB
```

### IF
- PC
- instruction fetch
- PC + 4
- next-PC selection

### ID
- instruction decode
- register-file read
- immediate generation
- control generation

### EX
- ALU operation
- ALU operand selection
- branch comparison
- branch/jump target calculation

### MEM
- load/store access
- memory control

### WB
- ALU/load/PC+4 result selection
- architectural register write

## Pipeline hazards

The pipelined implementation will address:

- RAW data hazards
- forwarding from later stages
- load-use stalls
- control hazards
- branch/jump flushing

## RTL baseline preservation

No existing RTL or testbench files are changed as part of documenting the baseline and preparing the pipeline migration. New pipeline-specific RTL will be developed separately so the original implementation remains available as a reference.
