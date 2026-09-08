module rv32i_alu #(
  parameter int XLEN = 32
) (
  input  logic [XLEN-1:0] a,
  input  logic [XLEN-1:0] b,
  input  logic [3:0]      op,
  output logic [XLEN-1:0] y,
  output logic             zero,
  output logic             less_signed,
  output logic             less_unsigned
);
  always_comb begin
    unique case (op)
      4'd0: y = a + b;
      4'd1: y = a - b;
      4'd2: y = a & b;
      4'd3: y = a | b;
      4'd4: y = a ^ b;
      4'd5: y = a << b[4:0];
      4'd6: y = a >> b[4:0];
      4'd7: y = $signed(a) >>> b[4:0];
      4'd8: y = ($signed(a) < $signed(b)) ? {{XLEN-1{1'b0}},1'b1} : '0;
      4'd9: y = (a < b) ? {{XLEN-1{1'b0}},1'b1} : '0;
      default: y = '0;
    endcase
  end

  assign zero          = (y == '0);
  assign less_signed   = ($signed(a) < $signed(b));
  assign less_unsigned = (a < b);
endmodule
