interface AXI4 #(
  int unsigned N = 1,
  int unsigned I = 1
)(
  input bit ACLK,
  input bit ARESETn
);
  logic   [I-1:0] ARID    ;
  logic  [32-1:0] ARADDR  ;
  logic   [4-1:0] ARREGION;
  logic   [8-1:0] ARLEN   ;
  logic   [3-1:0] ARSIZE  ;
  logic   [2-1:0] ARBURST ;
  logic           ARLOCK  ;
  logic   [4-1:0] ARCACHE ;
  logic   [3-1:0] ARPROT  ;
  logic   [4-1:0] ARQOS   ;
  logic           ARVALID ;
  logic           ARREADY ;
  logic   [I-1:0] RID     ;
  logic [8*N-1:0] RDATA   ;
  logic   [2-1:0] RRESP   ;
  logic           RLAST   ;
  logic           RVALID  ;
  logic           RREADY  ;
  logic   [I-1:0] AWID    ;
  logic  [32-1:0] AWADDR  ;
  logic   [4-1:0] AWREGION;
  logic   [8-1:0] AWLEN   ;
  logic   [3-1:0] AWSIZE  ;
  logic   [2-1:0] AWBURST ;
  logic           AWLOCK  ;
  logic   [4-1:0] AWCACHE ;
  logic   [3-1:0] AWPROT  ;
  logic   [4-1:0] AWQOS   ;
  logic           AWVALID ;
  logic           AWREADY ;
  logic [8*N-1:0] WDATA   ;
  logic   [N-1:0] WSTRB   ;
  logic           WLAST   ;
  logic           WVALID  ;
  logic           WREADY  ;
  logic   [I-1:0] BID     ;
  logic   [2-1:0] BRESP   ;
  logic           BVALID  ;
  logic           BREADY  ;
  
  clocking cbMON @(posedge ACLK);
    input   ARID    ;
    input   ARADDR  ;
    input   ARREGION;
    input   ARLEN   ;
    input   ARSIZE  ;
    input   ARBURST ;
    input   ARLOCK  ;
    input   ARCACHE ;
    input   ARPROT  ;
    input   ARQOS   ;
    input   ARVALID ;
    input   ARREADY ;
    input   RID     ;
    input   RDATA   ;
    input   RRESP   ;
    input   RLAST   ;
    input   RVALID  ;
    input   RREADY  ;
    input   AWID    ;
    input   AWADDR  ;
    input   AWREGION;
    input   AWLEN   ;
    input   AWSIZE  ;
    input   AWBURST ;
    input   AWLOCK  ;
    input   AWCACHE ;
    input   AWPROT  ;
    input   AWQOS   ;
    input   AWVALID ;
    input   AWREADY ;
    input   WDATA   ;
    input   WSTRB   ;
    input   WLAST   ;
    input   WVALID  ;
    input   WREADY  ;
    input   BID     ;
    input   BRESP   ;
    input   BVALID  ;
    input   BREADY  ;
  endclocking: cbMON

  modport M (
    output ARID    ,
    output ARADDR  ,
    output ARREGION,
    output ARLEN   ,
    output ARSIZE  ,
    output ARBURST ,
    output ARLOCK  ,
    output ARCACHE ,
    output ARPROT  ,
    output ARQOS   ,
    output ARVALID ,
    input  ARREADY ,
    input  RID     ,
    input  RDATA   ,
    input  RRESP   ,
    input  RLAST   ,
    input  RVALID  ,
    output RREADY  ,
    output AWID    ,
    output AWADDR  ,
    output AWREGION,
    output AWLEN   ,
    output AWSIZE  ,
    output AWBURST ,
    output AWLOCK  ,
    output AWCACHE ,
    output AWPROT  ,
    output AWQOS   ,
    output AWVALID ,
    input  AWREADY ,
    output WDATA   ,
    output WSTRB   ,
    output WLAST   ,
    output WVALID  ,
    input  WREADY  ,
    input  BID     ,
    input  BRESP   ,
    input  BVALID  ,
    output BREADY
  );

  modport S (
    input  ARID    ,
    input  ARADDR  ,
    input  ARREGION,
    input  ARLEN   ,
    input  ARSIZE  ,
    input  ARBURST ,
    input  ARLOCK  ,
    input  ARCACHE ,
    input  ARPROT  ,
    input  ARQOS   ,
    input  ARVALID ,
    output ARREADY ,
    output RID     ,
    output RDATA   ,
    output RRESP   ,
    output RLAST   ,
    output RVALID  ,
    input  RREADY  ,
    input  AWID    ,
    input  AWADDR  ,
    input  AWREGION,
    input  AWLEN   ,
    input  AWSIZE  ,
    input  AWBURST ,
    input  AWLOCK  ,
    input  AWCACHE ,
    input  AWPROT  ,
    input  AWQOS   ,
    input  AWVALID ,
    output AWREADY ,
    input  WDATA   ,
    input  WSTRB   ,
    input  WLAST   ,
    input  WVALID  ,
    output WREADY  ,
    output BID     ,
    output BRESP   ,
    output BVALID  ,
    input  BREADY
  );

  modport Monitor (clocking cbMON);

