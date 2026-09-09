# Pipeline Migration

## Starting point

The project started from a previously implemented and tested **RV32I single-cycle processor**. The existing implementation includes the core datapath blocks and their directed testbenches.

The single-cycle implementation is credited as the initial baseline provided by **Bitspinner**.

## What has been completed

- Established the existing single-cycle RV32I implementation as the functional baseline.
- Preserved the existing RTL without modification.
- Preserved the existing testbenches without modification.
- Preserved the RV32I instruction reference table.
- Documented the single-cycle architecture and its blocks.
- Prepared the project structure for the transition to a 5-stage pipeline.

## Pipeline objective

Convert the single-cycle datapath into:

```text
IF → ID → EX → MEM → WB
```

using:

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

pipeline registers.

## Required pipeline work

1. Partition the existing datapath into the five stages.
2. Define the signals carried by each pipeline register.
3. Propagate control signals through the pipeline.
4. Add forwarding paths.
5. Add hazard detection and load-use stalls.
6. Add branch/jump flushing.
7. Reuse and extend verification around the pipelined core.
8. Re-run the existing instruction-level tests against the pipelined implementation.
9. Add pipeline-specific tests, assertions, and coverage.

## Baseline rule

The original single-cycle RTL and testbenches are kept unchanged. They serve as the reference implementation and regression baseline during the pipeline migration.
