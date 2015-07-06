module Axi4Master #(
  int unsigned N = 1,
  int unsigned I = 1
)(
  AXI4 intf
);

typedef struct packed {
  bit   [I-1:0] id    ;
  bit  [32-1:0] addr  ;
  bit   [4-1:0] region;
  bit   [8-1:0] len   ;
  bit   [3-1:0] size  ;
  bit   [2-1:0] burst ;
  bit           lock  ;
  bit   [4-1:0] cache ;
  bit   [3-1:0] prot  ;
  bit   [4-1:0] qos   ;
} ABeat;

typedef struct packed {
  bit   [I-1:0] id    ;
  bit   [2-1:0] resp  ;  
} BBeat;

typedef struct packed {
  bit   [I-1:0] id   ;
  bit [8*N-1:0] data;
  bit   [2-1:0] resp;
  bit           last;
} RBeat;

typedef struct packed {
  bit [8*N-1:0] data;
  bit   [N-1:0] strb;
  bit           last;
} WBeat;

  int AWDelay;
  int WDelay ;
  int BDelay ;
  int ARDelay;
  int RDelay ;
  
  ABeat AR_Q[$];
  RBeat  R_Q[$];
  ABeat AW_Q[$];
  WBeat  W_Q[$];
  BBeat  B_Q[$];
  
  task ARTransfer (
    input int     delay,
    input ABeat   ab
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARVALID  <= 1'b1;
    intf.ARID     <= ab.id    ;
    intf.ARADDR   <= ab.addr  ;
    intf.ARREGION <= ab.region;
    intf.ARLEN    <= ab.len   ;
    intf.ARSIZE   <= ab.size  ;
    intf.ARBURST  <= ab.burst ;
    intf.ARLOCK   <= ab.lock  ;
    intf.ARCACHE  <= ab.cache ;
    intf.ARPROT   <= ab.prot  ;
    intf.ARQOS    <= ab.qos   ;
    @(posedge intf.ACLK);
    while (!intf.ARREADY) @(posedge intf.ACLK);
    intf.ARVALID  <= 1'b0;
  endtask: ARTransfer
  
  task RTransfer (
    input int     delay,
    output RBeat  rb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RREADY <= 1'b1;
    while(!intf.RVALID) @(posedge intf.ACLK);
    rb.id   = intf.RID  ;
    rb.data = intf.RDATA;
    rb.resp = intf.RRESP;
    rb.last = intf.RLAST;
    intf.RREADY <= 1'b0;
  endtask: RTransfer

  task AWTransfer (
    input int   delay,
    input ABeat ab
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWVALID  <= 1'b1;
    intf.AWID     <= ab.id    ;
    intf.AWADDR   <= ab.addr  ;
    intf.AWREGION <= ab.region;
    intf.AWLEN    <= ab.len   ;
    intf.AWSIZE   <= ab.size  ;
    intf.AWBURST  <= ab.burst ;
    intf.AWLOCK   <= ab.lock  ;
    intf.AWCACHE  <= ab.cache ;
    intf.AWPROT   <= ab.prot  ;
    intf.AWQOS    <= ab.qos   ;
    @(posedge intf.ACLK);
    while (!intf.AWREADY) @(posedge intf.ACLK);
    intf.AWVALID  <= 1'b0;
  endtask: AWTransfer
  
  task WTransfer (
    input int   delay,
    input WBeat wb
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WVALID <= 1'b1;
    intf.WDATA  <= wb.data;
    intf.WSTRB  <= wb.strb;
    intf.WLAST  <= wb.last;
    @(posedge intf.ACLK);
    while (!intf.WREADY) @(posedge intf.ACLK);
    intf.WVALID <= 1'b0;
  endtask: WTransfer
  
  task BTransfer (
    input int    delay,
    output BBeat bb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BREADY <= 1'b1;
    while(!intf.BVALID) @(posedge intf.ACLK);
    bb.id   = intf.BID  ;
    bb.resp = intf.BRESP;
    intf.BREADY <= 1'b0;
  endtask: BTransfer
  
  task ARLoop;
    ABeat b;
    forever
    begin
      b = AR_Q.pop_back();
      ARTransfer(ARDelay, b);
    end
  endtask: ARLoop
  
  task RLoop;
    RBeat b;
    forever
    begin
      RTransfer(RDelay, b);
      R_Q.push_back(b);
    end
  endtask: RLoop

  task AWLoop;
    ABeat b;
    forever
    begin
      b = AW_Q.pop_back();
      AWTransfer(AWDelay, b);
    end
  endtask: AWLoop
  
  task WLoop;
    WBeat b;
    forever
    begin
      b = W_Q.pop_back();
      WTransfer(WDelay, b);
    end
  endtask: WLoop
  
  task BLoop;
    BBeat b;
    forever
    begin
      BTransfer(BDelay, b);
      B_Q.push_back(b);
    end
  endtask: BLoop
  
  task Run;
    fork
      ARLoop;
      RLoop;
      AWLoop;
      WLoop;
      BLoop;
    join
  endtask: Run
  
  task RBurst (
    input     [I-1:0] id,
    input int         len,
    inout byte        data[],
    inout bit [3-1:0] resp[]
  );
    bit        [I-1:0]        id_t;
    bit [255:0][N-1:0][8-1:0] data_t;
    bit        [2-1:0]        resp_t;
    bit                       last_t;
    int j=0;
    for (int i=0; i<256; i++) begin
//      RTransfer(0, id_t, data_t[j], resp_t, last_t);
      if (id_t == id) begin
        j++;
        if (last_t)
        
        break;
      end
    end
  endtask: RBurst

  task WBurst (
    input int   len,
    input byte  data[],
    input bit   strb[]
  );
    bit [N-1:0][7:0] data_t;
    bit [N-1:0]      strb_t;
    bit              last_t;
    for (int i=0; i<len; i++) begin
      for (int j=0; j<N; j++) begin
        data_t[j] = data[N*i+j];
        strb_t[j] = strb[N*i+j];
      end
      last_t = (i == (len -1));
//      WTransfer(0, data_t, strb_t, last_t);
    end
  endtask: WBurst
  
/*  
  task ReadTransaction (
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot,
    output bit [64-1:0] data,
    output bit  [3-1:0] resp
  );
    ARTransaction(ARDelay, addr, prot);
    RTransaction(RDelay, data, resp);
  endtask: ReadTransaction
  
  task WriteTransaction (
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot,
    input  bit [64-1:0] data,
    input  bit  [8-1:0] strb,
    output bit  [2-1:0] resp
  );
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction(WDelay, data, strb);
    join
    BTransaction(BDelay, resp);
  endtask: WriteTransaction
*/  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn) begin
      intf.ARID     <= {I{1'b0}};
      intf.ARADDR   <= 32'b0;
      intf.ARREGION <= 4'b0;
      intf.ARLEN    <= 8'b0;
      intf.ARSIZE   <= (N==1)?3'b000:(N==2)?3'b001:(N==4)?3'b010:(N==8)?3'b011:(N==16)?3'b100:(N==32)?3'b101:(N==64)?3'b110:3'b111;
      intf.ARBURST  <= 2'b01;
      intf.ARLOCK   <= 1'b0;
      intf.ARCACHE  <= 4'b0;
      intf.ARPROT   <= 3'b0;
      intf.ARQOS    <= 4'b0;
      intf.ARVALID  <= 1'b0;
      intf.RREADY   <= 1'b0;
      intf.AWID     <= {I{1'b0}};
      intf.AWADDR   <= 32'b0;
      intf.AWREGION <= 4'b0;
      intf.AWLEN    <= 8'b0;
      intf.AWSIZE   <= (N==1)?3'b000:(N==2)?3'b001:(N==4)?3'b010:(N==8)?3'b011:(N==16)?3'b100:(N==32)?3'b101:(N==64)?3'b110:3'b111;
      intf.AWBURST  <= 2'b01;
      intf.AWLOCK   <= 1'b0;
      intf.AWCACHE  <= 4'b0;
      intf.AWPROT   <= 3'b0;
      intf.AWQOS    <= 4'b0;
      intf.AWVALID  <= 1'b0;
      intf.WDATA    <= {N{8'b0}};
      intf.WSTRB    <= {N{1'b1}};
      intf.WLAST    <= 1'b0;
      intf.WVALID   <= 1'b0;
      intf.BREADY   <= 1'b0;
    end
  end
endmodule: Axi4Master

module Axi4Slave#(
  int unsigned N = 1,
  int unsigned I = 1
)(
  AXI4 intf
);
  int AWDelay;
  int WDelay ;
  int BDelay ;
  int ARDelay;
  int RDelay ;
  
  task ARTransfer (
    input  int          delay,
    output bit  [I-1:0] id    ,
    output bit [32-1:0] addr  ,
    output bit  [4-1:0] region,
    output bit  [8-1:0] len   ,
    output bit  [3-1:0] size  ,
    output bit  [2-1:0] burst ,
    output bit          lock  ,
    output bit  [4-1:0] cache ,
    output bit  [3-1:0] prot  ,
    output bit  [4-1:0] qos
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARREADY <= 1'b1;
    while (!intf.ARVALID) @(posedge intf.ACLK);
    id     = intf.ARID    ;
    addr   = intf.ARADDR  ;
    region = intf.ARREGION;
    len    = intf.ARLEN   ;
    size   = intf.ARSIZE  ;
    burst  = intf.ARBURST ;
    lock   = intf.ARLOCK  ;
    cache  = intf.ARCACHE ;
    prot   = intf.ARPROT  ;
    qos    = intf.ARQOS   ;
    intf.ARREADY <= 1'b0;
  endtask: ARTransfer
  
  task RTransfer (
    input  int           delay,
    input  bit   [I-1:0] id  ,
    input  bit [8*N-1:0] data,
    input  bit   [3'1:0] resp,
    input  bit           last
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RVALID <= 1'b1;
    intf.RID    <= id;
    intf.RDATA  <= data;
    intf.RRESP  <= resp;
    intf.RLAST  <= last;
    @(posedge intf.ACLK);
    while(!intf.RREADY) @(posedge intf.ACLK);
    intf.RVALID <= 1'b0;
  endtask: RTransfer

  task AWTransfer (
    input  int          delay,
    output bit  [I-1:0] id    ,
    output bit [32-1:0] addr  ,
    output bit  [4-1:0] region,
    output bit  [8-1:0] len   ,
    output bit  [3-1:0] size  ,
    output bit  [2-1:0] burst ,
    output bit          lock  ,
    output bit  [4-1:0] cache ,
    output bit  [3-1:0] prot  ,
    output bit  [4-1:0] qos
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWREADY <= 1'b1;
    while (!intf.AWVALID) @(posedge intf.ACLK);
    id     = intf.AWID;
    addr   = intf.AWADDR;
    region = intf.AWREGION;
    len    = intf.AWLEN;
    size   = intf.AWSIZE;
    burst  = intf.AWBURST;
    lock   = intf.AWLOCK;
    cache  = intf.AWCACHE;
    prot   = intf.AWPROT;
    qos    = intf.AWQOS;
    intf.AWREADY <= 1'b0;
  endtask: AWTransfer
  
  task WTransaer (
    input  int           delay,
    output bit [8*N-1:0] data,
    output bit   [N-1:0] strb,
    output bit           last
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WREADY <= 1'b1;
    while (!intf.WVALID) @(posedge intf.ACLK);
    data = intf.WDATA;
    strb = intf.WSTRB;
    last = intf.WLAST;
    intf.WREADY <= 1'b0;
  endtask: WTransaer
  
  task BTransfer (
    input  int         delay,
    input  bit [I-1:0] id  ,
    input  bit [2-1:0] resp
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BVALID <= 1'b1;
    intf.BID <= id;
    intf.BRESP <= resp;
    @(posedge intf.ACLK);
    while (!intf.BREADY) @(posedge intf.ACLK);
    intf.BVALID <= 1'b0;
  endtask: BTransfer
/*  
  task ReadRequest (
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot
  );
    ARTransaction(ARDelay, addr, prot);
  endtask: ReadRequest
  
  task ReadResponse (
    input  bit [32-1:0] data,
    input  bit  [2-1:0] resp
  );
    RTransaction(RDelay, data, resp);
  endtask: ReadResponse
  
  task WriteRequest (
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot,
    output bit [32-1:0] data,
    output bit  [4-1:0] strb
  );
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction(WDelay, data, strb);
    join
  endtask: WriteRequest
  
  task WriteResponse (
    input  bit [2-1:0] resp
  );
    BTransaction(BDelay, resp);
  endtask: WriteResponse
  
  task run;
  endtask: run
*/  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn) begin
      intf.ARREADY  <= 1'b0;
      intf.RID      <= {I{1'b0}};
      intf.RDATA    <= {N{8'b0}};
      intf.RRESP    <= 2'b0;
      intf.RLAST    <= 1'b0;
      intf.RVALID   <= 1'b0;
      intf.AWREADY  <= 1'b0;
      intf.WREADY   <= 1'b0;
      intf.BID      <= {I{1'b0}};
      intf.BRESP    <= 2'b0;
      intf.BVALID   <= 1'b0;
    end
  end
endmodule: Axi4Slave

module Axi4LiteMonitor#(
  int unsigned N = 1,
  int unsigned I = 1
)(
  AXI4Lite intf
);
  task run;
  endtask: run
  
endmodule: Axi4LiteMonitor
