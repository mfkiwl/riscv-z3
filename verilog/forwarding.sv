import wires::*;

module forwarding
(
  input forwarding_dec_in_type forwarding_dec_in,
  input forwarding_exe_in_type forwarding_exe_in,
  output forwarding_out_type forwarding_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res1 = 0;
  logic [31:0] res2 = 0;

  always_comb begin
    res1 = 0;
    res2 = 0;
    if (forwarding_dec_in.register_rden1 == 1) begin
      res1 = forwarding_dec_in.register_rdata1;
      if (forwarding_exe_in.execute_wren == 1 & forwarding_dec_in.register_raddr1 == forwarding_exe_in.execute_waddr) begin
        res1 = forwarding_exe_in.execute_wdata;
      end
    end
    if (forwarding_dec_in.register_rden2 == 1) begin
      res2 = forwarding_dec_in.register_rdata2;
      if (forwarding_exe_in.execute_wren == 1 & forwarding_dec_in.register_raddr2 == forwarding_exe_in.execute_waddr) begin
        res2 = forwarding_exe_in.execute_wdata;
      end
    end
    forwarding_out.data1 = res1;
    forwarding_out.data2 = res2;
  end

endmodule
