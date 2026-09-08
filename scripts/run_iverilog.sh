#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/iverilog"
mkdir -p "${BUILD_DIR}"

iverilog -g2012 -s tb_rtl_smoke -o "${BUILD_DIR}/simv" \
  "${ROOT_DIR}/rtl/core/rv32i_pkg.sv" \
  "${ROOT_DIR}/rtl/core/rv32i_alu.sv" \
  "${ROOT_DIR}/rtl/core/rv32i_regfile.sv" \
  "${ROOT_DIR}/rtl/core/rv32i_core.sv" \
  "${ROOT_DIR}/tb/tb_rtl_smoke.sv"

vvp "${BUILD_DIR}/simv"