endinterface: AXI4

interface AXI4Lite #(
  int unsigned N = 4,
  int unsigned I = 1
)(
  input bit ACLK,
  input bit ARESETn
);
  logic           ARVALID;
  logic           ARREADY;
  logic  [32-1:0] ARADDR ;
  logic   [3-1:0] ARPROT ;
  logic           RVALID ;
  logic           RREADY ;
  logic [8*N-1:0] RDATA  ;
  logic   [2-1:0] RRESP  ;
  logic           AWVALID;
  logic           AWREADY;
  logic  [32-1:0] AWADDR ;
  logic   [3-1:0] AWPROT ;
  logic           WVALID ;
  logic           WREADY ;
  logic [8*N-1:0] WDATA  ;
  logic   [N-1:0] WSTRB  ;
  logic           BVALID ;
  logic           BREADY ;
  logic   [2-1:0] BRESP  ;

  clocking cbMON @(posedge ACLK);
    input  ARVALID;
    input  ARREADY;
    input  ARADDR ;
    input  ARPROT ;
    input  RVALID ;
    input  RREADY ;
    input  RDATA  ;
    input  RRESP  ;
    input  AWVALID;
    input  AWREADY;
    input  AWADDR ;
    input  AWPROT ;
    input  WVALID ;
    input  WREADY ;
    input  WDATA  ;
    input  WSTRB  ;
    input  BVALID ;
    input  BREADY ;
    input  BRESP  ;
  endclocking: cbMON

  modport M (
    output ARVALID,
    input  ARREADY,
    output ARADDR ,
    output ARPROT ,
    input  RVALID ,
    output RREADY ,
    input  RDATA  ,
    input  RRESP  ,
    output AWVALID,
    input  AWREADY,
    output AWADDR ,
    output AWPROT ,
    output WVALID ,
    input  WREADY ,
    output WDATA  ,
    output WSTRB  ,
    input  BVALID ,
    output BREADY ,
    input  BRESP
  );

  modport S (
    input  ARVALID,
    output ARREADY,
    input  ARADDR ,
    input  ARPROT ,
    output RVALID ,
    input  RREADY ,
    output RDATA  ,
    output RRESP  ,
    input  AWVALID,
    output AWREADY,
    input  AWADDR ,
    input  AWPROT ,
    input  WVALID ,
    output WREADY ,
    input  WDATA  ,
    input  WSTRB  ,
    output BVALID ,
    input  BREADY ,
    output BRESP
  );

  modport Monitor (clocking cbMON);
  
endinterface: AXI4Lite

interface AXI4Stream #(
  int unsigned N = 1,
  int unsigned I = 1,
  int unsigned D = 1,
  int unsigned U = 1
)(
  input bit ACLK,
  input bit ARESETn
);
  logic           TVALID;
  logic           TREADY;
  logic [8*N-1:0] TDATA;
  logic   [N-1:0] TSTRB;
  logic   [N-1:0] TKEEP;
  logic           TLAST;
  logic   [I-1:0] TID;
  logic   [D-1:0] TDEST;
  logic   [U-1:0] TUSER;
  
  clocking cbMON @(posedge ACLK);
    input  TVALID;
    input  TREADY;
    input  TDATA ;
    input  TSTRB ;
    input  TKEEP ;
    input  TLAST ;
    input  TID   ;
    input  TDEST ;
    input  TUSER ;
  endclocking: cbMON
  
  modport M (
    output TVALID,
    input  TREADY,
    output TDATA ,
    output TSTRB ,
    output TKEEP ,
    output TLAST ,
    output TID   ,
    output TDEST ,
    output TUSER
  );

  modport S (
    input  TVALID,
    output TREADY,
    input  TDATA ,
    input  TSTRB ,
    input  TKEEP ,
    input  TLAST ,
    input  TID   ,
    input  TDEST ,
    input  TUSER
  );

  modport Monitor (clocking cbMON);

endinterface: AXI4Stream
