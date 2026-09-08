# Physical Design Plan

## Target

Sky130-based ASIC implementation using the OpenLane/LibreLane ecosystem.

## Flow

```text
RTL
 ↓
Synthesis
 ↓
Floorplan
 ↓
Placement
 ↓
CTS
 ↓
Routing
 ↓
Extraction
 ↓
STA / DRC / LVS
 ↓
GDSII
```

## Constraints

The clock period will be selected after establishing a clean baseline synthesis result. The project will avoid claiming a frequency target that has not been verified by STA.

## Signoff evidence

The repository will retain selected reports and summarized metrics for:

- cell area
- utilization
- clock period/frequency target
- WNS/TNS
- setup/hold status
- routing completion
- DRC
- LVS
- final GDSII generation

## Reproducibility

Every physical-design milestone should be executable from a documented configuration and script. Tool-version assumptions and PDK setup instructions belong in `docs/`.

## Important integration decision

The first signoff target is the **processor core with external instruction/data memory interfaces**. Large SRAM macros will not be added until the CPU and ASIC flow are stable. This avoids hiding processor behavior behind memory-macro integration problems.
