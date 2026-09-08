# RV32I RTL-to-GDSII

A complete RV32I RISC-V processor project covering RTL design, UVM-based verification, synthesis, timing analysis, physical design, signoff, and GDSII generation using the Sky130 PDK.

## Project status

**Phase 0 — Repository and architecture scaffold**

The implementation will be developed incrementally. The first hardware target is a clean RV32I core with a 5-stage pipeline, followed by constrained-random UVM verification and the ASIC flow.

## Planned flow

```text
RV32I ISA
   ↓
RTL architecture
   ↓
5-stage pipeline
   ↓
Directed + UVM verification
   ↓
Assertions + functional coverage
   ↓
RISC-V architectural tests
   ↓
Synthesis + STA
   ↓
Sky130 floorplan / placement / CTS / routing
   ↓
DRC / LVS / final STA
   ↓
GDSII
```

## Repository structure

- `rtl/` — synthesizable RTL
- `tb/uvm/` — UVM testbench
- `assertions/` — SystemVerilog assertions
- `tests/` — directed and regression tests
- `riscv_tests/` — architectural/ISA tests
- `sim/` — simulator entry points and file lists
- `scripts/` — reproducible simulation, lint, synthesis, and flow scripts
- `constraints/` — SDC timing constraints
- `openlane/` — Sky130/OpenLane configuration
- `pnr/` — physical-design inputs and run notes
- `reports/` — selected reproducible results
- `docs/` — architecture, verification, and physical-design documentation

## Verification goals

The verification environment will include:

- UVM agent(s) for instruction/data memory interfaces
- Transaction-level monitors
- Reference model / architectural predictor
- Scoreboard at the architectural commit boundary
- Constrained-random instruction streams
- Functional coverage
- SystemVerilog assertions
- Directed corner-case tests
- RISC-V ISA/compliance-oriented testing

## ASIC goals

The final target is a synthesizable RV32I core taken through the Sky130-based RTL-to-GDSII flow. Final results will record area, utilization, timing (WNS/TNS), clock target, power estimates where available, and DRC/LVS status.

## Development strategy

Work is organized into small milestones so every stage remains verifiable:

1. ISA definition and microarchitecture
2. Single-cycle functional reference
3. 5-stage pipelined RTL
4. Hazard detection and forwarding
5. UVM environment
6. Assertions and coverage
7. ISA-level regression
8. Synthesis and STA
9. Floorplanning through routing
10. Signoff and GDSII

See `docs/ARCHITECTURE.md`, `docs/VERIFICATION.md`, and `docs/PHYSICAL_DESIGN.md` for the detailed plan.
