`include "vscale_hasti_constants.vh"
`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module core_top
(
  input           clk,
  input           rst_n,
  //instruction inteface
  output          i_req_val,
  output  [31:0]  i_req_addr,
  input           i_req_ack,
  input   [31:0]  i_ack_rdata,
  //data interface
  output          d_req_val,
  output  [31:0]  d_req_addr,
  output  [2:0]   d_req_cop,
  output  [31:0]  d_req_wdata,
  output  [2:0]   d_req_size,
  input           d_req_ack,
  input   [31:0]  d_ack_rdata
);

  wire                       imem_wait;
  wire [`XPR_LEN-1:0]        imem_addr;
  wire [`XPR_LEN-1:0]        imem_rdata;
  wire                       imem_badmem_e;
  wire                       dmem_wait;
  wire                       dmem_en;
  wire                       dmem_wen;
  wire [`MEM_TYPE_WIDTH-1:0] dmem_size;
  wire [`XPR_LEN-1:0]        dmem_addr;
  wire [`XPR_LEN-1:0]        dmem_wdata_delayed;
  wire [`XPR_LEN-1:0]        dmem_rdata;
  wire                       dmem_badmem_e;

  vscale_pipeline vscale
  (
    .clk                  (clk),
    .reset                (~rst_n),
    .imem_wait            (imem_wait),
    .imem_addr            (imem_addr),
    .imem_rdata           (imem_rdata),
    .imem_badmem_e        (imem_badmem_e),
    .dmem_wait            (dmem_wait),
    .dmem_en              (dmem_en),
    .dmem_wen             (dmem_wen),
    .dmem_size            (dmem_size),
    .dmem_addr            (dmem_addr),
    .dmem_wdata_delayed   (dmem_wdata_delayed),
    .dmem_rdata           (dmem_rdata),
    .dmem_badmem_e        (dmem_badmem_e),
    .htif_reset           (~rst_n),
    .htif_pcr_req_valid   (1'b0),
    .htif_pcr_req_ready   (),
    .htif_pcr_req_rw      (),
    .htif_pcr_req_addr    (),
    .htif_pcr_req_data    (),
    .htif_pcr_resp_valid  (),
    .htif_pcr_resp_ready  (1'b0),
    .htif_pcr_resp_data   ()
  );

  assign i_req_val      = 1'b1;
  assign i_req_addr     = imem_addr;
  assign imem_wait      = ~i_req_ack;
  assign imem_rdata     = i_ack_rdata;
  assign imem_badmem_e  = 1'b0;

  assign d_req_val      = dmem_en;
  assign d_req_addr     = dmem_addr;
  assign d_req_cop      = (dmem_wen) ? 3'b001 : 3'b000;
  assign d_req_wdata    = dmem_wdata_delayed;
  assign d_req_size     = dmem_size;
  assign dmem_wait      = ~d_req_ack;
  assign dmem_rdata     = d_ack_rdata;
  assign dmem_badmem_e  = 1'b0;

endmodule