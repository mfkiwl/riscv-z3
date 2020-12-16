import constants::*;
import wires::*;

module pmp
(
  input logic rst,
  input logic clk,
  input pmp_in_type pmp_in,
  output pmp_out_type pmp_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0:0] exc;
  logic [31:0] etval;
  logic [3:0] ecause;
  logic [31:0] lowaddr;
  logic [31:0] highaddr;
  logic [33:0] memaddr;
  logic [31:0] mask;
  logic [4:0] mask_inc;

  integer i;
  integer j;

  generate

    if (pmp_enable==1) begin

      always_comb begin

        exc = 0;
        etval = 0;
        ecause = 0;
        lowaddr = 0;
        highaddr = 0;
        memaddr = 0;
        mask = 0;
        mask_inc = 0;

        if (pmp_in.mem_valid == 1) begin
          memaddr = {2'b0,pmp_in.mem_addr};
          for (i=0; i<pmp_regions; i=i+1) begin
						if (pmp_in.pmpcfg[i].A == 1) begin
              if (i == 0) begin
                lowaddr = 0;
              end else begin
                lowaddr = pmp_in.pmpaddr[i-1];
              end
              highaddr = pmp_in.pmpaddr[i];
              if (memaddr[33:2] < highaddr && memaddr[33:2] > lowaddr) begin
                if (pmp_in.pmpcfg[i].L == 1 || pmp_in.priv_mode == u_mode) begin
                  if (pmp_in.pmpcfg[i].X == 0 && pmp_in.mem_instr == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_instr_access_fault;
                  end else if (pmp_in.pmpcfg[i].R == 0 && (|pmp_in.mem_wstrb) == 0) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_load_access_fault;
                  end else if (pmp_in.pmpcfg[i].W == 0 && (|pmp_in.mem_wstrb) == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_store_access_fault;
                  end
                end
                break;
              end
            end else if (pmp_in.pmpcfg[i].A == 2) begin
              if ((~|(memaddr[33:2] ^ pmp_in.pmpaddr[i])) == 1) begin
                if (pmp_in.pmpcfg[i].L == 1 || pmp_in.priv_mode == u_mode) begin
                  if (pmp_in.pmpcfg[i].X == 0 && pmp_in.mem_instr == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_instr_access_fault;
                  end else if (pmp_in.pmpcfg[i].R == 0 && (|pmp_in.mem_wstrb) == 0) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_load_access_fault;
                  end else if (pmp_in.pmpcfg[i].W == 0 && (|pmp_in.mem_wstrb) == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_store_access_fault;
                  end
                end
                break;
              end
            end else if (pmp_in.pmpcfg[i].A == 3) begin
              mask = 32'hFFFFFFFF;
              mask_inc = 1;
              for (j=0; j<32; j++) begin
                if (pmp_in.pmpaddr[i][j] == 0) begin
                  break;
                end else if (pmp_in.pmpaddr[i][j] == 1) begin
                  mask_inc = mask_inc + 1;
                end
              end
              mask = mask << mask_inc;
              lowaddr = pmp_in.pmpaddr[i] & mask;
              if ((~|((memaddr[33:2] & mask) ^ lowaddr)) == 1) begin
                if (pmp_in.pmpcfg[i].L == 1 || pmp_in.priv_mode == u_mode) begin
                  if (pmp_in.pmpcfg[i].X == 0 && pmp_in.mem_instr == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_instr_access_fault;
                  end else if (pmp_in.pmpcfg[i].R == 0 && (|pmp_in.mem_wstrb) == 0) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_load_access_fault;
                  end else if (pmp_in.pmpcfg[i].W == 0 && (|pmp_in.mem_wstrb) == 1) begin
										exc = 1;
										etval = pmp_in.mem_addr;
										ecause = except_store_access_fault;
                  end
                end
                break;
              end
            end
          end
        end

  			pmp_out.exc = exc;
  			pmp_out.etval = etval;
  			pmp_out.ecause = ecause;

      end

    end else if (pmp_enable==0) begin

  		assign pmp_out.exc = 0;
  		assign pmp_out.etval = 0;
  		assign pmp_out.ecause = 0;

    end

  endgenerate

endmodule
