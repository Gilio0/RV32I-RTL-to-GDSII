package rv32i_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class rv32i_mem_txn extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit        we;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;
    bit      [31:0] rdata;

    `uvm_object_utils_begin(rv32i_mem_txn)
      `uvm_field_int(addr,  UVM_ALL_ON)
      `uvm_field_int(we,    UVM_ALL_ON)
      `uvm_field_int(wdata, UVM_ALL_ON)
      `uvm_field_int(wstrb, UVM_ALL_ON)
      `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "rv32i_mem_txn");
      super.new(name);
    endfunction
  endclass

  class rv32i_smoke_test extends uvm_test;
    `uvm_component_utils(rv32i_smoke_test)

    function new(string name = "rv32i_smoke_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), "UVM smoke-test scaffold created; environment will be expanded incrementally.", UVM_LOW)
    endfunction
  endclass
endpackage
