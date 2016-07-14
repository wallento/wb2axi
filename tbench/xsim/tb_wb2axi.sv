// Copyright 2016 by the authors
//
// Copyright and related rights are licensed under the Solderpad
// Hardware License, Version 0.51 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a
// copy of the License at http://solderpad.org/licenses/SHL-0.51.
// Unless required by applicable law or agreed to in writing,
// software, hardware and materials distributed under this License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the
// License.
//
// Authors:
//    Stefan Wallentowitz <stefan@wallentowitz.de>

`timescale 1ps/1ps

module tb_wb2axi;

   reg clk;
   reg rst;

   logic        wb_cyc_i;
   logic        wb_stb_i;
   logic        wb_we_i;
   logic [31:0] wb_adr_i;
   logic [31:0] wb_dat_i;
   logic [3:0]  wb_sel_i;
   logic [2:0]  wb_cti_i;
   logic [1:0]  wb_bte_i;
   logic        wb_ack_o;
   logic        wb_rty_o;
   logic        wb_err_o;
   logic [31:0] wb_dat_o;   

   logic [3:0]  s_axi_awid; 
   logic [31:0] s_axi_awaddr;   
   logic [7:0]  s_axi_awlen;
   logic [2:0]  s_axi_awsize;
   logic [1:0]  s_axi_awburst;
   logic        s_axi_awvalid;
   logic        s_axi_awready;
   logic [31:0] s_axi_wdata;
   logic [3:0]  s_axi_wstrb;
   logic        s_axi_wlast;
   logic        s_axi_wvalid;
   logic        s_axi_wready;
   logic [3:0]  s_axi_bid;
   logic [1:0]  s_axi_bresp;
   logic        s_axi_bvalid;
   logic        s_axi_bready;
   logic [3:0]  s_axi_arid;
   logic [31:0] s_axi_araddr;
   logic [7:0]  s_axi_arlen;
   logic [2:0]  s_axi_arsize;
   logic [1:0]  s_axi_arburst;
   logic        s_axi_arvalid;
   logic        s_axi_arready;
   logic [3:0]  s_axi_rid;
   logic [31:0] s_axi_rdata;
   logic [1:0]  s_axi_rresp;
   logic        s_axi_rlast;
   logic        s_axi_rvalid;
   logic        s_axi_rready;

   initial begin
      rst = 1;
      clk = 1;
      #20000;
      rst = 0;
   end

   always
     #5000 clk = ~clk;

   wb2axi
     #(.AXI_ID_WIDTH(4))
   dut(.*,
       .m_axi_awid    (s_axi_awid),
       .m_axi_awaddr  (s_axi_awaddr),
       .m_axi_awlen   (s_axi_awlen),
       .m_axi_awsize  (s_axi_awsize),
       .m_axi_awburst (s_axi_awburst),
       .m_axi_awcache (),
       .m_axi_awprot  (),
       .m_axi_awqos   (),
       .m_axi_awvalid (s_axi_awvalid),
       .m_axi_awready (s_axi_awready),

       .m_axi_wdata   (s_axi_wdata),
       .m_axi_wstrb   (s_axi_wstrb),
       .m_axi_wlast   (s_axi_wlast),
       .m_axi_wvalid  (s_axi_wvalid),
       .m_axi_wready  (s_axi_wready),

       .m_axi_bid     (s_axi_bid),
       .m_axi_bresp   (s_axi_bresp),
       .m_axi_bvalid  (s_axi_bvalid),
       .m_axi_bready  (s_axi_bready),
       
       .m_axi_arid    (s_axi_arid),
       .m_axi_araddr  (s_axi_araddr),
       .m_axi_arlen   (s_axi_arlen),
       .m_axi_arsize  (s_axi_arsize),
       .m_axi_arburst (s_axi_arburst),
       .m_axi_arcache (),
       .m_axi_arprot  (),
       .m_axi_arqos   (),
       .m_axi_arvalid (s_axi_arvalid),
       .m_axi_arready (s_axi_arready),

       .m_axi_rdata   (s_axi_rdata),
       .m_axi_rid     (s_axi_rid),
       .m_axi_rresp   (s_axi_rresp),
       .m_axi_rlast   (s_axi_rlast),
       .m_axi_rvalid  (s_axi_rvalid),
       .m_axi_rready  (s_axi_rready)
       );

   blk_mem_gen_0
     mem(.*,
         .s_aclk    (clk),
         .s_aresetn (!rst));
   
   task wb_write(input [31:0] addr,
                 input [31:0] data,
                 input [3:0]  strobe);
      @(negedge clk);

      wb_stb_i = 1;
      wb_cyc_i = 1;
      wb_we_i = 1;
      
      wb_adr_i = addr;
      wb_dat_i = data;
      wb_sel_i = strobe;
      wb_cti_i = 0;
      wb_bte_i = 0;
      
      @(posedge wb_ack_o);

      @(posedge clk);
      
      wb_stb_i = 0;
      wb_cyc_i = 0;        
   endtask // wb_write

   task wb_read(input [31:0] addr);
      @(negedge clk);

      wb_stb_i = 1;
      wb_cyc_i = 1;
      wb_we_i = 0;
      
      wb_adr_i = addr;
      wb_cti_i = 0;
      wb_bte_i = 0;
      
      @(posedge wb_ack_o);

      @(posedge clk);
      
      wb_stb_i = 0;
      wb_cyc_i = 0;        
   endtask // wb_write   
   
   initial begin
      wb_write(32'h0, 32'hdeadbeef, 4'hf);
      wb_read(32'h0);
      wb_write(32'h0, 32'h00000400, 4'h2);      
      wb_read(32'h0);
      wb_write(32'h1, 32'h0000be00, 4'h2);      
      wb_read(32'h0);
   end
   
endmodule // tb_wb2axi
