transcript on
if {[file exists work]} { vdel -all -lib work }
vlib work
vmap work work

vlog -sv rtl/core/rv32i_pkg.sv
vlog -sv rtl/core/rv32i_alu.sv
vlog -sv rtl/core/rv32i_regfile.sv
vlog -sv rtl/core/rv32i_core.sv
vlog -sv assertions/rv32i_sva.sv
vlog -sv tb/uvm/rv32i_core_if.sv
vlog -sv tb/uvm/rv32i_uvm_pkg.sv
vlog -sv tb/uvm/tb_top.sv

vsim -c tb_top +UVM_TESTNAME=rv32i_smoke_test -do "run -all; quit -f"
